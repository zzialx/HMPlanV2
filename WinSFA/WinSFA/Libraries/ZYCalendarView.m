//
//  ZYCalendarView.m
//  ZYCalendar
//
//  Created by winchannel on 16/10/26.
//  Copyright © 2016年 KangKang. All rights reserved.
//

#import "ZYCalendarView.h"
#import "ZYCalendarViewCell.h"
#import "UIView+BorderLine.h"
#define TPOTABBOTTOMLINE_COLOR [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]

extern NSString* ZYCalendarViewCellIdentifier;

@interface ZYCalendarView ()<ZYCalendarViewCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    
    NSInteger               currentPage;
    NSInteger               pageNumber;
    UIView  *         dataHeadView;
    UIView  *         timeHeadView;
    UILabel *         timeLabel;
    BOOL              isToday;
    NSInteger        startDayForWeek;  // 周日历的起始是周几
}
@property (nonatomic, assign) enCalendarViewType      type;

@end

@implementation ZYCalendarView

- (id)initWithFrame:(CGRect)frame CalendarType:(enCalendarViewType)pType withPageNumber:(int)collectionPageNumber withWeekStartDay:(NSString *)startDay{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.type = pType;
        if ([startDay isEqualToString:@"1"]) {
            startDayForWeek = 1;
        }else{
            startDayForWeek = 0;
        }
        pageNumber = collectionPageNumber;
        self.currentDate = [NSDate date];
        
        if (pType == en_calendar_type_week) {
            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
            
            self.fromDate = [DateUtil dateForCalendarIndexPath:fromIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
            self.toDate = [DateUtil dateForCalendarIndexPath:toIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
        }else{
            [self getMonthBeginAndEndWith:self.currentDate byFirstWeekday:startDayForWeek];
        }

        
        self.pointArray = [[NSMutableArray alloc]init];
        self.stateArray = [[NSMutableArray alloc]init];
        self.inplanStoreArray = [[NSMutableArray alloc]init];
        
        [self SetTimeHeadView];
        [self SetDataHeadView];
        [self SetCollectionView];
    }
    return self;
}

- (void)getMonthBeginAndEndWith:(NSDate *)newDate byFirstWeekday:(NSInteger)firstWeekday{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (firstWeekday == 1) {
        [calendar setFirstWeekday:2];//设定周一为周首日
    }
    BOOL ok = [calendar rangeOfUnit:NSMonthCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    //分别修改为 NSDayCalendarUnit NSWeekCalendarUnit NSYearCalendarUnit
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
        self.fromDate = beginDate;
        self.toDate = endDate;
    }else {
        return;
    }
    NSDateFormatter *myDateFormatter = [NSDateFormatter standardDateFormatter];
    [myDateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    NSString *s = [NSString stringWithFormat:@"%@-%@",beginString,endString];
    NSLog(@"%@",s);
}


- (NSArray *)getDaysOfTheWeek {
    NSDateFormatter *dateFormatter = [NSDateFormatter standardDateFormatter];
    
    // adjust array depending on which weekday should be first
    NSArray *weekdays = [dateFormatter shortWeekdaySymbols];
    NSCalendar *calendar =  [NSCalendar currentCalendar];
    NSUInteger firstWeekdayIndex = [calendar firstWeekday] -1;
    if (_type == en_calendar_type_week && startDayForWeek == 1) {
        firstWeekdayIndex = [calendar firstWeekday];
    }
    if (firstWeekdayIndex > 0)
    {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7-firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0,firstWeekdayIndex)]];
    }
    return weekdays;
}

- (float)GetCalendarViewHeight{
    
    ZYCalendarViewCell *the_cell = [[self.calendarCollectionView visibleCells] lastObject];
    float rt = the_cell.getCalendarHeight;
    rt+= [self GetHeaderViewHeigth];
    return rt;
}

- (float)GetHeaderViewHeigth{
    
    float rt = timeHeadView.frame.size.height + dataHeadView.frame.size.height;
    return rt;
}

 //绘制head 和日历
- (void)SetTimeHeadView{
    //时间文本
    if (timeHeadView) {
        return;
    }
    
    timeHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, kTimeHeadViewHeight)];
    [self addSubview:timeHeadView];

    UIColor *mainTintColor = [UIColor colorForKey:@"MainTintColor"];
    
    CGFloat timeWidth = 140;
    CGFloat todayWidth = 48;
//    CGFloat labelButtonWidth = timeWidth + todayWidth + MAIN_CELL_PADDING;
    CGFloat paddingTime = (self.width -  timeWidth) / 2;
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(paddingTime, MAIN_CELL_PADDING * 0.5, timeWidth, 24)];
    [timeLabel setText:@"2014-2"];
    [timeLabel setFont:[UIFont systemFontOfSize:15]];
    [timeLabel setTextAlignment:NSTextAlignmentCenter];
    [timeLabel setTextColor:mainTintColor];
    [timeHeadView addSubview:timeLabel];
    
    //todayButton
    UIButton *todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [todayButton setFrame:CGRectMake(self.frame.size.width - todayWidth - MAIN_CELL_PADDING , MAIN_CELL_PADDING * 0.5, todayWidth, 24)];
    [todayButton addTarget:self action:@selector(ScrollToToday) forControlEvents:UIControlEventTouchUpInside];
    [todayButton setTitle:NSLocalizedString(@"今日", nil)  forState:UIControlStateNormal];
    [todayButton  setTitleColor:mainTintColor forState:UIControlStateNormal];
    todayButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    todayButton.layer.borderWidth = 1.0;
    todayButton.layer.cornerRadius = 5;
    todayButton.layer.borderColor = MAIN_SEPERATE_LINE_COLOR.CGColor;
    [timeHeadView addSubview:todayButton];
}

- (void)SetDataHeadView{
    
    
    if (dataHeadView) {
        return;
    }
    float width = self.frame.size.width;
    
    NSArray *weekDays = [self getDaysOfTheWeek];
    float day_width = width/7;
    
   dataHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, timeHeadView.frame.origin.y + timeHeadView.frame.size.height, width, kDateHeadViewHeight)];
    dataHeadView.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    dataHeadView = [dataHeadView borderForColor:TPOTABBOTTOMLINE_COLOR borderWidth:0.5 borderType:UIBorderSideTypeTop];
    dataHeadView = [dataHeadView borderForColor:TPOTABBOTTOMLINE_COLOR borderWidth:0.5 borderType:UIBorderSideTypeBottom];
    [self addSubview:dataHeadView];
    // 周六 周日的index
    int satIndex = 6;
    int sunIndex = 0;
    if (_type == en_calendar_type_week && startDayForWeek == 1) {
        satIndex = 5;
        sunIndex = 6;
    }
    
    for (int i = 0 ; i<7 ; i++) {
        UILabel* each_day = [[UILabel alloc] init];
        NSString *each_day_str = [weekDays objectAtIndex:i];
        [each_day setText:each_day_str.uppercaseString];
        [each_day setTextAlignment:NSTextAlignmentCenter];
        [each_day setFont:[UIFont systemFontOfSize:13]];
        if (i == satIndex || i == sunIndex) {
            each_day.textColor = [UIColor grayColor];
        }else{
            each_day.textColor = [UIColor blackColor];
        }
        CGRect each_day_frame = CGRectMake(i*day_width, 2 , day_width, kDateHeadViewHeight - 4);
        [each_day setFrame:each_day_frame];
        [dataHeadView addSubview:each_day];
    }
    
}

- (void)SetCollectionView{
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0];
    [layout setMinimumInteritemSpacing:0];
    [layout setItemSize:CGSizeMake(width, height-[self GetHeaderViewHeigth])];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.calendarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, [self GetHeaderViewHeigth] , width, height - [self GetHeaderViewHeigth]) collectionViewLayout:layout];
    //calendarCollectionView.bounces = NO;
    [self.calendarCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.calendarCollectionView setDelegate:self];
    [self.calendarCollectionView setDataSource:self];
    [self.calendarCollectionView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.calendarCollectionView];
    self.calendarCollectionView.pagingEnabled = YES;
    
    [self.calendarCollectionView registerClass:[ZYCalendarViewCell class] forCellWithReuseIdentifier:ZYCalendarViewCellIdentifier.copy];
    
    currentPage = pageNumber/2;
    NSIndexPath* mid_index = [NSIndexPath indexPathForRow:currentPage inSection:0];
    [self.calendarCollectionView scrollToItemAtIndexPath:mid_index atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self SetLabelDate:[NSDate date]];

}
- (void) SetLabelDate:(NSDate*)_date
{
    NSDateFormatter* ff = [NSDateFormatter standardDateFormatter];
    [ff setDateFormat:@"yyyy-MM"];
    NSString *year_month = [ff stringFromDate:_date];
//    DateUtil *dateUtil = [[DateUtil alloc]init];
    if (timeLabel)
    {
        if (self.type == en_calendar_type_week) {
            
//            NSString *date = [NSString stringWithFormat:@"%@-(%lu ~ %lu)",year_month,(unsigned long)[dateUtil getDay:self.fromDate],(unsigned long)[dateUtil getDay:self.toDate] ];
            
            // SFA-17007 与安卓统一，此处只显示年月
            NSString *date = [NSString stringWithFormat:@"%@",year_month];

             [timeLabel setText:date];
        }else{
            [timeLabel setText:year_month];
        }
        
    }
}

- (void)ScrollToToday{
    if (currentPage == pageNumber/2 ) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
        ZYCalendarViewCell *cell = (ZYCalendarViewCell *)[self.calendarCollectionView cellForItemAtIndexPath:indexPath];
        cell.selectDate = nil;
        [self didSelecteDate:[NSDate date]];
        [self SetDateViewDot];
        currentPage = pageNumber/2;
        return ;
    }
    
    self.currentDate = [NSDate date];
    if (self.type == en_calendar_type_week) {
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];

        self.fromDate = [DateUtil dateForCalendarIndexPath:fromIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
        self.toDate = [DateUtil dateForCalendarIndexPath:toIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
        
    }else{
        [self getMonthBeginAndEndWith:self.currentDate byFirstWeekday:startDayForWeek];
    }
    currentPage = pageNumber/2;

    [self SetLabelDate:self.currentDate];
     BOOL isCurrentSchIsChanged =  [self.delegate calendarViewScrollViewTodayAndICurrentSchIsChanged];
    if (isCurrentSchIsChanged == NO) {
        [self.delegate calendarView:self didMoveToMonth:self.currentDate];
    }
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:pageNumber/2 inSection:0];
    [self.calendarCollectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    [self.calendarCollectionView reloadItemsAtIndexPaths:@[indexpath]];
    
    isToday = YES;
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return pageNumber;
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZYCalendarViewCell *cell = [self.calendarCollectionView dequeueReusableCellWithReuseIdentifier:ZYCalendarViewCellIdentifier.copy forIndexPath:indexPath];
    
    NSDate *cell_date = [self getCellDateByIndex:indexPath.row];
    
    
    if (currentPage == pageNumber/2 && isToday) {
        cell_date = [NSDate date];
        isToday = NO;
        [self didSelecteDate:cell_date];
    }else{
        cell.selectDate = self.selectedDate;
    }
    cell.delegate = self;
    cell.firstDayOfWeek = startDayForWeek;

    [cell SetWithDate:cell_date showType:self.type];
    
    
    return cell;

}

- (NSDate *)getCellDateByIndex:(NSInteger)index {
    NSDate *cell_date = self.currentDate;
    
    DateUtil *dateUtil = [[DateUtil alloc]init];
    NSInteger scrollPages = index - currentPage;
    if (scrollPages != 0 ) {
        if (self.type == en_calendar_type_month) {
            if (scrollPages >0) {
                while (scrollPages > 0) {
                    cell_date = [dateUtil nextMoth:cell_date];
                    scrollPages--;
                }
            }else if (scrollPages <0){
                while (scrollPages < 0) {
                    cell_date = [dateUtil previousMoth:cell_date];
                    scrollPages++;
                }
            }
        }else if (self.type == en_calendar_type_week){
            
            if (scrollPages >0) {
                cell_date = [dateUtil getAfterHoursForCurrentDate:self.currentDate afteredHours:7*24 * scrollPages];
                
            }else if (scrollPages <0){
                cell_date = [dateUtil getPreviousHourForCurrentDate:self.currentDate previouseHour:7*24 * (-scrollPages)];
            }
        }
        
    }
    
    return cell_date;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat cell_width = scrollView.frame.size.width;
    NSInteger pos_x = scrollView.contentOffset.x;
    NSInteger index = (pos_x+20)/cell_width;
    
    NSDate *cell_date = [self getCellDateByIndex:index];
    
    self.currentDate = cell_date;
    
    currentPage = index;
    if (self.type == en_calendar_type_week) {
        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:6 inSection:0];
        self.fromDate = [DateUtil dateForCalendarIndexPath:fromIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
        self.toDate = [DateUtil dateForCalendarIndexPath:toIndexPath withIndexDate:self.currentDate byFirstWeekday:startDayForWeek];
    }else{
        [self getMonthBeginAndEndWith:self.currentDate byFirstWeekday:startDayForWeek];
    }
    [self SetLabelDate:self.currentDate];
    
    
    NSDateFormatter* ff = [NSDateFormatter standardDateFormatter];
    [ff setDateFormat:@"yyyy-MM-dd"];
    
    [self.delegate calendarView:self didMoveToMonth:nil];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
    ZYCalendarViewCell *cell = (ZYCalendarViewCell *)[self.calendarCollectionView cellForItemAtIndexPath:indexPath];
    cell.selectDate = nil;

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (INTERFACE_IS_PHONE ) {
        if ([self.superview.superview.superview isKindOfClass:[UIScrollView class]] && self.type == en_calendar_type_week) {
            [(UIScrollView *)self.superview.superview.superview setScrollEnabled:NO];
        }
        if ([self.superview.superview.superview.superview isKindOfClass:[UIScrollView class]] && self.type == en_calendar_type_month) {
            [(UIScrollView *)self.superview.superview.superview.superview setScrollEnabled:NO];
        }
    }
}

- (void)didSelecteDate:(NSDate *)aDate{
    
    self.currentDate = aDate;
    self.selectedDate = aDate;
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelecteDate:)]) {
        [self.delegate calendarView:self didSelecteDate:aDate];
    }
    
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
     ZYCalendarViewCell *cell = (ZYCalendarViewCell *)[self.calendarCollectionView cellForItemAtIndexPath:indexPath];
    [cell setNumber:number];
    
}
- (void)SetDateViewDot{
    
    float cell_width = self.calendarCollectionView.frame.size.width;
    int pos_x = self.calendarCollectionView.contentOffset.x;
    int index = (pos_x+20)/cell_width;
    if (index == currentPage) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
        ZYCalendarViewCell *cell = (ZYCalendarViewCell *)[self.calendarCollectionView cellForItemAtIndexPath:indexPath];
        cell.isExChangeMap = self.isExChangeMap;
        [cell SetDateViewDot];
    }

}

-(NSArray *)calendar:(ZYCalendarViewCell *)calendarViewCell eventArrayForDate:(NSDate *)date{
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    for (int i =0 ; i <self.pointArray.count ; i++) {
         id selectedDate =[self.pointArray objectAtIndex:i];
        NSDate *date_;
        if ([selectedDate isKindOfClass:[NSString class]]) {
            date_ = [dateFormat dateFromString:(NSString *)selectedDate];
            
        }else if ([selectedDate isKindOfClass:[NSDate class]]){
            date_ = (NSDate *)selectedDate;
        }
        NSString *state = nil ;
        NSString *count = nil;
        if (i< self.stateArray.count) {
            state =[self.stateArray objectAtIndex:i];
        }
        if (i < self.inplanStoreArray.count) {
            count = [self.inplanStoreArray objectAtIndex:i];
        }
        
        if ([DateUtil checkSameDayWithDay1:date_ withDay2:date]) {
            
            if (state && state.length >0) {
                return [NSArray arrayWithObject:state];
            }else if (count && count.length >0){
                return [NSArray arrayWithObject:count];
            }else{
                return [NSArray arrayWithObject:[NSNull null]];
            }
            
        }
    }
    return nil;
}

- (NSArray *)calendarViewEventArrayForDate:(NSDate *)date{
    
    NSArray *eventArray = [self calendar:nil eventArrayForDate:date];
    return eventArray;
}

- (void)reloadViewWithArray:(NSArray *)aArray {
    
}
@end
