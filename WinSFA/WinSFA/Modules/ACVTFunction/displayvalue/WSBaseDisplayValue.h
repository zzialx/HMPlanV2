//
//  WSBaseDisplayValue.h
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_DisplayValue.h"

@protocol I_W_BuildInfo;

@interface WSBaseDisplayValue : NSObject<I_W_DisplayValue>

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo;        //获取本地数据库的值，子类实现
- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo;     //获取服务端提供的回显值，子类实现
- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo;         //获取默认值值，子类实现
- (NSObject *)getAppBackgroundCache:(NSObject<I_W_BuildInfo> *)buildInfo;   //获取app进入后台缓存数据方法
- (BOOL)isValueValid:(NSObject *)value;                                     //数值是否有效方法

@end
