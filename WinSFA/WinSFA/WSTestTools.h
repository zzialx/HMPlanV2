//
//  WSTestTools.h
//  WinSFA
//
//  Created by xiajl on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSTestTools : NSObject

+ (instancetype) getInstance ;

- (void)keepTimeWithKey:(NSString*)key;

- (void)keepTimeWithKey:(NSString*)key forcePrint:(BOOL)forcePrint;

- (void)printAndEndTimeIntervalforKey:(NSString *)keyString;

- (void)printAndEndTimeIntervalforKey:(NSString *)keyString forcePrint:(BOOL)forcePrint;

@end
