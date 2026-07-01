//
//  WSNestedAcvtValidate.m
//  WinSFA
//
//  Created by yang on 16/3/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSNestedAcvtValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
#import "WSANNestedAcvtPanel.h"

static NSString *const kShowActivityStyle = @"showActivityStyle";

static NSString *const kShowInMain = @"showInMain";



@implementation WSNestedAcvtValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    WSMessageObject *messageobject;
    
    if([[buildinfo getDisplayMode] containsString:kShowInMain] || [[buildinfo getDisplayMode] containsString:kShowActivityStyle]) { //这种情况特殊处理
        return  [self executeValidateWithAcvtShowInMain:buildinfo withWidget:widget];
        
    }else {
        if ([self isRequire:buildinfo]) {
            
            id  value = [widget getResultDirectly];
            
            if ([value isKindOfClass:[NSString class]]) {
                return [super executeValidate:buildinfo withWidget:widget];
            }else if ([value isKindOfClass:[NSArray class]]) {
                if (!value || [value count] == 0) {
                    NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),[buildinfo getQuestName]];
                    
                    messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                    
                    [[WSMessageCenter shareInstance] showMessageView:messageobject];
                    
                    return NO;
                }
            }
            
        }
    }
    
    
    
    return YES;
}




//MMSH-8185
- (BOOL)executeValidateWithAcvtShowInMain:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget {
    
    if ([self isRequire:buildinfo]) {
        
        if([widget isKindOfClass:[WSANNestedAcvtPanel class]]) {
            
            WSANNestedAcvtPanel *annest = (WSANNestedAcvtPanel *)widget;
            if (annest.acvtVCArray.count == 0) {
                NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),[buildinfo getQuestName]];
                
                WSMessageObject *messageobject;
                messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                
                return NO;
            }else {
                BOOL isOK = [annest executeValidateWithAcvtShowInMain];
                return isOK;
            }
            
        }
        
    }
    return YES;
}
@end
