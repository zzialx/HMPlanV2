//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//


/*
 
 *********************************************************************************
 *
 * 🌟🌟🌟 新建SDCycleScrollView交流QQ群：185534916 🌟🌟🌟
 *
 * 在您使用此自动轮播库的过程中如果出现bug请及时以以下任意一种方式联系我们，我们会及时修复bug并
 * 帮您解决问题。
 * 新浪微博:GSD_iOS
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios
 *
 * 另（我的自动布局库SDAutoLayout）：
 *  一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于
 *  做最简单易用的AutoLayout库。
 * 视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * 用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 * GitHub：https://github.com/gsdios/SDAutoLayout
 *********************************************************************************
 
 */


#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
    __weak UIImageView *_frontImageView;
    __weak UIView *_lineView;
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
        [self setupTitleFrontImage];
    }
    
    return self;
}

- (void)setTitleLabelAndFrontImageLineViewColor:(UIColor *)titleLabelAndFrontImageLineViewColor
{
    _titleLabelAndFrontImageLineViewColor = titleLabelAndFrontImageLineViewColor;
    _lineView.backgroundColor = titleLabelAndFrontImageLineViewColor;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
    _frontImageView.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    if (!_frontImageView || _frontImageView.hidden) {
        _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    } else {
        _titleLabel.text = title;
    }
    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}

- (void)setFrontImageName:(NSString *)imageName
{
    _frontImageName = [imageName copy];
    [_frontImageView setImage:[UIImage imageNamed:imageName]];
    if (_frontImageView.hidden) {
        _frontImageView.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.onlyDisplayText) {
        _titleLabel.frame = self.bounds;
    } else {
        _imageView.frame = self.bounds;
        CGFloat titleLabelW = self.sd_width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.sd_height - titleLabelH;
        _frontImageView.frame = CGRectMake(titleLabelX, titleLabelY, _frontImageView.image.size.width, titleLabelH);
        if (!_frontImageView.hidden && _frontImageView.image) {
            titleLabelX += _frontImageView.image.size.width;
        }
        if (self.isShowLine) {
            _lineView.frame = CGRectMake(titleLabelX, titleLabelY + 2, 1, titleLabelH - 4);
        }
        
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);

        
    }
}

- (void)setIsShowLine:(BOOL)isShowLine {
    _isShowLine = isShowLine;
    
    if (isShowLine) {
        UIView *lineView = [[UIView alloc] init];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _lineView = lineView;
        
        [self.contentView addSubview:lineView];
    }
}

- (void)setupTitleFrontImage
{
    UIImageView *frontImageView = [[UIImageView alloc] init];
    _frontImageView = frontImageView;

    [self.contentView addSubview:frontImageView];
}

@end
