//
//  KintoneLog.h
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

@class DDFileLogger;
@class CBFileLogger;

typedef NS_OPTIONS(NSUInteger, CBSdkLogFlag) {
    CBSdkLogFlagError   = 1 << 0,
    CBSdkLogFlagWarn    = 1 << 1,
    CBSdkLogFlagInfo    = 1 << 2,
    CBSdkLogFlagVerbose = 1 << 3
};

typedef NS_OPTIONS(NSUInteger, CBLogFlag) {
    CBLogFlagError      = 1 << 4,
    CBLogFlagWarn       = 1 << 5,
    CBLogFlagInfo       = 1 << 6,
    CBLogFlagVerbose    = 1 << 7
};

typedef NS_ENUM(NSUInteger, CBSdkLogLevel) {
    CBSdkLogLevelOff     = 0,
    CBSdkLogLevelError   = CBSdkLogFlagError,
    CBSdkLogLevelWarn    = CBSdkLogLevelError | CBSdkLogFlagWarn,
    CBSdkLogLevelInfo    = CBSdkLogLevelWarn  | CBSdkLogFlagInfo,
    CBSdkLogLevelVerbose = CBSdkLogLevelInfo  | CBSdkLogFlagVerbose
};

typedef NS_ENUM(NSUInteger, CBLogLevel) {
    CBLogLevelOff     = 0,
    CBLogLevelError   = CBLogFlagError,
    CBLogLevelWarn    = CBLogLevelError | CBLogFlagWarn,
    CBLogLevelInfo    = CBLogLevelWarn  | CBLogFlagInfo,
    CBLogLevelVerbose = CBLogLevelInfo  | CBLogFlagVerbose
};

/**
 ログクラスです。
 
 本クラスで出力されるログは Xcode のコンソールに出力されます。`CBFileLogger` をセットすることにより、ログファイルへの出力が可能となります。
 
 ## ログレベル
 
 アプリケーション向けのログレベル、SDK 向けのログレベルの 2 種類が存在します。  
 本 SDK を利用したアプリケーションのログレベルを制御したい場合は `CBLogLevel`、SDK 向けのログレベルを制御したい場合は `CBSdkLogLevel` を使用することを想定しています。
 
 アプリケーション向けのログレベルの定義:

    typedef NS_OPTIONS(NSUInteger, CBLogFlag) {
        CBLogFlagError      = 1 << 4,
        CBLogFlagWarn       = 1 << 5,
        CBLogFlagInfo       = 1 << 6,
        CBLogFlagVerbose    = 1 << 7
    };
 
    typedef NS_ENUM(NSUInteger, CBLogLevel) {
        CBLogLevelOff     = 0,
        CBLogLevelError   = CBLogFlagError,
        CBLogLevelWarn    = CBLogLevelError | CBLogFlagWarn,
        CBLogLevelInfo    = CBLogLevelWarn  | CBLogFlagInfo,
        CBLogLevelVerbose = CBLogLevelInfo  | CBLogFlagVerbose
    };
 
 SDK 向けのログレベルの定義:
 
    typedef NS_OPTIONS(NSUInteger, CBSdkLogFlag) {
        CBSdkLogFlagError   = 1 << 0,
        CBSdkLogFlagWarn    = 1 << 1,
        CBSdkLogFlagInfo    = 1 << 2,
        CBSdkLogFlagVerbose = 1 << 3
    };
 
    typedef NS_ENUM(NSUInteger, CBSdkLogLevel) {
        CBSdkLogLevelOff     = 0,
        CBSdkLogLevelError   = CBSdkLogFlagError,
        CBSdkLogLevelWarn    = CBSdkLogLevelError | CBSdkLogFlagWarn,
        CBSdkLogLevelInfo    = CBSdkLogLevelWarn  | CBSdkLogFlagInfo,
        CBSdkLogLevelVerbose = CBSdkLogLevelInfo  | CBSdkLogFlagVerbose
    };
 
 */
@interface CBLog : NSObject

/// ---------------------------------
/// @name FileLogger
/// ---------------------------------

/**
 `CBFileLogger` をセットします。

 `CBFileLogger` をセットすると、セットした時点からのログがファイルにも出力されるようになります。

 @param fileLogger セットする `CBFileLogger`
 */
+ (void)setFileLogger:(CBFileLogger *)fileLogger;

/**
 `CBFileLogger` を削除します。

 `CBFileLogger` を削除すると、削除した時点からのログがファイルに出力されません。既存のログファイルは維持されます。
 */
+ (void)removeFileLogger;

/// ---------------------------------
/// @name ログレベル
/// ---------------------------------

/**
 SDK 向けのログレベルを取得します。
 */
+ (CBSdkLogLevel)sdkLogLevel;

/**
 SDK 向けのログレベルをセットします。
 
 @param sdkLogLevel SDK 向けログレベル
 */
+ (void)setSdkLogLevel:(CBSdkLogLevel)sdkLogLevel;

/**
 アプリケーション向けのログレベルを取得します。
 */
+ (CBLogLevel)logLevel;

/**
 アプリケーション向けのログレベルをセットします。
 
 @param logLevel アプリケーション向けログレベル
 */
+ (void)setLogLevel:(CBLogLevel)logLevel;

/// ---------------------------------
/// @name SDK 向けログの出力
/// ---------------------------------

/**
 SDK 向けエラーログです。
 
 SDK 向けログレベルが `CBSdkLogLevelError` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)sdkLogError:(NSString *)format, ...;

/**
 SDK 向けワーニングログです。
 
 SDK 向けログレベルが `CBSdkLogLevelWarn` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)sdkLogWarn:(NSString *)format, ...;

/**
 SDK 向けインフォログです。
 
 SDK 向けログレベルが `CBSdkLogLevelInfo` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)sdkLogInfo:(NSString *)format, ...;

/**
 SDK 向け verbose ログです。
 
 SDK 向けログレベルが `CBSdkLogLevelVerbose` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)sdkLogVerbose:(NSString *)format, ...;

/// ---------------------------------
/// @name アプリケーション向けログの出力
/// ---------------------------------

/**
 アプリケーション向けエラーログです。
 
 アプリケーション向けログレベルが `CBLogLevelError` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)logError:(NSString *)format, ...;

/**
 アプリケーション向けワーニングログです。
 
 アプリケーション向けログレベルが `CBLogLevelWarn` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)logWarn:(NSString *)format, ...;

/**
 アプリケーション向けインフォログです。
 
 アプリケーション向けログレベルが `CBLogLevelInfo` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)logInfo:(NSString *)format, ...;

/**
 アプリケーション向け verbose ログです。
 
 アプリケーション向けログレベルが `CBLogLevelVerbose` で出力されます。
 
 @param format エラーフォーマット
 @param ... フォーマット引数
 */
+ (void)logVerbose:(NSString *)format, ...;

@end

/**
 ファイルロガーです。
 
 `CBLog` にセットすることにより、ログをファイルに出力します。ログファイルは "Documents/Logs" に保存され、指定されたサイズ、ファイル数で循環します。
 */
@interface CBFileLogger : NSObject

/// ---------------------------------
/// @name プロパティ
/// ---------------------------------

/**
 ログファイルの最大サイズを指定します。
 
 デフォルトは 3MB です。
 */
@property (nonatomic) int fileSize;

/**
 ログファイル数の最大値を指定します。
 
 デフォルトは 5 です。
 */
@property (nonatomic) int numberOfFiles;

/// ---------------------------------
/// @name CBFileLogger インスタンス
/// ---------------------------------

/**
 シングルトンの `CBFileLogger` インスタンスを取得します。
 */
+ (CBFileLogger *)sharedInstance;
- (DDFileLogger *)ddFileLogger;

@end