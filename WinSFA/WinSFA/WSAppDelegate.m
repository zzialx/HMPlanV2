//
//  WSAppDelegate.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSAppDelegate.h"
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UserNotifications/UserNotifications.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <LenzBusinessSDK/LenzBusinessSDK.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "WSDeviceRotateTool.h"
#import "WSFuncsBean.h"
#import "WSDictBean.h"
#import "MainViewController.h"
#import "WSLoginViewController.h"
#import "WSModifyPasswdViewController.h"
#import "WSAppData.h"
#import "WSAppSettingViewController.h"
#import "WSRequestHelper.h"
#import "WSCurrentTime.h"
#import "SaasViewController.h"
#import "SaasEnterViewController.h"
#import "FileManager.h"
#import "WCLogManager.h"
#import "WSManuallyUploadViewController.h"
#import "WinSFA.h"
#import "WSJSONBuilder.h"
#import "WSOfflineDataManager.h"
#import "MainViewController_iPad.h"
#import "WSTouchRecord.h"
#import "WSLockScreenView.h"
#import "WSWelcomeView.h"
#import "WSBeaconManager.h"
#import "MultipeerManager.h"
#import "WSFuncsBeanArray.h"
#import "BaseViewController.h"
#import "WSRequestBase.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "WSEnvrionment.h"
#import "WSMjetLoginManager.h"
#import "WSWelcomeEnterView.h"
#import "UINavigationController+Additions.h"
#import "WSSplitViewController.h"
#import "WSLoginDataProcessService+DB.h"
#import "WSBaseStoreDataTable.h"
#import "WSTestTools.h"
#import "WSSpecialAcvtListViewController.h"
#import "WSCommunicateViewController.h"
#import "WSChartConst.h"
#import "WSAllStoresViewController.h"
#import "WCTabBarController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSEnvrionment.h"
#import "SDImageCache.h"
#import "InitSwipePasswordViewController.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSEnvrionment.h"
#import "WSBaseFunsDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSOpenFeedbackView.h"
#import "WSBdLocationDataTable.h"
#import "WSFeatureVideoViewController.h"
#import "WSBaseFunsDBService.h"
#import "WSSubMenuViewController.h"
#import "WSBaseStoreDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSCalendarAlarmDBService.h"
#import "WSCalendarEventTools.h"
#import "WWKApi.h"
#import "IQKeyboardManager.h"
#import "WSPaiPaiManager.h"
#import "WSTelephoneOrderViewController.h"
#import "WSMyMsgAcvtListViewController.h"
#import "WinJSBridgeViewController.h"
#import "WSAppDelegate+Addtitions.h"
#import "WSSellFloatWindowManager.h"

#define kForceQuitFireTime          @"fireTime"
#define kForceQuitFireTimeString    @"fireTimeString"
#define kFeedBackFilter             @"wtfk"
#define kLastPlayFeatureVideoKey    @"lastPlayFeatureVideo"
#define kShortCutFC                 @"shortCutFc"
#define kShortCutIsStoreFunc        @"shortCutIsStoreFunc"
#define kOBSS3URL                   @"obs.cn-north-1.myhwclouds.com:443"
//=============================================================================================================================================

@interface WSAppDelegate () <UITabBarControllerDelegate, UNUserNotificationCenterDelegate,
WSFeatureVideoDelegate, WWKApiDelegate, BMKGeneralDelegate, BMKLocationAuthDelegate> {
    
    WSLockScreenView *lockView;
}

@property (nonatomic, assign) BOOL startAPP;
@property (nonatomic, assign) BOOL isShowTabBar;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, copy) NSString *WeChatAppId;
@property (nonatomic, copy) NSString *QQAppId;
@property (nonatomic, copy) NSString *QYWeiXinAppId;
@property (nonatomic, strong) NSTimer *iTimer;
@property (nonatomic, strong) NSTimer *backgroudGPSTimer;
@property (nonatomic, strong) WCBaseViewController* mainVC;
@property (nonatomic, strong) WSOpenFeedbackView *openFeedbackView;

@end
//=============================================================================================================================================

@implementation WSAppDelegate
@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize iTimer = _iTimer;
@synthesize saasVC;
@synthesize saasEnterViewControll;
@synthesize chatViewControll;
@synthesize registerVC;

#pragma mark - 实现application:didFinishLaunchingWithOptions:协议(程序即将启动协议)
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automaticDeparture:) name:AUTOMATIC_DEPARTURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureScreenShot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    [WSAppDelegate registerNotification];
    [self registerModelNotifi];
    
    [WSAppDelegate setIQKeyBoard];
    [WSAppDelegate setUpUISkinStyle];
    [WSAppDelegate saveUserFirstLaunch];
    [WSAppDelegate setLogManagerConfig];
    [WSAppDelegate setSDImageConfig];
    [WSAppDelegate writeSystemInfoToLog];
    [WSAppDelegate cleanupExpireFile];
    
    [WSAppDelegate initRongCloudSDK];
    [[WSPaiPaiManager sharedInstance] registerPaiPai];
    [self registerAppShareKey];
    [self registerLocationKey];
    [self registerUMPushSDKWithOptions:launchOptions application:application];
    
    [self performSelector:@selector(uploadException) withObject:nil afterDelay:35.0f];
    [WSAppDelegate uploadCrashFile];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self showLoginAndClearAppDatasByIsLogout:NO];
    [self.window makeKeyAndVisible];
    [WSSellFloatWindowManager showSellFloatWindow];

    return YES;
}

#pragma mark - 实现applicationDidEnterBackground:协议(程序进入后台协议)
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    __weak __typeof__ (self) wself = self;
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"bgTask" expirationHandler:^{
        
        __strong __typeof (wself) sself = wself;
        [sself stopKeepAlive];
    }];
    
    NSString *lockout = [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_RUN_IN_BACKGROUND];
    if (lockout.integerValue > 0) {
        [[WSTouchRecord sharedManager] stopTimer];
    }
    
    NSInteger chatnum = [self getUnReadMsgNumber];
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    NSString *unLeavedStoreName = inOutStoreObj.name.length > 0 ? inOutStoreObj.name : inOutStoreObj.memo1;
    if (unLeavedStoreName && [self appAllStoreCount] > 1) {
        [self createLocalNotificationWithTitle:NSLocalizedString(@"not_leave_store_tip", nil) message:unLeavedStoreName];
    }
    else {
        UIApplication *app = [UIApplication sharedApplication];
        [app setApplicationIconBadgeNumber:chatnum];
    }
    
    NSInteger badgeCount = 0;
    NSInteger unUploadAndRead = [self.mainVC markBadgeForMessage];
    badgeCount = unUploadAndRead;
    NSString *unUploadDataString = [NSString stringWithFormat:NSLocalizedString(@"background_unupload_tip", nil) , unUploadAndRead];
    if (unLeavedStoreName && [unLeavedStoreName length] > 0) {
        badgeCount += 1;
    }
    if (unUploadAndRead != 0) {
        [self createUnUploadDataLocalNotificationWithBody:unUploadDataString badgeCount:badgeCount+chatnum];
    }
    if (!unLeavedStoreName && badgeCount == 0) {
        [self removeLocalNoticationExceptEaseMob];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setApplicationIconBadgeNumber:badgeCount+chatnum];
    
    [[WSLocationManager getInstance] stopUpdatingLocationWithActive:NO];
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    if (enableLocation != nil && [enableLocation isEqualToString:@"1"]) {
        [[WSLocationManager getInstance] startUpdatingLocationWithActive:NO];
    }
    
    [[WSBeaconManager getInstance] didEnterBackground];
    
    NSString *enableMultipeer = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_MULTIPEER];
    if ([enableMultipeer isEqualToString:@"1"]) {
        [[MultipeerManager sharedManager] stopServices];
    }
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 实现applicationWillEnterForeground:协议(程序进入前台协议)
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self stopKeepAlive];
    [self removeLocalNoticationExceptEaseMob];
    
    [[WSLocationManager getInstance] stopUpdatingLocationWithActive:NO];
    
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    if (enableLocation != nil && [enableLocation isEqualToString:@"1"]) {
        [[WSLocationManager getInstance] startUpdatingLocationWithActive:NO];
    }
    
    [[WSBeaconManager getInstance] willEnterForeground];
    
    NSString *enableMultipeer = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_MULTIPEER];
    if ([enableMultipeer isEqualToString:@"1"]) {
        [[MultipeerManager sharedManager] startServices];
    }
}

#pragma mark - 实现userNotificationCenter:willPresentNotification:withCompletionHandler:协议 (将通知传递给前台运行的app协议)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

#pragma mark - 实现userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:协议 (将用户对通知响应结果告诉app协议)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    LogInfo(@"WSAppDelegate -- userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: userInfo = %@", userInfo);
    
    [self removeLocalNoticationExceptEaseMob];
}

#pragma mark - 注册推送权限方法
- (void)registerUMPushSDKWithOptions:(NSDictionary *)launchOptions application:(UIApplication *)application {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        LogInfo(@"WSAppDelegate -- registerUMPushSDKWithOptions:application: granted = %@", (granted ? @"YES" : @"NO"));
    }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - 创建本地推送消息方法(未离店提醒使用)
- (void)createLocalNotificationWithTitle:(NSString *)title message:(NSString *)msg {
        
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.body = [NSString stringWithFormat:@"%@ %@", msg, title];
    content.userInfo = [NSDictionary dictionaryWithObject:UNLEAVED_STORE_PUSH forKey:LOCAL_PUSH_KEY];
    
    NSString *identifier = @"unleavedStorePushIdentifier";
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:1.0f] timeIntervalSinceNow];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        LogInfo(@"WSAppDelegate -- createLocalNotificationWithTitle: error = %@", error);
    }];
}

#pragma mark - 创建本地推送消息方法(未上传数据提醒使用)
- (void)createUnUploadDataLocalNotificationWithBody:(NSString *)body badgeCount:(NSInteger)count {
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.sound = [UNNotificationSound defaultSound];
    content.body = body;
    content.badge = [NSNumber numberWithInteger:count];
    content.userInfo = [NSDictionary dictionaryWithObject:UNUPLOADDATA_COUNT_PUSH forKey:UNUPLOADDATA_COUNT_KEY];
    
    NSString *identifier = @"unuploaddataCountPushIdentifier";
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:1.0f] timeIntervalSinceNow];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        LogInfo(@"WSAppDelegate -- createUnUploadDataLocalNotificationWithBody:badgeCount: error = %@", error);
    }];
}

#pragma mark - 清除全部本地通知方法
- (void)removeAllLocalNotification {
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setApplicationIconBadgeNumber:0];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
}

#pragma mark - 清除本地通知方法(EaseMob消息除外 但现在不存在EASEMOB_RECEIVE_MESSAGE_KEY类型数据 等同于全部删除)
- (void)removeLocalNoticationExceptEaseMob {
    
    [self removeAllLocalNotification];
}

#pragma mark - 停止保持活力方法(针对bgTask处理)
- (void)stopKeepAlive {
    
    if (self.bgTask != UIBackgroundTaskInvalid) {
        
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}










-(void)SaasVC
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"saasenter" object:nil];
    WSLoginViewController *loginVC = [[WSLoginViewController alloc] init];
    WCNavigationController *navController = [[WCNavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = navController;
    
    self.saasVC = [[SaasViewController alloc] init];
    [self.window addSubview:self.saasVC.view];

    [self.window makeKeyAndVisible];

}
- (void)regsiterEnterLogin{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"regsiterEnterLogin" object:nil];
    [self showLoginAndClearAppDatasByIsLogout:NO];
    
}
- (BOOL)offlineLoginWhenLaunch {
    WSLoginViewController *loginViewController = [[WSLoginViewController alloc] init];
    BOOL isOfflineLogin = [loginViewController offlineLoginWhenLaunch];
    if (isOfflineLogin) {
        [self loginSuccess];
        return YES;
    }
    return NO;
}

//显示login和清除应用程序数据
- (void)showLoginAndClearAppDatasByIsLogout:(BOOL)isLogout
{
    LogTrace(); //输出日志
    if([self.window.rootViewController isKindOfClass:[UINavigationController class]]){ //如果根节点时一个UINavigationController类
        
        UINavigationController *rootNav = (UINavigationController *)self.window.rootViewController; //获取rootviewcontroller
        
        if(rootNav.topViewController!=nil && [rootNav.topViewController isKindOfClass:[WSLoginViewController class]]){ //如果topviewcontroller是WSLoginViewController时
        
            [WSAppData removeAll];//移除所有数据
            return;
        }
    }
    
    [WSAppData removeAll]; //移除所有数据
    //YIHAIKERRY-4249
    if (isLogout) {
        [WSAppData removeIsShowLoginRedirect];
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_LOGIN_SUCCESS]; //移除所有数据
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //2017-10-09-yuanji-针对用户自动选择退出登陆工况时，再次进入登陆界面时不在记录密码
    if(isLogout)
    {
//        YIHAIKERRY-1822 董宏 在清空记录密码的时候 也清空手势密码的存储
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLevel2Password];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_GESTURE_PASSWORD_LAST_USED_DATE];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_PASSWORD];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD_LAST_LOGIN];

        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (!isLogout) {
        if ([self offlineLoginWhenLaunch]) {
            return;
        }
    }
    
    WSLoginViewController *loginVC = [[WSLoginViewController alloc] init]; //实例化WSLoinViewController

    WCNavigationController *navController = [[WCNavigationController alloc] initWithRootViewController:loginVC];//初始化WCNavigationController
    
    [[NSNotificationCenter defaultCenter] addObserver:loginVC
                                             selector:@selector(fillUserIdAndPass:)
                                                 name:OpenAppByOtherApps
                                               object:nil];//添加通知，此通知会在其他app打开当前app是调用
    
    self.window.rootViewController = navController; //设置rootViewcontroller
    self.mainVC = nil;
    
}

#pragma mark notification method
//自动离店开始监听通知
- (void)automaticDeparture:(NSNotification*)noti
{
//    NSDictionary *dic = [noti userInfo];
//    if(dic)
//    {
//        [[NSUserDefaults standardUserDefaults]  setObject:dic forKey:AUTOMATIC_DEPARTURE];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else
//    {
//        if (self.startAPP) {
//            return;
//        }
//        self.startAPP = YES;
//        NSDictionary *dic = [[NSUserDefaults standardUserDefaults]  objectForKey:AUTOMATIC_DEPARTURE];
//        if (!dic||dic.count<1) {
//            return;
//        }
//    }
//    self.bgLocation = [[BGLogation alloc]init];
//    [self.bgLocation startLocation];
}
// 截屏
- (void)captureScreenShot:(NSNotification *)notification {
    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean* fb = [funcsArray getFuncsBeanWithFilter:kFeedBackFilter];
    if (!fb) {
        return;
    }
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvtBean = [service queryAcvtByFilter:fb.filter acvtCode:fb.filter];
    if (!acvtBean) {
        return;
    }

    [self.openFeedbackView removeFromSuperview];
    [self.window addSubview:self.openFeedbackView];
    [self.openFeedbackView showWithFuncs:fb acvtBean:acvtBean];
}

#pragma mark - 登录成功回调方法
- (void)loginSuccess{
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_LOGIN_ALL_TIME forcePrint:YES];
    
    [[NSUserDefaults standardUserDefaults]  setObject:@"0" forKey:@"tabBarSytle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNumber *onlineConsultationSwitchStateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION_SWITCH_STATE];
    if (onlineConsultationSwitchStateNumber == nil) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:ONLINE_CONSULTATION_SWITCH_STATE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
    UIViewController *mainNavigationController = nil;
    
    BOOL isBottomMenu = [WSEnvrionment getIsBottomMenu];
    NSString *bottomMenuStr = [[NSUserDefaults standardUserDefaults] objectForKey:BOTTOM_MENU];
    if ([bottomMenuStr isEqualToString:@"1"]) {
        isBottomMenu = YES;
    }
    
    self.isShowTabBar = NO;
    if (INTERFACE_IS_PHONE && isBottomMenu && fba.funcsArray.count < 6) {
        self.isShowTabBar = YES;
    }
    
    [self downloadFuncsImagesWithFuncsArray:fba.funcsArray];

    if (INTERFACE_IS_PHONE && !self.isShowTabBar) {
    
        self.mainVC = [[MainViewController alloc]init];
        
        NSString *FeaturesLString = [WSAppData getObjectbyKey:EMPNAME];
        self.mainVC.title = FeaturesLString;
        WCNavigationController *homeNavigationController = [[WCNavigationController alloc]initWithRootViewController:self.mainVC];
        if (IOS7_OR_LATER) {
            
            homeNavigationController.navigationBar.translucent = NO;
            [homeNavigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
        }
        mainNavigationController = homeNavigationController;

        NSString *checkUploadFlag = [WSAppData getObjectbyKey:CHECK_UPLOADED_DATA];
        if ([checkUploadFlag isEqualToString:@"1"] || [checkUploadFlag isEqualToString:@"2"]) {
            
            WSOffLineUploadTable *l_leaveStore = [WSOffLineUploadTable sharedTable];
            NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
            if (pending > 0) {
                
                WSFuncsBean *funcsBean;
                for (WSFuncsBean *fb in fba.funcsArray) {
                    
                    if ([fb.fv isEqualToString:@"TB_V180"]) {
                        funcsBean = fb;
                        break;
                    }
                }
                
                WSManuallyUploadViewController *manullyUploadController;
                if (funcsBean) {
                    manullyUploadController = [[WSManuallyUploadViewController alloc] initWithFuncs:funcsBean];
                }
                else {
                    manullyUploadController = [[WSManuallyUploadViewController alloc] init];
                }
                manullyUploadController.isInCheckUploadedDataFlow = YES;
                [homeNavigationController pushViewController:manullyUploadController animated:YES];
            }
        }
    }
    else if(INTERFACE_IS_PAD) {
        
        self.mainVC = [[MainViewController_iPad alloc] init];
        mainNavigationController = [[WCNavigationController alloc] initWithRootViewController:self.mainVC];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"tabBarSytle"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        WCTabBarController *tabBarController = [[WCTabBarController alloc] init];
        tabBarController.delegate = self;
        NSMutableArray* vcArray = [NSMutableArray array];
        
        for (WSFuncsBean *fb in fba.funcsArray) {

            NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
            WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
            if (vc == nil) {
                continue;
            }

            if (fb.funcsArray && fb.funcsArray.count > 0) {
                
                WSFuncsBean* cfb = [fb.funcsArray objectAtIndex:0];
                if ([cfb.fv isEqualToString:@"TAB_CHAT"]) {
                    self.chatViewControll = vc;
                }
            }

            [self setTabBarItemWithVC:vc andFuncsBean:fb];
            
            UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:vc];
            if ([vc isKindOfClass:[WSTelephoneOrderViewController class]]) {
                
                WSTelephoneOrderViewController *tipVc = (WSTelephoneOrderViewController *)vc;
                [tipVc handleTabBarItemBadgeValue];
            }
            else if ([vc isKindOfClass:[WSMyMsgAcvtListViewController  class]]) {
                
                WSMyMsgAcvtListViewController *tipVc = (WSMyMsgAcvtListViewController *)vc;
                [tipVc handleTabBarItemBadgeValue];
            }
            
            [vcArray addObject:navCon];
        }
        
        [tabBarController setViewControllers:vcArray];
        [tabBarController setSelectedIndex:0];
        
        mainNavigationController = tabBarController;
        UIViewController* viewController = [tabBarController.viewControllers firstObject];
        viewController.parentViewController.title = [fba.funcsArray.firstObject name];
    }
    
    self.window.rootViewController = mainNavigationController;
    [self.window makeKeyAndVisible];
    
    NSString *isForceExit = [[NSUserDefaults standardUserDefaults] objectForKey:IS_FORCE_EXIT];
    NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
    BOOL isOfflineLoginWhenLaunch = [WSEnvrionment getUseOfflineLoginWhenLaunch];
    if ([isForceExit isEqualToString:@"0"] || [isOfflineLanding isEqualToString:@"1"] || isOfflineLoginWhenLaunch) {
        [self removeForceQuit];
    }
    else {
        [self addForceQuit];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:APP_LOGIN_SUCCESS];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self removeWelcomeView:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUnreadNumber) name:WS_CHATNOTIFY_RESETUNREADNUMBER object:nil];
    
    [self checkPassiveLocation];
    [[WSBeaconManager getInstance] checkBeacon];
    
    NSString *enableMultipeer = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_MULTIPEER];
    if ([enableMultipeer isEqualToString:@"1"]) {
        
        [[MultipeerManager sharedManager] startServices];
    }
    
    [self removeAllLocalNotification];
    [self createCalendarWithDB];
    self.sfaHasLogin = YES;
    
    NSString *savedLevel2Password = [[NSUserDefaults standardUserDefaults] objectForKey:kLevel2Password];
    BOOL userGesturePassword = [WSEnvrionment getUserGesturePassword];
    if (!(savedLevel2Password.length > 0) && userGesturePassword) {
        [self initAndShowSwipePasswordViewController];
    }
    
    if (INTERFACE_IS_PAD) {
        
        WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
        NSString *unLeavedStoreName = inOutStoreObj.name.length>0?inOutStoreObj.name:[inOutStoreObj memo1];
        if (unLeavedStoreName) {
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:unLeavedStoreName forKey:UNLEAVED_STORE];
            [[NSNotificationCenter defaultCenter] postNotificationName:ALERT_UNLEAVED_STORE object:nil userInfo:dic];
        }
    }
    
    [self showLoginTipAlert];
    
    [[WSPaiPaiManager sharedInstance] getLenzTaskInfo];
    
    [self uploadRemoteNoticeDeviceToken];
    
    //连接RC IM Server
    [WSAppDelegate connectRongCloudIMServer];
}

- (void)showLoginTipAlert
{
    NSArray *loginTipArray = [WSAppData getObjectbyKey:LOGIN_TIP];
    NSDictionary *loginTipDic = [loginTipArray firstObject];
    NSString *message = [loginTipDic objectForKey:@"tip"];
    
    if (message && message.length > 0) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
        [alert show];
    }
}

- (void)initAndShowSwipePasswordViewController
{

    NSString *swipePassword = [[NSUserDefaults standardUserDefaults] objectForKey:kLevel2Password];
    
    InitSwipePasswordViewController *initSwipePasswordVC = [[InitSwipePasswordViewController alloc] init];
    if (swipePassword.length > 0) {
        initSwipePasswordVC.swipeType = SwipeTypeUnlock;
    }else{
        initSwipePasswordVC.swipeType = SwipeTypeInit;
    }
        __weak typeof(self) weakself = self;
    initSwipePasswordVC.finishSwipeBlock= ^{
        //        if (weakself.loginBlock) {
        //            weakself.loginBlock();
        //        }
        [weakself.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    [self.window.rootViewController presentViewController:initSwipePasswordVC animated:YES completion:^{
        
    }];
}

- (void)setTabBarItemWithVC:(UIViewController *)vc andFuncsBean:(WSFuncsBean *)fb {
    
    UIImage *SelectedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_tabBar_selected_server.png", fb.iconOfDone]];
    UIImage *UnselectedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_tabBar_unselected_server.png", fb.icon]];
    if (!SelectedImage) {
        SelectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tabBar_Selected.png",fb.fv]];
    }
    if (!UnselectedImage) {
        UnselectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_tabBar_Unselected.png",fb.fv]];
    }

    NSString *tabbarItemTitle = fb.name;
    if ([WSEnvrionment getNotUseTabBarItemTitle]) {
        tabbarItemTitle = nil;
    }

    SelectedImage = [SelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UnselectedImage = [UnselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:tabbarItemTitle image:UnselectedImage selectedImage:SelectedImage];
    
    if ([WSEnvrionment getNotUseTabBarItemTitle]) {
        vc.tabBarItem.imageInsets=UIEdgeInsetsMake(6, 0,-6, 0);
    }
    
    UIColor *color119 = [UIColor colorWithRed:119 / 255.0f green:119 / 255.0f blue:119 / 255.0f alpha:1];
    UIColor *tabBabNormalColor = [UIColor colorForKey:@"TabBar"] ? [UIColor colorForKey:@"TabBar"] : color119;
    NSDictionary* normalDic = [NSDictionary dictionaryWithObject:tabBabNormalColor forKey:NSForegroundColorAttributeName];
    
    UIColor *color108 = [UIColor colorWithRed:8 / 255.0f green:41 / 255.0f blue:108 / 255.0f alpha:1];
    UIColor *tabBabHighlightColor = [UIColor highlightColorForKey:@"TabBar"] ? [UIColor highlightColorForKey:@"TabBar"] : color108;
    NSDictionary* selectedDic = [NSDictionary dictionaryWithObject:tabBabHighlightColor forKey:NSForegroundColorAttributeName];
    
    if (@available(iOS 13, *)) {
        
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalDic;
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedDic;
        vc.tabBarItem.standardAppearance = appearance;
        
        [[UITabBar appearance] setTintColor:tabBabHighlightColor];
        [[UITabBar appearance] setUnselectedItemTintColor:tabBabNormalColor];
    }
    else {

        [vc.tabBarItem setTitleTextAttributes:normalDic  forState:UIControlStateNormal];
        [vc.tabBarItem setTitleTextAttributes:selectedDic  forState:UIControlStateSelected];
    }
}

// 下载funcs功能对应的显示图片并保存图片到本地磁盘缓存
- (void)downloadFuncsImagesWithFuncsArray:(NSArray *)funcsArray
{
     for(WSFuncsBean* fb in funcsArray){
         
         NSString *oldIconStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_unselectedIcon", fb.icon]];
         if (fb.icon.length > 0 && ![oldIconStr isEqualToString:fb.icon]) {
             NSMutableString *unselectedIconUrlSeg = [NSMutableString stringWithFormat:@"%@", fb.icon];
             [unselectedIconUrlSeg replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, unselectedIconUrlSeg.length)];
             NSString *unselectedImageUrlStr = [NSString stringWithFormat:@"%@%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName], unselectedIconUrlSeg];
             
             [[WSRequestHelper shareInstance] downloadImageWithUrl:unselectedImageUrlStr progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                 // 处理下载进度
             } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
               
                  if (error) {
                      DDLogDebug(@"error is %@",error);
                  }
                  if (image) {
                      // 图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
                      [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_tabBar_unselected_server.png",fb.icon] toDocument:NO];
                      
                      [[NSUserDefaults standardUserDefaults] setObject:fb.icon forKey:[NSString stringWithFormat:@"%@_unselectedIcon", fb.icon]];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      
                      if (self.isShowTabBar) {
                          [self refreshTabBarItemImageWithFuncsBean:fb];
                      }else{
                          if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
                              UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
                              UIViewController *navRootVC = [[navController viewControllers] firstObject];
                              if ([navRootVC isKindOfClass:[MainViewController class]]) {
                                  MainViewController *mainVC = (MainViewController *)navRootVC;
                                  [mainVC refreshMainCellViewImageWithFuncsBean:fb];
                              }
                          }
                      }
                  }
              }];

         }
         
         NSString *oldIconOfDoneStr = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_selectedIcon", fb.iconOfDone]];
         if (fb.iconOfDone.length > 0 && ![oldIconOfDoneStr isEqualToString:fb.iconOfDone]) {
             
             NSMutableString *selectedIconUrlSeg = [NSMutableString stringWithFormat:@"%@", fb.iconOfDone];
             [selectedIconUrlSeg replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, selectedIconUrlSeg.length)];
             NSString *selectedImageUrlStr = [NSString stringWithFormat:@"%@%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName], selectedIconUrlSeg];

             [[WSRequestHelper shareInstance] downloadImageWithUrl:selectedImageUrlStr progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                 // 处理下载进度
             } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
                  if (error) {
                      DDLogDebug(@"error is %@",error);
                  }
                  if (image) {
                      // 图片下载完成  在这里进行相关操作，如加到数组里 或者显示在imageView上
                      [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"%@_tabBar_selected_server.png",fb.iconOfDone] toDocument:NO];
                      
                      //
                      [[NSUserDefaults standardUserDefaults] setObject:fb.iconOfDone forKey:[NSString stringWithFormat:@"%@_selectedIcon", fb.iconOfDone]];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      
                      if (self.isShowTabBar) {
                          [self refreshTabBarItemImageWithFuncsBean:fb];
                      }else{
    
                      }
                  }
              }];

         }
         
    }
}

- (void)refreshTabBarItemImageWithFuncsBean:(WSFuncsBean *)fb
{
    NSString *funcClassName = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        
        for (UIViewController *vc in tabBarController.viewControllers) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navController = (UINavigationController *)vc;
                NSString *rootVCClassName = [[[navController viewControllers] firstObject] className];
                UIViewController *navRootVC = [[navController viewControllers] firstObject];
                
                if ([rootVCClassName isEqualToString:funcClassName]) {
                    [self setTabBarItemWithVC:navRootVC andFuncsBean:fb];
                    break;
                }
            }
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TAB_JUMP_FC];

    WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean* fb = [fba.funcsArray objectAtIndex:tabBarController.selectedIndex];
    viewController.parentViewController.title = fb.name;
    
    UIViewController *controller = (UINavigationController *)viewController.childViewControllers.lastObject;
    
    if (controller && [controller isKindOfClass:[SuperBarViewController class]]) {
        
        SuperBarViewController *superBarVC = (SuperBarViewController *)controller;
        
        if (superBarVC.selectViewController && [superBarVC.selectViewController isKindOfClass:[SuperWorkSpaceViewController class]]) {
            
            SuperWorkSpaceViewController *workSpaceVC= (SuperWorkSpaceViewController *)superBarVC.selectViewController;
            workSpaceVC.isLoaded = NO;
        }
    }

    if(fb.funcsArray.count>0){
        WSFuncsBean *jumpFuncsBean = [fb.funcsArray objectAtIndex:0];
        if (jumpFuncsBean.fv && [jumpFuncsBean.fv isEqualToString:@"TAB_V20001"]) {
            [self callOrDownLoadOtherAPPWith:jumpFuncsBean];
        }
    }
    
}

- (void)callOrDownLoadOtherAPPWith:(WSFuncsBean *)funcs
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP];
    if (!userId) {   userId = @"";    }
    if (!password) {   password = @"";    }
    NSDictionary *dic = @{@"userID": userId, @"password" : password};
    [self callOrDownLoadOtherAPPWith:funcs paramsDic:dic];
}

- (void)callOrDownLoadOtherAPPWith:(WSFuncsBean *)funcs paramsDic:(NSDictionary *)paramsDic {
    
    NSMutableString *string = [NSMutableString stringWithString:[NSString stringNotNilWithValue:funcs.jumpUrl]];
    if (paramsDic) {
        
        NSString *json = [paramsDic JSONString];
        [string appendString:[json mk_urlEncodedString]];
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:string]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string] options:@{} completionHandler:nil];
    }
    else {
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"not_to_install_the_application", nil), [NSString stringNotNilWithValue:funcs.iParentFuncsBean.name]];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message: message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil)  block:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            NSString *urlString = [NSString stringNotNilWithValue:funcs.iosOpenUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        } ];
        [alert show];
    }
}



-(void)removeWelcomeView:(NSNotification*)aNot
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeWelcomeView" object:nil];
    
    [WSTouchRecord sharedManager].login=YES;
    
    NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
    if(lockout.integerValue>0){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLockScreenVC:) name:@"showLockScreenVC" object:nil];
        
        [[WSTouchRecord sharedManager] resetTimer];
    }

}

-(void)showLockScreenVC:(NSNotification*)aNot
{
    LogInfo(@"");
    NSArray *subViews = [self.window.rootViewController.view subviews];
    
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[WSLockScreenView class]]) {
            LogInfo(@"subView is WSLockScreenView class");
            return ;
        }
    }
    
    lockView=[[WSLockScreenView alloc] initWithFrame:self.window.rootViewController.view.bounds];
    [self.window.rootViewController.view addSubview:lockView];
}

- (void)logout{
    LogTrace();
    
    self.sfaHasLogin = NO;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SSOLOGINSTATE];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_IN_OFFLINE_LOGIN];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:LOGIN_SAAS_SEND_VERSION];
   
    [WSTouchRecord sharedManager].login=NO;
    
    NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_TIMEOUT];
    if(lockout.integerValue>0){
        [[WSTouchRecord sharedManager] stopTimer];
    }

    //log out后停止一些操作，cancel 所有请求。
    [self stopBackgroundUploadGPS];
    [[WSOfflineDataManager sharedInstance] stopAutoUpload];
    [[WCNetworkEngine sharedInstance] cancelAllRequest];
    [self.window removeAllSubviews];
    //保存应用上次退出状态以及相关信息
    [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusNormal] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    NSString *versionCode = [WSEnvrionment getAppSystemVersion];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    [WSRongCloudManager logoutConnectRongCallKitIMServer];
    
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERNAME_CALL_APP];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PASSWORD_CALL_APP];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self clearCookies];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [[WSMjetLoginManager sharedInstance] mjetLogout];
    
    [WSBaseStoreOtherDataDBService clearStoresSearchCodeFlag];
    

    
    [self showLoginAndClearAppDatasByIsLogout:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *enableMultipeer = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_MULTIPEER];
        if ([enableMultipeer isEqualToString:@"1"]) {
            [[MultipeerManager sharedManager] stopServices];
        }
        
    });
    // 退出登录不应该清除上次登录人的用户名。因为如果清除了,cacheDataVersionJ就会一直传一样的，获取不到数据---与安卓一致
    //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME_LAST_LOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD_LAST_LOGIN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SWIPE_PASSWORD_IS_RIGHT];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)clearCookies
{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMjetLoginInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    if ([WSMjetLoginManager isNeedMejtLogin]) {
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray* siteCookies = [cookies cookies];
        for (NSHTTPCookie* cookie in siteCookies) {
            [cookies deleteCookie:cookie];
        }
        
        return;
    }
    
    //    获取serverURL
    WSServerIPList *serverIpArr = [WSAppData getObjectbyKey:@"serverURL"];
    if (!serverIpArr.serverIPArray || serverIpArr.serverIPArray.count < 1)
    {
        return;
    }
    WSServerIPController *serverIP = [serverIpArr.serverIPArray objectAtIndex:0];
    NSString *serverUrl = [serverIP ServerIPString];
    if (!serverUrl)
    {
        return;
    }
    
    // 加载webView前 清除cookies
    NSString *baseUrl = [serverUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* siteCookies = [cookies cookiesForURL:[NSURL URLWithString:baseUrl]];
    for (NSHTTPCookie* cookie in siteCookies) {
        [cookies deleteCookie:cookie];
    }
}

// 启用视频播放
- (void)playFeatureVideo {
    WSFeatureVideoViewController *videoController = [[WSFeatureVideoViewController alloc] init];
    videoController.delegate = self;
    self.window.rootViewController = videoController;
    [self.window makeKeyAndVisible];
}

//启用引导页
- (void)saasEnter {
    
    LogInfo(@"%s",__func__);
    
    self.saasEnterViewControll = [[SaasEnterViewController alloc] init];
    self.saasEnterViewControll.view.frame = [[UIScreen mainScreen] bounds];
    [self.window addSubview:saasEnterViewControll.view];
    [self.window makeKeyAndVisible];
}

- (BOOL)registerAgreement{

    BOOL showAuthorizationVC = NO;
    NSString *authorizationContrent = NSLocalizedString(@"termsandconditions", nil);
    if (INTERFACE_IS_PHONE  && authorizationContrent && [authorizationContrent length] > 0){
        NSUserDefaults *firstLauchDefaults = [NSUserDefaults standardUserDefaults];
        BOOL firstLauch = [firstLauchDefaults boolForKey:@"AppFirstLaunch"];
        NSString *authorization = [WSPlistHelper valueForKey:OPEN_TC_EVERY_TIME withPlistName:kConfilgFileName];
        if (authorization == nil) {
            authorization = @"0";
        }
        if ([authorization isEqualToString:@"0"] && firstLauch ) {
            showAuthorizationVC = YES;
        } else if ([authorization isEqualToString:@"1"]) {
            showAuthorizationVC = YES;
        }
    }
    return showAuthorizationVC;
}
- (void)showForceAlertView:(NSTimer *)timer
{
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *sysTime = [formatTime stringFromDate:[NSDate date]];  // 当前时间
    
    NSMutableDictionary *userInfo = [timer userInfo];
    NSString *exitTime = [userInfo objectForKey:@"FIRE_TIME"];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"force_quit_content", nil),exitTime,sysTime];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"force_quit_tip", nil) message:message];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm",nil) block:^{
        [self quit];
    }];
    [alert show];
}

-(void)quit
{
    
    //保存应用上次退出状态以及相关信息
    [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusNormal] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    NSString *versionCode = [WSEnvrionment getAppSystemVersion];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MAIN_TIPS];

    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
    [self logout];

}

- (NSDictionary *)getForceQuitDateAndTime {
    NSString *bizDate =[WSCurrentTime getDateString];
    NSString *exitTime = [WSAppData getObjectbyKey:FORCEEXITTIME];
    if (exitTime == nil || [exitTime isEqualToString:@"null"]) {
        exitTime = @"04"; // 凌晨4点
    }
    
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatTime.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    // 得到临时退出时间, 判断并可能重置退出时间
    NSString *tmpFireTime = [NSString stringWithFormat:@"%@ %@:00:00", bizDate, exitTime];
    //12小时制需要重置日期格式
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fireDate = [formatTime dateFromString:tmpFireTime];
    [formatTime setDateFormat:@"HH"];
    NSString *time = [formatTime stringFromDate:[NSDate date]];
    if ([exitTime intValue] <= [time intValue]) {
        fireDate = [fireDate dateByAddingTimeInterval:24*60*60];
    }
    // 系统退出时间点
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *fireTime = [formatTime stringFromDate:fireDate];
    
    NSDictionary *dict = @{kForceQuitFireTime: fireDate==nil?@"":fireDate, kForceQuitFireTimeString: fireTime==nil?@"":fireTime};
    return dict;
}

- (NSDate *)getForceQuitTime {
    NSDictionary *dict = [self getForceQuitDateAndTime];
    return [dict objectForKey:kForceQuitFireTime];
}

-(void)addForceQuit
{
    NSMutableDictionary  *userInfo = [NSMutableDictionary dictionary];

    NSDictionary *dict = [self getForceQuitDateAndTime];
    
    NSString *fireTime = [dict objectForKey:kForceQuitFireTimeString];
    [userInfo setValue:fireTime forKey:@"FIRE_TIME"];
    
    NSDate *fireDate = [dict objectForKey:kForceQuitFireTime];
    
    LogInfo(@"\n[ LogInfo - fireTime = %@ ]\n", fireTime);
    [self.iTimer invalidate];
    self.iTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:0 target:self selector:@selector(showForceAlertView:) userInfo:userInfo repeats:NO];
    NSRunLoop *theRunLoop=[NSRunLoop currentRunLoop];
    [theRunLoop addTimer:self.iTimer forMode:NSRunLoopCommonModes];
}

- (void)removeForceQuit
{
    if (self.iTimer && [self.iTimer isValid]) {
        [self.iTimer invalidate];
        self.iTimer = nil;
    }
}

- (void)tencentDidLogin{
    
    NSLog(@"tencentDidLogin 成功");
}

- (void)tencentDidNotLogin:(BOOL)cancelled{

    NSLog(@"tencentDidNotLogin 失败");
}

- (void)tencentDidNotNetWork{

    NSLog(@"tencentDidNotNetWork 未连上网");
}

/*
 重写设置设备方向控制
 */
-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return [WSDeviceRotateTool supportedInterfaceOrientationsForWindow:window application:application ];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    LogTrace();
    
    NSString* lockout= [[NSUserDefaults standardUserDefaults] objectForKey:LOCK_RUN_IN_BACKGROUND];
    if(lockout.integerValue>0){
        if([WSTouchRecord sharedManager].login){
            [WSTouchRecord sharedManager].login=NO;
            lockView=[[WSLockScreenView alloc] initWithFrame:self.window.rootViewController.view.bounds];
            [self.window.rootViewController.view addSubview:lockView];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    LogTrace();
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGGE_MAINCELL_STATENORMAL object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KCheckNetWork" object:self userInfo:nil];

    if (self.iTimer != nil && self.iTimer.isValid) {
        NSDate *nowDate = [NSDate date];
        NSDate *fireDate = [self.iTimer fireDate];
        NSComparisonResult result = [nowDate compare:fireDate];
        LogInfo(@"nowdate = %@ firedate = %@ result = %ld", nowDate, fireDate, (long)result);
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            [self.iTimer invalidate];
            self.iTimer = nil;
            [self showLoginAndClearAppDatasByIsLogout:NO];
        }
    }

}


/* For iOS 4.1 and earlier */
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    NSString * urlstr = [ url absoluteString]; //@"wx48a9785f1dc0e4c9://platformId=wechat"
    if ([urlstr isEqualToString:[NSString stringWithFormat:@"%@://platformId=wechat",self.WeChatAppId ]]) {
        
    }else{
        
        [self handleOpenUrl:url];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [self handleOpenUrl:url];
    return YES;
}

- (void)handleOpenUrl:(NSURL*)url
{
    if (!url) {        return;    }
    NSString *string = [url absoluteString];
    if (!string) {   return;   }
     
    NSString *destring = [string urlDecodedString];
    NSArray *array = [destring componentsSeparatedByString:@"//"];
    if (array && [array count] > 1) {
        NSDictionary* dic = [[array objectAtIndex:1] objectFromJSONString];
        NSString *userIdFromOtherApps = [dic objectForKey:@"userID"];
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
        if (![userIdFromOtherApps isEqualToString:userId] && ![userId isEqualToString:@""])
        {
            /*
             先注销 在登陆
             */
            if (userId)
            {
                [self logout];
            }
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:OpenAppByOtherApps object:nil userInfo:dic];
    }
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [WWKApi handleOpenURL:url delegate:self];
}








- (void)gotoShortCutFuncsWithParam:(NSDictionary *)dic {
    NSString *fc = dic[kShortCutFC];

    WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *funcBean = [funcsArray getFuncsBeanWithFC:fc];
    if (!funcBean) {
        LogError(@"gotoShortCut Error fc: %@", fc);
    }
    WSBaseFunsDBService *funcsService = [[WSBaseFunsDBService alloc] init];
    NSString *parentFC = [funcsService getParentFCWithSonFC:fc];
    if ([parentFC length] == 0) {
        LogError(@"gotoShortCut Error No parentFC: %@", fc);
    }
    WSFuncsBean *parentFuncBean = [funcsArray getFuncsBeanWithFC:parentFC];
    if (!funcBean) {
        LogError(@"gotoShortCut Error parentFC: %@", parentFC);
    }
    // MSTD-7295 WSSubMenuViewController 临时方案重构后删除这段逻辑
    WSSubMenuViewController *vc =  [[WSSubMenuViewController alloc] initWithFuncs:parentFuncBean];
    vc.wsSplitController = (WSSplitViewController *)self.window.rootViewController;
    if ([dic[kShortCutIsStoreFunc] boolValue]) {
        WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
        vc.currentStore = [storeService queryOnlyOneStore];
        
        vc.funcBeanArray = [WSFuncsBeanFilterLogicService filterFuncsBean:parentFuncBean.funcsArray withStore:vc.currentStore bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    }
    
    [vc gotoFuncsBean:funcBean];
}

// MSTD-7295  backAction 的创建在 WSBaseWorkFlowViewController 有 WSSubMenuViewController 的地方 重构后删除这种调用逻辑
- (void)backAction {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    
    NSArray* array=[[NSUserDefaults standardUserDefaults] objectForKey:@"peerArray"];
    NSMutableArray* newarray=[NSMutableArray array];
    
    for(NSDictionary* dic in array){
        NSMutableDictionary* newdic=[NSMutableDictionary dictionaryWithDictionary:dic];
        [newdic setObject:@"0" forKey:@"online"];
        [newarray addObject:newdic];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newarray forKey:@"peerArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    NSObject *exitAppStatus = [FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if ([exitAppStatus isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)exitAppStatus;
        if ([number intValue] == 0) {
            //保存应用上次退出状态以及相关信息
            [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusException] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
            [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
            NSString *versionCode = [WSEnvrionment getAppSystemVersion];
            [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
            NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
            [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
            [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
        }
    }

}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // 不能删除
    LogTrace();
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - WSFeatureVideoDelegate
- (void)donePlaying {
    NSString *versionCode = [WSEnvrionment getAppSystemVersion];
    [[NSUserDefaults standardUserDefaults] setObject:versionCode forKey:kLastPlayFeatureVideoKey];
    
    [self showLoginAndClearAppDatasByIsLogout:NO];
}

#pragma mark - gps/WCLocationManagerDelegate
- (void)locationTimerAction {
    
    LogTrace();
    
    if ([[WSLocationManager getInstance] isCurrentTimeInLocationPeriod]) {
        
        LogInfo(@"开始获取被动位置");

        self.isUpdatingLocation = YES;
        
        // SFA-11417 按照安卓逻辑修改，只有超过 LOCATION_CHECK_TIME 才上传位置
        NSNumber *checkTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_CHECK_TIME];
        
        WSBdLocationDataTable *locationTable = [[WSBdLocationDataTable alloc] init];
        NSArray *lastUploadData = [locationTable queryWithCurrentEmpId];
        if ([lastUploadData count] > 0) {
            WSBdLocationDataObject *locationData = lastUploadData[0];
            if (locationData && [locationData.loc_time length] > 0) {
                double nowValue =  [[WSCurrentTime getTimestampString] doubleValue];
                double lastValue = [locationData.loc_time doubleValue] / 1000;
                if (nowValue - lastValue < [checkTime doubleValue]) {
                    LogInfo(@"距离上次上传被动位置时间未超过 %@ 秒不需要上传数据", checkTime);
                    return;
                }
            }
        }
        
        DDLogInfo(@"使用通知方式获取定位回调");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
        [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
    }
    else
    {
        LogInfo(@"当前时间不在被动位置时间范围内，停止timer");
        if (self.backgroudGPSTimer && [self.backgroudGPSTimer isValid]) {
            [self.backgroudGPSTimer invalidate];
            self.backgroudGPSTimer = nil;
        }
        
    }
}

- (void)locationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *aLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    if (error) {
        LogError(@"获取被动位置失败,error:%@",error);
    }
    else
    {
        LogInfo(@"获取被动位置成功,lat:%lf\nlon:%lf", aLocationDescribe.location.coordinate.latitude, aLocationDescribe.location.coordinate.longitude);
    }
    
    LogInfo(@"上传被动位置\nupload background gps at:\nlat:%lf\nlon:%lf", aLocationDescribe.location.coordinate.latitude, aLocationDescribe.location.coordinate.longitude);
    [self uploadLocation:aLocationDescribe];
    
}

- (void)updateLocationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    
    NSError *error = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedErrorKey];
    CLLocation *location = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
    if (error) {
        LogError(@"获取被动位置失败,error:%@",error);
    }
    else
    {
        LogInfo(@"获取被动位置成功,lat:%lf\nlon:%lf", location.coordinate.latitude, location.coordinate.longitude);
    }
    
    LogInfo(@"上传被动位置\nupload background gps at:\nlat:%lf\nlon:%lf", location.coordinate.latitude, location.coordinate.longitude);
    
    if (self.isUpdatingLocation == YES) {
        [[WSLocationManager getInstance] startUpdatesCityInfoWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
            if (aLocationDescribe &&
                aLocationDescribe.detailAddress &&
                [aLocationDescribe.detailAddress isKindOfClass:[NSString class]] )
            {
                    
                  [self uploadLocation:aLocationDescribe];

            }
        }];
        
    }
    
    self.isUpdatingLocation= NO;
    
}


-(void)uploadLocation:(WSLocationDescribe*)locatonDescribe;
{
    LogInfo(@"PASSVIE LOCATION uploadLocation aLocation.horizontalAccuracy:%f", locatonDescribe.location.horizontalAccuracy);
    
    WSRequestHelper* l_upload = [WSRequestHelper shareInstance];
    if (locatonDescribe.location.horizontalAccuracy < 0)
        return;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];

    [l_upload uploadBackGroundGPSWithLocation:locatonDescribe NotifyName:notifyID];

}

- (void)stopBackgroundUploadGPS
{
    if (self.backgroudGPSTimer) {
        if ([self.backgroudGPSTimer isValid]) {
            [self.backgroudGPSTimer invalidate];
        }
        self.backgroudGPSTimer = nil;
    }
}


#pragma mark
#pragma mark about chat UI
/*
 *函数功能：取得当前聊天未读消息数量
 **/
-(NSInteger)getUnReadMsgNumber{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger msgNumber=0;
    for (EMConversation * obj in conversations) {
            msgNumber+=obj.unreadMessagesCount;
    }
    return msgNumber;

}
/*
 *函数功能：取得离点和未上传消息数量
 **/
-(NSInteger)getNotoMsgNumber{
    // 未上传的和未读信息的提示
    NSInteger badgeCount = 0;
    NSInteger unUploadAndRead = [self.mainVC markBadgeForMessage]; // 我的信息未读信息 + 未上传数据条数；
    badgeCount = unUploadAndRead;
    
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    NSString *unLeavedStoreName = inOutStoreObj.name.length>0?inOutStoreObj.name:[inOutStoreObj memo1];
    
    if (unLeavedStoreName && [unLeavedStoreName length] > 0) {
        badgeCount += 1;
    }
    
    return badgeCount;
    
}

-(void) resetUnreadNumber{
    
    if(!self.chatViewControll)
        return;
//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *localNotifications = [app scheduledLocalNotifications];
//    NSInteger notCunt=[localNotifications count];
    
    NSInteger num=[self getUnReadMsgNumber];
    if(num>0){
        NSString * badgeValue = [NSString stringWithFormat:@"%ld",(long)num];
        if (num > 99) {
            badgeValue = @"...";
        }
        self.chatViewControll.tabBarItem.badgeValue = badgeValue;
        // 右上角数字背景色
        if(IOS10_OR_LATER){
            self.chatViewControll.tabBarItem.badgeColor = [UIColor redColor];
        }
    }else{
        self.chatViewControll.tabBarItem.badgeValue = nil;
        // 右上角数字背景色
        if(IOS10_OR_LATER){
            self.chatViewControll.tabBarItem.badgeColor = [UIColor redColor];
        }
    }
}
- (NSInteger)appAllStoreCount  {
    
    NSInteger allStore=0;
    NSString * queryreleatesql =@"select * from ws_base_store_table";
    
    NSMutableArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:queryreleatesql andClassName:@"WSBaseStoreDataObject"];
    if(array){
        allStore=array.count;
    }
    return allStore;
}

- (void)checkPassiveLocation{
    BOOL passiveLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_PASSIVE_LOCATION] boolValue];
    if (passiveLocation) {
        /*
         ExitAppStatusException = 0, // "EXCEPTION"
         ExitAppStatusNormal = 1, // "NORMAL"
         ExitAppStatusForce = 2, // "FORCE_EXIT"
         ExitAppStatusBizdateError = 3 // "BIZDATE_ERROR"
         */
        NSNumber *checkTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_CHECK_TIME];
        
        if (self.backgroudGPSTimer && [self.backgroudGPSTimer isValid]) {
            [self.backgroudGPSTimer invalidate];
        }
        
        NSDate *startDate = [[WSLocationManager getInstance] getLocationBeginDate];
        NSDate *endDate = [[WSLocationManager getInstance] getLocationEndDate];
        NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
        
        LogInfo(@"PASSIVE LOCATION start time:%@, end time:%@, interval time:%d, System time:%@", [WSCurrentTime formatDataToString: startDate], [WSCurrentTime formatDataToString: endDate], checkTime.intValue, [WSCurrentTime formatDataToString: [NSDate date]]);
        if ([[WSLocationManager getInstance] isPassiveLocationAllDay]) {
            LogInfo(@"全天上传被动位置");
            self.backgroudGPSTimer = [NSTimer scheduledTimerWithTimeInterval:checkTime.intValue target:self selector:@selector(locationTimerAction) userInfo:nil repeats:YES];
            [self.backgroudGPSTimer fire];
        }else if ([currentDate compare:startDate] == NSOrderedAscending) {
            
            //还没到begin Time
            LogInfo(@"还没到被动位置启动时间,start time fire.");
            self.backgroudGPSTimer = [NSTimer scheduledTimerWithTimeInterval:checkTime.intValue target:self selector:@selector(locationTimerAction) userInfo:nil repeats:YES];
            [self.backgroudGPSTimer setFireDate:startDate];
        }
        else if ([currentDate compare:startDate] != NSOrderedAscending && [currentDate compare:endDate] == NSOrderedAscending )
        {
            //在location时间内
            LogInfo(@"当前时间在LOCATIONS时间范围内，启动被动位置上报, fire.");
            self.backgroudGPSTimer = [NSTimer scheduledTimerWithTimeInterval:checkTime.intValue target:self selector:@selector(locationTimerAction) userInfo:nil repeats:YES];
            [self.backgroudGPSTimer fire];
            
        }
        else if ([currentDate compare:endDate] != NSOrderedAscending)
        {
            //已经过了end time
            LogInfo(@"当前时间已经过了被动位置LOCATION_END_TIME,stop.");
        }
    }
}

- (WSOpenFeedbackView *)openFeedbackView {
    if (!_openFeedbackView) {
        _openFeedbackView = [[WSOpenFeedbackView alloc] init];
    }
    return _openFeedbackView;
}

#pragma mark - 实现application:didRegisterForRemoteNotificationsWithDeviceToken:协议
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if (![deviceToken isKindOfClass:[NSData class]]) {
        return;
    }
    
    //绑定融云token
    [WSRongCloudManager bindRongCloudDeviceToken:deviceToken];

}

#pragma mark - 实现application:didReceiveRemoteNotification:fetchCompletionHandler:协议 (应用程序已收到远程通知)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if (![userInfo valueForKeyPath:@"aps.recall"]) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

#pragma mark - 通过数据库创建日历方法
- (void)createCalendarWithDB {
    
    NSArray *calendarArray = [WSCalendarAlarmDBService queryCalendarAlarmDataWithEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    WSBaseStoreOtherDataObject *dataObject = calendarArray.firstObject;
    [[WSCalendarEventTools sharedManager] deleteCalendarEventWithDateStr:[WSAppData getObjectbyKey:APPDATA_BIZDATE]
                                                                andTitle:dataObject.item2];
    [calendarArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         WSBaseStoreOtherDataObject *dataObject = obj;
         [[WSCalendarEventTools sharedManager] createCalendarEventWithTimeStr:dataObject.item4 andTitle:dataObject.item2
                                                               andDescription:dataObject.item3];
    }];
}

@end
//=============================================================================================================================================
