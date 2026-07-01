//
//  WSSFALoginLogo.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginLogo.h"
#import "WSSFALoginGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图图标 延展(内部)
@interface WSSFALoginLogo ()

@property (nonatomic, strong) UIColor *textColor;   //文本颜色

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图图标 延展(工具)
@interface WSSFALoginLogo (Tool)

- (void)layoutLoginLogo; //布局登陆标志方法

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图图标
@implementation WSSFALoginLogo

#pragma mark - 获取logoImageView方法
- (UIImageView *)logoImageView
{
    if (_logoImageView == nil)
    {
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _logoImageView.backgroundColor = [UIColor clearColor];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _logoImageView.image = [UIImage scaledImageForName:@"appname" ofType:@"png"];
    }
    
    return _logoImageView;
}

#pragma mark - 获取appTypeLabel方法
- (UILabel *)appTypeLabel
{
    if (_appTypeLabel == nil)
    {
        _appTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _appTypeLabel.backgroundColor = [UIColor clearColor];
        _appTypeLabel.font = [UIFont systemFontOfSize:(UI_Login_Font + 10.0f)];
        _appTypeLabel.textAlignment = NSTextAlignmentCenter;
        _appTypeLabel.textColor = _textColor;
        _appTypeLabel.numberOfLines = 0;
        _appTypeLabel.text = [WSPlistHelper getApppPackageType];
    }
    
    return _appTypeLabel;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIColor *color = [UIColor colorForKey:WSLoginViewTextColorMrak];
        _textColor = (color ? color : MAIN_TINT_COLOR);
        
        [self addSubview:self.logoImageView];
        [self addSubview:self.appTypeLabel];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginLogo];
}

#pragma mark - 更新登陆图标方法
- (void)updateLoginLogo
{
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图图标 延展(工具)
@implementation WSSFALoginLogo (Tool)

#pragma mark - 布局登陆标志方法
- (void)layoutLoginLogo
{
    UIImage *logoImage = self.logoImageView.image;
    CGFloat drawMaxWidth = CGRectGetWidth(self.frame);
    
    CGFloat x = (drawMaxWidth - logoImage.size.width) / 2;
    CGFloat y = 0.0f;
    CGFloat w = logoImage.size.width;
    CGFloat h = logoImage.size.height;
    self.logoImageView.frame = CGRectMake(x, y, w, h);
    
    CGRect appTypeLabelFrame = CGRectZero;
    if(self.appTypeLabel.text.length > 0)
    {
        CGSize textSize = [self.appTypeLabel.text ws_sizeWithFont:self.appTypeLabel.font constrainedToWidth:drawMaxWidth];
        CGFloat x = (drawMaxWidth - textSize.width) / 2;
        CGFloat y = 0.0f;
        CGFloat w = textSize.width;
        CGFloat h = textSize.height;
        appTypeLabelFrame = CGRectMake(x, y, w, h);
    }
    self.appTypeLabel.frame = appTypeLabelFrame;
}

@end
//===================================================================================================================================================================
