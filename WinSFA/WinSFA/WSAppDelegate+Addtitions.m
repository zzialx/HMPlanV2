//
//  WSAppDelegate+Addtitions.m
//  WinSFA
//
//  Created by zzialx on 2023/7/27.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSAppDelegate+Addtitions.h"
#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <SafariServices/SafariServices.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+Addtional.h"
#import "UINavigationController+Additions.h"
#import "WSSplitViewController.h"
#import "WSRequestHelper.h"
#import "FileManager.h"
#import "IQKeyboardManager.h"
#import "WinJSBridgeViewController.h"
#import "WSEnvrionment.h"
#import "WSAvAuthorizationManager.h"
#import "WSRequestTools.h"
#import "WSRongCloudManager.h"
#import "WSFileCleanupManager.h"


@interface WSAppDelegate (Additions) <BMKGeneralDelegate, BMKLocationAuthDelegate, SFSafariViewControllerDelegate>


@end

@implementation WSAppDelegate (Addtitions)

#pragma mark -  # Class Method
#pragma mark -  判断是否是第一次登陆
+ (void)saveUserFirstLaunch {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AppEverLaunch"]) { //检测AppEverLaunch是否为假
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppEverLaunch"]; //设置App已启动过为真
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppFirstLaunch"]; //设置App第一次启动为真
        
    }else{
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AppFirstLaunch"];//设置app第一次启动为假
        
    }
}

#pragma mark - about log

+  (void)writeSystemInfoToLog{
    LogInfo(@"系统版本：%@ %@", [[UIDevice currentDevice] systemName] , [[UIDevice currentDevice] systemVersion]);
    LogInfo(@"设备版本：%@", [[UIDevice currentDevice] platform]);
    LogInfo(@"是否越狱：%@", [[UIDevice currentDevice] isJailBroken] ? @"post_quit_yes" : @"post_quit_no");
    LogInfo(@"svn版本号：%@", [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName]);
    LogInfo(@"可用内存：%f MB", [UIDevice freeMemory]/1024.0/1024.0);
    LogInfo(@"已用内存：%f MB", [UIDevice usedMemory]/1024.0/1024.0);
    CGFloat freeMB = [[UIDevice freeDiskSpaceInBytes] floatValue]/1024.0/1024.0;
    NSString *unit = @"MB";
    if (freeMB / 1024.0 > 1.0) {
        freeMB = freeMB / 1024.0;
        unit = @"GB";
    }
    LogInfo(@"可用存储空间: %f %@", freeMB, unit);
}
#pragma mark - about UI skin style
+ (void)setUpUISkinStyle{
    //statusBarStyle
    if (IOS7_OR_LATER) {
        //大于ios7版本的情况（含）
        NSString *statusBarStyle = [[WSSkinStyleManager sharedInstance].skinStyleResourceCahche objectForKey:[NSString stringWithFormat:@"%@%@", kStatusBarStyle, INTERFACE_IS_PAD ? kiPadSuffix : @""]];
        //获得statusbar的样式字符串
        if ([statusBarStyle isEqualToString:@"1"]) {
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; //设置其样式为UIStatusBarStyleLightContent
        
        }
    }
    //mainTintColor
    UIColor *mainTintColor = MAIN_TINT_COLOT;//获得MainTinkColor
    if (mainTintColor) {
        [[UISegmentedControl appearance] setTintColor:mainTintColor]; //设置分项选择的颜色
        [[UIButton appearance] setTintColor:mainTintColor];  //设置UIButton的颜色
        if (IOS7_OR_LATER) { //大于ios7版本的情况（含）
            [[UIAlertView appearance] setTintColor:mainTintColor];
        }
        
        if (!IOS7_OR_LATER) {
            [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageFromColor:mainTintColor with:CGRectMake(0, 0, 300, 40)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
            [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor] with:CGRectMake(0, 0, 300, 40)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [[UISegmentedControl appearance] setDividerImage:[UIImage imageFromColor:mainTintColor with:CGRectMake(0, 0, 1, 40)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
    }
    
    NSMutableDictionary *normalDic = [[NSMutableDictionary alloc] init];
    [normalDic setObject:UI_SEGMENTCONTROL_FONT forKey:NSFontAttributeName];//设置字体
    if (mainTintColor) {//如果mainTintColor不为空
        [normalDic setObject:mainTintColor forKey:NSForegroundColorAttributeName]; //设置字体颜色
    }
    [[UISegmentedControl appearance] setTitleTextAttributes:normalDic   forState:UIControlStateNormal];//设置正常状态
    [[UISegmentedControl appearance] setTitleTextAttributes:@{ NSFontAttributeName: UI_SEGMENTCONTROL_FONT,
                                                               NSForegroundColorAttributeName: [UIColor whiteColor]
                                                               }   forState:UIControlStateSelected]; //设置选中状态的字体和颜色
    
    NSMutableDictionary *naviBarDic = [NSMutableDictionary dictionary];
    
    //navigation bar title color and font
    UIColor *navBarTitleColor = [UIColor colorForKey:@"NavigationBarTitleColor"]; //获取导航的颜色
    if (navBarTitleColor) {
        [naviBarDic setObject:navBarTitleColor forKey:NavigationBarTitleColor];
    }
    
    UIFont *navBarTitleFont = [UIFont fontForKey:@"NavigationBarTitleFont"]; //获取导航的字体
    if (navBarTitleFont) {
        [naviBarDic setObject:navBarTitleFont forKey:NavigationBarTitleFont];
    }
    
    //navigation bar background color
    UIColor *navBarBackgroudColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
    if (navBarBackgroudColor) {
        [naviBarDic setObject:navBarBackgroudColor forKey:NavigationBarBackgroudColor];
    }
    
    //navigation bar button title color and font
    UIColor *navBarButtonTitleColor = [UIColor colorForKey:@"NavigationBarButtonTitleColor"];//获取navigationbarbtntitle的颜色
    if (!IOS7_OR_LATER) {
        navBarButtonTitleColor = nil;
    }
    UIFont *navBarButtonTitleFont = [UIFont fontForKey:@"NavigationBarButtonTitleFont"]; //获取navigationbarbtntitlefont的颜色
    if (navBarButtonTitleColor) {
        [naviBarDic setObject:navBarButtonTitleColor forKey:NavigationBarButtonTitleColor];
    }
    if (navBarButtonTitleFont) {
        [naviBarDic setObject:navBarButtonTitleFont forKey:NavigationBarButtonTitleFont];
    }
    
    [UINavigationController setNavigationBarUIStyleWithDictionary:naviBarDic];
    
    if (INTERFACE_IS_PAD) {
        if ([UIColor colorForKey:@"NavigationBarSplitBackgroundColor"]) {
            [naviBarDic setObject:[UIColor colorForKey:@"NavigationBarSplitBackgroundColor"] forKey:NavigationBarBackgroudColor];
        }else {
            [naviBarDic setObject:mainTintColor forKey:NavigationBarBackgroudColor];
        }
        
        if ([UIColor colorForKey:@"NavigationBarSpliteTitleColor"]) {
            [naviBarDic setObject:[UIColor colorForKey:@"NavigationBarSpliteTitleColor"] forKey:NavigationBarTitleColor];
        }else {
            [naviBarDic setObject:[UIColor whiteColor] forKey:NavigationBarTitleColor];
        }
        
        if ([UIColor colorForKey:@"NavigationBarButtonSpliteTitleColor"]) {
            [naviBarDic setObject:[UIColor colorForKey:@"NavigationBarButtonSpliteTitleColor"] forKey:NavigationBarButtonTitleColor];
        }else {
            [naviBarDic setObject:[UIColor whiteColor] forKey:NavigationBarButtonTitleColor];
        }
        
        [UINavigationController setNavigationBarUIStyleWithDictionary:naviBarDic whenContainedIn:[WSSplitViewController class]];
    }

#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : navBarButtonTitleColor, NSFontAttributeName : navBarTitleFont};
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = navBarBackgroudColor;
        appearance.shadowColor = UIColor.clearColor;
        appearance.titleTextAttributes = dic;
        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
    }
#endif
#ifdef __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        UITableView.appearance.sectionHeaderTopPadding = 0.0f;
    }
#endif
}

#pragma mark - # 设置第三方键盘
+ (void)setIQKeyBoard{
    
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldToolbarUsesTextFieldTintColor = NO;
    [IQKeyboardManager sharedManager].toolbarTintColor = MAIN_TINT_COLOR;
}

#pragma mark - # 设置日志系统配置信息
+ (void)setLogManagerConfig{
    
    [[WCLogManager sharedInstance] setUpUncaughtExceptionHandler];
    [[WCLogManager sharedInstance] setUpDDlogger];
}
#pragma mark - # 设置SDWebImage配置信息
+ (void)setSDImageConfig{
    
    [SDImageCache sharedImageCache].maxCacheAge = 60 * 60 * 24 * 7;
    [SDImageCache sharedImageCache].maxCacheAgeForDocument = 60 * 60 * 24 * 2;
}
#pragma mark - # 注册通知
+ (void)registerNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUnleavedStore:) name:ALERT_UNLEAVED_STORE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertUnUploadDataCount:) name:ALERT_UNUPLOADDATA_COUNT object:nil];
    
}
#pragma mark - # 上传闪退日志
+ (void)uploadCrashFile{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString*filePath = [documentsDirectory stringByAppendingPathComponent:@"wch_DataBase.db"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [[WCLogManager sharedInstance] startUploadLog:UploadLogTypedCrash];
    }
}
#pragma mark - # 融云初始化
+ (void)initRongCloudSDK{
    
    [[WSRongCloudManager sharedInstance] initRongCallKitSDK];
}
#pragma mark - # 连接融云服务器
+ (void)connectRongCloudIMServer{
    LogInfo(@"RC：登录成功之后，获取用户token，连接融云IM服务器");
    
    [WSRequestTools requestRongIMTokenSuccess:^(NSString *token) {
        
        if(ISNULL(token).length>0){
            LogInfo(@"RC：获取IM token成功");
            [WSRongCloudManager connectRongCallKitIMServerWithToken:token];
            
        }else{
            LogError(@"RC：获取IM token失败，无法连接RongCloud IM Server");
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText: NSLocalizedString(@"im_server_token_tips", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }];
}
#pragma mark - # 删除过期的分享文件夹
+ (void)cleanupExpireFile{
    
    NSString *customPath = [[WSFileCleanupManager getShareFolderPath] stringByAppendingPathComponent:@""];
        
    [WSFileCleanupManager cleanupFoldersInPath:customPath
                                     daysToKeep:7
                                     completion:^(BOOL success, NSInteger deletedCount, NSError *error) {
        if (success) {
            LogInfo(@"自定义清理完成，删除了 %ld 个文件夹", (long)deletedCount);
             
        } else {
            LogError(@"自定义清理失败: %@", error.localizedDescription);
              
        }
    }];
}
#pragma mark - # 上传异常
- (void)uploadException{
    LogTrace();
    WSRequestHelper* l_upload = [WSRequestHelper shareInstance];
    
    NSString* l_exception = (NSString*)[FileManager getUserDefaults:EexceptionKey];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"l" forKey:@"type"];
    [infoDic setObject:[NSString stringNotNilWithValue:l_exception]  forKey:@"data"];
    [infoDic setObject:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:@"time"];
    if(l_exception != nil)
        [l_upload uploadExceptionInfo:infoDic];
}


#pragma mark - # 注册第三方定位 sdk 的 key
- (void)registerLocationKey{
    if ([WSEnvrionment getUseBaiduMap]) {
        
        NSString *key = [WSPlistHelper valueForKey:kBaiduMap_key withPlistName:kConfilgFileName];
        [[BMKMapManager sharedInstance] start:key generalDelegate:self];
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:key authDelegate:self];
        LogInfo(@"WSAppDelegate didFinishLaunchingWithOptions BaiduKey = %@", key);
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        NSString *key = [WSPlistHelper valueForKey:kGaode_key withPlistName:kConfilgFileName];
        [AMapServices sharedServices].apiKey = key;
        LogInfo(@"WSAppDelegate didFinishLaunchingWithOptions GeoKey = %@", key);
    }
}
#pragma mark - # 注册 App分享 key
- (void)registerAppShareKey{

}

#pragma mark - 上传远程通知设备令牌方法
- (void)uploadRemoteNoticeDeviceToken {
    LogInfo(@"绑定youmeng token");
}

- (void)registerModelNotifi{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:JUMP_CHAT_NOTIFI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpChat:) name:JUMP_CHAT_NOTIFI object:nil];

}
#pragma mark - # 绑定友盟通知回调方法
- (void)bindUMengNotification:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bindUMengNotification" object:nil];

    NSError *error = [[sender userInfo] objectForKey:ERROR];
    self.isUploadDeviceTokenSuccess = (error ? NO : YES);
}
//未离店通知
- (void)alertUnleavedStore:(NSNotification*)noti{
    NSDictionary *dic = [noti userInfo];
    NSString *storeName = [dic objectForKey:UNLEAVED_STORE];
    if (storeName) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:[NSString stringWithFormat:@"%@ %@",storeName,NSLocalizedString(@"not_leave_store_tip", nil)]];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
        [alert show];
    }
}
//未上传数据通知
- (void)alertUnUploadDataCount:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ALERT_UNUPLOADDATA_COUNT object:nil];
    NSDictionary *dic = [notification userInfo];
    NSString *msg = [dic objectForKey:UNUPLOAD_DATA_COUNT];
    if (msg) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:msg];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
        [alert show];
    }

}

@end
