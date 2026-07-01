//
//  WSCalendaView.m
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import "WSCalendaView.h"
#import "CalendarCell.h"
#import "MonthModel.h"
#import "CalendarHeaderView.h"
#import "NSDate+Formatter.h"
#import "WSDimensMacros.h"
#import "UIColor+Additions.h"
#import "SDWebImageManager.h"

@interface WSCalendaView () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    UIButton * wsc_preButton;
    UIButton * wsc_nextButton;
    UIView *   wsc_topHeadView;
    NSIndexPath * wsc_curIndexPath;
    BOOL wsc_allowsMultipleSelection;
    NSInteger wsc_cellWidth;
    NSInteger wsc_cellHeight;
    NSInteger wsc_lastDays;
    NSDictionary * wsc_contentDic;
    BOOL wsc_allowsPartDate; //是否允许选择全部日期，日期由接口设定
    NSMutableDictionary * wsc_canSelDateDic; //日历可选日期段字典
    CGSize wsc_realSize; //日历实际高度
    BOOL newPlan; //是否是 史克日历计划

    
}

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *dayModelArray;
@property (strong, nonatomic)  UILabel *dateLabel;
//@property (strong, nonatomic) NSDate *tempDate;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSCalendar *greCalendar;
@end

@implementation WSCalendaView

#pragma mark View lifecycle

-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel{
   return  [self initWithFrame:frame MultipleSel:isAllowsMultipSel NewPlan:NO];
   
}

-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel NewPlan:(BOOL)isNewPlan{
    
    if(self=[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)]){
        wsc_allowsMultipleSelection=isAllowsMultipSel;
        wsc_allowsPartDate=YES;
        newPlan = isNewPlan;
        [self initeData:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)];
        [self creatContrl:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)];
        [self creatCollectView];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame MultipleSel:(BOOL)isAllowsMultipSel allDateSel:(BOOL)isAllowsAllSel dateDic:(NSDictionary*)dateDic{
    
    if(self=[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)]){
        wsc_allowsMultipleSelection=isAllowsMultipSel;
        wsc_allowsPartDate=isAllowsAllSel;
        if(dateDic){
          wsc_canSelDateDic=[[NSMutableDictionary alloc]initWithDictionary:dateDic];
        }else{
            wsc_canSelDateDic=[[NSMutableDictionary alloc]init];
        }
        [self initeData:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)];
        [self creatContrl:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width/7.f*4.5f/5.f*6+HeaderViewHeight+TopButtonHeight)];
        [self creatCollectView];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame{
    return  [self initWithFrame:frame MultipleSel:NO];
}
-(void)creatContrl:(CGRect)rect{
    if(wsc_topHeadView==nil){
        wsc_topHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, TopButtonHeight)];
        wsc_topHeadView.backgroundColor=[UIColor colorWithRed:247.f/255.f green:246.f/255.f blue:247.f/255.f alpha:1];
        [self addSubview:wsc_topHeadView];
    }
    if(wsc_preButton==nil){
        UIImage * image=[UIImage imageNamed:@"arrow_back.png"];
        wsc_preButton=[UIButton buttonWithType:UIButtonTypeCustom];
        wsc_preButton.frame=CGRectMake(10, (TopButtonHeight-image.size.height)/2, 40, image.size.height);
        wsc_preButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        wsc_preButton.backgroundColor=[UIColor clearColor];
        [wsc_preButton setImage:image forState:UIControlStateNormal];
        [wsc_preButton addTarget:self action:@selector(PrebuttonDown) forControlEvents:UIControlEventTouchUpInside];
        [wsc_topHeadView addSubview:wsc_preButton];
    }
    
    if(wsc_nextButton==nil){
        UIImage * image=[UIImage imageNamed:@"arrow_next.png"];
        wsc_nextButton=[UIButton buttonWithType:UIButtonTypeCustom];
        wsc_nextButton.frame=CGRectMake(self.bounds.size.width-10-40, (TopButtonHeight-image.size.height)/2, 40, image.size.height);
        wsc_nextButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        wsc_nextButton.backgroundColor=[UIColor clearColor];
        [wsc_nextButton setImage:image forState:UIControlStateNormal];
        [wsc_nextButton addTarget:self action:@selector(nextbuttonDown) forControlEvents:UIControlEventTouchUpInside];
        [wsc_topHeadView addSubview:wsc_nextButton];
    }
    
    if (self.dateLabel==nil) {
        self.dateLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, (TopButtonHeight-UI_Font_Cal)/2, 200, UI_Font_Cal)];
        self.dateLabel.center=CGPointMake(self.bounds.size.width/2,  self.dateLabel.center.y);
        self.dateLabel.backgroundColor=[UIColor clearColor];
        self.dateLabel.font=[UIFont systemFontOfSize:UI_Font_Cal];
        self.dateLabel.textColor=[UIColor colorWithHexString:@"#242424"];
        self.dateLabel.textAlignment=NSTextAlignmentCenter;
        self.dateLabel.text=@"2016-10";
        [wsc_topHeadView addSubview:self.dateLabel];
    }

}

-(void)creatCollectView{
    [self addSubview:self.collectionView];
    self.tempDate = [NSDate date];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
    wsc_lastDays=self.dayModelArray.count;
    
    if (self.dayModelArray.count>35) {
        wsc_realSize=CGSizeMake(self.bounds.size.width, wsc_cellHeight*6.f);
    }else{
        wsc_realSize=CGSizeMake(self.bounds.size.width, wsc_cellHeight*5.f);
    }

}
- (CGFloat)getHight
{
    return wsc_realSize.height + HeaderViewHeight+TopButtonHeight;
}
-(void)initeData:(CGRect)rect{
    _allSelectDate=[[NSMutableArray alloc]init];
    wsc_contentDic=nil;
    self.clipsToBounds=YES;
    wsc_cellWidth=rect.size.width/7.f;
    wsc_cellHeight=wsc_cellWidth*4.5f/5.f;
   //SFA-15157
    if (INTERFACE_IS_PAD)
    {
         wsc_cellHeight=wsc_cellWidth*60/108;
    }
}

-(void)PrebuttonDown{
    self.tempDate = [self getLastMonth:self.tempDate];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
    [self resetSelectSize];
    if(newPlan)
    {
        [_allSelectDate removeAllObjects];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(wsCalendaView:changeToMonth:)]){
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.tempDate];
        [self.delegate wsCalendaView:self changeToMonth:comps.month];
    }
}



-(void)nextbuttonDown{
    self.tempDate = [self getNextMonth:self.tempDate];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
    [self resetSelectSize];
    if(newPlan)
    {
        [_allSelectDate removeAllObjects];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(wsCalendaView:changeToMonth:)]){
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.tempDate];
        [self.delegate wsCalendaView:self changeToMonth:comps.month];
    }}


- (void)jumpToMonthContainDate:(NSString *)string {

    NSDateFormatter *dateFormater = [NSDateFormatter standardDateFormatter];
    [dateFormater setDateFormat:@"yy-MM-dd"];
    self.tempDate = [dateFormater dateFromString:string];
    self.dateLabel.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
    [self resetSelectSize];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.tempDate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(wsCalendaView:changeToMonth:)]){
        [self.delegate wsCalendaView:self changeToMonth:comps.month];
    }
    
}
- (void)getDataDayModel:(NSDate *)date{
    NSUInteger days = [self numberOfDaysInMonth:date];
    NSInteger week = [self startDayOfWeek:date];
    NSInteger nextweek = 7-[self lastDayOfWeek:date];
    self.dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    for (int i= 1; i<days+week+nextweek; i++) {
        if (i<week) {
            NSInteger lastday=week-i;
            NSDateComponents *comps=[self getLastDayFormBack:lastday];
            if (comps) {
                MonthModel *mon = [MonthModel new];
                mon.dayValue=comps.day;
                mon.monValue=comps.month;
                mon.yearValue=comps.year;
                mon.isCurMonth=NO;
                mon.yymmdd=[NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)comps.year,(long)comps.month,(long)comps.day];
                [self.dayModelArray addObject:mon];
            }else{
               [self.dayModelArray addObject:@""];
            }
        }else if(i<days+week){
            MonthModel *mon = [MonthModel new];
            mon.dayValue = day;
            mon.isCurMonth=YES;
            NSDate *dayDate = [self dateOfDay:day];
            NSDateComponents *comps=[self componentsOfDay:day];
            mon.dateValue = dayDate;
            mon.monValue=comps.month;
            mon.yearValue=comps.year;
//            mon.num10ImageUrl=@"12";
//            mon.num11ImageUrl=@"12";
//            mon.num12ImageUrl=@"12";
            mon.yymmdd=[NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)comps.year,(long)comps.month,(long)comps.day];
            
            if(wsc_allowsPartDate==NO){
                //不允许选择全部日期
                BOOL isVisible=[self isItemVisible:mon.yymmdd];
                if(isVisible){
                    mon.isCurMonth=YES;
                }else{
                    mon.isCurMonth=NO;
                }
            }
            NSString *dayDateString = [self.dateFormatter stringFromDate:dayDate];
            NSString *nowDateString = [self.dateFormatter stringFromDate:[NSDate date]];
            if ([dayDateString isEqualToString:nowDateString]) {
                mon.isSelectedDay = YES;
                _todayDateStr=[NSString stringWithString:mon.yymmdd];
            }
            [self.dayModelArray addObject:mon];
            day++;
        }else{
            NSInteger lastday=i-days-week+1;
            NSDateComponents *comps=[self getNextDayFormBack:lastday];
            if (comps) {
                MonthModel *mon = [MonthModel new];
                mon.dayValue=comps.day;
                mon.monValue=comps.month;
                mon.yearValue=comps.year;
                mon.yymmdd=[NSString stringWithFormat:@"%02ld-%02ld-%02ld",(long)comps.year,(long)comps.month,(long)comps.day];
                mon.isCurMonth=NO;
                [self.dayModelArray addObject:mon];
            }else{
                [self.dayModelArray addObject:@""];
            }

        }
    }
    NSArray * array= [self.collectionView visibleCells];
    for (CalendarCell * cell in array) {
        if (cell) {
            cell.visible=NO;
        }
    }
    if(wsc_contentDic){
        for (MonthModel * obj in self.dayModelArray) {
            NSDictionary * ItemDic= [wsc_contentDic objectForKey:obj.yymmdd];
            if (ItemDic) {
                NSString * num10url=[ItemDic objectForKey:LOAD_IMAGE_Number10URL];
                obj.num10ImageUrl=num10url;
                NSString * num12url=[ItemDic objectForKey:LOAD_IMAGE_Number12URL];
                obj.num12ImageUrl=num12url;
                NSString * num13url=[ItemDic objectForKey:LOAD_IMAGE_Number13URL];
                obj.num13ImageUrl=num13url;
            }
        }
    }
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dayModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    cell.newPlan = newPlan;

    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        cell.monthModel = (MonthModel *)mon;
    }else{
        cell.dayLabel.text = @"";
    }
    cell.visible=NO;
    cell.isPlan=NO;
    MonthModel * cor_mon=nil;
    if ([mon isKindOfClass:[MonthModel class]]) {
        cor_mon = mon;
    }
    if (newPlan) {
        if(!cor_mon.isCurMonth){
            cell.userInteractionEnabled = NO;
        }else{
            cell.userInteractionEnabled = YES;
        }
        if(self.planCalendarDataModel){
            for (WSPlanCalendarDataInfoModel *dataInfoModel in self.planCalendarDataModel.tableData) {
                if ([cor_mon.yymmdd isEqualToString:dataInfoModel.day]) {
                    if (dataInfoModel.visitList.count > 0 || dataInfoModel.forenoon || dataInfoModel.afternoon || dataInfoModel.allday) {
                        cell.isPlan=YES;
                    }
                    break;
                }
            }
        }else{
            for (WSPlanCalendarManageDataInfoModel *dataInfoModel in self.planCalendarMenageDataModel.tableData) {
                if ([cor_mon.yymmdd isEqualToString:dataInfoModel.day]) {
                    if (dataInfoModel.salesList.count > 0 || dataInfoModel.leaderList.count > 0 || dataInfoModel.forenoon || dataInfoModel.afternoon || dataInfoModel.allday) {
                        cell.isPlan=YES;
                    }
                    break;
                }
            }
        }
    }
    for (NSString * s_date in _allSelectDate) {
        if ([mon isKindOfClass:[MonthModel class]]) {
            MonthModel * cor_mon=mon;
            if ([cor_mon.yymmdd isEqualToString:s_date]) {
                cell.visible=YES;
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

            }
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    CalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CalendarHeaderView" forIndexPath:indexPath];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        //self.dateLabel.text = [(MonthModel *)mon dateValue].yyyyMMddByLineWithDate;
    }
    if(wsc_allowsPartDate==NO){
        //不允许选择全部日期
        BOOL isVisible=[self isItemVisibleForIndexPath:indexPath];
        if(isVisible){
            
        }else{
            [self performSelector:@selector(deselectItemAtIndex:) withObject:indexPath afterDelay:0.1];
            return;
        }
    }

    CalendarCell * cell=(CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        cell.visible=YES;

    }
    [self resetSelectArray];
}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    CalendarCell * cell=(CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //NSIndexPath * test=indexPath;
    if (cell) {
        cell.visible=NO;
    }
    if(!newPlan){
        [self resetSelectArray];
    }
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        NSInteger width = wsc_cellWidth;
        NSInteger height =wsc_cellHeight;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(width, height);
        flowLayout.headerReferenceSize = CGSizeMake(self.bounds.size.width, HeaderViewHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, wsc_topHeadView.frame.origin.y+wsc_topHeadView.bounds.size.height, width * 7, wsc_topHeadView.bounds.size.height+wsc_cellHeight*6.f) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = wsc_allowsMultipleSelection;
        
        [_collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
        [_collectionView registerClass:[CalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CalendarHeaderView"];
        
        //此处给其增加拖动手势，用此手势触发cell移动效果
        if (wsc_allowsMultipleSelection) {
            UIPanGestureRecognizer *longGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
            [_collectionView addGestureRecognizer:longGesture];
        }
        
    }
    return _collectionView;
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    CGPoint  pos= [longGesture locationInView:self.collectionView];
    CGRect touchRect=CGRectMake(0, wsc_topHeadView.bounds.size.height, self.collectionView.bounds.size.width, wsc_realSize.height-15);
    if(!CGRectContainsPoint(touchRect, pos)){
        return;
    }
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longGesture locationInView:self.collectionView]];
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            if (indexPath == nil) {
                break;
            }
            //在路径上则开始移动该路径上的cell
        }
            break;
        case UIGestureRecognizerStateChanged:{
            //移动过程当中随时更新cell位置
            if (wsc_curIndexPath==NULL || wsc_curIndexPath.row!=indexPath.row) {
                wsc_curIndexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            }else{
                return;
            }
            
            if(wsc_allowsPartDate==NO){
                //不允许选择全部日期
                BOOL isVisible=[self isItemVisibleForIndexPath:wsc_curIndexPath];
                if(isVisible){
                    
                }else{
                    return;
                }
            }

            if(self.collectionView){
                [self.collectionView selectItemAtIndexPath:wsc_curIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                CalendarCell * cell=(CalendarCell *)[self.collectionView cellForItemAtIndexPath:wsc_curIndexPath];
                if (cell) {
                    cell.visible=YES;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            if(wsc_allowsPartDate==NO){
                //不允许选择全部日期
                BOOL isVisible=[self isItemVisibleForIndexPath:wsc_curIndexPath];
                if(isVisible){
                    
                }else{
                    return;
                }
            }

            [self resetSelectArray];
            break;
        default:
            
            break;
    }
}

#pragma mark 数据计算相关函数
-(void)resetSelectArray{
    
    NSArray * array= self.collectionView.indexPathsForSelectedItems;
    [_allSelectDate removeAllObjects];
    for(NSIndexPath* item in array){
        if(item.row<self.dayModelArray.count){
            MonthModel * mon=[self.dayModelArray objectAtIndex:item.row];
            [_allSelectDate addObject:[NSString stringWithString:mon.yymmdd]];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(wsCalendaView:selDateAarray:)]){
        [self.delegate wsCalendaView:self selDateAarray: _allSelectDate];
    }
    
}

-(void)resetSelectSize{
    if (wsc_lastDays!=self.dayModelArray.count) {
        
        CGSize size;
        if (self.dayModelArray.count>35) {
             size= CGSizeMake(self.bounds.size.width, wsc_cellHeight*6.f+HeaderViewHeight+TopButtonHeight);
             wsc_realSize=CGSizeMake(self.bounds.size.width, wsc_cellHeight*6.f);
        }else{
            size= CGSizeMake(self.bounds.size.width, wsc_cellHeight*5.f+HeaderViewHeight+TopButtonHeight);
            wsc_realSize=CGSizeMake(self.bounds.size.width, wsc_cellHeight*5.f);
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(wsCalendaView:changToSize:)]){
            [self.delegate wsCalendaView:self changToSize:size];
        }
    }
    wsc_lastDays=self.dayModelArray.count;
}

-(void)resetReloadSelItem{
    for (NSString * selDate in _allSelectDate) {
        for (int i=0;i<self.dayModelArray.count;i++) {
            MonthModel * obj =[ self.dayModelArray objectAtIndex:i];
            if([obj.yymmdd isEqualToString:selDate]){
                NSIndexPath * indexpath=[NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionView selectItemAtIndexPath:indexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }
}

-(BOOL) isItemVisible:(NSString*)seldate_str{
    
    if(wsc_allowsPartDate==YES)
        return YES;
    NSString * startdate_str=[wsc_canSelDateDic objectForKey:CALEND_DATESEL_START];
    if(startdate_str==nil || startdate_str.length<=0)
        return YES;
    NSString * enddate_str=[wsc_canSelDateDic objectForKey:CALEND_DATESEL_END];
    if(enddate_str==nil || enddate_str.length<=0)
        return YES;
    
    NSDate* startDate = [self.dateFormatter dateFromString:startdate_str];
    NSDate* endDate = [self.dateFormatter dateFromString:enddate_str];
    NSDate* selDate = [self.dateFormatter dateFromString:seldate_str];
    
    if([startDate compare:selDate]!=NSOrderedDescending && [selDate compare:endDate]!=NSOrderedDescending){
        return  YES;
    }else{
        return  NO;
    }
}

-(BOOL) isItemVisibleForIndexPath:(NSIndexPath *)indexpath{
    
    if(indexpath.row>self.dayModelArray.count-1)
        return YES;
    MonthModel * mode=[self.dayModelArray objectAtIndex:indexpath.row];
    NSString * selDate_str=mode.yymmdd;
    return  [self isItemVisible:selDate_str];
}

#pragma mark
#pragma mark 功能函数

-(void)deselectItemAtIndex:(NSIndexPath*)indexpath{
    [_collectionView deselectItemAtIndexPath:indexpath animated:NO];
}

#pragma mark -计算日期函数
- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    return [self.greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
}

- (NSDate *)firstDateOfMonth:(NSDate *)date{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = 1;
    return [self.greCalendar dateFromComponents:comps];
}

- (NSDate *)lastDateOfMonth:(NSDate *)date{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = [self numberOfDaysInMonth:self.tempDate];
    return [self.greCalendar dateFromComponents:comps];
}


- (NSUInteger)startDayOfWeek:(NSDate *)date
{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self firstDateOfMonth:date]];
    return comps.weekday;
}
- (NSUInteger)lastDayOfWeek:(NSDate *)date
{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self lastDateOfMonth:date]];
    return comps.weekday;
}

- (NSDate *)getLastMonth:(NSDate *)date{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    NSInteger tempDay = comps.day;

    comps.month -= 1;
    comps.day = 1;
    if (tempDay > [self numberOfDaysInMonth:[self.greCalendar dateFromComponents:comps]]) {
        comps.day = [self numberOfDaysInMonth:[self.greCalendar dateFromComponents:comps]];
    }
    
    return [self.greCalendar dateFromComponents:comps];
}

- (NSDate *)getNextMonth:(NSDate *)date{
    
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    NSInteger tempDay = comps.day;
    
    comps.month += 1;
    comps.day = 1;
    if (tempDay > [self numberOfDaysInMonth:[self.greCalendar dateFromComponents:comps]]) {
        comps.day = [self numberOfDaysInMonth:[self.greCalendar dateFromComponents:comps]];
    }
    
    return [self.greCalendar dateFromComponents:comps];
}

- (NSDate *)dateOfDay:(NSInteger)day{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self.tempDate];
    comps.day = day;
    return [self.greCalendar dateFromComponents:comps];
}
- (NSDateComponents *)componentsOfDay:(NSInteger)day{
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self.tempDate];
    comps.day = day;
    return comps;
}

//取得上个月倒数第N天数据
-(NSDateComponents*)getLastDayFormBack:(NSInteger)day{
    
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60*day sinceDate:[self firstDateOfMonth:self.tempDate]];//前一天
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:lastDay];
    return comps;
}
//取得下个月第N天数据
-(NSDateComponents*)getNextDayFormBack:(NSInteger)day{
    
    NSDate *lastDay = [NSDate dateWithTimeInterval:24*60*60*day sinceDate:[self lastDateOfMonth:self.tempDate]];//前一天
    NSDateComponents *comps = [self.greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:lastDay];
    return comps;

}


#pragma mark 外部接口函数
-(void)resetDateImageContent:(NSDictionary *)contentDic{
    if(contentDic==nil)
        return;
    wsc_contentDic=[[NSDictionary alloc]initWithDictionary:contentDic];
    for (MonthModel * obj in self.dayModelArray) {
        NSDictionary * ItemDic= [contentDic objectForKey:obj.yymmdd];
        if (ItemDic) {
            NSString * num10url=[ItemDic objectForKey:LOAD_IMAGE_Number10URL];
            obj.num10ImageUrl=num10url;
            NSString * num12url=[ItemDic objectForKey:LOAD_IMAGE_Number12URL];
            obj.num12ImageUrl=num12url;
            NSString * num13url=[ItemDic objectForKey:LOAD_IMAGE_Number13URL];
            obj.num13ImageUrl=num13url;
            
        }
    }
    [self.collectionView reloadData];
    [self resetReloadSelItem];
}
-(CGSize)getControlViewSize{
    if (self.dayModelArray.count>35) {
        return CGSizeMake(self.bounds.size.width, wsc_cellHeight*6.f+HeaderViewHeight+TopButtonHeight);
    }else{
        return CGSizeMake(self.bounds.size.width, wsc_cellHeight*5.f+HeaderViewHeight+TopButtonHeight);
    }
    
}
-(void)resetSelectDate:(NSString *)selDate{
    if(selDate==nil || selDate.length<=0)
        return;
    // SFA-20225 不显示的不需要处理
    if (![self isItemVisible:selDate]) {
        return;
    }
    
    [_allSelectDate removeAllObjects];
    
    [_allSelectDate addObject:[NSString stringWithString:selDate]];
    
    for (int i=0;i<self.dayModelArray.count;i++) {
        MonthModel * obj =[ self.dayModelArray objectAtIndex:i];
        if([obj.yymmdd isEqualToString:selDate]){
            NSIndexPath * indexpath=[NSIndexPath indexPathForRow:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexpath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self.collectionView reloadData];

        }
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSDateFormatter *inputFormatter = [NSDateFormatter standardDateFormatter];
        [inputFormatter setDateFormat:@"yyyy-MM-dd"];
        _dateFormatter = inputFormatter;
    }
    return _dateFormatter;
}
- (NSCalendar *)greCalendar {
    if (!_greCalendar) {
        NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        _greCalendar = greCalendar;
    }
    return _greCalendar;
}
- (void)setPlanCalendarDataModel:(WSPlanCalendarDataModel *)planCalendarDataModel
{
    _planCalendarDataModel = planCalendarDataModel;
    [self.collectionView reloadData];
}
- (void)setPlanCalendarMenageDataModel:(WSPlanCalendarManageDataModel *)planCalendarMenageDataModel
{
    _planCalendarMenageDataModel = planCalendarMenageDataModel;
    [self.collectionView reloadData];
}
@end
