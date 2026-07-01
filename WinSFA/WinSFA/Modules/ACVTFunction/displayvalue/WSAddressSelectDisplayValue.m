//
//  WSAddressSelectDisplayValue.m
//  WinSFA
//
//  Created by xiajl on 15/3/25.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAddressSelectDisplayValue.h"
#import "I_W_BuildInfo.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"

@implementation WSAddressSelectDisplayValue

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *redisSelectName = nil;
    
    NSString *str = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    if (str) {
        NSDictionary *dic = [str objectFromJSONString];
        if (dic) {
            [model.qstDBValueDictionary setObject:dic forKey:[buildInfo getAcvtQstId]];
            
        }
        NSString *address = [dic objectForKey:@"address"];
        if (address) {
            redisSelectName = address;
        }
    }
    
    return redisSelectName;
}

- (NSObject *)getDefaultValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    NSString *redisSelectName = nil;
    
    if ([buildInfo getDefaultValue] && [[buildInfo getDefaultValue] length] > 0) {
        
        for (WSAcvtBean_qst_opt *tempOpt in [buildInfo getOptArray]) {
            if ([buildInfo getDefaultValue] && [tempOpt.optId isEqualToString:[buildInfo getDefaultValue]]) {
                redisSelectName = tempOpt.optName;
                break;
            }
        }
    }
    
    return redisSelectName;
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
