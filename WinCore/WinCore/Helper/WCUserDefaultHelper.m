//
//  RSDataPersistenceAssistant.m
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

// 最后一次登录的用户ID
#define kLastLoginAccountId  @"kLastLoginAccountId"
#define kLastLoginUserAccount @"kLastLoginUserAccount"
// 检查新版本时间
#define kCheckNewVersionTime @"kCheckNewVersionTime"
#define kUserImageKey @"kUserImageKey"

#import "WCUserDefaultHelper.h"

@implementation WCUserDefaultHelper

//存最后一次登录的用户id
+ (long long)lastLoginUserID {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kLastLoginAccountId] longLongValue];
}

//取最后一次登录的用户id
+ (void)saveLastLoginUserID:(long long)userID {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:userID] forKey:kLastLoginAccountId];
}

// 取上次登录的用户名
+ (NSString*)lastLoginUserAccount
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoginUserAccount];
}
//存上次登录的用户名
+ (void)saveLastLoginUserAccount:(NSString*)accout
{
    [[NSUserDefaults standardUserDefaults] setObject:accout forKey:kLastLoginUserAccount];
}

+(NSString*) getUserImageKey
{
    NSString * userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"usernameForCallingApp"];
    NSString * unionimageKey=[NSString stringWithFormat:@"%@_%@",kUserImageKey,userName];
    return [[NSUserDefaults standardUserDefaults] objectForKey:unionimageKey];
}
+(void) saveUserImageKey:(NSString*) imageKey
{
    if(imageKey){
        NSString * userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"usernameForCallingApp"];
        NSString * unionimageKey=[NSString stringWithFormat:@"%@_%@",kUserImageKey,userName];
         [[NSUserDefaults standardUserDefaults] setObject:imageKey forKey:unionimageKey];
    }
}

// 是否需要检查新版本
- (BOOL)needCheckNewVersion
{
    // 取上一次的时间,看是否大于3天。如果大于3天，则需要更新
    NSNumber* t = [[NSUserDefaults standardUserDefaults] objectForKey:kCheckNewVersionTime];
    if (t == nil) {
        return YES;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now-t.doubleValue > (24*60*60*3)) {
        return YES;
    }
    else {
        return NO;
    }
}

// 保存检查新版本的时间
- (void)saveCheckNewVersionTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSNumber* nowNum = [NSNumber numberWithDouble:now];
    [[NSUserDefaults standardUserDefaults] setObject:nowNum forKey:kCheckNewVersionTime];
}



@end
