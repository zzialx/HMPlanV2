//
//  WSDatePickerLabel.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-7-27.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSDatePickerLabel.h"
#import "WSApplicationWindowsRelationManager.h"

@interface WSDatePickerLabel ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) WSYMPickView *ymPickView;

@property (nonatomic, strong) WSFuncsBean_Param *param;

@property (nonatomic, assign)BOOL iIsObserver;

@property (nonatomic, strong)UIButton *timeImage;

@end

@implementation WSDatePickerLabel

@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (id)initWithFrame:(CGRect)frame param:(WSFuncsBean_Param *)aParam {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        // Initialization code
        
        self.font = [UIFont systemFontOfSize:UI_Font - 1];
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByCharWrapping;
        self.textAlignment = NSTextAlignmentCenter;
        self.contentMode =  UIViewContentModeCenter;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:singleTap];
       
        self.param = aParam;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame param:nil];
}


-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if ([[UIDevice currentDevice] systemVersionByFloat] >= 8.000000) {
        if (_datePickerLaberMode == WSDatePickerLabelModeTime){
            [self.timeImage setFrame:CGRectMake((CGRectGetWidth(self.bounds) -  MAIN_CELL_BUTTON_WH ) / 2.0, (self.frame.size.height -  MAIN_CELL_BUTTON_WH) / 2,  MAIN_CELL_BUTTON_WH,  MAIN_CELL_BUTTON_WH)];
        }
    }

}

- (void) layoutSubviews
{
    if (_datePickerLaberMode == WSDatePickerLabelModeTime){
        [self.timeImage setFrame:CGRectMake((CGRectGetWidth(self.bounds) -  MAIN_CELL_BUTTON_WH ) / 2.0, (self.frame.size.height -  MAIN_CELL_BUTTON_WH) / 2,  MAIN_CELL_BUTTON_WH,  MAIN_CELL_BUTTON_WH)];
    }
    
    if (_datePickerLaberMode == WSDatePickerLabelModeDate || _datePickerLaberMode == WSDatePickerLabelModeYM ){
        [self.timeImage setFrame:CGRectMake((CGRectGetWidth(self.bounds) -  MAIN_CELL_BUTTON_WH ) / 2.0, (self.frame.size.height -  MAIN_CELL_BUTTON_WH) / 2,  MAIN_CELL_BUTTON_WH,  MAIN_CELL_BUTTON_WH)];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (!self.enabled) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        // SFA-8263 获取当前响应者所在VC，让整个view取消第一响应者，从而让所有控件的键盘隐藏。
        UIViewController *currentVC = [[WSApplicationWindowsRelationManager sharedManager] getCurrentVC];
        [currentVC.view endEditing:YES];
        
        WSPickerViewType pickerType = [WSPickerView convertToPickerViewTypeFromDatePickerLabelMode:self.datePickerLaberMode];
        
        BOOL isAddDeleteButton = [self.param.isReq isEqualToString:@"1"] ? NO : YES;
        WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerType isAddDeleteButton:isAddDeleteButton];
        
        NSDate *maxDate;
        NSDate *minDate;
        if (self.param.max) {
            maxDate = [self limitedDateAccordingParamMinOrMax:self.param.max];
        } else if (self.maxValue) {
            maxDate = [self convertStringToDate:self.maxValue];
        }
        if (self.param.min) {
            minDate = [self limitedDateAccordingParamMinOrMax:self.param.min];
        } else if (self.minValue) {
            minDate = [self convertStringToDate:self.minValue];
        }
        if (self.datePickerLaberMode == WSDatePickerLabelModeYM) {
            [pickerView setDateStr:self.text];
           
            [pickerView setMaximumDate:maxDate];
            [pickerView setMinimumDate:minDate];
        }else if (pickerType == WSPickerViewTypeDate){
            [pickerView setMaximumDate:maxDate];
            [pickerView setMinimumDate:minDate];
        }
        
        __weak typeof(self) weakSelf = self;
        [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
            if (!isOK) {
                return;
            }
            if(data){
                //确定按钮
                NSDate *date = (NSDate *)data;
                [weakSelf p_setDate:date pickerType:pickerType];
            }else{
                //删除按钮
                [weakSelf p_deleteDate];
            }
        }];
    }
}


-(void)p_deleteDate{
    if (self.text.length>0){
        _isValueChange = YES;
    }
    self.text = @"";
    [self addSubview:self.timeImage];
    [self recoveryStyle];
}
- (void)p_setDate:(NSDate *)date pickerType:(WSPickerViewType)pickerType {
    NSString *dateString=nil;
    if(pickerType == WSPickerViewTypeTime){
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = @"HH:mm";
        dateString = [formatter stringFromDate:date];
    } else if (pickerType == WSPickerViewTypeDateYearMonth) {
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = @"yyyy-MM";
        dateString = [formatter stringFromDate:date];
    } else {
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = @"yyyy-MM-dd";
        dateString = [formatter stringFromDate:date];
    }
    
    if (![self.text isEqualToString:dateString]) {
        _isValueChange = YES;
        if ([self.delegate respondsToSelector:@selector(datePickerLabel:valueChanged:)]) {
            [self.delegate datePickerLabel:self valueChanged:dateString];
        }
    }
    [self setTimeText:dateString];
    [self.timeImage removeFromSuperview];
    [self changeStyle];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedDatePickerLabel:)]) {
        [self.delegate didSelectedDatePickerLabel:self];
    }
}



- (NSDate *)limitedDateAccordingParamMinOrMax:(NSString *)minMax {
    
    if (self.datePickerLaberMode == WSDatePickerLabelModeYM) {
        
        NSDateComponents *dateComponents = [WSCurrentTime YMDComponents];
        NSInteger currentYear = dateComponents.year;
        NSInteger currentMonth = dateComponents.month;
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        [formatter setDateFormat:@"yyyy-MM"];
        if ([minMax length] > 0) {
            NSInteger limitedYear = currentYear;
            NSInteger limitedMonth = currentMonth;
            if (limitedMonth + [minMax integerValue] > 12) {
                limitedYear += (currentMonth + [minMax integerValue])/12;
                limitedMonth = (currentMonth + [minMax integerValue])%12;
                return [formatter dateFromString:[NSString stringWithFormat:@"%ld-%ld",(long)limitedYear,(long)limitedMonth]];
            }else if (limitedMonth + [minMax integerValue] < 0) {
                limitedYear -= -(currentMonth + [minMax integerValue])/12 + 1;
                limitedMonth = 12 + (currentMonth + [minMax integerValue])%12;
            }else {
                limitedMonth +=   + [minMax integerValue];
            }
            
            NSDate *limitDate = [formatter dateFromString:[NSString stringWithFormat:@"%ld-%ld",(long)limitedYear,(long)limitedMonth]];
            return limitDate;
        }
        
    }else {
        
        if (minMax.length > 0) {
            
            NSDate * currentDay = [WSCurrentTime getCurrentServerDate];
            NSDate * limitedDay = [NSDate dateWithTimeInterval:24 * 60 * 60 *[minMax integerValue] sinceDate:currentDay];
            return limitedDay;
        }
        
    }
    return nil;
}

- (NSDate *)convertStringToDate:(NSString *)dateString {
    if (dateString) {
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        if (self.datePickerLaberMode == WSDatePickerLabelModeDate) {
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }else if (self.datePickerLaberMode == WSDatePickerLabelModeYM){
            [formatter setDateFormat:@"yyyy-MM"];
        }
        return [formatter dateFromString:dateString];
    }
    return nil;
}
- (void)addTimeImageToView {
    [self addSubview:self.timeImage];
}

/**
 改变label显示样式
 */
- (void)changeStyle {
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
    self.layer.cornerRadius = 5.0;
    self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245/255.0 blue:245/255.0 alpha:1];
}
- (void)recoveryStyle {
    self.layer.borderWidth = 0;
    self.layer.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1].CGColor;
    self.layer.cornerRadius = 0;
    self.backgroundColor = [UIColor whiteColor];
}
- (void)createDatePickerIconWith:(WSDatePickerLabelMode)datePickerLabelMode {
    _datePickerLaberMode = datePickerLabelMode;
    UIImage *image =  nil;
    if (_datePickerLaberMode == WSDatePickerLabelModeTime) {
        image = [UIImage scaledImageForName:@"icon_clock" ofType:@"png"];
    }else if(_datePickerLaberMode == WSDatePickerSheetModeDate ||
             _datePickerLaberMode == WSDatePickerLabelModeYM) {
        image = [UIImage scaledImageForName:@"date_select_icon" ofType:@"png"];
    }
    _timeImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timeImage setImage:image forState:UIControlStateNormal];
    _timeImage.userInteractionEnabled = NO;
}


#pragma mark WSYMPickViewDelegate Methods

- (void)pickView:(WSYMPickView *)pickView selectedDate:(NSString *)dateString {
    if (![self.text isEqualToString:dateString]) {
        _isValueChange = YES;
        if ([self.delegate respondsToSelector:@selector(datePickerLabel:valueChanged:)]) {
            [self.delegate datePickerLabel:self valueChanged:dateString];
        }
    }
}


#pragma mark - WSValidateData protocal
- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType {
    //    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
    //    NSLog(@"%d--%s-----%p-----%d", __LINE__, __FUNCTION__, self, self.iDataType);
    //    if (self.iDataType == WSValidateDataIsDepended) {
    //        [self addObserver:self
    //               forKeyPath:@"text"
    //                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
    //                  context:nil];
    //        self.iIsObserver = YES;
    //    }
    
    if (self.iDataType == WSValidateDataIsDepended) {
//        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
//        NSNumber *number = nil;
//        if (self.text && [self.text length] > 0) {
//            number = [NSNumber numberWithBool:YES];
//        }else{
//            number = [NSNumber numberWithBool:NO];
//        }
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(textChanged:)
//                                                     name:UITextFieldTextDidChangeNotification
//                                                   object:self];
//        
//        self.iIsObserver = YES;
    }
    
    
}

//- (void)textChanged:(NSNotification *) notification
//{
//    if ([notification object] == self) {
//        if ([[notification object] isKindOfClass:[WSHTextField class]]) {
//            WSHTextField *textfield = (WSHTextField *)[notification object];
//            NSNumber *number = nil;
//            if (textfield.text && [textfield.text length] > 0) {
//                number = [NSNumber numberWithBool:YES];
//            }else{
//                number = [NSNumber numberWithBool:NO];
//            }
//            
//            NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
//            
//            
//        }
//    }
//}

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
////    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
//
//    if (keyPath != nil && [keyPath isEqualToString:@"text"]) {
//        id new = [change objectForKey:@"new"];
//        NSNumber *number = nil;
//        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
//        if ([new isKindOfClass:[NSNull class]]) {
//            number = [NSNumber numberWithBool:NO];
//        }else if([new isKindOfClass:[NSString class]]){
//            NSString *str = (NSString *)new;
//            BOOL flag = NO;
//            if (str != nil && [str length] > 0) {
//                flag = YES;
//            }
//            number = [NSNumber numberWithBool:flag];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:number userInfo:nil];
//
//    }
//}


- (void)updateState:(NSNotification *)sender
{
    //    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        if (!isEnable) {
            self.text = nil;
        }
        [self setEnabled:isEnable];
        
    }
}

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}

- (NSString *)getTextValue
{
    return self.text;
}

- (BOOL)isValueLegal
{
    return self.text != nil && [self.text length] > 0;
}


- (void)dealloc {
    //    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
   
//    if (self.iDataType == WSValidateDataIsDepended && self.iIsObserver == YES) {
//        //        [self removeObserver:self forKeyPath:@"text" context:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void) setTimeText:(NSString *)timeText
{
    
    if (self.datePickerLaberMode == WSDatePickerLabelModeTime) {
        
        if (timeText && [timeText length] > 0) {
            self.text = timeText;
            [self.timeImage removeFromSuperview];
        }else{
            self.text = @"";
            [self addSubview:self.timeImage];
            
        }
    }else{
    
        self.text = timeText;
    }
}

@end
