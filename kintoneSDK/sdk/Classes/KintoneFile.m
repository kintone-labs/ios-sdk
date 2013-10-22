//
//  KintoneFile.m
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

#import "KintoneFile.h"

@implementation KintoneFile

- (KintoneFile *)initWithProperties:(NSDictionary *)properties
{
    if (self = [super init]) {
        _contentType = properties[@"contentType"];
        _fileKey     = properties[@"fileKey"];
        _name        = properties[@"name"];
        _size        = [properties[@"size"] intValue];
        _deleted     = NO;
    }
    
    return self;
}

- (KintoneFile *)initWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType
{
    if (self = [super init])
    {
        _data        = data;
        _name        = name;
        _contentType = contentType;
        _fileKey     = nil;
        _deleted     = NO;
    }
    
    return self;
}

- (NSDictionary *)json
{
    return @{@"fileKey" : _fileKey};
}

- (void)setFileKeyWithJSONDictionary:(NSDictionary *)json
{
    _fileKey  = json[@"fileKey"];
}

@end
