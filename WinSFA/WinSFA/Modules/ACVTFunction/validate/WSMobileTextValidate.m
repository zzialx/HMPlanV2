//
//  WSMobileTextValidate.m
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMobileTextValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"



@implementation WSMobileTextValidate


-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo{
    
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{

    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if ([super executeValidate:buildinfo withWidget:widget]) {
        
        if ([[buildinfo getReadOnly] isEqualToString:@"1"]) {
            return YES;
        }
        
        NSObject  *value = [widget getResultDirectly];
        
        WSMessageObject *messageobject;
        
        NSMutableArray *btns =[[NSMutableArray alloc] init];
        [btns addObject:NSLocalizedString(@"confirm", nil)];
        
        if ([(NSString *)value length]>0) {
            
            NSString *reg = MULITY_MOBILE_PHONE_REG;
            if ([[buildinfo getRegularExpression] length] > 0) {
                reg = [buildinfo getRegularExpression];
            }
            
            if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg] evaluateWithObject:(NSString *)value] == YES) {
                
                return YES;
                
            }else{
                
                NSString *msg = [NSString stringWithFormat:@"【%@】%@", [buildinfo getQuestName], NSLocalizedString(@"fill_not_correct", nil)];
                messageobject = [self getMessageObject:msg AndTitle:nil andButtons:btns andDelegate:widget messageId:@"" messageType:MESSAGE_TYPE_OK];
                
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                
                return NO;
            }
        }
    }else{
        
        return NO;
    }
    return YES;
}


@end
