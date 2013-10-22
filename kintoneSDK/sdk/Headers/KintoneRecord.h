//
//  KintoneRecord.h
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

@class KintoneField;
@class KintoneRecordNumberField;
@class KintoneCreatorField;
@class KintoneCreatedTimeField;
@class KintoneModifierField;
@class KintoneUpdatedTimeField;

/**
 kintone アプリのレコードを表すクラスです。
 */
@interface KintoneRecord : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 レコードに含まれるフィールドです。
 */
@property (nonatomic, readonly) NSMutableDictionary *fields;

/**
 レコード番号フィールドです。
 
 設定されていない場合には `nil` になります。
 */
@property (nonatomic, readonly) KintoneRecordNumberField *recordNumber;

/**
 レコードの作成者フィールドです。
 
 設定されていない場合には `nil` になります。
 */
@property (nonatomic, readonly) KintoneCreatorField *creator;

/**
 レコードの作成日時フィールドです。
 
 設定されていない場合には `nil` になります。
 */
@property (nonatomic, readonly) KintoneCreatedTimeField *createdTime;

/**
 レコードの更新者フィールドです。
 
 設定されていない場合には `nil` になります。
 */
@property (nonatomic, readonly) KintoneModifierField *modifier;

/**
 レコードの更新日時フィールドです。
 
 設定されていない場合には `nil` になります。
 */
@property (nonatomic, readonly) KintoneUpdatedTimeField *updatedTime;

/// ---------------------------------
/// @name フィールド追加
/// ---------------------------------

/**
 レコードに指定したフィールドを追加します。
 
 @param field 追加するフィールド
 */
- (void)addField:(KintoneField *)field;

/// ---------------------------------
/// @name json 形式のデータより KintoneRecord を生成
/// ---------------------------------

/**
 json 形式のデータより `KintoneRecord` を生成します。
 
 @param JSON `[KintoneAPI record:success:failure:queue:]` の success Block 引数の JSON
 
 @return 生成された `KintoneRecord` オブジェクト
 */
+ (KintoneRecord *)kintoneRecordFromJSON:(id)JSON;

+ (KintoneRecord *)kintoneRecordFromDictionary:(NSDictionary *)record;

/**
 json 形式のデータより `KintoneRecord` の `NSArray` を生成します。
 
 @param JSON `[KintoneAPI recordsWithFields:query:success:failure:queue:]` の success Block 引数の JSON
 
 @return 生成された `KintoneRecord`
 */
+ (NSArray *)kintoneRecordsFromJSON:(id)JSON;

@end
