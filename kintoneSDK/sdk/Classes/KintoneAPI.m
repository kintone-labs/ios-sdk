//
//  KintoneAPI.m
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

#import "KintoneAPI.h"

#import "CBCredential.h"
#import "CBOperationQueue.h"
#import "KintoneApplication.h"
#import "KintoneField.h"
#import "KintoneFile.h"
#import "KintoneRecord.h"
#import "KintoneSite.h"

#import "AFNetworking.h"
#import "GTMBase64.h"
#import "GTMNSString+URLArguments.h"

#define KINTONE_API_PATH(file)  [[NSString alloc] initWithFormat:@"%@%@", API_BASEPATH, (file)]

@interface KintoneAPI ()
@property (nonatomic, weak, readwrite) KintoneApplication *kintoneApplication;
@end

@implementation KintoneAPI
{
    NSString *_cybozuAuthorization;
}

static NSString * const API_BASEPATH = @"/k/v1/";

@synthesize userAgent = _userAgent;

- (KintoneAPI *)initWithKintoneApplication:(KintoneApplication *)newKintoneApplication
{
    assert(newKintoneApplication != nil);

    if (self = [super init]) {
        self.kintoneApplication = newKintoneApplication;
    }
    
    return self;
}

+ (NSString *)baseUserAgent
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [[NSString alloc] initWithString:[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"kintoneResources" withExtension:@"bundle"]];
    NSString *path = [bundle pathForResource:@"kintoneResources-Info" ofType:@"plist"];
    NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfFile:path];

    return [userAgent stringByAppendingFormat:@" %@/%@", infoDictionary[@"kintoneSdkName"], infoDictionary[(__bridge NSString *)kCFBundleVersionKey]];
}

- (NSString *)userAgent
{
    if (_userAgent == nil) {
        // create User-Agent as '<baseUserAgent> <bundle name>/<bundle version>'
        NSDictionary *mainBundleInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *bundleName = [mainBundleInfoDictionary[(__bridge NSString *)kCFBundleNameKey] gtm_stringByEscapingForURLArgument];
        NSString *bundleVersion = [mainBundleInfoDictionary[(__bridge NSString *)kCFBundleVersionKey] gtm_stringByEscapingForURLArgument];
        _userAgent = [[KintoneAPI baseUserAgent] stringByAppendingFormat:@" %@/%@", bundleName, bundleVersion];
    }
    
    return _userAgent;
}

- (void)setUserAgent:(NSString *)userAgent
{
    if (![NSString isNilOrEmpty:userAgent]) {
        _userAgent = [[KintoneAPI baseUserAgent] stringByAppendingFormat:@" %@", userAgent];
    }
}

- (NSString *)cybozuAuthorization
{
    // X-Cybozu-Authorization: base64(user:password)
    if (_cybozuAuthorization == nil) {
        CBError* __autoreleasing error = nil;
        NSString *password = [self.kintoneApplication.kintoneSite.cbCredential password:&error];
        NSString *authString = [[NSString alloc] initWithFormat:@"%@:%@", self.kintoneApplication.kintoneSite.cbCredential.user, password];
        _cybozuAuthorization = [GTMBase64 stringByEncodingData:[NSData dataWithBytes:[authString UTF8String] length:[authString length]]];
    }
    
    return _cybozuAuthorization;
}

- (NSMutableURLRequest *)createRequest:(NSString *)path requestMethod:(NSString *)requestMethod
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@%@", self.kintoneApplication.kintoneSite.cbCredential.domain, path]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:requestMethod];
    [request setValue:[self cybozuAuthorization] forHTTPHeaderField:@"X-Cybozu-Authorization"];
    [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (NSMutableURLRequest *)createRequestWithJSON:(NSDictionary *)json path:(NSString *)path requestMethod:(NSString *)requestMethod
{
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    NSMutableURLRequest *request = [self createRequest:path requestMethod:requestMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestData];

    return request;
}

- (NSMutableURLRequest *)createFileUploadRequest:(NSData *)fileData fileName:(NSString *)fileName contentType:(NSString *)contentType
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.kintoneApplication.kintoneSite.cbCredential.domain]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:KINTONE_API_PATH(@"file.json")
                                                                   parameters:nil
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:contentType];
                                                    }];
    [request setValue:[self cybozuAuthorization] forHTTPHeaderField:@"X-Cybozu-Authorization"];
    [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (void)form:(CBNetworkingSuccessBlockForJSONResponse)success failure:(CBNetworkingFailureBlockForJSONResponse)failure queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"form.json");
    NSURLRequest *request = [self createRequest:[[NSString alloc] initWithFormat:@"%@?app=%d", path, self.kintoneApplication.appId] requestMethod:@"GET"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)record:(int)recordId success:(CBNetworkingSuccessBlockForJSONResponse)success failure:(CBNetworkingFailureBlockForJSONResponse)failure queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"record.json");
    NSURLRequest *request = [self createRequest:[NSString stringWithFormat:@"%@?app=%d&id=%d", path, self.kintoneApplication.appId, recordId]  requestMethod:@"GET"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)records:(NSArray *)fields
          query:(NSString *)query
        success:(CBNetworkingSuccessBlockForJSONResponse)success
        failure:(CBNetworkingFailureBlockForJSONResponse)failure
          queue:(NSOperationQueue *)queue
{
    NSMutableString *params = [NSMutableString stringWithFormat:@"app=%d", self.kintoneApplication.appId];
    for (int i = 0; i < fields.count; i++) {
        NSString *field = fields[i];
        [params appendFormat:@"&%@=%@", [[NSString stringWithFormat:@"fields[%d]", i] gtm_stringByEscapingForURLArgument], [field gtm_stringByEscapingForURLArgument]];
    }
    if ([query length] > 0) {
        [params appendFormat:@"&query=%@", [query gtm_stringByEscapingForURLArgument]];
    }

    NSString *path = KINTONE_API_PATH(@"records.json");
    NSURLRequest *request = [self createRequest:[[NSString alloc] initWithFormat:@"%@?%@", path, params] requestMethod:@"GET"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)recordsWithFields:(NSArray *)fields
                    query:(NSString *)query
                  success:(CBNetworkingSuccessBlockForJSONResponse)success
                  failure:(CBNetworkingFailureBlockForJSONResponse)failure
                    queue:(NSOperationQueue *)queue
{
    NSMutableArray *fieldCodeArray = [NSMutableArray arrayWithCapacity:fields.count];
    for (id value in fields) {
        assert([value isKindOfClass:[KintoneField class]]);
        
        KintoneField *field = (KintoneField *)value;
        [fieldCodeArray addObject:field.code];
    }
    
    [self records:fieldCodeArray query:query success:success failure:failure queue:queue];
}

- (void)recordsWithFields:(NSArray *)fields
             kintoneQuery:(KintoneQuery *)query
                  success:(CBNetworkingSuccessBlockForJSONResponse)success
                  failure:(CBNetworkingFailureBlockForJSONResponse)failure
                    queue:(NSOperationQueue *)queue
{
    [self recordsWithFields:fields query:query.kintoneQuery success:success failure:failure queue:queue];
}

- (void)insert:(NSDictionary *)fieldJSON
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue
{
#warning TODO: validate required fields

    NSString *path = KINTONE_API_PATH(@"record.json");
    NSDictionary *json = @{@"app"    : @(self.kintoneApplication.appId),
                           @"record" : fieldJSON};
    
    NSURLRequest *request = [self createRequestWithJSON:json path:path requestMethod:@"POST"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)insertWithRecord:(KintoneRecord *)record
                 success:(CBNetworkingSuccessBlockForJSONResponse)success
                 failure:(CBNetworkingFailureBlockForJSONResponse)failure
                   queue:(NSOperationQueue *)queue
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:record.fields.count];
    for (id key in record.fields.keyEnumerator) {
        KintoneField *field = (KintoneField *)record.fields[key];
        [json addEntriesFromDictionary:field.json];
    }

    [self insert:json success:success failure:failure queue:queue];
}

- (void)bulkInsert:(NSArray *)fieldJSON
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"records.json");
    NSDictionary *json = @{@"app"     : @(self.kintoneApplication.appId),
                           @"records" : fieldJSON};
    
#warning TODO: validate required fields
    
    NSURLRequest *request = [self createRequestWithJSON:json path:path requestMethod:@"POST"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)bulkInsertWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue
{
    NSMutableArray *json = [NSMutableArray arrayWithCapacity:records.count];
    for (id value in records) {
        assert([value isKindOfClass:[KintoneRecord class]]);
        
        KintoneRecord *record = (KintoneRecord *)value;
        NSMutableDictionary *fieldDict = [NSMutableDictionary dictionaryWithCapacity:record.fields.count];
        for (id key in record.fields.keyEnumerator) {
            KintoneField *field = (KintoneField *)record.fields[key];
            [fieldDict addEntriesFromDictionary:field.json];
        }
        
        [json addObject:fieldDict];
    }

    [self bulkInsert:json success:success failure:failure queue:queue];
}

- (void)update:(int)recordId
     fieldJSON:(NSDictionary *)fieldJSON
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"record.json");
    NSDictionary *json = @{@"app"    : @(self.kintoneApplication.appId),
                           @"id"     : @(recordId),
                           @"record" : fieldJSON};
    
#warning TODO: validate required fields
    
    NSURLRequest *request = [self createRequestWithJSON:json path:path requestMethod:@"PUT"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)update:(int)recordId
        record:(KintoneRecord *)record
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:record.fields.count];
    for (id key in record.fields.keyEnumerator) {
        KintoneField *field = (KintoneField *)record.fields[key];
        if (field.type == KintoneRecordNumberFieldType) {
            continue;
        }
        [json addEntriesFromDictionary:field.json];
    }
    
    [self update:recordId fieldJSON:json success:success failure:failure queue:queue];
}

- (void)bulkUpdate:(NSArray *)fieldJSON
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"records.json");
    NSDictionary *json = @{@"app"     : @(self.kintoneApplication.appId),
                           @"records" : fieldJSON};
    
#warning TODO: validate required fields
    
    NSURLRequest *request = [self createRequestWithJSON:json path:path requestMethod:@"PUT"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)bulkUpdateWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue
{
    NSMutableArray *json = [NSMutableArray arrayWithCapacity:records.count];
    for (id value in records) {
        assert([value isKindOfClass:[KintoneRecord class]]);
        
        KintoneRecord *record = (KintoneRecord *)value;
        NSMutableDictionary *fieldDict = [NSMutableDictionary dictionaryWithCapacity:record.fields.count];
        for (id key in record.fields.keyEnumerator) {
            KintoneField *field = (KintoneField *)record.fields[key];
            if (field.type == KintoneRecordNumberFieldType) {
                continue;
            }
            [fieldDict addEntriesFromDictionary:field.json];
        }

        NSDictionary *recordDict = @{@"id"     : record.recordNumber.value,
                                     @"record" : fieldDict};
        
        [json addObject:recordDict];
    }

    [self bulkUpdate:json success:success failure:failure queue:queue];
}

- (void)bulkDelete:(NSArray *)recordIds
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue
{
    NSMutableString *params = [NSMutableString stringWithFormat:@"app=%d", self.kintoneApplication.appId];
    for (int i = 0; i < recordIds.count; i++) {
        assert([recordIds[i] isKindOfClass:[NSNumber class]]);
        
        NSNumber *recordId = (NSNumber *)recordIds[i];
        [params appendFormat:@"&%@=%d", [NSString stringWithFormat:@"ids[%d]", i], [recordId intValue]];
    }
    
    NSString *path = KINTONE_API_PATH(@"records.json");
    NSURLRequest *request = [self createRequest:[[NSString alloc] initWithFormat:@"%@?%@", path, params] requestMethod:@"DELETE"];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)bulkDeleteWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue
{
    NSMutableArray *recordIds = [NSMutableArray arrayWithCapacity:records.count];
    for (id value in records) {
        assert([value isKindOfClass:[KintoneRecord class]]);
        
        KintoneRecord *record = (KintoneRecord *)value;
        [recordIds addObject:record.recordNumber.value];
    }
    
    [self bulkDelete:recordIds success:success failure:failure queue:queue];
}

- (void)fileDownload:(NSString *)fileKey
             success:(CBNetworkingSuccessBlockForHTTPResponse)success
             failure:(CBNetworkingFailureBlockForHTTPResponse)failure
            download:(CBNetworkingDownloadProgressBlock)download
              output:(NSOutputStream *)output
               queue:(NSOperationQueue *)queue
{
    NSString *path = KINTONE_API_PATH(@"file.json");
    NSString *param = [NSString stringWithFormat:@"fileKey=%@", fileKey];

    NSURLRequest *request = [self createRequest:[[NSString alloc] initWithFormat:@"%@?%@", path, param] requestMethod:@"GET"];
    [CBNetworking sendRequestForDownload:request
                              credential:self.kintoneApplication.kintoneSite.cbCredential
                                 success:success
                                 failure:failure
                                download:download
                                  output:output
                                   queue:queue];
}

- (void)fileUpload:(NSData *)fileData
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue
{
    NSURLRequest *request = [self createFileUploadRequest:fileData fileName:fileName contentType:contentType];
    [CBNetworking sendRequestForJSONResponse:request credential:self.kintoneApplication.kintoneSite.cbCredential success:success failure:failure queue:queue];
}

- (void)fileUploadWithFile:(KintoneFile *)file
                   success:(CBNetworkingSuccessBlockForJSONResponse)success
                   failure:(CBNetworkingFailureBlockForJSONResponse)failure
                     queue:(NSOperationQueue *)queue
{
    [self fileUpload:file.data fileName:file.name contentType:file.contentType success:success failure:failure queue:queue];
}

@end
