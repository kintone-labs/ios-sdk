//
//  KintoneAPI.h
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
#import "CBNetworking.h"

@class KintoneApplication;
@class KintoneFile;
@class KintoneQuery;
@class KintoneRecord;
@class CBCredential;
@class CBError;

/**
 kintone の API をコールするクラスです。
 
 内部で `CBNetworking` を呼び出します。`success`, `failure` Block、エラー、ログ等については `CBNetworking` を参照してください。
 
 ## API の呼び出し
 
 API は非同期で動作します。block により成功レスポンス/失敗レスポンス後の処理を記述できます。
 
 例:
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [CBLog logVerbose:@"success"];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        [CBLog logVerbose:@"failure"];
 
        // show error dialog if failure
        UIAlertView *alert = [error alertView];
        [alert show];
    };
 
    [kintoneApplication.kintoneAPI record:1 success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 ## NSOperationQueue による API 呼び出しの直列化
 
 ファイルのダウンロード、アップロードを行うような場合、複数の API を直列に実行することになります。`KintoneAPI` では複数の API の呼び出しをまとめる `NSOperationQueue` を引数として渡すようにしています。kintone SDK では、同時実行 operation 数を 1 にし、確実に１つずつの operation しか動作しないシングルトンの queue を [CBOperationQueue sharedNonConcurrentQueue] として用意しています。この queue を利用することにより、複数の API を直列に実行することが可能となります。
 
 但し、API 成功/失敗レスポンス後に動作する success / failure Block はこの queue とは独立して動作します。これら Block の処理の完了後に次の API を呼び出したい場合、Block の中で次の API を呼び出すことにより、連続した処理が可能となります。`fileDownload:success:failure:download:output:queue:` に実装例があるので、参考にしてください。
 */

@interface KintoneAPI : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 紐付けられた kintone アプリです。
 */
@property (nonatomic, weak, readonly) KintoneApplication *kintoneApplication;

/**
 API コール時に利用する User-Agent です。
 
 User-Agent のデフォルトフォーマット:
 
    <UIWebView User-Agent> + " kintoneSDK/" + <kintone SDK バージョン> + " " + <bundle 名> + "/" + <bundle バージョン>

    // 例
    User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403 kintoneSDK/1.0.0 sample/1.0.0
 
 User-Agent が指定された場合のフォーマット:
 
    <UIWebView User-Agent> + " kintoneSDK/" + <kintone SDK バージョン> + " " + <指定された userAgent>

    // 例
    kintoneAPI.userAgent = @"sample";
 
    User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403 kintoneSDK/1.0.0 sample
 */
@property (nonatomic) NSString *userAgent;

- (KintoneAPI *)initWithKintoneApplication:(KintoneApplication *)kintoneApplication;

/// ---------------------------------
/// @name APIs
/// ---------------------------------

/**
 kintone アプリのフォーム情報を取得します。
 
 取得したフォーム情報は `[KitoneField fieldsFromJSON:]` によりフィールドの code を key とし `KintoneField` を値とした `NSDictionary` として取得できます。
 
 例:
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *fields = [KintoneField fieldsFromJSON:JSON];
        [CBLog logVerbose:@"fields = %@", fields];
    };
 
    [kintoneApplication.kintoneAPI form:success failure:nil queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)form:(CBNetworkingSuccessBlockForJSONResponse)success failure:(CBNetworkingFailureBlockForJSONResponse)failure queue:(NSOperationQueue *)queue;

/**
 kintone アプリの指定したレコード番号のデータを取得します。
 
 受信した json データは `[KintoneRecord kintoneRecordFromJSON:]` により `KintoneRecord` オブジェクトとして取得できます。各フィールド値は `[KintoneRecord fields]` にセットされた `KintoneField` から取得できます。
 
 例:
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        KintoneRecord *record = [KintoneRecord kintoneRecordFromJSON:JSON];
        // 取得した全フィールドを表示
        for (id key in record.fields.keyEnumerator) {
            KintoneField *field = (KintoneField *)record.fields[key];
            [CBLog logVerbose:@"key = %@, value = %@", key, field.value];
        }
        // レコード番号を表示
        [CBLog logVerbose:@"record number = %@", record.recordNumber.value];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        //
    };
 
    [kintoneApplication.kintoneAPI record:1 success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param recordId 取得対象の kintone アプリレコード番号
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)record:(int)recordId success:(CBNetworkingSuccessBlockForJSONResponse)success failure:(CBNetworkingFailureBlockForJSONResponse)failure queue:(NSOperationQueue *)queue;

/**
 kintone アプリからレコードを一括取得します。
 
 `fields` としてフィールドコードの `NSArray` を渡す点を除き、`recordsWithFields:query:success:failure:queue:` と同等です。
 
 @param fields レスポンスとして取得したいフィールドコードを `NSString` として指定
 @param query 検索クエリ文字列。`KintoneQueue kintoneQuery` より取得可能。
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)records:(NSArray *)fields
          query:(NSString *)query
        success:(CBNetworkingSuccessBlockForJSONResponse)success
        failure:(CBNetworkingFailureBlockForJSONResponse)failure
          queue:(NSOperationQueue *)queue;

/**
 kintone アプリからレコードを一括取得します。
 
 queue を直接文字列で指定できることを除き、`recordsWithFields:kintoneQuery:success:failure:queue:` と同等です。
 
 @param fields レスポンスとして取得したいフィールドを `KintoneField` として指定
 @param query 検索クエリ文字列。`[KintoneQueue kintoneQuery]` より取得可能。
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)recordsWithFields:(NSArray *)fields
                    query:(NSString *)query
                  success:(CBNetworkingSuccessBlockForJSONResponse)success
                  failure:(CBNetworkingFailureBlockForJSONResponse)failure
                    queue:(NSOperationQueue *)queue;

/**
 kintone アプリからレコードを一括取得します。
 
 受信した json データは `[KintoneRecord kintoneRecordsFromJSON:]` により、`KintoneRecord` の `NSArray` として取得できます。
 
 例:
 
    // single line text field
    NSDictionary *properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneSingleLineTextFieldType],
                                 @"code" : @"Single_line_text"};
    KintoneField *field1 = [[KintoneField alloc] initWithProperties:properties];
    // radio button field
    properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneRadioButtonFieldType],
                   @"code" : @"Single_choice"};
    KintoneField *field2 = [[KintoneField alloc] initWithProperties:properties];
 
    // 以下の query を生成
    // (Single_line_text = "test") and (Single_choice in ("sample2"))
    KintoneQuery *q = [KintoneQuery new];
    [q where:
        [q and:
            [q eq:field1 value:@"test"],
            [q in:field2 value:@[@"sample2"]], nil
        ]
    ];
    [q limit:1];
    [q offset:1];
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *records = [KintoneRecord kintoneRecordsFromJSON:JSON];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        //
    };
 
    [kintoneApplication.kintoneAPI recordsWithFields:@[field1] kintoneQuery:q success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param fields レスポンスとして取得したいフィールドを `KintoneField` として指定
 @param query 検索クエリ
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)recordsWithFields:(NSArray *)fields
             kintoneQuery:(KintoneQuery *)query
                  success:(CBNetworkingSuccessBlockForJSONResponse)success
                  failure:(CBNetworkingFailureBlockForJSONResponse)failure
                    queue:(NSOperationQueue *)queue;

/**
 kintone アプリへレコードを登録します。
 
 `fieldJSON` として json 形式の登録レコードを渡す点を除き、`insertWithRecord:success:failure:queue:` と同等です。
 
 @param fieldJSON json 形式の登録レコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)insert:(NSDictionary *)fieldJSON
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue;

/**
 kintone アプリへレコードを登録します。
 
 例:
 
    // この例では新規に KintoneField インスタンスを作成していますが、KintoneRecord 等から KintoneField が取得できるようならそちらを利用するとよいです
    // single line text field
    CBError* __autoreleasing error1 = nil;
    NSDictionary *properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneSingleLineTextFieldType],
                                 @"code" : @"Single_line_text"};
    KintoneField *field1 = [[KintoneField alloc] initWithProperties:properties];
    // KintoneField へ setValue することにより、field の properties が正しくセットされているならセットした値の validation を実行できます
    BOOL ret1 = [field1 setValue:@"test" error:&error1];
 
    // radio button field
    CBError* __autoreleasing error2 = nil;
    properties = @{@"type"    : [KintoneField fieldTypeNameForFieldType:KintoneRadioButtonFieldType],
                   @"code"    : @"Single_choice",
                   @"options" : @[@"sample1", @"sample2"]};
    KintoneField *field2 = [[KintoneField alloc] initWithProperties:properties];
    BOOL ret2 = [field2 setValue:@"sample2" error:&error2];
 
    if (ret1 && ret2) {
        KintoneRecord *record = [KintoneRecord new];
        [record addField:field1];
        [record addField:field2];
 
        CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //
        };
        CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            //
        };
 
        [kintoneApplication.kintoneAPI insertWithRecord:record success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
    }
    else {
        // validation error
    }
 
 @param record 登録するレコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)insertWithRecord:(KintoneRecord *)record
                 success:(CBNetworkingSuccessBlockForJSONResponse)success
                 failure:(CBNetworkingFailureBlockForJSONResponse)failure
                   queue:(NSOperationQueue *)queue;

/**
 kintone アプリへレコードを一括登録します。
 
 `insert:success:failure:queue:` とほぼ同等です。登録するレコードを json 形式の `NSArray` として指定します。

 @param fieldJSON json 形式の登録レコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkInsert:(NSArray *)fieldJSON
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue;

/**
 kintone アプリへレコードを一括登録します。
 
 `insertWithRecord:success:failure:queue:` とほぼ同等です。登録するレコードを `KintoneRecord` の `NSArray` として指定します。
 
 例:
 
    [kintoneApplication.kintoneAPI bulkInsertWithRecords:@[record1, record2] success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param records `KintoneRecord` 形式の登録レコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkInsertWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue;

/**
 kintone アプリの指定されたレコードを更新します。
 
 更新対象のレコード番号を指定する点を除き、`insert:success:failure:queue:` と同様です。
 
 @param recordId 更新対象レコード番号
 @param fieldJSON json 形式の登録レコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)update:(int)recordId
     fieldJSON:(NSDictionary *)fieldJSON
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue;

/**
 kintone アプリの指定されたレコードを更新します。
 
 更新対象のレコード番号を指定する点を除き、`insertWithRecord:success:failure:queue:` と同等です。

 @param recordId 更新対象レコード番号
 @param record 登録するレコード
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)update:(int)recordId
        record:(KintoneRecord *)record
       success:(CBNetworkingSuccessBlockForJSONResponse)success
       failure:(CBNetworkingFailureBlockForJSONResponse)failure
         queue:(NSOperationQueue *)queue;

/**
 kintone アプリの指定されたレコードを一括更新します。
 
 `update:fieldJSON:success:failure:queue:` とほぼ同様です。更新する `fieldJSON` にレコード番号を含めた json 形式のデータを指定する必要があります。
 
 @param fieldJSON 更新対象のレコード番号が含まれた json 形式データ
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkUpdate:(NSArray *)fieldJSON
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue;

/**
 kintone アプリの指定されたレコードを一括更新します。
 
 `update:record:success:failure:queue:` とほぼ同様です。更新する `KintoneRecord` にレコード番号の `KintoneField` をセットした `NSArray` を指定する必要があります。
 
 例:
 
    CBError* __autoreleasing error1 = nil;
    NSDictionary *properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneSingleLineTextFieldType],
                                 @"code" : @"Single_line_text"};
    KintoneField *field1 = [[KintoneField alloc] initWithProperties:properties];
    BOOL ret1 = [field1 setValue:@"bulk update" error:&error1];
    // KintoneRecordNumberField の生成
    properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneRecordNumberFieldType],
                   @"code" : @"Record_number"};
    KintoneField *field2 = [[KintoneField alloc] initWithProperties:properties];
    BOOL ret2 = [field2 setValue:@1 error:&error1];
    KintoneField *field3 = [[KintoneField alloc] initWithProperties:properties];
    BOOL ret3 = [field3 setValue:@2 error:&error1];
 
    if (ret1 && ret2 && ret3) {
        KintoneRecord *record1 = [KintoneRecord new];
        [record1 addField:field1];
        [record1 addField:field2];
 
        KintoneRecord *record2 = [KintoneRecord new];
        [record2 addField:field1];
        [record2 addField:field3];
 
        CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //
        };
        CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            //
        };
 
        [kintoneApplication.kintoneAPI bulkUpdateWithRecords:@[record1, record2] success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
    }
 
 @param records 更新対象のレコード番号フィールド `KintoneRecordNumberField` がセットされた `KintoneRecord`
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkUpdateWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue;

/**
 指定されたレコードを kintone アプリより一括削除します。
 
 削除対象をレコード番号を `NSArray` として指定する点を除き、`bulkDeleteWithRecords:success:failure:queue:` と同様です。
 
 @param recordIds 削除対象のレコード番号 'NSNumber'
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkDelete:(NSArray *)recordIds
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue;

/**
 指定されたレコードを kintone アプリより一括削除します。
 
 `bulkUpdateWithRecords:success:failure:queue:` と同様に、レコード番号の `KintoneField` をセットした `KintoneRecord` を指定します。
 
 例:
 
    // KintoneRecordNumberField を生成
    NSDictionary *properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneRecordNumberFieldType],
                                 @"code" : @"Record_number"};
    KintoneField *field1 = [[KintoneField alloc] initWithProperties:properties];
    // レコード番号 1 をセット
    BOOL ret1 = [field1 setValue:@1 error:nil];
    KintoneField *field2 = [[KintoneField alloc] initWithProperties:properties];
    // レコード番号 2 をセット
    BOOL ret2 = [field2 setValue:@2 error:nil];
 
    if (ret1 && ret2) {
        // KintoneRecordNumberField を KintoneRecord にセット
        KintoneRecord *record1 = [KintoneRecord new];
        [record1 addField:field1];
 
        KintoneRecord *record2 = [KintoneRecord new];
        [record2 addField:field2];
 
        CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //
        };
        CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            //
        };
 
        [kintoneApplication.kintoneAPI bulkDeleteWithRecords:@[record1, record2] success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
    }

 @param records 削除対象のレコード番号フィールド `KintoneRecordNumberField` がセットされた `KintoneRecord`
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)bulkDeleteWithRecords:(NSArray *)records
                      success:(CBNetworkingSuccessBlockForJSONResponse)success
                      failure:(CBNetworkingFailureBlockForJSONResponse)failure
                        queue:(NSOperationQueue *)queue;

/**
 kintone アプリ上の指定されたファイルをダウンロードします。
 
 ファイルのダウンロードは、一旦レコードの取得等で入手した `fileKey` を指定することで可能となります。レコードの取得で生成された `KintoneRecord` より `[KintoneFileField value]` を取得すると、`KintoneFile` としてファイル情報を操作できるようになります。ダウンロードするファイルは、引数として渡す `NSOutputStream` でコントロールします。
 
 例:
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        KintoneRecord *record = [KintoneRecord kintoneRecordFromJSON:JSON];
 
        // attachment files
        KintoneField *field = (KintoneField *)record.fields[@"Attachment"];
        NSArray *files = (NSArray *)field.value;
 
        if (files > 0) { // 添付ファイルあり
            KintoneFile *file = (KintoneFile *)files[0];
 
            // "Documents" 配下にダウンロードファイルを保存する
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
            NSString *downloadFile = [baseDir stringByAppendingPathComponent:file.name];
            NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:downloadFile append:NO];
 
            // ファイルダウンロードのレスポンスは json ではないため、block も別のものとなる
            CBNetworkingSuccessBlockForHTTPResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
                //
            };
            CBNetworkingFailureBlockForHTTPResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error) {
                //
            };
 
            [kintoneApplication.kintoneAPI fileDownload:file.fileKey
                                                success:success
                                                failure:failure
                                               download:nil
                                                 output:output
                                                  queue:[CBOperationQueue sharedNonConcurrentQueue]];
        }
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        //
    };
 
    [kintoneApplication.kintoneAPI record:3 success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param fileKey ダウンロードする fileKey
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param download ダウンロードの進捗を管理する Block
 @param output ダウンロードしたデータを管理する `NSOutputStream`
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)fileDownload:(NSString *)fileKey
             success:(CBNetworkingSuccessBlockForHTTPResponse)success
             failure:(CBNetworkingFailureBlockForHTTPResponse)failure
            download:(CBNetworkingDownloadProgressBlock)download
              output:(NSOutputStream *)output
               queue:(NSOperationQueue *)queue;

/**
 ファイルを kintone アプリへアップロードします。
 
 `fileUploadWithFile:success:failure:queue:` と同等です。`KintoneFile` に代わり、アップロードするファイルの情報を直接指定します。
 
 @param fileData アップロードするファイルデータ
 @param fileName アップロードするファイル名
 @param contentType アップロードするファイルの mime type
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)fileUpload:(NSData *)fileData
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType
           success:(CBNetworkingSuccessBlockForJSONResponse)success
           failure:(CBNetworkingFailureBlockForJSONResponse)failure
             queue:(NSOperationQueue *)queue;

/**
 ファイルを kintone アプリへアップロードします。
 
 アップロードするデータをセットした `KintoneFile` を指定し、レスポンス `JSON` を `[KintoneFile setFileKeyWithJSONDictionary:]` に渡すことにより、`fileKey` のセットされた `KintoneFile` を取得できます。この `KintoneFile` をセットした `KintoneFileField` を含む `KintoneRecord` を kintone アプリへ登録/更新することでファイルのアップロードが可能となります。
 
 例：
 
    // "Documents/sample.png" をアップロード
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *filePath = [baseDir stringByAppendingPathComponent:@"sample.png"];
    NSData *data = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    KintoneFile *file = [[KintoneFile alloc] initWithData:data name:@"sample.png" contentType:@"image/png"];
 
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // fileKey を KintoneFile にセット
        [file setFileKeyWithJSONDictionary:JSON];
 
        NSDictionary *properties = @{@"type" : [KintoneField fieldTypeNameForFieldType:KintoneFileFieldType],
                                     @"code" : @"Attachment"};
        KintoneFileField *field = [[KintoneFileField alloc] initWithProperties:properties];
        // file をフィールドに追加
        [field addFile:file];
        // アップロードするファイルが複数ある場合には、更に追加することが可能
        // [field addFile:file2];
 
        // KintoneFileField をセットした KintoneRecord を作成
        KintoneRecord *record = [KintoneRecord new];
        [record addField:field];
 
        // レコード登録、各 Block は省略
        [kintoneApplication.kintoneAPI insertWithRecord:record success:nil failure:nil queue:[CBOperationQueue sharedNonConcurrentQueue]];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        //
    };
 
    [kintoneApplication.kintoneAPI fileUploadWithFile:file success:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
 
 @param file アップロードファイルのデータがセットされた `KintoneFile`
 @param success 成功レスポンス時に実行される Block
 @param failure 失敗レスポンス時に実行される Block
 @param queue リクエスト処理に利用される `NSOperationQueue`
 */
- (void)fileUploadWithFile:(KintoneFile *)file
                   success:(CBNetworkingSuccessBlockForJSONResponse)success
                   failure:(CBNetworkingFailureBlockForJSONResponse)failure
                     queue:(NSOperationQueue *)queue;

@end
