//
//  KintoneInitialViewController.m
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

#import "KintoneInitialViewController.h"

#import "KintoneAppDelegate.h"
#import "KintoneMasterViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface KintoneInitialViewController ()

@end

@implementation KintoneInitialViewController
{
    KintoneAppDelegate *_appDelegate;
    UIPickerView *_certFilePickerView;
    UIActionSheet *_certFileActionSheet;
    NSMutableArray *_certFiles;
    NSString *_selectedCertFile;
}

static NSString * const NO_SELECTED_FILE = @"(no selected file)";
static NSString * const SELECTED_CERT_FILE_NAME = @"selectedCertFileName";

@synthesize masterViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    _appDelegate = [[UIApplication sharedApplication] delegate];
    CBCredential *cbCredential = _appDelegate.kintoneApplication.kintoneSite.cbCredential;
    
    // domain
    self.domain.text = _appDelegate.domain;
    // app ID
    self.appId.text = [NSString stringWithFormat:@"%d", _appDelegate.appId];
    // login name
    self.loginName.text = _appDelegate.loginName;
    // password
    self.password.text = [cbCredential password:nil];
    // basic authentication user
    self.basicAuthUser.text = [cbCredential basicAuthUser:nil];
    // basic authentication password
    self.basicAuthPassword.text = [cbCredential basicAuthPassword:nil];
    // client certificate
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedCertFileName = [userDefaults stringForKey:SELECTED_CERT_FILE_NAME];
    self.certFile.text = (selectedCertFileName != nil) ? selectedCertFileName : NO_SELECTED_FILE;
    
    [self setCloseButtonForTextField:self.domain];
    [self setCloseButtonForTextField:self.appId];
    [self setCloseButtonForTextField:self.loginName];
    [self setCloseButtonForTextField:self.password];
    [self setCloseButtonForTextField:self.basicAuthUser];
    [self setCloseButtonForTextField:self.basicAuthPassword];
    [self setCloseButtonForTextField:self.certPassword];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setDomain:nil];
    [self setAppId:nil];
    [self setLoginName:nil];
    [self setPassword:nil];
    [self setBasicAuthUser:nil];
    [self setBasicAuthPassword:nil];
    [self setCertPassword:nil];
    [self setCertFile:nil];
    [super viewDidUnload];
}

- (void)setCloseButtonForTextField:(UITextField *)textField
{
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,30)];
    accessoryView.backgroundColor = [UIColor clearColor];

    UIColor *backgroundColor = [UIColor colorWithRed:125/255.0 green:134/255.0 blue:146/255.0 alpha:1];

    UILabel *closeLabel = [UILabel new];
    closeLabel.backgroundColor = backgroundColor;
    closeLabel.frame = CGRectMake(290.0, 20.0, 30.0, 10.0);
    [accessoryView addSubview:closeLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(290.0, 0.0, 30.0, 30.0);
    closeButton.layer.cornerRadius = 4.0f;
    closeButton.layer.backgroundColor = [backgroundColor CGColor];
    [closeButton setTitle:@"▼" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView addSubview:closeButton];
    
    textField.inputAccessoryView = accessoryView;
}

- (void)closeKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cert file cell
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self discoverCertFiles];
        
        // tool bar
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
        toolBar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
        [toolBar setItems:@[doneButton] animated:YES];
        
        // picker view
        if (_certFilePickerView == nil) {
            _certFilePickerView = [UIPickerView new];
            _certFilePickerView.showsSelectionIndicator = YES;
            _certFilePickerView.delegate = self;
            _certFilePickerView.dataSource = self;
            _certFilePickerView.frame = CGRectMake(0.0f, toolBar.frame.size.height, _certFilePickerView.frame.size.width, _certFilePickerView.frame.size.height);
        }
        
        if (_certFileActionSheet == nil) {
            _certFileActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            [_certFileActionSheet addSubview:toolBar];
            [_certFileActionSheet addSubview:_certFilePickerView];
        }
        [_certFileActionSheet showInView:self.view];
        [_certFileActionSheet setBounds:CGRectMake(0, 0, self.view.frame.size.width, _certFileActionSheet.frame.size.height + toolBar.frame.size.height + _certFilePickerView.frame.size.height * 2)];
    }
}

#pragma mark - Text field delete

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)saveConfiguration:(id)sender
{
    if (self.domain.text.length == 0 || self.appId.text.length == 0 || self.loginName.text.length == 0 || self.password.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Error"
                                                        message:@"Domain / App ID / Login Name / Password should be specified."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
        return;
    }

    _appDelegate.domain = self.domain.text;
    _appDelegate.appId = [self.appId.text intValue];
    _appDelegate.loginName = self.loginName.text;
    
    // renew credential
    CBCredential *cbCredential = [[CBCredential alloc] initWithDomain:self.domain.text user:self.loginName.text];
    
    // password
    CBError* __autoreleasing error = nil;
    if (![cbCredential setPassword:self.password.text error:&error]) {
        UIAlertView *alert = [error alertView];
        [alert show];
    }
    
    // basic authentication user
    if (![cbCredential setBasicAuthUser:self.basicAuthUser.text error:&error]) {
        UIAlertView *alert = [error alertView];
        [alert show];
    }

    // basic authentication password
    if (![cbCredential setBasicAuthPassword:self.basicAuthPassword.text error:&error]) {
        UIAlertView *alert = [error alertView];
        [alert show];
    }

     // client certificate
    if (_certFilePickerView != nil) {
        NSDictionary *selectedCertFile = _certFiles[[_certFilePickerView selectedRowInComponent:0]];
        if (![selectedCertFile[@"name"] isEqualToString:NO_SELECTED_FILE]) {
            NSFileManager *fileManager = [NSFileManager new];
            if ([fileManager fileExistsAtPath:selectedCertFile[@"path"]] &&
                ![cbCredential importClientCertificateWithPath:selectedCertFile[@"path"] password:self.certPassword.text error:&error]) {
                UIAlertView *alert = [error alertView];
                [alert show];
            }
        }
    }

    // indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];

    // renew KintoneSite and KintoneApplication
    KintoneSite *kintoneSite = [[KintoneSite alloc] initWithCredential:cbCredential];
    KintoneApplication *kintoneApplication = [kintoneSite kintoneApplication:_appDelegate.appId];
    _appDelegate.kintoneApplication = kintoneApplication;

    // confirm connecting to kintone
    // use "form" api to confirm connecting to kintone
    
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        _appDelegate.initialized = YES;

        [indicator stopAnimating];
        
        // fetch kintone records
        [self.masterViewController fetchRecords];

        // dismiss setting view controller if success
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        _appDelegate.initialized = NO;
        
        [indicator stopAnimating];
        
        // show error dialog if failure
        UIAlertView *alert = [error alertView];
        [alert show];
    };
    
    [_appDelegate.kintoneApplication.kintoneAPI form:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
}

#pragma mark - UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _certFiles[row][@"name"];
}

#pragma mark - UIPickerView data source

- (void)discoverCertFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *certDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    _certFiles = [NSMutableArray array];
    [_certFiles addObject:@{@"name": NO_SELECTED_FILE, @"path" : @""}];
    
    NSFileManager *fileManager = [NSFileManager new];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:certDir];
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString:@"pfx"]) {
            [_certFiles addObject:@{@"name": file, @"path": [certDir stringByAppendingPathComponent:file]}];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _certFiles.count;
}

#pragma mark -

- (void)onDoneButton
{
    self.certFile.text = _certFiles[[_certFilePickerView selectedRowInComponent:0]][@"name"];
    [_certFileActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

@end
