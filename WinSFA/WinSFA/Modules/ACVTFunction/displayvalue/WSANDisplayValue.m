//
//  WSANDisplayValue.m
//  WinSFA
//
//  Created by yang on 16/3/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSANDisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"
#import "WSAddNewAcvtModel.h"

@implementation WSANDisplayValue

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *redisValue = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    return redisValue;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *redisValue = nil;
    if (!model.isNewAddAcvt) {
        if ([model isKindOfClass:[WSAddNewAcvtModel class]]) {
            WSAddNewAcvtModel *addNewAcvtModel = (WSAddNewAcvtModel *)model;
            /*对店的新增门店（问卷）的回显 史克医院*/
            if (addNewAcvtModel.acvtNewStoreQstInfos && addNewAcvtModel.currentNewStore.Id) {
                redisValue = [addNewAcvtModel getAcvtNewStoreServeRedisValueForStoreByQstId:[buildInfo getAcvtQstId]];
            }
        }

        NSString *value = [model getAcvtDisValueByAcvtQstId:[buildInfo getAcvtQstId]];
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
