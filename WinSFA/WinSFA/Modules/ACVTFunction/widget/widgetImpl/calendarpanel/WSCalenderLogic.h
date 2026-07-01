//
//  WSYearCalenderLogic.h
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WSMonthCollectionViewCellModel.h"
#import "NSDate+WSYearCalendarLogic.h"

@interface WSCalenderLogic : NSObject;

- (NSMutableArray *)reloadCalendarView:(NSDate *)date selectDate:(NSDate *)date1 needDays:(NSInteger) days_number;

- (void)selectLogic:(WSMonthCollectionViewCellModel *)day;

@end
