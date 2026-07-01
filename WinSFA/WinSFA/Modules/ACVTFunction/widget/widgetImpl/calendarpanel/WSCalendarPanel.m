//
//  WSLabelPanel.m
//  WinSFA
//
//  Created by yang on 15/11/12.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSCalendarPanel.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"
#import "UICopyLabel.h"
#import "UILabel+Additional.h"
#import "WSCalendaView.h"

#import "I_W_DataSource.h"
#import "WSCALDataSource.h"
#import "WSDimensMacros.h"
#import "WSCalendarLogicService.h"
#import "WSDataSourceManager.h"

@interface WSCalendarPanel () <WSCalendaViewDelegate>
{
    NSInteger _currentDisplayMonth;
    BOOL _isReloadIconsWhenUpdateWidgetValue;
}

@property (nonatomic, strong) WSCalendaView *infoCalendarView;

@end

@implementation WSCalendarPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        _isReloadIconsWhenUpdateWidgetValue = NO;
        return self;
    }
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
}


- (void)loadDataSource:(NSObject<I_W_DataSource> *)datasource {
    [super loadDataSource: datasource];
}


- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    NSString *text = [xbuildInfo getDefaultValue];
    if (!text) {
        text = [NSString stringWithFormat:@"%@",[xbuildInfo getQuestName]];
    }
    
    BOOL orientition = NO;
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"]) {
        orientition = YES;
    }
    
    [self resetTitle:@""];
    
    NSString *memo3 = [xbuildInfo getAcvtMemo3];
    NSDictionary *dateDictionary = nil;
    if (![memo3 isEqualToString:@"selectAllDay"]) {
        NSDateComponents *components = [WSCurrentTime YMDComponents];
        NSInteger day = components.day;
        NSString *mnum = [xbuildInfo getMumx];
        NSString *memo = [xbuildInfo getAcvtMemo];
        NSString *startDate = [WSCurrentTime dateFromNowMonth:0 day:day + [mnum integerValue]];
        NSString *endDate = nil;
        if ([mnum integerValue] + day < [memo integerValue]) {
            NSInteger days = [WSCurrentTime numberOfDaysInCurrentMonth];
            endDate = [WSCurrentTime dateFromNowMonth:0 day:days];
        }else {
            endDate = [WSCurrentTime  getNextMonthLastDay];
        }
        dateDictionary = @{CALEND_DATESEL_START : [NSString stringNotNilWithValue:startDate], CALEND_DATESEL_END : [NSString stringNotNilWithValue:endDate]};
    }

    _infoCalendarView = [[WSCalendaView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 400) MultipleSel:YES allDateSel:NO dateDic:dateDictionary];
    _infoCalendarView.delegate = self;
    
    CGSize size = [_infoCalendarView getControlViewSize];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height);
    
    [self addSubview:_infoCalendarView];

    NSString *redis = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    _originalValue = redis;
    if ([redis length] > 0) {
        
        /*设置日期选中日期*/
        [self.infoCalendarView resetSelectDate:redis];
        
        /*跳转到回显日期所在月*/
        [self.infoCalendarView jumpToMonthContainDate:redis];
        
        /*设置日历某些天的排班标记*/
        if ([xdataSource isKindOfClass:[WSCALDataSource class]]) {
            NSObject *iconInfos = [(WSCALDataSource *)xdataSource getCalendaDutyPlanIcon:@[redis] usingGenId:YES];
            [self.infoCalendarView resetDateImageContent:(NSMutableDictionary *)iconInfos];
        }
    }else {
        /*无回显值时 是新增要显示当前月上数六天下数六天之间的时候*/
        if ([xdataSource isKindOfClass:[WSCALDataSource class]]) {
            WSCALDataSource *calDataSource = (WSCALDataSource *)xdataSource;
            NSArray *dateStr = [calDataSource  getCalenderShowLimitDateStrs];
            NSObject *iconInfos = [(WSCALDataSource *)xdataSource getCalendaDutyPlanIcon:dateStr usingGenId:NO];
            [self.infoCalendarView resetDateImageContent:(NSMutableDictionary *)iconInfos];
        }
    }
    
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setUserInteractionEnabled:NO];
    }
    //[self refreshFrame];
}

- (void)refreshFrame
{
    CGFloat height = self.infoCalendarView.frame.origin.y + [self.infoCalendarView getControlViewSize].height;
    CGFloat paddingY = self.frame.origin.y;
    CGFloat titleHeight = self.titleLabel.height;
    if (height < titleHeight) {
        height = titleHeight;
    }
    
    if (!([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"])) {
        height += 10;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, paddingY, self.frame.size.width, height)];
    
}


- (NSObject *)getResultDirectly
{
    if (self.infoCalendarView) {
        return [self.infoCalendarView.allSelectDate componentsJoinedByString:@","];
    }
    return nil;
}

- (NSObject *)getResultPresentation
{
    if (_originalValue) {
        return _originalValue;
    }
    
    return nil;
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [self setUserInteractionEnabled:NO];
    }else {
        [self setUserInteractionEnabled:YES];
    }
}

- (void)reloadCurrentWidgetWithValue:(NSObject *)value {
    if(self.infoCalendarView){
        _isReloadIconsWhenUpdateWidgetValue = YES;
        [self.infoCalendarView resetDateImageContent:(NSDictionary *)value];
    }
}



#pragma mark
#pragma mark WSCalendarViewDelegate
-(void)wsCalendaView:(WSCalendaView *)calendarView selDateAarray:(NSArray *)dateArray {
    
}



-(void)wsCalendaView:(WSCalendaView *)calendarView changToSize:(CGSize)size {
    if (self.infoCalendarView.size.height != size.height) {
        CGRect rect = self.frame;
        rect.size.height = size.height;
        self.frame = rect;
        NSLog(@"NSStringFromCGSize(size)-----%@",NSStringFromCGSize(size));
    }
}


-(void)wsCalendaView:(WSCalendaView *)calendarView changeToMonth:(NSInteger)month
{
    _currentDisplayMonth = month;
    
    // MSTD-5870 排班表有改动则重新查询并设置icon的值
//    if (_isReloadIconsWhenUpdateWidgetValue) {
        [self resetCalenderViewsIcon];
//    }

}

/*
 获取当前日历显示月份的上月最后6天下月前6天之间的时间
 */
- (NSArray *)getDisplayCalenderShowLimitDateStrs {
    
    NSMutableArray *dateStrs = [NSMutableArray array];
    for (NSInteger i = - CALENDER_LIMIT_DAY; i < 0; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth] day:i+1]];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    
    for (NSInteger i = 0; i < numberOfDaysInMonth; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth] day:i+1]];
    }
    
    for (NSInteger i = 0; i < CALENDER_LIMIT_DAY ; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth+1] day:i+1]];
    }
    return dateStrs;
}

- (void)resetCalenderViewsIcon {
    
    NSArray *dateStrs = [self getDisplayCalenderShowLimitDateStrs];
    
    WSAcvtModel *acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;

    NSMutableDictionary *calendarIconsDic = [WSCalendarLogicService getCalendaDutyPlanIcon:dateStrs usingGenId:NO acvtModel:acvtModel];
    if ([calendarIconsDic allKeys].count > 0) {
        [self.infoCalendarView resetDateImageContent:calendarIconsDic];
    }
    
}

@end
