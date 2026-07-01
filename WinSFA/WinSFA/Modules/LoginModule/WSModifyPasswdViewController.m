//
//  ModifyPasswdViewController.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-15.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "WSModifyPasswdViewController.h"
#import "WinSFA.h"
//#import "JSON.h"
#import "WSRequestHelper.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+TapAction.h"
#import "WCDataPacker2.h"
#import "WSRootConfigDataProcessService.h"
#import "WSRootConfigDataProcessService.h"
#import "WSReportFormController.h"
//#import "ConfigFileController.h"

#define kURLretrievePassword      (@"/retrievePass/retrievePassword.jsp?iosfresh=false&")

#define kChangePasswordViewYOffSet (SCREEN_HEIGHT * 0.18)
#define kChangePasswordViewWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  SCREEN_WIDTH * 0.8 :310)
#define kChangePasswordViewHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 196 : 230)
#define kTextFieldWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 203 : 250)
#define kTextFieldHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 35 : 46)
#define kTextFieldTopSpace ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 7 : 6)

#define kTextFieldLeftViewWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 90 : 100)

#define kSubmitButtonYOffset_f ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? (SCREEN_HEIGHT * 0.05) : 20)
#define kButtonHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 44 : 50)
#define kButtonTopGap ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 20 : 25)
#define kButtonBotttomSapce kButtonTopGap

#define kForgetButtonHeight 20
#define kForgetButtonWidth 70
#define kForgetTopSpace 5
#define KWSLOGINMINPASSWORDLEN 4
#define KWSLOGINMAXPASSWORDLEN 20



@interface UITextField(ex)
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
@end
@implementation UITextField(ex)
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return NO;
}
@end

@interface WSModifyPasswdViewController ()
{
    UIButton    *submitButton;
    UIButton    *backButton;
    UIButton    *forgetButton;
}

/**
 等待请求结果时，取消用户操作
 请求结束后，打开用户操作
 */

@property (nonatomic, strong) UITextField *shouldBeginTextField;

- (void)enableUserInterface:(BOOL)userInterfaceable;
@end

@implementation WSModifyPasswdViewController
@synthesize textFields;
@synthesize tableCellTitle;



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //[self.navigationController setNavigationBarHidden:NO];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
        
    [backBtn setBackgroundColor:[UIColor clearColor]];
        
    [backBtn setImage:[UIImage scaledImageForName:@"icon_back" ofType:@"png"] forState:UIControlStateNormal];
        
//    [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
        
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=homeButtonItem;
        
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    UIImage *bgImage;
    if (INTERFACE_IS_PAD) {
        bgImage = [UIImage scaledImageForName:@"login_bg_lanscape" ofType:@"png"];
    } else {
        if (IS_IPHONE5) {
            bgImage = [UIImage scaledImageForName:@"login_bg-568" ofType:@"png"];
        } else {
            bgImage = [UIImage scaledImageForName:@"login_bg" ofType:@"png"];
        }
    }
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    bgImageView.image = bgImage;
    [self.view addSubview:bgImageView];
    
    self.title = NSLocalizedString(@"modify_password_label",nil);
    
    NSString *IDString = NSLocalizedString(@"current_user_name_label",nil);
    NSString *PassWordString = NSLocalizedString(@"old_password_label",nil);
    NSString *NewPassWordString = NSLocalizedString(@"new_password_label",nil);
    NSString *confirmPSWString = NSLocalizedString(@"check_new_password_label",nil);
    self.tableCellTitle = [NSArray arrayWithObjects:
                           IDString,PassWordString,NewPassWordString,confirmPSWString, nil];
    

    CGFloat offsetY = kChangePasswordViewYOffSet;

    self.textFields = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        
//        UILabel *placeHodlerLable =[[UILabel alloc]initWithFrame:CGRectMake(5, (2*kTextFieldTopSpace + kTextFieldHeight)*i + kTextFieldTopSpace, (kChangePasswordViewWidth - kTextFieldWidth ), kTextFieldHeight)];
//        placeHodlerLable.textAlignment = NSTextAlignmentLeft;
//        placeHodlerLable.textColor = [UIColor redColor];
//        placeHodlerLable.font = [UIFont systemFontOfSize:14];
//        placeHodlerLable.contentMode = UIControlContentVerticalAlignmentCenter;
        NSString *taget = [NSString stringWithFormat:@"%@",[self.tableCellTitle objectAtIndex:i]];
        
//        placeHodlerLable.text = taget;
//        [changePswView addSubview:placeHodlerLable];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - kChangePasswordViewWidth)/2, kChangePasswordViewYOffSet + (2*kTextFieldTopSpace + kTextFieldHeight)*i + kTextFieldTopSpace,kChangePasswordViewWidth, kTextFieldHeight)];
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.secureTextEntry = i;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textColor = DETAIL_TEXT_COLOR;
        textField.delegate = self;
        textField.font = [UIFont systemFontOfSize:UI_Font];
        textField.placeholder = taget;
		[self.textFields addObject:textField];
        [self.view addSubview:textField];
        
        [self addBottomBorderToView:textField];
        
        if (i == 0) {
            textField.text = self.modifyUserName;
            if ([self.modifyUserName length] > 0) {
                textField.enabled = NO;
            }
        }
        offsetY += 2 * kTextFieldTopSpace + kTextFieldHeight;
    }
    //SFA-25235
    forgetButton = [[UIButton alloc] init];
    NSString *title = [NSString stringWithFormat:@"%@?",NSLocalizedString(@"password_retake", nil)];
    [forgetButton setTitle:title forState:UIControlStateNormal];
    [forgetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    forgetButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [forgetButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:forgetButton.titleLabel.text];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [forgetButton setAttributedTitle:str forState:UIControlStateNormal];
    
    CGSize titleSize = [forgetButton.titleLabel.text ws_sizeWithFont:forgetButton.titleLabel.font constrainedToHeight:kForgetButtonHeight];
    CGFloat sapce = (SCREEN_WIDTH - kChangePasswordViewWidth) / 2;
    forgetButton.frame = CGRectMake( kChangePasswordViewWidth + sapce - titleSize.width, offsetY + kForgetTopSpace, titleSize.width, kForgetButtonHeight);
    [forgetButton addTarget:self action:@selector(gotoRetrievePassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetButton];
    
    
    submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    CGFloat sumbitBtnOffsetY = kSubmitButtonYOffset_f + offsetY;
    CGRect btnRect = CGRectMake((SCREEN_WIDTH - kChangePasswordViewWidth) / 2, sumbitBtnOffsetY, kChangePasswordViewWidth, kButtonHeight);
   
    UIColor *mainTintColor = [UIColor colorForKey:@"SubBtnTintColor"] ? [UIColor colorForKey:@"SubBtnTintColor"] : [UIColor colorWithRed:57.0f/255 green:131.0f/255 blue:248.0f/255 alpha:1.0f];
    
    UIImage *btnImg = [UIImage imageFromColor:mainTintColor with:btnRect];
    UIImage *btnPressImg = [UIImage imageFromColor:[mainTintColor colorWithAlphaComponent:ALPHA_PRESSED] with:btnRect];
    UIImage *btnDisableImg = [UIImage imageFromColor:[mainTintColor colorWithAlphaComponent:ALPHA_DISABLED] with:btnRect];
    [submitButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [submitButton setBackgroundImage:btnDisableImg forState:UIControlStateDisabled];
    [submitButton setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
    
    submitButton.layer.masksToBounds = YES;
    submitButton.layer.cornerRadius = kButtonHeight / 11;
    
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.frame = btnRect;
    NSString *SubmitString = NSLocalizedString(@"submit",nil);
    [submitButton setTitle:SubmitString forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(commitPasswd:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [self.view addSubview:submitButton];
    
}

- (void)viewDidUnload
{
    textFields = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)addBottomBorderToView:(UIView *)view {
    CGRect frame = view.frame;
    
    CALayer *bottomLayer = [CALayer layer];
    
    bottomLayer.frame = CGRectMake(0, frame.size.height, frame.size.width, 1);
    bottomLayer.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [view.layer addSublayer:bottomLayer];
}


/**
 等待请求结果时，取消用户操作
 请求结束后，打开用户操作
 */
- (void)enableUserInterface:(BOOL)userInterfaceable
{
    [submitButton setUserInteractionEnabled:userInterfaceable];
    [backButton setUserInteractionEnabled:userInterfaceable];
}

- (void)commitPasswd:(id)sender{
   
    //对用户输入信息进行验证 addBy wangdongyan modify By wangdongyan 2012-02-28 for 有问题
    [self enableUserInterface:NO];
    if ([self infoValid:self.textFields]) {
        [self enableUserInterface:YES];
        return;
    }
    
    [self resignFirstResponderAndWillClean:NO];
    
    NSString *webAddress = [WSHttpURLHelper getRootConfigWebAddress];
    
    if ([webAddress length] > 0) {
        [self sendModifyPasswordRequest];
    }else {
        [self startGetRootConfig];
    }
    
}

- (void)gotoRetrievePassword
{
    NSString *url = [self getRetrievePasswordUrl];
    if (url.length > 0) {
        [self gotoRetrievePasswordWithUrl:url];
    }
    else{
        NSString *title = @"请求失败";
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:self action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void)gotoRetrievePasswordWithUrl:(NSString *)findPwdURL
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [self animationsOnTextField:NO];
    WSReportFormController *findPwd = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:findPwdURL]];
    findPwd.title = NSLocalizedString(@"password_retake", nil);
    [self.navigationController pushViewController:findPwd animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (NSString *)getRetrievePasswordUrl
{
    return [self getRetrievePasswordUrlWithServerUrl:[WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]];
}

- (NSString *)getRetrievePasswordUrlWithServerUrl:(NSString *)serverUrl
{
    NSString *findPwdURL = nil;
    NSString *findPasswordMjet = [WSPlistHelper valueForKey:kGET_PASSWORD_URL withPlistName:kConfilgFileName];
    if ([findPasswordMjet length] > 0)
        findPwdURL = [NSString stringWithFormat:@"%@&nls=%@", findPasswordMjet,[UIDevice getPreferredLanguage]];
    else
        findPwdURL = [NSString stringWithFormat:@"%@%@", serverUrl, kURLretrievePassword];
    
    return findPwdURL;
}

- (void)sendModifyPasswordRequest{
    
       NSArray* keys = [NSArray arrayWithObjects:@"username",@"password",@"newPass",@"newPass2", nil];
       NSMutableArray* values = [[NSMutableArray alloc]init ];
       for(UITextField* tf in textFields)
       {
           // add By wangdongyan 2012-02-29 for 当什么都不输入而点击提交时返回
           if (tf.text==nil) {
               return;
           }
           
           if (tf.secureTextEntry && ((tf.text == nil) || ([tf.text length] < KWSLOGINMINPASSWORDLEN) || ([tf.text length] > KWSLOGINMAXPASSWORDLEN)) ) {
               
               NSString *info = NSLocalizedString(@"username_or_psw_null", nil);
               [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:info tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
               return;
           }
           if (tf.text == nil) {
               tf.text = @"";
           }
           
           [values addObject:tf.text];
       }
       
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(changePassWordResponse:)
                                                    name:CHANGE_NOTIFY
                                                  object:nil];
       
       NSDictionary* changePassWord = [NSDictionary dictionaryWithObjects:values forKeys:keys];
       
       NSString *originalKey = [WCDataPacker2 sharedInstance].InitHttpCode2;
       
       [[WCDataPacker2 sharedInstance] setInitHttpCode2:nil];
       
       [[WSRequestHelper shareInstance] appChangePassWord:changePassWord notifyName:CHANGE_NOTIFY];
       
       [[WCDataPacker2 sharedInstance] setInitHttpCode2:originalKey];
       
       [MBProgressHUD showHUDAddedTo:self.view withText:NSLocalizedString(@"Saving_password_prompt", nil) tips:nil tapTarget:self action:nil];
}

- (void)back:(id)sender{
    
    [self resignFirstResponderAndWillClean:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.shouldBeginTextField) {
        [self.shouldBeginTextField  resignFirstResponder];
    }
}

- (void)animationsOnTextField:(BOOL)up{
    
    int y[2] = {64 , (INTERFACE_IS_PHONE ? 0 : - 80)};
    [UIView beginAnimations:@"showkeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3f];
    [self.view setFrame:CGRectMake(0, y[up], self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.shouldBeginTextField = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animationsOnTextField:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self animationsOnTextField:NO];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.shouldBeginTextField == nil || self.shouldBeginTextField == textField) {
        [self animationsOnTextField:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.secureTextEntry) {
        NSString *content = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (content != nil && [content length] > KWSLOGINMAXPASSWORDLEN ) {
            NSString *title = [NSString stringWithFormat:NSLocalizedString(@"password_exceed_max_length", nil),KWSLOGINMAXPASSWORDLEN] ;
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    return YES;
}

- (void)changePassWordResponse:(id)sender
{
   //add By wangdongyan  
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:CHANGE_NOTIFY object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:@"datas"];
    NSString* flag = [[info objectFromJSONString]objectForKey:@"flag"];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    //NSLog(@"error code is %d",error.code);
    if (error == 0 && info != nil && [@"1" isEqualToString:flag])
    {
        NSString *userName = ((UITextField *)[textFields objectAtIndex:0]).text;
//        NSString *oldPassword = ((UITextField *)[textFields objectAtIndex:1]).text;
        NSString *newPassword = ((UITextField *)[textFields objectAtIndex:2]).text;
        
        NSString *userNameCall = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
        if ([[userName lowercaseString] isEqualToString:[userNameCall lowercaseString]]) {
            [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:PASSWORD_CALL_APP];

        }
        
        NSString *userNameLast = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
        if ([[userName lowercaseString] isEqualToString:[userNameLast lowercaseString]]) {
            [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:PASSWORD_LAST_LOGIN];
            
        }
        
        NSString *userNameNomal = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
        if ([[userName lowercaseString] isEqualToString:[userNameNomal lowercaseString]]) {
            [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:PASSWORD];;
            
        }
        
        
        
        //add by wangdongyan 2012-02-29 for 当修改成功时清空
        [self back:nil];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[[info objectFromJSONString] objectForKey:@"msg"] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[[info objectFromJSONString] objectForKey:@"msg"] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
    [self enableUserInterface:YES];
}


/**
 清空输入框的内容
 */
- (void)resignFirstResponderAndWillClean:(BOOL)willCLean
{
    for (UITextField *modifyedText in textFields)
    {
        [modifyedText resignFirstResponder];
        if (willCLean) {
            modifyedText.text=nil;
        }
    }
}

//user Infomation AddBywangdongyan
//一样的话 返回 NO  修改思路错路，不应该是与本地的匹配

-(BOOL)infoValue:(NSString *)aSource  aDest:(NSString *)aDestion aMsg:(NSString *)aMessage
{
    if (![aSource isEqualToString:aDestion])
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:aMessage tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return YES;
    }
    return NO;

}


//user Infomation Valid AddBywangdongyan  modify By wangdongyan 2012-02-28 for 有问题，应该发到服务器与之匹配

-(BOOL)infoValid:(NSMutableArray *)textFieldList{
    
//    //验证用户名
//    NSString *sUserName=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
//    UITextField *sUser=[textFieldList objectAtIndex:0];
//    
//    NSString *sCurrentUser=sUser.text;
//    
//    if ([self infoValue:sUserName aDest:sCurrentUser aMsg:@"用户不存在"])
//    {
//        return YES;
//    }
//
//    //验证原密码
//    NSString *sOldpasswd=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
//    UITextField *text=[textFieldList objectAtIndex:1];
//    NSString *sCurrentpasswds=text.text;
//    
//    if ([self infoValue:sOldpasswd aDest:sCurrentpasswds aMsg:@"原密码输入错误"]) {
//        
//        return YES; 
//    }
        
    //检查用户名称或者密码是否为空
    
    for (int i =0 ; i< textFieldList.count; i++) {
        UITextField *field = [textFieldList objectAtIndex:i];
        NSString *targetName = [self.tableCellTitle objectAtIndex:i];
        if (field.text.length >0) {
            
        }
        else{
            NSString *title = [NSString stringWithFormat:@"%@ 未输入",targetName];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
             return YES;
            
        }
    }
    
    //检查密码的长度是否为1-25位
    int i = 0;
    for (UITextField *field in textFieldList) {
        if (i != 0) {
            if ([field.text length] < KWSLOGINMINPASSWORDLEN || [field.text length] > KWSLOGINMAXPASSWORDLEN) {
                NSString *format = NSLocalizedString(@"password_length", nil);
                NSString *info = [NSString stringWithFormat:format, KWSLOGINMINPASSWORDLEN, KWSLOGINMAXPASSWORDLEN];
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:info tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return YES;
                
            }
        }
        i++;
    }
    
    
    //验证新密码与确认密码
    UITextField *newText=[textFieldList objectAtIndex:2];
    NSString *newPassword=newText.text;
    
    UITextField *rNewText=[textFieldList objectAtIndex:3];
    NSString *rNewPassword=rNewText.text;
    //NSLog(@"new:%@--rnew:%@",newPassword,rNewPassword);
    //一样返回 NO
    NSString *NOMatchString = NSLocalizedString(@"w_rewriteusername",nil);
    if ([self infoValue:newPassword aDest:rNewPassword aMsg:NOMatchString]) {
       return YES;   
    }
    return NO;
}

#pragma - mark root config


- (void)startGetRootConfig
{
    NSString *userName = ((UITextField *)[textFields objectAtIndex:0]).text;
    NSString *oldPassword = ((UITextField *)[textFields objectAtIndex:1]).text;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRootConfigFinish:) name:GETROOTCONFIG_NOTIFY object:nil];
    [[WSRequestHelper shareInstance] appGetRootConfig:userName passWd:oldPassword notifyName:GETROOTCONFIG_NOTIFY progress:nil];
}

- (void)getRootConfigFinish:(id)sender {
    LogInfo(@"请求配置数据结束");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GETROOTCONFIG_NOTIFY object:nil];
    
    NSDictionary *data = [sender userInfo];
    
    NSString *info = [data objectForKey:DATAS];
    
    NSError *error = [data objectForKey:ERROR];
    
    NSDictionary *dic = [info objectFromJSONString];
    
    if (!error && dic) {
        [WSRootConfigDataProcessService processRootConfigData:dic isRememberBtnSelected:NO];
        [self sendModifyPasswordRequest];
    }else {
        NSString *msg = [error ws_localizedDescription];
        if (!msg || [msg length] == 0) {
            msg = NSLocalizedString(@"fail_upload", nil);
        }
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
    
    
}

@end
