//
//  WSTimeTextFieldWithPickerOfTwoZonePanel.m
//  WinSFA
//
//  Created by HZH on 2018/1/29.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSTimeTextFieldWithPickerOfTwoZonePanel.h"
#import "I_W_BuildInfo.h"
#import "DateUtil.h"

@interface WSTimeTextFieldWithPickerOfTwoZonePanel ()
{
    //IOS8.0以下版本，DatePicker设置最大最小值，界面不回滚，只能在此手动限制
    NSDate * _minDate;
    NSDate * _maxDate;
    NSString *lastValue;
    
    NSDate *_minDateFromScript;
}
@end

@implementation WSTimeTextFieldWithPickerOfTwoZonePanel

- (id)initWithFrame:(CGRect)frame {
    
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




- (void)showDatePickerViewWithIndex:(UIDatePickerMode)pickertype
{
    NSDate *nowDate ;

    
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
    
//    WSPickerViewType pickerViewType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:pickertype];
    BOOL isAddDeleteButton = [[xbuildInfo getISRequire] isEqualToString:@"1"] ? NO : YES;
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:WSPickerViewTypeDatas andTitleArray:[NSArray arrayWithObjects:@"开始时间:", @"结束时间:", nil] isAddDeleteButton:isAddDeleteButton];

//    [pickerView setDate:nowDate animated:YES];
//    [pickerView setMaximumDate:_maxDate];
//    [pickerView setMinimumDate:_minDate];
    
    NSMutableArray *dataMArray = [[NSMutableArray alloc] init];
//    [dataMArray addObject:[NSArray arrayWithObjects:@"开始时间", nil]];
    [dataMArray addObject:[self getTimeDataArrayWithMaxNum:24]];
    [dataMArray addObject:[self getTimeDataArrayWithMaxNum:60]];
    
//    [dataMArray addObject:[NSArray arrayWithObjects:@"结束时间", nil]];
    [dataMArray addObject:[self getTimeDataArrayWithMaxNum:24]];
    [dataMArray addObject:[self getTimeDataArrayWithMaxNum:60]];

    pickerView.dataSources = [NSArray arrayWithArray:dataMArray];
    
    NSMutableArray *defaultSelectedMArray = [[NSMutableArray alloc] init];
    
    if ([textField.text length] > 0) {
        // 有回显设置默认时间选择为回显的值
        NSArray *tempArray = [textField.text componentsSeparatedByString:@"-"];
        
        for (NSString *timeStr in tempArray) {
            NSArray *timeStrSegmentArray = [timeStr componentsSeparatedByString:@":"];

            for (NSInteger i = 0; i < timeStrSegmentArray.count; i ++) {
                NSString *numStr = [timeStrSegmentArray objectAtIndex:i];
                [defaultSelectedMArray addObject:[[dataMArray objectAtIndex:i] objectAtIndex:[numStr integerValue]]];
            }
        }
    }else{
        // 无回显设置默认时间选择为当前时间
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateFormat:self.dateFormat];
        NSString *nowTimeStr = [formatter  stringFromDate:nowDate];
        
        NSArray *timeStrSegmentArray = [nowTimeStr componentsSeparatedByString:@":"];
        
        for (NSInteger i = 0; i < timeStrSegmentArray.count; i ++) {
            NSString *numStr = [timeStrSegmentArray objectAtIndex:i];
            [defaultSelectedMArray addObject:[[dataMArray objectAtIndex:i] objectAtIndex:[numStr integerValue]]];
        }
        
        for (NSInteger i = 0; i < timeStrSegmentArray.count; i ++) {
            NSString *numStr = [timeStrSegmentArray objectAtIndex:i];
            NSInteger num = [numStr integerValue];
            
            if (i == 0) {
                if (num < 23) {
                    num = num + 1;
                }else{
                    num = 0;
                }
            }
            
            [defaultSelectedMArray addObject:[[dataMArray objectAtIndex:i] objectAtIndex:num]];
        }
    }
    
    
   
    
    
    [pickerView.pickerView reloadAllComponents];
    
    [pickerView setDefaultSelectedData:[NSArray arrayWithArray:defaultSelectedMArray]];

    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        if ([data isKindOfClass:[NSArray class]]) {
            NSArray *selectedDataArray = (NSArray *)data;
            
            weakSelf.textField.text = [NSString stringWithFormat:@"%@:%@-%@:%@", [selectedDataArray objectAtIndex:0], [selectedDataArray objectAtIndex:1], [selectedDataArray objectAtIndex:2], [selectedDataArray objectAtIndex:3]];
        } else if (!data) {
            weakSelf.textField.text = @"";
        }

    }];
    
}

// 根据传入最大数字返回00-maxNum的字符串数组
- (NSArray *)getTimeDataArrayWithMaxNum:(NSInteger)maxNum
{
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < maxNum; i ++) {
        NSString *numStr = nil;
        
        if (i < 10) {
            numStr = [NSString stringWithFormat:@"0%ld", i];
        }else{
            numStr = [NSString stringWithFormat:@"%ld", i];
        }
        
        [mArray addObject:numStr];
    }
    
    return [NSArray arrayWithArray:mArray];
}

//- (void)setMinDate:(NSString *)dateString {
//    
//    DateUtil  *dateutil = [[DateUtil alloc] init];
//    _minDateFromScript = [dateutil dateString:dateString formateString:self.dateFormat localstr:[[NSLocale currentLocale] localeIdentifier]];
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
