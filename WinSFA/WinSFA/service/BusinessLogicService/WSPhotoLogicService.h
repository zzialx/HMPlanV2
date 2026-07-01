//
//  WSPhotoLogicService.h
//  WinSFA
//
//  Created by yang on 17/4/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSPhotoLogicService : NSObject

+ (NSString *)getAcvtImageIndexWithFC:(NSString *)fc acvtMD5:(NSString *)acvtMD5 acvtQstId:(NSString *)acvtQstId;

+ (NSArray *)getPhotoNameArrayByImageIDArray:(NSArray *)imageIDArray;

/*
 注：后台回显包含两种格式：
 旧：photoKey@url
 新：imageIndex@photoKey@url
 两种格式都支持
 */
+ (NSString *)getImageIndexFromServerRedisValue:(NSString *)redisValue;

+ (NSString *)getPhotoKeyFromServerRedisValue:(NSString *)redisValue;

+ (NSString *)getPhotoURLFromServerRedisValue:(NSString *)redisValue;

+ (NSString *)getFCFromImageIndex:(NSString *)imageIndex;

+ (BOOL)isServerRedisPhoto:(NSString *)imageID;

+ (NSString *)getImageTitleFromServerRedisValue:(NSString *)redisValue;

@end
