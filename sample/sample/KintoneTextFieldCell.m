//
//  KintoneTextFieldCell.m
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

#import "KintoneTextFieldCell.h"

#import "KintoneFieldUtil.h"

@implementation KintoneTextFieldCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.fieldLabel.frame = CGRectMake(CGRectGetMinX(self.fieldLabel.frame), CGRectGetMinY(self.fieldLabel.frame),
                                       CGRectGetWidth(self.superview.frame), CGRectGetHeight(self.fieldLabel.frame));
    self.fieldValue.frame = CGRectMake(CGRectGetMinX(self.fieldValue.frame), CGRectGetMinY(self.fieldValue.frame),
                                       CGRectGetWidth(self.superview.frame), CGRectGetHeight(self.fieldValue.frame));
    
    self.fieldValue.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueWithKintoneField:(KintoneField *)field form:(NSDictionary *)form
{
    self.fieldValue.text = [KintoneFieldUtil stringValue:field];
    
    KintoneField *fieldInfo = (KintoneField *)form[field.code];
    if (fieldInfo != nil) {
        // use decimal format
        if (fieldInfo.digit) {
            self.fieldValue.text = [KintoneTextFieldCell valueWithDecimalFormat:[NSNumber numberWithDouble:[self.fieldValue.text doubleValue]]];
        }
        if (fieldInfo.format) {
            if ([fieldInfo.format isEqualToString:@"NUMBER_DIGIT"]) {
                self.fieldValue.text = [KintoneTextFieldCell valueWithDecimalFormat:[NSNumber numberWithDouble:[self.fieldValue.text doubleValue]]];
            }
        }
        
        // display field label
        if (!fieldInfo.noLabel) {
            self.fieldLabel.text = fieldInfo.label;
        }
    }
    else {
        self.fieldLabel.text = nil;
    }
    
    // move field value origin to field label's one if no field label
    CGPoint fieldValuePoint = CGPointMake(CGRectGetMinX(self.fieldValue.frame), CGRectGetMinY(self.fieldLabel.frame));
    if (self.fieldLabel.text.length > 0) {
        CGSize fieldLabelSize = [self.fieldLabel.text sizeWithFont:self.fieldLabel.font
                                                 constrainedToSize:[UIScreen mainScreen].bounds.size
                                                     lineBreakMode:NSLineBreakByWordWrapping];
        fieldValuePoint = CGPointMake(CGRectGetMinX(self.fieldValue.frame), fieldValuePoint.y + fieldLabelSize.height);
    }

    // size to fit
    [self.fieldLabel sizeToFit];
    // [self.fieldValue sizeToFit] doesn't work properly.
    // the number of line is wrong if use numberFormatted fieldValue.
    CGSize fieldValueSize = [self.fieldValue.text sizeWithFont:self.fieldValue.font
                                             constrainedToSize:[UIScreen mainScreen].bounds.size
                                                 lineBreakMode:NSLineBreakByWordWrapping];
    self.fieldValue.frame = CGRectMake(fieldValuePoint.x, fieldValuePoint.y, fieldValueSize.width, fieldValueSize.height);
    [self.fieldValue sizeToFit];
}

+ (NSString *)valueWithDecimalFormat:(NSNumber *)value
{
    return [NSNumberFormatter localizedStringFromNumber:value numberStyle:NSNumberFormatterDecimalStyle];
}

- (CGFloat)height:(CGSize)maxSize
{
    CGFloat height = CGRectGetHeight(self.fieldLabel.frame) + CGRectGetHeight(self.fieldValue.frame) + 2;
    
    return (height > maxSize.height) ? maxSize.height : height;
}

@end
