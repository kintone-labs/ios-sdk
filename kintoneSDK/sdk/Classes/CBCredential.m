//
//  KintoneCredential.m
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

#import "CBCredential.h"

#import "CBKeychain.h"

@implementation CBCredential
{
    NSString *_password;
    NSString *_basicAuthUser;
    NSString *_basicAuthPassword;
    NSURLCredential *_basicAuthCredential;
    NSURLCredential *_clientCertificateCredential;
}

@synthesize domain = _domain;
@synthesize user = _user;

static NSString * const BASICAUTHUSER_KEY = @"basicAuthUser";
static NSString * const BASICAUTHPASSWORD_KEY = @"basicAuthPassword";

- (CBCredential *)initWithDomain:(NSString *)domain user:(NSString *)user
{
    assert(![NSString isNilOrEmpty:domain] && ![NSString isNilOrEmpty:user]);

    if (self = [super init]) {
        _domain = domain;
        _user = user;
        _password = nil;
        _basicAuthUser = nil;
        _basicAuthPassword = nil;
        _basicAuthCredential = nil;
        _clientCertificateCredential = nil;
    }
    
    return self;
}

#pragma mark - get data

- (NSString *)password:(CBError* __autoreleasing *)error
{
    if (_password == nil) {
        _password = [CBKeychain genericPasswordWithService:_domain account:_user error:error];
    }
    
    return _password;
}

- (NSString *)genericAttributeWithKey:(NSString *)key error:(CBError* __autoreleasing *)error
{
    assert(![NSString isNilOrEmpty:key]);

    NSData *genericAttributeData = [CBKeychain genericAttributeForGenericPasswordWithService:_domain account:_user error:error];
    NSDictionary *genericAttribute = [NSKeyedUnarchiver unarchiveObjectWithData:genericAttributeData];
    return genericAttribute[key];
}

- (NSString *)basicAuthUser:(CBError* __autoreleasing *)error
{
    if (_basicAuthUser == nil) {
        _basicAuthUser = [self genericAttributeWithKey:BASICAUTHUSER_KEY error:error];
    }
    
    return _basicAuthUser;
}

- (NSString *)basicAuthPassword:(CBError* __autoreleasing *)error
{
    if (_basicAuthPassword == nil) {
        _basicAuthPassword = [self genericAttributeWithKey:BASICAUTHPASSWORD_KEY error:error];
    }
    
    return _basicAuthPassword;
}

#pragma mark - set data

- (BOOL)setPassword:(NSString *)password error:(CBError* __autoreleasing *)error
{
    BOOL ret = [CBKeychain setGenericPassword:password service:_domain account:_user attribute:nil error:error];
    if (ret) {
        _password = password;
    }
    
    return ret;
}

- (BOOL)setGenericAttribute:(NSString *)attribute key:(NSString *)key error:(CBError* __autoreleasing *)error
{
    assert(![NSString isNilOrEmpty:key]);

    // get generic attribute from Keychain
    NSData *genericAttributeData = [CBKeychain genericAttributeForGenericPasswordWithService:_domain account:_user error:nil];
    NSMutableDictionary *genericAttribute;
    if (genericAttributeData == nil) {
        genericAttribute = [NSMutableDictionary dictionary];
    }
    else {
        genericAttribute = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:genericAttributeData]];
    }
    
    if ([NSString isNilOrEmpty:attribute]) {
        // remove attribute from generic attribute dictionary
        [genericAttribute removeObjectForKey:key];
    }
    else {
        // update attribute
        genericAttribute[key] = attribute;
    }
    genericAttributeData = [NSKeyedArchiver archivedDataWithRootObject:genericAttribute];
    
    return [CBKeychain setGenericAttirbuteForGenericPassword:genericAttributeData service:_domain account:_user error:error];
}

- (BOOL)setBasicAuthUser:(NSString *)user error:(CBError* __autoreleasing *)error
{
    BOOL ret = [self setGenericAttribute:user key:BASICAUTHUSER_KEY error:error];
    if (ret) {
        _basicAuthUser = user;
    }
    
    return ret;
}

- (BOOL)setBasicAuthPassword:(NSString *)password error:(CBError* __autoreleasing *)error
{
    BOOL ret = [self setGenericAttribute:password key:BASICAUTHPASSWORD_KEY error:error];
    if (ret) {
        _basicAuthPassword = password;
    }
    
    return ret;
}

#pragma mark - about client certificate

- (BOOL)importClientCertificateWithPath:(NSString *)path password:(NSString *)password error:(CBError* __autoreleasing *)error
{
    assert(![NSString isNilOrEmpty:path]);

    return [self importClientCertificate:[NSData dataWithContentsOfFile:path] password:password error:error];
}

- (BOOL)importClientCertificate:(NSData *)certificate password:(NSString *)password error:(CBError* __autoreleasing *)error
{
    assert(certificate != nil);

    NSDictionary *options = @{(__bridge id)kSecImportExportPassphrase: password};
    
    CFArrayRef itemsRef = NULL;
    OSStatus status = SecPKCS12Import((__bridge CFDataRef)certificate, (__bridge CFDictionaryRef)options, &itemsRef);
    NSArray *items = [NSArray arrayWithArray:(__bridge_transfer NSArray *)itemsRef];
    
    if (status == errSecSuccess) {
        [CBLog sdkLogVerbose:@"Certificate has been imported by specified password"];
        
        // delete old certificate
        BOOL ret = [CBKeychain deleteWithSecClass:kSecClassIdentity error:error];
        if (!ret) {
            return NO;
        }

        // add new certificate
        NSDictionary *pkcs12Dictionary = items[0];
        SecIdentityRef identity = (__bridge SecIdentityRef)pkcs12Dictionary[(__bridge id)kSecImportItemIdentity];
        ret = [CBKeychain setIdentity:identity error:error];
        if (!ret) {
            return NO;
        }
        [CBLog sdkLogVerbose:@"Certificate has been imported to Keychain."];
        
        // clear credential
        _clientCertificateCredential = nil;
    }
    else {
        // error occurred.
        *error = [CBError errorWithFormat:@"CBErrorCannotImportCertificate", status];
    }
    
    return NO;
}

#pragma mark - get credential

- (NSURLCredential *)basicAuthCredential:(CBError* __autoreleasing *)error
{
    if (_basicAuthCredential == nil) {
        _basicAuthCredential = [NSURLCredential credentialWithUser:[self basicAuthUser:error]
                                                          password:[self basicAuthPassword:error]
                                                       persistence:NSURLCredentialPersistenceForSession];
    }
    
    return _basicAuthCredential;
}

- (NSURLCredential *)clientCertificateCredential:(CBError* __autoreleasing *)error
{
    if (_clientCertificateCredential == nil) {
        SecIdentityRef identity = [CBKeychain identity:error];
        if (identity != NULL) {
            _clientCertificateCredential = [NSURLCredential credentialWithIdentity:identity certificates:nil persistence:NSURLCredentialPersistenceForSession];
        }
    }
    
    return _clientCertificateCredential;
}

#pragma mark - clear credentials

- (BOOL)clear:(CBError* __autoreleasing *)error
{
    _password = nil;
    _basicAuthUser = nil;
    _basicAuthPassword = nil;
    _basicAuthCredential = nil;
    _clientCertificateCredential = nil;
    return [CBKeychain deleteAll:error];
}

@end
