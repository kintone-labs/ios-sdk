//
//  KintoneField.h
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
#import "KintoneQuery.h"

@class CBError;
@class KintoneFile;

typedef NS_ENUM(NSUInteger, KintoneFieldType) {
    KintoneLabelFieldType = 1,      // 1
    KintoneSingleLineTextFieldType, // 2
    KintoneNumberFieldType,         // 3
    KintoneCalcFieldType,           // 4
    KintoneMultiLineTextFieldType,  // 5
    KintoneRichTextFieldType,       // 6
    KintoneCheckBoxFieldType,       // 7
    KintoneRadioButtonFieldType,    // 8
    KintoneDropDownFieldType,       // 9
    KintoneMultiSelectFieldType,    // 10
    KintoneFileFieldType,           // 11
    KintoneDateFieldType,           // 12
    KintoneTimeFieldType,           // 13
    KintoneDatetimeFieldType,       // 14
    KintoneLinkFieldType,           // 15
    KintoneUserSelectFieldType,     // 16
    KintoneLookupFieldType,         // 17
    KintoneReferenceTableFieldType, // 18
    KintoneCategoryFieldType,       // 19
    KintoneStatusFieldType,         // 20
    KintoneStatusAssigneeFieldType, // 21
    KintoneRecordNumberFieldType,   // 22
    KintoneCreatorFieldType,        // 23
    KintoneCreatedTimeFieldType,    // 24
    KintoneModifierFieldType,       // 25
    KintoneUpdatedTimeFieldType,    // 26
    KintoneSubtableFieldType,       // 27
    KintoneUnsupportedFieldType     // 28
};

/**
 kintone アプリのフィールドクラスです。
 
 フィールドタイプ毎のサブフィールドクラスの詳細は、それぞれのフィールドクラスのドキュメントを参照してください。
 
 ## フィールドタイプ
 
    typedef NS_ENUM(NSUInteger, KintoneFieldType) {
        KintoneLabelFieldType = 1,      // 1
        KintoneSingleLineTextFieldType, // 2
        KintoneNumberFieldType,         // 3
        KintoneCalcFieldType,           // 4
        KintoneMultiLineTextFieldType,  // 5
        KintoneRichTextFieldType,       // 6
        KintoneCheckBoxFieldType,       // 7
        KintoneRadioButtonFieldType,    // 8
        KintoneDropDownFieldType,       // 9
        KintoneMultiSelectFieldType,    // 10
        KintoneFileFieldType,           // 11
        KintoneDateFieldType,           // 12
        KintoneTimeFieldType,           // 13
        KintoneDatetimeFieldType,       // 14
        KintoneLinkFieldType,           // 15
        KintoneUserSelectFieldType,     // 16
        KintoneLookupFieldType,         // 17
        KintoneReferenceTableFieldType, // 18
        KintoneCategoryFieldType,       // 19
        KintoneStatusFieldType,         // 20
        KintoneStatusAssigneeFieldType, // 21
        KintoneRecordNumberFieldType,   // 22
        KintoneCreatorFieldType,        // 23
        KintoneCreatedTimeFieldType,    // 24
        KintoneModifierFieldType,       // 25
        KintoneUpdatedTimeFieldType,    // 26
        KintoneSubtableFieldType,       // 27
        KintoneUnsupportedFieldType     // 28
    };
 */
@interface KintoneField : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 フィールド名です。
 
 全てのフィールドに付与されます。
 */
@property (nonatomic, copy, readonly) NSString *label;

/**
 フィールドコードです。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSString *code;

/**
 フィールドタイプです。
 
 上記 `KintoneFieldType` となります。
 */
@property (nonatomic, readonly) KintoneFieldType type;

/**
 入力必須フィールドかどうかを表します。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) BOOL required;

/**
 フィールド名の非表示を表します。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) BOOL noLabel;

/**
 重複可否を表します。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) BOOL unique;

/**
 数値フィールドの入力可能な最大値です。
 
 存在しない場合、`INT_MAX` が設定されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) int maxValue;

/**
 数値フィールドの入力可能な最小値です。
 
 存在しない場合、`0` が設定されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) int minValue;

/**
 文字列フィールドの入力可能な最大文字数です。
 
 存在しない場合、`INT_MAX` が設定されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) int maxLength;

/**
 文字列フィールドの入力可能な最小文字数です。
 
 存在しなし場合、`0` が設定されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) int minLength;

/**
 初期値です。
 
 複数初期値が指定可能なフィールドは `NSArray` となります。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) id defaultValue;

/**
 初期値の式です。
 
 日付、時刻、日時フィールドで利用されます。"Now" もしくは `NSNull` となります。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSString *defaultExpression;

/**
 選択系フィールドの選択項目です。
 
 `NSString` で指定されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSArray *options;

/**
 自動計算値です。
 
 例："金額" * "数量"。フィールドはフィールドコードにて記述されます。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSString *expression;

/**
 数値の桁区切り表示を表します。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) BOOL digit;

/**
 リンクの種類を表します。
 
 "WEB", "CALL", "MAIL" のいずれかです。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSString *protocol;

/**
 表示形式です。
 
 "NUMBER", "NUMBER_DIGIT", "DATETIME", "DATE", "TIME", "HOUR_MINUTE", "DAY_HOUR_MINUTE" のいずれかです。フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, copy, readonly) NSString *format;

/**
 フィールド値です。
 
 フィールドタイプによって存在しない場合があります。
 */
@property (nonatomic, readonly) id value;

/// ---------------------------------
/// @name インスタンス生成
/// ---------------------------------

/**
 `KintoneField` もしくは `KintoneField` を継承するクラスを返します。
 
 指定された `type` に応じたクラスが返されます。
 
 @param properties 上記プロパティで挙げられた property のみサポートします。これら以外のプロパティは無視されます。
 
 @return `KintoneField` もしくは `KintoneField` を継承するクラスインスタンス
 */
- (instancetype)initWithProperties:(NSDictionary *)properties;

/// ---------------------------------
/// @name メソッド
/// ---------------------------------

/**
 指定されたフィールドタイプ名の `KintoneFieldType` を返します。
 
 `fieldTypeNameForFieldType:` で逆変換ができます。
 
 @param fieldTypeName kintone API レスポンスで返されるフィールタイプを表す文字列
 
 @return `fieldTypeName` に対応する `KintoneFieldType`
 */
+ (KintoneFieldType)fieldTypeForFieldTypeName:(NSString *)fieldTypeName;

/**
 指定された `KintoneFieldType` に対応するフィールドタイプ文字列を返します。
 
 `fieldTypeForFieldTypeName:` で逆変換ができます。
 
 @param fieldType `KintoneFieldType` 値
 
 @return `fieldType` に対応するフィールドタイプ文字列
 */
+ (NSString *)fieldTypeNameForFieldType:(KintoneFieldType)fieldType;

/**
 指定された JSON 形式のフィールド定義より、`code` をキーとした `KintoneField` 一覧を返します。
 
 `KintoneAPI form:failure:queue:` でのレスポンスに適用することを想定しています。
 
 @param JSON JSON 形式の kintone アプリのフィールド定義
 
 @return `code` をキーとした `KintoneField`。フィールドコード `code` を含まないフィールド (ラベルフィールド) は返り値に含まれません。
 */
+ (NSDictionary *)fieldsFromJSON:(id)JSON;

/**
 指定された演算子と値で、kintone クエリの条件文を生成します。
 
 本メソッドは主に `KintoneQuery` 内部から呼ばれることを想定しています。返される条件文は、フィールドタイプにより異なります。演算子、値はフィールドタイプ毎にサポートされるものかチェックされ、不正な場合は assert で失敗します。具体的には、各 `KintoneField` サブクラスの `conditionQuery` を参照してください。

 @param operator kintone クエリ演算子
 @param value フィールド値
 
 @return 指定された演算子と値で生成された kintone クエリ条件文
 */
- (NSString *)conditionQuery:(KintoneQueryOperatorType)operator value:(id)value;

/**
 フィールドに値をセットします。
 
 フィールドタイプ、プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。
 
 @param value フィールド値
 @param error フィールド値が不正な場合 `K_ERROR_00001` エラー
 
 @return フィールド値が正常にセットされれば YES、不正な値の場合は NO
 */
- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error;

/**
 フィールドの JSON 形式の定義を返します。
 
 フィールド定義は JSON 文字列ではなく、`NSDictionary`, `NSArray` を利用し、表現されます。
 
 @return フィールド の JSON 形式の定義
 */
- (NSDictionary *)json;

@end

/**
 kintone アプリ ラベルフィールドです。
 */
@interface KintoneLabelField : KintoneField

@end

@interface KintoneKindOfSingleLineTextField : KintoneField

@end

@interface KintoneKindOfMultiLineTextField : KintoneField

@end

@interface KintoneSelectableField : KintoneField

@end

@interface KintoneKindOfDateField : KintoneField

@end

@interface KintoneKindOfDatetimeField : KintoneKindOfDateField

@end

/**
 kintone アプリ 文字列(1 行)フィールドです。
 
 <h2 class="subtitle subtitle-tasks">Tasks</h2>

 <!-- --------------------------------- -->
 <!-- Tasks -->
 <!-- --------------------------------- -->
 
 <ul class="task-list">
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/conditionQuery:value:">–&nbsp;conditionQuery:value:</a></code>
            <span class="tooltip"><p>指定された演算子と値で、kintone クエリの条件文を生成します。</p></span>
        </span>
    </li>
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/setValue:error:">–&nbsp;setValue:error:</a></code>
            <span class="tooltip"><p>フィールドに値をセットします。</p></span>
        </span>
    </li>
 </ul>
 
 <!-- --------------------------------- -->
 <!-- Instance Methods -->
 <!-- --------------------------------- -->

 <div class="section section-methods">
    <a title="Instance Methods" name="instance_methods"></a>
    <h2 class="subtitle subtitle-methods">Instance Methods</h2>
 
    <!-- --------------------------------- -->
    <!-- conditionQuery:value: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/conditionQuery:value:" title="conditionQuery:value:"></a>
        <h3 class="subsubtitle method-title">conditionQuery:value:</h3>
 
        <div class="method-subsection brief-description">
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (NSString *)conditionQuery:(KintoneQueryOperatorType)<em>operator</em> value:(id)<em>value</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>operator</em></dt>
                <dd><p>kintone クエリ演算子。<code>KintoneEqualQueryOperatorType</code> (=), <code>KintoneNotEqualQueryOperatorType</code> (!=), <code>KintoneLikeQueryOperatorType</code> (like), <code>KintoneNotLikeQueryOperatorType</code> (not like), <code>KintoneInQueryOperatorType</code> (in), <code>KintoneNotInQueryOperatorType</code> (not in) 以外は assert で失敗します。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>KintoneInQueryOperatorType</code>, <code>KintoneNotInQueryOperatorType</code> に関しては <code>NSString</code> の <code>NSArray</code> 以外が指定されると、assert で失敗します。それ以外の <code>operatorType</code> の場合、<code>NSString</code> 以外で失敗します。</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>指定された演算子と値で生成された kintone クエリ条件文</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
    </div>
 
    <!-- --------------------------------- -->
    <!-- setValue:error: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/setValue:error:" title="setValue:error:"></a>
        <h3 class="subsubtitle method-title">setValue:error:</h3>
 
        <div class="method-subsection brief-description">
            <p>フィールドに値をセットします。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (BOOL)setValue:(id)<em>value</em> error:(CBError *__autoreleasing *)<em>error</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSString</code> でない、もしくは文字列長が制限値外の場合、エラーとなり、NO が返されます。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>error</em></dt>
                <dd><p>フィールド値が不正な場合 <code>K_ERROR_00001</code> エラー</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>フィールド値が正常にセットされれば YES、不正な値の場合は NO</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>フィールドに値をセットします。</p>
 
            <p>プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。</p>
        </div>
    </div>
 </div>
 */
@interface KintoneSingleLineTextField : KintoneKindOfSingleLineTextField

@end

/**
 kintone アプリ 数値フィールドです。
 */
@interface KintoneNumberField : KintoneField

/**
 指定された演算子と値で、kintone クエリの条件文を生成します。
 
 @param operatorType クエリ演算子。`KintoneEqualQueryOperatorType` (=), `KintoneNotEqualQueryOperatorType` (!=), `KintoneGreaterThanQueryOperatorType` (>), `KintoneLessThanQueryOperatorType` (<), `KintoneGreaterThanOrEqualQueryOperatorType` (>=), `KintoneLessThanOrEqualQueryOperatorType` (<=), `KintoneInQueryOperatorType` (in), `KintoneNotInQueryOperatorType` (not in) 以外は assert で失敗します。
 @param value フィールド値。`KintoneInQueryOperatorType`, `KintoneNotInQueryOperatorType` に関しては `NSNumber` の `NSArray` 以外が指定されると、assert で失敗します。それ以外の `operatorType` の場合、`NSNumber` 以外で失敗します。
 
 @return 指定された演算子と値で生成された kintone クエリ条件文
 */
- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value;

/**
 フィールドに値をセットします。
 
 プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。
 
 @param value フィールド値。`NSNumber` でない、もしくは値が制限値外の場合、エラーとなり、NO が返されます。
 @param error フィールド値が不正な場合 `K_ERROR_00001` エラー
 
 @return フィールド値が正常にセットされれば YES、不正な値の場合は NO
 */
- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error;

@end

/**
 kintone アプリ 数値計算フィールドです。
 */
@interface KintoneCalcField : KintoneField

@end

/**
  kintone アプリ 文字列(複数行)フィールドです。
 
 <h2 class="subtitle subtitle-tasks">Tasks</h2>

 <!-- --------------------------------- -->
 <!-- Tasks -->
 <!-- --------------------------------- -->
 
 <ul class="task-list">
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/conditionQuery:value:">–&nbsp;conditionQuery:value:</a></code>
            <span class="tooltip"><p>指定された演算子と値で、kintone クエリの条件文を生成します。</p></span>
        </span>
    </li>
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/setValue:error:">–&nbsp;setValue:error:</a></code>
            <span class="tooltip"><p>フィールドに値をセットします。</p></span>
        </span>
    </li>
 </ul>
 
 <!-- --------------------------------- -->
 <!-- Instance Methods -->
 <!-- --------------------------------- -->

 <div class="section section-methods">
    <a title="Instance Methods" name="instance_methods"></a>
    <h2 class="subtitle subtitle-methods">Instance Methods</h2>
 
    <!-- --------------------------------- -->
    <!-- conditionQuery:value: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/conditionQuery:value:" title="conditionQuery:value:"></a>
        <h3 class="subsubtitle method-title">conditionQuery:value:</h3>
 
        <div class="method-subsection brief-description">
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (NSString *)conditionQuery:(KintoneQueryOperatorType)<em>operator</em> value:(id)<em>value</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>operator</em></dt>
                <dd><p>kintone クエリ演算子。<code>KintoneLikeQueryOperatorType</code> (like), <code>KintoneNotLikeQueryOperatorType</code> (not like) 以外は assert で失敗します。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSString</code> でない場合、assert で失敗します。</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>指定された演算子と値で生成された kintone クエリ条件文</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
    </div>
 
    <!-- --------------------------------- -->
    <!-- setValue:error: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/setValue:error:" title="setValue:error:"></a>
        <h3 class="subsubtitle method-title">setValue:error:</h3>
 
        <div class="method-subsection brief-description">
            <p>フィールドに値をセットします。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (BOOL)setValue:(id)<em>value</em> error:(CBError *__autoreleasing *)<em>error</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSString</code> でない、もしくは文字列長が制限値外の場合、エラーとなり、NO が返されます。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>error</em></dt>
                <dd><p>フィールド値が不正な場合 <code>K_ERROR_00001</code> エラー</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>フィールド値が正常にセットされれば YES、不正な値の場合は NO</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>フィールドに値をセットします。</p>
 
            <p>プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。</p>
        </div>
    </div>
 </div>
 */
@interface KintoneMultiLineTextField : KintoneKindOfMultiLineTextField

@end

/**
 kintone アプリ リッチエディターフィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneMultiLineTextField` と同様です。
 */
@interface KintoneRichTextField : KintoneKindOfMultiLineTextField

@end

/**
   kintone アプリ チェックボックスフィールドです。
 
 <h2 class="subtitle subtitle-tasks">Tasks</h2>

 <!-- --------------------------------- -->
 <!-- Tasks -->
 <!-- --------------------------------- -->
 
 <ul class="task-list">
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/conditionQuery:value:">–&nbsp;conditionQuery:value:</a></code>
            <span class="tooltip"><p>指定された演算子と値で、kintone クエリの条件文を生成します。</p></span>
        </span>
    </li>
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/setValue:error:">–&nbsp;setValue:error:</a></code>
            <span class="tooltip"><p>フィールドに値をセットします。</p></span>
        </span>
    </li>
 </ul>
 
 <!-- --------------------------------- -->
 <!-- Instance Methods -->
 <!-- --------------------------------- -->

 <div class="section section-methods">
    <a title="Instance Methods" name="instance_methods"></a>
    <h2 class="subtitle subtitle-methods">Instance Methods</h2>
 
    <!-- --------------------------------- -->
    <!-- conditionQuery:value: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/conditionQuery:value:" title="conditionQuery:value:"></a>
        <h3 class="subsubtitle method-title">conditionQuery:value:</h3>
 
        <div class="method-subsection brief-description">
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (NSString *)conditionQuery:(KintoneQueryOperatorType)<em>operator</em> value:(id)<em>value</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>operator</em></dt>
                <dd><p>kintone クエリ演算子。<code>KintoneEqualQueryOperatorType</code> (=), <code>KintoneNotEqualQueryOperatorType</code> (!=), <code>KintoneInQueryOperatorType</code> (in), <code>KintoneNotInQueryOperatorType</code> (not in) 以外は assert で失敗します。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>KintoneInQueryOperatorType</code>, <code>KintoneNotInQueryOperatorType</code> に関しては <code>NSString</code> の <code>NSArray</code> 以外が指定されると、assert で失敗します。それ以外の <code>operatorType</code> の場合、<code>NSString</code> 以外で失敗します。</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>指定された演算子と値で生成された kintone クエリ条件文</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
    </div>
 
    <!-- --------------------------------- -->
    <!-- setValue:error: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/setValue:error:" title="setValue:error:"></a>
        <h3 class="subsubtitle method-title">setValue:error:</h3>
 
        <div class="method-subsection brief-description">
            <p>フィールドに値をセットします。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (BOOL)setValue:(id)<em>value</em> error:(CBError *__autoreleasing *)<em>error</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSString</code> でない、もしくは設定された <code>option</code> 値にマッチしない場合、エラーとなり、NO が返されます。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>error</em></dt>
                <dd><p>フィールド値が不正な場合 <code>K_ERROR_00001</code> エラー</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>フィールド値が正常にセットされれば YES、不正な値の場合は NO</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>フィールドに値をセットします。</p>
 
            <p>プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。</p>
        </div>
    </div>
 </div>
 */
@interface KintoneCheckBoxField : KintoneSelectableField

@end

/**
 kintone アプリ ラジオボタンフィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneCheckBoxField` と同様です。
 */
@interface KintoneRadioButtonField : KintoneSelectableField

@end

/**
 kintone アプリ ドロップダウンフィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneCheckBoxField` と同様です。
 */
@interface KintoneDropDownField : KintoneSelectableField

@end

/**
 kintone アプリ 複数選択フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneCheckBoxField` と同様です。
 */
@interface KintoneMultiSelectField : KintoneSelectableField

@end

/**
 kintone アプリ ファイルフィールドです。
 
 フィールドへのファイルの追加/更新/削除は本クラスのメソッドを介し、`KintoneFile` を操作することで可能となります。詳しくは `[KintoneAPI fileDownload:success:failure:download:output:queue:]`, `[KintoneAPI fileUploadWithFile:success:failure:queue:]` を参照してください。
 */
@interface KintoneFileField : KintoneField

/**
 指定された演算子と値で、kintone クエリの条件文を生成します。
 
 @param operatorType クエリ演算子。`KintoneLikeQueryOperatorType` (like), `KintoneNotLikeQueryOperatorType` (not like) 以外は assert で失敗します。
 @param value フィールド値。`NSString` 以外が指定されると assert で失敗します。
 
 @return 指定された演算子と値で生成された kintone クエリ条件文
 */
- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value;

/**
 指定された番号の `KintoneFile` オブジェクトを返します。
 
 @param index `KintoneFileField` に含まれる `KintoneFile` 番号。0 よりも小さい、もしくはファイル数を超えている場合には nil を返します。
 
 @return 指定された番号の `KintoneFile' オブジェクト
 */
- (KintoneFile *)fileWithIndex:(int)index;

/**
 フィールドにファイルを追加します。
 
 追加したファイルは、`KintoneAPI` を利用することにより kintone アプリへ反映されます。
 
 @param file 追加するファイル
 */
- (void)addFile:(KintoneFile *)file;

/**
 フィールドからファイルを削除します。
 
 @param file 削除するファイル
 */
- (void)deleteFile:(KintoneFile *)file;

/**
 指定した番号のファイルをフィールドより削除します。
 
 @param index ファイル番号
 */
- (void)deleteFileWithIndex:(int)index;

@end

/**
 kintone アプリ 日付フィールドです。
 
 <h2 class="subtitle subtitle-tasks">Tasks</h2>

 <!-- --------------------------------- -->
 <!-- Tasks -->
 <!-- --------------------------------- -->
 
 <ul class="task-list">
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/conditionQuery:value:">–&nbsp;conditionQuery:value:</a></code>
            <span class="tooltip"><p>指定された演算子と値で、kintone クエリの条件文を生成します。</p></span>
        </span>
    </li>
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/setValue:error:">–&nbsp;setValue:error:</a></code>
            <span class="tooltip"><p>フィールドに値をセットします。</p></span>
        </span>
    </li>
 </ul>
 
 <!-- --------------------------------- -->
 <!-- Instance Methods -->
 <!-- --------------------------------- -->

 <div class="section section-methods">
    <a title="Instance Methods" name="instance_methods"></a>
    <h2 class="subtitle subtitle-methods">Instance Methods</h2>
 
    <!-- --------------------------------- -->
    <!-- conditionQuery:value: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/conditionQuery:value:" title="conditionQuery:value:"></a>
        <h3 class="subsubtitle method-title">conditionQuery:value:</h3>
 
        <div class="method-subsection brief-description">
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (NSString *)conditionQuery:(KintoneQueryOperatorType)<em>operator</em> value:(id)<em>value</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>operator</em></dt>
                <dd><p>kintone クエリ演算子。<code>KintoneEqualQueryOperatorType</code> (=), <code>KintoneNotEqualQueryOperatorType</code> (!=), <code>KintoneGreaterThanQueryOperatorType</code> (>), <code>KintoneLessThanQueryOperatorType</code> (<), <code>KintoneGreaterThanOrEqualQueryOperatorType</code> (>=), <code>KintoneLessThanOrEqualQueryOperatorType</code> (<=) 以外は assert で失敗します。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSDate</code> もしくは "<code>TODAY()</code>", "<code>THIS_MONTH()</code>", "<code>THIS_YEAR()</code>" 以外の場合は assert で失敗します。</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>指定された演算子と値で生成された kintone クエリ条件文</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
    </div>
 </div>
  */
@interface KintoneDateField : KintoneKindOfDateField

@end

/**
 kintone アプリ 時刻フィールドです。
 */
@interface KintoneTimeField : KintoneField

/**
 指定された演算子と値で、kintone クエリの条件文を生成します。
 
 @param operatorType クエリ演算子。`KintoneEqualQueryOperatorType` (=), `KintoneNotEqualQueryOperatorType` (!=), `KintoneGreaterThanQueryOperatorType` (>), `KintoneLessThanQueryOperatorType` (<), `KintoneGreaterThanOrEqualQueryOperatorType` (>=) 以外は assert で失敗します。
 @param value フィールド値。`NSDate` 以外が指定されると、assert で失敗します。
 
 @return 指定された演算子と値で生成された kintone クエリ条件文
 */
- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value;

@end

/**
 kintone アプリ 日時フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneDateField` と同様です。
 */
@interface KintoneDatetimeField : KintoneKindOfDatetimeField

@end

/**
 kintone アプリ リンクフィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneSingleLineTextField` と同様です。
 */
@interface KintoneLinkField : KintoneKindOfSingleLineTextField

@end

@interface KintoneUserField : KintoneField

@end

/**
 kintone アプリ ユーザー選択フィールドです。
 
 <h2 class="subtitle subtitle-tasks">Tasks</h2>

 <!-- --------------------------------- -->
 <!-- Tasks -->
 <!-- --------------------------------- -->
 
 <ul class="task-list">
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/conditionQuery:value:">–&nbsp;conditionQuery:value:</a></code>
            <span class="tooltip"><p>指定された演算子と値で、kintone クエリの条件文を生成します。</p></span>
        </span>
    </li>
    <li>
        <span class="tooltip">
            <code><a href="#//api/name/setValue:error:">–&nbsp;setValue:error:</a></code>
            <span class="tooltip"><p>フィールドに値をセットします。</p></span>
        </span>
    </li>
 </ul>
 
 <!-- --------------------------------- -->
 <!-- Instance Methods -->
 <!-- --------------------------------- -->

 <div class="section section-methods">
    <a title="Instance Methods" name="instance_methods"></a>
    <h2 class="subtitle subtitle-methods">Instance Methods</h2>
 
    <!-- --------------------------------- -->
    <!-- conditionQuery:value: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/conditionQuery:value:" title="conditionQuery:value:"></a>
        <h3 class="subsubtitle method-title">conditionQuery:value:</h3>
 
        <div class="method-subsection brief-description">
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (NSString *)conditionQuery:(KintoneQueryOperatorType)<em>operator</em> value:(id)<em>value</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>operator</em></dt>
                <dd><p>kintone クエリ演算子。<code>KintoneInQueryOperatorType</code> (in), <code>KintoneNotInQueryOperatorType</code> (not in) 以外は assert で失敗します。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSStrint</code> の <code>NSArray</code> 以外が指定された場合、assert で失敗します。</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>指定された演算子と値で生成された kintone クエリ条件文</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>指定された演算子と値で、kintone クエリの条件文を生成します。</p>
        </div>
    </div>
 
    <!-- --------------------------------- -->
    <!-- setValue:error: -->
    <!-- --------------------------------- -->
 
    <div class="section-method">
        <a name="//api/name/setValue:error:" title="setValue:error:"></a>
        <h3 class="subsubtitle method-title">setValue:error:</h3>
 
        <div class="method-subsection brief-description">
            <p>フィールドに値をセットします。</p>
        </div>
 
        <div class="method-subsection method-declaration"><code>- (BOOL)setValue:(id)<em>value</em> error:(CBError *__autoreleasing *)<em>error</em></code></div>
 
        <!-- --------------------------------- -->
        <!-- Parameters -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection arguments-section parameters">
            <h4 class="method-subtitle parameter-title">Parameters</h4>
 
            <dl class="argument-def parameter-def">
                <dt><em>value</em></dt>
                <dd><p>フィールド値。<code>NSArray</code> でなく、その値が <code>code</code> キーを含む <code>NSDictionary</code> でない場合、エラーとなり、<code>NO</code> が返されます。</p></dd>
            </dl>
 
            <dl class="argument-def parameter-def">
                <dt><em>error</em></dt>
                <dd><p>フィールド値が不正な場合 <code>K_ERROR_00001</code> エラー</p></dd>
            </dl>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Return Value -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection return">
            <h4 class="method-subtitle parameter-title">Return Value</h4>
            <p>フィールド値が正常にセットされれば YES、不正な値の場合は NO</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- Discussion -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection discussion-section">
            <h4 class="method-subtitle">Discussion</h4>
            <p>フィールドに値をセットします。</p>
 
            <p>プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。</p>
        </div>
 
        <!-- --------------------------------- -->
        <!-- See Also -->
        <!-- --------------------------------- -->
 
        <div class="method-subsection see-also-section">
            <h4 class="method-subtitle">See Also</h4>
            <ul>
                <li><code><p><a href="http://developers.cybozu.com/ja/kintone/appfield-objects.html">cybozu.com developers - フィールド形式 - ユーザー選択</a></p></code></li>
            </ul>
        </div>
    </div>
 </div>
 */
@interface KintoneUserSelectField : KintoneUserField

@end

/**
 kintone アプリ ルックアップフィールドです。
 */
@interface KintoneLookupField : KintoneField

@end

/**
 */
@interface KintoneReferenceTableField : KintoneField

@end

/**
 kintone アプリ カテゴリーフィールドです。
 */
@interface KintoneCategoryField : KintoneField

/**
 フィールドに値をセットします。
 
 プロパティ値が適切に設定されている場合、サポート対象の値かチェックされます。
 
 @param value フィールド値。`NSString` の `NSArray` でない場合、エラーとなり、NO が返されます。
 @param error フィールド値が不正な場合 `K_ERROR_00001` エラー
 
 @return フィールド値が正常にセットされれば YES、不正な値の場合は NO
 
 @see [cybozu.com developers - フィールド形式 - カテゴリー](http://developers.cybozu.com/ja/kintone/appfield-objects.html)
 */
- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error;

@end

/**
 kintone アプリ 処理状況フィールドです。
 */
@interface KintoneStatusField : KintoneField

/**
 指定された演算子と値で、kintone クエリの条件文を生成します。
 
 @param operatorType クエリ演算子。`KintoneEqualQueryOperatorType` (=), `KintoneNotEqualQueryOperatorType` (!=), `KintoneInQueryOperatorType` (in), `KintoneNotInQueryOperatorType` (not in) 以外は assert で失敗します。
 @param value フィールド値。`KintoneInQueryOperatorType`, `KintoneNotInQueryOperatorType` に関しては `NSString` の `NSArray` 以外が指定されると、assert で失敗します。それ以外の `operatorType` の場合、`NSString` 以外で失敗します。
 
 @return 指定された演算子と値で生成された kintone クエリ条件文
 */
- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value;

@end

/**
 kintone アプリ 作業者フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneStatusField` と同様です。
 */
@interface KintoneStatusAssigneeField : KintoneUserField

@end

/**
 kintone アプリ レコード番号フィールドです。
 */
@interface KintoneRecordNumberField : KintoneField

@end

/**
 kintone アプリ 作成者フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneUserSelectField` と同様です。[cybozu.com developers - フィールド形式 - 作成者](http://developers.cybozu.com/ja/kintone/appfield-objects.html) を参照のこと。
 */
@interface KintoneCreatorField : KintoneUserField

@end

/**
 kintone アプリ 作成日時フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneDateField` と同様です。
 */
@interface KintoneCreatedTimeField : KintoneKindOfDatetimeField

@end

/**
 kintone アプリ 更新者フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneUserSelectField` と同様です。[cybozu.com developers - フィールド形式 - 更新者](http://developers.cybozu.com/ja/kintone/appfield-objects.html) を参照のこと。
 */
@interface KintoneModifierField : KintoneUserField

@end

/**
 kintone アプリ 更新日時フィールドです。
 
 各メソッド(`conditionQuery:value:`, `setValue:error:`)の挙動は `KintoneDateField` と同様です。
 */
@interface KintoneUpdatedTimeField : KintoneKindOfDatetimeField

@end

/**
 kintone アプリ サブテーブルフィールドです。
 
 `value` には `KintoneRecord` の `NSArray` がセットされます。
 */
@interface KintoneSubtableField : KintoneField

+ (NSArray *)recordsFromJSON:(id)JSON;

@end