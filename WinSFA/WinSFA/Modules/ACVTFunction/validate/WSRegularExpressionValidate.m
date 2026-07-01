//
//  WSRegularExpressionValidate.m
//  WinSFA
//
//  Created by yang on 16/10/25.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRegularExpressionValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSRegularExpressionValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if ([super executeValidate:buildinfo withWidget:widget]) {
        
        if ([[buildinfo getRegularExpression] length] > 0) {
            
            NSString  *value = (NSString *)[widget getResultDirectly];
            
            if ([value isKindOfClass:[NSString class]] && [value length] > 0) {
                
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", [buildinfo getRegularExpression]] evaluateWithObject:value] == YES) {
                    return YES;
                }else {
                    
                    NSString *msg = [NSString stringWithFormat:@"【%@】%@", [buildinfo getQuestName], NSLocalizedString(@"fill_not_correct", nil)];
                    
                    WSMessageObject *messageobject = [self getMessageObject:msg AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                    
                    [[WSMessageCenter shareInstance] showMessageView:messageobject];
                    
                    return NO;
                }
                
            }else {
                return YES;
            }
            
            
            
        }else {
            return YES;
        }
        
    }else{
        
        return NO;
    }
    return YES;
}

@end
