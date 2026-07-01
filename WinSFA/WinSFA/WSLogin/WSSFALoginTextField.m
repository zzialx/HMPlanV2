//
//  WSSFALoginTextField.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginTextField.h"
#import "WSSFALoginGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图文本框 延展(内部)
@interface WSSFALoginTextField ()

@property (nonatomic, strong) UIColor *textFieldTextColor;  //输入框文本颜色
@property (nonatomic, strong) UIColor *textFieldLineColor;  //输入框线颜色

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图文本框 延展(工具)
@interface WSSFALoginTextField (Tool)

- (void)layoutLoginTextField; //布局登陆文本框方法

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图文本框
@implementation WSSFALoginTextField

#pragma mark - 获取iconImageView方法
- (UIImageView *)iconImageView
{
    if (_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.backgroundColor = [UIColor clearColor];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconImageView;
}

#pragma mark - 获取textField方法
- (UITextField *)textField
{
    if (_textField == nil)
    {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = _textFieldTextColor;
        _textField.font = [UIFont systemFontOfSize:UI_Login_Font];
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    
    return _textField;
}

#pragma mark - 获取borderLineView方法
- (UIView *)borderLineView
{
    if (_borderLineView == nil)
    {
        _borderLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _borderLineView.backgroundColor = _textFieldLineColor;
    }
    
    return _borderLineView;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _elementSpace = kLoginViewStandardElementSpace;
        _lineHeight = kLoginViewStandardLineHeight;
        
        UIColor *color = [UIColor colorForKey:WSLoginViewInteractiveRegionInputElementTextColorMrak];
        _textFieldTextColor = (color ? color : MAIN_TINT_COLOR);
        
        color = [UIColor colorForKey:WSLoginViewInteractiveRegionInputElementLineColorMark];
        _textFieldLineColor = (color ? color : MAIN_TINT_COLOR);
        
        [self addSubview:self.iconImageView];
        [self addSubview:self.textField];
        [self addSubview:self.borderLineView];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginTextField];
}

#pragma mark - 更新登陆文本框方法
- (void)updateLoginTextField
{
    [self setNeedsLayout];
}

#pragma mark - 关闭输入框方法
- (void)closecTextField
{
    if ([self.textField respondsToSelector:@selector(resignFirstResponder)])
        [self.textField resignFirstResponder];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图文本框 延展(工具)
@implementation WSSFALoginTextField (Tool)

#pragma mark - 布局登陆文本框方法
- (void)layoutLoginTextField
{
    if(CGRectGetWidth(self.frame) <= 0.0f || CGRectGetHeight(self.frame) <= 0.0f)
    {
        self.iconImageView.frame = CGRectZero;
        self.textField.frame = CGRectZero;
        self.borderLineView.frame = CGRectZero;
        return;
    }
        
    CGFloat maxDrawWidth = CGRectGetWidth(self.frame);
    CGFloat maxDrawHeight = CGRectGetHeight(self.frame) - self.lineHeight;
    
    UIImage *iconImage = self.iconImageView.image;
    CGFloat x = 0.0f;
    CGFloat y = (maxDrawHeight - iconImage.size.height) / 2;
    CGFloat w = iconImage.size.width;
    CGFloat h = iconImage.size.height;
    self.iconImageView.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(self.iconImageView.frame) + self.elementSpace;
    y = 0.0f;
    w = maxDrawWidth - x;
    h = maxDrawHeight;
    self.textField.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = maxDrawHeight;
    w = CGRectGetWidth(self.frame);
    h = self.lineHeight;
    self.borderLineView.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================

