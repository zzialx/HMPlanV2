//
//  WSRatingViewDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/4/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSRatingViewDisplayValue.h"
#import "WSBaseModel.h"
#import "WSDataSourceManager.h"

@implementation WSRatingViewDisplayValue

- (NSObject *)getDisplayValueFor:(NSObject<I_W_BuildInfo> *)buildInfo {

    NSObject *backgroundCacheValue = [self getAppBackgroundCache:buildInfo];
    if (backgroundCacheValue) {
        return backgroundCacheValue;
    }
    
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    NSObject *redisValue;
    
    //本地
    if ([model nativeRedis] || [model.currentFuncs.fc isEqualToString:@"FAC_071"]) {
        redisValue = [self getNativeDBValue:buildInfo];
    }
    
    //回显服务器数据
    if (!redisValue && [model serverRedis]) {
        redisValue = [self getServerRedisValue:buildInfo];
    }
    
    //显示默认值
    if (!redisValue) {
        redisValue = [self getDefaultValue:buildInfo];
    }
    
    return redisValue;
}

@end
