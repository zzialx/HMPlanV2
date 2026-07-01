//
//  WSTimeFieldPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTimeTextFieldPanel.h"
#import "I_W_BuildInfo.h"
#import "DateUtil.h"

@interface WSTimeTextFieldPanel ()
{
    //IOS8.0以下版本，DatePicker设置最大最小值，界面不回滚，只能在此手动限制
    NSDate * _minDate;
    NSDate * _maxDate;
    NSString *lastValue;
    
    NSDate *_minDateFromScript;
}
@end

@implementation WSTimeTextFieldPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dateFormat = DATE_HOUR_CH;
    
        return self;
    
    }
    
    return nil;
}

- (void)timeAction:(id)sender {
    [self showDatePickerViewWithIndex:UIDatePickerModeTime];
}

// 重写父类方法重新设置DatePickerModeTime
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    [self showDatePickerViewWithIndex:UIDatePickerModeTime];
    
    return NO;
}




-(void)showDatePickerViewWithIndex:(UIDatePickerMode)pickertype
{
    NSDate *nowDate ;
    if ([textField.text length] > 0) {
        DateUtil  *dateutil = [[DateUtil alloc] init];
        nowDate = [dateutil dateString:textField.text formateString:self.dateFormat localstr:[[NSLocale currentLocale] localeIdentifier]];
    }
    
    if (!nowDate) {
        nowDate =[NSDate date];
    }
    
    // 获取最大值 和最小值
    _minDate = nil;
    _maxDate = nil;
    
    NSInteger minNum = [[xbuildInfo getSnumx] integerValue];
    NSInteger maxNum = [[xbuildInfo getMumx] integerValue];
    if (minNum < maxNum && [xbuildInfo getSnumx] && [xbuildInfo getMumx]) {
        _minDate = [NSDate dateWithTimeIntervalSinceNow:[[xbuildInfo getSnumx] integerValue] * 60];
        _maxDate = [NSDate dateWithTimeIntervalSinceNow:[[xbuildInfo getMumx] integerValue] * 60];
        
    }
    
    if (_minDateFromScript) {
        _minDate = _minDateFromScript;
    }
    
    
    WSPickerViewType pickerViewType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:pickertype];
    BOOL isAddDeleteButton = [[xbuildInfo getISRequire] isEqualToString:@"1"] ? NO : YES;
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType isAddDeleteButton:isAddDeleteButton];
    [pickerView setDate:nowDate animated:YES];
    [pickerView setMaximumDate:_maxDate];
    [pickerView setMinimumDate:_minDate];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
   
}

- (void)setMinDate:(NSString *)dateString {
    
    DateUtil  *dateutil = [[DateUtil alloc] init];
    _minDateFromScript = [dateutil dateString:dateString formateString:self.dateFormat localstr:[[NSLocale currentLocale] localeIdentifier]];
}


@end
