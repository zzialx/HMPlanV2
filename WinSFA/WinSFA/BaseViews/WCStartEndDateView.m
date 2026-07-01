//
//  WCStartEndDateView.m
//  StartEndDate
//
//  Created by ZhengJiepeng on 13-4-1.
//  Copyright (c) 2013年 ZhengJiepeng. All rights reserved.
//

#import "WCStartEndDateView.h"

#import "WSAcvtQstBottomLineView.h"

#import "DateUtil.h"

//static const CGFloat WCSENV_Select_Date_Button_Width = 48.0;

//static const CGFloat WCSENV_Select_Date_Button_Height = 76.0;

//static const CGFloat WCSENV_Select_Date_Button_Right_Margin = 0.0f;

#define WCSENV_Show_Date_Label_Width (SCREEN_WIDTH / 2)

//static const CGFloat WCSENV_Left_Label_Margin = 0.0f;

static const CGFloat WCSENV_Label_Width = 120.0f;

//static const CGFloat WCSENV_Label_Height = 30.f;


//static const CGFloat WCButtonWH = 40.0;

static const char *weekChar[7] = {"日", "一", "二", "三", "四", "五", "六"};

@interface WCStartEndDateView ()
{
    BOOL isFirstConfig;

}

@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;

@property (nonatomic, strong) UILabel *showStartDateLabel;
@property (nonatomic, strong) UILabel *showEndDateLabel;

@property (nonatomic, strong) UIButton *stButton;
@property (nonatomic, strong) UIButton *etButton;

@property (nonatomic, strong) UIActionSheet *actionSheet;
#ifdef __IPHONE_8_0
@property (nonatomic, strong) UIAlertController *actionController;
#endif
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) UIButton *currentButton;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSString *formatString;

@end

@implementation WCStartEndDateView

@synthesize startTitle = _startTitle;
@synthesize startDate = _startDate;
@synthesize endTitle = _endTitle;
@synthesize endDate = _endDate;

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
        formatter.dateFormat = self.formatString;
        _dateFormatter = formatter;
    }
    return _dateFormatter;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
       withDateMode:(UIDatePickerMode)pickerMode
 withIsSinglePicker:(BOOL)isSinglePicker
         dateString:(NSString *)dateString
   dateFormatString:(NSString *)dateFormatString {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.pickerMode = pickerMode;
        self.isSinglePicker = isSinglePicker;
        
        self.formatString = dateFormatString;
        
        if ([dateString length] > 0) {
            DateUtil  *dateutil = [[DateUtil alloc] init];
            
            NSDate *startDate;
            NSDate *endDate;
            NSArray *startEndTime = [dateString componentsSeparatedByString:@","];
            if ([startEndTime count] > 1) {
                startDate = [dateutil dateString:startEndTime[0] formateString:dateFormatString localstr:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
                
                endDate = [dateutil dateString:startEndTime[1] formateString:dateFormatString localstr:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
            } else {
                NSDate *valueDate = [dateutil dateString:dateString formateString:dateFormatString localstr:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]];
                
                startDate = valueDate;
                endDate = valueDate;
            }
            
            self.startDate = startDate;
            self.endDate = endDate;
        }
        
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = pickerMode;
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        
#ifdef __IPHONE_8_0
        if ([[UIDevice currentDevice] systemVersionLowerThan:@"8.0"])
        {
#endif
            NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n";
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"confirm", nil), nil];
            [_actionSheet addSubview:_datePicker];
            
#ifdef __IPHONE_8_0
        }else {
            NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n";
            self.actionController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            __weak typeof(self) wself = self;
            [self.actionController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [wself clickedOkActionButton];
            }]];
            
            
            [self.actionController.view addSubview:_datePicker];
        }
#endif
        isFirstConfig = YES;
        /*Jira - MSTD-6841  分割线顶到头 create by sunhongfu 2017-11-8*/
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, self.frame.size.height - 1, self.frame.size.width , MAIN_CELL_SEPERATOR_HEIGHT)];
        bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        bottomLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
        [self addSubview:bottomLineView];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat itemHeight = self.frame.size.height / 2;
    
    if (self.isSinglePicker) {
        itemHeight = self.frame.size.height;
    }

    _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, 0, WCSENV_Label_Width, itemHeight)];
    _startLabel.textAlignment = NSTextAlignmentLeft;
    _startLabel.font = [UIFont systemFontOfSize:UI_Font];
    _startLabel.backgroundColor = [UIColor clearColor];
    [_startLabel setText:NSLocalizedString(@"worklog_start_date", nil)];
    if ([self.startTitle length] > 0) {
        [_startLabel setText:self.startTitle];
    }
    [self addSubview:_startLabel];
    

    CGRect stButtonFrame = CGRectMake(self.frame.size.width - MAIN_CELL_BUTTON_WH, (itemHeight - MAIN_CELL_BUTTON_WH) / 2, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH);
    
    CGFloat showDateLabelWidth = WCSENV_Show_Date_Label_Width - MAIN_PADDING;
    CGFloat showDateLabel_x = self.width - stButtonFrame.size.width - showDateLabelWidth - MAIN_PADDING;
    _showStartDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(showDateLabel_x, 0, showDateLabelWidth, itemHeight)];
    _showStartDateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _showStartDateLabel.textAlignment = NSTextAlignmentRight;

    _showStartDateLabel.font = [UIFont systemFontOfSize:UI_Font];
    _showStartDateLabel.backgroundColor = [UIColor clearColor];
    [_showStartDateLabel setText:[self stringFromdate:_startDate]];
    _showStartDateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *startTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startLabelTap:)];
    [_showStartDateLabel addGestureRecognizer:startTap];
    [self addSubview:_showStartDateLabel];
    
    UIImage *btnImage;
    if (self.pickerMode == UIDatePickerModeDateAndTime) {
        btnImage = [UIImage imageNamed:@"time_select_icon"];
    } else {
        btnImage = [UIImage imageNamed:@"date_select_icon"];
    }
    
   
    
    self.stButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stButton setImage:btnImage forState:UIControlStateNormal];
    _stButton.frame = stButtonFrame;
    _stButton.tag=100;
    [_stButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    if (self.readRonly) {
        self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
        _stButton.enabled = NO;
    }
    else{
        _stButton.enabled = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    [_stButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [self addSubview:_stButton];
    
     /*Jira - MSTD-6841  分割线顶到头 create by sunhongfu 2017-11-8*/
    UIView *seperateLineView  = [[UIView alloc] initWithFrame: CGRectMake(SEPERATE_PADDING_Left, itemHeight - 1, self.width , MAIN_CELL_SEPERATOR_HEIGHT)];
    [seperateLineView setBackgroundColor:DETAIL_SEPERATE_LINE_COLOR];
    [self addSubview:seperateLineView];
    
    if (self.isSinglePicker) {
        [seperateLineView removeFromSuperview];
        [self setReadRonly:_readRonly];
        return;
    }
    _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(MAIN_CELL_PADDING, itemHeight, WCSENV_Label_Width, itemHeight)];
    _endLabel.textAlignment = NSTextAlignmentLeft;
    _endLabel.font = [UIFont systemFontOfSize:UI_Font];
    _endLabel.backgroundColor = [UIColor clearColor];
    [_endLabel setText:NSLocalizedString(@"worklog_end_date", nil)];
    if ([self.endTitle length] > 0) {
        [_endLabel setText:self.endTitle];
    }
    [self addSubview:_endLabel];
    
    _showEndDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(showDateLabel_x, itemHeight,showDateLabelWidth, itemHeight)];
    _showEndDateLabel.textAlignment = NSTextAlignmentRight;
    _showEndDateLabel.font = [UIFont systemFontOfSize:UI_Font];
    [_showEndDateLabel setText:[self stringFromdate:_endDate]];
    _showEndDateLabel.backgroundColor = [UIColor clearColor];
    _showEndDateLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *endTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endLabelTap:)];
    [_showEndDateLabel addGestureRecognizer:endTap];
    [self addSubview:_showEndDateLabel];
    
    self.etButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.etButton setImage:btnImage forState:UIControlStateNormal];
    _etButton.frame = CGRectMake(CGRectGetMinX(_stButton.frame), itemHeight, MAIN_CELL_BUTTON_WH, MAIN_CELL_BUTTON_WH);
    _etButton.tag = 200;
    [_etButton addTarget:self action:@selector(showPicker:) forControlEvents:UIControlEventTouchUpInside];
    if (self.readRonly) {
        _etButton.enabled = NO;
    }
    else{
        _etButton.enabled = YES;
    }
    [_etButton setTitleColor:MAIN_TEXT_COLOR forState:UIControlStateNormal];
    [self addSubview:_etButton];
    

    CGFloat seperatOffsetY = (itemHeight - MAIN_CELL_SEPERATOR_LENGTH) / 2;
    UIView *sperateLineView = [[UIView alloc] initWithFrame:CGRectMake(SEPERATE_PADDING_Left, seperatOffsetY, 1, MAIN_CELL_SEPERATOR_LENGTH)];
    sperateLineView.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:sperateLineView];
    
    UIView *sperateLineViewTwo = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(sperateLineView.frame), itemHeight + seperatOffsetY, 1, MAIN_CELL_SEPERATOR_LENGTH)];
    sperateLineViewTwo.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:sperateLineViewTwo];
    
    
    [self setReadRonly:_readRonly];
    
}

- (void)setReadRonly:(BOOL)readRonly
{
    _readRonly = readRonly;
    if (readRonly) {
        self.startLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        self.endLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        self.showStartDateLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        self.showEndDateLabel.textColor = MAIN_TEXT_DISABLE_COLOR;
        self.userInteractionEnabled = NO;
    }else {
        self.startLabel.textColor = DETAIL_TEXT_COLOR;
        self.endLabel.textColor = DETAIL_TEXT_COLOR;
        self.showStartDateLabel.textColor = MAIN_TEXT_COLOR;
        self.showEndDateLabel.textColor = MAIN_TEXT_COLOR;
        self.userInteractionEnabled = YES;
    }
}


- (void)startLabelTap:(UITapGestureRecognizer *)recognizer {
    [self showPicker:_stButton];
}

- (void)endLabelTap:(UITapGestureRecognizer *)recognizer {
    [self showPicker:_etButton];
}


- (void)showPicker:(UIButton *)sender {
    
    [self initMaxMinDate];
    
    if (sender == _stButton) {

        self.datePicker.minimumDate = self.sectionStartDate;
        
        if (self.startDate) {
            self.datePicker.date = self.startDate;
        }
        
    } else {
        
        if (self.startDate) {
            self.datePicker.minimumDate = self.startDate;
        }else {
            self.datePicker.minimumDate = self.sectionStartDate;
        }
        
        self.datePicker.maximumDate = self.sectionEndDate;
        
        if (self.endDate) {
            self.datePicker.date = self.endDate;
        }
        
    }
    self.currentButton = sender;

    if (self.delegate) {
        //兼容老版本
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            
            UIViewController *parentVC = (UIViewController*)self.delegate;
            
            /*
             ipad上弹出框必须要有一个锚点，即anchor point。当我们在iPhone等常规屏幕的设备上使用actionSheet时，
             很明显锚点在屏幕下方,而在ipad上，则需要我们自己手动设置。
             */
            if (INTERFACE_IS_PAD) {
                UIPopoverPresentationController *popPresenter = self.actionController.popoverPresentationController;
                popPresenter.sourceView = self;
                popPresenter.sourceRect = self.bounds;
                popPresenter.permittedArrowDirections = UIPopoverArrowDirectionLeft;
            }
            [parentVC presentViewController:self.actionController
                                   animated:YES
                                 completion:^{
                                     
                                 }];
        }
        ///////////////////////////////////////////////比较折中的方案,需要重新设计////////////////////////////////////////////////////////////////
        if ([self.delegate isKindOfClass:[UIView class]]) {
            
            if ([self.delegate respondsToSelector:@selector(showDatePickerView:andSelectedBtn:)]) {
                
                
                [self.delegate showDatePickerView:self andSelectedBtn:sender];
                
            }
            
            
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
 
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self clickedOkActionButton];
}

- (void) clickedOkActionButton
{
    if (_currentButton == _stButton) {
        self.lastStartDateString = self.showStartDateLabel.text;
        self.startDate = _datePicker.date;
        if ([self.startDate compare:self.endDate] == NSOrderedDescending) {
            self.endDate = self.startDate;
        }
    } else {
    
        self.endDate = _datePicker.date;
    
    }
    
    [self.showEndDateLabel setText:[self stringFromdate:_endDate]];
 
    [self.showStartDateLabel setText:[self stringFromdate:_startDate]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(WCStartEndDateViewValueChanged:)]) {
        [self.delegate performSelector:@selector(WCStartEndDateViewValueChanged:) withObject:self];
    }
}
////////////////////////////////////////////////////////add by jimmy lee////////////////////////////////////////////////////////////////////////////
-(void)setSelectedDate:(NSDate *)date forBtn:(UIButton *)button{
    _currentButton = button;
    
    if (_currentButton == _stButton) {
        
        self.lastStartDateString = self.showStartDateLabel.text;
        
        self.startDate = date;
        if ([self.startDate compare:self.endDate] == NSOrderedDescending) {
            self.endDate = self.startDate;
        }
    } else {
        
        self.endDate = date;
        
    }
    
    [self.showEndDateLabel setText:[self stringFromdate:_endDate]];
    
    [self.showStartDateLabel setText:[self stringFromdate:_startDate]];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(WCStartEndDateViewValueChanged:)]) {
        
        [self.delegate performSelector:@selector(WCStartEndDateViewValueChanged:) withObject:self];
    }
    
}
////////////////////////////////////////////////////////add by jimmy lee////////////////////////////////////////////////////////////////////////////


- (NSString *)stringFromdate:(NSDate *)aDate {

    if (aDate) {
        NSString *dateString = [self.dateFormatter stringFromDate:aDate];
        
        if ([self.dateFormatter.dateFormat isEqualToString:@"yyyy-MM-dd"]) {
            
            NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:aDate];
            NSInteger weekday = [componets weekday];
            NSString *weekTitle = [NSString stringWithUTF8String:weekChar[weekday - 1]];
            
            return [NSString stringWithFormat:@"%@ (%@)", dateString, weekTitle];
        }else{
            return dateString;
        }
    }
    
    return nil;
}



- (NSString *)getMatchedDateString:(NSString *)dateString
{
    NSString *formatString = self.formatString;
    if ([dateString length] > [formatString length]) {
        NSString *subString = [dateString substringToIndex:[formatString length]];
        return subString;
    }
    
    return dateString;
}

#pragma mark - public API
- (void)setStartEndTitleByString:(NSString *)aString {
    NSArray *arr = [aString componentsSeparatedByString:@","];
    if ([arr count] > 1) {
        NSString *startString = [arr objectAtIndex:0];
        NSString *endString = [arr objectAtIndex:1];
        self.startTitle = NSLocalizedString(startString, nil);
        self.endTitle = NSLocalizedString(endString, nil);
    }else if ([arr count] == 1){
        self.startTitle = [arr firstObject];
        self.endTitle = [arr firstObject];
    }
}

- (void)setStartDateWithString:(NSString *)startDateString {
    
    NSString *dateString = [self getMatchedDateString:startDateString];
    
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    if (date) {
        self.startDate = date;
        self.showStartDateLabel.text = dateString;
    }else {
        self.startDate = nil;
        self.showStartDateLabel.text = nil;
    }
}

- (void)setEndDateWithString:(NSString *)endDateString {
    
    NSString *dateString = [self getMatchedDateString:endDateString];
    
    NSDate *date = [self.dateFormatter dateFromString:dateString];
    if (date) {
        self.endDate = date;
        self.showEndDateLabel.text = dateString;
    }else {
        self.endDate = nil;
        self.showEndDateLabel.text = nil;
    }
}

- (NSString *)getValueByString {

    NSString *startDateString = [self.dateFormatter stringFromDate:self.startDate];
    NSString *endDateString = [self.dateFormatter stringFromDate:self.endDate];
    return [NSString stringWithFormat:@"%@,%@", startDateString, endDateString];
}


/**
 *
 */
- (void) initMaxMinDate
{
    
    if (isFirstConfig) {
        isFirstConfig = NO;
        self.datePicker.minimumDate = self.sectionStartDate;
        self.datePicker.maximumDate = self.sectionEndDate;
        if ([self.startDate compare:self.sectionStartDate] == NSOrderedAscending) {
            self.startDate = self.sectionStartDate;
            self.endDate = self.sectionStartDate;
        }else if ([self.startDate compare:self.sectionEndDate] == NSOrderedDescending) {
            
            self.startDate = self.sectionEndDate;
            self.endDate = self.sectionEndDate;
        }
    }
}

@end
