//
//  WSReversePositingDisplayValue.m
//  WinSFA
//
//  Created by HZH on 2017/10/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSReversePositingDisplayValue.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "NSDictionary+Additional.h"

@implementation WSReversePositingDisplayValue

- (NSObject *)getNativeDBValue:(NSObject<I_W_BuildInfo> *)buildInfo
{
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    NSString *nativeValueJsonStr = [model.qstDBValueDictionary objectForKey:[buildInfo getAcvtQstId]];
    NSDictionary *nativeValueDic = [NSDictionary dictionaryWithJsonString:nativeValueJsonStr];
    
    NSString *redisValue = [NSString stringWithFormat:@"%@,%@,%@", [NSString stringNotNilWithValue:[nativeValueDic objectForKey:@"lat"]], [NSString stringNotNilWithValue:[nativeValueDic objectForKey:@"lon"]], [NSString stringNotNilWithValue:[nativeValueDic objectForKey:@"loc_addr"]]];
    
    return redisValue;
}

@end
