//
//  KintoneRecord.m
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

#import "KintoneRecord.h"

#import "KintoneField.h"

@interface KintoneRecord ()

@property (nonatomic, readwrite) NSMutableDictionary *fields;
@property (nonatomic, readwrite) KintoneRecordNumberField *recordNumber;
@property (nonatomic, readwrite) KintoneCreatorField *creator;
@property (nonatomic, readwrite) KintoneCreatedTimeField *createdTime;
@property (nonatomic, readwrite) KintoneModifierField *modifier;
@property (nonatomic, readwrite) KintoneUpdatedTimeField *updatedTime;

@end

@implementation KintoneRecord

- (KintoneRecord *)init
{
    if (self = [super init]) {
        self.fields = [NSMutableDictionary dictionary];
        self.recordNumber = nil;
        self.creator = nil;
        self.createdTime = nil;
        self.modifier = nil;
        self.updatedTime = nil;
    }
    
    return self;
}

- (void)addField:(KintoneField *)field
{
    // subtable record number doesn't have a field code.
    if (![NSString isNilOrEmpty:field.code]) {
        self.fields[field.code] = field;
    }
    
    // set built-in fields
    switch (field.type) {
        case KintoneRecordNumberFieldType:
            self.recordNumber = (KintoneRecordNumberField *)field;
            break;
        case KintoneCreatorFieldType:
            self.creator = (KintoneCreatorField *)field;
            break;
        case KintoneCreatedTimeFieldType:
            self.createdTime = (KintoneCreatedTimeField *)field;
            break;
        case KintoneModifierFieldType:
            self.modifier = (KintoneModifierField *)field;
            break;
        case KintoneUpdatedTimeFieldType:
            self.updatedTime = (KintoneUpdatedTimeField *)field;
            break;
            
        default:
            break;
    }
}

+ (KintoneRecord *)kintoneRecordFromJSON:(id)JSON
{
    return [KintoneRecord kintoneRecordFromDictionary:JSON[@"record"]];
}

+ (KintoneRecord *)kintoneRecordFromDictionary:(NSDictionary *)record
{
    KintoneRecord *kintoneRecord = [KintoneRecord new];
    
    for (NSString *code in record.keyEnumerator) {
        NSDictionary *properties = @{@"code"  : code,
                                     @"type"  : record[code][@"type"],
                                     @"value" : record[code][@"value"]};
        KintoneField *field = [[KintoneField alloc] initWithProperties:properties];
        [kintoneRecord addField:field];
    }
    
    return kintoneRecord;
}

+ (NSArray *)kintoneRecordsFromJSON:(id)JSON
{
    NSArray *jsonArray = (NSArray *)JSON[@"records"];
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:jsonArray.count];
    
    for (NSDictionary *record in jsonArray) {
        [records addObject:[KintoneRecord kintoneRecordFromDictionary:record]];
    }
    
    return records;
}

@end
