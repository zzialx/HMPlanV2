//
//  WSArrayDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDefaultArrayDisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"

@implementation WSDefaultArrayDisplayValue

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSArray *redisArray = nil;
    
    NSString *valueString = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    
    if (valueString && [valueString length] > 0) {
        redisArray = [valueString componentsSeparatedByString:@","];
    }
    
    return redisArray;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSArray *redisArray = nil;
    
    if (!model.isNewAddAcvt) {
        NSArray * values = [model getAcvtDisArrayValueByAcvtQstId:[buildInfo getAcvtQstId]];
        if (values && values.count > 0) {
            redisArray = values;
        }
    }
    
    return redisArray;
}

- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    NSArray *redisArray = nil;
    if ([buildInfo getDefaultValue] && [[buildInfo getDefaultValue] length] > 0) {
        redisArray = [[buildInfo getDefaultValue] componentsSeparatedByString:@","];
    }
    return redisArray;
}


@end
