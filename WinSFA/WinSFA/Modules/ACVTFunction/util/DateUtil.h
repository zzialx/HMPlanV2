//
//  DateUtil.h
//  humor
//
//  Created by zeng yonghong on 11-4-29.
//  Copyright 2011年 fractalist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, enCalendarViewType)
{
    en_calendar_type_week = 1,
    en_calendar_type_month = 2,
};

#define DATE_FORMAT_EN_US_CST @"EEE MMM dd HH:mm:ss 'CST' yyyy"

#define LOCAL_REPRESENT_EN_US @"en_US"

#define DATE_FORMAT_CH_WITHOUT_SEP @"yyyyMMddKmmss"

#define DATE_FORMAT_CH_WITH_SEP @"yyyy-MM-dd K:mm:ss"

#define DATE_FORMAT_CH_WITH_CHN @"yyyy年MM月dd日 K:mm:ss"

#define DATE_FORMAT_CH_WITH_CHN_NOTIME @"yyyy年MM月dd日"

#define DATE_FORMAT_CH_WITH_SEP_NOTIME @"yyyy-MM-dd"

#define DATE_FORMAT_CH_WITH_SEP_NOSEC @"yyyy-MM-dd HH:mm"

#define DATE_FORMAT_CH_WITH_NOS_SEP @"yyyy-MM-dd k:mm"

#define DATE_FORMAT_CH_WITH_SEP_SEC @"yyyy-MM-dd HH:mm:ss"

#define DATE_FORMAT_CH  @"yyyy-MM-dd"

#define DATE_HOUR_CH @"HH:mm"

#define DATE_FORMAT_YEAR_MONTH @"yyyy-MM"

#define DATE_FORMAT_YEAR @"yyyy"

@interface DateUtil : NSObject {
 
    NSString *animalyear;
}
-(id)init;
//获取nsdate对象
-(NSDate *)dateString:(NSString *)dstr formateString:(NSString *)formatestr localstr:(NSString *)local;
//获取字符串表示
-(NSString *)obtainDate:(NSDate *)date formateString:(NSString*)formatestr;   

//求begin 到 to的天数
-(NSInteger)computeDateDeviedDate:(NSDate *)begin to:(NSDate *)to;

//
+(NSString *)getCurrentTimeIntervalString;
+(NSString *)getCurrentTimeIntervalDoubleString;

-(NSDate *)dateFromString:(NSString *)dateString;

-(NSString *)formatDate:(NSDate *)date;


-(NSDate *)dateFromDate:(NSDate *)date withFormateStr:(NSString *)formatestr;


//获得当前是星期几
-(NSInteger)getWeekDayFromDate:(NSDate *)date;

//获取当前日期的前一天
-(NSDate *)getPreviousDateForCurrentDate:(NSDate *)date;

//取当前日期的前几个小时的时间
-(NSDate *)getPreviousHourForCurrentDate:(NSDate *)date previouseHour:(NSInteger)hour;

//获取当前日期的指定时间前一天
-(NSDate *)getPreviousDateForCurrentDate:(NSDate *)date withPointTime:(NSString *)time;

//获取当前时候后的几个小时的时间
-(NSDate *)getAfterHoursForCurrentDate:(NSDate *)date afteredHours:(NSInteger)hour;

-(NSDate *)getAfterHoursForCurrentDateStr:(NSString *)dateStr afteredHours:(NSInteger)hour;

//取出两个日期相隔的日期数组，包含开始和结束
-(NSMutableArray *)getDateArrayFromDate:(NSDate *)begin to:(NSDate *)to;

//获得从当前日期指定自然月个数的日期对象
-(NSDate *)getNatureDateFromNow:(NSDate *)begin andMonths:(NSInteger)months;

//比较两个日期，相等返回0，nowdate大于cmpdate 返回1 nowdate 小于cmpdate返回－1
-(NSInteger)dateCompare:(NSDate *)cmpdate nowDate:(NSDate *)date;

-(NSDate *)getAfterMinutesForCurrentDate:(NSDate *)date afteredMinutes:(float)minute;

//获取农历年份

-(NSString *)LunarForSolar:(NSDate *)solarDate;

//获取属相

-(NSString *)getAnimalDate:(NSDate *)selecteddate;
//获取星座

-(NSString *)getStarByMonth:(NSInteger)month andDay:(NSInteger)day;

//获得当前小时
-(NSInteger)getCurrentHour:(NSDate *)date;
//当前日
- (NSUInteger)getDay:(NSDate *)date;

- (NSDate *)nextMoth:(NSDate *)aDate;

- (NSDate *)previousMoth:(NSDate *)aDate;


+ (BOOL)checkSameDayWithDay1:(NSDate *)day1 withDay2:(NSDate *)day2;

+ (BOOL)checkSameWeekWithWeek1:(NSDate *)week1 withWeek2:(NSDate *)week2;

+ (BOOL)checkSameMonthWithMonth1:(NSDate *)month1 withMonth2:(NSDate *)month2;

//日历上通过指定的日期获取当前位置的date
+ (NSDate *)dateForCalendarIndexPath:(NSIndexPath *)indexPath withIndexDate:(NSDate *)indexFirstDate byFirstWeekday:(NSInteger)firstWeekday;

//获取当前日期星期几（英文显示）
- (NSString *)getWeekDayEnglishFromDate:(NSDate *)aDate;


- (NSDate *)zeroOfDate;

@end
