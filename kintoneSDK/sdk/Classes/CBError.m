//
//  KintoneError.m
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

#import "CBError.h"

#import "KintoneBundle.h"

@implementation CBError

@synthesize cbErrorCode;

static NSString * const CBErrorCodeErrorKey = @"CBErrorCodeErrorKey";
static NSString * const CBStackTraceErrorKey = @"CBStackTraceErrorKey";
static NSString * const CBErrorDomain = @"com.cybozu.error";

#pragma mark - create instance

+ (CBError *)errorWithFormat:(NSString *)key, ...
{
    va_list args;
    va_start(args, key);

    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"kintoneResources" withExtension:@"bundle"]];
    NSString *path = [bundle pathForResource:@"KintoneErrorMessages" ofType:@"plist"];
    NSDictionary *errorDetailResource = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *errorDetailDict = (NSDictionary *)[errorDetailResource objectForKey:key];
    NSAssert(nil != errorDetailDict, @"Specified error message is not defined.", nil);

    NSString *code = [NSString stringWithString:errorDetailDict[@"ErrorCodeKey"]];
    NSString *description = [[NSString alloc] initWithFormat:errorDetailDict[@"DescriptionKey"] arguments:args];
    NSString *reason = [[NSString alloc] initWithFormat:errorDetailDict[@"FailureReasonKey"] arguments:args];
    NSString *suggestion = [[NSString alloc] initWithFormat:errorDetailDict[@"RecoverySuggestionKey"] arguments:args];
    
    va_end(args);
    
    return [CBError errorWithCode:code description:description failureReason:reason recoverySuggestion:suggestion];
}

+ (CBError *)errorWithNSError:(NSError *)error
{
    if ([error isKindOfClass:[self class]]) {
        return (CBError *)error;
    }
    
    return [CBError errorWithCode:[NSString stringWithFormat:@"%d", [error code]]
                      description:[error localizedDescription]
                    failureReason:[error localizedFailureReason]
               recoverySuggestion:[error localizedRecoverySuggestion]];
}

+ (CBError *)errorWithCode:(NSString *)code description:(NSString *)description failureReason:(NSString *)failureReason recoverySuggestion:(NSString *)recoverySuggestion
{
    if ([NSString isNilOrEmpty:code]) {
        code = @"";
    }
    if ([NSString isNilOrEmpty:description]) {
        description = @"";
    }
    if ([NSString isNilOrEmpty:failureReason]) {
        failureReason = @"";
    }
    if ([NSString isNilOrEmpty:recoverySuggestion]) {
        recoverySuggestion = @"";
    }
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description,
                               NSLocalizedFailureReasonErrorKey: failureReason,
                               NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion,
                               CBErrorCodeErrorKey: code,
                               CBStackTraceErrorKey: [NSThread callStackSymbols]};
    
    CBError *error = [CBError errorWithDomain:CBErrorDomain code:-1 userInfo:userInfo];

    [CBLog logError:@"%@", error];
    
    return error;
}

#pragma mark - instance methods

- (NSString *)cbErrorCode
{
    return self.userInfo[CBErrorCodeErrorKey];
}

- (NSString *)errorMessage
{
    NSMutableString *message = [NSMutableString new];

    // description
    NSString *element = [self userInfo][NSLocalizedDescriptionKey];
    if (![NSString isNilOrEmpty:element]) {
        [message appendFormat:@"%@", element];
    }

    // error code
    element = [self userInfo][CBErrorCodeErrorKey];
    if (![NSString isNilOrEmpty:element]) {
        if (![NSString isNilOrEmpty:message]) {
            [message appendString:@"\n\n"];
        }
        [message appendFormat:@"%@\n", KintoneLocalizedString(@"[Error code]")];
        [message appendString:element];
    }

    // cause
    element = [self userInfo][NSLocalizedFailureReasonErrorKey];
    if (![NSString isNilOrEmpty:element]) {
        if (![NSString isNilOrEmpty:message]) {
            [message appendString:@"\n\n"];
        }
        [message appendFormat:@"%@\n", KintoneLocalizedString(@"[Cause]")];
        [message appendString:element];
    }
    
    // countermeasure
    element = [self userInfo][NSLocalizedRecoverySuggestionErrorKey];
    if (![NSString isNilOrEmpty:element]) {
        if (![NSString isNilOrEmpty:message]) {
            [message appendString:@"\n\n"];
        }
        [message appendFormat:@"%@\n", KintoneLocalizedString(@"[Countermeasure]")];
        [message appendString:element];
    }
    
    return message;
}

- (UIAlertView *)alertView
{
    return [[UIAlertView alloc] initWithTitle:KintoneLocalizedString(@"Error")
                                      message:[self errorMessage]
                                     delegate:nil
                            cancelButtonTitle:@"Close"
                            otherButtonTitles:nil];
}

@end
