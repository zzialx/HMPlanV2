//
//  WSDateTextFieldPanel.h
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFiledPanel.h"


@interface WSDateTextFieldPanel : WSTextFiledPanel<UIActionSheetDelegate>

@property (nonatomic, strong) NSString *dateFormat;
@property (nonatomic , strong) NSDate * minDate;
@property (nonatomic , strong) NSDate * maxDate;

-(void)showDatePickerViewWithIndex:(UIDatePickerMode)pickertype;

-(void)setDateContent:(NSDate *)date;

@end
