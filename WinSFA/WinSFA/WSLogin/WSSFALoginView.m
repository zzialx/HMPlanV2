//
//  WSSFALoginView.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginView.h"
#import "WSSFALoginTool.h"
#import "WSSFALoginGlobalDefinitions.h"
#import "WSSFALoginLogo.h"
#import "WSSFALoginInputView.h"
#import "WSSFALoginHotlineView.h"
#import "WSSFALoginTextField.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(内部)
@interface WSSFALoginView ()

@property (nonatomic, strong) UIImageView *bgImageView;                 //背景视图
@property (nonatomic, strong) WSSFALoginLogo *logoImageView;            //logo视图
@property (nonatomic, strong) UIVisualEffectView *effectView;           //效果视图
@property (nonatomic, strong) WSSFALoginInputView *loginInputView;      //输入视图
@property (nonatomic, strong) WSSFALoginHotlineView *loginHotlineView;  //热线视图
@property (nonatomic, weak) UITextField *shouldBeginTextField;          //启动的输入框

#pragma mark - 热线按键点击回调方法 sender:响应对象
- (void)hotlineButtonClick:(id)sender;

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(工具)
@interface WSSFALoginView (Tool)

#pragma mark - 布局登陆视图方法
- (void)layoutLoginView;

#pragma mark - 输入框状态变化后展示动画方法 up:是否向上
- (void)animationsOnTextField:(BOOL)up;

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(WSSFALoginInputViewDataSource)
@interface WSSFALoginView (loginInputViewDataSource) <WSSFALoginInputViewDataSource>

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(UITextFieldDelegate)
@interface WSSFALoginView (textFieldDelegate) <UITextFieldDelegate>

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图
@implementation WSSFALoginView

#pragma mark - 获取bgImageView方法
- (UIImageView *)bgImageView
{
    if(_bgImageView == nil)
    {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bgImageView.backgroundColor = [UIColor clearColor];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        _bgImageView.image = [UIImage scaledImageForName:@"login_bg-568" ofType:@"png"];
    }
    
    return _bgImageView;
}

#pragma mark - 获取logoImageView方法
- (WSSFALoginLogo *)logoImageView
{
    if(_logoImageView == nil)
    {
        _logoImageView = [[WSSFALoginLogo alloc] initWithFrame:CGRectZero];
        _logoImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _logoImageView;
}

#pragma mark - 获取effectView方法
- (UIVisualEffectView *)effectView
{
    if(_effectView == nil)
    {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.frame = CGRectZero;
        _effectView.hidden = YES;
    }
    
    return _effectView;
}

#pragma mark - 获取loginInputView方法
- (WSSFALoginInputView *)loginInputView
{
    if(_loginInputView == nil)
    {
        _loginInputView = [[WSSFALoginInputView alloc] initWithFrame:CGRectZero];
        _loginInputView.backgroundColor = [UIColor clearColor];
        _loginInputView.dataSource = self;
        
        _loginInputView.nameTextField.textField.delegate = self;
        _loginInputView.passwdTextField.textField.delegate = self;
        _loginInputView.orgCodeTextField.textField.delegate = self;
    }
    
    return _loginInputView;
}

#pragma mark - 获取loginHotlineView方法
- (WSSFALoginHotlineView *)loginHotlineView
{
    if(_loginHotlineView == nil)
    {
        _loginHotlineView =  [[WSSFALoginHotlineView alloc] initWithFrame:CGRectZero];
        _loginHotlineView.backgroundColor = [UIColor clearColor];
        [_loginHotlineView.hotlineTelephoneButton addTarget:self action:@selector(hotlineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loginHotlineView;
}

#pragma mark - 重写initWithFrame方法
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _isShowOrgCode = NO;
        _isShowWarning = NO;
        _isShowRetrieve = NO;
        _isShowHotline = NO;
        
        [self addSubview:self.bgImageView];
        [self addSubview:self.logoImageView];
        [self addSubview:self.loginHotlineView];
        [self addSubview:self.effectView];
        [self addSubview:self.loginInputView];
    }
    
    return self;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutLoginView];
}

#pragma mark - 更新登陆视图方法
- (void)updateLoginView
{
    [self setNeedsLayout];
}

#pragma mark - 清除键盘方法
- (void)dispearKeyboard
{
    [self.loginInputView.nameTextField closecTextField];
    [self.loginInputView.passwdTextField closecTextField];
    [self.loginInputView.orgCodeTextField closecTextField];
}

#pragma mark - 热线按键点击回调方法
- (void)hotlineButtonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (self.hotlineClickBlock)
        self.hotlineClickBlock(button.currentAttributedTitle.string);
}

#pragma mark - 重写touchesBegan:withEvent:方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dispearKeyboard];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(工具)
@implementation WSSFALoginView (Tool)

#pragma mark - 布局登陆视图方法
- (void)layoutLoginView
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.bgImageView.frame = CGRectMake(x, y, w, h);
    self.effectView.frame = CGRectMake(x, y, w, h);
    
    UIImage *logoImage = self.logoImageView.logoImageView.image;
    x = (CGRectGetWidth(self.frame) - logoImage.size.width) / 2;
    y = ((self.isShowOrgCode) ? kLoginViewLogoDrawStartY_Element3 : kLoginViewLogoDrawStartY_Element2);
    w = logoImage.size.width;
    h = logoImage.size.height;
    self.logoImageView.frame = CGRectMake(x, y, w, h);
    
    x = kLoginViewStandardSpace;
    y = ((self.isShowOrgCode) ? kLoginViewInteractiveRegionDrawStartY_Element3 : kLoginViewInteractiveRegionDrawStartY_Element2);
    w = CGRectGetWidth(self.frame) - (kLoginViewStandardSpace * 2);
    h = [self.loginInputView getLoginInputViewHeightWithWidth:w];
    self.loginInputView.frame = CGRectMake(x, y, w, h);
    
    CGRect loginHotlineViewFrame = CGRectZero;
    if(self.isShowHotline)
    {
        x = kLoginViewStandardSpace;
        y = CGRectGetHeight(self.frame) - kLoginViewHotlineHeight;
        w = CGRectGetWidth(self.frame) - (kLoginViewStandardSpace * 2);
        h = kLoginViewHotlineHeight;
        loginHotlineViewFrame = CGRectMake(x, y, w, h);
    }
    self.loginHotlineView.frame = loginHotlineViewFrame;
}

#pragma mark - 输入框状态变化后展示动画方法
- (void)animationsOnTextField:(BOOL)up
{
    CGRect loginInputViewRect = self.loginInputView.frame;
    
    [UIView beginAnimations:@"showkeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    
    if(up)
        loginInputViewRect.origin.y = CGRectGetMinX(self.logoImageView.frame);
    else
        loginInputViewRect.origin.y = ((self.isShowOrgCode) ? kLoginViewInteractiveRegionDrawStartY_Element3 : kLoginViewInteractiveRegionDrawStartY_Element2);
    self.loginInputView.frame = loginInputViewRect;
    self.effectView.hidden = (up) ? NO : YES;
    
    [UIView commitAnimations];
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(WSSFALoginInputViewDataSource)
@implementation WSSFALoginView (loginInputViewDataSource)

#pragma mark - 获取是否显示机构代码数据
- (BOOL)isShowOrgCodeInLoginInputView:(WSSFALoginInputView *)loginInputView
{
    return self.isShowOrgCode;
}

#pragma mark - 获取是否显示警告数据
- (BOOL)isShowWarningInLoginInputView:(WSSFALoginInputView *)loginInputView
{
    return self.isShowWarning;
}

#pragma mark - 获取是否显示取回数据
- (BOOL)isShowRetrieveInLoginInputView:(WSSFALoginInputView *)loginInputView
{
    return self.isShowRetrieve;
}

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图 延展(UITextFieldDelegate)
@implementation WSSFALoginView (textFieldDelegate)

#pragma mark - 实现textFieldShouldBeginEditing:代理协议
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - 实现textFieldDidBeginEditing:代理协议
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0f];
    [self animationsOnTextField:YES];
}

#pragma mark - 实现textFieldDidEndEditing:代理协议
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animationsOnTextField:NO];
}

#pragma mark - 实现textFieldShouldReturn:代理协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 实现textFieldShouldClear:代理协议
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

@end
//===================================================================================================================================================================
