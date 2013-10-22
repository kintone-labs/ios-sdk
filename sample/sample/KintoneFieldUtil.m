//
//  KintoneFieldUtil.m
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

#import "KintoneFieldUtil.h"

@implementation KintoneFieldUtil

+ (NSString *)stringValue:(KintoneField *)field
{
    NSString *ret = @"";
    
    if (field.value == nil || [field.value isMemberOfClass:[NSNull class]]) {
        return ret;
    }
    
    if (field != nil) {
        switch (field.type) {
            case KintoneSingleLineTextFieldType:
            case KintoneMultiLineTextFieldType:
            case KintoneNumberFieldType:
            case KintoneCalcFieldType:
            case KintoneRichTextFieldType:
            case KintoneRadioButtonFieldType:
            case KintoneDropDownFieldType:
            case KintoneDateFieldType:
            case KintoneTimeFieldType:
            case KintoneDatetimeFieldType:
            case KintoneLinkFieldType:
            case KintoneStatusFieldType:
            case KintoneCreatedTimeFieldType:
            case KintoneUpdatedTimeFieldType:
                ret = field.value;
                break;
            case KintoneCheckBoxFieldType:
            case KintoneMultiSelectFieldType:
            case KintoneCategoryFieldType:
            {
                NSArray *value = (NSArray *)field.value;
                ret = [value componentsJoinedByString:@", "];
            }
                break;
            case KintoneFileFieldType:
            {
                NSArray *value = (NSArray *)field.value;
                NSMutableArray *files = [NSMutableArray arrayWithCapacity:value.count];
                for (KintoneFile *file in value) {
                    [files addObject:file.name];
                }
                ret = [files componentsJoinedByString:@", "];
            }
                break;
            case KintoneUserSelectFieldType:
            case KintoneStatusAssigneeFieldType:
            {
                NSArray *value = (NSArray *)field.value;
                NSMutableArray *users = [NSMutableArray arrayWithCapacity:value.count];
                for (NSDictionary *user in value) {
                    [users addObject:[NSString stringWithFormat:@"%@ (%@)", user[@"name"], user[@"code"]]];
                }
                ret = [users componentsJoinedByString:@", "];
            }
                break;
            case KintoneRecordNumberFieldType:
                ret = [field.value stringValue];
                break;
            case KintoneCreatorFieldType:
            case KintoneModifierFieldType:
            {
                NSDictionary *value = (NSDictionary *)field.value;
                ret = [NSString stringWithFormat:@"%@ (%@)", value[@"name"], value[@"code"]];
            }
                break;
            default:
                ret = @"";
                break;
        }
    }
    
    return ret;
}

@end
