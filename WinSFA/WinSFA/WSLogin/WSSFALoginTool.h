//
//  WSSFALoginTool.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//===================================================================================================================================================================

#pragma mark - SFA登陆工具
@interface WSSFALoginTool : NSObject

#pragma mark - 获取上一次输入的机构编码方法
+ (NSString *)getSaasOrgCode;

#pragma mark - 通过用户名/编码名获取机构编码方法 userName:用户名 orgName:编码名
+ (NSString *)getSaasWebAddressWithUserName:(NSString *)userName orgName:(NSString *)orgName;

#pragma mark - 存储网络状态方法
+ (void)saveNetworkType;

#pragma mark - 存储第一次登陆信息方法
+ (void)saveUserFirstLogin;

#pragma mark - 清除缓存方法
+ (void)clearCache;

@end
//===================================================================================================================================================================
