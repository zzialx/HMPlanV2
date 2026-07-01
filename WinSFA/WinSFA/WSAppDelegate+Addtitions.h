//
//  WSAppDelegate+Addtitions.h
//  WinSFA
//
//  Created by zzialx on 2023/7/27.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSAppDelegate.h"
#import <UserNotifications/UserNotifications.h>

static NSString * _Nonnull const  chatEndTips = @"对方已经挂断！！！";

static NSString * _Nonnull const  chatJumpUrlNullTips = @"视频链接信息为空,请联系管理人员！！！";

static NSString * _Nonnull const  chatExpiredTips = @"视频已取消！！！";


NS_ASSUME_NONNULL_BEGIN

@interface WSAppDelegate (Addtitions)


///存储启动状态
+ (void)saveUserFirstLaunch;

///打印系统日志 log
+  (void)writeSystemInfoToLog;


/// 设置系统主题颜色，导航栏颜色
+ (void)setUpUISkinStyle;

/// 设置第三方键盘
+ (void)setIQKeyBoard;

/// 设置日志管理
+ (void)setLogManagerConfig;

///设置SDWebImage配置信息
+ (void)setSDImageConfig;

///注册通知
+ (void)registerNotification;

///上传闪退日志
+ (void)uploadCrashFile;

///融云初始化
+ (void)initRongCloudSDK;

///连接融云服务器
+ (void)connectRongCloudIMServer;
///删除过期的分享文件夹
+ (void)cleanupExpireFile;
/**对象方法*/

///上传异常
- (void)uploadException;


///上传远程通知设备令牌方法
- (void)uploadRemoteNoticeDeviceToken;

///注册第三方定位 sdk 的 key
- (void)registerLocationKey;

///注册分享 key
- (void)registerAppShareKey;

///注册对象通知
- (void)registerModelNotifi;



@end

NS_ASSUME_NONNULL_END
