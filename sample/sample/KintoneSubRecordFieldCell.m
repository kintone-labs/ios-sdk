//
//  KintoneSubRecordFieldCell.m
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

#import "KintoneSubRecordFieldCell.h"

#import "KintoneFieldCell.h"
#import "KintoneFileFieldCell.h"
#import "KintoneTextFieldCell.h"

@interface KintoneSubRecordFieldCell ()

@property (nonatomic) UITableView *subRecordTableView;

@end

@implementation KintoneSubRecordFieldCell

static NSString * const KINTONE_SUBRECORDTABLE_FIELD_CELL = @"KintoneSubRecordTableFieldCell";
static NSString * const KINTONE_SUBRECORDTABLE_FILE_FIELD_CELL = @"KintoneSubRecordTableFileFieldCell";
static NSString * const KINTONE_SUBRECORDTABLE_TEXT_FIELD_CELL = @"KintoneSubRecordTableTextFieldCell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.subRecordTableView = [[UITableView alloc] initWithFrame:self.contentView.frame style:UITableViewStyleGrouped];
        self.subRecordTableView.delegate = self;
        self.subRecordTableView.dataSource = self;
        self.subRecordTableView.scrollEnabled = NO;
        self.subRecordTableView.backgroundView = nil;
        self.subRecordTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.subRecordTableView];
        
        [self.subRecordTableView registerClass:[KintoneFieldCell class] forCellReuseIdentifier:KINTONE_SUBRECORDTABLE_FIELD_CELL];
        [self.subRecordTableView registerClass:[KintoneFileFieldCell class] forCellReuseIdentifier:KINTONE_SUBRECORDTABLE_FILE_FIELD_CELL];
        [self.subRecordTableView registerNib:[UINib nibWithNibName:@"KintoneTextFieldCell" bundle:nil] forCellReuseIdentifier:KINTONE_SUBRECORDTABLE_TEXT_FIELD_CELL];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subRecordFields.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KintoneField *field = self.subRecordFields[indexPath.row];
    
    NSString *cellIdentifier;
    switch (field.type) {
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
            cellIdentifier = KINTONE_SUBRECORDTABLE_TEXT_FIELD_CELL;
            break;
        case KintoneFileFieldType:
            cellIdentifier = KINTONE_SUBRECORDTABLE_FILE_FIELD_CELL;
            break;
            
        default:
            cellIdentifier = KINTONE_SUBRECORDTABLE_FIELD_CELL;
            break;
    }
    KintoneFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValueWithKintoneField:field form:nil];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KintoneFieldCell *cell = (KintoneFieldCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return [cell height:tableView.frame.size];
}

- (CGFloat)height:(CGSize)maxSize
{
    CGFloat height = 22;
    for (int i = 0; i < [self tableView:self.subRecordTableView numberOfRowsInSection:1]; i++) {
        KintoneFieldCell *cell = (KintoneFieldCell *)[self tableView:self.subRecordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        height += [cell height:maxSize];
    }
    
    return height;
}

@end
