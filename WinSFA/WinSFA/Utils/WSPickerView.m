//
//  WSPickerView.m
//  WinSFA
//
//  Created by Alicia on 16/11/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPickerView.h"
#import "WSYMPickView.h"
#import "NSString+Additions.h"

static const CGFloat kContentHeight = 216;
static const CGFloat kViewCornerRadius = 10;
#define kContentWidthPad     (SCREEN_WIDTH * 0.3)
#define kActionHeight       (INTERFACE_IS_PHONE ? 34 : 44)
#define UI_Btn_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 14.0f : 16.0f)
#define kComponentsTitleHeight  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 20.0f : 30.0f)
#define UI_Title_Font  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 15.0f : 17.0f)

@interface WSPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

//@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) WSYMPickView *ymPickView;
@property (nonatomic, strong) UIView *actionView;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic , strong) NSDate * minDay;
@property (nonatomic , strong) NSDate * maxDay;

@property (nonatomic , strong) NSArray *titleArray;
@property (nonatomic , assign) BOOL isShowContentTitle;
@property (nonatomic, assign) CGFloat contentTitleHeight;

@end

@implementation WSPickerView



- (instancetype) init {
    self = [super init];
    if (self) {
        [self setupViews:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews:frame];
    }
    return self;
}

- (void)setupViews:(CGRect)frame {
    self.frame = frame;
    self.selectedArray = [NSMutableArray array];
    self.contentHeight = kContentHeight;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)];
    [self addGestureRecognizer:tap];
}


#pragma mark - Public Method
+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type isAddDeleteButton:(BOOL)isAddDeleteButton {
    return  [self showPickerViewInWindowWithType:type andTitleArray:nil isAddDeleteButton:isAddDeleteButton];
}


+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type  {
    return [self showPickerViewInWindowWithType:type andTitleArray:nil isAddDeleteButton:NO];
}

+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray {
    return [self showPickerViewInWindowWithType:type andTitleArray:titleArray isAddDeleteButton:NO];
}

+ (WSPickerView *)showPickerViewInWindowWithType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray isAddDeleteButton:(BOOL)isAddDeleteButton {
    UIView * view = [UIApplication sharedApplication].delegate.window;
    return [self showPickerViewInView:view withType:type andTitleArray:titleArray isAddDeleteButton:isAddDeleteButton];
}

+ (WSPickerView *)showPickerViewInVCTop:(UIViewController *)VC withType:(WSPickerViewType)type {
    UIView * view;
    if (VC.tabBarController) {
        view = VC.tabBarController.view;
    }else if (VC.navigationController){
        view = VC.navigationController.view;
    }else{
        view = VC.view;
    }
    
    return [self showPickerViewInView:view withType:type];
}

+ (WSPickerView *)showPickerViewInView:(UIView *)view withType:(WSPickerViewType)type {
    return [self showPickerViewInView:view withType:type andTitleArray:nil isAddDeleteButton:NO];
}

+ (WSPickerView *)showPickerViewInView:(UIView *)view withType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray {
    return [self showPickerViewInView:view withType:type andTitleArray:titleArray isAddDeleteButton:NO];
}

+ (WSPickerView *)showPickerViewInView:(UIView *)view withType:(WSPickerViewType)type andTitleArray:(NSArray *)titleArray isAddDeleteButton:(BOOL)isAddDeleteButton {
    WSPickerView * pickerView = [[WSPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    pickerView.isAddDeleteButton = isAddDeleteButton;
    pickerView.pickerType = type;
    [pickerView showInView:view andTitleArray:titleArray];
    return pickerView;
}

+ (WSPickerViewType)convertToPickerViewTypeFromDatePickerMode:(UIDatePickerMode)mode {
    WSPickerViewType pickerViewType;
    switch (mode) {
        case UIDatePickerModeTime:
            pickerViewType = WSPickerViewTypeTime;
            break;
        case UIDatePickerModeDate:
            pickerViewType = WSPickerViewTypeDate;
            break;
        case UIDatePickerModeDateAndTime:
            pickerViewType = WSPickerViewTypeDateAndTime;
            break;
        case UIDatePickerModeCountDownTimer:
            pickerViewType = WSPickerViewTypeCountDownTimer;
            break;
        default:
            pickerViewType = WSPickerViewTypeDate;
            break;
    }
    return pickerViewType;
}

+ (WSPickerViewType)convertToPickerViewTypeFromDatePickerLabelMode:(WSDatePickerLabelMode)mode {
    WSPickerViewType pickerViewType;
    switch (mode) {
        case WSDatePickerLabelModeTime:
            pickerViewType = WSPickerViewTypeTime;
            break;
        case WSDatePickerLabelModeYM:
            pickerViewType = WSPickerViewTypeDateYearMonth;
            break;
        default:
            pickerViewType = WSPickerViewTypeDate;
            break;
    }
    return pickerViewType;
}

- (void)setPickerType:(WSPickerViewType)pickerType{
    _pickerType = pickerType;
    
    if (_datePicker) {
        [_datePicker removeFromSuperview];
    }
    if (_ymPickView) {
        [_ymPickView removeFromSuperview];
    }
    if (_pickerView) {
        [_pickerView removeFromSuperview];
    }
    
    switch (pickerType) {
        case WSPickerViewTypeTime:
            self.datePicker.datePickerMode = UIDatePickerModeTime;
            [self.actionView addSubview:self.datePicker];
            break;
        case WSPickerViewTypeDate:
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            [self.actionView addSubview:self.datePicker];
            break;
        case WSPickerViewTypeDateAndTime:
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            [self.actionView addSubview:self.datePicker];
            break;
        case WSPickerViewTypeCountDownTimer:
            self.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
            [self.actionView addSubview:self.datePicker];
            break;
        case WSPickerViewTypeDatas:
            [self.actionView addSubview:self.pickerView];
            break;
        case WSPickerViewTypeDateYear:
            self.ymPickView.pickeMode = WSDatePickerSheetModeY;
            [self.actionView addSubview:self.ymPickView];
            break;
        case WSPickerViewTypeDateYearMonth:
            self.ymPickView.pickeMode = WSDatePickerSheetModeYM;
            [self.actionView addSubview:self.ymPickView];
            break;
        default:
            break;
    }
}

//- (void)setDataSources:(NSArray *)dataSources{
//    // 待实现
//    if (dataSources) {
//        self.dataSources = dataSources;
//    }
//    
//}

- (void)setDefaultSelectedData:(NSArray *)selectedDataArray
{
    if (selectedDataArray && selectedDataArray.count > 0) {
        self.selectedArray = [NSMutableArray arrayWithArray:selectedDataArray];
        
        for (NSInteger i = 0; i < selectedDataArray.count; i ++) {
            NSString *selectedNumStr = [selectedDataArray objectAtIndex:i];
//            [self pickerView:self.pickerView didSelectRow:[selectedNumStr integerValue] inComponent:i];
            [self.pickerView selectRow:[selectedNumStr integerValue] inComponent:i animated:NO];
        }
    }

}

#pragma mark - Property
- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    [self.datePicker setDate:date animated:animated];
}

- (void)setDateStr:(NSString *)dateStr {
    [self.ymPickView setNowDateStr:dateStr];
}

- (void)setMinimumDate:(NSDate *)minimumDate{
    if (self.pickerType == WSPickerViewTypeDateYearMonth || self.pickerType == WSPickerViewTypeDateYear) {
        [self.ymPickView setMinDate:minimumDate];
    }else {
        [self.datePicker setMinimumDate:minimumDate];
    }
}
- (NSDate *)minimumDate{
    if (self.pickerType == WSPickerViewTypeDateYearMonth || self.pickerType == WSPickerViewTypeDateYear) {
        return self.ymPickView.minDate;
    } else {
        return self.datePicker.minimumDate;
    }
}

- (void)setMaximumDate:(NSDate *)maximumDate{
    if (self.pickerType == WSPickerViewTypeDateYearMonth || self.pickerType == WSPickerViewTypeDateYear) {
        [self.ymPickView setMaxDate:maximumDate];
    }else {
        [self.datePicker setMaximumDate:maximumDate];
    }
}

- (NSDate *)maximumDate{
    if (self.pickerType == WSPickerViewTypeDateYearMonth || self.pickerType == WSPickerViewTypeDateYear) {
         return self.ymPickView.maxDate;
    } else {
        return self.datePicker.maximumDate;
    }
}

- (void)setCountDownDuration:(NSTimeInterval)countDownDuration{
    [self.datePicker setCountDownDuration:countDownDuration];
}

- (NSTimeInterval)countDownDuration{
    return self.datePicker.countDownDuration;
}

- (void)setMinuteInterval:(NSInteger)minuteInterval{
    [self.datePicker setMinuteInterval:minuteInterval];
}

- (NSInteger)minuteInterval{
    return self.datePicker.minuteInterval;
}


#pragma mark - Private Method

- (void)showInView:(UIView *)view{
    [self showInView:view andTitleArray:nil];
}

- (void)showInView:(UIView *)view andTitleArray:(NSArray *)titleArray {
    
    if (titleArray && titleArray.count > 0) {
        _titleArray = titleArray;
        _isShowContentTitle = YES;
    }else{
        _isShowContentTitle = NO;
    }
    
    _contentTitleHeight = _isShowContentTitle ? kComponentsTitleHeight : 0;
    
    CGFloat height = kActionHeight + self.contentHeight + _contentTitleHeight;
    
    [view addSubview:self];
    
    if (INTERFACE_IS_PHONE) {
        self.backgroundColor = [UIColor clearColor];
        self.actionView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        
        [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
            self.backgroundColor = POP_WINDOW_BG_COLOR;
            
            self.actionView.frame = CGRectMake(0, SCREEN_HEIGHT - height, SCREEN_WIDTH, height);
        }];
    } else {
        self.backgroundColor = POP_WINDOW_BG_COLOR;
        self.actionView.frame = CGRectMake((SCREEN_WIDTH - kContentWidthPad) / 2, (SCREEN_HEIGHT - height) / 2, kContentWidthPad, height);
    }
}

- (void)removeFromSuperview{
    if (INTERFACE_IS_PHONE) {
        [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
            self.backgroundColor = [UIColor clearColor];
            
            self.actionView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, kActionHeight + self.contentHeight);
            
        } completion:^(BOOL finished) {
            [super removeFromSuperview];
        }];
    } else {
        [super removeFromSuperview];
    }
}

-(void)deleteAction:(UIButton *)sender{
   
    if (self.didSelectBlock){
        self.didSelectBlock(nil,YES);
    }
    [self removeFromSuperview];
}

- (void)okAction:(UIButton *)sender {
    
    if (self.didSelectBlock) {
        if (self.pickerType == WSPickerViewTypeDatas) {
            self.didSelectBlock(self.selectedArray, YES);
        }else {
            NSDate *selecteDate = nil;
            if (self.pickerType == WSPickerViewTypeDateYearMonth) {
                NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
                [formatter setDateFormat:@"yyyy-MM"];
                selecteDate = [formatter  dateFromString:self.ymPickView.selecteDate];
            } else if (self.pickerType == WSPickerViewTypeDateYear) {
                NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
                [formatter setDateFormat:@"yyyy"];
                selecteDate = [formatter  dateFromString:self.ymPickView.selecteDate];
            } else {
                selecteDate = self.datePicker.date;
                
                if (self.minDay && self.maxDay) {
                    NSDateFormatter *dateFromate = [NSDateFormatter standardDateFormatter];
                    [dateFromate setDateFormat:@"yyyy-MM-dd"];
                    NSString *tips = nil;
                    
                    if ([[dateFromate stringFromDate:selecteDate] compare:[dateFromate stringFromDate:self.maxDay]] == NSOrderedDescending) {
                        
                        NSString *maxDateStr = [dateFromate stringFromDate:self.maxDay];
                        tips = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"必须小于等于", nil),maxDateStr];
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:tips tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.0f];
                        
                        return;
                    }
                    
                    if ([[dateFromate stringFromDate:selecteDate] compare:[dateFromate stringFromDate:self.minDay]] == NSOrderedAscending){
                        NSString *minDateStr = [dateFromate stringFromDate:self.minDay];
                        tips = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"必须大于等于", nil),minDateStr];
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:tips tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:2.0f];
                        return;
                        
                    }
                }
               
            }
            self.didSelectBlock(selecteDate,YES);
        }
    }
    [self removeFromSuperview];
}

- (void)cancelAction:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)datePickerAction:(UIDatePicker *)picker{
    if (self.didSelectBlock) {
        self.didSelectBlock(picker.date, NO);
    }
}

#pragma mark - Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (self.dataSources) {
        return self.dataSources.count;
    } else {
        return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (self.dataSources[component]) {
        NSArray * arr = self.dataSources[component];
        return arr.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray * arr = self.dataSources[component];
    return [arr objectAtIndex:row];
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSArray *arr = self.dataSources[component];
//    NSString *titleStr = [arr objectAtIndex:row];
//
//    CGFloat fontSize = 15.0;
//
//    if (component == 0 || component == 3) {
//        fontSize = 10.0;
//    }
//
//    NSAttributedString *unitAttriString = [[NSAttributedString alloc]initWithString:titleStr attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],                               NSFontAttributeName:[UIFont systemFontOfSize:fontSize]                                                                                                  }];
//
//    return unitAttriString;
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    // reset split line color
//    for(UIView *singleLine in pickerView.subviews)
//    {
//        if (singleLine.frame.size.height < 1)
//        {
//            singleLine.backgroundColor = [UIColor grayColor];
//        }
//    }
    
    // reset every single row UILabel
    UILabel *pickerLabel = (UILabel*)view;
    
    if (!pickerLabel){
        
        pickerLabel = [[UILabel alloc] init];
        // Setup label properties - frame, font, colors etc
        //adjustsFontSizeToFitWidth property to YES
        [pickerLabel setTextColor:[UIColor blackColor]];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:22.0]];
    }
    
    // Fill the label text here
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];

    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    NSArray * arr = self.dataSources[component];
//
//
//
//    [self.selectedArray replaceObjectAtIndex:component withObject:[arr objectAtIndex:row]];
//
//    if (self.didSelectBlock) {
//           self.didSelectBlock(self.selectedArray, NO);
//    }
    
    [self validateStartAndEndTimeWithRow:row andComponent:component];
}

// 验证结束时间不能小于开始时间
- (BOOL)validateStartAndEndTimeWithRow:(NSInteger)row andComponent:(NSInteger)component
{
    NSArray * arr = self.dataSources[component];
    
    NSString *oldValue = [self.selectedArray objectAtIndex:component];

    [self.selectedArray replaceObjectAtIndex:component withObject:[arr objectAtIndex:row]];

    
    if ([[self.selectedArray objectAtIndex:0] integerValue] > [[self.selectedArray objectAtIndex:2] integerValue]) {
        [self.pickerView selectRow:[oldValue integerValue] inComponent:component animated:NO];
        [self.selectedArray replaceObjectAtIndex:component withObject:oldValue];
        [self showErrorHud];
    }else if ([[self.selectedArray objectAtIndex:0] integerValue] == [[self.selectedArray objectAtIndex:2] integerValue]) {
        
        if ([[self.selectedArray objectAtIndex:1] integerValue] >= [[self.selectedArray objectAtIndex:3] integerValue]) {
            [self.pickerView selectRow:[oldValue integerValue] inComponent:component animated:NO];
            [self.selectedArray replaceObjectAtIndex:component withObject:oldValue];
            [self showErrorHud];
        }else{
            return YES;
        }
    }else{
        return YES;
    }
    
    return NO;
}

// 验证失败弹出提示
- (void)showErrorHud
{
    NSString *errorString = NSLocalizedString(@"time_check_error_lable",nil);
    
    [MBProgressHUD showHUDAddedTo:self withText:errorString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.0];
    
}

#pragma mark - Getters and Setters
- (UIView *)actionView {
    if (!_actionView) {
        _actionView = [[UIView alloc] init];
        _actionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_actionView];
        if (INTERFACE_IS_PAD) {
            _actionView.layer.cornerRadius = kViewCornerRadius;
            _actionView.layer.masksToBounds = YES;
        }
        
        UIFont *btnFont = [UIFont fontWithName:@"PingFangSC-Regular" size:UI_Btn_Font];
        UIColor *mainTintColor = [UIColor colorForKey:@"MainTintColor"];
        CGFloat colNunber = self.isAddDeleteButton ? 3:2;
        UIButton * cancelButton = [[UIButton alloc] init];
        NSString *cancelStr = NSLocalizedString(@"cancel_label", nil);
        if (INTERFACE_IS_PHONE) {
            CGSize cancelSize = [cancelStr ws_sizeWithFont:btnFont constrainedToHeight:kActionHeight];
            cancelSize.width += MAIN_PADDING * 2;
            [cancelButton setFrame:CGRectMake(0, 5, cancelSize.width, kActionHeight)];
        } else {
            CGFloat width = kContentWidthPad / colNunber;
            [cancelButton setFrame:CGRectMake(0, self.contentHeight, width, kActionHeight)];
            [self addTopBorderToView:cancelButton];
        }
        [cancelButton setTitle:cancelStr forState:UIControlStateNormal];
        [cancelButton setTitleColor:mainTintColor forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:btnFont];
        [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        [_actionView addSubview:cancelButton];
       
        if (self.isAddDeleteButton) {
            
            UIButton * deleteButton = [[UIButton alloc] init];
            NSString *deleteStr = NSLocalizedString(@"delete_label", nil);
            if (INTERFACE_IS_PHONE) {
                CGSize cancelSize = [cancelStr ws_sizeWithFont:btnFont constrainedToHeight:kActionHeight];
                cancelSize.width += MAIN_PADDING * 2;
                [deleteButton setFrame:CGRectMake((SCREEN_WIDTH-cancelSize.width)/2, 5, cancelSize.width, kActionHeight)];
            } else {
                CGFloat width = kContentWidthPad / colNunber;
                [deleteButton setFrame:CGRectMake(width+1, self.contentHeight, width-2, kActionHeight)];
                [self addTopBorderToView:deleteButton];
                [self addLeftBorderToView:deleteButton];
            }
            [deleteButton setTitle:deleteStr forState:UIControlStateNormal];
            [deleteButton setTitleColor:mainTintColor forState:UIControlStateNormal];
            [deleteButton.titleLabel setFont:btnFont];
            [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [_actionView addSubview:deleteButton];

        }
       
        
        
        
        UIButton * okButton = [[UIButton alloc] init];
        NSString *okStr = NSLocalizedString(@"confirm", nil);
        if (INTERFACE_IS_PHONE) {
            CGSize okSize = [okStr ws_sizeWithFont:btnFont constrainedToHeight:kActionHeight];
            okSize.width += MAIN_PADDING * 2;
            [okButton setFrame:CGRectMake(SCREEN_WIDTH - okSize.width, 5, okSize.width, kActionHeight)];
        } else {
            CGFloat width = kContentWidthPad / colNunber;
            [okButton setFrame:CGRectMake(self.isAddDeleteButton ? 2*width :width, self.contentHeight, width, kActionHeight)];
            [self addLeftBorderToView:okButton];
            [self addTopBorderToView:okButton];
        }
        [okButton setTitle:okStr forState:UIControlStateNormal];
        [okButton.titleLabel setFont:btnFont];
        [okButton setTitleColor:mainTintColor forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
        [_actionView addSubview:okButton];
        
        if (_titleArray && _titleArray.count > 0) {
            for (NSInteger i = 0; i < _titleArray.count; i ++) {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/_titleArray.count * i, kActionHeight, SCREEN_WIDTH/_titleArray.count, _contentTitleHeight)];
                titleLabel.text = [_titleArray objectAtIndex:i];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.font = FONT_SIZE_PINGFANG_MEDIUM(UI_Title_Font);
                
                [_actionView addSubview:titleLabel];
            }

        }
        
    }
    return _actionView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGRect viewFrame;
        if (INTERFACE_IS_PHONE) {
            viewFrame = CGRectMake(0, kActionHeight + _contentTitleHeight, self.width, self.contentHeight);
        } else {
            viewFrame = CGRectMake((SCREEN_WIDTH - kContentWidthPad) / 2, _contentTitleHeight, kContentWidthPad, self.contentHeight);
        }
        _pickerView = [[UIPickerView alloc] initWithFrame:viewFrame];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}


- (UIDatePicker *)datePicker {
    
    if (!_datePicker) {
        
        CGRect viewFrame = [self getPickerFrame];
        _datePicker = [[UIDatePicker alloc] initWithFrame:viewFrame];
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        _datePicker.date = [NSDate date];
        [_datePicker addTarget:self action:@selector(datePickerAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (WSYMPickView *)ymPickView {
    if (!_ymPickView) {
        CGRect viewFrame = [self getPickerFrame];
        _ymPickView = [[WSYMPickView alloc] initWithFrame:viewFrame];
        _ymPickView.backgroundColor = [UIColor whiteColor];
    }
    return _ymPickView;
}

- (CGRect)getPickerFrame {
    CGRect viewFrame;
    if (INTERFACE_IS_PHONE) {
        viewFrame = CGRectMake(0, kActionHeight, SCREEN_WIDTH, self.contentHeight);
    } else {
        viewFrame = CGRectMake(0, 0, kContentWidthPad, self.contentHeight);
    }
    return viewFrame;
}

- (void)addLeftBorderToView:(UIView *)view {
    CGRect frame = view.frame;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 1, frame.size.height);
    layer.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [view.layer addSublayer:layer];
}

- (void)addTopBorderToView:(UIView *)view {
    CGRect frame = view.frame;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, frame.size.width, 1);
    layer.backgroundColor =  DETAIL_SEPERATE_LINE_COLOR.CGColor;
    [view.layer addSublayer:layer];
}

@end
