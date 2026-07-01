//
//  NSDate+Formatter.h
//  SystemXinDai
//
//  Created by LvJianfeng on 16/3/26.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "NSDate+Formatter.h"
#import "WSAttanceViewModel.h"

@implementation NSDate (Formatter)

+ (NSDate *)yesterday{
    return  [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
}

+(NSDateFormatter *)formatter {
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

+(NSDateFormatter *)formatterWithoutTime {
    
    static NSDateFormatter *formatterWithoutTime = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatterWithoutTime = [[NSDate formatter] copy];
        [formatterWithoutTime setTimeStyle:NSDateFormatterNoStyle];
    });
    
    return formatterWithoutTime;
}

+(NSDateFormatter *)formatterWithoutDate {
    
    static NSDateFormatter *formatterWithoutDate = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        formatterWithoutDate = [[NSDate formatter] copy];
        [formatterWithoutDate setDateStyle:NSDateFormatterNoStyle];
    });
    
    return formatterWithoutDate;
}

#pragma mark -
#pragma mark Formatter with date & time
-(NSString *)formatWithUTCTimeZone {
    return [self formatWithTimeZoneOffset:0];
}

-(NSString *)formatWithLocalTimeZone {
    return [self formatWithTimeZone:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset {
    return [self formatWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatWithTimeZone:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatter];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark -
#pragma mark Formatter without time
-(NSString *)formatWithUTCTimeZoneWithoutTime {
    return [self formatWithTimeZoneOffsetWithoutTime:0];
}

-(NSString *)formatWithLocalTimeZoneWithoutTime {
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffsetWithoutTime:(NSTimeInterval)offset {
    return [self formatWithTimeZoneWithoutTime:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatWithTimeZoneWithoutTime:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatterWithoutTime];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}

#pragma mark -
#pragma mark Formatter without date
-(NSString *)formatWithUTCWithoutDate {
    return [self formatTimeWithTimeZone:0];
}
-(NSString *)formatWithLocalTimeWithoutDate {
    return [self formatTimeWithTimeZone:[NSTimeZone localTimeZone]];
}

-(NSString *)formatWithTimeZoneOffsetWithoutDate:(NSTimeInterval)offset {
    return [self formatTimeWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
}

-(NSString *)formatTimeWithTimeZone:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [NSDate formatterWithoutDate];
    [formatter setTimeZone:timezone];
    return [formatter stringFromDate:self];
}
#pragma mark -
#pragma mark Formatter  date
+ (NSString *)currentDateStringWithFormat:(NSString *)format
{
    NSDate *chosenDate = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:chosenDate];
    return date;
}
+ (NSDate *)dateWithSecondsFromNow:(NSInteger)seconds {
    NSDate *date = [NSDate date];
    NSDateComponents *components = [NSDateComponents new];
    [components setSecond:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateSecondsAgo = [calendar dateByAddingComponents:components toDate:date options:0];
    return dateSecondsAgo;
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}
- (NSString *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:format];
    NSString *date = [formatter stringFromDate:self];
    return date;
}
- (NSString *)yyyyMMByLineWithDate{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM"];
    return [formatter stringFromDate:self];
}

- (NSString *)mmddByLineWithDate{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"MM-dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)mmddChineseWithDate{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"MM月dd日"];
    return [formatter stringFromDate:self];
}

- (NSString *)hhmmssWithDate{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [formatter setDateFormat:@"HH:mm:ss"];
    return [formatter stringFromDate:self];
}

- (NSString *)yyyyMMddByLineWithDate{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:self];
}

- (NSString *)morningOrAfterWithHH{
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"HH"];
    NSString *status = [formatter stringFromDate:self];
    if (status.intValue > 0 && status.intValue < 12) {
        return @"上午好";
    }else{
        return @"下午好";
    }
    return @"";
}
+ (NSInteger)timeCompare:(NSString*)dateStr{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateA = [dateFormatter dateFromString:date.yyyyMMddByLineWithDate];
    NSDate *dateB = [dateFormatter dateFromString:dateStr];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        return 0; //今天之前
    }
    else if (result == NSOrderedAscending){
        return 1;//今天之后
    }
    return 2;//今天
    
}

#pragma mark - 验证当前日期方法(当天之前和60天以后无效)
+ (BOOL)validateWithSelectDateStr:(NSString *)selectDateStr {
        
    NSDate *currentdate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSDateComponents *startComponents = [[NSDateComponents alloc] init];
    [startComponents setYear:0];
    [startComponents setMonth:0];
    [startComponents setDay:-1];
    NSDate *startDate = [calendar dateByAddingComponents:startComponents toDate:currentdate options:0];
    NSString *startDateStr = [dateFormatter stringFromDate:startDate];
    
    NSDateComponents *endComponents = [[NSDateComponents alloc] init];
    [endComponents setYear:0];
    [endComponents setMonth:0];
    [endComponents setDay:61];
    NSDate *endDate = [calendar dateByAddingComponents:endComponents toDate:currentdate options:0];
    NSString *endDateStr = [dateFormatter stringFromDate:endDate];
    
    NSDate *start = [dateFormatter dateFromString:startDateStr];
    NSDate *end = [dateFormatter dateFromString:endDateStr];
    NSDate *selectDate = [dateFormatter dateFromString:selectDateStr];
    if ([selectDate compare:start] == NSOrderedDescending && [selectDate compare:end] == NSOrderedAscending) {
        return YES;
    }
    return NO;
}

@end
