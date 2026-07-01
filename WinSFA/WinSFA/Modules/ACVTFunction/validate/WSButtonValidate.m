//
//  WSButtonValidate.m
//  WinSFA
//
//  Created by HZH on 16/12/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSButtonValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSButtonValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    WSMessageObject *messageobject;
    
    NSString  *value = (NSString *)[widget getResultDirectly];
    
    if ([self isRequire:buildinfo] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
        
        if ([(NSString *)value length]!=0 && [(NSString *)value isEqualToString:@"0"]) {
            
            NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"%@ 未填写", nil),[buildinfo getQuestName]];
            
            messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
            
            [[WSMessageCenter shareInstance] showMessageView:messageobject];
            
            return NO;
        }
    }
    
    return YES;
}

@end
