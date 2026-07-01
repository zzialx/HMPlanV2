//
//  WSLabelDisplayValue.m
//  WinSFA
//
//  Created by yang on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSLabelDisplayValue.h"
#import "WSEmpAcvtDisArray.h"
#import "WSEmpAcvtDis.h"
#import "I_W_BuildInfo.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSAddNewAcvtModel.h"

@implementation WSLabelDisplayValue

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *redisValue = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    return redisValue;
}

- (NSObject *)getServerRedisValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    
    WSEmpAcvtDisArray* l_empAcvtDisArray = [WSAppData getObjectbyKey:EMPACVTDIS];
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    for(WSEmpAcvtDis* f_ead in l_empAcvtDisArray.m_empAcvtDisArray)
    {
        if([model.currentAcvtBean.acvtId isEqualToString:f_ead.m_acvtId]&&
           [f_ead.m_qstId isEqualToString:[buildInfo getAcvtQstId]])
        {
            return f_ead.m_disValue;
        }
    }
    
    
    
    NSString *redisValue = nil;
    if (!model.isNewAddAcvt) {
        if ([model isKindOfClass:[WSAddNewAcvtModel class]]) {
            WSAddNewAcvtModel *addNewAcvtModel = (WSAddNewAcvtModel *)model;
            /*对店的新增门店（问卷）的回显 史克医院*/
            if (addNewAcvtModel.acvtNewStoreQstInfos && addNewAcvtModel.currentNewStore.Id) {
                redisValue = [addNewAcvtModel getAcvtNewStoreServeRedisValueForStoreByQstId:[buildInfo getAcvtQstId]];
            }
        }
        
        /*正常问卷的服务器回显*/
        NSString *value = [model getAcvtDisValueByAcvtQstId:[buildInfo getAcvtQstId]];
        if (value && [value length] > 0) {
            redisValue = value;
        }

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
