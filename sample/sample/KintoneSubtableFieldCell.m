//
//  KintoneSubtableFieldCell.m
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

#import "KintoneSubtableFieldCell.h"

#import "KintoneSubRecordFieldCell.h"

@interface KintoneSubtableFieldCell ()

@property (nonatomic) UITableView *subTableView;
@property (nonatomic, copy) NSArray *subRecords;

@end

@implementation KintoneSubtableFieldCell

static NSString * const KINTONE_SUBRECORD_FIELD_CELL = @"KintoneSubRecordFieldCell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.subTableView = [[UITableView alloc] initWithFrame:self.contentView.frame style:UITableViewStyleGrouped];
        self.subTableView.delegate = self;
        self.subTableView.dataSource = self;
        self.subTableView.scrollEnabled = NO;
        self.subTableView.backgroundView = nil;
        [self.contentView addSubview:self.subTableView];
        self.subTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [self.subTableView registerClass:[KintoneSubRecordFieldCell class] forCellReuseIdentifier:KINTONE_SUBRECORD_FIELD_CELL];
    }
    return self;
}

- (void)setValueWithKintoneField:(KintoneField *)field form:(NSDictionary *)form
{
    self.subRecords = field.value;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subRecords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KintoneSubRecordFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:KINTONE_SUBRECORD_FIELD_CELL];
    cell.subRecordFields = ((KintoneRecord *)self.subRecords[indexPath.row]).fields.allValues;
    
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
    for (int i = 0; i < [self tableView:self.subTableView numberOfRowsInSection:1]; i++) {
        KintoneFieldCell *cell = (KintoneFieldCell *)[self tableView:self.subTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        height += [cell height:maxSize];
    }
    
    return height;
}

@end
