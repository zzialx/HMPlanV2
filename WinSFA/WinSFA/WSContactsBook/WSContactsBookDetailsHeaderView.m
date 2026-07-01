//
//  WSContactsBookDetailsHeaderView.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookDetailsHeaderView.h"
#import "WSContactsBookGlobalDefinitions.h"
#import "WSContactsBookTools.h"
//===================================================================================================================================================================

#pragma mark - 通讯录详情头视图 延展(内部)
@interface WSContactsBookDetailsHeaderView ()

@property (nonatomic, strong) UIImageView *bgImageView;     //背景视图
@property (nonatomic, strong) UIImageView *iconImageView;   //头像视图
@property (nonatomic, strong) UILabel *nameLabel;           //姓名标签
@property (nonatomic, strong) UILabel *jobTitleLabel;       //职称标签

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情头视图 延展(工具)
@interface WSContactsBookDetailsHeaderView (Tools)

#pragma mark - 布局头视图方法
- (void)layoutHeaderView;

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情头视图
@implementation WSContactsBookDetailsHeaderView

#pragma mark - 获取bgImageView方法
- (UIImageView *)bgImageView
{
    if(_bgImageView == nil)
    {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.backgroundColor = [UIColor clearColor];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImageView;
}

#pragma mark - 获取iconImageView方法
- (UIImageView *)iconImageView
{
    if(_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.clipsToBounds = YES;
    }
    return _iconImageView;
}

#pragma mark - 获取nameLabel方法
- (UILabel *)nameLabel
{
    if (_nameLabel == nil)
    {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:kContactsBookMainTitleSize_big];
        _nameLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleWhiteColor];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _nameLabel;
}

#pragma mark - 获取jobTitleLabel方法
- (UILabel *)jobTitleLabel
{
    if (_jobTitleLabel == nil)
    {
        _jobTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _jobTitleLabel.backgroundColor = [UIColor clearColor];
        _jobTitleLabel.textAlignment = NSTextAlignmentLeft;
        _jobTitleLabel.font = [UIFont systemFontOfSize:kContactsBookAuxiliaryTitleSize_big];
        _jobTitleLabel.textColor = [[WSContactsBookTools sharedManager] getContactsBookTitleWhiteColor];
        _jobTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _jobTitleLabel;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addSubview:self.bgImageView];
        [self addSubview:self.iconImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.jobTitleLabel];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutHeaderView];
}

#pragma mark - 更新视图方法 bgImage:背景视图 name:姓名 jobTitle:职称 iconUrl:头像url
- (void)updateViewWithBgImage:(UIImage *)bgImage name:(NSString *)name jobTitle:(NSString *)jobTitle iconUrl:(NSString *)iconUrl
{
    self.bgImageView.image = bgImage;
    NSString *urlStr = [[WSContactsBookTools sharedManager] getEffectiveDownloadURL:iconUrl];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage scaledImageForName:@"headportrait_normal" ofType:@"png"]];
    self.nameLabel.text = name;
    self.jobTitleLabel.text = jobTitle;
    
    [self setNeedsLayout];
}

#pragma mark - 获取高度方法 bgImage:背景视图 maxWidth:最大宽度
- (CGFloat)getHeightWithBgImage:(UIImage *)bgImage maxWidth:(CGFloat)maxWidth
{
    if(bgImage.size.width <= 0.0f || bgImage.size.height <= 0.0f || maxWidth <= 0.0f)
        return 0.0f;
    
    return (maxWidth * bgImage.size.height / bgImage.size.width);
}

@end
//===================================================================================================================================================================

#pragma mark - 通讯录详情头视图 延展(工具)
@implementation WSContactsBookDetailsHeaderView (Tools)

#pragma mark - 布局头视图方法
- (void)layoutHeaderView
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.bgImageView.frame = CGRectMake(x, y, w, h);
    
    x = kContactsBookSpace_big;
    y = CGRectGetHeight(self.frame) - kContactsBookDetailsIconBottomSpace - kContactsBookIconSize_big;
    w = kContactsBookIconSize_big;
    h = kContactsBookIconSize_big;
    self.iconImageView.frame = CGRectMake(x, y, w, h);
    self.iconImageView.layer.cornerRadius = kContactsBookIconSize_big / 2;
    
    CGFloat maxDrawHeight = kContactsBookIconSize_big;
    CGSize mainTitleSize = CGSizeMake(0.0f, 0.0f);
    CGSize auxiliaryTitleSize = CGSizeMake(0.0f, 0.0f);
    CGFloat textDrawHeight = 0.0f;
    if(self.nameLabel.text.length > 0)
    {
        mainTitleSize = [self.nameLabel.text ws_sizeWithFont:self.nameLabel.font constrainedToWidth:2000.0f];
        textDrawHeight = mainTitleSize.height;
    }
    if(self.jobTitleLabel.text.length > 0)
    {
        auxiliaryTitleSize = [self.jobTitleLabel.text ws_sizeWithFont:self.jobTitleLabel.font constrainedToWidth:2000.0f];
        textDrawHeight += ((textDrawHeight > 0) ? (kContactsBookSpace_small + auxiliaryTitleSize.height) : auxiliaryTitleSize.height);
    }
    
    x = CGRectGetMaxX(self.iconImageView.frame) + kContactsBookSpace_big;
    y = (maxDrawHeight - textDrawHeight) / 2 + CGRectGetMinY(self.iconImageView.frame);
    w = CGRectGetWidth(self.frame) - x - kContactsBookSpace_big;
    h = mainTitleSize.height;
    self.nameLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.iconImageView.frame) + kContactsBookSpace_big;
    CGFloat tempY = (maxDrawHeight - textDrawHeight) / 2 + CGRectGetMinY(self.iconImageView.frame);
    y = (CGRectGetHeight(self.nameLabel.frame) > 0) ? (CGRectGetMaxY(self.nameLabel.frame) + kContactsBookSpace_small) : tempY;
    w = CGRectGetWidth(self.frame) - x - kContactsBookSpace_big;
    h = auxiliaryTitleSize.height;
    self.jobTitleLabel.frame = CGRectMake(x, y, w, h);
}


@end
//===================================================================================================================================================================
