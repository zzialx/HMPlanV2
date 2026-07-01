//
//  WSCalendarAlarmDBService.h
//  WinSFA
//
//  Created by yuanji on 2018/1/31.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
//===================================================================================================================================================================

#pragma mark - 日历闹钟数据库服务
@interface WSCalendarAlarmDBService : WSDBService

#pragma mark - 获取日历闹钟数据方法
+ (NSArray *)queryCalendarAlarmDataWithEmpId:(NSString *)empId;

@end
//===================================================================================================================================================================
