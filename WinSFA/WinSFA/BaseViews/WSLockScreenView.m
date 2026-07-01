//
//  WSLockScreenView.m
//  WinSFA
//
//  Created by zhangke on 14/6/30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#define LeftCap 20.0f
#define lock_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 18.0f : 22.0f)
#define textfield_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 16.0f : 20.0f)

#import "WSLockScreenView.h"
#import "WSRequestHelper.h"
#import "MBProgressHUD+TapAction.h"
#import "WSTouchRecord.h"

@interface WSLockScreenView ()<UITextFieldDelegate>{
    UITextField* passwordTextField;
    UILabel* userNameLabel;
    UIView* backView;
    UIImageView* lockScreenBackView;
}

@end


@implementation WSLockScreenView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        backView=[[UIView alloc] initWithFrame:frame];
        backView.backgroundColor=[UIColor blackColor];
        backView.alpha=0.0f;
        [self addSubview:backView];

        UIImage* lockScreenBackImage=[UIImage imageForName:@"lockBack"];
        lockScreenBackView=[[UIImageView alloc] initWithFrame:CGRectMake((self.width-lockScreenBackImage.size.width)/2, self.height, lockScreenBackImage.size.width, lockScreenBackImage.size.height)];
        lockScreenBackView.image=lockScreenBackImage;
        [self addSubview:lockScreenBackView];
        lockScreenBackView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        UIImage* lockLogoImage=[UIImage imageForName:@"lock"];
        UIImageView* lockLogoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(lockScreenBackView.width-lockLogoImage.size.width-LeftCap/2, LeftCap/2, lockLogoImage.size.width, lockLogoImage.size.height)];
        lockLogoImageView.image=lockLogoImage;
        [lockScreenBackView addSubview:lockLogoImageView];
        lockScreenBackView.userInteractionEnabled=YES;
        
        
        userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(LeftCap+5, CGRectGetMaxY(lockLogoImageView.frame), lockScreenBackView.width-LeftCap*2, 45)];
        userNameLabel.text=[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
        userNameLabel.textColor=[UIColor whiteColor];
        userNameLabel.backgroundColor=[UIColor clearColor];
        userNameLabel.font=[UIFont systemFontOfSize:lock_Font];
        [lockScreenBackView addSubview:userNameLabel];
        
         passwordTextField=[[UITextField alloc] initWithFrame:CGRectMake(LeftCap, CGRectGetMaxY(userNameLabel.frame)+LeftCap/2, lockScreenBackView.width-LeftCap*2, 45)];
        passwordTextField.borderStyle=UITextBorderStyleNone;
        passwordTextField.backgroundColor=[UIColor whiteColor];
        passwordTextField.font=[UIFont systemFontOfSize:textfield_Font];
        passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, passwordTextField.height)];
        passwordTextField.leftView = leftView;
        passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        
        NSString *InputPSWString = NSLocalizedString(@"please_enter_psw",nil);
        passwordTextField.placeholder = InputPSWString;
        passwordTextField.secureTextEntry = YES;
        
        passwordTextField.delegate=self;
        
        [lockScreenBackView addSubview:passwordTextField];

    
        UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(passwordTextField.frame)+LeftCap, lockScreenBackView.width, 1)];
        lineView.backgroundColor=[UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
        [lockScreenBackView addSubview:lineView];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        CGFloat btnHeight = 44;
        CGRect btnRect = CGRectMake(LeftCap, lockScreenBackView.height - btnHeight - LeftCap, lockScreenBackView.width - LeftCap * 2, btnHeight);
        
        UIColor *mainTintColor = MAIN_TINT_COLOR;
        
        UIImage *btnImg = [UIImage imageFromColor:mainTintColor with:btnRect];
        UIImage *btnPressImg = [UIImage imageFromColor:[mainTintColor colorWithAlphaComponent:ALPHA_PRESSED] with:btnRect];
        [loginButton setBackgroundImage:btnImg forState:UIControlStateNormal];
        [loginButton setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
        
        loginButton.layer.masksToBounds = YES;
        loginButton.layer.cornerRadius = btnHeight / 8;
        
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        loginButton.frame = btnRect;
        NSString *LoginString = @"unlock";
        [loginButton setTitle:LoginString forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginStart:) forControlEvents:UIControlEventTouchUpInside];
        loginButton.titleLabel.font=[UIFont systemFontOfSize:lock_Font];
        [lockScreenBackView addSubview:loginButton];
        

        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            lockScreenBackView.centerY=self.height/2;
            backView.alpha=0.7f;
        } completion:nil];
        
        
    }
    return self;
}
//  点击登录按钮 发送获取配置文件请求。
- (void)loginStart:(id)sender{
    
    if ((!passwordTextField.text) || ([passwordTextField.text length] ==0) || ( [passwordTextField.text length] > 20)) {
        NSString *info = NSLocalizedString(@"username_or_psw_null", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:info tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [passwordTextField resignFirstResponder];
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP] length]>0){
        if([passwordTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP]]){
            [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                lockScreenBackView.bottom=0;
                backView.alpha=0.0f;
            } completion:^(BOOL finish){
                [self removeFromSuperview];
                
                [WSTouchRecord sharedManager].login=YES;

                NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
                if(lockout.integerValue>0){
                    [[WSTouchRecord sharedManager] resetTimer];
                }
            }];
        }else{
            NSString *LoginfailString = NSLocalizedString(@"login_fail",nil);
            [self showAlert:LoginfailString];
        }
    }else{
        [MBProgressHUD showHUDAddedTo:self withText:NSLocalizedString(@"logining_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginResponse:)
                                                     name:LOGIN_NOTIFY
                                                   object:nil];
        [[WSRequestHelper shareInstance] postRequestOnLogin:userNameLabel.text passWd:passwordTextField.text notifyName:LOGIN_NOTIFY URL:URL_LOGIN];
    }
}

- (void)loginResponse:(id)sender{
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *dic = [info objectFromJSONString];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFY object:nil];
    
    if (error != nil){
        [self showAlert:[error ws_localizedDescription]];
        return;
    }
    
    if (!info || [info length] == 0 ) {
        return;
    }
    
    NSNumber* flag = [dic objectForKey:@"flag"];
    if([flag isEqualToNumber:[NSNumber numberWithInteger:0]]){
        
        //错误信息
        NSString* message = [dic objectForKey:@"msg"];
        if (![message isKindOfClass:[NSNull class]]) {
            [self showAlert:message];
        }
        
        return;
    }
    
    
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        lockScreenBackView.bottom=0;
        backView.alpha=0.0f;
    } completion:^(BOOL finish){
        [self removeFromSuperview];
        
        [WSTouchRecord sharedManager].login=YES;

        NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
        if(lockout.integerValue>0){
            [[WSTouchRecord sharedManager] resetTimer];
        }
    }];
}

- (void)showAlert:(NSString *)message{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}


- (void)animationsOnTextField:(BOOL)up{
    int y[2] = {0, -160};
    [UIView beginAnimations:@"showkeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3f];
    CGRect newFrame = self.frame;
    newFrame.origin.y = y[up];
    [self setFrame:newFrame];
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animationsOnTextField:NO];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animationsOnTextField:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *content = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (content != nil && [content length] > 20) {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


@end
