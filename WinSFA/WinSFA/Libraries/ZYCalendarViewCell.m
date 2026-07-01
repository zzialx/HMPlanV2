//
//  ZYCalendarViewCell.m
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import "ZYCalendarViewCell.h"
#import "ZYCalendarDayCell.h"
#import "ZYCalendarViewFlowLayout.h"
#import "DateUtil.h"

extern NSString* ZYCalendarDayCellIdentifier;
const NSString* ZYCalendarViewCellIdentifier = @"PWSCalendarViewCellIdentifier";

@interface ZYCalendarViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    
    NSCalendar*        calendar;
    UICollectionView*  _collectionView;
    
    
}
@property (nonatomic, strong) NSDate *firstDate;
@end

@implementation ZYCalendarViewCell

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        calendar = [NSCalendar currentCalendar];
        _firstDate = [NSDate date];
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews{
    
    ZYCalendarViewFlowLayout *layout = [[ZYCalendarViewFlowLayout alloc]init];
    CGFloat itemWidth = floor(CGRectGetWidth(self.bounds)/7);
    if (itemWidth > self.height) {
        itemWidth = self.height;
    }
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    [self.contentView addSubview:_collectionView];
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setScrollEnabled:NO];
    
    [_collectionView registerClass:[ZYCalendarDayCell class] forCellWithReuseIdentifier:ZYCalendarDayCellIdentifier.copy];
    
}

- (void)setCalendarType:(enCalendarViewType)calendarType{
    
    _calendarType = calendarType;
    [_collectionView reloadData];
}

- (void)SetWithDate:(NSDate *)aDate showType:(enCalendarViewType)calendarType{
    
    if (calendarType == en_calendar_type_month)
    {
        _firstDate = [self GetFirstDayOfMonth:aDate];
    }
    else if (calendarType == en_calendar_type_week)
    {
        _firstDate = aDate;
        
    }
    self.calendarType = calendarType;
}

- (NSDate*) GetFirstDayOfMonth:(NSDate*)pDate
{
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitYear fromDate:pDate];
    NSDate* rt = [calendar dateFromComponents:components];
    return rt;
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger rt = 0 ;
    
     CGFloat itemWidth = floorf(CGRectGetWidth(collectionView.bounds) / 7);
     CGFloat itemHeight = itemWidth;
    if (self.calendarType == en_calendar_type_month) {
        NSRange rangeOfWeeks = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:_firstDate];
        self.calendarHeight = itemHeight*rangeOfWeeks.length;
        rt = (rangeOfWeeks.length * 7);
    }else if (self.calendarType == en_calendar_type_week){
        
        self.calendarHeight = itemHeight;
        rt = 7;
    }
    return rt;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZYCalendarDayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZYCalendarDayCellIdentifier.copy forIndexPath:indexPath];
    
    NSDate* cell_date  = [DateUtil dateForCalendarIndexPath:indexPath withIndexDate:_firstDate byFirstWeekday:self.firstDayOfWeek];
    NSDateComponents *cellDateComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:cell_date];
    NSDateComponents *firstOfMonthsComponents = [calendar components:NSCalendarUnitMonth fromDate:_firstDate];
   
     NSArray *eventArray = [self.delegate calendar:self eventArrayForDate:cell_date];
    cell.isExChangeMap = self.isExChangeMap;
    
    BOOL  isSelected = [cell_date isEqualToDate:self.selectDate];
    if (self.calendarType == en_calendar_type_month)
    {
        if (cellDateComponents.month == firstOfMonthsComponents.month)
        {
            [cell setP_date:cell_date];
        }
        else
        {
            isSelected = NO;
            [cell setP_date:nil];
        }
    }
    else if (self.calendarType == en_calendar_type_week)
    {
        [cell setP_date:cell_date];

    }
    [cell SetEventArray:eventArray];
    [cell setSelected:isSelected];
    if(isSelected && _number != -1)
    {
        [cell setNumber:_number];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelecteDate:)]) {
        NSDate* date = [DateUtil dateForCalendarIndexPath:indexPath withIndexDate:_firstDate byFirstWeekday:self.firstDayOfWeek];
        [self.delegate performSelector:@selector(didSelecteDate:) withObject:date];
         self.selectDate = date;
        [collectionView reloadData];
    }
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    [_collectionView reloadData];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *selectdate = [DateUtil dateForCalendarIndexPath:indexPath withIndexDate:_firstDate byFirstWeekday:self.firstDayOfWeek];
    if (self.calendarType == en_calendar_type_month) {
        return   [DateUtil checkSameMonthWithMonth1:selectdate withMonth2:_firstDate];
    }else if (self.calendarType == en_calendar_type_week){
         return YES;
    }
    return NO;
}

- (void)SetDateViewDot{
    
    [_collectionView reloadData];
}

@end
