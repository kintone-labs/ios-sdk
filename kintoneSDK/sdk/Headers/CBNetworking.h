//
//  CBNetworking.h
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

@class CBCredential;
@class CBError;

typedef void (^CBNetworkingSuccessBlockForJSONResponse)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^CBNetworkingFailureBlockForJSONResponse)(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON);
typedef void (^CBNetworkingSuccessBlockForHTTPResponse)(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject);
typedef void (^CBNetworkingFailureBlockForHTTPResponse)(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error);
typedef void (^CBNetworkingDownloadProgressBlock)(NSUInteger bytesRead , long long totalBytesRead , long long totalBytesExpectedToRead);
typedef void (^CBNetworkingUploadProgressBlock)(NSUInteger bytesWritten , long long totalBytesWritten , long long totalBytesExpectedToWrite);

/**
 非同期での HTTP 通信を行うクラスです。
 
 json でのレスポンス、バイナリデータでのレスポンスに特化したメソッドを提供します。リクエスト時の認証は 'CBCredential' を渡すことにより自動的に行われます。引数として指定した `NSOperationQueue` を管理することにより、処理の一括キャンセル等が可能となります。レスポンス受信後の処理は、Block で指定します。成功時、失敗時の Block を指定し、状況に応じた処理を Block 中に記述することが可能です。レスポンスステータスが 200 の場合は成功レスポンス、それ以外の場合は失敗レスポンスとして、各 Block が実行されます。
 
 通信中は、iOS デバイス上のステータスバーに indicator が表示されます。indicator は通信中のみ表示され、成功/失敗時の Block 処理では indicator は動作しません。
 
 ## 利用される Block の型
 
 型宣言された Block:
 
    // json での成功レスポンス用 Block
    typedef void (^CBNetworkingSuccessBlockForJSONResponse)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
    // json での失敗レスポンス用 Block
    typedef void (^CBNetworkingFailureBlockForJSONResponse)(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON);
    // 一般的な HTTP 成功レスポンス用 Block
    typedef void (^CBNetworkingSuccessBlockForHTTPResponse)(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject);
    // 一般的な HTTP 失敗レスポンス用 Block
    typedef void (^CBNetworkingFailureBlockForHTTPResponse)(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error);
    // ダウンロードの進捗を管理する Block
    typedef void (^CBNetworkingDownloadProgressBlock)(NSUInteger bytesRead , long long totalBytesRead , long long totalBytesExpectedToRead);
    // アップロードの進捗を管理する Block
    typedef void (^CBNetworkingUploadProgressBlock)(NSUInteger bytesWritten , long long totalBytesWritten , long long totalBytesExpectedToWrite);
 
 ## エラー
 
 レスポンスステータス 401 は BASIC 認証エラーとして解釈され、C_ERROR_00003 の 'CBError' を返します。cybozu.com の返す json 形式のエラーの場合、エラーコードを json レスポンスの code、message を recoverySuggestion として 'CBError' を返します。それ以外のエラーの場合、`NSError` をラップした形で `CBError` が返されます。
 
 ## ログ
 
 リクエスト、レスポンスのログは、`CBSdkLogLevelVerbose' レベルで出力されます。リクエストヘッダの `X-Cybozu-Authorization` 値、レスポンスヘッダで Set-Cookie される JSESSIONID、CB_OPENAUTH は '*****' で伏せた状態で出力されます。
 */
@interface CBNetworking : NSObject

/**
 json レスポンスを受け取ることを想定した HTTP リクエストメソッドです。
 
 @param request リクエスト
 @param credential 認証情報
 @param success 成功レスポンス時に実行される block
 @param failure 失敗レスポンス時に実行される block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
+ (void)sendRequestForJSONResponse:(NSURLRequest *)request
         credential:(CBCredential *)credential
            success:(CBNetworkingSuccessBlockForJSONResponse)success
            failure:(CBNetworkingFailureBlockForJSONResponse)failure
              queue:(NSOperationQueue *)queue;

/**
 バイナリデータダウンロードを想定した HTTP リクエストメソッドです。
 
 @param request リクエスト
 @param credential 認証情報
 @param success 成功レスポンス時に実行される block
 @param failure 失敗レスポンス時に実行される block
 @param download ダウンロードの進捗を管理する block
 @param output ダウンロードしたデータを処理する 'NSOutputStream'。ダウンロードしたデータの保存はこの引数で管理します。
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
+ (void)sendRequestForDownload:(NSURLRequest *)request
                    credential:(CBCredential *)credential
                       success:(CBNetworkingSuccessBlockForHTTPResponse)success
                       failure:(CBNetworkingFailureBlockForHTTPResponse)failure
                      download:(CBNetworkingDownloadProgressBlock)download
                        output:(NSOutputStream *)output
                         queue:(NSOperationQueue *)queue;

@end
