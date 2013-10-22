//
//  KintoneFile.h
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
 kintone ファイルクラスです。
 
 フィールドへの添付ファイルを操作するために利用します。`KintoneFileField` とセットで利用することを想定しています。
 */
@interface KintoneFile : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 ファイルの mime type です。
 */
@property (nonatomic, copy, readonly) NSString *contentType;

/**
 fileKey です。kintone アプリ上でファイルを操作するために利用するキーです。
 */
@property (nonatomic, copy, readonly) NSString *fileKey;

/**
 ファイル名です。
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 ファイルサイズです。
 */
@property (nonatomic, readonly) int size;

/**
 ファイルデータです。
 */
@property (nonatomic, readonly) NSData *data;

/**
 削除対象ファイルフラグです。YES の場合、削除対象となります。
 */
@property (nonatomic) bool deleted;

/// ---------------------------------
/// @name KintoneFile インスタンス生成
/// ---------------------------------

- (KintoneFile *)initWithProperties:(NSDictionary *)properties;

/**
 新規作成された `KintoneFile` インスタンスを返します。
 
 @param data ファイルデータ
 @param name ファイル名
 @param contentType ファイルの mime type
 
 @return 'KintoneFile` インスタンス
 */
- (KintoneFile *)initWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType;

/// ---------------------------------
/// @name その他メソッド
/// ---------------------------------

- (NSDictionary *)json;

/**
 json 形式のデータから fileKey を設定します。
 
 `[KintoneAPI fileUploadWithFile:success:failure:queue:]` の success block 内で利用することを想定しています。
 
 @param fileKey fileKey 値
 */
- (void)setFileKeyWithJSONDictionary:(NSDictionary *)fileKey;

@end
