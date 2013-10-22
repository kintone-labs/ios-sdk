//
//  KintoneFileFieldCell.m
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

#import "KintoneFileFieldCell.h"

#import "KintoneAppDelegate.h"

@interface KintoneFileFieldCell ()

@property (nonatomic) KintoneAppDelegate *appDelegate;

@end

@implementation KintoneFileFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
    }
    return self;
}

- (KintoneAppDelegate *)appDelegate
{
    if (_appDelegate == nil) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
    }
    
    return _appDelegate;
}

+ (NSCache *)sharedImageCache
{
    static NSCache *sharedImageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [NSCache new];
    });
    
    return sharedImageCache;
}

- (void)setValueWithKintoneField:(KintoneField *)field form:(NSDictionary *)form
{
    CGFloat contentViewHeight = 0;
    
    KintoneField *fieldInfo = (KintoneField *)form[field.code];
    if (fieldInfo != nil && !fieldInfo.noLabel) {
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        label.text = fieldInfo.label;
        [self.contentView addSubview:label];

        // resize and add mergin
        [label sizeToFit];
        label.frame = CGRectMake(10, 2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame) + 2);
        contentViewHeight += CGRectGetHeight(label.frame);
    }
    
    for (KintoneFile *file in field.value) {
        if ([KintoneFileFieldCell isSupportedImage:file.contentType]) {
            // image file
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"fileFieldCellDefault" ofType:@"png"];
            UIImageView *imageView = [self imageView:file placeholderImage:[UIImage imageWithContentsOfFile:imagePath]];
            [self.contentView addSubview:imageView];
            imageView.frame = CGRectMake(10, contentViewHeight, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame) + 2);
            contentViewHeight += CGRectGetHeight(imageView.frame);
        }
        else {
            // not image file
            UILabel *fileInfoLabel = [KintoneFileFieldCell fileInfoLabel:file];
            [self.contentView addSubview:fileInfoLabel];
            fileInfoLabel.frame = CGRectMake(10, contentViewHeight, CGRectGetWidth(fileInfoLabel.frame), CGRectGetHeight(fileInfoLabel.frame) + 2);
            contentViewHeight += CGRectGetHeight(fileInfoLabel.frame);
        }
    }
    
    // resize content view
    self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame),
                                        CGRectGetWidth(self.contentView.frame), contentViewHeight);
}

- (CGFloat)height:(CGSize)maxSize
{
    return self.contentView.frame.size.height;
}

+ (BOOL)isSupportedImage:(NSString *)contentType
{
    NSSet *supportedImageFormats = [NSSet setWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon" @"image/x-xbitmap", @"image/x-win-bitmap", nil];
    
    return [supportedImageFormats containsObject:contentType];
}

- (void)fetchImage:(KintoneFile *)file imageView:(UIImageView *)imageView
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = imageView.center;
    [imageView addSubview:indicator];
    [indicator startAnimating];
    
    NSOutputStream *output = [NSOutputStream outputStreamToMemory];
    
    CBNetworkingSuccessBlockForHTTPResponse success = ^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
        UIImage *image = [UIImage imageWithData:[output propertyForKey:NSStreamDataWrittenToMemoryStreamKey]];
        imageView.image = [KintoneFileFieldCell thumnailImage:image];
        [[KintoneFileFieldCell sharedImageCache] setObject:image forKey:file.fileKey];
        
        [indicator stopAnimating];
    };
    CBNetworkingFailureBlockForHTTPResponse failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, CBError *error) {
        [indicator stopAnimating];
    };

    [self.appDelegate.kintoneApplication.kintoneAPI fileDownload:file.fileKey
                                                         success:success
                                                         failure:failure
                                                        download:nil
                                                          output:output
                                                           queue:[CBOperationQueue sharedConcurrentQueue]];
}

- (UIImageView *)imageView:(KintoneFile *)file placeholderImage:(UIImage *)placeholderImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    UIImage *image = [[KintoneFileFieldCell sharedImageCache] objectForKey:file.fileKey];
    if (image) {
        imageView.image = image;
    }
    else {
        imageView.image = placeholderImage;
        [self fetchImage:file imageView:imageView];
    }
    
    return imageView;
}

+ (UIImage *)thumnailImage:(UIImage *)image
{
    CGSize thumnailSize = CGSizeMake(150, 150);
    UIGraphicsBeginImageContext(thumnailSize);
    [image drawInRect:CGRectMake(0, 0, thumnailSize.width, thumnailSize.height)];
    UIImage *thumnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumnailImage;
}

+ (UILabel *)fileInfoLabel:(KintoneFile *)file
{
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:18];
    label.text = [NSString stringWithFormat:@"%@ (%d bytes)", file.name, file.size];
    [label sizeToFit];
    
    return label;
}

@end
