//
//  CBKeychain.m
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

#import "CBKeychain.h"

#import <Security/Security.h>

@implementation CBKeychain

#pragma mark - set data

+ (BOOL)setData:(id)data type:(CFTypeRef)type query:(NSDictionary *)query error:(CBError* __autoreleasing *)error
{
    assert(data != nil);

    BOOL ret = NO;

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    
    if (status == errSecSuccess) {
        // already exist. update data.
        NSDictionary *attribute = @{(__bridge id)type: data};

        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attribute);

        if (status == errSecSuccess) {
            ret = YES;
        }
        else {
            *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
        }
    }
    else if (status == errSecItemNotFound) {
        // new data
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:query];
        attributes[(__bridge id)type] = data;
        attributes[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
        status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
        
        if (status == errSecSuccess) {
            ret = YES;
        }
        else {
            *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
        }
    }
    else {
        // something wrong
        *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
    }
    
    return ret;
}

+ (BOOL)setGenericPassword:(NSString *)password
                   service:(NSString *)service
                   account:(NSString *)account
                 attribute:(NSData *)attribute
                     error:(CBError* __autoreleasing *)error
{
    assert(![NSString isNilOrEmpty:service] && ![NSString isNilOrEmpty:account]);
    
    if ([NSString isNilOrEmpty:password]) {
        return NO;
    }

    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = service;
    query[(__bridge id)kSecAttrAccount] = account;
    if (attribute != nil) {
        query[(__bridge id)kSecAttrGeneric] = attribute;
    }
    
    return [CBKeychain setData:[password dataUsingEncoding:NSUTF8StringEncoding] type:kSecValueData query:query error:error];
}

+ (BOOL)setGenericAttirbuteForGenericPassword:(NSData *)attribute
                                      service:(NSString *)service
                                      account:(NSString *)account
                                        error:(CBError* __autoreleasing *)error
{
    assert(attribute != nil && ![NSString isNilOrEmpty:service] && ![NSString isNilOrEmpty:account]);
    
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: service,
                            (__bridge id)kSecAttrAccount: account};
    
    return [CBKeychain setData:attribute type:kSecAttrGeneric query:query error:error];
}

#pragma mark - get data

+ (NSDictionary *)dataWithQuery:(NSDictionary *)query error:(CBError* __autoreleasing *)error
{
    assert(query != nil);

    NSMutableDictionary *mutableQuery = [NSMutableDictionary dictionaryWithDictionary:query];
    mutableQuery[(__bridge id)kSecReturnData]          = (__bridge id)kCFBooleanTrue;
    mutableQuery[(__bridge id)kSecReturnAttributes]    = (__bridge id)kCFBooleanTrue;
    mutableQuery[(__bridge id)kSecReturnRef]           = (__bridge id)kCFBooleanTrue;
    mutableQuery[(__bridge id)kSecReturnPersistentRef] = (__bridge id)kCFBooleanTrue;
    
    CFDictionaryRef dictionaryRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)mutableQuery, (CFTypeRef *)&dictionaryRef);
    
    if (status == errSecSuccess) {
        return (__bridge_transfer NSDictionary *)dictionaryRef;
    }
    else if (status == errSecItemNotFound) {
        return nil;
    }
    else {
        // error occurred.
        *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
    }
    
    return nil;
}

+ (NSDictionary *)dataForGenericPasswordWithService:(NSString *)service account:(NSString *)account error:(CBError* __autoreleasing *)error
{
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: service,
                            (__bridge id)kSecAttrAccount: account};
    
    return [CBKeychain dataWithQuery:query error:error];
}

+ (NSString *)genericPasswordWithService:(NSString *)service account:(NSString *)account error:(CBError* __autoreleasing *)error
{
    NSDictionary *dictionary = [CBKeychain dataForGenericPasswordWithService:service account:account error:error];
    return [[NSString alloc] initWithData:dictionary[@"v_Data"] encoding:NSUTF8StringEncoding];
}

+ (NSData *)genericAttributeForGenericPasswordWithService:(NSString *)service account:(NSString *)account error:(CBError* __autoreleasing *)error
{
    NSDictionary *dictionary = [CBKeychain dataForGenericPasswordWithService:service account:account error:error];
    return dictionary[(__bridge id)kSecAttrGeneric];
}

+ (SecIdentityRef)identity:(__autoreleasing CBError **)error
{
    NSDictionary *query = @{(__bridge id)kSecClass:       (__bridge id)kSecClassIdentity,
                            (__bridge id)kSecReturnRef:   (__bridge id)kCFBooleanTrue};
    
    SecIdentityRef identity = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&identity);
    
    if (status == errSecSuccess) {
        return identity;
    }
    else if (status == errSecItemNotFound) {
        return NULL;
    }
    else {
        // error occurred.
        *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
    }
    
    return NULL;
}

#pragma mark - for identity

+ (BOOL)setIdentity:(SecIdentityRef)identity error:(CBError* __autoreleasing *)error
{
    NSDictionary *attributes = @{(__bridge id)kSecValueRef:       (__bridge id)identity,
                                 (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock};
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);

    if (status == errSecSuccess) {
        return YES;
    }
    else {
        *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
    }
    
    return NO;
}

+ (BOOL)deleteWithQuery:(NSDictionary *)query error:(CBError* __autoreleasing *)error
{
    assert(query != nil);
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess) {
        [CBLog sdkLogVerbose:@"Items are deleted. (queue:%@)", query];
        
        return YES;
    }
    else {
        *error = [CBError errorWithFormat:@"CBErrorCannotOperateKeychain", status];
    }
    
    return NO;
}

+ (BOOL)deleteWithSecClass:(CFTypeRef)secClass error:(CBError* __autoreleasing *)error
{
    assert(secClass != NULL);

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)secClass};
    return [CBKeychain deleteWithQuery:query error:error];
}

+ (BOOL)deleteAll:(CBError* __autoreleasing *)error
{
    // delete generic passwords
    if (![CBKeychain deleteWithSecClass:kSecClassGenericPassword error:error]) {
        return NO;
    }
    
    // delete internet passwords
    if (![CBKeychain deleteWithSecClass:kSecClassInternetPassword error:error]) {
        return NO;
    }
    
    // delete keys
    if (![CBKeychain deleteWithSecClass:kSecClassKey error:error]) {
        return NO;
    }
    
    // delete certificates
    if (![CBKeychain deleteWithSecClass:kSecClassCertificate error:error]) {
        return NO;
    }
    
    // delete identities
    if (![CBKeychain deleteWithSecClass:kSecClassIdentity error:error]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - for debug

+ (void)dumpWithQuery:(NSDictionary *)query
{
    assert(query != nil);
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    assert((status == errSecSuccess) == (result != NULL));
    
    [CBLog sdkLogVerbose:@"query: %@", query];
    if (result != NULL) {
        [CBLog sdkLogVerbose:@"%@", result];
        
        CFRelease(result);
    }
}

+ (void)dumpWithSecClass:(CFTypeRef)secClass
{
    assert(secClass != NULL);
    
    NSDictionary *query = @{(__bridge id)kSecClass:               (__bridge id)secClass,
                            (__bridge id)kSecMatchLimit:          (__bridge id)kSecMatchLimitAll,
                            (__bridge id)kSecReturnData:          (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecReturnAttributes:    (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecReturnRef:           (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecReturnPersistentRef: (__bridge id)kCFBooleanTrue};
    
    [CBKeychain dumpWithQuery:query];
}

+ (void)dumpAll
{
    [CBKeychain dumpWithSecClass:kSecClassGenericPassword];  // genp
    [CBKeychain dumpWithSecClass:kSecClassInternetPassword]; // inet
    [CBKeychain dumpWithSecClass:kSecClassKey];              // keys
    [CBKeychain dumpWithSecClass:kSecClassCertificate];      // cert
    [CBKeychain dumpWithSecClass:kSecClassIdentity];         // idnt
}

@end
