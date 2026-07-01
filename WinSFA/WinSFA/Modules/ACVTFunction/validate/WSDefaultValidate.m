//
//  WSDefaultValidate.m
//  WinSFA
//
//  Created by winchannel on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDefaultValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
@implementation WSDefaultValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo{
    
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{

    WSMessageObject *messageobject;
    
    NSString  *value = (NSString *)[widget getResultDirectly];
    
    if ([self isRequire:buildinfo] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
        // SFA-18599 校验的时候需要忽略空格回车
        if (value==nil  ||  [(NSString *)value length]==0 || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        
            NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"not_filled", nil),[buildinfo getQuestName]];
            
            messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
            
            [[WSMessageCenter shareInstance] showMessageView:messageobject];
            
            return NO;
        }
    }
    
    return YES;
}

@end
