//
//  RSDataPersistenceAssistant.h
//  x2
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCFileManagerHelper : NSObject

/**
 * 	从文件中取得用户信息
 */
+ (NSObject *)objectForKey:(NSString *)key userId:(long long)userId;

/**
 * 	向文件中写入用户信息
 */
+ (BOOL)setObject:(NSObject *)value forKey:(NSString *)key userId:(long long)userId;

@end