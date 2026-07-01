//
//  WSSFALoginInputView.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginInputView.h"
#import "WSSFALoginTextField.h"
#import "WSSFALoginRememberButton.h"
#import "JFTakeCountButton.h"
#import "WSSFALoginGlobalDefinitions.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图 延展()
@interface WSSFALoginInputView ()

@property (nonatomic, strong) UIColor *textFieldBgColor;        //输入框背景颜色
@property (nonatomic, strong) UIColor *loginButtonBgColor;      //登录按键背景颜色
@property (nonatomic, strong) UIColor *loginButtonTitltColor;   //登录按键文本颜色
@property (nonatomic, strong) UIColor *loginWarningTitltColor;  //登录警告文本颜色
@property (nonatomic, strong) UIColor *textColor;               //文本颜色

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图 延展(工具)
@interface WSSFALoginInputView (Tool)

- (CGFloat)getRememberHeightWithWidth:(CGFloat)width;   //获取指定宽度内记住元素高度方法 width:指定宽度
- (CGFloat)getWarningTextHeightWithWidth:(CGFloat)width;//获取指定宽度内警告元素高度方法 width:指定宽度
- (CGFloat)getAboutHeightWithWidth:(CGFloat)width;      //获取指定宽度内关于高度方法 width:指定宽度
- (void)layoutLoginInputView;                           //布局登陆输入视图方法

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图
@implementation WSSFALoginInputView

#pragma mark - 获取bgView方法
- (UIView *)bgView
{
    if(_bgView == nil)
    {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = _textFieldBgColor;
        _bgView.alpha = kLoginViewStandardAlpha;
        _bgView.layer.cornerRadius = kLoginViewStandardCornerRadius;
        _bgView.layer.masksToBounds = YES;
        _bgView.clipsToBounds = YES;
    }
    
    return _bgView;
}

#pragma mark - 获取nameTextField方法
- (WSSFALoginTextField *)nameTextField
{
    if(_nameTextField == nil)
    {
        _nameTextField = [[WSSFALoginTextField alloc] initWithFrame:CGRectZero];
        _nameTextField.backgroundColor = [UIColor clearColor];
        _nameTextField.iconImageView.image = [UIImage scaledImageForName:@"usernameIcon" ofType:@"png"];
        _nameTextField.textField.placeholder = NSLocalizedString(@"user_name_edit_hint", nil);
        _nameTextField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return _nameTextField;
}

#pragma mark - 获取passwdTextField方法
- (WSSFALoginTextField *)passwdTextField
{
    if(_passwdTextField == nil)
    {
        _passwdTextField = [[WSSFALoginTextField alloc] initWithFrame:CGRectZero];
        _passwdTextField.backgroundColor = [UIColor clearColor];
        _passwdTextField.iconImageView.image = [UIImage scaledImageForName:@"passwordIcon" ofType:@"png"];
        _passwdTextField.textField.placeholder = NSLocalizedString(@"password_edit_hint", nil);
        _passwdTextField.textField.secureTextEntry = YES;
        _passwdTextField.textField.clearsOnBeginEditing = NO;
        _passwdTextField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return _passwdTextField;
}

#pragma mark - 获取orgCodeTextField方法
- (WSSFALoginTextField *)orgCodeTextField
{
    if(_orgCodeTextField == nil)
    {
        _orgCodeTextField = [[WSSFALoginTextField alloc] initWithFrame:CGRectZero];
        _orgCodeTextField.backgroundColor = [UIColor clearColor];
        _orgCodeTextField.iconImageView.image = [UIImage scaledImageForName:@"organizationIcon" ofType:@"png"];
        _orgCodeTextField.textField.placeholder = NSLocalizedString(@"org_code", nil);
        _orgCodeTextField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return _orgCodeTextField;
}

#pragma mark - 获取rememberButton方法
- (WSSFALoginRememberButton *)rememberButton
{
    if(_rememberButton == nil)
    {
        _rememberButton = [[WSSFALoginRememberButton alloc] initWithFrame:CGRectZero];
        _rememberButton.backgroundColor = [UIColor clearColor];
    }
    
    return _rememberButton;
}

#pragma mark - 获取loginButton方法
- (JFTakeCountButton *)loginButton
{
    if (_loginButton == nil)
    {
        UIImage *btnImg = [UIImage createImageWithColor:_loginButtonBgColor];
        UIImage *btnPressImg = [UIImage createImageWithColor:[_loginButtonBgColor colorWithAlphaComponent:kLoginViewStandardAlpha]];
        
        _loginButton = [JFTakeCountButton buttonWithType:UIButtonTypeCustom];
        _loginButton.backgroundColor = [UIColor clearColor];
        [_loginButton.titleLabel setFont:[UIFont systemFontOfSize:(UI_Login_Font + 5.0f)]];
        [_loginButton setBackgroundImage:btnImg forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:btnImg forState:UIControlStateDisabled];
        [_loginButton setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
        [_loginButton setTitleColor:_loginButtonTitltColor forState:UIControlStateNormal];
        [_loginButton setTitleColor:[_loginButtonTitltColor colorWithAlphaComponent:kLoginViewStandardAlpha] forState:UIControlStateDisabled];
        [_loginButton setTitle:NSLocalizedString(@"login_label", nil) forState:UIControlStateNormal];
        _loginButton.layer.masksToBounds = YES;
        _loginButton.layer.cornerRadius = kLoginViewStandardCornerRadius;
    }
    
    return _loginButton;
}

#pragma mark - 获取warningLabel方法
- (UILabel *)warningLabel
{
    if (_warningLabel == nil)
    {
        _warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _warningLabel.backgroundColor = [UIColor clearColor];
        _warningLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        _warningLabel.textAlignment = NSTextAlignmentLeft;
        _warningLabel.textColor = _loginWarningTitltColor;
        _warningLabel.numberOfLines = 0;
        _warningLabel.text = NSLocalizedString(@"login_warning", nil);
    }
    
    return _warningLabel;
}

#pragma mark - 获取retrieveButton方法
- (UIButton *)retrieveButton
{
    if (_retrieveButton == nil)
    {
        _retrieveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retrieveButton.backgroundColor = [UIColor clearColor];
        _retrieveButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        [_retrieveButton setTitle:NSLocalizedString(@"password_retake", nil) forState:UIControlStateNormal];
        [_retrieveButton setTitleColor:_textColor forState:UIControlStateNormal];
        _retrieveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    return _retrieveButton;
}

#pragma mark - 获取aboutButton方法
- (UIButton *)aboutButton
{
    if (_aboutButton == nil)
    {
        _aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _aboutButton.backgroundColor = [UIColor clearColor];
        _aboutButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
        [_aboutButton setTitle:NSLocalizedString(@"about", nil) forState:UIControlStateNormal];
        [_aboutButton setTitleColor:_textColor forState:UIControlStateNormal];
        _aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    return _aboutButton;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIColor *color = [UIColor colorForKey:WSLoginViewInteractiveRegionBgColorMark];
        _textFieldBgColor = (color ? color : [UIColor whiteColor]);
        
        color = [UIColor colorForKey:WSLoginViewInteractiveRegionLoginButtonBgColorMark];
        _loginButtonBgColor = (color ? color : MAIN_TINT_COLOR);
        
        color = [UIColor colorForKey:WSLoginViewInteractiveRegionLoginButtonTextColorMark];
        _loginButtonTitltColor = (color ? color : [UIColor whiteColor]);
        
        color = [UIColor colorForKey:WSLoginViewWarningTextColorMark];
        _loginWarningTitltColor = (color ? color : [UIColor redColor]);
        
        color = [UIColor colorForKey:WSLoginViewTextColorMrak];
        _textColor = (color ? color : MAIN_TINT_COLOR);
        
        [self addSubview:self.bgView];
        [self addSubview:self.nameTextField];
        [self addSubview:self.passwdTextField];
        [self addSubview:self.orgCodeTextField];
        [self addSubview:self.rememberButton];
        [self addSubview:self.loginButton];
        [self addSubview:self.warningLabel];
        [self addSubview:self.retrieveButton];
        [self addSubview:self.aboutButton];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginInputView];
}

#pragma mark - 获取指定宽度范围内登陆视图输入视图高度方法 maxWidth:指定宽度
- (CGFloat)getLoginInputViewHeightWithWidth:(CGFloat)maxWidth
{
    CGFloat maxHeight = (kLoginViewTextFieldHeight * 2) + kLoginViewStandardSpace;
    if([self.dataSource isShowOrgCodeInLoginInputView:self])
        maxHeight += kLoginViewTextFieldHeight;
    
    maxHeight += ([self getRememberHeightWithWidth:maxWidth] + kLoginViewStandardSpace * 2);
    
    maxHeight += (kLoginViewLoginButtonHeight + kLoginViewStandardSpace);
    
    if([self.dataSource isShowWarningInLoginInputView:self])
        maxHeight += ([self getWarningTextHeightWithWidth:maxWidth]);
    
    maxHeight += [self getAboutHeightWithWidth:maxWidth] + kLoginViewStandardSpace;
    
    return maxHeight;
}

#pragma mark - 更新登陆输入方法
- (void)updateLoginInput
{
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图 延展(工具)
@implementation WSSFALoginInputView (Tool)

#pragma mark - 获取指定宽度内记住元素高度方法 width:指定宽度
- (CGFloat)getRememberHeightWithWidth:(CGFloat)width
{
    CGFloat imageHeight = self.rememberButton.iconButton.currentImage.size.height;
    
    CGFloat maxWidth = width - (kLoginViewInteractiveRegionOffX * 2) - (kLoginViewInteractiveRegionElementOffX * 2);
    NSString *text = self.rememberButton.titleButton.currentTitle;
    CGSize textSize = [text ws_sizeWithFont:self.rememberButton.titleButton.titleLabel.font constrainedToWidth:maxWidth];

    CGFloat maxHeight = (imageHeight > textSize.height) ? imageHeight : textSize.height;
    return maxHeight;
}

#pragma mark - 获取指定宽度内警告元素高度方法 width:指定宽度
- (CGFloat)getWarningTextHeightWithWidth:(CGFloat)width
{
    CGFloat maxWidth = width - (kLoginViewInteractiveRegionOffX * 2);
    CGSize textSize = [self.warningLabel.text ws_sizeWithFont:self.warningLabel.font constrainedToWidth:maxWidth];
    
    return textSize.height;
}

#pragma mark - 获取指定宽度内关于高度方法 width:指定宽度
- (CGFloat)getAboutHeightWithWidth:(CGFloat)width
{
    CGFloat maxWidth = (width - (kLoginViewInteractiveRegionOffX * 2) - (kLoginViewInteractiveRegionElementOffX * 2)) / 2;
    NSString *text = self.aboutButton.currentTitle;
    CGSize textSize = [text ws_sizeWithFont:self.aboutButton.titleLabel.font constrainedToWidth:maxWidth];

    return textSize.height;
}

#pragma mark - 布局登陆输入视图方法
- (void)layoutLoginInputView
{
    CGFloat currentDrawHeight = 0.0f;
    
    self.bgView.frame = self.bounds;
    
    CGFloat x = (kLoginViewInteractiveRegionOffX + kLoginViewInteractiveRegionElementOffX);
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame) - (x * 2);
    CGFloat h = kLoginViewTextFieldHeight;
    self.nameTextField.frame = CGRectMake(x, y, w, h);
    currentDrawHeight = CGRectGetMaxY(self.nameTextField.frame);
    
    x = (kLoginViewInteractiveRegionOffX + kLoginViewInteractiveRegionElementOffX);
    y = CGRectGetMaxY(self.nameTextField.frame);
    w = CGRectGetWidth(self.frame) - (x * 2);
    h = kLoginViewTextFieldHeight;
    self.passwdTextField.frame = CGRectMake(x, y, w, h);
    currentDrawHeight = CGRectGetMaxY(self.passwdTextField.frame);
    
    CGRect orgCodeTextFieldFrame = CGRectZero;
    if([self.dataSource isShowOrgCodeInLoginInputView:self])
    {
        x = (kLoginViewInteractiveRegionOffX + kLoginViewInteractiveRegionElementOffX);;
        y = CGRectGetMaxY(self.passwdTextField.frame);
        w = CGRectGetWidth(self.frame) - (x * 2);
        h = kLoginViewTextFieldHeight;
        orgCodeTextFieldFrame = CGRectMake(x, y, w, h);
        currentDrawHeight = CGRectGetMaxY(orgCodeTextFieldFrame);
    }
    self.orgCodeTextField.frame = orgCodeTextFieldFrame;
    
    currentDrawHeight += kLoginViewStandardSpace;
    
    x = (kLoginViewInteractiveRegionOffX + kLoginViewInteractiveRegionElementOffX);
    y = currentDrawHeight;
    w = CGRectGetWidth(self.frame) - (x * 2);
    h = [self getRememberHeightWithWidth:CGRectGetWidth(self.frame)];
    self.rememberButton.frame = CGRectMake(x, y, w, h);
    currentDrawHeight = CGRectGetMaxY(self.rememberButton.frame);
    
    currentDrawHeight += kLoginViewStandardSpace * 2;
    
    x = kLoginViewInteractiveRegionOffX;
    y = currentDrawHeight;
    w = CGRectGetWidth(self.frame) - (x * 2);
    h = kLoginViewLoginButtonHeight;
    self.loginButton.frame = CGRectMake(x, y, w, h);
    currentDrawHeight = CGRectGetMaxY(self.loginButton.frame);
    
    CGRect warningLabelFrame = CGRectZero;
    if([self.dataSource isShowWarningInLoginInputView:self])
    {
        CGFloat x = kLoginViewInteractiveRegionOffX;
        CGFloat y = CGRectGetMaxY(self.loginButton.frame);
        CGFloat w = CGRectGetWidth(self.frame) - (x * 2);
        CGFloat h = [self getWarningTextHeightWithWidth:CGRectGetWidth(self.frame)];
        warningLabelFrame = CGRectMake(x, y, w, h);
        currentDrawHeight = CGRectGetMaxY(warningLabelFrame);
    }
    self.warningLabel.frame = warningLabelFrame;
    
    currentDrawHeight += kLoginViewStandardSpace;
    CGFloat halfMaxDrawWidth = CGRectGetWidth(self.frame) - (kLoginViewInteractiveRegionOffX * 2) - (kLoginViewInteractiveRegionElementOffX * 2);
    
    CGRect retrieveButtonFrame = CGRectZero;
    if([self.dataSource isShowRetrieveInLoginInputView:self])
    {
        CGSize textSize = [self.retrieveButton.currentTitle ws_sizeWithFont:self.retrieveButton.titleLabel.font constrainedToWidth:halfMaxDrawWidth];
        CGFloat x = kLoginViewInteractiveRegionOffX + kLoginViewInteractiveRegionElementOffX;
        CGFloat y = currentDrawHeight;
        CGFloat w = textSize.width;
        CGFloat h = textSize.height;
        retrieveButtonFrame = CGRectMake(x, y, w, h);
    }
    self.retrieveButton.frame = retrieveButtonFrame;
    
    CGSize textSize = [self.aboutButton.currentTitle ws_sizeWithFont:self.aboutButton.titleLabel.font constrainedToWidth:halfMaxDrawWidth];
    x = CGRectGetWidth(self.frame) - kLoginViewInteractiveRegionOffX - kLoginViewInteractiveRegionElementOffX - textSize.width;
    y = currentDrawHeight;
    w = textSize.width;
    h = textSize.height;
    self.aboutButton.frame = CGRectMake(x, y, w, h);
}

@end
//===================================================================================================================================================================
