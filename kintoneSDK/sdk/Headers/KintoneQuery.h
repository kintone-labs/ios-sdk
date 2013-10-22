//
//  KintoneQuery.h
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

typedef NS_ENUM(NSUInteger, KintoneQueryOperatorType) {
    KintoneEqualQueryOperatorType              = NSEqualToPredicateOperatorType,
    KintoneNotEqualQueryOperatorType           = NSNotEqualToPredicateOperatorType,
    KintoneGreaterThanQueryOperatorType        = NSGreaterThanPredicateOperatorType,
    KintoneLessThanQueryOperatorType           = NSLessThanPredicateOperatorType,
    KintoneGreaterThanOrEqualQueryOperatorType = NSGreaterThanOrEqualToPredicateOperatorType,
    KintoneLessThanOrEqualQueryOperatorType    = NSLessThanOrEqualToPredicateOperatorType,
    KintoneInQueryOperatorType                 = NSInPredicateOperatorType,
    KintoneNotInQueryOperatorType              = 100,
    KintoneLikeQueryOperatorType               = NSLikePredicateOperatorType,
    KintoneNotLikeQueryOperatorType            = 101
};

/**
 kintone アプリのレコード一括取得用クエリを生成するクラスです。
 
 ## 演算子の定義
 
    typedef NS_ENUM(NSUInteger, KintoneQueryOperatorType) {
        KintoneEqualQueryOperatorType              = NSEqualToPredicateOperatorType,              // =
        KintoneNotEqualQueryOperatorType           = NSNotEqualToPredicateOperatorType,           // !=
        KintoneGreaterThanQueryOperatorType        = NSGreaterThanPredicateOperatorType,          // >
        KintoneLessThanQueryOperatorType           = NSLessThanPredicateOperatorType,             // <
        KintoneGreaterThanOrEqualQueryOperatorType = NSGreaterThanOrEqualToPredicateOperatorType, // >=
        KintoneLessThanOrEqualQueryOperatorType    = NSLessThanOrEqualToPredicateOperatorType,    // <=
        KintoneInQueryOperatorType                 = NSInPredicateOperatorType,                   // in
        KintoneNotInQueryOperatorType              = 100,                                         // not in
        KintoneLikeQueryOperatorType               = NSLikePredicateOperatorType,                 // like
        KintoneNotLikeQueryOperatorType            = 101                                          // not like
    };
 
 ## クエリ作成の例
 
 f1 like "API" and f2 = "kintone" and  (f3 > 10 or f4 in ("S", "A") ) order by f5 desc limit 5 offset 10
 ※ f1 - f5 は、各フィールドのフィールドコード。
 
    // Field1 は f1 に対応
    KintoneQuery *q = [KintoneQuery new];
    [q where:
        [q and:
            [q like:Field1 value:@"API"],
            [q eq:Field2 value:@"kintone"],
            [q or:
                [q greaterThan:Field3 value:10],
                [q in:Field4 value:@[@"S", @"A"]], nil
            ], nil
        ]
    ];
    [q orderBy:Kintone5 asc:NO];
    [q limit:5];
    [q offset:10];
 
 詳しくは [cybozu.com developers - レコード取得](http://developers.cybozu.com/ja/kintone/apprec-readapi.html) を参照。
 */
@interface KintoneQuery : NSObject

+ (NSString *)operatorTypeToString:(KintoneQueryOperatorType)operatorType;

/// ---------------------------------
/// @name 句
/// ---------------------------------

/**
 where 句を設定します。
 
 @param query 演算子メソッドにて生成された `NSArray`
 */
- (void)where:(NSArray *)query;

/**
 order by 句を設定します。
 
 @param field ソート対象フィールド
 @param asc `YES`: 昇順、`NO`: 降順
 */
- (void)orderBy:(KintoneField *)field asc:(BOOL)asc;

/**
 limit 句を設定します。
 
 @param limit limit 値
 */
- (void)limit:(int)limit;

/**
 offset 句を設定します。
 
 @param offset offset 値
 */
- (void)offset:(int)offset;

/// ---------------------------------
/// @name 演算子
/// ---------------------------------

/**
 "and" 演算子です。
 
 指定された条件文を "and" で結合します。
 
 @param conditions 条件文
 @param ... `nil` 終端
 
 @return 指定された条件文の "and" 結合を表す `NSArray`
 */
- (NSArray *)and:(NSArray *)conditions, ... NS_REQUIRES_NIL_TERMINATION;

/**
 "or" 演算子です。
 
 指定された条件文を "or" で結合します。
 
 @param conditions 条件文
 @param ... `nil` 終端
 
 @return 指定された条件文の "or" 結合を表す `NSArray`
 */
- (NSArray *)or:(NSArray *)condition, ... NS_REQUIRES_NIL_TERMINATION;

/**
 "`=`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`=`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)eq:(KintoneField *)field value:(id)value;

/**
 "`!=`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`!=`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)notEq:(KintoneField *)field value:(id)value;

/**
 "`>`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`>`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)greaterThan:(KintoneField *)field value:(id)value;

/**
 "`<`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`<`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)lessThan:(KintoneField *)field value:(id)value;

/**
 "`>=`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`>=`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)greaterThanOrEqual:(KintoneField *)field value:(id)value;

/**
 "`<=`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`<=`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)lessThanOrEqual:(KintoneField *)field value:(id)value;

/**
 "`in`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`in`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)in:(KintoneField *)field value:(NSArray *)value;

/**
 "`not in`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`not in`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)notIn:(KintoneField *)field value:(NSArray *)value;

/**
 "`like`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`like`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)like:(KintoneField *)field value:(NSString *)value;

/**
 "`not like`" 演算子を使った条件文を生成します。
 
 @param field 左辺のフィールドオブジェクト
 @param value 右辺の比較値
 
 @return "`not like`" 演算子を使った条件文を表す `NSArray`
 */
- (NSArray *)notLike:(KintoneField *)field value:(NSString *)value;

/// ---------------------------------
/// @name クエリ文字列
/// ---------------------------------

/**
 kintone アプリのレコード一括取得用のクエリ文字列です。
 
 `[KintoneAPI recordsWithFields:query:success:failure:queue:]` の `query` として利用します。
 
 @return インスタンスに設定した句で生成されるクエリ文字列
 */
- (NSString *)kintoneQuery;

@end
