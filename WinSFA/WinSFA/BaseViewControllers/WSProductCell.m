//
//  WSProductCell.m
//  WinSFA
//
//  Created by yang on 16/1/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSProductCell.h"

#define kDefautHeight 50.0f
#define kTopSpace 10.0f
#define kLeftSpace (INTERFACE_IS_PHONE ? 10.0f : 20.0f)
#define kSelectImageViewWidth 19.0f
#define kViewGap (INTERFACE_IS_PHONE ? 10.0f : 20.0f)
#define kSelectImage [UIImage imageNamed:@"icn_check"]
#define kUnSelectImage [UIImage imageNamed:@"icn_nocheck"]
#define kLabelFont [UIFont systemFontOfSize:UI_Font]


@interface WSProductCell ()

@property (nonatomic, strong) UIImageView *selectImageView;

@property (nonatomic, strong)  UILabel *nameLabel;

@end

@implementation WSProductCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.isNeedSelect = YES;
        
        UIImageView *selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftSpace, (self.height - kSelectImageViewWidth)/2, kSelectImageViewWidth, kSelectImageViewWidth)];
        selectImageView.image = kUnSelectImage;
        selectImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.selectImageView = selectImageView;
        [self.contentView addSubview:self.selectImageView];
        
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(selectImageView.right + kViewGap, 0, self.width - (selectImageView.right + kViewGap), self.height)];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = kLabelFont;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _nameLabel = nameLabel;
        [self.contentView addSubview:self.nameLabel];
        
        return self;
    }
    
    return nil;
}

- (void)setContent:(NSString *)content isSelect:(BOOL) isSelect
{
    self.isCellSelected = isSelect;
    
    CGFloat labelOrigin;
    if (self.isNeedSelect) {
        self.selectImageView.hidden = NO;
        labelOrigin = self.selectImageView.right + kViewGap;
    }else {
        self.selectImageView.hidden = YES;
        labelOrigin = kLeftSpace;
    }
    
    CGFloat contentWidth = self.width - labelOrigin - kLeftSpace;
    
    CGSize size = [content ws_sizeWithFont:kLabelFont constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    self.nameLabel.frame = CGRectMake(labelOrigin, (self.height - size.height)/2, contentWidth, size.height);
    
    self.nameLabel.text = content;
    
    if (self.isNeedSelect) {
        if (isSelect) {
            self.selectImageView.image = kSelectImage;
        }else {
            self.selectImageView.image = kUnSelectImage;
        }
    }
}

+ (CGFloat)heightForRowWithContent:(NSString *)content tableWidth:(CGFloat)tableWidth isNeedSelect:(BOOL)isNeedSelect
{
    CGFloat height = kDefautHeight;
    if ([content length] > 0) {
        CGFloat labelOrigin;
        if (isNeedSelect) {
            labelOrigin = kLeftSpace + kSelectImageViewWidth + kViewGap;
        }else {
            labelOrigin = kLeftSpace;
        }
        
        CGFloat contentWidth = tableWidth - labelOrigin - kLeftSpace;
        
        CGSize size = [content ws_sizeWithFont:kLabelFont constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByCharWrapping];
        
        if ((size.height + kTopSpace * 2) > height) {
            height = size.height + kTopSpace * 2;
        }
    }
    
    return height;
}

@end
