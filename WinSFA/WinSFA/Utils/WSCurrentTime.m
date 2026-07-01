//
//  CurrentTime.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-19.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import "WSCurrentTime.h"
#import "WSAppData.h"

@implementation WSCurrentTime

+(NSString*)getYearString
{
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    
    return [WSCurrentTime getYearStringWithTime:currentDate];

}
+(NSString*)getYearStringWithTime:(NSDate *)currentDate
{
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy"];
    NSString *date = nil;
    date = [formatDate stringFromDate: currentDate];
    return date;
}

+ (NSString*)getMonthString
{
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    return [WSCurrentTime getMonthStringWithTime:currentDate];
}
+ (NSString*)getMonthStringWithTime:(NSDate *)currentDate
{
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM"];
    
    NSString *date = nil;
    date = [formatDate stringFromDate: currentDate];
    return date;
}

+ (NSString*)getWeekString
{
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM－c/cc"];
    
    NSString *date = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    date = [formatDate stringFromDate: currentDate];

    return date;
}

+ (NSString *)getDateString{
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    
    return [WSCurrentTime getDateStringWithTime:currentDate];
}
+ (NSString*)getDateStringWithTime:(NSDate *)currentDate
{
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = nil;
    date = [formatDate stringFromDate: currentDate];
    return date;
}

+ (NSString *)getDateStringForDevice {
    
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = nil;
    NSDate *currentDate = [NSDate currentGregorianDate];
    date = [formatDate stringFromDate: currentDate];
    
    return date;
}

+ (NSString *)getTimeString{
  
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"HH:mm:ss"];
    NSString *time = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    time = [formatTime stringFromDate:currentDate];

    return time;
}


+ (NSString *)getTimeStringbyMills:(NSTimeInterval)time{

    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"HH:mm:ss"];
    NSString *ret = [formatTime stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
    return ret;
}

+ (NSString *)getTimeMillisString{
    NSTimeInterval timeOS;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    timeOS = [currentDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", (timeOS * 1000.0)];
}

+ (NSString *)getTimeMillisStringForDevice{
    NSTimeInterval timeOS;
    NSDate *currentDate = [NSDate currentGregorianDate];
    timeOS = [currentDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f", (timeOS * 1000.0)];
}

+ (NSString *)getTimestampString{
    NSTimeInterval timeOS;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    timeOS = [currentDate timeIntervalSince1970];
    
    long long time = (long long)timeOS;
    return [NSString stringWithFormat:@"%llu", time];
}

/*
 * for 拍照加水印使用
 */
+ (NSString *)getLocalizedWeekAndDateString
{
    NSDateFormatter *formatDate = [NSDateFormatter currentLocaleDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd EEEE"];
    
    NSString *date = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    date = [formatDate stringFromDate: currentDate];
    
    return date;
}

+ (NSString *)getLocalizedWeekAndDateStringFormatDot
{
    NSDateFormatter *formatDate = [NSDateFormatter currentLocaleDateFormatter];
    [formatDate setDateFormat:@"yyyy.MM.dd EEEE"];
    
    NSString *date = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    date = [formatDate stringFromDate: currentDate];
    
    return date;
}

/*
 * for 拍照加水印使用
 */
+ (NSString *)getShortTimeString
{
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    
    return [WSCurrentTime getShortTimeStringWithTime:currentDate];
}
+ (NSString *)getShortTimeStringWithTime:(NSDate *)currentDate
{
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"HH:mm"];
    
    NSString *time = nil;
    time = [formatTime stringFromDate:currentDate];
    return time;
}

+ (NSString *)getTimeDifferencebydif:(NSTimeInterval)dif{
    int hour = 0;
    int min = 0;
    int sec = 0;
    
    sec = (int)dif % 60;
    
    int _min = dif / 60;
    
    min = _min % 60;
    
    int _hour = _min / 60;
    
    hour = _hour % 60;
    NSString *ret = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    
    return ret;
}

+ (NSString*)getServerTime
{
    return [NSString stringWithFormat:@"%lf", [[WSCurrentTime getTimeMillisString] longLongValue] / 1000.0];
}

+ (NSString*)getDateTime
{
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    
    return [WSCurrentTime getDateTimeWithTime:currentDate];
}
+ (NSString*)getDateTimeWithTime:(NSDate *)currentDate
{
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *time = nil;
    time = [formatTime stringFromDate:currentDate];
    
    return time;
}

+ (NSString*)getDateTimeWithOutTime
{
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *time = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    time = [formatTime stringFromDate:currentDate];
    
    return time;
}

+ (NSString *)currentDay {
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd"];
    NSString *day = [formatTime stringFromDate:currentDate];
    return day;
}

+ (NSString *)formatDataToString:(NSDate*)date
{
    if (date) {
        NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [formatTime stringFromDate:date];
    }
    return @"NON";
}

+ (NSDate *)getCurrentServerDate {

    
    //is_offline_landing = 1 时，上传均采用手机端时间
    NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
    if ([isOfflineLanding isEqualToString:@"1"]) {
        return [NSDate currentGregorianDate];
    }
    
    NSNumber *baseUptime = [[NSUserDefaults standardUserDefaults] objectForKey:@"tickTime"];
    NSDate *serverTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverTime"];
    if (baseUptime == nil || serverTime == nil) {
        LogInfo(@"baseUptime:%@, serverTime:%@", baseUptime, serverTime);
        return [NSDate date];
    }
    time_t nowUptime = [WSAppData uptime];
    NSDate *nowServerDate = [NSDate dateWithTimeInterval:(nowUptime - [baseUptime longValue]) sinceDate:serverTime];
    return nowServerDate;
}

+ (NSInteger)yearDifferencetWith:(NSString *)oneCalendarIndentifier andIndentifier:(NSString *)otherCalendarIndentifier {
    // NSRepublicOfChinaCalendar,NSBuddhistCalendar
    NSInteger chinaCalendarYear = [self currentYearWithCalendarIndentifier:NSCalendarIdentifierRepublicOfChina];
    NSInteger buddhistCalendarYear = [self currentYearWithCalendarIndentifier:NSCalendarIdentifierBuddhist];
    NSInteger different = ABS(buddhistCalendarYear - chinaCalendarYear);
    return different;
}

+ (NSInteger)currentYearWithCalendarIndentifier:(NSString *)calendarIndentifier {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIndentifier];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth |NSCalendarUnitYear) fromDate:[NSDate date]];
    
    NSInteger currentYear = [dateComponents year];
    return currentYear;
}

+ (NSString *)currentTimeWithCalendarIndentifier:(NSString *)calendarIndentifier {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIndentifier];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth |NSCalendarUnitYear) fromDate:[NSDate date]];
    
    NSInteger currentYear = [dateComponents year];
    NSInteger currentMonth = [dateComponents month];
    NSInteger currentDay = [dateComponents day];
    return [NSString stringWithFormat:@"%ld-%ld-%ld",(long)currentYear, (long)currentMonth, (long)currentDay];
}

+ (NSDate *)currentDateWithCalendarIndentifier:(NSString *)calendarIndentifier{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIndentifier];
    
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitDay |
                                                              NSCalendarUnitMonth |
                                                              NSCalendarUnitYear|
                                                              NSCalendarUnitHour|
                                                              NSCalendarUnitMinute|
                                                              NSCalendarUnitSecond) fromDate:[NSDate date]];
    return [gregorian dateFromComponents:dateComponents];

}

+ (BOOL)systemCalendaIdentifierEqualTo:(NSString *)calendarIdentifier {
    BOOL  equal = NO;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    id indentifier = [calendar  calendarIdentifier];
    if ([indentifier isEqual:calendarIdentifier]) {
        equal = YES;
    }
    return equal;
}

+ (NSString *)getMD5TimeWithDataType:(NSString *)dataType
{
    NSString* l_dateStr;
    const char* l_MD5Type = [dataType UTF8String];
    if(l_MD5Type == NULL)
    {
        l_dateStr = [WSCurrentTime getDateString];
        return l_dateStr;
    }
    switch (*l_MD5Type)
    {
        case 'Y':
        {
            l_dateStr = [WSCurrentTime getYearString];
        }
            break;
        case 'M':
        {
            l_dateStr = [WSCurrentTime getMonthString];
            
        }
            break;
        case 'W':
        {
            l_dateStr = [WSCurrentTime getWeekString];
            
        }
            break;
        case 'E':
        {
            l_dateStr = [WSCurrentTime getDateTime];
        }
            break;
        case 'L': //永远覆盖前一条
        {
            l_dateStr = @"L";
            break;
        }
        case 'D': {
            l_dateStr = [WSCurrentTime getDateString];
        }
            break;
        default:
        {
            l_dateStr = [WSCurrentTime getDateString];
        }
            break;
    }
    
    return l_dateStr;
}

//获取年月日对象
+ (NSDateComponents *)YMDComponents
{
    return [[NSCalendar currentCalendar] components:
            NSCalendarUnitYear|
            NSCalendarUnitMonth|
            NSCalendarUnitDay|
            NSCalendarUnitWeekday fromDate:[NSDate date]];
}
+ (NSInteger)getDurationWithFomeDateStr:(NSString *)fomeDateStr withEndDateStr:(NSString *)endDateStr{
    
    //获取近店时间
    NSDate *enterDate = [self getDate4TimeStr:fomeDateStr];
    //离店时间
    NSDate *leaveDate =[self getDate4TimeStr:endDateStr];
    
    NSTimeInterval time = [leaveDate timeIntervalSinceDate:enterDate];
    
    int minute = ((int)time)%(3600*24)/60;
    
    return minute;
    
}
+ (NSDate *)getDate4TimeStr:(NSString *)timeStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    NSArray *array = [timeStr componentsSeparatedByString:@":"];
    
    if (array.count ==3) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];

    }else if (array.count == 2){
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    NSDate *date = [dateFormatter dateFromString:timeStr];
    
    return date;
    
}

+ (NSString *)dateFromNowMonth:(NSInteger)mIndex  day:(NSInteger)dIndex {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:now];
    comps.month = comps.month + mIndex;
    comps.day = dIndex;
    NSDate *resultDate = [cal dateFromComponents:comps];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:resultDate];
}

+ (NSString *)dateFromMonthOfDate:(NSDate *)date andMonth:(NSInteger)mIndex day:(NSInteger)dIndex {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
    comps.month = comps.month + mIndex;
    comps.day = dIndex;
    NSDate *resultDate = [cal dateFromComponents:comps];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:resultDate];
}

+ (NSUInteger)numberOfDaysInCurrentMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    return  range.length;
}

+ (NSString *)weedDay {
    //[NSDateComponents Weekday] 的返回值，默认是 星期天是 1 星期一是 2 ……星期六是 7 。
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSArray *weekdays = [NSArray arrayWithObjects:@"星期日",@"周一", @"周二", @"周三", @"周四", @"周五", @"周六",nil];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSDate *date = [NSDate date];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    return  [weekdays objectAtIndex:theComponents.weekday - 1];
}

+ (NSInteger )yearIndex {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    return components.year;
}
+ (NSInteger)monthIndex {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    return  components.month;
}
- (NSInteger)dayIndex {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth |NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    return  components.day;
}


+ (NSString *)getNextMonthLastDay {
    NSCalendar* cal=[NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    /*
     设置日为1号
     */
    dateComponents.day =1;
    /*
     设置月份为后延2个月
     */
    dateComponents.month +=2;
    NSDate * endDayOfNextMonth = [cal dateFromComponents:dateComponents];
    /*
     两个月后的1号往前推1天，即为下个月最后一天
     */
    endDayOfNextMonth = [endDayOfNextMonth dateByAddingTimeInterval:-1];
    
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd"];
    return [formatDate stringFromDate: endDayOfNextMonth];
}

+ (NSInteger)distanceFromNowToMonth:(NSInteger)month
{
    NSInteger distance = 0;
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:now];
    comps.day = 1;
    
    NSDateComponents *dComps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:now];
    dComps.month = month;
    dComps.day = 1;
    
    distance = dComps.month - comps.month;
    
    // 差值溢出调整
    if (distance<0) {
        distance += 12;
    }

    return distance;
}

+ (NSString *)getCurrentTimeForRichMedia
{    
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *date = nil;
    NSDate *currentDate = [WSCurrentTime getCurrentServerDate];
    date = [formatDate stringFromDate: currentDate];
    
    return date;
}

+ (NSDictionary *)getTotalTimeInfoDictWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    //按照日期格式创建日期格式句柄
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    //将日期字符串转换成Date类型
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    //将日期转换成时间戳
    NSTimeInterval start = [startDate timeIntervalSince1970]*1;
    NSTimeInterval end = [endDate timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    //计算具体的天，时，分，秒
    int second = (int)value %60;//秒
    int minute = (int)value / 60 % 60;
    int hour = (int)value / 3600;
    int day = (int)value / (24 * 3600);
    //将获取的int数据重新转换成字符串
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:[NSNumber numberWithInt:day] forKey:@"day"];
    [resultDict setObject:[NSNumber numberWithInt:hour] forKey:@"hour"];
    [resultDict setObject:[NSNumber numberWithInt:minute] forKey:@"minute"];
    [resultDict setObject:[NSNumber numberWithInt:second] forKey:@"second"];
    
    //返回string类型的总时长
    return [NSDictionary dictionaryWithDictionary:resultDict];
}

+ (NSString *)getTimeStringWithInterval:(double)interval withFormat:(NSString *)timeFormat{
//    YIHAIKERRY-1831 服务器 时间戳处理
   if(@(interval).stringValue.length>10)
    {
        interval = interval/1000;
    }
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    [dateFormatter setDateFormat:timeFormat];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    return [dateFormatter stringFromDate:date];
    
}

#pragma mark - 比对时间差异(分钟) startTime:起始时间 endTime:结束时间
+ (NSInteger)comparisonTimeDifferenceMinute:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *date1 = [dateFormatter dateFromString:startTime];
    NSDate *date2 = [dateFormatter dateFromString:endTime];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitMinute;
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    return cmps.minute;
}
+ (NSInteger)comparisonINWeekDayTimeWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime{
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];

    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSString * oneDayStr = [dateFormatter stringFromDate:startTime];

    NSString * anotherDayStr = [dateFormatter stringFromDate:endTime];

    NSDate  * dateA = [dateFormatter dateFromString:oneDayStr];
    
    NSDate  * dateB = [dateFormatter dateFromString:anotherDayStr];

    NSComparisonResult result = [dateA compare:dateB];

    NSLog(@"date1 : %@, date2 : %@", startTime, startTime);

    if(result ==NSOrderedDescending) {
        return 1;
    }else if(result ==NSOrderedAscending){
        return -1;
    }
    return 0;
}
/*********

比较两个日期之间某年或某月或某日或某时等的具体差值

*******/

+ (NSInteger)differencewithDate:(NSString*)dateString withDate:(NSString*)anotherdateString{

    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];

    [formatter setDateFormat:@"yyyy-MM-dd "];

    NSDate*date2 = [formatter dateFromString:dateString];

    NSDate*date1 = [formatter dateFromString:anotherdateString];

    NSCalendar*gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    unsigned unitFlags = NSCalendarUnitDay;//年、月、日、时、分、秒、周等等都可以

    NSDateComponents * comps = [gregorian components:unitFlags fromDate:date1 toDate:date2 options:0];

    int day = (int)[comps day];//时间差

    NSLog(@"时间差= %d，abs(day)=%d",day,abs(day));

    return day;

}
+ (NSString *)getLastMonthString
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
    //    [lastMonthComps setYear:1]; // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
    lastMonthComps.month = -1;
    NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
    NSString *dateStr = [formatter stringFromDate:newdate];
    return dateStr;
}

+ (NSString *)getTimeFromTimestamp:(double)time{

    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    //将时间转换为字符串
    NSString *timeStr=[formatter stringFromDate:myDate];
    return timeStr;
}

@end
