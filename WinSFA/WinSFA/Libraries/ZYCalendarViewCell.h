//
//  ZYCalendarViewCell.h
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateUtil.h"

@class ZYCalendarViewCell;

@protocol ZYCalendarViewCellDelegate <NSObject>

@optional
- (void)didSelecteDate:(NSDate *)aDate;

- (void)didChangeViewHeight:(CGFloat)changeHeight;

-(NSArray *)calendar:(ZYCalendarViewCell *)calendarViewCell eventArrayForDate:(NSDate *)date;

@end


@interface ZYCalendarViewCell : UICollectionViewCell

@property (nonatomic, weak) id<ZYCalendarViewCellDelegate> delegate;
@property (nonatomic, assign)enCalendarViewType calendarType;
@property (nonatomic, strong)    NSDate             *selectDate;
@property (nonatomic, assign, getter = getCalendarHeight) CGFloat  calendarHeight;
@property (nonatomic, assign) BOOL isExChangeMap;
@property (nonatomic, assign) NSInteger firstDayOfWeek;
@property (nonatomic, assign) NSInteger number;

- (void)SetWithDate:(NSDate *)aDate showType:(enCalendarViewType)calendarType;

- (void)SetDateViewDot;

@end
