//
//  WSSFALoginTool.m
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSFALoginTool.h"
#import "WSSFALoginGlobalDefinitions.h"
#import "WSEnvrionment.h"
//#import "WSStatisticsManager.h"
//===================================================================================================================================================================

#pragma mark - SFA登陆工具
@implementation WSSFALoginTool

#pragma mark - 获取上一次输入的机构编码方法
+ (NSString *)getSaasOrgCode
{
    NSString *url = [WSEnvrionment getSaasUrl];
    if ([url length] > 0)
    {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME];
        NSString *password  = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
        if ([userName length] > 0 && [password length] > 0)
        {
            NSString *saasUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SAAS_WEB_ADDRESS];
            NSArray *saasUrlArray = [saasUrl componentsSeparatedByString:WSLoginSaasWebAddressSeparatorMark];
            if ([saasUrlArray count] == 3)
            {
                NSString *urlUserName = saasUrlArray[0];
                if ([urlUserName isEqualToString:userName])
                    return saasUrlArray[1];
            }
        }
    }
    
    return nil;
}

#pragma mark - 通过用户名/编码名获取机构编码方法 userName:用户名 orgName:编码名
+ (NSString *)getSaasWebAddressWithUserName:(NSString *)userName orgName:(NSString *)orgName
{
    NSString *saasUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SAAS_WEB_ADDRESS];
    NSArray *saasUrlArray = [saasUrl componentsSeparatedByString:WSLoginSaasWebAddressSeparatorMark];
    if ([saasUrlArray count] == 3)
    {
        NSString *urlUserName = saasUrlArray[0];
        NSString *orgCode = saasUrlArray[1];
        if ([urlUserName isEqualToString:userName] && [orgCode isEqualToString:orgName])
            return saasUrlArray[2];
    }
    
    return nil;
}

#pragma mark - 存储网络状态方法
+ (void)saveNetworkType
{
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    NSString *netType = @"";
    switch (status)
    {
        case NotReachable:
        {
            netType = @"";
        }
            break;
        case ReachableViaWiFi:
        {
            netType = @"WIFI";
        }
            break;
        case ReachableViaWWAN:
        {
            netType = @"MOBILE";
        }
            break;
        default:
            break;
    }
    
//    [[WSStatisticsManager sharedInstance] insertLoginSenceEventWithID:EVENT_NET_TYPE startTime:nil endTime:nil
//                                                           eventValue:netType genId:[WSStatisticsManager getGenId]];
}

#pragma mark - 存储第一次登陆信息方法
+ (void)saveUserFirstLogin
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLogin"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLogin"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLogin"];
    }
    else
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLogin"];
}

#pragma mark - 清除缓存方法
+ (void)clearCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_ME_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:REMEMBER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataBaseFilePath = [documentsDirectory stringByAppendingPathComponent:@"wch_DataBase.db"];
    
    NSString *message = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataBaseFilePath])
    {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:dataBaseFilePath error:&error])
        {
            [[WSFMDatebase getInstance] closeDB];
            message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"清除数据库成功:", nil),documentsDirectory];
        }
        else
            message = error.debugDescription;
    }
    else
        message = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"数据库不存在:", nil),documentsDirectory];
    
    LogInfo(@"%@", message);
}

@end
//===================================================================================================================================================================
