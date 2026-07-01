//
//  WSDateTimeTextFieldPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/19.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDateTimeTextFieldPanel.h"
#import "DateUtil.h"
#import "I_W_BuildInfo.h"

@implementation WSDateTimeTextFieldPanel
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dateFormat = DATE_FORMAT_CH_WITH_SEP_SEC;
        
        return self;
        
    }
    
    return nil;
}


//此问题只为显示，不需要编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
   // [super showDatePickerViewWithIndex:UIDatePickerModeDateAndTime];
    
    return NO;
}



@end
