//
//  WSCalendarAlarmDBService.m
//  WinSFA
//
//  Created by yuanji on 2018/1/31.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCalendarAlarmDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreOtherDataTable.h"
//===================================================================================================================================================================

#pragma mark - 日历闹钟数据库服务
@implementation WSCalendarAlarmDBService

#pragma mark - 重写replaceToTableWithDicts:FromNode:hasNewData:方法(保存到自己的表中)
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    [service deleteWithType:CALENDAR_ALARM];

    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dicts.count];
    for (NSDictionary *dic in dicts)
    {
        NSString *empId = [NSString stringWithValue:dic[@"empId"]];
        NSString *item1 = [NSString stringWithValue:dic[@"id"]];
        NSString *item2 = [NSString stringWithValue:dic[@"title"]];
        NSString *item3 = [NSString stringWithValue:dic[@"description"]];
        NSString *item4 = [NSString stringWithValue:dic[@"remindTime"]];
        
        if(empId && item1 && item2 && item3 && item4)
            [dataArray addObject:@{@"type" : CALENDAR_ALARM, @"emp_id" : empId, @"item1" : item1, @"item2" : item2, @"item3" : item3, @"item4" : item4}];
    }
    
    return [service replaceToTableWithDicts:dataArray FromNode:CALENDAR_ALARM hasNewData:YES];
}

#pragma mark - 获取日历闹钟数据方法
+ (NSArray *)queryCalendarAlarmDataWithEmpId:(NSString *)empId
{
    if (empId.length <= 0)
        return nil;
    
    NSArray *tipArray = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"emp_id"] ArgumentsValue:@[CALENDAR_ALARM, empId]];
    return tipArray;
}

@end
//===================================================================================================================================================================
