//
//  WSDateTextFieldPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDateTextFieldPanel.h"
#import "I_W_BuildInfo.h"
#import "DateUtil.h"
//===================================================================================================================================================================

#pragma mark - 日期输入框面板 延展(内部)
@interface WSDateTextFieldPanel ()
{
    NSString *lastValue;        //IOS8.0以下版本，DatePicker设置最大最小值，界面不回滚，只能在此手动限制
    UIView *_sperateLineView;
    UIButton *_timeButton;
}

@end
//===================================================================================================================================================================

#pragma mark - 日期输入框面板 延展(工具)
@interface WSDateTextFieldPanel (Tools)

#pragma mark - 通过是否只读标示设置日期输入框方法 isReadonly:是否只读标示
- (void)dateTextFieldSetupWithIsReadonly:(NSString *)isReadonly;

@end
//===================================================================================================================================================================

#pragma mark - 日期输入框面板
@implementation WSDateTextFieldPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.dateFormat = DATE_FORMAT_CH;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_WF])
        self.textField.frame = CGRectMake(self.titleLabel.origin.x, self.textField.origin.y, self.width - self.titleLabel.origin.x - MAIN_PADDING, self.textField.height);
    else
        self.textField.frame = CGRectMake(self.textField.origin.x, self.textField.origin.y,
                                          self.width - self.textField.origin.x - MAIN_CELL_BUTTON_WH - MAIN_PADDING, self.textField.height);
}

- (NSDate *)minDate
{
    // SFA-21288 && [[xbuildInfo getSnumx] integerValue] != 0 ()   SFA-24490 (等于0为从今天开始，不应添加此条件)
    if (_minDate == nil && [xbuildInfo getSnumx].length > 0 )
        _minDate = [NSDate dateWithTimeIntervalSinceNow:[[xbuildInfo getSnumx] integerValue]*24*60*60];
    
    return _minDate;
}

- (NSDate *)maxDate
{
    // SFA-21288 && [[xbuildInfo getMumx] integerValue] != 0。 SFA-24490 (等于0为到今天，不应该添加此条件)
    if (_maxDate == nil && [xbuildInfo getMumx].length > 0)
        _maxDate = [NSDate dateWithTimeIntervalSinceNow:[[xbuildInfo getMumx] integerValue]*24*60*60];
    
    return _maxDate;
}

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    // YIHAIKERRY-3727 zhaodanyang
    if ([[xbuildInfo getDisplayMode] isEqualToString:QST_DISPLAYMODE_CENTER]) {
        self.textField.textAlignment = NSTextAlignmentCenter;
    }
    else{
        //MN-1615 2018-04-09
        self.textField.textAlignment = NSTextAlignmentRight;
        
    }
    
    NSString *btnImageName = nil;
    NSString *btnDisableImageName = nil;
    if ( [self.dateFormat isEqualToString:DATE_FORMAT_CH_WITH_CHN_NOTIME] || [self.dateFormat isEqualToString:DATE_FORMAT_CH_WITH_SEP_NOTIME]
        || [self.dateFormat isEqualToString:DATE_FORMAT_CH] || [self.dateFormat isEqualToString:DATE_FORMAT_YEAR_MONTH] || [self.dateFormat isEqualToString:DATE_FORMAT_YEAR])
    {
        btnImageName = @"date_select_icon";
        btnDisableImageName = @"date_select_icon_disable";
    }
    else
    {
        btnImageName = @"time_select_icon";
        btnDisableImageName = @"time_select_icon_disable";
    }
    
    //WF只是显示的功能，不需要编辑
    if (![[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_WF])
    {
        UIImage *btnImage  = [UIImage scaledImageForName:btnImageName ofType:@"png"];
        UIImage *btnDisableImage = [UIImage scaledImageForName:btnDisableImageName ofType:@"png"];
        UIButton *timeButton = [[UIButton alloc] init];
        [timeButton setImage:btnImage forState:UIControlStateNormal];
        [timeButton setImage:btnDisableImage forState:UIControlStateDisabled];
        [timeButton addTarget:self action:@selector(timeAction:) forControlEvents:UIControlEventTouchUpInside];
        _timeButton = timeButton;
        [self addSubview:timeButton];
        
        UIView *sperateLineView = [[UIView alloc] init];
        sperateLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
        _sperateLineView = sperateLineView;
        [self addSubview:sperateLineView];
    }
    
    [self dateTextFieldSetupWithIsReadonly:[xbuildInfo getReadOnly]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //WF只是显示的功能，不需要编辑
    if ([[xbuildInfo getAcvtQstType] isEqualToString:QST_TYPE_WF])
        self.textField.frame = CGRectMake(self.titleLabel.origin.x, self.textField.origin.y, self.width - self.titleLabel.origin.x - MAIN_PADDING, self.textField.height);
    else
    {
        BOOL orientition = NO;
        if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"])
            orientition = YES;
        
        CGFloat timeOffsetY;
        CGFloat seperatOffsetY;
        if (orientition)
        {
            timeOffsetY = (self.height - MAIN_CELL_BUTTON_WH) / 2;
            seperatOffsetY = (self.height - MAIN_CELL_SEPERATOR_LENGTH) / 2;
        }
        else
        {
            timeOffsetY = (self.height - CGRectGetMaxY(self.titleLabel.frame) - MAIN_CELL_BUTTON_WH) / 2  + CGRectGetMaxY(self.titleLabel.frame) ;
            seperatOffsetY = (self.height  - CGRectGetMaxY(self.titleLabel.frame) -  MAIN_CELL_SEPERATOR_LENGTH) / 2  + CGRectGetMaxY(self.titleLabel.frame);
        }
        
        //2017-11-01-MSTD-6727-布局更改
        CGFloat textStrWidth = [self.titleLabel.text ws_sizeWithFont:self.titleLabel.font constrainedToHeight:CGRectGetHeight(self.titleLabel.frame)].width;
        CGFloat x = CGRectGetMinX(self.titleLabel.frame);
        CGFloat y = CGRectGetMinY(self.titleLabel.frame);
        CGFloat w = textStrWidth;
        CGFloat h = CGRectGetHeight(self.titleLabel.frame);
        self.titleLabel.frame = CGRectMake(x, y, w, h);
        
        
        textStrWidth = [self.textField.text ws_sizeWithFont:self.textField.font constrainedToHeight:CGRectGetHeight(self.textField.frame)].width;

        //MN-1755 2018-04-18 布局变更
        if([[xbuildInfo getReadOnly] integerValue] == 1)
        {
            x += w;
            // SFA-22547 zhaodanyang
            w = CGRectGetWidth(self.frame) - MAIN_BUTTON_WH - x;
            _timeButton.frame = CGRectZero;
            _sperateLineView.frame = CGRectZero;
        }
        else
        {
            x = CGRectGetWidth(self.frame) - MAIN_CELL_BUTTON_WH;
            y = timeOffsetY;
            w = MAIN_CELL_BUTTON_WH;
            h = MAIN_CELL_BUTTON_WH;
            _timeButton.frame = CGRectMake(x, y, w, h);
            x = CGRectGetMaxX(self.titleLabel.frame) + MAIN_TEXT_IMG_PADDING;
            w = CGRectGetMinX(_timeButton.frame) - MAIN_TEXT_IMG_PADDING - x;
            _sperateLineView.frame = CGRectMake(CGRectGetMinX(_timeButton.frame), seperatOffsetY, 1, MAIN_CELL_SEPERATOR_LENGTH);
        }
        //        董宏  YIHAIKERRY-2360
        x = CGRectGetMaxX(self.titleLabel.frame) + MAIN_TEXT_IMG_PADDING;
        y = CGRectGetMinY(self.textField.frame);
        
        if (w < textStrWidth && !orientition) {
            x = x- textStrWidth + fabs(w);
            w = textStrWidth;
        }
        
        h = CGRectGetHeight(self.textField.frame);
        self.textField.frame = CGRectMake(x, y, w, h);
    }
}

- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo
{
    [super loadBuildInfo:buildInfo];
}

- (void)timeAction:(id)sender
{
    // YIHAIKERRY-3757 zhaodanyang
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    [self showDatePickerViewWithIndex:UIDatePickerModeDate];
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    [self dateTextFieldSetupWithIsReadonly:isReadonly];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self showDatePickerViewWithIndex:UIDatePickerModeDate];
    return NO;
}

- (void)showDatePickerViewWithIndex:(UIDatePickerMode)pickertype {
    
    NSDate *nowDate;
    if ([textField.text length] > 0) {
        DateUtil *dateutil = [[DateUtil alloc] init];
        nowDate = [dateutil dateString:textField.text formateString:self.dateFormat localstr:[[NSLocale currentLocale] localeIdentifier]];
    }
    if (!nowDate) {
        nowDate = [NSDate date];
    }
    if ([nowDate compare:self.minDate] == NSOrderedAscending) {
        nowDate = self.minDate;
    }
    
    WSPickerViewType pickerViewType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:pickertype];
    BOOL isAddDeleteButton = [[xbuildInfo getISRequire] isEqualToString:@"1"] ? NO : YES;
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType isAddDeleteButton:isAddDeleteButton];
    [pickerView setDate:nowDate animated:YES];
    [pickerView setMaximumDate:self.maxDate];
    [pickerView setMinimumDate:self.minDate];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        
        if (!isOK) {
            return;
        }
         
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
}

//8.0以下系统有问题，超过最大值、或者小于最小值DatePicker界面不回滚,只能手动限制
-(void)valueChanged:(UIDatePicker *)datePicker
{
    if (_minDate && ![[datePicker.date earlierDate:_minDate] isEqualToDate:_minDate]) //超过最小值
        [datePicker setDate:_minDate animated:YES];
    else if (_maxDate && [[datePicker.date earlierDate:_maxDate] isEqualToDate:_maxDate]) //超过最大值
        [datePicker setDate:_maxDate animated:YES];
}

//刷新当前widget显示值
- (void)reloadCurrentWidgetWithValue:(NSObject *)value
{
    if ([value isKindOfClass:[NSString class]])
    {
        NSString *valueString = (NSString *)value;
        if ([valueString length] > 0)
        {
            DateUtil  *dateutil = [[DateUtil alloc] init];
            NSDate *valueDate = [dateutil dateString:valueString formateString:self.dateFormat localstr:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
            
            if (valueDate)
                [self setDateContent:valueDate];
            else
            {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:valueString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                self.textField.text = lastValue;
            }
        }
    }
}

- (void)widgetDidLoadFinish
{
    //SFA-7953 时间类型已改为初始化时不执行脚本，因为时间类型即使没有回显值，也会给一个当前时间的默认值，会影响脚本逻辑
    //安卓本来就是初始化时不执行问题脚本
    //    if ([self.textField.text length] > 0) {
    //        if ([[xbuildInfo getLuaScript] length] > 0) {
    //            if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
    //                [self.delegate executeLuaScript:xbuildInfo widget:self];
    //
    //            }
    //        }
    //    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:200];
    [self setDateContent:datePicker.date];
}

-(void)setDateContent:(NSDate *)date
{
    lastValue = textField.text;
    DateUtil  *dateutil = [[DateUtil alloc] init];
    NSString *time = [dateutil obtainDate:date formateString:self.dateFormat];
    [textField setText:time];
    self.resultCheck = time ;
    if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)])
        [self.delegate executeLuaScript:xbuildInfo widget:self];
}

- (NSObject *)getDisplayValuePresentation
{
    return textField.text;
}

@end
//===================================================================================================================================================================

#pragma mark - 日期输入框面板 延展(工具)
@implementation WSDateTextFieldPanel (Tools)

#pragma mark - 通过是否只读标示设置日期输入框方法 isReadonly:是否只读标示
- (void)dateTextFieldSetupWithIsReadonly:(NSString *)isReadonly
{
    BOOL isReadonlyInt = [isReadonly boolValue];
    if(isReadonlyInt == 1)
    {
        self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
        
        textField.enabled = NO;
        textField.textColor = PanelTextFieldColorReadonly;
        textField.placeholder = @"";
        
        _timeButton.hidden = YES;
        _sperateLineView.hidden = YES;
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        
        textField.enabled = YES;
        textField.textColor = PanelTextFieldColor;
        textField.placeholder = NSLocalizedString(@"please_fill_in", nil);
        
        _timeButton.hidden = NO;
        _sperateLineView.hidden = NO;
    }
    [self setNeedsLayout];
}

@end
//===================================================================================================================================================================

