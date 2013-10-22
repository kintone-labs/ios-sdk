//
//  KintoneSite.m
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

#import "KintoneSite.h"

#import "CBCredential.h"
#import "KintoneApplication.h"

@implementation KintoneSite
{
    NSMutableDictionary *_kintoneApplications;
}

@synthesize cbCredential;

- (KintoneSite *)initWithCredential:(CBCredential *)credential
{
    assert(credential != nil);
    
    if (self = [super init]) {
        cbCredential = credential;
        _kintoneApplications = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (KintoneApplication *)kintoneApplication:(int)appId
{
    assert(appId >= 0);

    NSNumber *appIdNum = [NSNumber numberWithInt:appId];
    KintoneApplication *kintoneApplication = _kintoneApplications[appIdNum];

    if (kintoneApplication == nil) {
        kintoneApplication = [[KintoneApplication alloc] initWithAppId:appId kintoneSite:self];
        _kintoneApplications[appIdNum] = kintoneApplication;
    }
    
    return kintoneApplication;
}

@end
