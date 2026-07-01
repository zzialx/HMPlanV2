//
//  WSStartEndDatePanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStartEndDatePanel.h"
#import "WCStartEndDateView.h"
#import "I_W_BuildInfo.h"
#import "WSDatePicker.h"
#import "WidgetConstant.h"
#import "DateUtil.h"
#import "I_W_DisplayValue.h"

#import "WSStringValueChangeChecker.h"

#import "WSMainLeftView.h"

@interface WSStartEndDatePanel () <WCStartEndDateViewDelegate>
@property (nonatomic,strong) DateUtil *dateUtil;

@end

@implementation WSStartEndDatePanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.xvalueChangeChecker = [[WSStringValueChangeChecker alloc] init];
        self.dateUtil = [[DateUtil alloc]init];

        return self;
    }
    return nil;
    
}

-(void)buildDisplayContent{
    
    if (self.isShowTitleLabel) {
        [super buildDisplayContent];
    }
    BOOL isShowUIview = YES;
    
    NSString *displayValue = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    
    _originalValue = displayValue;
    
    CGRect startEndDateViewFrame = CGRectMake(0, 0,self.width, MAIN_CELL_HEIGHT * 2) ;
    
    if ([self isSinglePicker]) {
        startEndDateViewFrame = CGRectMake(0, 0, self.width, MAIN_CELL_HEIGHT);
    }

    // SFA-18280 屏蔽该逻辑调整到获取回显值的地方做控制
//    BOOL isShowCurrentDate = YES;
//    if ([[xbuildInfo getDefaultValue] isEqualToString:@"0"]) {
//        isShowCurrentDate = NO;
//    }

    
    if ([[xbuildInfo getAcvtQstType] isEqualToString:@"SE"]) {
        
        wcSedView = [[WCStartEndDateView alloc] initWithFrame:startEndDateViewFrame withDateMode:UIDatePickerModeDate withIsSinglePicker:[self isSinglePicker] dateString:displayValue dateFormatString:DATE_FORMAT_CH_WITH_SEP_NOTIME];
        
    }else if ([[xbuildInfo getAcvtQstType] isEqualToString:@"TT"]){
        
        NSString *formatString = DATE_FORMAT_CH_WITH_SEP_NOSEC;
        if ([[xbuildInfo getMlen] isEqualToString:@"1"]) {
            formatString = DATE_FORMAT_CH_WITH_SEP_SEC;
        }
        
        wcSedView = [[WCStartEndDateView alloc] initWithFrame:startEndDateViewFrame withDateMode:UIDatePickerModeDateAndTime withIsSinglePicker:[self isSinglePicker] dateString:displayValue dateFormatString:formatString];

    }
   
    if ([self isSinglePicker]) {
        [wcSedView setStartEndTitleByString:[xbuildInfo getQuestName]];
    }else{
        [wcSedView setStartEndTitleByString:NSLocalizedString(@"begin_end_date", nil)];
    }
    
    if ([_originalValue isKindOfClass:[NSString class]]) {
        
        NSArray *startEndTime = [displayValue componentsSeparatedByString:@","];
        [wcSedView setStartDateWithString:[startEndTime objectAtIndex:0]];
        
        if ([self isSinglePicker] == NO) {
            
            if (startEndTime.count == 1) {
                [wcSedView setEndDateWithString:[startEndTime objectAtIndex:0]];
            } else if (startEndTime.count == 2) {
                [wcSedView setEndDateWithString:[startEndTime objectAtIndex:1]];
            }

        }
        
    }
    
    wcSedView.delegate = self;
    
    wcSedView.tag = [[xbuildInfo getAcvtQstId] intValue];
    
    int temp_snum = [[xbuildInfo getSnumx] intValue];
    
    int temp_mnum = [[xbuildInfo getMumx] intValue];
    
    CGFloat wc_SedView_y = self.isShowTitleLabel ? (titleLabel.frame.origin.y+titleLabel.frame.size.height+2.0) : 0;
    
    if (temp_snum > temp_mnum){
        
        isShowUIview = NO;
        
        UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 70)];
        
        lable.backgroundColor = kCLEAR_COLOR_value;
        
        lable.text = NSLocalizedString(@"timezone_config_error", nil);
        
        lable.textAlignment = NSTextAlignmentCenter;
        
        lable.numberOfLines = 0;
        
        lable.font =[UIFont systemFontOfSize:12];
        
        lable.textColor = [UIColor redColor];
        
        [self addSubview:lable];
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, lable.frame.size.height+20.0)];
        
    }else if (!(temp_snum == 0 && temp_mnum == 0 )) {
        
        //        SFA-20009
        //        SFA 汉高移动【ios】：技师登录常规课程里面的开始时间只能选择当天当前时间段，请修改为当天但是不限制时间段。
        //        SFA-25787 董宏
        [wcSedView setSectionStartDate:[[NSDate date] dateByAddingTimeInterval:temp_snum * 24 * 60 * 60]];

        [wcSedView setSectionEndDate:[[NSDate date] dateByAddingTimeInterval:temp_mnum * 24 * 60 * 60]];
        
        [wcSedView setFrame:CGRectMake(wcSedView.frame.origin.x, wc_SedView_y, self.frame.size.width, wcSedView.frame.size.height)];
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, wcSedView.frame.size.height)];
        
    } else if (temp_mnum == 0 && temp_snum == 0){
        
        [wcSedView setFrame:CGRectMake(wcSedView.frame.origin.x,wc_SedView_y, self.frame.size.width, wcSedView.frame.size.height)];
        
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, wcSedView.frame.size.height)];
    }
    
//    WSAcvtQstBottomLineView *bottomLine = [[WSAcvtQstBottomLineView alloc] initWithFrame:CGRectMake(wcSedView.frame.origin.x, self.frame.size.height -1, wcSedView.frame.size.width + 20, 1)];
//    [self addSubview:bottomLine];
    [self addSubview:wcSedView];

   
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
         [wcSedView setReadRonly:YES];
    }else{
         [wcSedView setReadRonly:NO];
    }
    
    _resultCheck = [self getResultPresentation];

}

- (BOOL)isSinglePicker
{
    BOOL isSinglePicker = NO;
    if ([[xbuildInfo getMlen] isEqualToString:@"1"]) {
        isSinglePicker = YES;
    }
    
    return isSinglePicker;
}

- (NSString *)getFormatString
{
    NSString *formatString ;
    if ([[xbuildInfo getAcvtQstType] isEqualToString:@"SE"]) {
        formatString = DATE_FORMAT_CH ;
        
    }else if ([[xbuildInfo getAcvtQstType] isEqualToString:@"TT"]){
        
        formatString = DATE_FORMAT_CH_WITH_SEP_SEC ;
    }
    
    return formatString;
}

-(NSObject *)getResultDirectly{
    return [self getResultStringWithSeparator:@","];
}
- (NSObject *)getResultPresentation {
    return [self getResultStringWithSeparator:LUA_SEPARATOR];
}

-(NSString *)getResultStringWithSeparator:(NSString *)separator{
    DateUtil  *du =[[DateUtil alloc] init];
    
    NSString *formatString = [self getFormatString];
    
    NSString *begindatestr =  [du obtainDate:wcSedView.startDate formateString:formatString];
    
    if (![[xbuildInfo getMlen] isEqualToString:@"0"]) {
        
        return begindatestr;
    }else if (begindatestr) {
        NSString *enddatestr = [du obtainDate:wcSedView.endDate formateString:formatString];
        
        return [NSString stringWithFormat:@"%@%@%@",begindatestr,separator,enddatestr];
    }
    return nil;
}
- (void)reloadCurrentWidgetWithValue:(NSObject *)value{
    
    if ([value isKindOfClass:[NSString class]]) {
        
        NSArray *startEndTime = [(NSString *)value componentsSeparatedByString:@","];
        
        if ([self isSinglePicker]) {
            NSString *valueString = (NSString *)value;
            
            if ([valueString length] > 0) {
                
                DateUtil  *dateutil = [[DateUtil alloc] init];
                NSDate *valueDate = [dateutil dateString:[startEndTime firstObject] formateString:[self getFormatString] localstr:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
                if (valueDate) {
                    [wcSedView setStartDateWithString:[startEndTime objectAtIndex:0]];
                }else {
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:valueString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    
                    [wcSedView setStartDateWithString:wcSedView.lastStartDateString];
                }
            }
        }else {
            [wcSedView setStartDateWithString:[startEndTime objectAtIndex:0]];
            
            [wcSedView setEndDateWithString:[startEndTime objectAtIndex:1]];
        }

    }
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    if ([valuePresentation isKindOfClass:[NSString class]]) {
        
        NSArray *startEndTime = [(NSString *)valuePresentation componentsSeparatedByString:@","];
        
        NSString *startTime = [startEndTime objectAtIndex:0];
        [wcSedView setStartDateWithString:startTime];
        
        if (![self isSinglePicker]) {
            if ([startEndTime count] > 1) {
                [wcSedView setEndDateWithString:[startEndTime objectAtIndex:1]];
            } else if ([startTime isEqualToString:@""]){
                [wcSedView setEndDateWithString:startTime];
            }
        }
    }
    
}

- (void)setReadonly:(NSString *)isReadonly {
    
    [super setReadonly:isReadonly];
    
    if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
        [wcSedView setReadRonly:YES];
    }else{
        [wcSedView setReadRonly:NO];
    }
    
}

#pragma mark -
#pragma mark WCStartEndDateViewDelegate method

- (void)showDatePickerView:(WCStartEndDateView *)aWCStartEndDateView andSelectedBtn:(UIButton *)selectedbtn{
    
    wcSedView = aWCStartEndDateView;
    
    selectedBtn = selectedbtn;
    
    int leftSpacing = 0;
    if (INTERFACE_IS_PAD) {
        leftSpacing = k_MainkLeftVieWidth;
    }
    
    UIDatePickerMode mode = aWCStartEndDateView.pickerMode;
    NSDate *nowDate;
    NSDate *maxDate;
    NSDate *minDate;
    if (selectedBtn.tag == 100) {
        nowDate = wcSedView.startDate;
        maxDate = wcSedView.sectionEndDate;
        minDate = wcSedView.sectionStartDate;
    }else if (selectedBtn.tag == 200) {
        nowDate = wcSedView.endDate;
        maxDate = wcSedView.sectionEndDate;
        minDate = wcSedView.startDate;
    }
    
    
    if (!nowDate) {
        nowDate =[NSDate date];
    }
    
    
    WSPickerViewType pickerType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:mode];
    
    BOOL isAddDeleteButton = [[xbuildInfo getISRequire] isEqualToString:@"1"] ? NO : YES;
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerType isAddDeleteButton:isAddDeleteButton];
    [pickerView setDate:nowDate animated:YES];
    [pickerView setMaximumDate:maxDate];
    [pickerView setMinimumDate:minDate];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [wcSedView setSelectedDate:date forBtn:selectedBtn];
        
        [weakSelf checkValueChange];
    }];
}


- (void)WCStartEndDateViewValueChanged:(WCStartEndDateView *)aWCStartEndDateView{
    
    _resultCheck = [self getResultPresentation];
    if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
        [self.delegate executeLuaScript:xbuildInfo widget:self];
        
    }
}

@end
