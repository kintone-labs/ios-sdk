//
//  CBNetworking.m
//
//  Copyright 2013 Cybozu
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "CBNetworking.h"

#import "CBCredential.h"

#import "AFNetworking.h"

@implementation CBNetworking

+ (void)sendRequestForJSONResponse:(NSURLRequest *)request
                        credential:(CBCredential *)credential
                           success:(CBNetworkingSuccessBlockForJSONResponse)success
                           failure:(CBNetworkingFailureBlockForJSONResponse)failure
                             queue:(NSOperationQueue *)queue
{
    // wrap blocks for logging and creating error object
    CBNetworkingSuccessBlockForJSONResponse successBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

        [self log:request response:response responseObject:JSON];

        if (success) {
            success(request, response, JSON);
        }
    };
    void (^failureBlock)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

        [self log:request response:response responseObject:JSON];

        if (failure) {
            CBError *cbError = nil;
        
            if ([response statusCode] == 401) {
                // basic authentication error (status code: 401)
                cbError = [CBError errorWithFormat:@"CBErrorFailBasicAuthentication"];
            }
            else if ([JSON isKindOfClass:[NSDictionary class]]) {
                // kintone or Slash error
                id errorCode = JSON[@"code"];
                id recoverySuggestion = JSON[@"message"];
                if (errorCode != nil && recoverySuggestion != nil) {
                    cbError = [CBError errorWithCode:errorCode description:nil failureReason:nil recoverySuggestion:recoverySuggestion];
                }
            }
            
            // NSError
            if (cbError == nil) {
                cbError = [CBError errorWithNSError:error];
            }
        
            failure(request, response, cbError, JSON);
        }
    };
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:successBlock failure:failureBlock];
    [self setOptimizedBlocks:operation credential:credential];

    // start the network activity indicator in the status bar
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    // send request
    [queue addOperation:operation];
}

+ (void)sendRequestForDownload:(NSURLRequest *)request
                    credential:(CBCredential *)credential
                       success:(CBNetworkingSuccessBlockForHTTPResponse)success
                       failure:(CBNetworkingFailureBlockForHTTPResponse)failure
                      download:(CBNetworkingDownloadProgressBlock)download
                        output:(NSOutputStream *)output
                         queue:(NSOperationQueue *)queue
{
    // wrap blocks for logging and creating error object
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

        [self log:operation.request response:operation.response responseObject:nil];

        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    };
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        id responseObject = nil;
        id responseJSON = nil;
        if ([operation.responseData length] > 0 && [operation isFinished]) {
            if (operation.responseString) {
                NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                
                if (data) {
                    if ([NSJSONSerialization isValidJSONObject:data]) {
                        responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        responseJSON = responseObject;
                    }
                    else {
                        responseObject = operation.responseString;
                    }
                } else {
                    //
                }
            }
        }

        [self log:operation.request response:operation.response responseObject:responseJSON ? responseJSON : responseObject];

        if (failure) {
            CBError *cbError = nil;
            
            if ([operation.response statusCode] == 401) {
                // basic authentication error (status code: 401)
                cbError = [CBError errorWithFormat:@"CBErrorFailBasicAuthentication"];
            }
            else if (responseJSON) {
                // kintone or Slash error
                id errorCode = responseJSON[@"code"];
                id recoverySuggestion = responseJSON[@"message"];
                if (errorCode != nil && recoverySuggestion != nil) {
                    cbError = [CBError errorWithCode:errorCode description:nil failureReason:nil recoverySuggestion:recoverySuggestion];
                }
            }
        
            // NSError
            if (cbError == nil) {
                cbError = [CBError errorWithNSError:error];
            }
            
            failure(operation.request, operation.response, cbError);
        }
    };
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = output;
    [self setOptimizedBlocks:operation credential:credential];
    [operation setCompletionBlockWithSuccess:successBlock failure:failureBlock];
    if (download) {
        [operation setDownloadProgressBlock:download];
    }
    
    // start the network activity indicator in the status bar
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    // send request
    [queue addOperation:operation];
}

+ (void)setOptimizedBlocks:(AFURLConnectionOperation *)operation credential:(CBCredential *)credential
{
    // ignore server certificate validation, support basic authentication and client certificate
    [operation setAuthenticationAgainstProtectionSpaceBlock:^(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
        if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
            // basic authentication
            // actually, this condition won't be used.
            return YES;
        }
        else if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
        {
            // client certificate
            return YES;
        }
        
        // other
        return NO;
    }];
    
    // set credential
    [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
            // basic authentication
            [challenge.sender useCredential:[credential basicAuthCredential:nil] forAuthenticationChallenge:challenge];
        }
        else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
        {
            // client certificate
            [challenge.sender useCredential:[credential clientCertificateCredential:nil] forAuthenticationChallenge:challenge];
        }
    }];
    
    // disable cache
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return nil;
    }];
}

+ (void)log:(NSURLRequest *)request response:(NSHTTPURLResponse *)response responseObject:(id)responseObject
{
    // request log
    [CBLog sdkLogVerbose:@"request URL: %@", request.URL];
    for (id key in request.allHTTPHeaderFields.keyEnumerator) {
        if ([key isEqualToString:@"X-Cybozu-Authorization"]) {
            // obscure the value
            [CBLog sdkLogVerbose:@"request header: \"X-Cybozu-Authorization\" = \"*****\""];
        }
        else {
            [CBLog sdkLogVerbose:@"request header: \"%@\" = \"%@\"", key, request.allHTTPHeaderFields[key]];
        }
    }
    [CBLog sdkLogVerbose:@"request method: %@", request.HTTPMethod];
    if (request.HTTPBody != nil) {
        [CBLog sdkLogVerbose:@"request body: %@", [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil]];
    }

    // response log
    [CBLog sdkLogVerbose:@"status code: %d", [response statusCode]];
    for (id key in response.allHeaderFields.keyEnumerator) {
        if ([key isEqualToString:@"Set-Cookie"]) {
            // obscure session cookies
            NSArray *values = [response.allHeaderFields[key] componentsSeparatedByString:@";"];
            NSMutableArray *obscuredValues = [NSMutableArray arrayWithCapacity:values.count];
            for (NSString *value in values) {
                NSString *obscuredValue = value;
                NSRange range = [value rangeOfString:@"JSESSIONID="];
                if (range.location != NSNotFound) {
                    NSRange maskRange = NSMakeRange(range.location + range.length, value.length - range.location - range.length);
                    obscuredValue = [value stringByReplacingCharactersInRange:maskRange withString:@"*****"];
                }
                range = [value rangeOfString:@"CB_OPENAUTH="];
                if (range.location != NSNotFound) {
                    NSRange maskRange = NSMakeRange(range.location + range.length, value.length - range.location - range.length);
                    obscuredValue = [value stringByReplacingCharactersInRange:maskRange withString:@"*****"];
                }
                [obscuredValues addObject:obscuredValue];
            }
            [CBLog sdkLogVerbose:@"response header: \"Set-Cookie\" = \"%@\"", [obscuredValues componentsJoinedByString:@";"]];
        }
        else {
            [CBLog sdkLogVerbose:@"response header: \"%@\" = \"%@\"", key, response.allHeaderFields[key]];
        }
    }
    if (responseObject) {
        [CBLog sdkLogVerbose:@"response body: %@", responseObject];
    }
}

@end
