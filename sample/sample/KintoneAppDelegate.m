//
//  KintoneAppDelegate.m
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

#import "KintoneAppDelegate.h"

#import "KintoneInitialViewController.h"

#define KINTONE_DEBUG   1

@implementation KintoneAppDelegate

static NSString * const INITIALIZED_KEY   = @"initialized";
static NSString * const DOMAIN_KEY        = @"domain";
static NSString * const APPID_KEY         = @"appId";
static NSString * const LOGINNAME_KEY     = @"loginName";

@synthesize initialized;
@synthesize domain = _domain;
@synthesize loginName = _loginName;
@synthesize appId = _appId;
@synthesize kintoneApplication;
@synthesize fields;

+ (void)initialize
{
#if DEBUG
    [CBLog setSdkLogLevel:CBSdkLogLevelVerbose];
    [CBLog setLogLevel:CBLogLevelVerbose];

    CBFileLogger *fileLogger = [CBFileLogger sharedInstance];
    [CBLog setFileLogger:fileLogger];
#else
    [CBLog setSdkLogLevel:KintoneSdkLogLevelOff];
    [CBLog setLogLevel:KintoneLogLevelOff];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];

    _domain = nil;
    _loginName = nil;
    _appId = -1;
    kintoneApplication = nil;
    fields = [NSMutableDictionary new];

    if (self.initialized) {
        CBCredential *credential = [[CBCredential alloc] initWithDomain:self.domain user:self.loginName];
        KintoneSite *kintoneSite = [[KintoneSite alloc] initWithCredential:credential];
        kintoneApplication = [kintoneSite kintoneApplication:self.appId];

        /*
        // indicator
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.center = self.window.rootViewController.view.center;
        [self.window.rootViewController.view addSubview:indicator];
        [indicator startAnimating];
        
        // get application form information
        CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [fields setDictionary:[KintoneField fieldsFromJSON:JSON]];
        
            [indicator stopAnimating];
        };
        CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            [[CBOperationQueue sharedConcurrentQueue] cancelAllOperations];
            [indicator stopAnimating];
            
            // show error dialog if failure
            UIAlertView *alert = [error alertView];
            [alert show];
        };
        
        [kintoneApplication.kintoneAPI form:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
         */
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)initialized
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:INITIALIZED_KEY];
}

- (void)setInitialized:(BOOL)newInitialized
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:newInitialized forKey:INITIALIZED_KEY];
    [userDefaults synchronize];
}

- (NSString *)domain
{
    if (_domain == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _domain = [userDefaults stringForKey:DOMAIN_KEY];
    }
    
    return _domain;
}

- (void)setDomain:(NSString *)domain
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:domain forKey:DOMAIN_KEY];
    [userDefaults synchronize];
    
    _domain = domain;
}

- (NSString *)loginName
{
    if (_loginName == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _loginName = [userDefaults stringForKey:LOGINNAME_KEY];
    }
    
    return _loginName;
}

- (void)setLoginName:(NSString *)loginName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:loginName forKey:LOGINNAME_KEY];
    [userDefaults synchronize];
    
    _loginName = loginName;
}

- (int)appId
{
    if (_appId < 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _appId = [userDefaults integerForKey:APPID_KEY];
    }
    
    return _appId;
}

- (void)setAppId:(int)appId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:appId forKey:APPID_KEY];
    [userDefaults synchronize];
    
    _appId = appId;
}

@end
