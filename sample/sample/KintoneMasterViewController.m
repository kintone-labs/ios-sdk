//
//  KintoneMasterViewController.m
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

#import "KintoneMasterViewController.h"

#import "KintoneAppDelegate.h"
#import "KintoneInitialViewController.h"
#import "KintoneDetailViewController.h"
#import "KintoneSetting.h"
#import "KintoneFieldUtil.h"

@interface KintoneMasterViewController () {
    NSMutableArray *_objects;
    UIActivityIndicatorView *_indicator;
}
@end

@implementation KintoneMasterViewController
{
    KintoneAppDelegate *_appDelegate;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // get notification of selectedListViewFields changes
    KintoneSetting *setting = [KintoneSetting sharedInstance];
    [setting addObserver:self forKeyPath:@"changedSelectedListViewFields" options:0 context:nil];

    // setting button
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(setting:)];

    self.navigationItem.rightBarButtonItems = @[settingButton];
    
    // indicator view
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.center = self.view.center;
    [self.view addSubview:_indicator];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];

    if (!_appDelegate.initialized) {
        // not initialized yet
        // show initial view controller
        KintoneInitialViewController *initialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
        initialViewController.masterViewController = self;
        [self presentViewController:initialViewController animated:NO completion:nil];
    }
    else {
        // already initialized

        [_indicator startAnimating];
        
        if (_appDelegate.fields.count == 0) {
            // get application form information
            CBNetworkingSuccessBlockForJSONResponse formSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                [_appDelegate.fields setDictionary:[KintoneField fieldsFromJSON:JSON]];
                [_indicator stopAnimating];
                
                [self fetchRecords];
            };

            CBNetworkingFailureBlockForJSONResponse formFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
                [_indicator stopAnimating];
                
                // show error dialog if failure
                UIAlertView *alert = [error alertView];
                [alert show];
            };
            
            [_appDelegate.kintoneApplication.kintoneAPI form:formSuccess failure:formFailure queue:[CBOperationQueue sharedNonConcurrentQueue]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)insertNewObject:(id)sender
{
    [self performSegueWithIdentifier:@"addRecord" sender:self];
}
 */

- (void)setting:(id)sender
{
    [self performSegueWithIdentifier:@"ToSetting" sender:self];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    KintoneRecord *object = _objects[indexPath.row];
    
    // display selected fields by list view setting
    // textLabel      : selectedListViewFields[0]
    // detailTextLabel: selectedListViewFields[1]
    NSArray *selectedListViewFields = [[KintoneSetting sharedInstance] parsedSelectedListViewFields];
    if (selectedListViewFields.count > 0) {
        NSDictionary *selectedListViewField = selectedListViewFields[0];
        cell.textLabel.text = [KintoneFieldUtil stringValue:[KintoneMasterViewController selectedField:selectedListViewField record:object]];
        
        if (selectedListViewFields.count > 1) {
            selectedListViewField = selectedListViewFields[1];
            NSString *detailText = [KintoneFieldUtil stringValue:[KintoneMasterViewController selectedField:selectedListViewField record:object]];
            cell.detailTextLabel.text = detailText;
        }
    }
    
    return cell;
}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KintoneRecord *object = _objects[indexPath.row];
        KintoneDetailViewController *detailViewController = (KintoneDetailViewController *)[segue destinationViewController];
        detailViewController.detailItem = object;
    }
}

+ (KintoneField *)selectedField:(NSDictionary *)selectedListViewField record:(KintoneRecord *)record
{
    NSString *code = (NSString *)selectedListViewField[@"code"];
    if (code.length == 0) {
        // build-in field
        for (NSString *code in record.fields.keyEnumerator) {
            KintoneField *field = (KintoneField *)record.fields[code];
            if (field.type == [KintoneField fieldTypeForFieldTypeName:selectedListViewField[@"type"]]) {
                return field;
            }
        }
    }
    else {
        // other field
        return (KintoneField *)record.fields[code];
    }
    
    return nil;
}

- (void)fetchRecords
{
    [_indicator startAnimating];
    
    CBNetworkingSuccessBlockForJSONResponse recordsSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        _objects = [NSMutableArray arrayWithArray:[KintoneRecord kintoneRecordsFromJSON:JSON]];
        [self.tableView reloadData];
        
        [_indicator stopAnimating];
    };
    CBNetworkingFailureBlockForJSONResponse recordsFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        [_indicator stopAnimating];
        
        // show error dialog if failure
        UIAlertView *alert = [error alertView];
        [alert show];
    };
    
    [_appDelegate.kintoneApplication.kintoneAPI recordsWithFields:nil
                                                     kintoneQuery:nil
                                                          success:recordsSuccess
                                                          failure:recordsFailure
                                                            queue:[CBOperationQueue sharedNonConcurrentQueue]];
}

- (void)onRefresh:(id)sender
{
    [self.refreshControl beginRefreshing];
    [self fetchRecords];
    [self.refreshControl endRefreshing];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"changedSelectedListViewFields"]) {
        // selected list view fields are changed.
        [self.tableView reloadData];
    }
}

@end
