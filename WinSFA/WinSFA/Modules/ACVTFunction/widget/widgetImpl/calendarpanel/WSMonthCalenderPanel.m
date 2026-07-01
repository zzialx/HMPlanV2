//
//  WSMonthCalenderPanel.m
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMonthCalenderPanel.h"
#import "WSMonthCollectionHeadView.h"
#import "WSMonthCollectionViewCell.h"
#import "WSMonthCollectionViewLayout.h"
#import "WSBaseDictsDBService.h"
#import "WSCalenderLogic.h"

#define COLLECTION_SECTION 1
#define YEAR_CALENDER_BOTTOM_SCROLLVIEW_HEIGHT 50.0f


@interface WSMonthCalenderPanel ()

@property(nonatomic,assign)CGSize size;
@property(nonatomic,strong)WSMonthCollectionViewLayout *collectionViewlayout;
@property(nonatomic,strong)NSString *selectYear;
@property(nonatomic,strong)NSString *selctedMonth;

@end

@implementation WSMonthCalenderPanel

static NSString *MonthHeader = @"MonthHeaderView";

static NSString *DayCell = @"DayCell";

-(id)initWithFrame:(CGRect)frame   funcs:(WSFuncsBean *)funcs{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _size = frame.size;
        self.currentFuncs = funcs;
        [self initMonthCollectionData];
        [self initMonthCollectionView];
        [self initYearCalenderBottomScrollView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, YEAR_CALENDER_BOTTOM_SCROLLVIEW_HEIGHT, self.bounds.size.width, 1)];
        [line setBackgroundColor:[UIColor colorWithHexString:@"#d8d8d8"]];
        [self addSubview:line];
        
        return self;
    }
    return nil;
}

/*
  获取月的数据models 不带考勤记录
 */
- (void)initMonthCollectionData {
     NSUInteger daysCount = [[NSDate date] numberOfDaysInCurrentMonth];//计算这个月有多少天
    _months = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyyMM"];
    NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
    NSDate *currentDate = [formatter dateFromString:currentDateString];
    
    WSCalenderLogic *logic = [[WSCalenderLogic alloc] init];
    self.months = [logic reloadCalendarView:currentDate selectDate:nil needDays:daysCount];
    [self generateAttendanceRecordsMonthsData];
}

/*
  数据 塞入models
 */
- (void)generateAttendanceRecordsMonthsData {
    WSDutyBeanArray *dutyBeanArray = [WSAppData getObjectbyKey:DUTY_ATTENDANCEDETAIL];
 
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    NSArray* otherDutyArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
    
    [dutyBeanArray.dutyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __block  WSDutyBean *dutyBean = (WSDutyBean *)obj;
        [otherDutyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSDictBean *dictBean = (WSDictBean *)obj;
            if (dutyBean.morning && dictBean.Id && [dutyBean.morning isEqualToString:dictBean.Id]) {
                //
                [dutyBean setMorning:dictBean.name];
            }
            if (dutyBean.afternoon && dictBean.Id && [dutyBean.afternoon isEqualToString:dictBean.Id]) {
                [dutyBean setAfternoon: dictBean.name];
            }
        }];
        
    }];
    
    
    NSArray *month = [self.months firstObject];
    if ([month count] > 0) {
        for (NSInteger i = 0; i < [month count]; i++) {
            __block WSMonthCollectionViewCellModel *cellModel = [month objectAtIndex:i];
            if (dutyBeanArray.dutyArray) {
                 [dutyBeanArray.dutyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     WSDutyBean *tmpDutybean = (WSDutyBean *)obj;
                     NSInteger year =[tmpDutybean.year integerValue];
                     NSInteger month = [tmpDutybean.month integerValue];
                     NSInteger day = [tmpDutybean.day integerValue];
                     if (cellModel.year == year
                         && cellModel.month == month
                         && cellModel.day == day) {
                         [cellModel setDutyBean:tmpDutybean];
                     }
                 }];
            }
        }
    }
}

- (void)initMonthCollectionView {
    _collectionViewlayout = [WSMonthCollectionViewLayout new];
    _collectionViewlayout.cellHeight = [self collectionCellHeight];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, YEAR_CALENDER_BOTTOM_SCROLLVIEW_HEIGHT, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:_collectionViewlayout]; //初始化网格视图大小
    self.collectionView.backgroundColor = [UIColor grayColor];
    [self.collectionView registerClass:[WSMonthCollectionViewCell class] forCellWithReuseIdentifier:DayCell];//cell重用设置ID
    
    [self.collectionView registerClass:[WSMonthCollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader];
    
    //    self.collectionView.bounces = NO;//将网格视图的下拉效果关闭
    
    self.collectionView.delegate = self;//实现网格视图的delegate
    
    self.collectionView.dataSource = self;//实现网格视图的dataSource
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self  addSubview:self.collectionView];
}

- (void)initYearCalenderBottomScrollView {
    
     WSYearCalenderBottomScrollView *yearCalenderBottomScrollView = [[WSYearCalenderBottomScrollView alloc]  initWithFrame:CGRectMake(0,0.0f, _size.width, YEAR_CALENDER_BOTTOM_SCROLLVIEW_HEIGHT)];
    yearCalenderBottomScrollView.delegate = self;
    [self addSubview:yearCalenderBottomScrollView];
}


- (CGFloat)collectionCellHeight {
    CGFloat collectionHeadTopMargin = 0.f;
    CGFloat collectionHeadHeight = 43.f;
    CGFloat collectionViewBottonMargin = 10.f;
    CGFloat collectionContentHeight = 768 - 64.0f - (kSegmentedControlHeight + kSegmentedControlTopGap + kSegmentedControlBottomGap) - YEAR_CALENDER_BOTTOM_SCROLLVIEW_HEIGHT -  collectionHeadTopMargin - collectionHeadHeight - collectionViewBottonMargin;
    
    NSMutableArray *days = [self.months firstObject];
    CGFloat cellHeight = 90.0f;
    NSInteger daysCount = [days count];
    NSInteger row = daysCount/7;
    cellHeight = collectionContentHeight/row;
    return cellHeight;
}

-(void)relodDataWith:(NSMutableArray *)tmpMonths {
   
    [self initMonthCollectionData];
//    if (_months == nil) {
//        _months = [[NSMutableArray alloc]init];
//    }
//    self.months = tmpMonths;
    [self.collectionView reloadData];
}


- (void)collectionViewReloadWith:(NSString *)year month:(NSString *)month {
    
}

#pragma mark - CollectionView代理方法

//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return COLLECTION_SECTION;
}


//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    
    return [[self.months firstObject] count];
}


//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WSMonthCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DayCell forIndexPath:indexPath];
    NSMutableArray *days = [self.months firstObject];
    WSMonthCollectionViewCellModel *model = [days objectAtIndex:indexPath.row];
    cell.model = model;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        WSMonthCollectionHeadView *tmpMonthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader forIndexPath:indexPath];
        
        reusableview = tmpMonthHeader;
    }
    return reusableview;
    
}


//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

//    WSMonthCollectionViewCellModel  *model = [[self.months firstObject] objectAtIndex:indexPath.row];

    /*
    if (model.style == MonthCellDayTypeFutur || model.style == MonthCellDayTypeWeek ||model.style == MonthCellDayTypeClick) {
        //  to do something
        [self.collectionView reloadData];
    }
     */
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}


#pragma mark WSYearCalenderBottomScrollViewDelegate Methods 
- (void)yearCalenderBottomScrollView:(WSYearCalenderBottomScrollView *)yearCalender selectedYear:(NSString *)year month:(NSString *)month
{
    self.selectYear = year;
    self.selctedMonth = month;
    [self flipView];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}

/*
 翻页动画
 */

-(void)flipView{
    [UIView beginAnimations:@"FlipAnim" context:NULL];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.collectionView cache:NO];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationDuration:0.5f];

    [UIView commitAnimations];
    
}

-(void)reloadCollectionView {
    if ([self.months count] > 0) {
        [self.months removeAllObjects];
    }
    NSDateFormatter *fromatter = [NSDateFormatter standardDateFormatter];
    [fromatter setDateFormat:@"yyyyMM"];
    NSString *selectedString = nil;
    if ([self.selctedMonth integerValue] < 10) {
        selectedString = [NSString stringWithFormat:@"%@0%@ ",self.selectYear,self.selctedMonth ];
    } else if ([self.selctedMonth integerValue] >= 10) {
        selectedString = [NSString stringWithFormat:@"%@%@",self.selectYear,self.selctedMonth];
    }
    [fromatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSCalendarIdentifierGregorian]];
    [fromatter setTimeZone:[NSTimeZone localTimeZone]];
//    SFA-16622
//    SFA辉瑞医院--考勤记录中数据显示问题
    if (self.selectYear==nil && self.selctedMonth==nil){
        selectedString = [fromatter stringFromDate:[NSDate date]];
    }
    NSDate *selectedDate = [fromatter dateFromString:selectedString];
    WSCalenderLogic *logic = [[WSCalenderLogic alloc] init];
    NSUInteger daysCount = [selectedDate numberOfDaysInCurrentMonth];//计算这个月有多少天
    self.months = [logic reloadCalendarView:selectedDate selectDate:nil needDays:daysCount];
    [self generateAttendanceRecordsMonthsData];
    _collectionViewlayout.cellHeight = [self collectionCellHeight];
    [self.collectionView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
