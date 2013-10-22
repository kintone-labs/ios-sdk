//
//  KintoneSetting.m
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

#import "KintoneSetting.h"

@interface KintoneSetting ()

@property (nonatomic, copy, readwrite) NSMutableArray *selectedListViewFields;
@property (nonatomic, copy, readwrite) NSMutableArray *selectedDetailViewFields;

@end

@implementation KintoneSetting

static NSString * const SELECTED_LIST_VIEW_FIELDS = @"selectedListViewFields";
static NSString * const SELECTED_DETAIL_VIEW_FIELDS = @"selectedDetailViewFields";

@synthesize selectedListViewFields;
@synthesize selectedDetailViewFields;
@synthesize changedSelectedListViewFields;
@synthesize changedSelectedDetailViewFields;

+ (KintoneSetting *)sharedInstance
{
    static KintoneSetting *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
        sharedInstance.selectedListViewFields = nil;
        sharedInstance.selectedDetailViewFields = nil;
    });
    
    return sharedInstance;
}

- (NSArray *)selectedListViewFields
{
    if (selectedListViewFields == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        selectedListViewFields = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:SELECTED_LIST_VIEW_FIELDS]];
        
        if (selectedListViewFields.count == 0) {
            // record number field is always selected.
            selectedListViewFields = [NSMutableArray arrayWithArray:@[[NSString stringWithFormat:@":%@", [KintoneField fieldTypeNameForFieldType:KintoneRecordNumberFieldType]]]];
            [userDefaults setObject:selectedListViewFields forKey:SELECTED_LIST_VIEW_FIELDS];
            [userDefaults synchronize];
        }
    }
    
    return selectedListViewFields;
}

- (NSArray *)selectedDetailViewFields
{
    if (selectedDetailViewFields == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        selectedDetailViewFields = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:SELECTED_DETAIL_VIEW_FIELDS]];
    }
    
    return selectedDetailViewFields;
}

- (void)chooseListViewField:(KintoneField *)field
{
    NSString *code = (field.code == nil) ? @"" : field.code;
    NSString *fieldString = [NSString stringWithFormat:@"%@:%@", code, [KintoneField fieldTypeNameForFieldType:field.type]];
    if (self.selectedListViewFields.count == 2) {
        self.selectedListViewFields[1] = fieldString;
    }
    else {
        [self.selectedListViewFields addObject:fieldString];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.selectedListViewFields forKey:SELECTED_LIST_VIEW_FIELDS];
    [userDefaults synchronize];
    self.changedSelectedListViewFields = YES;
}

- (void)chooseDetailViewField:(KintoneField *)field
{
    NSString *code = (field.code == nil) ? @"" : field.code;
    NSString *fieldString = [NSString stringWithFormat:@"%@:%@", code, [KintoneField fieldTypeNameForFieldType:field.type]];
    if ([self.selectedDetailViewFields indexOfObject:fieldString] == NSNotFound) {
        // new field
        [self.selectedDetailViewFields addObject:fieldString];
    }
    else {
        // already selected field
        [self.selectedDetailViewFields removeObject:fieldString];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.selectedDetailViewFields forKey:SELECTED_DETAIL_VIEW_FIELDS];
    [userDefaults synchronize];
    self.changedSelectedDetailViewFields = YES;
}

- (NSArray *)parsedSelectedViewFields:(NSArray *)selectedViewFields
{
    NSMutableArray *parsedSelectedFields = [NSMutableArray arrayWithCapacity:selectedViewFields.count];
    for (NSString *selectedField in selectedViewFields) {
        // selectedField = <field code>:<field type>
        NSDictionary *parsedField;
        NSRange range = [selectedField rangeOfString:@":" options:NSBackwardsSearch];
        if (range.location == 0) {
            parsedField = @{@"code" : @"",
                            @"type" : [selectedField substringFromIndex:1]};
        }
        else {
            parsedField = @{@"code" : [selectedField substringToIndex:range.location],
                            @"type" : [selectedField substringFromIndex:(range.location + 1)]};
        }

        [parsedSelectedFields addObject:parsedField];
    }
    
    return parsedSelectedFields;
}

- (NSArray *)parsedSelectedListViewFields
{
    return [self parsedSelectedViewFields:self.selectedListViewFields];
}

- (NSArray *)parsedSelectedDetailViewFields
{
    return [self parsedSelectedViewFields:self.selectedDetailViewFields];
}

@end
