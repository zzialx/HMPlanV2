//
//  WSYMDateTextFieldPanel.m
//  WinSFA
//
//  Created by Stephanie on 16/6/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSYMDateTextFieldPanel.h"
#import "DateUtil.h"
#import "WSYMPickView.h"
#import "I_W_BuildInfo.h"

@interface WSYMDateTextFieldPanel ()<WSYMPickerViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) WSYMPickView *ymPickView;

@end

@implementation WSYMDateTextFieldPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.dateFormat = DATE_FORMAT_YEAR_MONTH;
        
        return self;
        
    }
    
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}

- (void)timeAction:(id)sender {
    [self showYMDatePickerView];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    [self showYMDatePickerView];
    
    return NO;
}


- (void)showYMDatePickerView
{
    WSPickerViewType pickerViewType = WSPickerViewTypeDateYearMonth;
    WSDatePickerSheetMode pickSheetMode = WSDatePickerSheetModeYM;
    
    NSString *acvtQstType = [xbuildInfo getAcvtQstType];
    if ([acvtQstType isEqualToString:COL_TYPYM]) {
        pickSheetMode = WSDatePickerSheetModeYM ;
        pickerViewType = WSPickerViewTypeDateYearMonth;
        self.dateFormat = DATE_FORMAT_YEAR_MONTH;
    }else if ([acvtQstType isEqualToString:COL_TYPY]){
        pickSheetMode = WSDatePickerSheetModeY;
        pickerViewType = WSPickerViewTypeDateYear;
        self.dateFormat = DATE_FORMAT_YEAR;
    }

    BOOL isAddDeleteButton = [[xbuildInfo getISRequire] isEqualToString:@"1"] ? NO : YES;
    WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:pickerViewType isAddDeleteButton:isAddDeleteButton];
    [pickerView setDateStr:self.textField.text];
    
    __weak typeof(self) weakSelf = self;
    [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
        if (!isOK) {
            return;
        }
        NSDate *date = (NSDate *)data;
        [weakSelf setDateContent:date];
    }];
}

- (void)valueChanged
{
    if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
        [self.delegate executeLuaScript:xbuildInfo widget:self];
        
    }
}

#pragma mark - WSYMPickViewDelegate Methods

- (void)pickView:(WSYMPickView *)pickView selectedDate:(NSString *)dateString {
    
//    self.textField.text = dateString;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *dateString = _ymPickView.selecteDate;
    
    switch (buttonIndex) {
        case 0:
            if (![self.textField.text isEqualToString:dateString]) {
                
                self.textField.text = dateString;
                
                [self valueChanged];
            }
            
            break;
        case 1:
            if (![self.textField.text isEqualToString:@""]) {
                self.textField.text = @"";
                [self valueChanged];
            }
            
            break;
            
        default:
            break;
    }
    self.ymPickView = nil;
}

@end
