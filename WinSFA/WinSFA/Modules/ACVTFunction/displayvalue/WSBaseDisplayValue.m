//
//  WSBaseDisplayValue.m
//  WinSFA
//
//  Created by yang on 15-3-24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDisplayValue.h"
#import "WSBaseModel.h"
#import "WSAcvtModel.H"
#import "WSDataSourceManager.h"

@implementation WSBaseDisplayValue

#pragma mark - 获取app进入后台缓存数据方法
- (NSObject *)getAppBackgroundCache:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (![model isKindOfClass:[WSAcvtModel class]]) {
        return nil;
    }
    
    WinEnterBackgroundDataModel *dataModel = [model queryEnterBackgroundMark];
    if (dataModel) {
            
        //app进入后台缓存功能开启 直接本地数据
        NSObject *redisValue = [self getNativeDBValue:buildInfo];
        return redisValue;
    }
    
    return nil;
}

- (NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    NSObject *backgroundCacheValue = [self getAppBackgroundCache:buildInfo];
    if (backgroundCacheValue) {
        return backgroundCacheValue;
    }
    
    WSAcvtModel *model = (WSAcvtModel*)[WSDataSourceManager sharedInstance].currentActiveModel;
    if (![model isKindOfClass:[WSAcvtModel class]]) {
        return nil;
    }

    NSObject *redisValue;
    if (model.hasLocalData && !model.isFromRealTimeData) {
        
        //本地
        if ([model nativeRedis]) {
            redisValue = [self getNativeDBValue:buildInfo];
        }
    }
    else {
        
        //服务器
        if (![self isValueValid:redisValue] && [model serverRedis]) {
            redisValue = [self getServerRedisValue:buildInfo];
        }
        
        //显示默认值
        if (![self isValueValid:redisValue]) {
            redisValue = [self getDefaultValue:buildInfo];
        }
    }
    
    return redisValue;
}

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    return nil;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    return nil;
}

- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    return nil;
}

- (BOOL)isValueValid:(NSObject *)value {
    
    if (value) {
        return YES;
    }
    return NO;
}

@end
