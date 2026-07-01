//
//  ZYCalendarView.h
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateUtil.h"

static const CGFloat kTimeHeadViewHeight = 40;
static const CGFloat kDateHeadViewHeight = 25;

@class ZYCalendarView;

@protocol ZYCalendarDelegate <NSObject>

@optional

- (void)calendarView:(ZYCalendarView *)aCalendarView didSelecteDate:(NSDate *)aDate;

- (void)calendarView:(ZYCalendarView *)aCanlendarView didMoveToMonth:(NSDate *)aDate;

- (BOOL)calendarViewScrollViewTodayAndICurrentSchIsChanged;

@end

@interface ZYCalendarView : UIView

@property (nonatomic, weak) id<ZYCalendarDelegate> delegate;


@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong)NSMutableArray *stateArray;
@property (nonatomic, strong)NSMutableArray *inplanStoreArray;
@property (nonatomic, strong)UICollectionView *calendarCollectionView;


@property (nonatomic, strong) NSDate * currentDate;
//记住之前选中的日期，为后续标记
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;

@property (nonatomic, assign) BOOL isExChangeMap;
@property (nonatomic, assign) NSInteger number;


- (id) initWithFrame:(CGRect)frame CalendarType:(enCalendarViewType)pType withPageNumber:(int)collectionPageNumber withWeekStartDay:(NSString *)startDay;

- (void)SetDateViewDot;

- (NSArray *)calendarViewEventArrayForDate:(NSDate *)date;

- (void)reloadViewWithArray:(NSArray *)aArray;

@end
