//
//  WSRongCloudManager.m
//  WinSFA
//
//  Created by zzialx on 2024/2/28.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import "WSRongCloudManager.h"
#import "WSEnvrionment.h"
#import <RongCallLib/RCCallSession.h>
#import "WSDeviceRotateTool.h"

static NSString * const RongcloudAppKeyString = @"RongcloudAppKey";

static WSRongCloudManager *instance = nil;

@implementation WSRongCloudManager

+ (WSRongCloudManager *)sharedInstance
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSRongCloudManager alloc] init];
        });
    }
    return instance;
}
#pragma mark - # 融云初始化sdk
- (void)initRongCallKitSDK{
    
    LogInfo(@"RC init");
    NSString * rcAppKey = [WSEnvrionment getAppRongCludKey];
    LogInfo(@"RC SDK key %@",rcAppKey);

    RCInitOption * option = [[RCInitOption alloc]init];
    [[RCIM sharedRCIM] initWithAppKey:rcAppKey option:option];
    
    //设置视频码率
    [[RCCallClient sharedRCCallClient] setBitRate:2200];
    //设置视频分辨率
    [[RCCallClient sharedRCCallClient] setVideoProfile:RC_VIDEO_PROFILE_720P];
    //获取RongCloud版本
    LogInfo(@"RC SDK version %@",[RCCallClient getVersion]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateNewSession:)
                                                 name:@"RCCallNewSessionCreation Notification" object:nil];
    
}
- (void)didCreateNewSession:(NSNotification *)notification {
    RCCallSession *session = notification.object;
    LogInfo(@"接收到通话邀请通知：%ld",(long)session.callStatus);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        UIViewController *topmVC = [WSDeviceRotateTool topmostViewController];
        
        if (topmVC) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                                               message:@"使用相机时请勿拍摄到其他人员"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil)
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
            }];
               
            [confirmAction setValue:MAIN_TINT_COLOT forKey:@"titleTextColor"];
            [alert addAction:confirmAction];
            [topmVC presentViewController:alert animated:YES completion:nil];
        }else{
            LogError(@"顶层vc不存在，使用自定义BlockAlertView");
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:@"使用相机时请勿拍摄到其他人员"];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
            [alert show];
        }
       
    });
}
#pragma mark - # 连接融云IM服务器
+ (void)connectRongCallKitIMServerWithToken:(NSString*)token{
    
    LogInfo(@"RC connect IM Server token：%@",token);
    @weakify_self;
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
            if(code != RCDBOpenSuccess){
                // 数据库打开失败，处理
                LogError(@"RC open data base failure");
            }
        } success:^(NSString *userId) {
            // 连接成功，处理
            LogInfo(@"RC connect success action userId:%@",userId);
        } error:^(RCConnectErrorCode errorCode) {
            // 连接失败，处理
            LogError(@"RC connect failure code:%ld",errorCode);
            @strongify_self;
            [self showTipsWithRCErrorCode:errorCode];
        }];
    
}
#pragma mark - # 断开融云IM服务器连接
+ (void)logoutConnectRongCallKitIMServer{
    
    LogInfo(@"RC logout IM Server and no recieve push message");
    [[RCIM sharedRCIM] logout];
    
}

#pragma mark - # 发起单人呼叫测试
+ (void)startSingleCallWithRongCallKitIMServer{
    
    LogInfo(@"RC startSingleCall test");
    [[RCCall sharedRCCall] startSingleCall:@"127127" mediaType:RCCallMediaVideo];
   
}
#pragma mark - # 绑定融云devicetoken
+ (void)bindRongCloudDeviceToken:(NSData*)deviceToken{
    
    NSString * rongcloudAppKey = [WSPlistHelper valueForKey:RongcloudAppKeyString withPlistName:kConfilgFileName];
    if(rongcloudAppKey.length>0&&deviceToken){
        LogInfo(@"RC IM 绑定 deviceToken");
        [[RCIMClient sharedRCIMClient] setDeviceTokenData:deviceToken];
    }else{
        LogError(@"rongcloudAppKey:%@",rongcloudAppKey);
    }
}
#pragma mark - # 显示融云连接IM服务器报错提示
+ (void)showTipsWithRCErrorCode:(RCConnectErrorCode)errorCode{
    
    if (errorCode == RC_DISCONN_KICK) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *text = NSLocalizedString(@"im_server_DISCONN_KICK", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    }else if (errorCode == RC_CONN_TOKEN_EXPIRE) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *text = NSLocalizedString(@"im_server_token_KICK", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    }else if (errorCode == RC_CONN_OTHER_DEVICE_LOGIN) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *text = NSLocalizedString(@"im_server_other_KICK", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    }
}

@end
