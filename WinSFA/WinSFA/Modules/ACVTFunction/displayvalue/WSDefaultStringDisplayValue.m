//
//  WSStringDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDefaultStringDisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"
#import "WSAcvtDisBean.h"
#import "WSAcvtDisQstBean.h"

#import "WSAddNewAcvtModel.h"

@implementation WSDefaultStringDisplayValue


- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *redisValue = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    if (redisValue.length <= 0) {
        redisValue = [model.qstDBValueDictionary objectForKey:[NSString stringWithFormat:@"%@%@", [buildInfo getAcvtQstType], [buildInfo getAcvtQstId]]];
    }
    

    return redisValue;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *redisValue = nil;
    
    //门店下的 问卷新增配置回显
    if (!model.isNewAddAcvt || (model.currentStore.Id && ![model.currentStore.Id isEqualToString:@"-1"]) || model.isFromRealTimeData) {
        
        if ([model isKindOfClass:[WSAddNewAcvtModel class]] ) {
            
            WSAddNewAcvtModel *addNewAcvtModel = (WSAddNewAcvtModel *)model;
            //对店的新增门店（问卷）的回显 史克医院
            if (addNewAcvtModel.acvtNewStoreQstInfos && addNewAcvtModel.currentNewStore.Id) {
                redisValue = [addNewAcvtModel getAcvtNewStoreServeRedisValueForStoreByQstId:[buildInfo getAcvtQstId]];
            }
        }

        NSString *value = [model getAcvtDisValueByAcvtQstId:[buildInfo getAcvtQstId]];
        if (value && [value length] > 0) {
            redisValue = value;
        }
    }
    else {
        //对人的调查问卷的回显(不是新增之后的回显)
        NSString *value = [model getAcvtDisValueWhenCreatetForPeopleByQstId:[buildInfo getAcvtQstId]];
        if (value && [value length] > 0) {
            redisValue = value;
        }
    }
    
    return redisValue;
}

- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    NSString *redisValue = nil;
    
    if ([buildInfo getDefaultValue] && [[buildInfo getDefaultValue] length] > 0) {
        redisValue = [buildInfo getDefaultValue];
    }
    return redisValue;
}

- (BOOL)isValueValid:(NSObject *)value
{
    if ([value isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)value;
        if ([string length] > 0) {
            return YES;
        }
        
        return NO;
    }
    
    return [super isValueValid:value];
}

@end
