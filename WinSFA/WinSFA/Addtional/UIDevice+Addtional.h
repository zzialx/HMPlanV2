//
//  UIDevice+Addtional.h
//  
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 *屏幕宽度
 */
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)

/*
 *屏幕高度
 */
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)

@interface UIDevice (Addtional)

// 是否是iPhone
+ (BOOL)isiPhone;

// 是否是iPad
+ (BOOL)isiPad;
//是否是ipad模拟器
+ (BOOL)isiPadSimulator;
//是否是iPhone模拟器
+ (BOOL)isiPhoneSimulator;
// 是否是iTouch
+ (BOOL)isiPodTouch;

// 支持拔打电话
+ (BOOL)supportTelephone;

// 支持发送短信
+ (BOOL)supportSendSMS;

// 支持发送邮件
+ (BOOL)supportSendMail;

// 支持摄像头取景
+ (BOOL)supportCamera;

// 以全小写的形式返回设备名称
- (NSString*)modelNameLowerCase;

// 系统版本，以float形式返回
- (CGFloat)systemVersionByFloat;

// 系统版本比较
- (BOOL)systemVersionLowerThan:(NSString*)version;
- (BOOL)systemVersionNotHigherThan:(NSString *)version;
- (BOOL)systemVersionHigherThan:(NSString*)version;
- (BOOL)systemVersionNotLowerThan:(NSString *)version;

+ (NSString *) macAddress;

// 系统是否越狱
- (BOOL) isJailBroken;

// 当前语言环境
+(NSString*)sysLanguage;
+ (NSString*)getPreferredLanguage;

// 内存信息
+ (unsigned int)freeMemory;
+ (unsigned int)usedMemory;

+ (BOOL)isRetina4inch;

+ (NSString *)platformNameForSFA;

+ (NSNumber *)freeDiskSpaceInBytes;

@end
