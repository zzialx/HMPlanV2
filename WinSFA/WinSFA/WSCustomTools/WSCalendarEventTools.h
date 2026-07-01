//
//  WSCalendarEventTools.h
//  WinSFA
//
//  Created by yuanji on 2018/2/2.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//===================================================================================================================================================================

#pragma mark - 日历事件工具
@interface WSCalendarEventTools : NSObject

#pragma mark - 获取共享日历事件工具
+ (instancetype)sharedManager;

#pragma mark - 创建日历事件方法(按时间创建) timeStr:时间字符(格式:yyyy-MM-dd HH:mm) title:标题 description:描述
- (void)createCalendarEventWithTimeStr:(NSString *)timeStr andTitle:(NSString *)title andDescription:(NSString *)description;

#pragma mark - 删除日历事件方法(按天删除全部日历事件) dateStr:日期字符(格式:yyyy-MM-dd) title:标题(以标题为依据删除)
- (void)deleteCalendarEventWithDateStr:(NSString *)dateStr andTitle:(NSString *)title;

#pragma mark - 删除日历事件方法(按时间删除某个日历事件) timeStr:时间字符(格式:yyyy-MM-dd HH:mm) description:描述(以描述为依据删除)
- (void)deleteCalendarEventWithTimeStr:(NSString *)timeStr andDescription:(NSString *)description;

@end
//===================================================================================================================================================================
