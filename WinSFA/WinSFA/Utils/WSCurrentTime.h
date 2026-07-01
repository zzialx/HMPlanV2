//
//  CurrentTime.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-19.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCurrentTime : NSObject
                         // about time
+ (NSString *)getYearString;
+ (NSString *)getYearStringWithTime:(NSDate *)currentDate;
+ (NSString *)getMonthString;
+ (NSString *)getMonthStringWithTime:(NSDate *)currentDate;
+ (NSString *)getWeekString;
+ (NSString *)getDateString;
+ (NSString *)getDateStringWithTime:(NSDate *)currentDate;
+ (NSString *)getTimeString;
+ (NSString *)getTimeStringbyMills:(NSTimeInterval)time;
+ (NSString *)getTimeMillisString;
+ (NSString *)getTimeDifferencebydif:(NSTimeInterval)dif;
+ (NSString *)getServerTime;
+ (NSString *)getDateTime;
+ (NSString *)getDateTimeWithTime:(NSDate *)currentDate;
+ (NSDate *)getCurrentServerDate;
+ (NSString *)currentDay;
+ (NSString *)formatDataToString:(NSDate*)date;
+ (NSString *)getDateTimeWithOutTime;


+ (NSString *)getDateStringForDevice;
+ (NSString *)getTimeMillisStringForDevice;

/*
 * for 拍照加水印使用
 */
+ (NSString *)getLocalizedWeekAndDateString;
+ (NSString *)getLocalizedWeekAndDateStringFormatDot;
/*
 * for 拍照加水印使用
 */
+ (NSString *)getShortTimeString;
+ (NSString *)getShortTimeStringWithTime:(NSDate *)currentDate;
+ (NSInteger)yearDifferencetWith:(NSString *) calendarIndentifier andIndentifier:(NSString *)otherCalendarIndentifier;

+ (BOOL)systemCalendaIdentifierEqualTo:(NSString *)calendarIdentifier;

+ (NSString *)currentTimeWithCalendarIndentifier:(NSString *)calendarIndentifier;

+ (NSInteger)currentYearWithCalendarIndentifier:(NSString *)calendarIndentifier;

+ (NSDate *)currentDateWithCalendarIndentifier:(NSString *)calendarIndentifier;

+ (NSString *)getMD5TimeWithDataType:(NSString *)dataType;

+ (NSDateComponents *)YMDComponents;

+ (NSDate *)getDate4TimeStr:(NSString *)timeStr;

+ (NSInteger)getDurationWithFomeDateStr:(NSString *)fomeDateStr withEndDateStr:(NSString *)endDateStr;

+ (NSString *)dateFromNowMonth:(NSInteger)mIndex  day:(NSInteger)dIndex;
// 增加不止当月推算日期
+ (NSString *)dateFromMonthOfDate:(NSDate *)date andMonth:(NSInteger)mIndex day:(NSInteger)dIndex;

+ (NSUInteger)numberOfDaysInCurrentMonth;

+ (NSString *)getNextMonthLastDay;

+ (NSString *)weedDay;

+ (NSInteger)yearIndex;

+ (NSInteger)monthIndex;

- (NSInteger)dayIndex;

+ (NSInteger)distanceFromNowToMonth:(NSInteger)month;

+ (NSString *)getCurrentTimeForRichMedia;

+ (NSString *)getTimestampString;

// YIHAIKERRY-1085 获取两个日期的间隔时间的详细信息
+ (NSDictionary *)getTotalTimeInfoDictWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

+ (NSString *)getTimeStringWithInterval:(double)interval withFormat:(NSString *)timeFormat;

#pragma mark - 比对时间差异(分钟) startTime:起始时间 endTime:结束时间
+ (NSInteger)comparisonTimeDifferenceMinute:(NSString *)startTime endTime:(NSString *)endTime;


/// 比较时间是否在一周之内
/// - Parameters:
///   - startTime: 开始时间
///   - endTime: 结束时间
+ (NSInteger)comparisonINWeekDayTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

//YIHAIKERRY-3575
//益海嘉里上海大客户销量上报需求
+ (NSString *)getLastMonthString;

//日期比较
+ (NSInteger)differencewithDate:(NSString*)dateString withDate:(NSString*)anotherdateString;

+ (NSString *)getTimeFromTimestamp:(double)time;

@end
