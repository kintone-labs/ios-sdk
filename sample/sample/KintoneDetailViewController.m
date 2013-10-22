//
//  KintoneDetailViewController.m
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

#import "KintoneDetailViewController.h"

#import "KintoneAppDelegate.h"
#import "KintoneFieldUtil.h"
#import "KintoneSetting.h"
#import "KintoneFileFieldCell.h"
#import "KintoneSubtableFieldCell.h"
#import "KintoneTextFieldCell.h"

@interface KintoneDetailViewController ()

@property (nonatomic) KintoneAppDelegate *appDelegate;
@property (nonatomic) NSDictionary *form;
@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation KintoneDetailViewController

static NSString * const KINTONE_FIELD_CELL = @"KintoneFieldCell";
static NSString * const KINTONE_FILE_FIELD_CELL = @"KintoneFileFieldCell";
static NSString * const KINTONE_TEXT_FIELD_CELL = @"KintoneTextFieldCell";
static NSString * const KINTONE_SUBTABLE_FIELD_CELL = @"KintoneSubtableFieldCell";

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
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];

    [self.tableView registerClass:[KintoneFieldCell class] forCellReuseIdentifier:KINTONE_FIELD_CELL];
    [self.tableView registerClass:[KintoneFileFieldCell class] forCellReuseIdentifier:KINTONE_FILE_FIELD_CELL];
    [self.tableView registerNib:[UINib nibWithNibName:KINTONE_TEXT_FIELD_CELL bundle:nil] forCellReuseIdentifier:KINTONE_TEXT_FIELD_CELL];
    [self.tableView registerClass:[KintoneSubtableFieldCell class] forCellReuseIdentifier:KINTONE_SUBTABLE_FIELD_CELL];
    
    [self fetchRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[KintoneSetting sharedInstance] parsedSelectedDetailViewFields].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedViewField = [[KintoneSetting sharedInstance] parsedSelectedDetailViewFields][indexPath.row];
    
    NSString *cellIdentifier;
    KintoneFieldType fieldType = [KintoneField fieldTypeForFieldTypeName:selectedViewField[@"type"]];
    switch (fieldType) {
        case KintoneSingleLineTextFieldType:
        case KintoneNumberFieldType:
        case KintoneCalcFieldType:
        case KintoneMultiLineTextFieldType:
        case KintoneRichTextFieldType:
        case KintoneCheckBoxFieldType:
        case KintoneRadioButtonFieldType:
        case KintoneDropDownFieldType:
        case KintoneMultiSelectFieldType:
        case KintoneDateFieldType:
        case KintoneTimeFieldType:
        case KintoneDatetimeFieldType:
        case KintoneLinkFieldType:
        case KintoneUserSelectFieldType:
        case KintoneCategoryFieldType:
        case KintoneStatusFieldType:
        case KintoneStatusAssigneeFieldType:
        case KintoneRecordNumberFieldType:
        case KintoneCreatorFieldType:
        case KintoneCreatedTimeFieldType:
        case KintoneModifierFieldType:
        case KintoneUpdatedTimeFieldType:
            cellIdentifier = KINTONE_TEXT_FIELD_CELL;
            break;
        case KintoneFileFieldType:
            cellIdentifier = KINTONE_FILE_FIELD_CELL;
            break;
        case KintoneSubtableFieldType:
            cellIdentifier = KINTONE_SUBTABLE_FIELD_CELL;
            break;
            
        default:
            cellIdentifier = KINTONE_FIELD_CELL;
            break;
    }
    KintoneFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValueWithKintoneField:self.detailItem.fields[selectedViewField[@"code"]] form:self.form];
    
    return cell;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KintoneFieldCell *cell = (KintoneFieldCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];

    return [cell height:tableView.frame.size];
}

#pragma mark -

- (void)fetchRecord
{
    [self.indicator startAnimating];
    
    CBNetworkingSuccessBlockForJSONResponse formSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.form = [KintoneField fieldsFromJSON:JSON];
    
        CBNetworkingSuccessBlockForJSONResponse recordSuccess = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            self.detailItem = [KintoneRecord kintoneRecordFromJSON:JSON];
            [self.tableView reloadData];
            
            [self.indicator stopAnimating];
        };
        CBNetworkingFailureBlockForJSONResponse recordFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
            [[CBOperationQueue sharedConcurrentQueue] cancelAllOperations];
            [self.indicator stopAnimating];
            
            // show error dialog if failure
            UIAlertView *alert = [error alertView];
            [alert show];
        };
        
        [self.appDelegate.kintoneApplication.kintoneAPI record:[self.detailItem.recordNumber.value intValue]
                                                       success:recordSuccess
                                                       failure:recordFailure
                                                         queue:[CBOperationQueue sharedNonConcurrentQueue]];
    };
    CBNetworkingFailureBlockForJSONResponse formFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error, id JSON) {
        [[CBOperationQueue sharedConcurrentQueue] cancelAllOperations];
        [self.indicator stopAnimating];
        
        // show error dialog if failure
        UIAlertView *alert = [error alertView];
        [alert show];
    };
    
    [self.appDelegate.kintoneApplication.kintoneAPI form:formSuccess failure:formFailure queue:[CBOperationQueue sharedNonConcurrentQueue]];
}

@end
