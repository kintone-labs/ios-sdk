//
//  KintoneSite.h
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
@class KintoneApplication;

/**
 cybozu.com ドメインを表すクラスです。
 
 cybozu.com ドメインへの接続に利用する credential を指定し、ドメイン単位でオブジェクトを生成します。
 */
@interface KintoneSite : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 `KintoneSite` に紐づく credential です。
 */
@property (nonatomic) CBCredential *cbCredential;

/// ---------------------------------
/// @name インスタンス生成
/// ---------------------------------

/**
 cybozu.com ドメインへの接続に利用する credential を指定してインスタンスを生成します。
 
 @param credential ドメイン認証情報
 
 @return `KintoneSite` オブジェクト
 */
- (KintoneSite *)initWithCredential:(CBCredential *)credential;

/// ---------------------------------
/// @name KintoneApplication 取得
/// ---------------------------------

/**
 ドメインに存在する kintone アプリのオブジェクトを取得します。
 
 @param appId kintone アプリ ID
 
 @return `KintoneApplication` オブジェクト
 */
- (KintoneApplication *)kintoneApplication:(int)appId;

@end
