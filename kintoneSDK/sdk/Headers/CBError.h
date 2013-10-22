//
//  KintoneError.h
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
 エラークラスです。
 
 `CBError` としてエラーが作成されるとログレベル `CBLogLevelError` としてログ出力されます。`CBError` を利用することで、リソース管理された専用のエラー情報の提供、`NSError` のラッピング、`UIAlertView` としてエラー表示が可能となります。
 */

@interface CBError : NSError

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 `CBError` のエラーコードです。
 
 `CBError` の場合、`code` は `-1` となり、本プロパティに kintone SDK で用意したエラーコードが設定されます。`NSError` をベースに生成された `CBError` の場合、本プロパティと `code` は同じ値となります。
 */
@property (nonatomic, copy, readonly) NSString *cbErrorCode;

/// ---------------------------------
/// @name CBError インスタンスの生成
/// ---------------------------------

/**
 指定された `key` で `CBError` インスタンスを生成します。
 
 `key` は `kintoneResouces.bundle` の `KintoneErrorMessages.plist` で定義されたものを利用します。`KintoneErrorMessages.plist` で定義する文言フォーマットは ["Formatting String Objects"](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/FormatStrings.html)に従い、フォーマットに含まれる引数は `key` に続けて記述することで指定できます。
 
 @param key `kintoneResouces.bundle` の `KintoneErrorMessages.plist` で定義された `Key`
 @param ... エラーメッセージフォーマット引数。`DescriptionKey`, `FailureReasonKey`, `RecoverySuggestionKey` の順に割り当てられます。指定された `key` が `KintoneErrorMessages.plist` に存在しない場合、`assert` で失敗します。
 
 @return 新規作成された `CBError` インスタンス
 */
+ (CBError *)errorWithFormat:(NSString *)key, ...;

/**
 指定された `NSError` をラップして `CBError` として返します。
 
 @param error `NSError`
 
 @return 新規作成された `CBError` インスタンス
 */
+ (CBError *)errorWithNSError:(NSError *)error;

/**
 指定したエラー情報で `CBError` インスタンスを生成します。
 
 `CBError` インスタンスを生成するローレベルメソッドです。
 
 @param code エラーコード
 @param description エラー詳細
 @param failureReason 原因
 @param recoverySuggestion 対策
 
 @return 新規作成された `CBError` インスタンス
 */
+ (CBError *)errorWithCode:(NSString *)code description:(NSString *)description failureReason:(NSString *)failureReason recoverySuggestion:(NSString *)recoverySuggestion;

/// ---------------------------------
/// @name UIAlertView の生成
/// ---------------------------------

/**
 エラー情報を含む UIAlertView を返します。
 
 alert view には、設定されたエラー詳細、エラーコード、原因、対策が準備表示され、各情報が `nil` もしくは空文字の場合には、その情報は非表示となります。
 */
- (UIAlertView *)alertView;

@end
