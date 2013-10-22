//
//  KintoneViewSettingViewController.m
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

#import "KintoneViewSettingViewController.h"

#import "KintoneAppDelegate.h"
#import "KintoneSetting.h"

@interface KintoneViewSettingViewController ()

@property (nonatomic, copy) NSMutableArray *fields;

@end

@implementation KintoneViewSettingViewController

@synthesize selectedView;
@synthesize fields;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //
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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // indicator
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    
    switch (self.selectedView) {
        case KintoneListViewSetting:
            self.title = @"List View Setting";
            break;
        case KintoneDetailViewSetting:
            self.title = @"Detail View Setting";
            break;
            
        default:
            break;
    }
    
    KintoneAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    fields = [NSMutableArray new];
    NSMutableDictionary *fieldList = [NSMutableDictionary new];
    
    // get application form information
    CBNetworkingSuccessBlockForJSONResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [fieldList setDictionary:[KintoneField fieldsFromJSON:JSON]];
        [fields setArray:fieldList.allValues];
        
        // built-in fields
        NSArray *builtInFields = @[[[KintoneField alloc] initWithProperties:@{@"type": [KintoneField fieldTypeNameForFieldType:KintoneRecordNumberFieldType]}],
                                   [[KintoneField alloc] initWithProperties:@{@"type": [KintoneField fieldTypeNameForFieldType:KintoneCreatorFieldType]}],
                                   [[KintoneField alloc] initWithProperties:@{@"type": [KintoneField fieldTypeNameForFieldType:KintoneCreatedTimeFieldType]}],
                                   [[KintoneField alloc] initWithProperties:@{@"type": [KintoneField fieldTypeNameForFieldType:KintoneModifierFieldType]}],
                                   [[KintoneField alloc] initWithProperties:@{@"type": [KintoneField fieldTypeNameForFieldType:KintoneUpdatedTimeFieldType]}]];
        [fields insertObjects:builtInFields atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];

        // get a record to create more accurate form information
        CBNetworkingSuccessBlockForJSONResponse recordsSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSArray *records = [KintoneRecord kintoneRecordsFromJSON:JSON];
            
            if (records.count > 0) {
                [fields removeAllObjects];
                KintoneRecord *record = (KintoneRecord *)records[0];
                [fieldList addEntriesFromDictionary:record.fields];
                
                // built-in fields
                NSArray *builtInFields = @[record.recordNumber, record.creator, record.createdTime, record.modifier, record.updatedTime];
                
                for (NSString *code in fieldList.keyEnumerator) {
                    KintoneField *field = (KintoneField *)fieldList[code];

                    switch (field.type) {
                        case KintoneRecordNumberFieldType:
                        case KintoneCreatorFieldType:
                        case KintoneCreatedTimeFieldType:
                        case KintoneModifierFieldType:
                        case KintoneUpdatedTimeFieldType:
                            continue;
                            
                        default:
                            [self.fields addObject:field];
                            break;
                    }
                }
                
                [fields insertObjects:builtInFields atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)]];
            }

            [self.tableView reloadData];
            
            [indicator stopAnimating];
        };
        CBNetworkingFailureBlockForJSONResponse recordsFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            [[CBOperationQueue sharedConcurrentQueue] cancelAllOperations];
            [self.tableView reloadData];

            [indicator stopAnimating];
            
            // show error dialog if failure
            UIAlertView *alert = [error alertView];
            [alert show];
        };
        
        KintoneQuery *q = [KintoneQuery new];
        [q limit:1];
        
        [appDelegate.kintoneApplication.kintoneAPI recordsWithFields:nil
                                                        kintoneQuery:q
                                                             success:recordsSuccess
                                                             failure:recordsFailure
                                                               queue:[CBOperationQueue sharedNonConcurrentQueue]];
    };
    CBNetworkingFailureBlockForJSONResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        [[CBOperationQueue sharedConcurrentQueue] cancelAllOperations];
        [indicator stopAnimating];
        
        // show error dialog if failure
        UIAlertView *alert = [error alertView];
        [alert show];
    };

    [appDelegate.kintoneApplication.kintoneAPI form:success failure:failure queue:[CBOperationQueue sharedNonConcurrentQueue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    KintoneField *field = (KintoneField *)fields[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"code: %@", field.code];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"type: %@", [KintoneField fieldTypeNameForFieldType:field.type]];

    // show checkmarks
    cell.accessoryType = UITableViewCellAccessoryNone;
    KintoneSetting *setting = [KintoneSetting sharedInstance];
    NSArray *selectedViewFields = nil;
    switch (self.selectedView) {
        case KintoneListViewSetting:
            selectedViewFields = [setting parsedSelectedListViewFields];
            break;
        case KintoneDetailViewSetting:
            selectedViewFields = [setting parsedSelectedDetailViewFields];
            break;

        default:
            break;
    }

    for (NSDictionary *selectedField in selectedViewFields) {
        NSString *code = (NSString *)selectedField[@"code"];
        if ((code.length == 0 && field.type == [KintoneField fieldTypeForFieldTypeName:selectedField[@"type"]]) || // built-in field
            (code.length > 0 && [field.code isEqualToString:selectedField[@"code"]])) { // other field
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;

    switch (self.selectedView) {
        case KintoneListViewSetting:
            title = @"Select a field for list view";
            break;
        case KintoneDetailViewSetting:
            title = @"Select fields for detail view";
            break;
            
        default:
            title = @"";
            break;
    }
    
    return title;
}

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
    switch (self.selectedView) {
        case KintoneListViewSetting:
            [[KintoneSetting sharedInstance] chooseListViewField:self.fields[indexPath.row]];
            break;
        case KintoneDetailViewSetting:
            [[KintoneSetting sharedInstance] chooseDetailViewField:self.fields[indexPath.row]];
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

@end
