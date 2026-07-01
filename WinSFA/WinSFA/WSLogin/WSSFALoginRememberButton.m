//
//  WSSFALoginRememberButton.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginRememberButton.h"
#import "WSSFALoginGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图记住按键 延展(内部)
@interface WSSFALoginRememberButton ()

@property (nonatomic, strong) UIColor *buttonTextColor;  //按键文本颜色

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图记住按键 延展(工具)
@interface WSSFALoginRememberButton (Tool)

- (void)layoutLoginRememberButton; //布局登陆记住按键方法

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图记住按键
@implementation WSSFALoginRememberButton

#pragma mark - 获取iconButton方法
- (UIButton *)iconButton
{
    if (_iconButton == nil)
    {
        _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconButton.backgroundColor = [UIColor clearColor];
        [_iconButton setImage:[UIImage scaledImageForName:@"remeber_pwd_unselected" ofType:@"png"] forState:UIControlStateNormal];
        [_iconButton setImage:[UIImage scaledImageForName:@"remeber_pwd_selected" ofType:@"png"] forState:UIControlStateSelected];
    }
    
    return _iconButton;
}

#pragma mark - 获取titleButton方法
- (UIButton *)titleButton
{
    if (_titleButton == nil)
    {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.backgroundColor = [UIColor clearColor];
        [_titleButton setTitleColor:_buttonTextColor forState:UIControlStateNormal];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        _titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_titleButton setTitle:NSLocalizedString(@"remember_my_info_label", nil) forState:UIControlStateNormal];
    }
    
    return _titleButton;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _elementSpace = kLoginViewStandardElementSpace;
        
        UIColor *color = [UIColor colorForKey:WSLoginViewTextColorMrak];
        _buttonTextColor = (color ? color : MAIN_TINT_COLOR);
        
        [self addSubview:self.iconButton];
        [self addSubview:self.titleButton];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginRememberButton];
}

#pragma mark - 更新登陆记住按键方法
- (void)updateLoginRememberButton
{
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图记住按键 延展(工具)
@implementation WSSFALoginRememberButton (Tool)

#pragma mark - 布局登陆记住按键方法
- (void)layoutLoginRememberButton
{
    if(CGRectGetWidth(self.frame) <= 0.0f || CGRectGetHeight(self.frame) <= 0.0f)
    {
        self.iconButton.frame = CGRectZero;
        self.titleButton.frame = CGRectZero;
        return;
    }
    
    UIImage *iconImage = self.iconButton.currentImage;
    CGFloat x = 0.0f;
    CGFloat y = (CGRectGetHeight(self.frame) - iconImage.size.height) / 2;
    CGFloat w = iconImage.size.width;
    CGFloat h = iconImage.size.height;
    self.iconButton.frame = CGRectMake(x, y, w, h);
    
    CGFloat drawMaxWidth = CGRectGetWidth(self.frame) - CGRectGetMaxX(self.iconButton.frame) - self.elementSpace;
    CGSize textSize = [self.titleButton.titleLabel.text ws_sizeWithFont:self.titleButton.titleLabel.font constrainedToWidth:drawMaxWidth];
    x = CGRectGetMaxX(self.iconButton.frame) + self.elementSpace;
    y = (CGRectGetHeight(self.frame) - textSize.height) / 2;
    w = textSize.width;
    h = textSize.height;
    self.titleButton.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
