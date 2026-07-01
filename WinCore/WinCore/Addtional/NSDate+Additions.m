//
//  NSDate+Additions.m
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

/*
 * 获取时间戳字符串,按照产品需求拼出来
 */
- (NSString *)getTimeString
{
    NSString *title = nil;
    
    if([self compareWithToday] == 0)
    {
        // 如果是今天
        title = [NSString stringWithFormat:NSLocalizedString(@"%@",@"%@"), [self stringForTimelineWithFormat:@"hh:mm a"]];
    }
    else if([self compareWithToday] == -1)
    {
        // 如果是昨天
        title = [NSString stringWithString:NSLocalizedString(@"Yesterday", @"Yesterday")];
    }
    else if([self compareWithToday] <= -2 && [self compareWithThisWeek])
    {
        switch ([self getWeekDay]) {
            case 1:
                title = @"Sunday";
                break;
            case 2:
                title = @"Monday";
                break;
            case 3:
                title = @"TuesDay";
                break;
            case 4:
                title = @"Wednesday";
                break;
            case 5:
                title = @"Thursday";
                break;
            case 6:
                title = @"Friday";
                break;
            case 7:
                title = @"Saturday";
                break;
            default:
                break;
        }
    }
    else
    {
        title = [NSString stringWithValue:[self stringForTimelineWithFormat:@"MM/dd/yyyy"]];
    }
    return title;
}

- (NSString *)getTimeStringForComment
{
    NSString *title = nil;
    
    if([self compareWithToday] == 0)
    {
        // 如果是今天
        title = [NSString stringWithFormat:NSLocalizedString(@"%@",@"%@"), [self stringForTimelineWithFormat:@"hh:mm a"]];
    }
    else if([self compareWithToday] == -1)
    {
        // 如果是昨天
        title = [NSString stringWithFormat:NSLocalizedString(@"Yesterday %@", @"Yesterday %@"),[self stringForTimelineWithFormat:@"hh:mm a"]];
    }
    else
    {
        // 昨天以前
        title = [NSString stringWithValue:[self stringForTimelineWithFormat:@"MM/dd/yyyy hh:mm a"]];
    }
    return title;
}

+ (NSDate *)currentGregorianDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    if([calendar isEqual:NSGregorianCalendar]){
        return now;
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:calendar.calendarIdentifier];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitYear |
                                                              NSCalendarUnitMonth |
                                                              NSCalendarUnitDay|
                                                              NSCalendarUnitHour|
                                                              NSCalendarUnitMinute|
                                                              NSCalendarUnitSecond |
                                                              NSCalendarUnitNanosecond) fromDate:[NSDate date]];
    return [gregorian dateFromComponents:dateComponents];
}

/*
 * 与今天的时间做比较
 */
- (NSInteger) compareWithToday {
	
	
	NSDate *today = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[formatter setDateFormat:@"yyyy-MM-dd"];
	
	NSString *todayStr = [formatter stringFromDate:today];
	today = [formatter dateFromString:todayStr];
	
	NSInteger interval = (NSInteger) [self timeIntervalSinceDate:today];
	
	NSInteger intervalDate = 0;
	if (interval <= 0) {
		intervalDate = interval / (24 * 60 * 60) - 1;
	} else {
		intervalDate = interval / (24 * 60 * 60);
	}
	
	return intervalDate;
}

/*
 * 按给定格式返回时间字符串
 */
- (NSString *) stringForTimelineWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	[formatter setDateFormat:format];
	NSString *timeStr = [formatter stringFromDate:self];
	

	return timeStr;
}


- (BOOL)compareWithThisWeek
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:date];
    NSInteger thisWeek = [comps week]; // 今年的第几周
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:self];
    NSInteger compareWeek = [comps week];
    
    return thisWeek == compareWeek;
}

- (NSInteger)getWeekDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:self];
    NSInteger weekDay = [comps weekday];
    return weekDay;
}

- (NSDate *)ws_dateAddingByDay:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:day];
    NSDate *date = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    return date;
}

- (NSDate *)ws_dateAddingByMonth:(NSInteger)month {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setMonth:month];
    NSDate *date = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    return date;
}

- (NSDate *)ws_dateAddingByYear:(NSInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setYear:year];
    NSDate *date = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    return date;
}

@end
