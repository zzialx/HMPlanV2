//
//  NSDate+WSYearCalendarLogic.h
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WSYearCalendarLogic)

- (NSUInteger)numberOfDaysInCurrentMonth;

- (NSUInteger)numberOfWeeksInCurrentMonth;

- (NSUInteger)weeklyOrdinality;

- (NSDate *)firstDayOfCurrentMonth;

- (NSDate *)lastDayOfCurrentMonth;

- (NSDate *)dayInThePreviousMonth;

- (NSDate *)dayInTheFollowingMonth;

- (NSDate *)dayInTheFollowingMonth:(NSInteger)month; // 获取当前日期之后的几个月

- (NSDate *)dayInTheFollowingDay:(NSInteger)day; // 获取当前日期之后的几个天

- (NSDateComponents *)YMDComponents;

- (NSDate *)dateFromString:(NSString *)dateStrig; // NSString 转 NSDate

- (NSString *)stringFromDate:(NSDate *)date; // NSDate 转 NSString

+ (NSInteger)getDayNumbertoDay:(NSDate *)today beforDay:(NSDate *)beforday;

- (NSInteger)getWeekIntValueWithDate;

// 判断日期是今天，明天，后天，周几
- (NSString *)compareIfTodayWithDate;

// 通过数字返回星期几
+ (NSString *)getWeekStringFromInteger:(NSInteger)week;

@end
