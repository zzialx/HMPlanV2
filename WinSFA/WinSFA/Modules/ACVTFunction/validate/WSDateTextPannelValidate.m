//
//  WSDateTextPannelValidate.m
//  WinSFA
//
//  Created by mac on 17/9/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDateTextPannelValidate.h"
#import "WSDateTextFieldPanel.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
@implementation WSDateTextPannelValidate
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if (![super executeValidate:buildinfo withWidget:widget]) {
        return NO;
    }
    
    // SFA-13363  如果控件当前为只读 则不需要校验 
    if ([widget isKindOfClass:[WSDateTextFieldPanel class]] && ![[buildinfo getReadOnly] isEqualToString:@"1"] && [buildinfo getISRequire] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
        WSDateTextFieldPanel * dateTextField = (WSDateTextFieldPanel *)widget;
        NSString * value = (NSString *) [dateTextField getDisplayValuePresentation];
   
        NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
        [formatTime setDateFormat:@"yyyy-MM-dd"];

        NSString * minDateString = [formatTime stringFromDate:dateTextField.minDate];
        NSString * maxDateString = [formatTime stringFromDate:dateTextField.maxDate];
        
        NSString  *message ;
        if (value.length > 0 && minDateString.length > 0) {
            if ([value compare:minDateString] == NSOrderedAscending) {
                message =[NSString stringWithFormat:@"%@%@%@",[buildinfo getQuestName],NSLocalizedString(@"greater_or_equal", nil),minDateString];
            }
        }
        
        
        if (value.length > 0 && maxDateString.length > 0) {
            if ([value compare:maxDateString] == NSOrderedDescending) {
                 message =[NSString stringWithFormat:@"%@%@%@",[buildinfo getQuestName],NSLocalizedString(@"less_or_equal", nil),maxDateString];
            }
        }
        
        if (message.length > 0) {
            WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
            [[WSMessageCenter shareInstance] showMessageView:messageobject];
            return NO;
        }
        
        
    }
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo {
    return YES;
}
-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    return YES;
}

@end
