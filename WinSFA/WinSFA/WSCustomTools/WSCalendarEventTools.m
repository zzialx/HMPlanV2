//
//  WSCalendarEventTools.m
//  WinSFA
//
//  Created by yuanji on 2018/2/2.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCalendarEventTools.h"
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - 日历事件工具 延展(内部)
@interface WSCalendarEventTools ()

@property (nonatomic, strong) EKEventStore *calendarEvent; //日历事件

@end
//===================================================================================================================================================================

#pragma mark - 日历事件工具 延展(工具)
@interface WSCalendarEventTools (Tools)

#pragma mark - 获取指定日期内的全部日历事件方法 dateStr:日期字符(格式:yyyy-MM-dd)
- (NSArray *)getCalendarEventWithDateStr:(NSString *)dateStr;

@end
//===================================================================================================================================================================

#pragma mark - 日历事件工具
@implementation WSCalendarEventTools

#pragma mark - 获取共享日历事件工具
+ (instancetype)sharedManager
{
    static WSCalendarEventTools *calendarEventTools;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        calendarEventTools = [[WSCalendarEventTools alloc] init];
    });
    
    return calendarEventTools;
}

#pragma mark - 重写init方法
- (instancetype)init
{
    if (self = [super init])
        _calendarEvent = [[EKEventStore alloc] init];
    
    return self;
}

#pragma mark - 创建日历事件方法(按时间创建) timeStr:时间字符(格式:yyyy-MM-dd HH:mm) title:标题 description:描述
- (void)createCalendarEventWithTimeStr:(NSString *)timeStr andTitle:(NSString *)title andDescription:(NSString *)description
{
    if(!timeStr || !title || !description)
        return;
    
    EKAuthorizationStatus eventStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(eventStatus == EKAuthorizationStatusNotDetermined)
    {
        __weak __typeof(self) weakSelf = self;
        [self.calendarEvent requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if(granted)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf createCalendarEventWithTimeStr:timeStr andTitle:title andDescription:description];
                 });
             }
         }];
    }
    else if(eventStatus == EKAuthorizationStatusAuthorized)
    {
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
        startDateComponents.minute = 0;
        NSDate *startDate = [calendar dateByAddingComponents:startDateComponents toDate:[formatter dateFromString:timeStr] options:0];
        if(!startDate)
            return;
        
        EKEvent *newEvent = [EKEvent eventWithEventStore:self.calendarEvent];
        newEvent.title = title;
        newEvent.notes = description;
        newEvent.startDate = startDate;
        newEvent.endDate = startDate;
        newEvent.allDay = NO;
        newEvent.alarms = @[[EKAlarm alarmWithRelativeOffset:0]];
        [newEvent setCalendar:[self.calendarEvent defaultCalendarForNewEvents]];
        
        [self.calendarEvent saveEvent:newEvent span:EKSpanThisEvent commit:YES error:nil];
    }
}

#pragma mark - 删除日历事件方法(按天删除全部日历事件) dateStr:日期字符(格式:yyyy-MM-dd) title:标题(以标题为依据删除)
- (void)deleteCalendarEventWithDateStr:(NSString *)dateStr andTitle:(NSString *)title
{
    if(!dateStr || !title)
        return;
    
    EKAuthorizationStatus eventStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(eventStatus == EKAuthorizationStatusNotDetermined)
    {
        __weak __typeof(self) weakSelf = self;
        [self.calendarEvent requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if(granted)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf deleteCalendarEventWithDateStr:dateStr andTitle:title];
                 });
             }
         }];
    }
    else if(eventStatus == EKAuthorizationStatusAuthorized)
    {
        NSArray *calendarEvents = [self getCalendarEventWithDateStr:dateStr];
        [calendarEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             EKEvent *event = (EKEvent *)obj;
             if([event.title isEqualToString:title])
             {
                 [event setCalendar:[self.calendarEvent defaultCalendarForNewEvents]];
                 [self.calendarEvent removeEvent:event span:EKSpanThisEvent commit:YES error:nil];
             }
         }];
    }
}

#pragma mark - 删除日历事件方法(按时间删除某个日历事件) timeStr:时间字符(格式:yyyy-MM-dd HH:mm) description:描述(以描述为依据删除)
- (void)deleteCalendarEventWithTimeStr:(NSString *)timeStr andDescription:(NSString *)description
{
    if(!timeStr || !description)
        return;
    
    EKAuthorizationStatus eventStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if(eventStatus == EKAuthorizationStatusNotDetermined)
    {
        __weak __typeof(self) weakSelf = self;
        [self.calendarEvent requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if(granted)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf deleteCalendarEventWithTimeStr:timeStr andDescription:description];
                 });
             }
         }];
    }
    else if(eventStatus == EKAuthorizationStatusAuthorized)
    {
        NSArray *components = [timeStr componentsSeparatedByString:@" "];
        NSString *dateStr = components.firstObject;
        NSArray *calendarEvents = [self getCalendarEventWithDateStr:dateStr];
        if(calendarEvents.count <= 0)
            return;
        
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [formatter dateFromString:timeStr];
        [calendarEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             EKEvent *event = (EKEvent *)obj;
             if([event.startDate isEqualToDate:date] || [event.description containsString:description])
             {
                 [event setCalendar:[self.calendarEvent defaultCalendarForNewEvents]];
                 [self.calendarEvent removeEvent:event span:EKSpanThisEvent commit:YES error:nil];
             }
         }];
    }
}

@end
//===================================================================================================================================================================

#pragma mark - 日历事件工具 延展(工具)
@implementation WSCalendarEventTools (Tools)

#pragma mark - 获取指定日期内的全部日历事件方法 dateStr:日期字符(格式:yyyy-MM-dd)
- (NSArray *)getCalendarEventWithDateStr:(NSString *)dateStr
{
    if(!dateStr)
        return nil;
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateStr];
    if(!date)
        return nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
    startDateComponents.day = 0;
    NSDate *startDate = [calendar dateByAddingComponents:startDateComponents toDate:date options:0];
    NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
    endDateComponents.day = 1;
    NSDate *endDate = [calendar dateByAddingComponents:endDateComponents toDate:date options:0];
    
    NSPredicate *predicate = [self.calendarEvent predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [self.calendarEvent eventsMatchingPredicate:predicate];
    return events;
}

@end
//===================================================================================================================================================================
