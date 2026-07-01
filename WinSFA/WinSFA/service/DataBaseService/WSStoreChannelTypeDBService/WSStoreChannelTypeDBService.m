//
//  WSStoreChannelTypeDBService.m
//  WinSFA
//
//  Created by zhangmin on 2018/9/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSStoreChannelTypeDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreOtherDataTable.h"

@implementation WSStoreChannelTypeDBService

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    [service deleteWithType:STORE_CHANNEL_TYPE];
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dicts.count];
    for (NSDictionary *dic in dicts) {
        NSString *empId = [NSString stringWithValue:dic[@"empId"]];
        NSString *item1 = [NSString stringWithValue:dic[@"channelId"]];
        NSString *item2 = [NSString stringWithValue:dic[@"typeId"]];
        if(empId && item1 && item2) {
            [dataArray addObject:@{@"type" : STORE_CHANNEL_TYPE, @"emp_id" : empId, @"item1" : item1, @"item2" : item2}];
        }
    }
    return [service replaceToTableWithDicts:dataArray FromNode:STORE_CHANNEL_TYPE hasNewData:YES];
}

@end
