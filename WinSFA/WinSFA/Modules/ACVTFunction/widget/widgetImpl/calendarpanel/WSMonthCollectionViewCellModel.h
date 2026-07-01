//
//  WSMonthCollectionViewCellModel.h
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+WSYearCalendarLogic.h"

#import "WSDutyBean.h"

typedef NS_ENUM(NSInteger, MonthCollectionViewCellDayType) {
    MonthCellDayTypeEmpty,   //不显示
    MonthCellDayTypePast,    //过去的日期
    MonthCellDayTypeFutur,   //将来的日期
    MonthCellDayTypeWeek,    //周末
    MonthCellDayTypeClick    //被点击的日期
    
};


@interface WSMonthCollectionViewCellModel : NSObject

@property (assign, nonatomic) MonthCollectionViewCellDayType style;//显示的样式

@property (nonatomic, assign) NSUInteger day;//天
@property (nonatomic, assign) NSUInteger month;//月
@property (nonatomic, assign) NSUInteger year;//年
@property (nonatomic, assign) NSUInteger week;//周

@property (nonatomic, strong) NSString *Chinese_calendar;//农历
@property (nonatomic, strong) NSString *holiday;//节日

@property (nonatomic, strong) WSDutyBean *dutyBean;


+ (WSMonthCollectionViewCellModel *)calendarDayWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;
- (NSDate *)date;//返回当前天的NSDate对象
- (NSString *)toString;//返回当前天的NSString对象
- (NSString *)getWeek; //返回星期


@end
