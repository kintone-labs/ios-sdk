//
//  CBKeychain.h
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

#import <Foundation/Foundation.h>

@class CBError;

@interface CBKeychain : NSObject

+ (BOOL)setData:(id)data type:(CFTypeRef)type query:(NSDictionary *)query error:(CBError* __autoreleasing *)error;
+ (BOOL)setGenericPassword:(NSString *)password
                   service:(NSString *)service
                   account:(NSString *)account
                 attribute:(NSData *)attribute
                     error:(CBError* __autoreleasing *)error;
+ (BOOL)setGenericAttirbuteForGenericPassword:(NSData *)attribute
                                      service:(NSString *)service
                                      account:(NSString *)account
                                        error:(CBError* __autoreleasing *)error;
+ (NSDictionary *)dataWithQuery:(NSDictionary *)query error:(CBError* __autoreleasing *)error;
+ (NSString *)genericPasswordWithService:(NSString *)service account:(NSString *)account error:(CBError* __autoreleasing *)error;
+ (NSData *)genericAttributeForGenericPasswordWithService:(NSString *)service account:(NSString *)account error:(CBError* __autoreleasing *)error;
+ (SecIdentityRef)identity:(CBError* __autoreleasing *)error;
+ (BOOL)setIdentity:(SecIdentityRef)identity error:(CBError* __autoreleasing *)error;
//+ (BOOL)importClientCertificateWithPath:(NSString *)path password:(NSString *)password error:(KintoneError* __autoreleasing *)error;
+ (BOOL)deleteWithSecClass:(CFTypeRef)secClass error:(CBError* __autoreleasing *)error;
+ (BOOL)deleteAll:(CBError* __autoreleasing *)error;
+ (void)dumpWithSecClass:(CFTypeRef)secClass;
+ (void)dumpAll;

@end
