//
//  DateUtil.m
//  humor
//
//  Created by zeng yonghong on 11-4-29.
//  Copyright 2011 fractalist. All rights reserved.
//

#import "DateUtil.h"


@implementation DateUtil

-(id)init{
    
    return [super init];
}

/**
 This function have three parameters,first parameter is a NSString object that represent a string of date
 second parameter is a NSString object that represent a string of date formate (for example: like a "EEE MMM dd HH:mm:ss 'CST' yyyy" or other standard date formate string or customized date formate string)
 the third parameter is a NSString object that represent a string of a local identifier (for example: like a "en_US,zh_CN" or other standard local identifier),this function will return a NSDate Object for the terminal user.
 **/

-(NSDate *)dateString:(NSString *)dstr formateString:(NSString *)formatestr localstr:(NSString *)local
{
    NSDateFormatter *dateformate= [NSDateFormatter standardDateFormatter];
    [dateformate setDateFormat:formatestr];
    NSDate *date =nil;
    @try {
        date=[dateformate dateFromString:dstr];
    }
    @catch (NSException *exception) {

        NSLog(@"===>>>>> %@",exception);
    }
    @finally {
        
    }
    
    
    return date;
}
/**
 */

-(NSString *)obtainDate:(NSDate *)date formateString:(NSString *)formatestr{
    NSString *daterepresent=@"";
    NSDateFormatter *dateformate= [NSDateFormatter standardDateFormatter];
    [dateformate setDateFormat:formatestr];
    daterepresent=[dateformate stringFromDate:date];
    
    return daterepresent;
}

-(NSDate *)dateFormat:(NSDate *)date formateString:(NSString *)formatestr{
    
    NSDateFormatter *dateformate= [NSDateFormatter standardDateFormatter];
    [dateformate setDateFormat:formatestr];
    
    
    return nil;
    
}


-(NSDate *)dateFromDate:(NSDate *)date withFormateStr:(NSString *)formatestr{
    
    NSDateFormatter *df = [NSDateFormatter standardDateFormatter];
    
    [df setDateFormat:formatestr];
    
    NSDate *returndate=[df dateFromString:[df stringFromDate:date]];

    return returndate;
    
}

-(NSInteger)computeDateDeviedDate:(NSDate *)begin to:(NSDate *)to{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:begin  toDate:to  options:0];
    NSInteger days = [comps day];
    
    return days;
    
}

-(NSMutableArray *)getDateArrayFromDate:(NSDate *)begin to:(NSDate *)to{
    
    
    NSMutableArray *distantdate=[[NSMutableArray alloc] init];
    
    
    NSInteger  days=[self computeDateDeviedDate:begin to:to];
    
    NSDate   *dateinfo=nil;
    
    
    int hours=24;
    
    [distantdate addObject:begin];
    
    for (int i=1;i<=days;i++) {
        
        dateinfo = [self getAfterHoursForCurrentDate:begin afteredHours:hours];
        
        [distantdate addObject:dateinfo];
        NSLog(@"日期直接输出=>>>> %@",dateinfo);
        NSLog(@"日期转化后==>>>> %@",[self obtainDate:dateinfo formateString:@"yyyy-MM-dd k:mm"]);
        begin= dateinfo;
        
    }
    
    //[distantdate addObject:to];
    
    return distantdate;
}

+(NSString *)getCurrentTimeIntervalString{
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    
    NSString *curTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
    
    return curTime;
}

+(NSString *)getCurrentTimeIntervalDoubleString{
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
//    double dTime = [[NSNumber numberWithDouble:time] doubleValue]; // 将double转为long long型
    
    NSString *curTime = [NSString stringWithFormat:@"%.6f",time]; // 输出long long型
    
    return curTime;
}

- (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return destDate;
    
}

-(NSString *)formatDate:(NSDate *)date{
    
    NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    NSString* str = [formatter stringFromDate:date];
    return str;
    
}



-(NSInteger)getWeekDayFromDate:(NSDate *)date{
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit) fromDate:date];
    
    return [comps weekday];
    
    
    
}
- (NSString *)getWeekDayEnglishFromDate:(NSDate *)aDate{
    
    long weekday = [self getWeekDayFromDate:aDate];
    
    switch (weekday -1) {
        case 0:
            return @"Sunday";
            break;
        case 1:
            return @"Monday";
            break;
        case 2:
            return @"Tuesday";
            break;
        case 3:
            return @"Wednesday";
            break;
        case 4:
            return @"Thursday";
            break;
        case 5:
            return @"Friday";
            break;
        case 6:
            return @"Saturday";
            break;
        default:
            break;
    }
    return nil;


}

-(NSInteger)getCurrentHour:(NSDate *)date{
    
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    comps =[calendar components:(NSHourCalendarUnit) fromDate:date];
    
    return [comps hour];
    
}



//获取当前日期的前一天
-(NSDate *)getPreviousDateForCurrentDate:(NSDate *)date{
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - 24*3600)];
    
    return newDate;
}

//获取当前日期的指定时间前一天
-(NSDate *)getPreviousDateForCurrentDate:(NSDate *)date withPointTime:(NSString *)time{
    
    NSDate  *newdate=[self getPreviousDateForCurrentDate:date];
    
    NSString *newdatestr= [self obtainDate:newdate formateString:@"yyyy-MM-dd"];
    
    NSString  *newdatetimestr=[NSString stringWithFormat:@"%@ %@",newdatestr,time];
    
    NSDate   *previousdatebyspecifictime=[self  dateString:newdatetimestr formateString:DATE_FORMAT_CH_WITH_NOS_SEP localstr:@"zh_CN"];

    return previousdatebyspecifictime;
}
//取当前日期的前几个小时的时间
-(NSDate *)getPreviousHourForCurrentDate:(NSDate *)date previouseHour:(NSInteger)hour{
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] - hour*3600)];
    
    return newDate;
}


//获取当前时候后的几个小时的时间
-(NSDate *)getAfterHoursForCurrentDate:(NSDate *)date afteredHours:(NSInteger)hour{
    
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + (float)hour*3600)];
    return newDate;
    
}
-(NSDate *)getAfterHoursForCurrentDateStr:(NSString *)dateStr afteredHours:(NSInteger)hour{
    
    NSDate *date = [self dateFromString:dateStr];
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + (float)hour*3600)];
    
    return newDate;
}



-(NSDate *)getAfterMinutesForCurrentDate:(NSDate *)date afteredMinutes:(float)minute{
    
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + minute*36000)];
    return newDate;
    
}


//获得从当前日期指定自然月个数的日期对象
-(NSDate *)getNatureDateFromNow:(NSDate *)begin andMonths:(NSInteger)months
{
    NSDate  *resultdate =  nil;
    int  totaldays = [self getCurrentMonthSDays:begin];
    int  currentday= (int)[self getDay:begin];
    int devideday=totaldays-currentday;
    if (devideday==0) {
        
        devideday =totaldays;
    }
    //先获得当前日期到月底的天数
    int year =(int) [self getYear:begin];
    int month =(int)[self getMonth:begin];
    if (month==12) {
        month=0;
    }
    //循环获取相邻月份的天数，并相加
    for(int i=month+1;i<=months;i++){
        NSString *month=[NSString stringWithFormat:@"%d",i];
        NSString *datenext=nil;
        if ([month length]<2) {
            datenext=[NSString stringWithFormat:@"%d-0%d-0%d",year,i,1];
        }else{
            datenext=[NSString stringWithFormat:@"%d-%d-0%d",year,i,1];
        }
        NSDate *xdate=[self dateFromString:datenext];
        devideday += [self getCurrentMonthSDays:xdate];
    }
    resultdate =[self getAfterHoursForCurrentDate:begin afteredHours:(devideday  *24)];
    return resultdate;
}

//比较两个日期，相等返回0，nowdate大于cmpdate 返回1 nowdate 小于cmpdate返回－1
-(NSInteger)dateCompare:(NSDate *)cmpdate nowDate:(NSDate *)date{
    NSInteger compareresult =0;
    if ([date compare:cmpdate]==0) {
        return 0;
    
    }
    
    NSDate  *compdate= [date earlierDate:cmpdate];
    
    if ([compdate isEqual:cmpdate]) {
        
         return  -1; //小于
    }else{
        
         return 1; //大于
    }
    
    return compareresult;
}


-(int)getCurrentMonthSDays:(NSDate *)date{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSUInteger numberOfDaysInMonth = range.length;
    return  (int)numberOfDaysInMonth;
    
}


//获取日
- (NSUInteger)getDay:(NSDate *)date{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:date];
	return [dayComponents day];
}
//获取月
- (NSUInteger)getMonth:(NSDate *)date
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:date];
	return [dayComponents month];
}
//获取年
- (NSUInteger)getYear:(NSDate *)date
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:date];
	return [dayComponents year];
}
//获得小时
- (int )getHour:(NSDate *)date {
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *components = [calendar components:unitFlags fromDate:date];
	NSInteger hour = [components hour];
	return (int)hour;
}
//获得分钟
- (int)getMinute:(NSDate *)date {
    
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSUInteger unitFlags =NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit |NSHourCalendarUnit|NSMinuteCalendarUnit;
	NSDateComponents *components = [calendar components:unitFlags fromDate:date];
	NSInteger minute = [components minute];
	return (int)minute;

}


//农历转换函数
-(NSString *)LunarForSolar:(NSDate *)solarDate{
    //天干名称
    NSArray *cTianGan = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];
    
    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                         @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                         @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static NSInteger wCurYear,wCurMonth,wCurDay;
    static NSInteger nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:solarDate];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    animalyear = szShuXiang;
    
    
    NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];
    
    
    //生成农历月、日
    NSString *szNongliDay;
    
    if (wCurMonth < 1){
        
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    }
    else{
        
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth];
    }
    
    NSString *lunarDate = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}

-(NSString *)getAnimalDate:(NSDate *)selecteddate{
    
    [self LunarForSolar:selecteddate];
    
    return animalyear;
    
}

-(NSString *)getStarByMonth:(NSInteger)month andDay:(NSInteger)day{
    
    NSString *string= @"魔羯水瓶双鱼牡羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    
    NSInteger array[] = {20,19,21,21,21,22,23,23,23,23,22,22};
    
    NSInteger index = month*2-(day<array[month-1]?2:0);
    
    NSString *content =[string substringWithRange:NSMakeRange(index, 2)];
    
    return content;
    
}
//获得当前日期
- (NSString *)dateOfday:(NSDate *)aDate{
    
    NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
    formatter.dateFormat = @"d";
    
    return [formatter stringFromDate:aDate];
}

- (NSDate *)nextMoth:(NSDate *)aDate{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 12)
    {
        comps.month = month+1;
        rt = [cal dateFromComponents:comps];
    }
    else
    {
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, (long)month+1];
        NSDateFormatter* ff = [NSDateFormatter standardDateFormatter];
        [ff setDateFormat:@"yyyy-MM-dd"];
        NSDate* the_month = [ff dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, (long)month+1, (long)MIN(day, day_in_month)];
        rt = [ff dateFromString:datestring];
    }
    
    return rt;
    
}

- (NSDate *)previousMoth:(NSDate *)aDate{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 1)
    {
        comps.month = month-1;
        rt = [cal dateFromComponents:comps];
    }
    else
    {
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, (long)month-1];
        NSDateFormatter* ff = [NSDateFormatter standardDateFormatter];
        [ff setDateFormat:@"yyyy-MM-dd"];
        NSDate* the_month = [ff dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, (long)month-1, (long)MIN(day, day_in_month)];
        rt = [ff dateFromString:datestring];
    }
    return rt;
}
+ (BOOL)checkSameDayWithDay1:(NSDate *)day1 withDay2:(NSDate *)day2{
    NSDateFormatter* formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* s1 = [formatter stringFromDate:day1];
    NSString* s2 = [formatter stringFromDate:day2];
    BOOL rt = [s1 isEqualToString:s2];
    return rt;
}

+ (BOOL)checkSameWeekWithWeek1:(NSDate *)week1 withWeek2:(NSDate *)week2{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    cal.firstWeekday = 2;
    NSUInteger count1 = [cal ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:week1];
    NSUInteger count2 = [cal ordinalityOfUnit:NSCalendarUnitWeekOfYear inUnit:NSCalendarUnitYear forDate:week2];
    NSDateComponents* w1 = [cal components:NSCalendarUnitYear|NSCalendarUnitWeekOfMonth fromDate:week1];
    NSDateComponents* w2 = [cal components:NSCalendarUnitYear|NSCalendarUnitWeekOfMonth fromDate:week2];
    BOOL rt = NO;
    if ((w1.weekOfMonth == w2.weekOfMonth) && ([week1 timeIntervalSinceDate:week2]<=24*3600*7))
    {
        rt =  count1 == count2;
        
    }
    return rt;
    
}

+ (BOOL)checkSameMonthWithMonth1:(NSDate *)month1 withMonth2:(NSDate *)month2{
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* m1 = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:month1];
    NSDateComponents* m2 = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:month2];
    BOOL rt = NO;
    if ((m1.year == m2.year) && (m1.month == m2.month))
    {
        rt = YES;
    }
    return rt;
}

+ (NSDate *)dateForCalendarIndexPath:(NSIndexPath *)indexPath withIndexDate:(NSDate *)indexFirstDate byFirstWeekday:(NSInteger)firstWeekday{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (firstWeekday == 1) {
        [calendar setFirstWeekday:2];
    }
    NSDateComponents *offset = [NSDateComponents new];
    
    offset.month = indexPath.section;
    
    NSDate *firstOfMonth = [calendar dateByAddingComponents:offset toDate:indexFirstDate options:0];
    
    NSInteger ordinalityOfFirstDay = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:firstOfMonth];
    
    NSDateComponents *dateComponents = [NSDateComponents new];
    
    dateComponents.day = ( 1 - ordinalityOfFirstDay) + indexPath.item;
    
    return [calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];

}

// 获取今天的0点时间
- (NSDate *)zeroOfDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
}


@end


