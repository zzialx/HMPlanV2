//
//  WSYMPickView.m
//  WinSFA
//
//  Created by heju on 16/2/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSYMPickView.h"

static const CGFloat YEAR_WIDTH = 100.0f;

static const CGFloat MONTH_WIDTH = 100.0f;

static const NSInteger YM_RANGE = 25;

#import "WSCurrentTime.h"

@interface WSYMPickView ()

@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, assign) NSInteger yearIndex;
@property (nonatomic, assign) NSInteger monthIndex;

@end

@implementation WSYMPickView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
         [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withNowDateStr:(NSString *)nowDateStr maxDate:(NSDate *)maxDateStr minDate:(NSDate *)minDateStr withPickerMode:(WSDatePickerSheetMode)PickerSheetMode{
    if (self = [super initWithFrame:frame]) {
        self.nowDateStr = nowDateStr;
        self.maxDate = maxDateStr;
        self.minDate = minDateStr;
        
        [self setupViews];
        
        self.pickeMode = PickerSheetMode;
        
        return self;
    }
    return nil;
    
}

- (void)setupViews {
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:self.bounds];
    // 显示选中框
    pickerView.showsSelectionIndicator=YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.pickerView = pickerView;
   
    NSDateComponents *dateComponents = [WSCurrentTime YMDComponents];
    _months = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    _years = [NSMutableArray array];
    for (NSInteger i = dateComponents.year -YM_RANGE;i < dateComponents.year + YM_RANGE; i++) {
        [_years addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
  
    _currentYear = [NSString stringWithFormat:@"%ld", (long)dateComponents.year];
    _currentMonth = [NSString stringWithFormat:@"%ld", (long)dateComponents.month];
    if (dateComponents.month < 10) {
        _currentMonth = [NSString stringWithFormat:@"0%ld", (long)dateComponents.month];
    }
    
    self.yearIndex = [_years indexOfObject:_currentYear];
    self.monthIndex = [_months indexOfObject:_currentMonth];
    [pickerView  selectRow:self.yearIndex inComponent:0 animated:YES];
    
    [self  addSubview:pickerView];
}

- (void)setPickeMode:(WSDatePickerSheetMode)pickeMode {
    _pickeMode = pickeMode;
    
    if (pickeMode == WSDatePickerSheetModeYM) {
        [self.pickerView selectRow:self.monthIndex inComponent:1 animated:YES];
        NSString *date = [NSString stringWithFormat:@"%@-%@",_currentYear,_currentMonth];
        _selecteDate = date;
        
    }else if (pickeMode == WSDatePickerSheetModeY){
        _selecteDate = _currentYear;
    }
    
    if (self.nowDateStr == nil) {
        self.nowDateStr = self.selecteDate;
    }
}

- (void)setNowDateStr:(NSString *)nowDateStr {
    if (!nowDateStr || !(nowDateStr.length > 0)) {
        return;
    }
    
    _nowDateStr = nowDateStr;
    
    NSArray *YMTimeArray =[nowDateStr componentsSeparatedByString:@"-"];
    _currentYear = [YMTimeArray objectAtIndex:0];
    if (YMTimeArray.count >1) {
        _currentMonth = [YMTimeArray objectAtIndex:1];
    }

    self.yearIndex = [_years indexOfObject:_currentYear];
    self.monthIndex = [_months indexOfObject:_currentMonth];
    
    [self resetSelectPiker:self.pickerView];
}

- (void)resetSelectPiker:(UIPickerView *)pickView {
    
    NSString *date = [NSString stringWithFormat:@"%@-%@",_currentYear,_currentMonth];
    if (_pickeMode == WSDatePickerSheetModeY) {
        date = _currentYear;
    } else {
        [pickView  selectRow:self.monthIndex inComponent:1 animated:YES];
    }
    [pickView  selectRow:self.yearIndex inComponent:0 animated:YES];
    
    _selecteDate = date;
}

- (void)resetPickView:(UIPickerView *)pickView tips:(NSString *)tips {
    _currentYear = _years[self.yearIndex];
    _currentMonth = _months[self.monthIndex];
    
    [self resetSelectPiker:pickView];

    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"提示!", nil) tips:tips tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.0f];
}

// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_pickeMode == WSDatePickerSheetModeY) {
       return 1;
    }
    return 2;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_years count];
    }
    return [_months count];
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if (component == 0) {
        return YEAR_WIDTH;
    }
    return MONTH_WIDTH;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        _currentYear = [_years objectAtIndex:row];
    } else {
        _currentMonth = [_months objectAtIndex:row];
    }
    NSString *date = [NSString stringWithFormat:@"%@-%@",_currentYear,_currentMonth];
    if (_pickeMode == WSDatePickerSheetModeY) {
        date = _currentYear;
    }
    _selecteDate = date;
    NSDateFormatter *dateFromate = [NSDateFormatter standardDateFormatter];
    [dateFromate setDateFormat:@"yyyy-MM"];
    NSDate *selectDate = [dateFromate dateFromString:_selecteDate];
    NSString *tips = nil;
    if ([selectDate compare:self.maxDate] == NSOrderedDescending) {
        
        NSString *maxDateStr = [dateFromate stringFromDate:self.maxDate];
        tips = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"超过最大时间", nil),maxDateStr];
        [self resetPickView:pickerView tips:tips];
        
        return;
    }
    if ([selectDate compare:self.minDate] == NSOrderedAscending){
        NSString *minDateStr = [dateFromate stringFromDate:self.minDate];
        tips = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"小于最小时间", nil),minDateStr];
       [self resetPickView:pickerView tips:tips];
        return;
        
    }
    if (component == 0) {
        self.yearIndex = row;
        
    }else if (component ==1){
        self.monthIndex = row;
    }
    
    if ([_delegate respondsToSelector:@selector(pickView:selectedDate:)]) {
        [_delegate pickView:self selectedDate:date];
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component==0)
    {
        return [_years objectAtIndex:row];
    }
    return [_months objectAtIndex:row];
}

@end
