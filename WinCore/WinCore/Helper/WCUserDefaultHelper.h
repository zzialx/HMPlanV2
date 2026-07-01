//
//  WCUserDefaultHelper.h
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCUserDefaultHelper : NSObject

/**
 * 存最后一次登录的用户id
 */
+ (long long)lastLoginUserID;

/**
 * 取最后一次登录的用户id
 */
+ (void)saveLastLoginUserID:(long long)userID;

// 取上次登录的用户名
+ (NSString*)lastLoginUserAccount;
//存上次登录的用户名
+ (void)saveLastLoginUserAccount:(NSString*)accout;

//存取聊天本地用户头像KEY
+(NSString*) getUserImageKey;
+(void) saveUserImageKey:(NSString*) imageKey;


// 是否需要检查新版本
- (BOOL)needCheckNewVersion;
// 保存检查新版本的时间
- (void)saveCheckNewVersionTime;


@end
