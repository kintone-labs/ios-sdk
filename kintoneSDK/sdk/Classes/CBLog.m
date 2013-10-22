//
//  KintoneLog.m
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

#import "CBLog.h"

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#define CB_LOG(lvl, flg, frmt)                    \
  va_list ap;                                     \
  va_start(ap, frmt);                             \
  [CBLog log:lvl flag:flg format:(frmt) args:ap]; \
  va_end(ap)

#pragma mark -

@implementation CBLog

static CBSdkLogLevel _sdkLogLevel = CBSdkLogLevelVerbose;
static CBLogLevel _logLevel = CBLogLevelVerbose;

static CBFileLogger *_fileLogger = nil;

+ (void)initialize
{
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

#pragma mark - file logger

+ (void)setFileLogger:(CBFileLogger *)fileLogger
{
    assert(fileLogger != nil);

    // remove current file logger
    [CBLog removeFileLogger];
    
    // add new file logger
    _fileLogger = fileLogger;
    [DDLog addLogger:[_fileLogger ddFileLogger]];
}

+ (void)removeFileLogger
{
    if (_fileLogger) {
        [DDLog removeLogger:[_fileLogger ddFileLogger]];
        _fileLogger = nil;
    }
}

+ (CBFileLogger *)fileLogger
{
    return _fileLogger;
}

#pragma mark -

+ (void)log:(int)level flag:(int)flag format:(NSString *)format args:(va_list)args
{
    if (level & flag) {
        [DDLog log:YES level:level flag:flag context:0 file:__FILE__ function:sel_getName(_cmd) line:__LINE__ tag:nil format:format args:args];
    }
}

#pragma mark - sdk log

+ (CBSdkLogLevel)sdkLogLevel
{
    return _sdkLogLevel;
}

+ (void)setSdkLogLevel:(CBSdkLogLevel)sdkLogLevel
{
    _sdkLogLevel = sdkLogLevel;
}

+ (void)sdkLogError:(NSString *)format, ...
{
    CB_LOG(_sdkLogLevel, CBSdkLogFlagError, format);
}

+ (void)sdkLogWarn:(NSString *)format, ...
{
    CB_LOG(_sdkLogLevel, CBSdkLogFlagWarn, format);
}

+ (void)sdkLogInfo:(NSString *)format, ...
{
    CB_LOG(_sdkLogLevel, CBSdkLogFlagInfo, format);
}

+ (void)sdkLogVerbose:(NSString *)format, ...
{
    CB_LOG(_sdkLogLevel, CBSdkLogFlagVerbose, format);
}

#pragma mark - kintone log

+ (CBLogLevel)logLevel
{
    return _logLevel;
}

+ (void)setLogLevel:(CBLogLevel)logLevel
{
    _logLevel = logLevel;
}

+ (void)logError:(NSString *)format, ...
{
    CB_LOG(_logLevel, CBLogFlagError, format);
}

+ (void)logWarn:(NSString *)format, ...
{
    CB_LOG(_logLevel, CBLogFlagWarn, format);
}

+ (void)logInfo:(NSString *)format, ...
{
    CB_LOG(_logLevel, CBLogFlagInfo, format);
}

+ (void)logVerbose:(NSString *)format, ...
{
    CB_LOG(_logLevel, CBLogFlagVerbose, format);
}

@end

#pragma mark -

@implementation CBFileLogger

static int const DEFAULT_FILE_SIZE = (1024 * 1024 * 3); // 3MB
static int const DEFAULT_NUM_FILES = 5;

static DDFileLogger *_ddFileLogger = nil;

@synthesize fileSize = _fileSize;
@synthesize numberOfFiles = _numberOfFiles;

+ (CBFileLogger *)sharedInstance
{
    static CBFileLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [CBFileLogger new];
    });

    return sharedInstance;
}

+ (NSString *)logsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
    
    return logsDirectory;
}

- (CBFileLogger *)init
{
    if (self = [super init]) {
        @synchronized(self) {
            if (_ddFileLogger == nil) {
                DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[CBFileLogger logsDirectory]];
                _ddFileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
                self.fileSize = DEFAULT_FILE_SIZE;
                self.numberOfFiles = DEFAULT_NUM_FILES;
                _ddFileLogger.rollingFrequency = 0; // never rolling by time
            }
        }
    }
    
    return self;
}

- (DDFileLogger *)ddFileLogger
{
    return _ddFileLogger;
}

- (int)fileSize
{
    return _ddFileLogger.maximumFileSize;
}

- (void)setFileSize:(int)fileSize
{
    _ddFileLogger.maximumFileSize = fileSize;
}

- (int)numberOfFiles
{
    return _ddFileLogger.logFileManager.maximumNumberOfLogFiles;
}

- (void)setNumberOfFiles:(int)numberOfFiles
{
    _ddFileLogger.logFileManager.maximumNumberOfLogFiles = numberOfFiles;
}

@end
