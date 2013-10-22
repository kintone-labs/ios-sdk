//
//  KintoneField.m
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

#import "KintoneField.h"

#import "KintoneFile.h"
#import "KintoneRecord.h"
#import "NSDate+Utility.h"

@interface KintoneField ()

@property (nonatomic, copy, readwrite) NSString *label;
@property (nonatomic, copy, readwrite) NSString *code;
@property (nonatomic, readwrite) KintoneFieldType type;
@property (nonatomic, readwrite) BOOL required;
@property (nonatomic, readwrite) BOOL noLabel;
@property (nonatomic, readwrite) BOOL unique;
@property (nonatomic, readwrite) int maxValue;
@property (nonatomic, readwrite) int minValue;
@property (nonatomic, readwrite) int maxLength;
@property (nonatomic, readwrite) int minLength;
@property (nonatomic, copy, readwrite) id defaultValue;
@property (nonatomic, copy, readwrite) NSString *defaultExpression;
@property (nonatomic, copy, readwrite) NSArray *options;
@property (nonatomic, copy, readwrite) NSString *expression;
@property (nonatomic, readwrite) BOOL digit;
@property (nonatomic, copy, readwrite) NSString *protocol;
@property (nonatomic, copy, readwrite) NSString *format;
@property (nonatomic, readwrite) id value;

@end

@implementation KintoneField

static NSString * const FIELD_TYPE_NAME_LABEL            = @"LABEL";
static NSString * const FIELD_TYPE_NAME_SINGLE_LINE_TEXT = @"SINGLE_LINE_TEXT";
static NSString * const FIELD_TYPE_NAME_NUMBER           = @"NUMBER";
static NSString * const FIELD_TYPE_NAME_CALC             = @"CALC";
static NSString * const FIELD_TYPE_NAME_MULTI_LINE_TEXT  = @"MULTI_LINE_TEXT";
static NSString * const FIELD_TYPE_NAME_RICH_TEXT        = @"RICH_TEXT";
static NSString * const FIELD_TYPE_NAME_CHECK_BOX        = @"CHECK_BOX";
static NSString * const FIELD_TYPE_NAME_RADIO_BUTTON     = @"RADIO_BUTTON";
static NSString * const FIELD_TYPE_NAME_DROP_DOWN        = @"DROP_DOWN";
static NSString * const FIELD_TYPE_NAME_MULTI_SELECT     = @"MULTI_SELECT";
static NSString * const FIELD_TYPE_NAME_FILE             = @"FILE";
static NSString * const FIELD_TYPE_NAME_DATE             = @"DATE";
static NSString * const FIELD_TYPE_NAME_TIME             = @"TIME";
static NSString * const FIELD_TYPE_NAME_DATETIME         = @"DATETIME";
static NSString * const FIELD_TYPE_NAME_LINK             = @"LINK";

// unsupported fields by form API
static NSString * const FIELD_TYPE_NAME_USER_SELECT     = @"USER_SELECT";
static NSString * const FIELD_TYPE_NAME_LOOKUP          = @"LOOKUP";
static NSString * const FIELD_TYPE_NAME_REFERENCE_TABLE = @"REFERENCE_TABLE";
static NSString * const FIELD_TYPE_NAME_CATEGORY        = @"CATEGORY";
static NSString * const FIELD_TYPE_NAME_STATUS          = @"STATUS";
static NSString * const FIELD_TYPE_NAME_STATUS_ASSIGNEE = @"STATUS_ASSIGNEE";

// built-in fields
static NSString * const FIELD_TYPE_NAME_RECORD_NUMBER = @"RECORD_NUMBER";
static NSString * const FIELD_TYPE_NAME_CREATOR       = @"CREATOR";
static NSString * const FIELD_TYPE_NAME_CREATED_TIME  = @"CREATED_TIME";
static NSString * const FIELD_TYPE_NAME_MODIFIER      = @"MODIFIER";
static NSString * const FIELD_TYPE_NAME_UPDATED_TIME  = @"UPDATED_TIME";

static NSString * const FIELD_TYPE_NAME_SUBTABLE      = @"SUBTABLE";

static NSDictionary *fieldTypeNameToFieldType()
{
    static NSDictionary *dict = nil;
    if (dict == nil) {
        dict = @{FIELD_TYPE_NAME_LABEL            : @(KintoneLabelFieldType),
                 FIELD_TYPE_NAME_SINGLE_LINE_TEXT : @(KintoneSingleLineTextFieldType),
                 FIELD_TYPE_NAME_NUMBER           : @(KintoneNumberFieldType),
                 FIELD_TYPE_NAME_CALC             : @(KintoneCalcFieldType),
                 FIELD_TYPE_NAME_MULTI_LINE_TEXT  : @(KintoneMultiLineTextFieldType),
                 FIELD_TYPE_NAME_RICH_TEXT        : @(KintoneRichTextFieldType),
                 FIELD_TYPE_NAME_CHECK_BOX        : @(KintoneCheckBoxFieldType),
                 FIELD_TYPE_NAME_RADIO_BUTTON     : @(KintoneRadioButtonFieldType),
                 FIELD_TYPE_NAME_DROP_DOWN        : @(KintoneDropDownFieldType),
                 FIELD_TYPE_NAME_MULTI_SELECT     : @(KintoneMultiSelectFieldType),
                 FIELD_TYPE_NAME_FILE             : @(KintoneFileFieldType),
                 FIELD_TYPE_NAME_DATE             : @(KintoneDateFieldType),
                 FIELD_TYPE_NAME_TIME             : @(KintoneTimeFieldType),
                 FIELD_TYPE_NAME_DATETIME         : @(KintoneDatetimeFieldType),
                 FIELD_TYPE_NAME_LINK             : @(KintoneLinkFieldType),
                 FIELD_TYPE_NAME_USER_SELECT      : @(KintoneUserSelectFieldType),
                 FIELD_TYPE_NAME_LOOKUP           : @(KintoneLookupFieldType),
                 FIELD_TYPE_NAME_REFERENCE_TABLE  : @(KintoneReferenceTableFieldType),
                 FIELD_TYPE_NAME_CATEGORY         : @(KintoneCategoryFieldType),
                 FIELD_TYPE_NAME_STATUS           : @(KintoneStatusFieldType),
                 FIELD_TYPE_NAME_STATUS_ASSIGNEE  : @(KintoneStatusAssigneeFieldType),
                 FIELD_TYPE_NAME_RECORD_NUMBER    : @(KintoneRecordNumberFieldType),
                 FIELD_TYPE_NAME_CREATOR          : @(KintoneCreatorFieldType),
                 FIELD_TYPE_NAME_CREATED_TIME     : @(KintoneCreatedTimeFieldType),
                 FIELD_TYPE_NAME_MODIFIER         : @(KintoneModifierFieldType),
                 FIELD_TYPE_NAME_UPDATED_TIME     : @(KintoneUpdatedTimeFieldType),
                 FIELD_TYPE_NAME_SUBTABLE         : @(KintoneSubtableFieldType)};
    }
    
    return dict;
}

static NSDictionary *fieldTypeToFieldTypeName()
{
    static NSMutableDictionary *dict = nil;
    if (dict == nil) {
        NSDictionary *source = fieldTypeNameToFieldType();
        dict = [NSMutableDictionary dictionaryWithCapacity:source.count];
        for (NSString *key in source.keyEnumerator) {
            dict[source[key]] = key;
        }
    }
    
    return dict;
}

+ (KintoneFieldType)fieldTypeForFieldTypeName:(NSString *)fieldTypeName
{
    return [fieldTypeNameToFieldType()[fieldTypeName] intValue];
}

+ (NSString *)fieldTypeNameForFieldType:(KintoneFieldType)fieldType
{
    return fieldTypeToFieldTypeName()[@(fieldType)];
}

- (instancetype)initWithProperties:(NSDictionary *)properties
{
    assert(properties != nil);
    
    _value = nil;
    switch ([KintoneField fieldTypeForFieldTypeName:properties[@"type"]]) {
        case KintoneLabelFieldType:
            self = [KintoneLabelField new];
            break;
        case KintoneSingleLineTextFieldType:
            self = [KintoneSingleLineTextField new];
            break;
        case KintoneNumberFieldType:
            self = [KintoneNumberField new];
            break;
        case KintoneCalcFieldType:
            self = [KintoneCalcField new];
            break;
        case KintoneMultiLineTextFieldType:
            self = [KintoneMultiLineTextField new];
            break;
        case KintoneRichTextFieldType:
            self = [KintoneRichTextField new];
            break;
        case KintoneCheckBoxFieldType:
            self = [KintoneCheckBoxField new];
            break;
        case KintoneRadioButtonFieldType:
            self = [KintoneRadioButtonField new];
            break;
        case KintoneDropDownFieldType:
            self = [KintoneDropDownField new];
            break;
        case KintoneMultiSelectFieldType:
            self = [KintoneMultiSelectField new];
            break;
        case KintoneFileFieldType:
            self = [KintoneFileField new];
            [self setValue:properties[@"value"] error:nil];
            break;
        case KintoneDateFieldType:
            self = [KintoneDateField new];
            break;
        case KintoneTimeFieldType:
            self = [KintoneTimeField new];
            break;
        case KintoneDatetimeFieldType:
            self = [KintoneDatetimeField new];
            break;
        case KintoneLinkFieldType:
            self = [KintoneLinkField new];
            break;
        case KintoneUserSelectFieldType:
            self = [KintoneUserSelectField new];
            break;
        case KintoneLookupFieldType:
            self = [KintoneLookupField new];
            break;
        case KintoneCategoryFieldType:
            self = [KintoneCategoryField new];
            break;
        case KintoneStatusFieldType:
            self = [KintoneStatusField new];
            break;
        case KintoneStatusAssigneeFieldType:
            self = [KintoneStatusAssigneeField new];
            break;
        case KintoneRecordNumberFieldType:
            self = [KintoneRecordNumberField new];
            if ([properties[@"value"] isKindOfClass:[NSString class]]) {
                _value = [NSNumber numberWithInt:[properties[@"value"] intValue]];
            }
            break;
        case KintoneCreatorFieldType:
            self = [KintoneCreatorField new];
            break;
        case KintoneCreatedTimeFieldType:
            self = [KintoneCreatedTimeField new];
            break;
        case KintoneModifierFieldType:
            self = [KintoneModifierField new];
            break;
        case KintoneUpdatedTimeFieldType:
            self = [KintoneUpdatedTimeField new];
            break;
        case KintoneSubtableFieldType:
            self = [KintoneSubtableField new];
            _value = [KintoneSubtableField recordsFromJSON:properties[@"value"]];
            break;
            
        default:
            // unsupported field
            self = [super init];
            break;
    }
    
    if (self) {
        _label             = properties[@"label"];
        _code              = properties[@"code"];
        _type              = [KintoneField fieldTypeForFieldTypeName:properties[@"type"]];
        _required          = [properties[@"required"] boolValue];
        _noLabel           = [properties[@"noLabel"] boolValue];
        _unique            = [properties[@"unique"] boolValue];
        _maxValue          = (properties[@"maxValue"] == nil || [properties[@"maxValue"] isMemberOfClass:[NSNull class]]) ? INT_MAX : [properties[@"maxValue"] intValue];
        _minValue          = (properties[@"minValue"] == nil || [properties[@"minValue"] isMemberOfClass:[NSNull class]]) ? 0 : [properties[@"minValue"] intValue];
        _maxLength         = (properties[@"maxLength"] == nil || [properties[@"maxLength"] isMemberOfClass:[NSNull class]]) ? INT_MAX : [properties[@"maxLength"] intValue];
        _minLength         = (properties[@"minLength"] == nil || [properties[@"minLength"] isMemberOfClass:[NSNull class]]) ? 0 : [properties[@"minLength"] intValue];
        _defaultValue      = properties[@"defaultValue"];
        _defaultExpression = properties[@"defaultExpression"];
        _options           = properties[@"options"];
        _expression        = properties[@"expression"];
        _digit             = [properties[@"digit"] boolValue];
        _protocol          = properties[@"protocol"];
        _format            = properties[@"format"];
        _value             = _value == nil ? properties[@"value"] : _value;
    }
    
    return self;
}

+ (NSDictionary *)fieldsFromJSON:(id)JSON
{
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    for (NSDictionary *properties in JSON[@"properties"]) {
        KintoneFieldType fieldType = [KintoneField fieldTypeForFieldTypeName:properties[@"type"]];
        if (fieldType == KintoneLabelFieldType) {
            // label field is omitted because it has no unique key "code"
            continue;
        }
        
        fields[properties[@"code"]] = [[KintoneField alloc] initWithProperties:properties];
    }

    return fields;
}

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operator value:(id)value
{
    return nil;
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    _value = value;

    return YES;
}

- (NSDictionary *)json
{
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : self.value}};
}

@end

@implementation KintoneLabelField

@end

@implementation KintoneKindOfSingleLineTextField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneLikeQueryOperatorType ||
             operatorType == KintoneNotLikeQueryOperatorType ||
             operatorType == KintoneInQueryOperatorType ||
             operatorType == KintoneNotInQueryOperatorType,
             @"invalid operator type: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSString *stringValue;
    switch (operatorType) {
        case KintoneInQueryOperatorType:
        case KintoneNotInQueryOperatorType:
            NSAssert([value isKindOfClass:[NSArray class]], @"the value must be NSArray of NSString: %@", value);
            for (id val in value) {
                NSAssert([val isKindOfClass:[NSString class]], @"the value must be NSArray of NSString: %@", value);
            }
            
            stringValue = [NSString stringWithFormat:@"(\"%@\")", [value componentsJoinedByString:@"\", \""]];
            break;
            
        default:
            NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
            stringValue = [NSString stringWithFormat:@"\"%@\"", value];
            break;
    }
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSString class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSString *_value = (NSString *)value;
    if (_value.length < self.minLength || _value.length > self.maxLength) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", _value];
        return NO;
    }

    self.value = _value;

    return YES;
}

@end

@implementation KintoneKindOfMultiLineTextField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneLikeQueryOperatorType ||
             operatorType == KintoneNotLikeQueryOperatorType,
             @"invalid operator: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
    NSString *stringValue = [NSString stringWithFormat:@"\"%@\"", value];
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSString class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSString *_value = (NSString *)value;
    if (_value.length < self.minLength || _value.length > self.maxLength) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", _value];
        return NO;
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneNumberField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneGreaterThanQueryOperatorType ||
             operatorType == KintoneLessThanQueryOperatorType ||
             operatorType == KintoneGreaterThanOrEqualQueryOperatorType ||
             operatorType == KintoneLessThanOrEqualQueryOperatorType ||
             operatorType == KintoneInQueryOperatorType ||
             operatorType == KintoneNotInQueryOperatorType,
             @"invalid operator: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSString *stringValue;
    switch (operatorType) {
        case KintoneInQueryOperatorType:
        case KintoneNotInQueryOperatorType:
            NSAssert([value isKindOfClass:[NSArray class]], @"the value must be NSArray of NSNumber: %@", value);
            for (id val in value) {
                NSAssert([val isKindOfClass:[NSNumber class]], @"the value must be NSArray of NSNumber: %@", value);
            }
            
            stringValue = [NSString stringWithFormat:@"(%@)", [value componentsJoinedByString:@", "]];
            break;
            
        default:
            NSAssert([value isKindOfClass:[NSNumber class]], @"the value must be NSNumber: %@", value);
            stringValue = [value stringValue];
            break;
    }
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSNumber class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSNumber *_value = (NSNumber *)value;
    if (_value.intValue < self.minLength || _value.intValue > self.maxLength) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", _value];
        return NO;
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneSelectableField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneInQueryOperatorType ||
             operatorType == KintoneNotInQueryOperatorType,
             @"invalid operator for selectable field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSString *stringValue;
    switch (operatorType) {
        case KintoneInQueryOperatorType:
        case KintoneNotInQueryOperatorType:
            NSAssert([value isKindOfClass:[NSArray class]], @"the value must be NSArray of NSString: %@", value);
            for (id val in value) {
                NSAssert([val isKindOfClass:[NSString class]], @"the value must be NSArray of NSString: %@", value);
            }
            
            stringValue = [NSString stringWithFormat:@"(\"%@\")", [value componentsJoinedByString:@"\", \""]];
            break;
            
        default:
            NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
            stringValue = [NSString stringWithFormat:@"\"%@\"", value];
            break;
    }

    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSString class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSString *_value = (NSString *)value;
    NSArray *_options = (NSArray *)self.options;
    if (![_options containsObject:_value]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneFileField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneLikeQueryOperatorType ||
             operatorType == KintoneNotLikeQueryOperatorType,
             @"invalid operator for file field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
    NSString *stringValue = [NSString stringWithFormat:@"\"%@\"", value];
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    NSArray *array = (NSArray *)value;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
    for (id val in array) {
        if ([val isKindOfClass:[NSDictionary class]]) {
            KintoneFile *file = [[KintoneFile alloc] initWithProperties:val];
            [mutableArray addObject:file];
        }
        else {
            [mutableArray addObject:val];
        }
    }
    
    self.value = mutableArray;
    
    return YES;
}

- (NSDictionary *)json
{
    NSArray *_value = (NSArray *)self.value;
    NSMutableArray *value = [NSMutableArray arrayWithCapacity:_value.count];
    for (KintoneFile *file in _value) {
        if (!file.deleted && ![NSString isNilOrEmpty:file.fileKey]) {
            // omit deleted / unuploaded file
            [value addObject:file.json];
        }
    }
    
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : value}};
}

- (KintoneFile *)fileWithIndex:(int)index
{
    NSArray *value = (NSArray *)self.value;
    if (index < 0 || index >= value.count) {
        return nil;
    }
    
    return [self.value objectAtIndex:index];
}

- (void)addFile:(KintoneFile *)file
{
    NSMutableArray *value = (NSMutableArray *)self.value;
    [value addObject:file];
}

- (void)deleteFile:(KintoneFile *)file
{
    file.deleted = YES;
}

- (void)deleteFileWithIndex:(int)index
{
    [self deleteFile:[self fileWithIndex:index]];
}

@end

@implementation KintoneUserField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneInQueryOperatorType ||
             operatorType == KintoneNotInQueryOperatorType,
             @"invalid operator for user field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSAssert([value isKindOfClass:[NSArray class]], @"the value must be NSArray of NSString: %@", value);
    NSArray *valueArray = (NSArray *)value;
    NSMutableArray *valuesAroundDoubleQuote = [NSMutableArray arrayWithCapacity:valueArray.count];
    for (id val in value) {
        NSAssert([val isKindOfClass:[NSString class]], @"the value must be NSArray of NSString: %@", value);

        if ([@"LOGINUSER()" isEqualToString:val]) {
            [valuesAroundDoubleQuote addObject:val];
        }
        else {
            // put double quote around if not reserved function "LOGINUSER()"
            [valuesAroundDoubleQuote addObject:[NSString stringWithFormat:@"\"%@\"", val]];
        }
    }

    NSString *stringValue = [NSString stringWithFormat:@"(%@)", [valuesAroundDoubleQuote componentsJoinedByString:@", "]];
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSArray class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSArray *_value = (NSArray *)value;
    for (id val in _value) {
        if (![val isKindOfClass:[NSDictionary class]]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
        
        if (!val[@"code"]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneKindOfDateField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneGreaterThanQueryOperatorType ||
             operatorType == KintoneLessThanQueryOperatorType ||
             operatorType == KintoneGreaterThanOrEqualQueryOperatorType ||
             operatorType == KintoneLessThanOrEqualQueryOperatorType,
             @"invalid operator for date field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, value];
}

@end

@implementation KintoneKindOfDatetimeField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate value
    NSString *stringValue;
    if ([value isKindOfClass:[NSString class]]) {
        NSAssert([@"TODAY()" isEqualToString:value] || [@"THIS_MONTH()" isEqualToString:value] || [@"THIS_YEAR()" isEqualToString:value],
                 @"the value must be NSDate, TODAY(), THIS_MONTH() or THIS_YEAR(): %@", value);
        
        stringValue = value;
    }
    else {
        NSAssert([value isKindOfClass:[NSDate class]], @"the value must be NSDate, TODAY(), THIS_MONTH() or THIS_YEAR(): %@", value);
        
        stringValue = [NSString stringWithFormat:@"\"%@\"", [NSDate rfc3339StringFromDate:value]];
    }
    
    return [super conditionQuery:operatorType value:stringValue];
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSDate class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    
    self.value = value;
    
    return YES;
}

@end

@implementation KintoneTimeField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneGreaterThanQueryOperatorType ||
             operatorType == KintoneLessThanQueryOperatorType ||
             operatorType == KintoneGreaterThanOrEqualQueryOperatorType ||
             operatorType == KintoneLessThanOrEqualQueryOperatorType,
             @"invalid operator for time field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSAssert([value isKindOfClass:[NSDate class]], @"the value must be NSDate: %@", value);
    NSString *stringValue = [NSString stringWithFormat:@"\"%@\"", [NSDate timeStringFromDate:value]];
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

- (NSDictionary *)json
{
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : [NSDate timeStringFromDate:self.value]}};
}

@end

@implementation KintoneStatusField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate operator
    NSAssert(operatorType == KintoneEqualQueryOperatorType ||
             operatorType == KintoneNotEqualQueryOperatorType ||
             operatorType == KintoneInQueryOperatorType ||
             operatorType == KintoneNotInQueryOperatorType,
             @"invalid operator for status field: %@", [KintoneQuery operatorTypeToString:operatorType]);
    
    // validate value
    NSString *stringValue;
    switch (operatorType) {
        case KintoneInQueryOperatorType:
        case KintoneNotInQueryOperatorType:
            NSAssert([value isKindOfClass:[NSArray class]], @"the value must be NSArray of NSString: %@", value);
            for (id val in value) {
                NSAssert([val isKindOfClass:[NSString class]], @"the value must be NSArray of NSString: %@", value);
            }
            
            stringValue = [NSString stringWithFormat:@"(\"%@\")", [value componentsJoinedByString:@"\", \""]];
            break;
            
        default:
            NSAssert([value isKindOfClass:[NSString class]], @"the value must be NSString: %@", value);
            stringValue = [NSString stringWithFormat:@"\"%@\"", value];
            break;
    }
    
    // create condition clause
    NSString *operator = [KintoneQuery operatorTypeToString:operatorType];
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, operator, stringValue];
}

@end

@implementation KintoneSingleLineTextField

@end

@implementation KintoneCalcField

#warning TODO: validateQueryCondition

@end

@implementation KintoneMultiLineTextField

@end

@implementation KintoneRichTextField

@end

@implementation KintoneCheckBoxField

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSArray class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSArray *_value = (NSArray *)value;
    NSArray *_options = self.options;
    for (id val in _value) {
        if (![val isKindOfClass:[NSString class]]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
        
        if (![_options containsObject:val]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneRadioButtonField

@end

@implementation KintoneDropDownField

@end

@implementation KintoneMultiSelectField

@end

@implementation KintoneDateField

- (NSString *)conditionQuery:(KintoneQueryOperatorType)operatorType value:(id)value
{
    // validate value
    NSString *stringValue;
    if ([value isKindOfClass:[NSString class]]) {
        NSAssert([@"TODAY()" isEqualToString:value] || [@"THIS_MONTH()" isEqualToString:value] || [@"THIS_YEAR()" isEqualToString:value],
                 @"the value must be NSDate, TODAY(), THIS_MONTH() or THIS_YEAR(): %@", value);
        
        stringValue = value;
    }
    else {
        NSAssert([value isKindOfClass:[NSDate class]], @"the value must be NSDate, TODAY(), THIS_MONTH() or THIS_YEAR(): %@", value);
        
        stringValue = [NSString stringWithFormat:@"\"%@\"", [NSDate dateStringFromDate:value]];
    }
    
    return [super conditionQuery:operatorType value:stringValue];
}

- (NSDictionary *)json
{
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : [NSDate dateStringFromDate:self.value]}};
}

@end

@implementation KintoneDatetimeField

- (NSDictionary *)json
{
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : [NSDate rfc3339StringFromDate:self.value]}};
}

@end

@implementation KintoneLinkField

@end

@implementation KintoneUserSelectField

@end

@implementation KintoneStatusAssigneeField

@end

@implementation KintoneLookupField

#warning TODO: validateQueryCondition

@end

@implementation KintoneReferenceTableField

#warning TODO: validateQueryCondition

@end

@implementation KintoneCategoryField

#warning TODO: validateQueryCondition

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSArray class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }
    NSArray *_value = (NSArray *)value;
    for (id val in _value) {
        if (![val isKindOfClass:[NSString class]]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
    }
    
    self.value = _value;
    
    return YES;
}

@end

@implementation KintoneRecordNumberField

#warning TODO: validateQueryCondition

@end

@implementation KintoneCreatorField

@end

@implementation KintoneCreatedTimeField

@end

@implementation KintoneModifierField

@end

@implementation KintoneUpdatedTimeField

@end

@implementation KintoneSubtableField

+ (NSArray *)recordsFromJSON:(id)JSON
{
    NSArray *subTableRecords = (NSArray *)JSON;
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:subTableRecords.count];
    for (NSDictionary *subTableRecord in subTableRecords) {
        KintoneRecord *record = [KintoneRecord kintoneRecordFromDictionary:subTableRecord[@"value"]];
        // set record number using 'id'
        KintoneField *field = [[KintoneField alloc] initWithProperties:@{@"type"  : [KintoneField fieldTypeNameForFieldType:KintoneRecordNumberFieldType],
                                                                         @"value" : subTableRecord[@"id"]}];
        [record addField:field];
        [records addObject:record];
    }

    return records;
}

- (BOOL)setValue:(id)value error:(CBError* __autoreleasing *)error
{
    // validate value
    if (![value isKindOfClass:[NSArray class]]) {
        *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
        return NO;
    }

    NSArray *array = (NSArray *)value;
    for (id val in array) {
        if (![val isKindOfClass:[KintoneRecord class]]) {
            *error = [CBError errorWithFormat:@"KintoneErrorInvalidFieldValue", value];
            return NO;
        }
    }
    
    self.value = value;
    
    return YES;
}

- (NSDictionary *)json
{
    NSArray *records = (NSArray *)self.value;
    NSMutableArray *value = [NSMutableArray arrayWithCapacity:records.count];

    for (KintoneRecord *record in records) {
        NSMutableDictionary *recordValue = [NSMutableDictionary dictionaryWithCapacity:record.fields.count];
        for (NSString *code in record.fields.keyEnumerator) {
            KintoneField *field = record.fields[code];
            [recordValue addEntriesFromDictionary:field.json];
        }
        NSMutableDictionary *tableValue = [NSMutableDictionary dictionaryWithDictionary:@{@"value": recordValue}];
        if (record.recordNumber != nil) {
            tableValue[@"id"] = record.recordNumber.value;
        }
        [value addObject:tableValue];
    }
    
    return @{self.code : @{@"type"  : [KintoneField fieldTypeNameForFieldType:self.type],
                           @"value" : value}};
}

@end