//
//  WSEmptyViewCell.m
//  WinSFA
//
//  Created by yuanji on 2018/1/20.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSEmptyViewCell.h"
//==========================================================================================================================================================

#pragma mark - 空视图单元格
@implementation WSEmptyViewCell

#pragma mark - 获取iconImageView方法
- (UIImageView *)iconImageView
{
    if(_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconImageView;
}

#pragma mark - 获取label方法
- (UILabel *)label
{
    if (_label == nil)
    {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:15.0f];
        _label.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
    }
    
    return _label;
}

#pragma mark - 重写initWithStyle:reuseIdentifier:方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.label];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat space = 8.0f;
    CGFloat textDrawWidth = CGRectGetWidth(self.contentView.frame) - (space * 2);
    
    UIImage *image = [UIImage scaledImageForName:@"empty" ofType:@"png"];
    NSString *text = self.label.text;
    
    CGSize textSize = [text ws_sizeWithFont:self.label.font constrainedToWidth:textDrawWidth];
    CGFloat elementheight = image.size.height + space + textSize.height;
    
    CGFloat x = (CGRectGetWidth(self.contentView.frame) - image.size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.contentView.frame) - elementheight) / 2;
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    self.iconImageView.frame = CGRectMake(x, y, w, h);
    
    x = (CGRectGetWidth(self.frame) - textSize.width) / 2;
    y = CGRectGetMaxY(self.iconImageView.frame) + space;
    w = textSize.width;
    h = textSize.height;
    self.label.frame = CGRectMake(x, y, w, h);
}

#pragma mark - 设置空视图单元格 funcsBean:功能块
- (void)setupEmptyViewCellFromFuncsBean:(WSFuncsBean *)funcsBean
{
    UIImage *defaultImage = [UIImage scaledImageForName:@"empty" ofType:@"png"];
    NSString *defaultText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Not data available", nil)];
    
    NSString *urlStr = [WSHttpURLHelper getImageCompleteURL:funcsBean.defaultImageUrl];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:defaultImage];
    self.label.text = (funcsBean.defaultString.length > 0) ? funcsBean.defaultString : defaultText;;
}

@end
//==========================================================================================================================================================
