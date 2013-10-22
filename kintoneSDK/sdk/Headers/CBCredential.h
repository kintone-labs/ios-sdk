//
//  KintoneCredential.h
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

/**
 `CBCredential` は Web サービスにおいて必要となる認証情報を Keychain を利用し、管理します。 対象ドメイン、ユーザー名の組合せをキーに、パスワード、BASIC 認証情報、クライアント証明書の管理ができます。
 */

@class CBError;

@interface CBCredential : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 認証先ドメインです。
 
 `CBCredential` インスタンス生成時に渡した `domain` がセットされます。
 */
@property (nonatomic, copy, readonly) NSString *domain;

/**
 認証対象ユーザーです。
 
 `CBCredential` インスタンス生成時に渡した `user` がセットされます。
 */
@property (nonatomic, copy, readonly) NSString *user;

/// ---------------------------------
/// @name CBCredential インスタンスの生成と初期化
/// ---------------------------------

/**
 指定されたドメイン、ユーザーで `CBCredential` を初期化します。
 
 @param domain 認証先ドメインです。`nil` もしくは空文字の場合、`assert` で失敗します。
 @param user 認証対象ユーザーです。`nil` もしくは空文字の場合、`assert` で失敗します。
 
 @return 新規作成された `CBCredential` インスタンス
 */
- (CBCredential *)initWithDomain:(NSString *)domain user:(NSString *)user;

/// ---------------------------------
/// @name 認証情報の取得
/// ---------------------------------

/**
 パスワードを取得します。
 
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return パスワード
 */
- (NSString *)password:(CBError* __autoreleasing *)error;

/**
 BASIC 認証ユーザー名を取得します。
 
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return BASIC 認証ユーザー名
 */
- (NSString *)basicAuthUser:(CBError* __autoreleasing *)error;

/**
 BASIC 認証パスワードを取得します。
 
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return BASIC 認証パスワード
 */
- (NSString *)basicAuthPassword:(CBError* __autoreleasing *)error;

/// @name 認証情報の保存

/**
 パスワードを Keychain に保存します。
 
 @param password パスワード
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return 保存に成功した場合は `YES`、失敗もしくは `password` が `nil`、空文字の場合 `NO`
 */
- (BOOL)setPassword:(NSString *)password error:(CBError* __autoreleasing *)error;

/**
 BASIC 認証ユーザー名を Keychain に保存します。
 
 @param user BASIC 認証ユーザー名
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return 保存に成功した場合は `YES`、それ以外で `NO`
 */
- (BOOL)setBasicAuthUser:(NSString *)user error:(CBError* __autoreleasing *)error;

/**
 BASIC 認証パスワードを Keychain に保存します。
 
 @param password BASIC 認証パスワード
 @param error Keychain にアクセスできない場合、`C_ERROR_00001` のエラーを返します。
 
 @return 保存に成功した場合は `YES`、それ以外で `NO`
 */
- (BOOL)setBasicAuthPassword:(NSString *)password error:(CBError* __autoreleasing *)error;

/**
 クライアント証明書を Keychain に保存します。
 
 @param path クライアント証明書のパス。`nil`、空文字、もしくは証明書が存在しない場合は `assert` で失敗します。
 @param password クライアント証明書パスワード
 @param error Keychain にアクセスできない場合は `C_ERROR_00001`、証明書をインポートできない場合は `C_ERROR_00002` のエラーを返します。
 
 @return 保存に成功した場合は `YES`、それ以外で `NO`
 */
- (BOOL)importClientCertificateWithPath:(NSString *)path password:(NSString *)password error:(CBError* __autoreleasing *)error;

/**
 BASIC 認証用 credential を取得します。
 
 @param error Keychain にアクセスできない場合 `C_ERROR_00001` のエラーを返します。
 
 @return BASIC 認証用 credential。初回取得時にエラーが発生した場合には `nil` を返します。
 */
- (NSURLCredential *)basicAuthCredential:(CBError* __autoreleasing *)error;

/**
 クライアント証明書用 credential を取得します。
 
 @param error Keychain にアクセスできない場合 `C_ERROR_00001` のエラーを返します。
 
 @return クライアント証明書用 credential。初回取得時にエラーが発生した場合には `nil` を返します。
 */
- (NSURLCredential *)clientCertificateCredential:(CBError* __autoreleasing *)error;

/**
 認証情報をクリアし、Keychain よりアクセス可能な全ての情報を削除します。
 
 @param error Keychain にアクセスできない場合 `C_ERROR_00001` のエラーを返します。
 
 @return クリアに成功した場合は `YES`、それ以外で `NO`
 */
- (BOOL)clear:(CBError* __autoreleasing *)error;

@end
