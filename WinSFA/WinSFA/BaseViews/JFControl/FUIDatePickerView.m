//
//  FUITimePickerView.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "FUIDatePickerView.h"

#define TITLE_WIDTH     (150)
#define PADDING_CONTENT (CGRectMake(0, 2, 2, 2))    //left, top, right, bottom

@interface FUIDatePickerView() <UITextFieldDelegate> {
    FRefreshDateBlock refreshBlock;
}

@property (strong, nonatomic) UITextField   *textFieldEnterDate;
@property (nonatomic, strong) NSString      *acvtQstId;

//@property (strong, nonatomic) IBOutlet UIPickerView *customPicker;
@end

@implementation FUIDatePickerView

- (id)initWithFrame:(CGRect)frame
     withPickerMode:(UIDatePickerMode)mode
       withTitleStr:(NSString*)title
  withDateNormalStr:(NSString*)dateStr
      withAcvtQstId:(NSString*)idStr
          withBlock:(FRefreshDateBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        refreshBlock = block;
        self.acvtQstId = idStr;
        CGFloat height = CGRectGetHeight(frame) - CGRectGetMinY(PADDING_CONTENT) - CGRectGetHeight(PADDING_CONTENT);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        if (title) {
            [titleLabel setFrame:CGRectMake(CGRectGetMinX(PADDING_CONTENT),
                                            CGRectGetMinY(PADDING_CONTENT),
                                            TITLE_WIDTH,
                                            height)];
            [titleLabel setText:title];
            [titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
            [titleLabel setBackgroundColor:kCLEAR_COLOR_value];
            [self addSubview:titleLabel];
        }
        
        _textFieldEnterDate = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(PADDING_CONTENT) + CGRectGetWidth(titleLabel.frame),
                                                                            CGRectGetMinY(PADDING_CONTENT),
                                                                            CGRectGetWidth(frame) - CGRectGetMaxX(titleLabel.frame) - CGRectGetWidth(PADDING_CONTENT),
                                                                            height)];
        _textFieldEnterDate.textAlignment = NSTextAlignmentLeft;
        _textFieldEnterDate.backgroundColor = [UIColor whiteColor];
        [_textFieldEnterDate setBorderStyle:UITextBorderStyleRoundedRect];
        [_textFieldEnterDate setBorderStyle:UITextBorderStyleNone];
        [_textFieldEnterDate setFont:[UIFont systemFontOfSize:UI_Font]];
        if (dateStr) {
            [_textFieldEnterDate setText:dateStr];
        }
        _textFieldEnterDate.delegate = self;
        [self addSubview:_textFieldEnterDate];
        
        _customDatePicker = [[UIDatePicker alloc] init];
        _customDatePicker.datePickerMode = mode;
        _customDatePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier: [UIDevice sysLanguage]];
        if (@available(iOS 13.4, *)) {
            _customDatePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
    }
    return self;
}

- (void) changeInteractionEnabled:(BOOL) isEnabled
{
    [self.textFieldEnterDate setUserInteractionEnabled: isEnabled];
    if (isEnabled) {
        [self.textFieldEnterDate setTextColor:[UIColor blackColor]];
    }else {
        [self.textFieldEnterDate setTextColor:[UIColor colorWithHexString:@"#888888"]];
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self endEditing:YES];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    WSPickerViewType pickerViewType = [WSPickerView convertToPickerViewTypeFromDatePickerMode:self.customDatePicker.datePickerMode];
    
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return  YES;
}

- (void)setDateContent:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    if (UIDatePickerModeTime == self.customDatePicker.datePickerMode) {
        formatter.dateFormat = @"HH:mm:";
    }else {
        formatter.dateFormat = @"yyyy-MM-dd";
    }
    NSString *timestamp = [formatter stringFromDate:self.customDatePicker.date];
    if (UIDatePickerModeTime == self.customDatePicker.datePickerMode) {
        //        formatter.dateFormat = @"ss";
        timestamp = [NSString stringWithFormat:@"%@00", timestamp]; //[formatter stringFromDate:[NSDate date]]];
    }
    if (![self.textFieldEnterDate.text isEqualToString:timestamp] && refreshBlock) {
        refreshBlock(self.acvtQstId, timestamp);
    }
    self.textFieldEnterDate.text = timestamp;
}


@end
