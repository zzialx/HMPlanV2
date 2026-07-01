//
//  LoginViewController.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-14.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "WSLoginViewController.h"
#import "WSModifyPasswdViewController.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
#import "WSFuncsBean.h"
#import "MainViewController.h"
#import "WSCurrentTime.h"
#import "WSOffLineUploadTable.h"
#import "MBProgressHUD.h"
#import "WSAppConfig.h"
#import "WSRequestDataCacheTable.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MBProgressHUD+TapAction.h"
#import "WSBaseStoreDataTable.h"
#import "UIDevice+Addtional.h"
#import "WCLogManager.h"
#import "WSOfflineDataManager.h"
#import "DDLog.h"
#import "WSContactsManager.h"
#import "WSImagePathTable.h"
#import "FileManager.h"
#import "WSLocationManager.h"
#import "WinSFA.h"
#import "WSOfflineDataDBService.h"
#import <CoreLocation/CoreLocation.h>
#import "WSJSONBuilder.h"
#import "BlockAlertView.h"
#import "WSConfigObject.h"
#import "WSTestTools.h"
#import "WSEnvrionment.h"
#import "WSReportFormController.h"
#import "WSRegisterViewController.h"
#import "WSMjetLoginManager.h"
#import "WSHotLineViewController.h"
#import "WSManuallyUploadViewController.h"
#import "WSCookieHelper.h"
#import "WSLoginDataProcessService+DB.h"
#import "InitSwipePasswordViewController.h"
#import "WSStatisticsManager.h"
#import "WSLoginProgressDefine.h"
#import "NSError+Description.h"
#import "WSRootConfigDataProcessService.h"
#import "WSLoadingImageView.h"
#import "WSSaasFindPwdView.h"
#import "WSEnvrionment.h"
#import "WSFindPassWordAlertView.h"
#import "WinSSOLoginJSBridgeViewController.h"
//=========================================================================================================================================================================

#define VERSIONTAG                              1000
#define EXCEPTIONTAG                            100
#define UPDATE_ALERT_TAG                        5001
#define KWSLOGINMINPASSWORDLEN                  1
#define KWSLOGINMAXPASSWORDLEN                  25
#define k_YOffSetDifference                     40
#define k_LoginBtnHeight                        44
#define k_LogoShrinkRatio                       0.8
#define k_LogoYOffSet                           ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.04 : 20)
#define k_hotLineHeight                         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 38)
#define k_ButtonWidth                           ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 70 : 105)
#define k_ButtonHeight                          ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 : 38)
#define k_LogoImageHeight                       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? (SCREEN_HEIGHT * 0.3) : 280)
#define k_RememberUserHeight                    ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 22 :32)
#define IsIphone4                               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define k_LoginBoxWidth                         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?   SCREEN_WIDTH * 0.8:310)
#define k_LoginBoxHeight                        ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 98:116)
#define k_ChangePwdXOffSet                      ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 27 : 308)
#define k_ChangePwdYOffSet                      ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 420 : 545)
#define k_LoginBtnYOffSet                       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? SCREEN_HEIGHT * 0.08 : 40)
#define k_LoginBtnTitleFont                     ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 18 : 24)
#define LOGINVIEW_TEXT_COLOR                    [UIColor colorForKey:@"LoginViewTextColor"]
#define LOGINVIEW_LOGINBTN_BACKGROUND_COLOR     [UIColor colorForKey:@"LoginViewLoginBtnBackgroundColor"]
#define kURLretrievePassword                    (@"/retrievePass/retrievePassword.jsp?iosfresh=false&")
#define LOGIN_SAAS_ACNUMBERS                    @"acnumbers"
#define LOGIN_SAAS_URL                          @"url"
#define LOGIN_SAAS_WEB_ADDRESS_SEPARATOR        @"[@]"
#define LOGIN_SAAS_SEND_VERSION_KEY             @"sendVersion"      //服务器端下发的是否需要上传版本号标识
#define USERNAME_FOR_ORG                        @"usernameForOrg"   //需要输入组织的时候要记住用户填写的用户名
#define PASSWORD_FOR_ORG                        @"passwordForOrg"   //需要输入组织的时候要记住用户填写的密码
//=========================================================================================================================================================================

@interface WSLoginViewController () <WSMjetLoginManagerDelegate, WSManuallyUploadViewControllerDelegate, WSLoginReterivePwdDelegate> {
    
    NSInteger loginCount;
    BOOL isBackFromOtherController;
    BOOL isRequestingLogIn;
    NSTimer *updateTimer;
    BOOL hasShownUpdateAlert;
    UIButton *registerBtn;
    BOOL shouldModifyPassword;
}

@property (nonatomic, strong) InitSwipePasswordViewController *swipeVC;
@property (nonatomic, strong) NSMutableString* m_verUrl;
@property (nonatomic, strong) WSAppSettingViewController *aboutVC;
@property (nonatomic, strong) WSRegisterViewController *registerVC;
@property (nonatomic, strong) UITextField *shouldBeginTextField;
@property (nonatomic, strong) UIColor *loginViewTextColor;
@property (nonatomic, strong) NSDictionary *dic;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSMutableDictionary *timestampDic;
@property (nonatomic, strong) WSLoadingImageView *indicatorView;
@property (nonatomic, strong) WSLoginDataProcessService *processService;
@property (nonatomic, assign) BOOL isShowOrgCode;
@property (nonatomic, strong) WSSaasFindPwdView *findPwdView;
@property (nonatomic, assign) BOOL isUseSaasWebAddressLogin;            //MSTD-6717 使用 SAAS 返回的 Web 地址登录
@property (nonatomic, assign) BOOL isCountingdown;                      //SFA-13909 登录按钮是否正在倒计时，倒计时中进行输入不改变登录按钮只读状态
@property (nonatomic, strong) UILabel *hotlineLabel;                    //公司热线
@property (nonatomic, strong) UILabel *hotlineBtn;                      //400
@property (nonatomic, strong) UIImageView *bgImageView;                 //背景视图
@property (nonatomic, strong) UIImageView *sysNameLogo;                 //logo视图
@property (nonatomic, strong) UIView *hotlineView;                      //热线视图
@property (nonatomic, strong) UIVisualEffectView *effectView;           //效果视图
@property (nonatomic, strong) UIView *loginBoxView;                     //登录盒子视图
@property (nonatomic, strong) UITextField *username;                    //姓名输入框
@property (nonatomic, strong) UITextField *passwd;                      //密码输入框
@property (nonatomic, strong) UITextField *orgCodeTextField;            //机构代码输入框
@property (nonatomic, strong) NSMutableArray *textFields;               //输入框数组
@property (nonatomic, strong) UIButton *rememberBtn;                    //记住用户名按键
@property (nonatomic, strong) JFTakeCountButton *loginBtn;              //登录按键
@property (nonatomic, strong) UIButton *ssoLoginBtn;                    //SSO登录按键
@property (nonatomic, strong) UILabel *warningLabel;                    //警告标签
@property (nonatomic, strong) UIButton *aboutButton;                    //关于按键
@property (nonatomic, strong) UIButton *changePSWBtn;                   //找回密码按键
@property (nonatomic, assign) CGFloat currentKeyboardHeight;            //当前键盘高度
@property (nonatomic, assign) BOOL isFirstLoadSubView;                  //是否第一次加载子视图
@property (nonatomic, assign) BOOL isSSOLogin;                          //是否sso登陆方式

- (void)cancelLogin:(id)sender;
- (void)animationsOnTextField:(BOOL)up;
- (void)dispearKeyboard;
- (void)loginResponse:(id)sender;
- (void)showAlert:(NSString *)message;
- (void)loginCancel;
- (void)addServiceCallToAddressBook;
- (BOOL)checkUserNameAndPsw;
- (void)saveUserFirstLogin;

@end
//=========================================================================================================================================================================

@implementation WSLoginViewController
@synthesize aiv;
@synthesize loginstate;
@synthesize cancelBtn;
@synthesize changePasswd;
@synthesize rememberUsername;
@synthesize phoneNumber;
@synthesize m_verUrl;
@synthesize aboutVC = _aboutVC;
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//系统方法
#pragma mark - 重写init方法
- (id)init {
    
    if (self = [super init]) {
        isRequestingLogIn = NO;
    }
    return self;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    LogTrace();
    
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideOrShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHideOrShow:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!self.isFirstLoadSubView) {
        
        self.isFirstLoadSubView = YES;
        [self setupViews];

        if (INTERFACE_IS_PHONE) {
            [self createGuidanceViewController];
        }
    }
    
    LogInfo(@"WSLoginViewController viewWillAppear 1 %@", [self getSSOLoginStateText]);
    NSString *authorization = [WSPlistHelper valueForKey:OPEN_TC_EVERY_TIME withPlistName:kConfilgFileName];
    if (!authorization) {
        authorization = @"0";
    }
    if (!isBackFromOtherController && authorization && [authorization isEqualToString:@"0"]) {
        LogInfo(@"WSLoginViewController viewWillAppear 2 %@", [self getSSOLoginStateText]);
        [self autoLogin];
    }
    
    if ([self remeberUserPwd]) {
        [self showUserPwd];
    }
    [self showModifyPwdOrNot];
}

#pragma mark - 重写viewDidAppear方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    LogTrace();
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    isBackFromOtherController = YES;//取消自动登录 因为将会从其他页面返回
}

#pragma mark - 重写viewDidUnload方法
- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    self.loginBoxView = nil;
    self.loginBtn = nil;
    self.changePasswd = nil;
    self.rememberUsername = nil;
    self.sysNameLogo = nil;
    self.textFields = nil;
    phoneNumber = nil;
    loginstate = nil;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 重写shouldAutorotateToInterfaceOrientation方法
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 获取indicatorView方法(软加载)
- (WSLoadingImageView *)indicatorView {
    
    if (!_indicatorView) {
        
        CGFloat imageWH = 20;
        CGRect indicatorFrame = CGRectMake((self.loginBtn.size.width - imageWH ) / 2, (self.loginBtn.size.height - imageWH ) / 2, imageWH, imageWH);
        WSLoadingImageView *indicatorView = [[WSLoadingImageView alloc] initWithFrame:indicatorFrame];
        [self.loginBtn addSubview:indicatorView];
        _indicatorView = indicatorView;
    }
    
    return _indicatorView;
}

#pragma mark - 获取processService方法(软加载)
- (WSLoginDataProcessService *)processService {
    
    if (!_processService) {
        _processService = [[WSLoginDataProcessService alloc] init];
    }
    return _processService;
}

#pragma mark - 获取sso登录状态文本方法
- (NSString *)getSSOLoginStateText {
    
    NSString *text = [NSString stringWithFormat:@"isSSOLogin = %d SSOLOGINSTATE = %@", self.isSSOLogin, [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE]];
    return text;
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//登陆执行
#pragma mark - 自动登录方法
- (void)autoLogin {
    
    LogInfo(@"WSLoginViewController autoLogin 1 %@", [self getSSOLoginStateText]);
    NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
    if ([ssoLoginState isEqualToString:@"1"]) {
        
        NSInteger exitAppStatus = ((NSNumber *)[FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY]).integerValue;
        if (exitAppStatus != ExitAppStatusForce && exitAppStatus != ExitAppStatusBizdateError && exitAppStatus != ExitAppStatusNormal) {
            
            LogInfo(@"WSLoginViewController autoLogin 2 %@", [self getSSOLoginStateText]);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 9999;
            [self loginStart:button];
        }
        return;
    }

    LogInfo(@"WSLoginViewController autoLogin 3 %@", [self getSSOLoginStateText]);
    NSInteger exitAppStatus = ((NSNumber *)[FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY]).integerValue;
    if (exitAppStatus != ExitAppStatusForce && exitAppStatus != ExitAppStatusBizdateError && exitAppStatus != ExitAppStatusNormal && [self checkUserNameAndPsw]) {
        
        if (!isRequestingLogIn && !shouldModifyPassword && !self.isCountingdown) {
            LogInfo(@"WSLoginViewController autoLogin 4 %@", [self getSSOLoginStateText]);
            [self loginStart:nil];
        }
    }
    
    LogInfo(@"WSLoginViewController autoLogin 5 %@", [self getSSOLoginStateText]);
}

#pragma mark - 登录按键响应方法
- (void)loginStart:(id)sender {
    
    LogInfo(@"WSLoginViewController loginStart 1 %@", [self getSSOLoginStateText]);
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_LOGIN_ALL_TIME forcePrint:YES];
    [[WSTestTools getInstance] keepTimeWithKey:LOG_CREATE_AND_UPDATE_DATABASE forcePrint:YES];
    
    BOOL bflag = [[WSDBManagerTable sharedTable] createAllDbTables];
    if (!bflag) {
        LogError(@"create database failure");
        [WSAppData removeAll];
        NSString *title = NSLocalizedString(@"database_error",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    UIButton *loginButton = (UIButton *)sender;
    self.isSSOLogin = ((loginButton.tag == 9999) ? YES : NO);
    LogInfo(@"WSLoginViewController loginStart 2 %@", [self getSSOLoginStateText]);
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_CREATE_AND_UPDATE_DATABASE forcePrint:YES];
    isRequestingLogIn = YES;
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate clearCookies];
    
    if ([self getUserNameFromTextField].length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if ([self.passwd.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.passwd.text forKey:PASSWORD_FOR_CACHE_DATA_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [WSAppData removeAll];
    
    BOOL swipe_password_is_right = [[[NSUserDefaults standardUserDefaults] objectForKey:SWIPE_PASSWORD_IS_RIGHT] boolValue];
    if (!swipe_password_is_right && !self.isSSOLogin) {
        
        if ((![self getUserNameFromTextField]) || (!self.passwd.text) || (![[self getUserNameFromTextField] length]) ||
            ([self.passwd.text length] < KWSLOGINMINPASSWORDLEN) || ( [self.passwd.text length] > KWSLOGINMAXPASSWORDLEN)) {
            NSString *info = NSLocalizedString(@"username_or_psw_null", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:info tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }
    
    [self dispearKeyboard];
    [self animationsOnTextField:NO];
    [self saveUserName];
    
    self.timestampDic = [NSMutableDictionary dictionary];
    [self saveNetworkType];
    NSString *beginRequetGenId = [WSStatisticsManager getGenId];
    [self.timestampDic setObject:beginRequetGenId forKey:EVENT_GET_LOGIN_DATA];
    
    LogInfo(@"WSLoginViewController loginStart 3 %@", [self getSSOLoginStateText]);
    if (self.isSSOLogin) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow animated:YES];
    }
    else {
        [self startIndicator];
    }
    
    [self login];
}

#pragma mark - 登陆方法
- (void)login {
    
    LogInfo(@"WSLoginViewController login 1 %@", [self getSSOLoginStateText]);
    [self startLogin];
}

#pragma mark - 启动登陆方法
- (void)startLogin {
    
    LogInfo(@"WSLoginViewController startLogin 1 %@", [self getSSOLoginStateText]);
    [self startLoginWithUrl:URL_LOGIN];
}

#pragma mark - 通过url启动登陆方法
- (void)startLoginWithUrl:(NSString *)url {
    
    LogInfo(@"WSLoginViewController startLoginWithUrl 1 %@", [self getSSOLoginStateText]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResponse:) name:LOGIN_NOTIFY object:nil];
    
    //已经登陆过app后 登录操作
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    if ([enableLocation isEqualToString:@"1"]) {
        
        LogInfo(@"WSLoginViewController startLoginWithUrl 2 %@", [self getSSOLoginStateText]);
        
        [self saveUserFirstLogin];
        NSString *loginCheckGps = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_CHECK_GPS];
        [self postRequestOnLogin:loginCheckGps url:url];
    }
    //第一次登录app 登录操作
    else {
        
        LogInfo(@"WSLoginViewController startLoginWithUrl 3 %@", [self getSSOLoginStateText]);
        
        NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
        if ([isOfflineLanding isEqualToString:@"1"]) {
            
            WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
            NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
            if (pending > 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self jumpToManualUploadController];
                return;
            }
        }
        
        LogInfo(@"WSLoginViewController startLoginWithUrl 4 %@", [self getSSOLoginStateText]);
        
        if (self.isSSOLogin) {
            NSString *ssoCode = [[NSUserDefaults standardUserDefaults] objectForKey:SSOCODE];
            [[WSRequestHelper shareInstance] postRequestOnLoginWithSSOUserCode:ssoCode notifyName:LOGIN_NOTIFY URL:url progress:nil];
        }
        else {
            [[WSRequestHelper shareInstance] postRequestOnLogin:[self getUserName] passWd:[self getUserPassword] notifyName:LOGIN_NOTIFY URL:url];
        }
    }
}

#pragma mark - 登陆成功通知回调方法
- (void)loginResponse:(id)sender {
    
    if (self.swipeVC) {
        [MBProgressHUD hideHUDForView:self.swipeVC.view animated:YES];
    }
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    
    LogInfo(@"请求业务数据结束");
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_GET_LOGIN_DATA forcePrint:YES];
    NSString *beginRequestGenId = [self.timestampDic objectForKey:EVENT_GET_LOGIN_DATA];
    if ([beginRequestGenId length] > 0)
        [[WSStatisticsManager sharedInstance] updateEndTime:[WSCurrentTime getTimeMillisStringForDevice] withGenID:beginRequestGenId];
    
    self.userInfo = [sender userInfo];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *dic = [info objectFromJSONString];
    self.dic = dic;
    
    NSString *timeUpdate = [dic objectForKey:APPDATA_TIME_UPDATE];
    [[NSUserDefaults standardUserDefaults] setObject:timeUpdate forKey:APPDATA_TIME_UPDATE];
    NSString *message = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFY object:nil];
    
    if (error) {
        
        if ([self showPromptWithError:error]) {
            return;
        }
    
        [self cancelLogin:nil];
        [self showAlert:[error ws_localizedDescription]];
        return;
    }
    
    if (!info || [info length] == 0 ) {
        LogError(@"info length == 0");
        [self cancelLogin:nil];
        return;
    }
    
    BOOL pwdWillExpire = NO;
    NSString *serverRemdinMsg = [dic objectForKey:PSW_VALID_DAY_MSG];
    message = [dic objectForKey:@"msg"];
    
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    if (![flag isEqualToString:@"1"]) {
        
        LogInfo(@"info: %@", info);
        NSDictionary *i_ver = [dic objectForKey:@"ver"];
        NSNumber *i_newVer = [i_ver objectForKey:@"newver"];
        if (i_newVer != nil&&![i_newVer isKindOfClass:[NSNull class]]) {
            
            NSString *versionUrl = [i_ver objectForKey:@"updateurl"];
            versionUrl = [versionUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (versionUrl) {
                
                if (self.m_verUrl == nil) {
                    m_verUrl = [[NSMutableString alloc]initWithFormat:@"%@",versionUrl];
                }
                else {
                    [self.m_verUrl setString:versionUrl];
                }
            }
            
            [self cancelLogin:nil];
            [self clearLastUserCacheData];
            [self updateSoftWare];
            return;
        }
        
        [self cancelLogin:nil];
        
        if ([flag isEqualToString:@"8"]) {
            [self clearCache];
        }
        
        if ([flag isEqualToString:@"14"]) {
            
            NSString *remdinMsg = NSLocalizedString(@"pwd_will_expired",nil);
            if ([serverRemdinMsg length] > 0) {
                remdinMsg = serverRemdinMsg;
            }
            else if ([message isKindOfClass:[NSString class]] && [message length] > 0) {
                remdinMsg = message;
            }
            [self showModifyPasswordAlertView:remdinMsg];
            return;
        }
        
        if ([flag isEqualToString:@"19"]) {
            
            NSString *remdinMsg = NSLocalizedString(@"pwd_will_expired",nil);
            if ([serverRemdinMsg length] > 0) {
                remdinMsg = serverRemdinMsg;
            }
            else if ([message isKindOfClass:[NSString class]] && [message length] > 0) {
                remdinMsg = message;
            }
            [self showModifyPasswordAlertViewWithCancel:remdinMsg];
            return;
        }
        
        if ([message isKindOfClass:[NSString class]] && [message length] > 0) {
            [self showUserORpwdAlert:message];
            return;
        }
        
        NSString *message = NSLocalizedString(@"login_fail", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if ([flag isEqualToString:@"1"]) {
        
        if (self.isSSOLogin) {
            NSString *username = [dic objectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SSOLOGINSTATE];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD];
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME_CALL_APP];
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:USERNAME_BEGIN_LOGIN];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SSOLOGINSTATE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([serverRemdinMsg length] > 0) {
            pwdWillExpire = YES;
        }
    }
    
    if ([WSEnvrionment getParamInLoginData]) {
        BOOL isSuccess = [self processRootConfigData:[sender userInfo] isLogin:NO];
        if (!isSuccess)
            return;
    }
    
    if (pwdWillExpire) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:serverRemdinMsg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [self performSelector:@selector(willProgessLoginData) withObject:nil afterDelay:1.5f];
    }
    else {
        [self progressLoginData];
    }
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//其它登录相关方法
#pragma mark - SSO登陆登陆按键响应方法
- (void)ssoLoginBtnClick:(id)sender {
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"121212122121" forKey:SSOCODE];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [self.view endEditing:YES];
//    self.username.text = @"";
//    self.passwd.text = @"";
//    [self.rememberBtn setSelected:NO];
//    self.isSSOLogin = YES;
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.tag = 9999;
//    [self loginStart:button];
//    return;
    
    [self.rememberBtn setSelected:NO];

    WinSSOLoginJSBridgeViewController *vc = [[WinSSOLoginJSBridgeViewController alloc] init];
    vc.externalOpenUrl = [NSString stringWithFormat:@"%@modules/h5/sso.html", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]];

    __weak __typeof__(self) weakSelf = self;
    vc.successBlock = ^(NSString *successCode) {

        __strong __typeof__(weakSelf) strongSelf = weakSelf;

        LogInfo(@"WSLoginViewController SSOLogin-successBlock successCode = %@", successCode);

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSOLOGINSTATE];
        [[NSUserDefaults standardUserDefaults] setObject:successCode forKey:SSOCODE];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [strongSelf.view endEditing:YES];
        strongSelf.username.text = @"";
        strongSelf.passwd.text = @"";
        [strongSelf.rememberBtn setSelected:NO];
        strongSelf.isSSOLogin = YES;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 9999;
        [strongSelf loginStart:button];
    };

    vc.title = NSLocalizedString(@"win_sso_login_button_title", nil);
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 取消登录方法
- (void)cancelLogin:(id)sender {
    
    [self stopIndicator];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERNAME_CALL_APP];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_CALL_APP];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:SSOLOGINSTATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    isRequestingLogIn = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTCANCEL object:nil];
}

#pragma mark - 清除最后登录用户缓存方法
- (void)clearLastUserCacheData {
    
    WSLoginDataProcessService *processService = [[WSLoginDataProcessService alloc] init];
    [WSLoginDataProcessService clearBaseDatas];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN]; //清除登录数据版本号缓存
    [FileManager removeDefaultsByKey:CACHE_DATA_VERSION_KEY_BYUSER(userName)];
    
    NSString *loginDataFilePath = [[FileManager Documents] stringByAppendingPathComponent:LOGIN_DATA_FILENAME_BYUSER(userName)];//清除登录数据文件
    [FileManager deleFileWithName:loginDataFilePath];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"preTimems"];
    [processService deleteAllRequestedStoreDataFlag];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AUTOMATIC_DEPARTURE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_UPDATE_LOCATION_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//进程执行
#pragma mark - 第一次登陆完成后 再次登录执行方法
- (void)postRequestOnLogin:(NSString *)gValue url:(NSString *)url {
    
    LogInfo(@"WSLoginViewController postRequestOnLogin 1 %@", [self getSSOLoginStateText]);
    
    NSDictionary *checkDictonary = [[WSLocationManager getInstance] checkLoginGps:gValue];
    NSNumber *allowToLogin = [checkDictonary objectForKey:@"allowToLogin"];
    id remind = [checkDictonary objectForKey:@"remindMsg"];
    NSString *message = nil;
    NSString *title = nil;
    NSString *cancelButtonTitle = nil;
    if (remind &&  [remind isKindOfClass:[NSDictionary class]]) {
        
        message = [remind objectForKey:@"message"];
        title = [remind objectForKey:@"title"];
        cancelButtonTitle = [remind objectForKey:@"cancelButtonTitle"];
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
        [alert setCancelButtonWithTitle:cancelButtonTitle block:nil];
        [alert show];
    }
    
    LogInfo(@"WSLoginViewController postRequestOnLogin 2 %@", [self getSSOLoginStateText]);
    if ([allowToLogin isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        
        LogInfo(@"WSLoginViewController postRequestOnLogin 3 %@", [self getSSOLoginStateText]);
        
        NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
        if ([isOfflineLanding isEqualToString:@"1"] || [isOfflineLanding isEqualToString:@"2"]) {
            
            WSOffLineUploadTable *l_leaveStore = [WSOffLineUploadTable sharedTable];
            NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
            if (pending > 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self jumpToManualUploadController];
                return;
            }
        }
        
        LogInfo(@"WSLoginViewController loginStart 4 %@", [self getSSOLoginStateText]);
        if (self.isSSOLogin) {
                    
            LogInfo(@"WSLoginViewController loginStart 5 %@", [self getSSOLoginStateText]);
            
            NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
            //已经登陆过
            if ([ssoLoginState isEqualToString:@"1"]) {
                NSString *ssoName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
                [[WSRequestHelper shareInstance] postRequestOnLoginWithSSOUserName:ssoName notifyName:LOGIN_NOTIFY URL:url progress:nil];
            }
            //未登陆过
            else {
                NSString *ssoCode = [[NSUserDefaults standardUserDefaults] objectForKey:SSOCODE];
                [[WSRequestHelper shareInstance] postRequestOnLoginWithSSOUserCode:ssoCode notifyName:LOGIN_NOTIFY URL:url progress:nil];
            }
            return;
        }
        
        LogInfo(@"WSLoginViewController loginStart 6 self.isSSOLogi = %d", self.isSSOLogin);
        BOOL isLoginState = [self checkUserNameAndPsw];
        if (!isLoginState) {
            return;
        }
        
        [[WSRequestHelper shareInstance] postRequestOnLogin:[self getUserName] passWd:[self getUserPassword] notifyName:LOGIN_NOTIFY URL:url progress:^(CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger totalProgress = WSLoginProgressRequestConfig + progress * (WSLoginProgressRequestLogin - WSLoginProgressRequestConfig);
                [self setProgress:totalProgress];
            });
        }];
    }
    else {
        [self cancelLogin:nil];
    }
}

#pragma mark - 处理根配置数据方法
- (BOOL)processRootConfigData:(NSDictionary *)data isLogin:(BOOL)isLogin {
    
    NSString *info = [data objectForKey:DATAS];
    NSError *error = [data objectForKey:ERROR];
    NSDictionary *dic = [info objectFromJSONString];
    if (!isLogin) {
        dic = [dic objectForKey:LOGIN_CONFIG_PARAMS];
    }
    
    if (error) {
        if ([self showPromptWithError:error]) {
            return NO;
        }
    }
    
    id numServerTime = [dic objectForKey:@"servertime"];
    BOOL isNum = NO;
    if ([numServerTime isKindOfClass:[NSNumber class]]) {
        isNum = YES;
    }
    else if ([numServerTime isKindOfClass:[NSString class]]) {
        isNum = [numServerTime isPureNumber];
    }
    
    if (info == nil || error != nil || !isNum) {
        [self cancelLogin:nil];
        [self showAlert:[error ws_localizedDescription]];
        return NO;
    }
    
    [WSRootConfigDataProcessService processRootConfigData:dic isRememberBtnSelected:self.rememberBtn.selected];
    [self saveUserPwd];
    [[WSConfigObject getInstance] initializationWithDictionary:dic];
    
    if (isLogin) {
        [self startLogin];
    }
    
    return YES;
}

#pragma mark - 处理登录数据方法
- (void)progressLoginData {

    BOOL swipe_password_is_right = [[[NSUserDefaults standardUserDefaults] objectForKey:SWIPE_PASSWORD_IS_RIGHT] boolValue];
    if (!swipe_password_is_right) {
        
        NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
        if ([ssoLoginState isEqualToString:@"1"]) {
            
            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
            NSString *lastUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
            lastUserName = [[lastUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            if (lastUserName && [lastUserName length] > 0 && ![lastUserName isEqualToString:userName]) {
                LogInfo(@"与上次登录账户不一致，清除数据。last:%@, current:%@", lastUserName, userName);
                [self clearLastUserCacheData];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_CALL_APP];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_LAST_LOGIN];
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME_LAST_LOGIN];
        }
        else {
            
            NSString *lastUserName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
            lastUserName = [[lastUserName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
            NSString *currentUserName = [self getUserNameFromTextField];
            currentUserName = [currentUserName lowercaseString];
            if (lastUserName && [lastUserName length] > 0 && ![lastUserName isEqualToString:currentUserName]) {
                LogInfo(@"与上次登录账户不一致，清除数据。last:%@, current:%@", lastUserName, currentUserName);
                [self clearLastUserCacheData];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:USERNAME_CALL_APP];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwd.text forKey:PASSWORD_CALL_APP];
            [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:USERNAME_LAST_LOGIN];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwd.text forKey:PASSWORD_LAST_LOGIN];
        }
    }
    
    NSNumber *number = [self.userInfo objectForKey:LOGIN_DATA_IS_FROMCACHE];
    BOOL isLoginDataFromCache = number ? [number boolValue] : NO;
    
    __weak typeof (self) weakSelf = self;
    
    NSString *userName = [self getUserName];
    NSString *password = [self getUserPassword];
    if (self.isSSOLogin) {
        userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
        password = @"";
    }
    [self.processService processLoginDataWithQueue:self.dic userName:userName password:password isFromCache:isLoginDataFromCache isOfflineLogin:NO
                                          complete:^(BOOL isSuccess) {
        if (isSuccess) {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_IN_OFFLINE_LOGIN];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSUCCESS object:nil];
        }
        else {
            [WSAppData removeAll];
            [weakSelf cancelLogin:nil];
            [weakSelf showAlert:[self.dic objectForKey:@"msg"]];
        }
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    }];
    
    if (self.isSSOLogin) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    }
    else {
        [self setProgress:WSLoginProgressProcessData];
        self.processService.progressBlock = ^(NSInteger progress) {
            NSInteger totalProgress = WSLoginProgressProcessData + progress / 100.0 * (WSLoginProgressSuccess - WSLoginProgressProcessData);
            [weakSelf setProgress:totalProgress];
        };
    }
}

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//UI部分
#pragma mark - 设置子视图方法
- (void)setupViews {
    
    [self dispearKeyboard];
    [self.view removeAllSubviews];
    
    if ([self isOpenNewLoginView]) {
        [self createBgImageView];
        [self createLogoView];
        [self createHotlinePhoneView];
        [self createEffectView];
        [self createLoginInteractiveRegionView];
        return;
    }
    
    [self otherSetupViews];
}

#pragma mark - 清除键盘方法
- (void)dispearKeyboard {
    
    for (int i = 0; i < [self.textFields count]; i++) {
        UITextField *text = [self.textFields objectAtIndex:i];
        if ([text respondsToSelector:@selector(resignFirstResponder)]) {
            [text resignFirstResponder];
        }
    }
}

#pragma mark - 判断是否开启新视图方法
- (BOOL)isOpenNewLoginView {
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *openNewLoginView = [plistDic objectForKey:@"OpenNewLoginView"];
    BOOL configFileCheck = ([openNewLoginView isEqualToString:@"1"] ? YES : NO);
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    
    BOOL projectCheck = ([projectName isEqualToString:@"UnileverMobileChef"] || [projectName isEqualToString:@"HWDJIOS"]) ? NO : YES;
    return (configFileCheck && INTERFACE_IS_PHONE && projectCheck);
}

#pragma mark - 创建背景视图方法
- (void)createBgImageView {
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.backgroundColor = [UIColor clearColor];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.image = [UIImage scaledImageForName:@"login_bg" ofType:@"png"];
    [self.view addSubview:bgImageView];
    self.bgImageView = bgImageView;
}

#pragma mark - 创建logo视图方法
- (void)createLogoView {
    
    UIColor *textColor = [UIColor colorForKey:@"LoginViewTextColor"];
    textColor = (textColor ? textColor : [UIColor colorWithRed:57.0f/255.0f green:131.0f/255.0f blue:248.0f/255.0f alpha:1.0f]);
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.image = [UIImage scaledImageForName:@"appname" ofType:@"png"];
    
    UILabel *appTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    appTypeLabel.backgroundColor = [UIColor clearColor];
    appTypeLabel.font = [UIFont systemFontOfSize:(UI_Login_Font + 10.0f)];
    appTypeLabel.textAlignment = NSTextAlignmentCenter;
    appTypeLabel.textColor = textColor;
    appTypeLabel.numberOfLines = 0;
    appTypeLabel.text = [WSPlistHelper getApppPackageType];
    
    CGFloat x = (CGRectGetWidth(self.view.frame) - logoImageView.image.size.width) / 2;
    CGFloat y = (self.isShowOrgCode) ? (CGRectGetHeight(self.view.frame) * 0.1) : ((CGRectGetHeight(self.view.frame) * 0.1) + 5.0f);
    CGFloat w = logoImageView.image.size.width;
    CGFloat h = logoImageView.image.size.height;
    logoImageView.frame = CGRectMake(x, y, w, h);
    
    CGFloat drawMaxWidth = CGRectGetWidth(logoImageView.frame);
    CGRect appTypeLabelFrame = CGRectZero;
    if(appTypeLabel.text.length > 0)
    {
        CGSize textSize = [appTypeLabel.text ws_sizeWithFont:appTypeLabel.font constrainedToWidth:drawMaxWidth];
        CGFloat x = (drawMaxWidth - textSize.width) / 2;
        CGFloat y = 0.0f;
        CGFloat w = textSize.width;
        CGFloat h = textSize.height;
        appTypeLabelFrame = CGRectMake(x, y, w, h);
    }
    appTypeLabel.frame = appTypeLabelFrame;
    
    [logoImageView addSubview:appTypeLabel];
    [self.view addSubview:logoImageView];
    self.sysNameLogo = logoImageView;
}

#pragma mark - 创建热线视图方法
- (void)createHotlinePhoneView {
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *winchannelHotline = [plistDic objectForKey:@"Hotline"];
    if ([winchannelHotline length] <= 0) {
        return;
    }
    
    CGFloat x = 15.0f;
    CGFloat y = CGRectGetHeight(self.view.frame) - 44.0f;
    CGFloat w = w = CGRectGetWidth(self.view.frame) - 30.0f;
    CGFloat h = 44.0f;
    UIView *hotlineView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    hotlineView.backgroundColor = [UIColor clearColor];
    
    UIColor *textColor = [UIColor colorForKey:@"LoginViewHotlineTextColor"];
    textColor = (textColor ? textColor : [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f]);
    
    CGFloat drawmaxWidth = CGRectGetWidth(hotlineView.frame);
    CGFloat drawMaxHeight = CGRectGetHeight(hotlineView.frame);
    
    UILabel *hotlineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hotlineLabel.backgroundColor = [UIColor clearColor];
    hotlineLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
    hotlineLabel.textColor = textColor;
    hotlineLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"service_hotline", nil)];
    hotlineLabel.textAlignment = NSTextAlignmentLeft;
    
    UIButton *hotlineTelephoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hotlineTelephoneButton.backgroundColor = [UIColor clearColor];
    hotlineTelephoneButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
    hotlineTelephoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    NSString *hotlineStr = [WSEnvrionment getHotline];
    NSMutableAttributedString *contont = [[NSMutableAttributedString alloc] initWithString:hotlineStr];
    NSRange contentRange = {0, hotlineStr.length};
    [contont addAttribute:NSForegroundColorAttributeName value:textColor range:contentRange];
    [contont addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [hotlineTelephoneButton setAttributedTitle:contont forState:UIControlStateNormal];
    [hotlineTelephoneButton addTarget:self action:@selector(hotLineClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize titleSize = [hotlineLabel.text ws_sizeWithFont:hotlineLabel.font constrainedToWidth:drawmaxWidth];
    CGSize phoneSize = [hotlineTelephoneButton.currentAttributedTitle.string ws_sizeWithFont:hotlineTelephoneButton.titleLabel.font constrainedToWidth:drawmaxWidth];
    CGFloat maxWidth = titleSize.width + 10.0f + phoneSize.width;
    CGFloat maxHeight = (titleSize.height > phoneSize.height) ? titleSize.height : phoneSize.height;
    
    x = (drawmaxWidth - maxWidth) / 2;
    y = (drawMaxHeight - maxHeight) / 2;
    w = titleSize.width;
    h = titleSize.height;
    hotlineLabel.frame = CGRectMake(x, y, w, h);
    
    x = CGRectGetMaxX(hotlineLabel.frame) + 10.0f;
    y = (drawMaxHeight - maxHeight) / 2;
    w = phoneSize.width;
    h = phoneSize.height;
    hotlineTelephoneButton.frame = CGRectMake(x, y, w, h);
    
    [hotlineView addSubview:hotlineLabel];
    [hotlineView addSubview:hotlineTelephoneButton];
    [self.view addSubview:hotlineView];
    self.hotlineView = hotlineView;
}

#pragma mark - 创建效果视图
- (void)createEffectView {
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.view.bounds;
    effectView.alpha = 0.9f;
    effectView.hidden = YES;
    [self.view addSubview:effectView];
    self.effectView = effectView;
}

#pragma mark - 创建登录活动区视图
- (void)createLoginInteractiveRegionView {
    
    [self.textFields removeAllObjects];
    self.textFields = [[NSMutableArray alloc] initWithCapacity:2];
    
    NSInteger countdownTime = 0;
    NSString *countdownTimeString = [WSEnvrionment getLoginCountdownTime];
    if ([countdownTimeString length] > 0) {
        countdownTime = [countdownTimeString integerValue];
    }
    CGFloat interactiveRegionSpace = 15.0f;
    CGFloat elementFrameSpace = 22.0f;
    CGFloat elementStartSpace = 5.0f;
    CGFloat textFiledCount = 2;
    CGFloat textFiledDrawHeight = 50.0f;
    CGFloat loginButtonDrawHeight = 44.0f;
    CGFloat offHeight = 0.0f;
    CGFloat interactiveRegionElementFont = UI_Login_Font;
    
    UIColor *textFieldBgColor = [UIColor colorForKey:@"LoginViewTextFieldBgColor"];
    textFieldBgColor = (textFieldBgColor ? textFieldBgColor : [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]);
    UIColor *textFieldTextcolor = [UIColor colorForKey:@"LoginViewTextFieldTextColor"];
    textFieldTextcolor = (textFieldTextcolor ? textFieldTextcolor : [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f]);
    UIColor *textFieldLineColor = [UIColor colorForKey:@"LoginViewTextFieldLineColor"];
    textFieldLineColor = (textFieldLineColor ? textFieldLineColor : [UIColor colorWithRed:232.0f/255.0f green:232.0f/255.0f blue:232.0f/255.0f alpha:1.0f]);
    UIColor *textColor = [UIColor colorForKey:@"LoginViewTextColor"];
    textColor = (textColor ? textColor : [UIColor colorWithRed:57.0f/255.0f green:131.0f/255.0f blue:248.0f/255.0f alpha:1.0f]);
    UIColor *buttonBgColor = [UIColor colorForKey:@"LoginViewLoginBtnBackgroundColor"];
    buttonBgColor = (buttonBgColor ? buttonBgColor : [UIColor colorWithRed:57.0f/255.0f green:131.0f/255.0f blue:248.0f/255.0f alpha:1.0f]);
    UIColor *buttonTextColor = [UIColor colorForKey:@"LoginViewLoginBtnTextColor"];
    buttonTextColor = (buttonTextColor ? buttonTextColor : [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]);
    UIColor *warningTitltColor = [UIColor colorForKey:@"LoginViewWarningTextColor"];
    warningTitltColor = (warningTitltColor ? warningTitltColor : [UIColor colorWithRed:254.0f/255.0f green:73.0f/255.0f blue:60.0f/255.0f alpha:1.0f]);
    
    UIImage *remeberPwdImage = [UIImage scaledImageForName:@"remeber_pwd_unselected" ofType:@"png"];
    NSString *remeberPwdStr = NSLocalizedString(@"remember_my_info_label", nil);
    UIFont *remeberPwdFont = [UIFont systemFontOfSize:interactiveRegionElementFont];
    CGSize remeberPwdStrSize = [remeberPwdStr ws_sizeWithFont:remeberPwdFont constrainedToWidth:500.0f];
    CGFloat remeberPwdMaxHeight = (remeberPwdImage.size.height > remeberPwdStrSize.height) ? remeberPwdImage.size.height : remeberPwdStrSize.height;
    
    NSString *warningStr = NSLocalizedString(@"login_warning", nil);
    UIFont *warningFont = [UIFont systemFontOfSize:interactiveRegionElementFont];
    CGFloat warningWidth = CGRectGetWidth(self.view.frame) - (interactiveRegionSpace * 2) - (elementFrameSpace * 2);
    CGSize warningStrSize = CGSizeZero;
    if(warningStr.length > 0) {
        warningStrSize = [warningStr ws_sizeWithFont:warningFont constrainedToWidth:warningWidth];
    }
    
    NSString *aboutStr = NSLocalizedString(@"about", nil);
    UIFont *aboutFont = [UIFont systemFontOfSize:interactiveRegionElementFont];
    CGSize aboutStrSize = [aboutStr ws_sizeWithFont:aboutFont constrainedToWidth:200.0f];
    
    CGFloat maxHeight = (textFiledCount * textFiledDrawHeight) + interactiveRegionSpace + remeberPwdMaxHeight + (interactiveRegionSpace * 2);
    maxHeight += loginButtonDrawHeight + warningStrSize.height + interactiveRegionSpace + aboutStrSize.height + interactiveRegionSpace;
    maxHeight += loginButtonDrawHeight + 20.0f;//sso登陆按键+说明标题
    
    //登陆交互区域背景框
    CGFloat x = interactiveRegionSpace;
    CGFloat y = (self.isShowOrgCode) ? (CGRectGetHeight(self.view.frame) * 0.3) : ((CGRectGetHeight(self.view.frame) * 0.3) + 20.0f);
    CGFloat w = CGRectGetWidth(self.view.frame) - (interactiveRegionSpace * 2);
    CGFloat h = maxHeight;
    UIView *interactiveRegionView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    interactiveRegionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:interactiveRegionView];
    self.loginBoxView = interactiveRegionView;
    
    //登陆交互区域背景框的装饰视图
    UIView *interactiveRegionAlphaView = [[UIView alloc] initWithFrame:interactiveRegionView.bounds];
    interactiveRegionAlphaView.backgroundColor = textFieldBgColor;
    interactiveRegionAlphaView.alpha = 0.5f;
    interactiveRegionAlphaView.layer.cornerRadius = 8.0f;
    interactiveRegionAlphaView.layer.masksToBounds = YES;
    interactiveRegionAlphaView.clipsToBounds = YES;
    [interactiveRegionView addSubview:interactiveRegionAlphaView];
    
    //登陆交互区输入框视图
    for (int i = 0; i < textFiledCount; ++i) {
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = textFieldTextcolor;
        textField.font = [UIFont systemFontOfSize:interactiveRegionElementFont];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textAlignment = NSTextAlignmentLeft;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingChanged];
        
        UIView *borderLineView = [[UIView alloc] initWithFrame:CGRectZero];
        borderLineView.backgroundColor = textFieldLineColor;
        
        //用户名
        if (i == 0) {
            
            iconImageView.image = [UIImage scaledImageForName:@"usernameIcon" ofType:@"png"];;
            textField.placeholder = NSLocalizedString(@"user_name_edit_hint", nil);
            
            NSString *usernameForOrg = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_FOR_ORG];
            if ([usernameForOrg length] > 0) {
                textField.text = usernameForOrg;
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERNAME_FOR_ORG];
            }
            else {
                textField.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
            }
            NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
            if ([ssoLoginState isEqualToString:@"1"]) {
                textField.text = @"";
            }
            self.username = textField;
        }
        //密码
        else if (i == 1) {
            
            iconImageView.image = [UIImage scaledImageForName:@"passwordIcon" ofType:@"png"];
            textField.placeholder = NSLocalizedString(@"password_edit_hint", nil);
            textField.secureTextEntry = YES;
            textField.clearsOnBeginEditing = NO;
            
            NSString *pwdForOrg = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_FOR_ORG];
            if ([pwdForOrg length] > 0) {
                textField.text = pwdForOrg;
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_FOR_ORG];
            }
            else {
                textField.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
            }
            NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
            if ([ssoLoginState isEqualToString:@"1"]) {
                textField.text = @"";
            }
            self.passwd = textField;
        }

        CGFloat x = elementFrameSpace;
        CGFloat y = (i * textFiledDrawHeight);
        CGFloat w = CGRectGetWidth(interactiveRegionView.frame) - (elementFrameSpace * 2);
        CGFloat h = textFiledDrawHeight;
        UIView *elementBgView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        elementBgView.backgroundColor = [UIColor clearColor];
        
        x = elementStartSpace;
        y = (CGRectGetHeight(elementBgView.frame) - 1.0f - iconImageView.image.size.height) / 2;
        w = iconImageView.image.size.width;
        h = iconImageView.image.size.height;
        iconImageView.frame = CGRectMake(x, y, w, h);
        
        x = CGRectGetMaxX(iconImageView.frame) + 10.0f;
        y = 0.0f;
        w = CGRectGetWidth(elementBgView.frame) - x;
        h = CGRectGetHeight(elementBgView.frame) - 1.0f;
        textField.frame = CGRectMake(x, y, w, h);
        
        x = 0.0f;
        y = CGRectGetHeight(elementBgView.frame) - 1.0f;
        w = CGRectGetWidth(elementBgView.frame);
        h = 1.0f;
        borderLineView.frame = CGRectMake(x, y, w, h);
        
        [elementBgView addSubview:iconImageView];
        [elementBgView addSubview:textField];
        [elementBgView addSubview:borderLineView];
        [interactiveRegionView addSubview:elementBgView];
        
        [self.textFields addObject:textField];
        offHeight = CGRectGetMaxY(elementBgView.frame);
    }
    offHeight += interactiveRegionSpace;
    
    //记住用户名选项按键
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconButton.backgroundColor = [UIColor clearColor];
    [iconButton setImage:[UIImage scaledImageForName:@"remeber_pwd_unselected" ofType:@"png"] forState:UIControlStateNormal];
    [iconButton setImage:[UIImage scaledImageForName:@"remeber_pwd_selected" ofType:@"png"] forState:UIControlStateSelected];
    x = elementFrameSpace + elementStartSpace;
    y = offHeight + ((remeberPwdMaxHeight - remeberPwdImage.size.height) / 2);
    w = remeberPwdImage.size.width;
    h = remeberPwdImage.size.height;
    iconButton.frame = CGRectMake(x, y, w, h);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME]) {
        [iconButton setSelected:YES];
    }
    else {
        NSString *rememberName = [[NSUserDefaults standardUserDefaults] objectForKey:REMEMBER_ME_KEY];
        if ([rememberName isEqualToString:@"1"]) {
            [iconButton setSelected:YES];
        }
    }
    NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
    if ([ssoLoginState isEqualToString:@"1"]) {
        [iconButton setSelected:NO];
    }
    
    [iconButton addTarget:self action:@selector(remberUserName:) forControlEvents:UIControlEventTouchUpInside];
    [interactiveRegionView addSubview:iconButton];
    self.rememberBtn = iconButton;
    //记住用户名标题
    UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton.backgroundColor = [UIColor clearColor];
    [titleButton setTitleColor:textColor forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
    titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleButton setTitle:NSLocalizedString(@"remember_my_info_label", nil) forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(remberUserName:) forControlEvents:UIControlEventTouchUpInside];
    x = CGRectGetMaxX(iconButton.frame) + 10.0f;
    y = offHeight + ((remeberPwdMaxHeight - remeberPwdStrSize.height) / 2);
    w = remeberPwdStrSize.width;
    h = remeberPwdStrSize.height;
    titleButton.frame = CGRectMake(x, y, w, h);
    [interactiveRegionView addSubview:titleButton];
    offHeight += remeberPwdMaxHeight + (interactiveRegionSpace * 2);
    
    //登陆按键
    x = elementFrameSpace;
    y = offHeight;
    w = CGRectGetWidth(interactiveRegionView.frame) - (elementFrameSpace * 2);
    h = loginButtonDrawHeight;
    __weak typeof(self) weakself = self;
    __block JFTakeCountButton *loginButton = [JFTakeCountButton initWithCount:(int)countdownTime withTitle:NSLocalizedString(@"login_label", nil) withTitleColor:nil
                                                                withTitleFont:nil withTitleFrame:CGRectMake(x, y, w, h) withIsShowTitle:YES withBlock:^{
        if (self.passwd.text.length > 0 && [self getUserNameFromTextField].length > 0) {
            weakself.loginBtn.enabled = YES;
        }
        else {
            weakself.loginBtn.enabled = NO;
        }
        weakself.isCountingdown = NO;
    }];
    if (countdownTime == 0 && self.passwd.text.length > 0 && [self getUserNameFromTextField].length > 0) {
        loginButton.enabled = YES;
    }
    else {
        loginButton.enabled = NO;
    }
    [loginButton addTarget:self action:@selector(loginStart:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 8.0f;
    [loginButton.titleLabel setFont:[UIFont systemFontOfSize:(UI_Login_Font + 5.0f)]];
    UIImage *btnImg = [UIImage createImageWithColor:buttonBgColor];
    UIImage *btnPressImg = [UIImage createImageWithColor:[buttonBgColor colorWithAlphaComponent:0.8f]];
    [loginButton setBackgroundImage:btnImg forState:UIControlStateNormal];
    [loginButton setBackgroundImage:btnImg forState:UIControlStateDisabled];
    [loginButton setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
    [loginButton setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [loginButton setTitleColor:[buttonTextColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    [interactiveRegionView addSubview:loginButton];
    [loginButton startTakeCount];
    self.loginBtn = loginButton;
    offHeight += loginButtonDrawHeight;
    
    //提醒标签
    if (warningStr.length > 0) {
        x = elementFrameSpace;
        y = offHeight;
        w = warningStrSize.width;
        h = warningStrSize.height;
        UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        warningLabel.backgroundColor = [UIColor clearColor];
        warningLabel.font = warningFont;
        warningLabel.textAlignment = NSTextAlignmentLeft;
        warningLabel.textColor = warningTitltColor;
        warningLabel.numberOfLines = 0;
        warningLabel.text = warningStr;
        [interactiveRegionView addSubview:warningLabel];
        self.warningLabel = warningLabel;
        offHeight += CGRectGetHeight(warningLabel.frame);
    }
    offHeight += interactiveRegionSpace;
    
    //关于按键
    x = CGRectGetWidth(interactiveRegionView.frame) - elementFrameSpace - elementStartSpace - aboutStrSize.width;
    y = offHeight;
    w = aboutStrSize.width;
    h = aboutStrSize.height;
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutButton.frame = CGRectMake(x, y, w, h);
    aboutButton.backgroundColor = [UIColor clearColor];
    aboutButton.titleLabel.font = aboutFont;
    [aboutButton setTitle:aboutStr forState:UIControlStateNormal];
    [aboutButton setTitleColor:textColor forState:UIControlStateNormal];
    aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [aboutButton addTarget:self action:@selector(aboutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [interactiveRegionView addSubview:aboutButton];
    self.aboutButton = aboutButton;
    offHeight += (CGRectGetHeight(aboutButton.frame) + interactiveRegionSpace);
    
    //找回密码按键
    if (![WSEnvrionment getHideRetrievePassword]) {
        NSString *retrieveStr = NSLocalizedString(@"password_retake", nil);
        UIFont *retrieveFont = [UIFont systemFontOfSize:interactiveRegionElementFont];
        CGSize retrieveStrSize = [retrieveStr ws_sizeWithFont:retrieveFont constrainedToWidth:200.0f];
        
        x = elementFrameSpace + elementStartSpace;
        y = CGRectGetMinY(self.aboutButton.frame);;
        w = retrieveStrSize.width;
        h = retrieveStrSize.height;
        UIButton *retrieveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        retrieveButton.frame = CGRectMake(x, y, w, h);
        retrieveButton.backgroundColor = [UIColor clearColor];
        retrieveButton.titleLabel.font = retrieveFont;
        [retrieveButton setTitle:retrieveStr forState:UIControlStateNormal];
        [retrieveButton setTitleColor:textColor forState:UIControlStateNormal];
        retrieveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [retrieveButton addTarget:self action:@selector(retrievePassword:) forControlEvents:UIControlEventTouchUpInside];
        [interactiveRegionView addSubview:retrieveButton];
        self.changePSWBtn = retrieveButton;
    }
    
    //sso登陆按键
    x = CGRectGetMinX(self.loginBtn.frame);
    y = offHeight;
    w = CGRectGetWidth(self.loginBtn.frame);
    h = CGRectGetHeight(self.loginBtn.frame);
    UIButton *ssoLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [ssoLoginBtn addTarget:self action:@selector(ssoLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    ssoLoginBtn.layer.masksToBounds = YES;
    ssoLoginBtn.layer.cornerRadius = 8.0f;
    ssoLoginBtn.titleLabel.font = [UIFont systemFontOfSize:(UI_Login_Font + 5.0f)];
    [ssoLoginBtn setTitle:NSLocalizedString(@"win_sso_login_button_title", nil) forState:UIControlStateNormal];
    [ssoLoginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ssoLoginBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    UIImage *ssoLoginBtnImg = [UIImage createImageWithColor:[UIColor blackColor]];
    UIImage *ssoLoginBtnPressImg = [UIImage createImageWithColor:[[UIColor blackColor] colorWithAlphaComponent:0.8f]];
    [ssoLoginBtn setBackgroundImage:ssoLoginBtnImg forState:UIControlStateNormal];
    [ssoLoginBtn setBackgroundImage:ssoLoginBtnImg forState:UIControlStateDisabled];
    [ssoLoginBtn setBackgroundImage:ssoLoginBtnPressImg forState:UIControlStateHighlighted];
    [interactiveRegionView addSubview:ssoLoginBtn];
    self.ssoLoginBtn = ssoLoginBtn;
    
    //按键标签说明
    x = CGRectGetMinX(self.ssoLoginBtn.frame);
    y = CGRectGetMaxY(self.ssoLoginBtn.frame);;
    w = CGRectGetWidth(self.loginBtn.frame);
    h = 20.0f;
    UILabel *loginWarningLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    loginWarningLabel.backgroundColor = [UIColor clearColor];
    loginWarningLabel.font = [UIFont systemFontOfSize:14.0f];
    loginWarningLabel.textAlignment = NSTextAlignmentCenter;
    loginWarningLabel.textColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    loginWarningLabel.text = NSLocalizedString(@"win_sso_login_info_title", nil);
    [interactiveRegionView addSubview:loginWarningLabel];
}

#pragma mark - 启动等待圈(登陆按键覆盖层)
- (void)startIndicator {
    
    [self.loginBtn setTitle:nil forState:UIControlStateNormal];
    [self.view setUserInteractionEnabled:NO];
    CGRect indicatorFrame = CGRectMake((self.loginBtn.size.width - self.indicatorView.size.width ) / 2, (self.loginBtn.size.height - self.indicatorView.size.height ) / 2,
                                       self.indicatorView.size.width, self.indicatorView.size.height);
    [self.indicatorView setFrame:indicatorFrame];
    [self.indicatorView setHidden:NO];
    [self.indicatorView startAnimating];
}

#pragma mark - 停止等待圈(登陆按键覆盖层)
- (void)stopIndicator {
    
    [self.indicatorView stopAnimating];
    [self.indicatorView setHidden:YES];
    [self.view setUserInteractionEnabled:YES];
    [self.loginBtn setTitle:NSLocalizedString(@"login_label",nil) forState:UIControlStateNormal];
}

#pragma mark - 键盘显示/消失通知监听方法
- (void)keyboardHideOrShow:(NSNotification *)notification {
    
    NSString *notificationName = notification.name;
    NSDictionary *keyboardInfo = notification.userInfo;
    CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.currentKeyboardHeight = keyboardFrame.size.height;
    
    if ([notificationName isEqualToString:UIKeyboardWillHideNotification]) {
        [self animationsOnTextField:NO];
    }
    else {
        [self animationsOnTextField:YES];
    }
}

#pragma mark - 输入框变化后视图动画方法
- (void)animationsOnTextField:(BOOL)up {
    
    CGRect logoRect = [self getLogoRect];
    int y[2] = {0, -logoRect.size.height};
    
    [UIView beginAnimations:@"showkeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4f];
    
    if ([self isOpenNewLoginView]) {
        
        CGRect loginInputViewRect = self.loginBoxView.frame;
        if(up) {
            CGFloat minOffsetY = 60;
            CGFloat offsetY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(loginInputViewRect) - self.currentKeyboardHeight - 40.0f;
            loginInputViewRect.origin.y = offsetY > minOffsetY ? offsetY : minOffsetY;
        }
        else {
            loginInputViewRect.origin.y = (self.isShowOrgCode) ? (CGRectGetHeight(self.view.frame) * 0.3) : ((CGRectGetHeight(self.view.frame) * 0.3) + 20.0f);
        }
        
        self.loginBoxView.frame = loginInputViewRect;
        self.effectView.hidden = (up) ? NO : YES;
    }
    else {
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = y[up];
        [self.view setFrame:newFrame];
    }
    
    [UIView commitAnimations];
}

#pragma mark - 设置logo矩形方法
- (CGRect)getLogoRect {
    
    CGFloat logoYOffset = k_LogoYOffSet;
    CGFloat logoHeight = k_LogoImageHeight;
    UIImage *image = self.sysNameLogo.image;
    CGFloat imageWidth = k_LogoImageHeight / image.size.height  * image.size.width;
    CGRect rect = CGRectMake((self.view.bounds.size.width - imageWidth)/2, logoYOffset, imageWidth , logoHeight);
    return rect;
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//代理协议
#pragma mark - 实现textFieldShouldBeginEditing:代理协议
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.shouldBeginTextField = textField;
    return YES;
}

#pragma mark - 实现textFieldShouldReturn:代理协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 实现textFieldShouldClear:代理协议
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    return YES;
}

#pragma mark - 实现textFieldDidBeginEditing:代理协议
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [textField performSelector:@selector(selectAll:) withObject:nil afterDelay:0.0];
}

#pragma mark - 实现textField:shouldChangeCharactersInRange:replacementString:代理协议
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.passwd) {
        NSString *content = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (content != nil && [content length] > KWSLOGINMAXPASSWORDLEN) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 实现textFieldDidEndEditing:代理协议
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark - 输入框变化监听方法
- (void)textWatcher:(id)sender {
    
    if (self.isCountingdown) {
        return;
    }
    
    BOOL isInput = YES;
    for (int i = 0; i < [self.textFields count]; i++) {
        
        UITextField *textfield = [self.textFields objectAtIndex:i];
        if (self.orgCodeTextField && textfield == self.orgCodeTextField) {
            continue;
        }
        
        if ([textfield.text isEqualToString:@""] || [textfield.text length] == 0) {
            isInput = NO;
            break;
        }
    }
    
    self.loginBtn.enabled = isInput;
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//其它
#pragma mark - 创建引导页视图方法
- (void)createGuidanceViewController {
    
    NSUserDefaults *firstLauchDefaults = [NSUserDefaults standardUserDefaults];
    BOOL firstLauch = [firstLauchDefaults boolForKey:@"AppFirstLaunch"];
    NSUserDefaults *firstLoginDefaults = [NSUserDefaults standardUserDefaults];
    BOOL everLogin = [firstLoginDefaults boolForKey:@"everLogin"];
    NSString *welcomePageOption = [WSPlistHelper valueForKey:WELCOME_PAGE_OPTION withPlistName:kConfilgFileName];
    
    BOOL isHWDJIOSHaiwai = NO;
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    if ([projectName isEqualToString:@"HWDJIOS"] && ![[UIDevice getPreferredLanguage] isEqualToString:@"zh_CN"]) {
        isHWDJIOSHaiwai = YES;
    }
    
    if (welcomePageOption &&[welcomePageOption isEqualToString:@"1"] && firstLauch && !everLogin && !isHWDJIOSHaiwai) {
        WSAppGuidanceViewController *guidanceVC = [[WSAppGuidanceViewController alloc] init];
        guidanceVC.view.backgroundColor = [UIColor whiteColor];
        [self addChildViewController:guidanceVC];
        [self.view addSubview:guidanceVC.view];
    }
}

#pragma mark - 从输入框获取用户名称方法
- (NSString *)getUserNameFromTextField {
    
    NSString *userName = self.username.text;
    if (userName.length > 0) {
        return [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    return userName;
}

- (NSString *)getUserName {
    
    BOOL swipe_password_is_right = [[[NSUserDefaults standardUserDefaults] objectForKey:SWIPE_PASSWORD_IS_RIGHT] boolValue];
    if (swipe_password_is_right) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
    }
    else {
        return [self getUserNameFromTextField];
    }
}

- (NSString *)getUserPassword {
    
    BOOL swipe_password_is_right = [[[NSUserDefaults standardUserDefaults] objectForKey:SWIPE_PASSWORD_IS_RIGHT] boolValue];
    if (swipe_password_is_right) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_LAST_LOGIN];
    }
    else {
        return self.passwd.text;
    }
}

- (void)saveUserName {
    
    if (self.rememberBtn.selected) {
        [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:USERNAME];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    }

    BOOL swipe_password_is_right = [[[NSUserDefaults standardUserDefaults] objectForKey:SWIPE_PASSWORD_IS_RIGHT] boolValue];
    if (!swipe_password_is_right) {
        [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:USERNAME_BEGIN_LOGIN];
    }
}

- (void)saveUserPwd {
    
    NSString *rememberPwd = [[NSUserDefaults standardUserDefaults] objectForKey:REMEMBER_PASSWORD];
    if ([rememberPwd isEqualToString:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.passwd.text forKey:PASSWORD];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)remeberUserPwd {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *remberUserPwd = [defaults valueForKey:REMEMBER_PASSWORD];
    if ([remberUserPwd isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

- (void)showUserPwd {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD] && self.rememberBtn.selected) {
        self.passwd.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
    }
    else {
        self.passwd.text = @"";
    }
}

- (void)showModifyPwdOrNot {
    
    self.changePSWBtn.hidden = NO;
    NSString *showModify =[[NSUserDefaults standardUserDefaults] objectForKey:IS_LOGIN_PASSWORD];
    if ([showModify isEqualToString:@"0"]) {
        self.changePSWBtn.hidden = YES;
    }
}

- (BOOL)checkUserNameAndPsw {
    
    BOOL isOK = YES;
    NSString *user_name = [self getUserName];
    NSString *psw = [self getUserPassword];
    if (user_name == nil || [@"" isEqualToString:user_name] || [@" " isEqualToString:user_name] || psw == nil || [@"" isEqualToString:psw] || [@" " isEqualToString:psw]) {
        isOK = NO;
    }
    return isOK;
}

- (void)showAlert:(NSString *)message {
    
    [self stopIndicator];
    
    NSString *OKString = NSLocalizedString(@"confirm",nil);
    NSString *TryString = NSLocalizedString(@"retry",nil);
    NSString *loginfailString = message ?: NSLocalizedString(@"login_fail",nil);
    NSString *title = NSLocalizedString(@"js_alert_title", nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:loginfailString];
    [alert setCancelButtonWithTitle:OKString block:nil];
    [alert addButtonWithTitle:TryString block:^{
        if (!isRequestingLogIn) {
            [self loginStart:nil];
        }
    }];
    [alert show];
}

- (void)showUserORpwdAlert:(NSString *)message {
    
    if (![message isKindOfClass:[NSString class]]) {
        message = @"";
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)showModifyPasswordAlertView:(NSString *)message {
    
    NSString *title = NSLocalizedString(@"js_alert_title", nil);
    NSString *OKString = NSLocalizedString(@"confirm",nil);
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
    [alert addButtonWithTitle:OKString block:^{
        [self modifyPasswd:nil];
    }];
    [alert show];
}

- (void)showModifyPasswordAlertViewWithCancel:(NSString *)message {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginRemindResponse:) name:LOGIN_REMIND_NOTIFY object:nil];
    NSString *title = NSLocalizedString(@"js_alert_title", nil);
    NSString *OKString = NSLocalizedString(@"confirm",nil);
    NSString *cancelString = NSLocalizedString(@"cancel_label",nil);
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
    [alert addButtonWithTitle:OKString block:^{
        [self modifyPasswd:nil];
    }];
    [alert addButtonWithTitle:cancelString block:^{
        [[WSRequestHelper shareInstance] postRequestOnLogin:[self getUserNameFromTextField] passWd:self.passwd.text notifyName:LOGIN_REMIND_NOTIFY URL:URL_LOGINREMIND];
    }];
    [alert show];
}

- (void)loginRemindResponse:(id)sender {
    
    self.userInfo = [sender userInfo];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    NSString *successMsg = [dic objectForKey:@"success"];
    NSInteger successMsgInt = [successMsg integerValue];
    if (successMsgInt != 1) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure",nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else {
        [self login];
    }
}

- (void)willProgessLoginData {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow animated:YES];
    [self progressLoginData];
}

- (void)fillUserIdAndPass:(NSNotification*)obj {
    
    if (!obj) {
        return;
    }
    
    if (!obj.userInfo) {
        return;
    }
    
    NSDictionary *dic = obj.userInfo;
    self.username.text = [dic objectForKey:@"userID"];
    self.passwd.text = [dic objectForKey:@"password"];
    if ([[WSAppData sharedManager].datas count] <= 0) {
        if (!isRequestingLogIn) {
            [self loginStart:nil];
        }
    }
}

- (BOOL)showPromptWithError:(NSError *)error {
    
    if (self.swipeVC) {
        [MBProgressHUD hideAllHUDsForView:self.swipeVC.view animated:YES];
    }

    if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotConnectToHost || error.code == NSURLErrorBadServerResponse) {
        
        NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];;
        NSString *buildType = [WSPlistHelper getAppBuildType];
        NSString *fileUrl = [NSString stringWithFormat:@"http://public.winsfa.com/%@/%@_%@.txt", appId, appId, buildType];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileUrl]];
        if (data) {
            
            NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([message length] == 0) {
                return NO;
            }
            
            [self cancelLogin:nil];
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message alignment:BlockAlertViewAlignmentLeft];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"disable_lable", nil) block:nil];
            [alert show];
            return YES;
        }
        else {
            LogError(@"Failed to access prompt message from %@", fileUrl);
        }
        
        return NO;
    }
    else {
        LogError(@"login error code is %ld", (long)error.code);
    }
    
    return NO;
}

- (void)jumpToManualUploadController {
    
    WSManuallyUploadViewController *con = [[WSManuallyUploadViewController alloc] init];
    con.delegate = self;
    con.autoUploadDatas = YES;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)gotoRetrievePassword {
    
    NSString *url = [self getRetrievePasswordUrl];
    [self gotoRetrievePasswordWithUrl:url];
}

- (void)gotoRetrievePasswordWithUrl:(NSString *)findPwdURL {
    
    [self dispearKeyboard];
    [self animationsOnTextField:NO];
    WSReportFormController *findPwd = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:findPwdURL] WithIsNeedCookie:NO];
    findPwd.title = NSLocalizedString(@"password_retake", nil);
    [self.navigationController pushViewController:findPwd animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (NSString *)getRetrievePasswordUrl {
    
    return [self getRetrievePasswordUrlWithServerUrl:[WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName]];
}

- (NSString *)getRetrievePasswordUrlWithServerUrl:(NSString *)serverUrl {
    
    NSString *findPwdURL = nil;
    NSString *findPasswordMjet = [WSPlistHelper valueForKey:kGET_PASSWORD_URL withPlistName:kConfilgFileName];
    if ([findPasswordMjet length] > 0) {
        findPwdURL = [NSString stringWithFormat:@"%@&nls=%@", findPasswordMjet,[UIDevice getPreferredLanguage]];
    }
    else {
        findPwdURL = [NSString stringWithFormat:@"%@%@", serverUrl, kURLretrievePassword];
    }
    
    return findPwdURL;
}

- (void)modifyPasswd:(id)sender {
    
    [self dispearKeyboard];
    [self animationsOnTextField:NO];
    
    NSString *getPasswordUrl = nil;
    NSString *getPasswordMjet = [WSPlistHelper valueForKey:kMODIFY_PASSWORD_URL withPlistName:kConfilgFileName];
    
    if ([getPasswordMjet length] > 0) {
        
        getPasswordUrl = [NSString stringWithFormat:@"%@&nls=%@", getPasswordMjet,[UIDevice getPreferredLanguage]];
        WSReportFormController *findPwd = [[WSReportFormController alloc]initWithURL:[NSURL URLWithString:getPasswordUrl]];
        findPwd.title = NSLocalizedString(@"modify_password_label", nil);
        [self.navigationController pushViewController:findPwd animated:YES];
    }
    else {
        WSModifyPasswdViewController *modifyPwdVC = [[WSModifyPasswdViewController alloc]init];
        modifyPwdVC.modifyUserName = [self getUserNameFromTextField];
        [self.navigationController pushViewController:modifyPwdVC animated:YES];
    }
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)updateSoftWare {
    
    NSString *VersionUpdateString = NSLocalizedString(@"js_alert_title", nil);
    NSString *NewVersionString = NSLocalizedString(@"update_tip", nil);
    NSString *OKString = NSLocalizedString(@"confirm", nil);
    NSString *upgradeMsg = [WSEnvrionment getUpgradeMessage];
    if ([upgradeMsg length] > 0) {
        NewVersionString  = upgradeMsg;
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:VersionUpdateString message:NewVersionString];
    [alert setCancelButtonWithTitle:OKString block:^{
        
        if (![WSEnvrionment onlyAlertWhenUpgrade]) {
            
            if (self.m_verUrl) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.m_verUrl] options:@{} completionHandler:nil];
            }
        }
    }];
    
    [alert show];
}

- (void)manualUploadBackAction {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.view withText:NSLocalizedString(@"logining_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    [[WSRequestHelper shareInstance] postRequestOnLogin:[self getUserNameFromTextField] passWd:self.passwd.text notifyName:LOGIN_NOTIFY URL:URL_LOGIN];
}

- (void)setProgress:(NSInteger)progress {
    
    NSString *loading = NSLocalizedString(@"pull_to_refresh_refreshing_label", nil);
    loading = [NSString stringWithFormat:@"%@%ld%%", loading, (long)progress];
    [self.loginBtn setTitle:loading forState:UIControlStateNormal];
    CGRect frame = CGRectMake(40, self.indicatorView.origin.y, self.indicatorView.width, self.indicatorView.height);
    [self.indicatorView setFrame:frame];
}

#pragma mark - 存储网络状态方法
- (void)saveNetworkType {
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    NSString *netType;
    switch (status) {
        case NotReachable: {
            netType = @"";
        }
            break;
        case ReachableViaWiFi: {
            netType = @"WIFI";
        }
            break;
        case ReachableViaWWAN: {
            netType = @"MOBILE";
        }
            break;
        default:
            break;
    }
    
    //[[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_NET_TYPE startTime:nil endTime:nil eventValue:netType genId:[WSStatisticsManager getGenId]];
}

#pragma mark - 存储第一次登陆信息方法
- (void)saveUserFirstLogin {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLogin"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLogin"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLogin"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLogin"];
    }
}

#pragma mark - 清除缓存方法
- (void)clearCache {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_ME_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBaseFilePath= [documentsDirectory stringByAppendingPathComponent:@"wch_DataBase.db"];
    NSString *message = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataBaseFilePath]) {
        
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:dataBaseFilePath error:&error]) {
            [[WSFMDatebase getInstance] closeDB];
            message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"清除数据库成功:", nil),documentsDirectory];
        }
        else {
            message = error.debugDescription;
        }
    }
    else {
        message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"数据库不存在:",nil),documentsDirectory];
    }
    
    LogInfo(@"%@", message);
}

#pragma mark - 重写touchesBegan:withEvent:方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.shouldBeginTextField) {
        [self.shouldBeginTextField resignFirstResponder];
    }
}

#pragma mark - 热线电话响应事件
- (void)hotLineClick {
    
    if ([[WSEnvrionment getOnlineConsultation] length] > 0) {
        
        //MSTD-7449
        NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
        if(online_Consultation.length <= 0) {
            online_Consultation = [WSEnvrionment getOnlineConsultation];
        }
        
        WSReportFormController *rfvc = [[WSReportFormController alloc] initWithURL:[NSURL URLWithString:[online_Consultation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        rfvc.title = NSLocalizedString(@"online_consult", nil);
        rfvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rfvc animated:YES];
    }
    else {
        
        WSHotLineViewController *hotLineVC = [[WSHotLineViewController alloc] init];
        self.definesPresentationContext = YES;
        hotLineVC.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        hotLineVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:hotLineVC animated:NO completion:nil];
        hotLineVC.checkChangePwd = ^(){
            [self modifyPasswd:nil];
        };
        hotLineVC.findBackPwd = ^(){
            [self retrievePassword:nil];
        };
    }
}

#pragma mark - 拒绝按键响应事件
- (void)rejectAction:(id)sender {
    
    exit(0);
}

#pragma mark - 关于按键响应事件
-(void)aboutBtnClicked {
    
    [self dispearKeyboard];
    [self animationsOnTextField:NO];
    
    self.aboutVC = [[WSAppSettingViewController alloc]init];
    [self.navigationController pushViewController:self.aboutVC animated:YES];
}

#pragma mark - 记住密码响应事件
- (void)remberUserName:(id)sender {
    
    if (self.rememberBtn.selected) {
        [self.rememberBtn setSelected:NO];
    }
    else {
        [self.rememberBtn setSelected:YES];
    }
}

#pragma mark - 找回密码响应事件
- (void)retrievePassword:(id)sender {
    
    if (![self alertPhoneHotLine]) {
        [self gotoRetrievePassword];
    }
}

- (BOOL)alertPhoneHotLine {
    
    NSString *findPasswordMjet = [WSPlistHelper valueForKey:kGET_PASSWORD_URL withPlistName:kConfilgFileName];
    if ([findPasswordMjet length] > 0 && ![findPasswordMjet containsString:@"http"] ) {
        NSArray *array = [findPasswordMjet componentsSeparatedByString:@"/"];
        if (array.count == 2) {
            WSFindPassWordAlertView *findPassword = [[WSFindPassWordAlertView alloc] init];
            [findPassword showFindPasswordAlertView ];
            return  YES;
        }
    }
    return NO;
}
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------










//无用
- (void)otherSetupViews {
    
//    loginCount = 0;
//    isBackFromOtherController = NO;
//    self.rememberUsername.hidden = YES;
//    _loginViewTextColor = LOGINVIEW_TEXT_COLOR ? : MAIN_TINT_COLOR;
//
//    BOOL isLongLanguage = NO;
//    if (![[UIDevice getPreferredLanguage] hasPrefix:@"zh"] && ![[UIDevice getPreferredLanguage] hasPrefix:@"en"] && ![[UIDevice getPreferredLanguage] hasPrefix:@"ja"])
//        isLongLanguage = YES;
//
//    UIImage *bgImage = nil;
//    if (INTERFACE_IS_PAD)
//        bgImage = [UIImage scaledImageForName:@"login_bg_lanscape" ofType:@"png"];
//    else
//    {
//        if (IS_IPHONE5)
//            bgImage = [UIImage scaledImageForName:@"login_bg-568" ofType:@"png"];
//        else
//            bgImage = [UIImage scaledImageForName:@"login_bg" ofType:@"png"];
//    }
//    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
//    bgImageView.image = bgImage;
//    [self.view addSubview:bgImageView];
//
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"appname" ofType:@"png"];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
//    self.sysNameLogo = [[UIImageView alloc] initWithImage:image];
//    self.sysNameLogo.tag = 555;
//    self.sysNameLogo.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:self.sysNameLogo];
//    CGSize logoRectSize = self.sysNameLogo.frame.size;
//    UILabel *appTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(logoRectSize.width/3, logoRectSize.height/10, logoRectSize.width/3, logoRectSize.height/5)];
//    appTypeLable.text = [WSPlistHelper getApppPackageType];
//    appTypeLable.font = [UIFont systemFontOfSize:UI_Font + 10];
//    appTypeLable.textAlignment = NSTextAlignmentCenter;
//    appTypeLable.textColor = MAIN_TINT_COLOR;
//    [self.sysNameLogo addSubview:appTypeLable];
//    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
//    [self.sysNameLogo setFrame:[self getLogoRect]];
//    self.sysNameLogo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
//
//    [self createLoginBoxView]; //登陆框
//
//    UIButton *remeberIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];// 记住用户名按钮icon
//    [remeberIconBtn setImage:[UIImage scaledImageForName:@"remeber_pwd_unselected" ofType:@"png"] forState:UIControlStateNormal];
//    [remeberIconBtn setImage:[UIImage scaledImageForName:@"remeber_pwd_selected" ofType:@"png"] forState:UIControlStateSelected];
//    [remeberIconBtn addTarget:self action:@selector(remberUserName:) forControlEvents:UIControlEventTouchUpInside];
//    CGFloat remeberOffsetX = CGRectGetMinX(_loginBoxView.frame);
//    remeberIconBtn.frame = CGRectMake(remeberOffsetX , CGRectGetMaxY(self.loginBoxView.frame) + k_RemeberYOffSet, k_RemeberIconWidth, k_RemeberIconHeight);
//    remeberIconBtn.userInteractionEnabled = YES;
//    self.rememberBtn = remeberIconBtn;
//    [self.view addSubview:remeberIconBtn];
//
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME])
//        [self.rememberBtn setSelected:YES];
//    else
//    {
//        NSString *rememberName = [[NSUserDefaults standardUserDefaults] objectForKey:REMEMBER_ME_KEY];
//        if ([rememberName isEqualToString:@"1"])
//            [self.rememberBtn setSelected:YES];
//    }
//
//    UIButton *rememberUserButton = [UIButton buttonWithType:UIButtonTypeCustom];// 记住用户名按钮
//    CGFloat rememberWidth = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 170 :170);
//    if (isLongLanguage)
//        rememberWidth = 270;
//    rememberUserButton.frame = CGRectMake(CGRectGetMaxX(remeberIconBtn.frame) + MAIN_PADDING / 2, CGRectGetMinY(remeberIconBtn.frame), rememberWidth, k_RememberUserHeight);
//    rememberUserButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [rememberUserButton addTarget:self action:@selector(remberUserName:) forControlEvents:UIControlEventTouchUpInside];
//    NSString *RememberIDString = NSLocalizedString(@"remember_my_info_label",nil);
//    [rememberUserButton  setTitle:RememberIDString forState:UIControlStateNormal];
//    [rememberUserButton setTitleColor:self.loginViewTextColor forState:UIControlStateNormal];
//    rememberUserButton.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
//    [self.view addSubview:rememberUserButton];
//
//    if (![WSEnvrionment getHideRetrievePassword])
//    {
//        self.changePSWBtn = [UIButton buttonWithType:UIButtonTypeCustom];//找回密码按钮
//        CGFloat changeBtnWidth = k_ButtonWidth+50;
//        CGFloat changePswOffsetX = CGRectGetMaxX(_loginBoxView.frame) - changeBtnWidth;
//        self.changePSWBtn.frame=CGRectMake(changePswOffsetX, CGRectGetMinY(rememberUserButton.frame), changeBtnWidth , k_ButtonHeight);
//        self.changePSWBtn.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
//        NSString *changePSWString = NSLocalizedString(@"password_retake",nil);
//        self.changePSWBtn.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
//        [self.changePSWBtn setTitle:changePSWString forState:UIControlStateNormal];
//        [self.changePSWBtn setTitleColor:self.loginViewTextColor forState:UIControlStateNormal];
//        [self.changePSWBtn addTarget:self action:@selector(retrievePassword:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.changePSWBtn];
//    }
//
//    if (isLongLanguage)
//    {
//        self.changePSWBtn.frame = CGRectMake(remeberIconBtn.left + 2, remeberIconBtn.bottom + 10, 280 , k_ButtonHeight);
//        self.changePSWBtn.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
//    }
//
//    CGFloat loginButtonX = CGRectGetMinX(_loginBoxView.frame);// 登录按钮和拒绝按钮
//    CGRect btnRect;
//    if ([WSEnvrionment getLoginReject])
//    {
//        NSString *rejectTitle = NSLocalizedString(@"login_reject_label", nil);
//        UIFont *loginButtonFont = [UIFont systemFontOfSize:k_LoginBtnTitleFont];
//        CGSize rejectSize = [rejectTitle ws_sizeWithFont:loginButtonFont constrainedToHeight:k_LoginBoxHeight];
//        CGFloat btnRejectWith = rejectSize.width + MAIN_PADDING * 2;
//        CGFloat btnOffsetY = CGRectGetMaxY(rememberUserButton.frame) + k_LoginBtnYOffSet;
//        btnRect = CGRectMake(loginButtonX,  btnOffsetY, CGRectGetWidth(_loginBoxView.frame) - btnRejectWith - MAIN_PADDING, k_LoginBtnHeight);
//        CGRect btnRejectRect = CGRectMake(CGRectGetMaxX(_loginBoxView.frame) - btnRejectWith, btnOffsetY, btnRejectWith, k_LoginBtnHeight);
//
//        UIButton *rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [rejectBtn setFrame:btnRejectRect];
//        [rejectBtn setTitle:rejectTitle forState:UIControlStateNormal];
//        [rejectBtn addTarget:self action:@selector(rejectAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self setButtonStyle:rejectBtn withRect:btnRejectRect];
//        [self.view addSubview:rejectBtn];
//
//    }
//    else
//        btnRect = CGRectMake(loginButtonX,  CGRectGetMaxY(rememberUserButton.frame) + k_LoginBtnYOffSet, CGRectGetWidth(_loginBoxView.frame), k_LoginBtnHeight);
//
//    NSInteger countdownTime = 0;
//    NSString *countdownTimeString = [WSEnvrionment getLoginCountdownTime];
//    if ([countdownTimeString length] > 0)
//        countdownTime = [countdownTimeString integerValue];
//
//    __weak typeof(self) weakself = self;
//    __block JFTakeCountButton *loginButton = [JFTakeCountButton initWithCount:(int)countdownTime withTitle:NSLocalizedString(@"login_label", nil) withTitleColor:nil withTitleFont:nil withTitleFrame:btnRect withIsShowTitle:YES withBlock:^{
//        if (self.passwd.text.length > 0 && [self getUserNameFromTextField].length > 0)
//            loginButton.enabled = YES;
//        else
//            loginButton.enabled = NO;
//        weakself.isCountingdown = NO;
//    }];
//
//    if (countdownTime == 0 && self.passwd.text.length > 0 && [self getUserNameFromTextField].length > 0)// jira winSFA MSTD-3642 跟安卓一致，如果账户或者密码未输入，则登录按钮不能点击，字体为灰色
//        loginButton.enabled = YES;
//    else
//        loginButton.enabled = NO;
//    loginButton.frame = btnRect;
//
//    [loginButton addTarget:self action:@selector(loginStart:) forControlEvents:UIControlEventTouchUpInside];
//    [self setButtonStyle:loginButton withRect:btnRect];
//    [self.view addSubview:loginButton];
//    self.loginBtn = loginButton;
//    [loginButton startTakeCount];
//
//    registerBtn = [UIButton buttonWithType:UIButtonTypeCustom]; // 注册按钮
//    if (projectName != nil && [projectName isEqualToString:@"HWDJIOS"])
//    {
//        registerBtn.frame=CGRectMake(CGRectGetMinX(loginButton.frame)+10, CGRectGetMaxY(loginButton.frame) + MAIN_PADDING, k_ButtonWidth + 60, k_ButtonHeight);
//        registerBtn.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
//        NSString *registerString = NSLocalizedString(@"sign_up",nil);
//        registerBtn.titleLabel.font = [UIFont systemFontOfSize:UI_Login_Font];
//        [registerBtn setTitle:registerString forState:UIControlStateNormal];
//        [registerBtn setTitleColor:self.loginViewTextColor forState:UIControlStateNormal];
//        [registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:registerBtn];
//    }
//
//    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];//热线
//    NSString *winchannelHotline = [plistDic objectForKey:@"Hotline"];
//    if ([winchannelHotline length] > 0)
//        [self createHotLineView];
//
//    UIFont *aboutFont = [UIFont systemFontOfSize:UI_Login_Font];// 关于按钮
//    CGRect aboutFrame;
//    NSString *aboutString = NSLocalizedString(@"about",nil);
//    CGSize aboutSize = [aboutString ws_sizeWithFont:aboutFont constrainedToHeight:k_ButtonHeight];
//    CGFloat aboutWidth = aboutSize.width + MAIN_PADDING;
//
//    NSString *loginWarning = NSLocalizedString(@"login_warning", nil);// 登录警告
//    if ([loginWarning length] > 0)// 登录警告放在登录按钮下方
//    {
//        UIFont *warningFont = [UIFont systemFontOfSize:UI_Login_Font];
//        CGSize warningSize = [loginWarning ws_sizeWithFont:warningFont constrainedToHeight:k_hotLineHeight];
//        UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(loginButtonX, CGRectGetMaxY(loginButton.frame) + MAIN_PADDING, warningSize.width, k_hotLineHeight)];
//        [warningLabel setFont:warningFont];
//        UIColor *warningColor = [UIColor colorForKey:@"LoginWarningTextColor"];
//        if (!warningColor)
//            warningColor = WARNING_TEXT_COLOR;
//        [warningLabel setTextColor:warningColor];
//        [warningLabel setText:loginWarning];
//        [self.view addSubview:warningLabel];
//
//        if ([winchannelHotline length] > 0)// 有登录警告时则关于按钮放在热线位置
//            aboutFrame = CGRectMake(CGRectGetMaxX(_hotlineView.frame) + MAIN_PADDING, CGRectGetMinY(_hotlineView.frame), aboutWidth, k_ButtonHeight);
//        else
//            aboutFrame = CGRectMake((self.view.width - aboutWidth) / 2 , self.view.height - k_ButtonHeight - MAIN_PADDING, aboutWidth, k_ButtonHeight);
//    }
//    else
//    {
//        CGFloat aboutBtnXOffset = CGRectGetMaxX(_loginBoxView.frame) - aboutWidth;
//        aboutFrame = CGRectMake(aboutBtnXOffset, CGRectGetMaxY(loginButton.frame) + MAIN_PADDING, aboutWidth, k_ButtonHeight);
//    }
//    UIButton *aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//
//    aboutBtn.frame= aboutFrame;
//    aboutBtn.titleLabel.font = aboutFont;
//    [aboutBtn setTitle:aboutString forState:UIControlStateNormal];
//    [aboutBtn setTitleColor:self.loginViewTextColor forState:UIControlStateNormal];
//    aboutBtn.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
//    [aboutBtn setUserInteractionEnabled:YES];
//    [aboutBtn addTarget:self action:@selector(aboutBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:aboutBtn];
//
//    if (INTERFACE_IS_PAD)// 其他个
//    {
//        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320, self.view.bounds.size.height - k_IconImageBottomSpace - k_IconImageHeight, k_IconImageWidth, k_IconImageHeight)];
//        [iconImageView setImage:[UIImage imageForName:@"pfizer_logo.png"]];
//        iconImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//        [self.view addSubview:iconImageView];
//    }
//
//    if (projectName != nil && [projectName isEqualToString:@"UnileverMobileChef"])
//    {
//        CGFloat sysNameLogoWidth = 392;
//        [self.sysNameLogo setFrame:CGRectMake((self.view.bounds.size.width - sysNameLogoWidth)/2, k_LogoYOffSet +100, sysNameLogoWidth , k_LogoImageHeight +214)];
//        CGFloat remeberOffsetX = CGRectGetMinX(_loginBoxView.frame);
//        remeberIconBtn.frame = CGRectMake(remeberOffsetX, CGRectGetMaxY(self.loginBoxView.frame) , k_RemeberIconWidth, k_RemeberIconHeight);
//        rememberUserButton.frame = CGRectMake(CGRectGetMaxX(remeberIconBtn.frame) + MAIN_PADDING, CGRectGetMinY(remeberIconBtn.frame),rememberWidth, k_RememberUserHeight);
//        loginButton.frame=CGRectMake(loginButtonX, CGRectGetMaxY(remeberIconBtn.frame) + MAIN_PADDING, CGRectGetWidth(_loginBoxView.frame), 43);
//        self.changePSWBtn.frame=CGRectMake(CGRectGetMinX(loginButton.frame) , CGRectGetMaxY(loginButton.frame) + MAIN_PADDING, k_ButtonWidth , k_ButtonHeight);
//        aboutBtn.frame=CGRectMake(aboutBtn.frame.origin.x , CGRectGetMinY(self.changePSWBtn.frame), aboutBtn.frame.size.width, k_ButtonHeight);
//    }
}

#pragma mark - 创建输入框视图
- (void)createTextField
{
//    self.textFields = [[NSMutableArray alloc] initWithCapacity:2];
//    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
//
//    NSInteger btnCount = [self getTextFieldCount];
//    for (int i = 0; i < btnCount; i++)
//    {
//        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, k_UserPwdIconHeight)];
//        UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0,k_UserPwdIconWidth, k_UserPwdIconHeight)];
//        if (projectName != nil && [projectName isEqualToString:@"UnileverMobileChef"] )
//            iconImageView.frame = CGRectMake((50 - 30)/2.0, 0,k_UserPwdIconWidth, k_UserPwdIconHeight);
//
//        UITextField *textField = [[UITextField alloc] init] ;
//        textField.frame = CGRectMake((k_LoginBoxWidth - k_LoginBoxWidth)/2, k_TextFieldYOffSet * i  + i*k_TextFieldHeight , k_LoginBoxWidth, k_TextFieldHeight);
//        textField.leftView = leftView;
//        textField.leftViewMode = UITextFieldViewModeAlways;
//        if (projectName != nil && [projectName isEqualToString:@"UnileverMobileChef"] )
//            textField.background = [UIImage imageNamed:@"textfield_bg.png"];
//        else
//            [self addBottomBorderToView:textField];
//
//        textField.textColor = DETAIL_TEXT_COLOR;
//        textField.font = [UIFont systemFontOfSize:UI_Font];
//        textField.keyboardType = UIKeyboardTypeDefault;
//        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        NSString *placeHolder;
//        UIImage *imageName = nil;
//        if (i == 0)
//        {
//            self.username = textField;
//            placeHolder = NSLocalizedString(@"user_name_edit_hint",nil);
//            imageName = [UIImage scaledImageForName:@"usernameIcon" ofType:@"png"];
//            NSString *usernameForOrg = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_FOR_ORG];
//            if ([usernameForOrg length] > 0)
//            {
//                self.username.text = usernameForOrg;
//                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERNAME_FOR_ORG];
//            }
//
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:USERNAME])
//            {
//                self.username.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
//                [self.rememberBtn setSelected:YES];
//            }
//        }
//        else if (i == 1)
//        {
//            self.passwd = textField;
//            placeHolder = NSLocalizedString(@"password_edit_hint",nil);
//            self.passwd.secureTextEntry = YES;
//            self.passwd.clearsOnBeginEditing = NO;
//
//            NSString *pwdForOrg = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_FOR_ORG];
//            if ([pwdForOrg length] > 0)
//            {
//                self.passwd.text = pwdForOrg;
//                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_FOR_ORG];
//            }
//            else
//                self.passwd.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
//
//            imageName = [UIImage scaledImageForName:@"passwordIcon" ofType:@"png"];
//        }
//        else if (i == 2)
//        {
//            self.orgCodeTextField = textField;
//            placeHolder = NSLocalizedString(@"org_code",nil);
//            imageName = [UIImage scaledImageForName:@"organizationIcon" ofType:@"png"];
//
//            NSString *orgCode = [self getSaasOrgCode];
//            if ([orgCode length] > 0)
//                self.orgCodeTextField.text = orgCode;
//        }
//
//        textField.placeholder = placeHolder;
//        if (INTERFACE_IS_PHONE)
//            textField.backgroundColor = kCLEAR_COLOR_value;
//
//        [iconImageView setImage:imageName];
//        [leftView addSubview:iconImageView];
//
//        textField.delegate = self;
//        [textField addTarget:self action:@selector(textWatcher:) forControlEvents:UIControlEventEditingChanged];
//        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        textField.textAlignment = NSTextAlignmentLeft;
//        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        [self.textFields addObject:textField];
//        [_loginBoxView addSubview:textField];
//    }
}

#pragma mark - 添加底部线视图方法
- (void)addBottomBorderToView:(UIView *)view
{
//    CGRect frame = view.frame;
//    CALayer *bottomLayer = [CALayer layer];
//    bottomLayer.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
//    UIColor *lineColor = [UIColor colorForKey:@"LoginViewTextFieldLineColor"] ? [UIColor colorForKey:@"LoginViewTextFieldLineColor"] : DETAIL_SEPERATE_LINE_COLOR;
//    bottomLayer.backgroundColor =  lineColor.CGColor;
//    [view.layer addSublayer:bottomLayer];
}

#pragma mark - 创建登陆框视图
- (void)createLoginBoxView
{
//    NSInteger textFieldCount = [self getTextFieldCount];
//    _loginBoxView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - k_LoginBoxWidth)/2,CGRectGetMaxY(self.sysNameLogo.frame) +  k_RemeberYOffSet, k_LoginBoxWidth, k_TextFieldHeight * textFieldCount + k_TextFieldYOffSet)];
//    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
//    if (projectName != nil && [projectName isEqualToString:@"UnileverMobileChef"] )
//        _loginBoxView.frame = CGRectMake((self.view.bounds.size.width - k_LoginBoxWidth)/2,CGRectGetMaxY(self.sysNameLogo.frame) +50, k_LoginBoxWidth, k_LoginBoxHeight);
//
//    _loginBoxView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    _loginBoxView.userInteractionEnabled = YES;
//    [self.view addSubview:_loginBoxView];
//    [self createTextField];
}

#pragma mark - 暂时未使用方法dismissAltertController
- (void)dismissAltertController:(NSTimer *)timer {
    
//    UIAlertController *alert = [timer userInfo];
//    [alert dismissViewControllerAnimated:YES completion:nil];
//    alert = nil;
}

#pragma mark - 暂时未使用方法createAuthorizationViewController
- (void)createAuthorizationViewController {
    
//    BOOL showAuthorizationVC = NO;
//    NSUserDefaults *firstLauchDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL firstLauch = [firstLauchDefaults boolForKey:@"AppFirstLaunch"];
//    NSString *authorization = [WSPlistHelper valueForKey:OPEN_TC_EVERY_TIME withPlistName:kConfilgFileName];
//    if (authorization == nil)
//        authorization = @"0";
//    if ([authorization isEqualToString:@"0"] && firstLauch)
//        showAuthorizationVC = YES;
//    else if ([authorization isEqualToString:@"1"])
//        showAuthorizationVC = YES;
//
//    if (showAuthorizationVC)
//    {
//        WSRegisterViewController *registerVC = [[WSRegisterViewController alloc] init];
//        [self.navigationController pushViewController:registerVC animated:YES];
//    }
}

#pragma mark - 暂时未使用方法loginCancel
- (void)loginCancel {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:REQUESTCANCEL object:nil];
}

- (void)initAndShowSwipePasswordViewController
{
//    NSString *swipePassword = [[NSUserDefaults standardUserDefaults] objectForKey:kLevel2Password];
//    InitSwipePasswordViewController *initSwipePasswordVC = [[InitSwipePasswordViewController alloc] init];
//    if (swipePassword.length > 0)
//        initSwipePasswordVC.swipeType = SwipeTypeUnlock;
//    else
//        initSwipePasswordVC.swipeType = SwipeTypeInit;
//    //    YIHAIKERRY-2080 董宏 增加手势页面菊花的隐藏
//    self.swipeVC = initSwipePasswordVC;
//    __weak typeof(InitSwipePasswordViewController*) weakSwipePasswordVC = initSwipePasswordVC;
//    __weak typeof(self) weakself = self;
//    initSwipePasswordVC.finishSwipeBlock= ^{
//        NSString *authorization = [WSPlistHelper valueForKey:OPEN_TC_EVERY_TIME withPlistName:kConfilgFileName];// 如果不是从其他页面返回，且不是每次都弹出宪章则进行自动登录
//        if (!authorization)
//            authorization = @"0";//默认为0
//        if (authorization && [authorization isEqualToString:@"0"])
//        {
//            // YIHAIKERRY-3036
//            //SFA 益海嘉里-传统渠道【离线登录】【ios】离线登录，输入正确的手势，无法登录
//            self.username.text = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
//
//            [MBProgressHUD showHUDAddedTo:weakSwipePasswordVC.view withText:NSLocalizedString(@"logining_prompt", nil)
//                                     tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
//
//            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SWIPE_PASSWORD_IS_RIGHT];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//
//            [weakself autoLogin];
//        }
//    };
//    [self presentViewController:initSwipePasswordVC animated:NO completion:^{
//    }];
}

#pragma mark - 获取输入的组织编码
- (NSString *)getSaasOrgCode
{
//    NSString *url = [WSEnvrionment getSaasUrl];
//    if ([url length] > 0)
//    {
//        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
//        if ([userName length] > 0)
//        {
//            NSString *password  = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
//            if ([password length] > 0)
//            {
//                NSString *saasUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SAAS_WEB_ADDRESS];
//                NSArray *saasUrlArray = [saasUrl componentsSeparatedByString:LOGIN_SAAS_WEB_ADDRESS_SEPARATOR];
//                if ([saasUrlArray count] == 3)
//                {
//                    NSString *urlUserName = saasUrlArray[0];
//                    if ([urlUserName isEqualToString:userName]) // 只有用户名和输入的用户名一致时才使用记录在本地的上一次输入的组织编码
//                        return saasUrlArray[1];
//                }
//            }
//        }
//    }
//
    return nil;
}

- (BOOL)isNeedAnyTimeOfflineLogin
{
//    NSString *offline = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
//    if ([offline isEqualToString:@"1"])
//        return YES;
//
    return NO;
}

- (BOOL)isNeedOfflineLogin
{
//    NSString *offline = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
//    if ([offline isEqualToString:@"1"] || [offline isEqualToString:@"2"])
//        return YES;
//
    return NO;
}

- (BOOL)canCurrentUserOfflineLogin:(BOOL)isAutoShowMessage
{
//    NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];//is_offline_landing = 2 时，才会校验时间
//    if ([isOfflineLanding isEqualToString:@"2"])
//    {
//        NSDate *serverTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverTime"];
//        if (!serverTime)
//        {
//            LogError(@"尝试离线登录，没有serverTime，登录失败");
//            if (isAutoShowMessage)
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"离线登录失败", nil) tips:nil tapTarget:nil action:nil
//                                         type:MBProgressHUDMessageTypeFailed];
//            return NO;
//        }
//
//        NSDate *serverDate = [WSCurrentTime getCurrentServerDate];
//        NSDate *phoneDate = [NSDate date];
//        NSTimeInterval interval = [serverDate timeIntervalSinceDate:phoneDate];
//        if (ABS(interval) > (60 * WCForceQuiteTimeInterval))
//        {
//            LogError(@"尝试离线登录，当前服务器计算时间与手机时间差值超过20分钟，登录失败，\nserverTime:%@，计算的服务器时间：%@，手机时间：%@，差值：%f分钟", serverTime, serverDate, phoneDate, (interval/60.0f));
//            if (isAutoShowMessage)
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"离线登录失败", nil) tips:nil tapTarget:nil action:nil
//                                         type:MBProgressHUDMessageTypeFailed];
//            return NO;
//        }
//    }
//
//    NSString *userNameLast = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
//    NSString *passwordLast = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_LAST_LOGIN];
//    if ([userNameLast length] > 0 && [userNameLast isEqualToString:[self getUserNameFromTextField]] && [passwordLast length] > 0 && [passwordLast isEqualToString:self.passwd.text])
//    {
//        LogInfo(@"离线登录校验通过：username:%@,password:%@", userNameLast, passwordLast);
//        return YES;
//    }
//    else
//    {
//        if (isAutoShowMessage)
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"用户名密码不符，离线登录失败", nil) tips:nil tapTarget:nil action:nil
//                                     type:MBProgressHUDMessageTypeFailed];
//    }
    return NO;
}

- (BOOL)offlineLoginWhenLaunch
{
//    if ([WSEnvrionment getUseOfflineLoginWhenLaunch])
//    {
//        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
//        NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
//        if ([userName length] == 0 || [pwd length] == 0)
//            return NO;
//
//        WSAppDelegate * deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
//        NSDate *forceQuitTime = [deleget getForceQuitTime];
//
//        NSDate *nowDate = [NSDate date];
//        if ([nowDate compare:forceQuitTime] == NSOrderedDescending) {
//            // 当前时间晚于强退时间则需要刷新数据
//            return NO;
//        }
//
//        return [self offlineLoginWithUserName:userName password:pwd isLaunch:YES];
//    }
    return NO;
}

- (void)offlineLogin
{
//    [self offlineLoginWithUserName:[self getUserNameFromTextField] password:self.passwd.text isLaunch:NO];
}

- (BOOL)offlineLoginWithUserName:(NSString *)userName password:(NSString *)password isLaunch:(BOOL)isLaunch
{
    return NO;
//    LogTrace();
//    WSLoginDataProcessService *processService = [[WSLoginDataProcessService alloc] init];
//    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME_CALL_APP];
//    [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD_CALL_APP];
//    if (![processService processLoginData:nil userName:userName password:password isFromCache:YES isOfflineLogin:YES])
//    {
//        [WSAppData removeAll];
//        [self cancelLogin:nil];
//        [self showAlert:NSLocalizedString(@"login_fail", nil)];
//        return NO;
//    }
//
//    if (!isLaunch)// 启动时候的离线登录数据在首页刷新，不需要校验业务日期 校验业务日期，这样的话每天第一次登录必须有网
//    {
//        NSString *oldBizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//        NSString *nowDate = [WSCurrentTime getDateString];
//        if (![oldBizDate isEqualToString:nowDate])
//        {
//            [WSAppData removeAll];
//            [self cancelLogin:nil];
//            [self showAlert:NSLocalizedString(@"离线登录失败，请联网登录", nil)];
//            return NO;
//        }
//    }
//
//    LogInfo(@"离线登录成功");
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:IS_IN_OFFLINE_LOGIN];
//    [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSUCCESS object:nil];
//    return YES;
}

#pragma mark - 获取输入框个数方法
- (NSInteger)getTextFieldCount
{
    return 2;
//    NSInteger btnCount = 2;
//    if (self.isShowOrgCode)
//        btnCount = 3;
//    return btnCount;
}

#pragma mark - 设置按键样式方法
- (void)setButtonStyle:(UIButton *)button withRect:(CGRect)rect
{
//    UIColor *loginBtnBackgroundColor = LOGINVIEW_LOGINBTN_BACKGROUND_COLOR?:MAIN_TINT_COLOR;
//    CGFloat btnRadius = k_LoginBtnHeight / 11;
//    UIFont *loginButtonFont = [UIFont systemFontOfSize:k_LoginBtnTitleFont];
//    [button.titleLabel setFont:loginButtonFont];
//    UIImage *btnImg = [UIImage imageFromColor:loginBtnBackgroundColor with:rect];
//    UIImage *btnPressImg = [UIImage imageFromColor:[loginBtnBackgroundColor colorWithAlphaComponent:ALPHA_PRESSED] with:rect];
//    [button setBackgroundImage:btnImg forState:UIControlStateNormal];
//    [button setBackgroundImage:btnImg forState:UIControlStateDisabled];
//    [button setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:ALPHA_DISABLED] forState:UIControlStateDisabled];
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = btnRadius;
}

- (BOOL)loginSaas {
//
//    NSString *url = [WSEnvrionment getSaasUrl];
//    if ([url length] > 0) {
//
//        BOOL isLoginSaasWebAddress = NO;
//        if (self.orgCodeTextField) {
//            if ([[self.orgCodeTextField text] length] > 0) {
//                isLoginSaasWebAddress = [self loginSaasWebAddressUrl];
//            }
//        }
//        if (!isLoginSaasWebAddress) {
//            [self requestLoginSassWithUrl:url];
//        }
//
//        return YES;
//    }
    return NO;
}

- (void)addOrgCode {
    
//    self.isShowOrgCode = YES;
//    if (!self.orgCodeTextField)// 没有组织编码控件则创建
//    {
//        [[NSUserDefaults standardUserDefaults] setObject:[self getUserNameFromTextField] forKey:USERNAME_FOR_ORG];
//        [[NSUserDefaults standardUserDefaults] setObject:self.passwd.text forKey:PASSWORD_FOR_ORG];
//        [self setupViews];
//    }
//
//    if ([self.orgCodeTextField.text length] > 0) // 创建成功或者已经存在组织编码控件
//    {
//        [self startIndicator];
//        [self loginSaasWebAddressUrl];
//    }
//    else
//    {
//        NSString *msg = NSLocalizedString(@"pls_input_org_code", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }
}

- (BOOL)loginSaasWebAddressUrl {
    
//    NSString *saasWebAddress = [self getSaasWebAddress];
//    if ([saasWebAddress length] > 0)
//    {
//        [self loginByBaseUrl:saasWebAddress];
//        return YES;
//    }
    return NO;
}

- (void)requestLoginSassWithUrl:(NSString *)url {
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSaasFinish:) name:LOGIN_SAAS_NOTIFY object:nil];
//    NSString *completeUrl = [WSHttpURLHelper getCompleteURLByServerUrl:url partOfURL:LOGIN_SAAS_METHOD];
//    [[WSRequestHelper shareInstance] postRequestOnLoginSaas:[self getUserNameFromTextField] orgName:self.orgCodeTextField.text notifyName:LOGIN_SAAS_NOTIFY URL:completeUrl];
}

- (void)loginSaasFinish:(id)sender {
    
//    [self stopIndicator];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_SAAS_NOTIFY object:nil];
//    NSDictionary *data = [sender userInfo];
//    NSString *info = [data objectForKey:DATAS];
//    NSDictionary *dic = [info objectFromJSONString];
//
//    NSString *acnumbers = [NSString stringWithValue:[dic objectForKey:LOGIN_SAAS_ACNUMBERS]];
//    if ([acnumbers isEqualToString:@"-1"])// 平台上多个账号
//        [self addOrgCode];
//    else if ([acnumbers isEqualToString:@"0"])
//    {
//        NSString *msg = @"请输入正确账号或联系管理员建立账号"; // TODO: 字符串确认
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }
//    else if ([acnumbers isEqualToString:@"1"]) // 只对应一个账号
//    {
//        NSString *url = [dic objectForKey:LOGIN_SAAS_URL];
//        if ([url length] > 0)
//        {
//            NSString *orgCode = @"";
//            if (self.orgCodeTextField && [self.orgCodeTextField.text length] > 0)
//                orgCode = self.orgCodeTextField.text;
//
//            NSString *saasUrl = [NSString stringWithFormat:@"%@%@%@%@%@", [self getUserNameFromTextField], LOGIN_SAAS_WEB_ADDRESS_SEPARATOR, orgCode, LOGIN_SAAS_WEB_ADDRESS_SEPARATOR, url];
//            [[NSUserDefaults standardUserDefaults] setObject:saasUrl forKey:LOGIN_SAAS_WEB_ADDRESS];
//
//            NSString *sendVersion = [NSString stringWithValue:[dic objectForKey:LOGIN_SAAS_SEND_VERSION_KEY]];
//            if ([sendVersion length] > 0 && [sendVersion isEqualToString:@"1"])
//                [[NSUserDefaults standardUserDefaults] setObject:LOGIN_SAAS_SEND_VERSION_YES forKey:LOGIN_SAAS_SEND_VERSION];
//            else
//                [[NSUserDefaults standardUserDefaults] setObject:LOGIN_SAAS_SEND_VERSION_NO forKey:LOGIN_SAAS_SEND_VERSION];
//
//            NSString *url = [WSEnvrionment getSaasUrl];
//            NSString *appUrl = [NSString stringWithFormat:@"%@%@", url, QR_SHARE];
//            [WSAppData putObject:appUrl forKey:APPDATA_QR_URL];
//            [[NSUserDefaults standardUserDefaults] setValue:appUrl forKey:APPDATA_QR_URL]; // 持久性
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        else
//            LogError(@"Failed get url when login sass, the url is not net:%@", info);
//
//        [self startIndicator];
//        [self loginByBaseUrl:url];
//
//    }
//    else
//        LogError(@"Failed get url when login sass:%@", info);
}

- (NSString *)getSaasWebAddress {
    
    return @"";
//    NSString *orgCode = @"";
//    if (self.orgCodeTextField && [self.orgCodeTextField.text length] > 0)
//        orgCode = self.orgCodeTextField.text;
//    return [self getSaasWebAddressWithUserName:[self getUserNameFromTextField] orgName:orgCode];
}

- (void)loginByBaseUrl:(NSString *)baseUrl
{
//    if (![WSEnvrionment getParamInLoginData])
//    {
//        NSString *completeUrl = [WSHttpURLHelper getCompleteURLByServerUrl:baseUrl partOfURL:GET_ROOTCONFIG];
//        [self startGetRootConfigWithUrl:completeUrl];
//        self.isUseSaasWebAddressLogin = YES;
//    }
//    else
//        [self startLoginSaasByBaseUrl:baseUrl];
//
//    if (![baseUrl hasSuffix:@"/"])
//        baseUrl = [baseUrl stringByAppendingFormat:@"/"];
//    [[NSUserDefaults standardUserDefaults] setObject:baseUrl forKey:SAAS_WEB_ADDRESS];
}

- (void)startLoginSaasByBaseUrl:(NSString *)baseUrl {
    
//    NSString *completeUrl = [WSHttpURLHelper getCompleteURLByServerUrl:baseUrl partOfURL:LOGIN_METHOD];
//    [self startLoginWithUrl:completeUrl];
}

- (void)gotoSaasRetrievePassword {
    
//    NSString *webAddress = [self getSaasWebAddress];
//    if ([webAddress length] > 0)
//    {
//        NSString *url = [self getRetrievePasswordUrlWithServerUrl:webAddress];
//        [self gotoRetrievePasswordWithUrl:url];
//    }
//    else
//    {
//        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//        [self.view addSubview:self.findPwdView];
//    }
}

- (void)requestLoginSassForReterivePwdWithUrl:(NSString *)url userName:(NSString *)userName orgName:(NSString *)orgName
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSaasForReterivePwdFinish:) name:LOGIN_SAAS_RETRIEVE_PWD_NOTIFY object:nil];
//    NSString *completeUrl = [WSHttpURLHelper getCompleteURLByServerUrl:url partOfURL:LOGIN_SAAS_METHOD];
//    [[WSRequestHelper shareInstance] postRequestOnLoginSaas:userName orgName:orgName notifyName:LOGIN_SAAS_RETRIEVE_PWD_NOTIFY URL:completeUrl];
}

- (void)loginSaasForReterivePwdFinish:(id)sender
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_SAAS_RETRIEVE_PWD_NOTIFY object:nil];
//    NSDictionary *data = [sender userInfo];
//    NSString *info = [data objectForKey:DATAS];
//    NSDictionary *dic = [info objectFromJSONString];
//
//    NSString *acnumbers = [NSString stringWithValue:[dic objectForKey:LOGIN_SAAS_ACNUMBERS]];
//    if ([acnumbers isEqualToString:@"-1"])
//    {
//        NSString *msg = NSLocalizedString(@"pls_input_org_code", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//
//    }
//    else if ([acnumbers isEqualToString:@"0"])
//    {
//        NSString *msg = NSLocalizedString(@"请输入正确账号或联系管理员建立账号", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//
//    }
//    else if ([acnumbers isEqualToString:@"1"]) // 只对应一个账号
//    {
//
//        NSString *url = [dic objectForKey:LOGIN_SAAS_URL];
//        if ([url length] > 0)
//        {
//            NSString *compeleteUrl = [self getRetrievePasswordUrlWithServerUrl:url];
//            [self gotoRetrievePasswordWithUrl:compeleteUrl];
//            [self removeFindPwdViewFromSuperView];
//        }
//        else
//            LogError(@"Failed get url when login sass, the url is not net:%@", info);
//    }
//    else
//        LogError(@"Failed get url when sass reterive pwd:%@", info);
}

- (void)getWebAddressByUserName:(NSString *)userName orgName:(NSString *)orgName
{
//    if ([orgName length] > 0)
//    {
//        NSString *webAddress = [self getSaasWebAddressWithUserName:userName orgName:orgName];
//        if ([webAddress length] > 0)
//        {
//            NSString *url = [self getRetrievePasswordUrlWithServerUrl:webAddress];
//            [self gotoRetrievePasswordWithUrl:url];
//            [self removeFindPwdViewFromSuperView];
//            return;
//        }
//    }
//
//    NSString *url = [WSEnvrionment getSaasUrl];
//    [self requestLoginSassForReterivePwdWithUrl:url userName:userName orgName:orgName];
}

- (void)addServiceCallToAddressBook
{
//    [[WSContactsManager sharedInstance] addServiceCallToAddressBook];
}

- (void)removeFindPwdViewFromSuperView
{
//    [self.findPwdView removeFromSuperview];
//    self.findPwdView = nil;
}

- (void)wsAuthorizationViewController:(WSAuthorizationViewController *)authorizationVC didSelected:(UIButton *)sender
{
//    [self autoLogin];
}
- (WSSaasFindPwdView *)findPwdView
{
//    if (!_findPwdView)
//    {
//        _findPwdView = [[WSSaasFindPwdView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
//        _findPwdView.delegate = self;
//    }
    return _findPwdView;
}

#pragma mark - 注册按键响应事件
- (void)registerClick
{
//    WSAuthorizationViewController *authorizationVC = [[WSAuthorizationViewController alloc]init];
//    [self.navigationController pushViewController:authorizationVC animated:YES];
}

#pragma mark - 通过用户名获取机构代码方法
- (NSString *)getSaasWebAddressWithUserName:(NSString *)userName orgName:(NSString *)orgName
{
//    NSString *saasUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SAAS_WEB_ADDRESS];
//    NSArray *saasUrlArray = [saasUrl componentsSeparatedByString:LOGIN_SAAS_WEB_ADDRESS_SEPARATOR];
//    if ([saasUrlArray count] == 3)
//    {
//        NSString *urlUserName = saasUrlArray[0];
//        NSString *orgCode = saasUrlArray[1];
//        if ([urlUserName isEqualToString:userName] && [orgCode isEqualToString:orgName])
//            return saasUrlArray[2];
//    }
    return nil;
}

#pragma mark - 创建热线视图
- (void)createHotLineView
{
//    _hotlineView = [[UIView alloc] init];
//
//    UIFont *hotlineFont = [UIFont boldSystemFontOfSize:UI_Login_Font];
//    UIFont *btnFont = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 13 : 16];
//    NSString *hotlineString = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"service_hotline", nil)];
//    CGSize hotlineSize = [hotlineString ws_sizeWithFont:hotlineFont constrainedToHeight:k_hotLineHeight];
//    CGFloat labelWidth = hotlineSize.width + 2 * MAIN_PADDING;
//    NSString *btnString = [WSEnvrionment getHotline];
//    CGSize btnSize = [btnString ws_sizeWithFont:btnFont constrainedToHeight:k_hotLineHeight];
//    CGFloat btnWidth = btnSize.width + 2 * MAIN_PADDING;
//    CGFloat viewWidth = labelWidth + btnWidth;
//
//    CGFloat hotX = self.view.width  / 2;
//    CGFloat hotY = self.view.height - self.view.height/10;
//    _hotlineView.center = CGPointMake(hotX, hotY);
//    _hotlineView.bounds = CGRectMake(0, 0, viewWidth, k_hotLineHeight);
//    [self.view addSubview:_hotlineView];
//
//    CGFloat labelGap = 20;
//    _hotlineLabel = [[UILabel alloc] init];
//    _hotlineLabel.font = hotlineFont;
//    [_hotlineLabel setTextColor:self.loginViewTextColor];
//    [_hotlineLabel setText:hotlineString];
//    _hotlineLabel.textAlignment = NSTextAlignmentRight;
//    _hotlineLabel.frame = CGRectMake(0, 0, labelWidth, CGRectGetHeight(_hotlineView.frame));
//    [_hotlineView addSubview:_hotlineLabel];
//
//    _hotlineBtn = [[UILabel alloc]init];
//    _hotlineBtn.textAlignment = NSTextAlignmentLeft;
//    _hotlineBtn.userInteractionEnabled = YES;
//    _hotlineBtn.frame = CGRectMake(labelWidth+labelGap, 0, btnWidth, CGRectGetHeight(_hotlineView.frame));
//    _hotlineBtn.font = btnFont;
//    UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hotLineClick)];
//    [_hotlineBtn addGestureRecognizer:gesture];
//
//    NSMutableAttributedString * contont = [[NSMutableAttributedString alloc]initWithString:btnString];
//    NSRange contentRange = {0,[btnString length]};
//    [contont addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:contentRange];
//    [contont addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
//    _hotlineBtn.attributedText = contont;
//
//    [_hotlineView addSubview:_hotlineBtn];
//    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
//    if (projectName != nil && [projectName isEqualToString:@"UnileverMobileChef"] )
//    {
//        _hotlineView.frame = CGRectZero;
//        _hotlineLabel.frame = CGRectZero;
//        _hotlineBtn.frame = CGRectZero;
//    }
}

- (void)startGetRootConfig
{
    //[self startGetRootConfigWithUrl:URL_GETROOTCONFIG];
}

- (void)startGetRootConfigWithUrl:(NSString *)url
{
//    [[WSTestTools getInstance] keepTimeWithKey:LOG_GET_ROOT_CONFIG_DATA forcePrint:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRootConfigFinish:) name:GETROOTCONFIG_NOTIFY object:nil];
//
//    [[WSRequestHelper shareInstance] appGetRootConfig:[self getUserName] passWd:[self getUserPassword] notifyName:GETROOTCONFIG_NOTIFY url:url progress:^(CGFloat progress)
//     {
//         dispatch_async(dispatch_get_main_queue(), ^{
//             NSInteger totalProgress = progress * WSLoginProgressRequestConfig;
//             [self setProgress:totalProgress];
//         });
//     }];
}

- (void)getRootConfigFinish:(id)sender
{
//    LogInfo(@"请求配置数据结束");
//    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_GET_ROOT_CONFIG_DATA forcePrint:YES];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:GETROOTCONFIG_NOTIFY object:nil];
//    [self processRootConfigData:[sender userInfo] isLogin:YES];
}

- (void)mjetLogin
{
//    [WSMjetLoginManager sharedInstance].delegate = self;
//    [[WSMjetLoginManager sharedInstance] setUpUsername:[self getUserName] password:[self getUserPassword]];
//    [[WSMjetLoginManager sharedInstance] mjetLogin];
}

- (void)mjetLoginSuccess:(NSDictionary *)dictionary
{
//    LogTrace();
//    if ([WSMjetLoginManager isNeedGetSSOSession])
//        [[WSMjetLoginManager sharedInstance] getSSOSessionForUrl:[WSHttpURLHelper getConfigFileServerIP]];
//    else
//        [self startGetRootConfig];
}

- (void)mjetLoginFailed:(NSDictionary *)dictionary
{
//    LogTrace();
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    NSString *msg = dictionary[@"errorDescription"];
//    if (!msg)
//        msg = dictionary[@"string"];
//    if (!msg)
//        msg = NSLocalizedString(@"login_fail", nil);
//
//    [self stopIndicator];
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)getSSOSessionSuccess:(NSDictionary *)dictionary
{
//    [self processRootConfigData:dictionary isLogin:YES];
}

- (void)getSSOSessionFailed:(NSDictionary *)dictionary
{
//    [self cancelLogin:nil];
//    NSString *title = NSLocalizedString(@"login_fail", nil);
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (action == @selector(cut:)) {
//        return YES;
//    } else if (action == @selector(copy:)) {
//        return YES;
//    } else if (action == @selector(paste:)) {
//        return YES;
//    } else if (action == @selector(select:)) {
//        return YES;
//    } else if (action == @selector(selectAll:)) {
//        return YES;
//    } else {
//        return [super canPerformAction:action withSender:sender];
//    }
//}

@end
//=========================================================================================================================================================================

