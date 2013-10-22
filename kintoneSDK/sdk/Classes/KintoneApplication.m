//
//  KintoneApplication.m
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

#import "KintoneApplication.h"

#import "KintoneAPI.h"
#import "KintoneSite.h"

@interface KintoneApplication ()

@property (nonatomic, readwrite) int appId;
@property (nonatomic, readwrite) KintoneSite *kintoneSite;
@property (nonatomic, readwrite) KintoneAPI *kintoneAPI;

@end

@implementation KintoneApplication

@synthesize appId;
@synthesize kintoneSite;
@synthesize kintoneAPI = _kintoneAPI;

- (KintoneApplication *)initWithAppId:(int)newAppId kintoneSite:(KintoneSite *)newKintoneSite
{
    assert(newAppId >= 0 && newKintoneSite != nil);

    if (self = [super init]) {
        self.appId = newAppId;
        self.kintoneSite = newKintoneSite;
        _kintoneAPI = nil;
    }
    
    return self;
}

- (KintoneAPI *)kintoneAPI
{
    if (_kintoneAPI == nil) {
        _kintoneAPI = [[KintoneAPI alloc] initWithKintoneApplication:self];
    }
    
    return _kintoneAPI;
}

@end
