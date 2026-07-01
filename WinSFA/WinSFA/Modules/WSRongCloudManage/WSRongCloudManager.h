//
//  WSRongCloudManager.h
//  WinSFA
//
//  Created by zzialx on 2024/2/28.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSRongCloudManager : NSObject


/// 单例
+(WSRongCloudManager*)sharedInstance;


/// 初始化融云CallKit SDK
- (void)initRongCallKitSDK;

/// 连接融云IM服务器
+ (void)connectRongCallKitIMServerWithToken:(NSString*)token;

/// 登出融云IM服务器连接,并且不再接受推送消息
+ (void)logoutConnectRongCallKitIMServer;

/// 发起单人呼叫测试
+ (void)startSingleCallWithRongCallKitIMServer;


/// 绑定融云devicetoken
/// - Parameter deviceToken:
+ (void)bindRongCloudDeviceToken:(NSData*)deviceToken;

@end

NS_ASSUME_NONNULL_END
