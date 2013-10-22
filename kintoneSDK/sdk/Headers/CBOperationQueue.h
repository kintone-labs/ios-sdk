//
//  CBOperationQueue.h
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
 シングルトンの `NSOperationQueue` を提供するクラスです。
 */
@interface CBOperationQueue : NSOperationQueue

/**
 シングルトンのデフォルト設定 `NSOperationQueue` を返します。
 
 @return `NSOperationQueue`
 */
+ (CBOperationQueue *)sharedConcurrentQueue;

/**
 同時実行 operation 数 1 のシングルトン `NSOperationQueue` を返します。
 
 `NSOperationQueue` にセットされた `NSOperation` の実行順を保証したい場合に利用します。
 
 @return `maxConcurrentOperationCount` が  1 の `NSOperationQueue`
 */
+ (CBOperationQueue *)sharedNonConcurrentQueue;

@end
