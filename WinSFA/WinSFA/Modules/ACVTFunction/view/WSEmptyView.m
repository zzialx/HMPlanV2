//
//  WSEmptyView.m
//  WinSFA
//
//  Created by yuanji on 18/1/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEmptyView.h"
//==========================================================================================================================================================

#pragma mark - 空视图 延展(内部)
@interface WSEmptyView ()

@property (nonatomic, strong) UIImageView *iconImageView;   //图标视图
@property (nonatomic, strong) UILabel *label;               //标签
@property (nonatomic, strong) UIImage *defaultImage;        //默认图片
@property (nonatomic, strong) NSString *defaultText;        //默认文本

@end
//==========================================================================================================================================================

#pragma mark - 空视图 延展(工具)
@interface WSEmptyView (Tools)

#pragma mark - 设置内容方法 funcsBean:功能块
- (void)setupContent:(WSFuncsBean *)funcsBean;

#pragma mark - 设置布局方法
- (void)setupLayout;

@end
//==========================================================================================================================================================

#pragma mark - 空视图
@implementation WSEmptyView

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
    if(_label == nil)
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

#pragma mark - 重写initWithFrame:方法
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andFuncsBean:nil];
}

#pragma mark - 自定义初始化方法 frame:边框 funcsBean:功能块
- (instancetype)initWithFrame:(CGRect)frame andFuncsBean:(WSFuncsBean *)funcsBean
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _defaultImage = [UIImage scaledImageForName:@"empty" ofType:@"png"];
        _defaultText = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Not data available", nil)];
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.label];
        [self setupContent:funcsBean];
    }
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupLayout];
}

#pragma mark - 自定义更新方法 funcsBean:功能块
- (void)updateFromFuncsBean:(WSFuncsBean *)funcsBean
{
    [self setupContent:funcsBean];
    [self setNeedsLayout];
}

@end
//==========================================================================================================================================================

#pragma mark - 空视图 延展(工具)
@implementation WSEmptyView (Tools)

#pragma mark - 设置内容方法 funcsBean:功能块
- (void)setupContent:(WSFuncsBean *)funcsBean
{
    NSString *urlStr = [WSHttpURLHelper getImageCompleteURL:funcsBean.defaultImageUrl];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:self.defaultImage];
    self.label.text = (funcsBean.defaultString.length > 0) ? funcsBean.defaultString : self.defaultText;
}

#pragma mark - 设置布局方法
- (void)setupLayout
{
    CGFloat space = 8.0f;
    CGFloat textDrawWidth = CGRectGetWidth(self.frame) - (space * 2);
    
    UIImage *image = self.defaultImage;
    NSString *text = self.label.text;
    CGSize textSize = [text ws_sizeWithFont:self.label.font constrainedToWidth:textDrawWidth];
    CGFloat elementheight = image.size.height + space + textSize.height;
    
    CGFloat x = (CGRectGetWidth(self.frame) - image.size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.frame) - elementheight) / 2;
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    self.iconImageView.frame = CGRectMake(x, y, w, h);
    
    x = (CGRectGetWidth(self.frame) - textSize.width) / 2;
    y = CGRectGetMaxY(self.iconImageView.frame) + space;
    w = textSize.width;
    h = textSize.height;
    self.label.frame = CGRectMake(x, y, w, h);
}

@end
//==========================================================================================================================================================
