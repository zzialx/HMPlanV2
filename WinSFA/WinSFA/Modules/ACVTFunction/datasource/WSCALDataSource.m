//
//  WSCALDataSource.m
//  WinSFA
//
//  Created by heju on 2016/12/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCALDataSource.h"
#import "WSDataSourceManager.h"
#import "WSBaseOptionDataItem.h"
#import "WSCalendarLogicService.h"

@implementation WSCALDataSource

- (NSObject *)getDataSourceFor:(NSObject<I_W_BuildInfo> *)buildInfo
{
    NSArray *dateStrs = [self getCalenderShowLimitDateStrs];
    return [self getCalendaDutyPlanIcon:dateStrs usingGenId:YES];
}

- (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid {
    WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    return [WSCalendarLogicService getCalendaDutyPlanIcon:dateStrs usingGenId:isUsingGenid acvtModel:acvtModel];
}




- (NSArray *)getCalenderShowLimitDateStrs {
    
    NSMutableArray *dateStrs = [NSMutableArray array];
    for (NSInteger i = - CALENDER_LIMIT_DAY; i < 0; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:0 day:i+1]];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    
    for (NSInteger i = 0; i < numberOfDaysInMonth; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:0 day:i+1]];
    }
    
    for (NSInteger i = 0; i < CALENDER_LIMIT_DAY ; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:1 day:i+1]];
    }
    return dateStrs;
}

@end
