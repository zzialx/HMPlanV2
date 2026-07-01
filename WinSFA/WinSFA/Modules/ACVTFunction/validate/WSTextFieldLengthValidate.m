//
//  WSTextFieldLengthValidate.m
//  WinSFA
//
//  Created by xiajl on 15/6/3.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTextFieldLengthValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSTextFieldLengthValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo{
    
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    
    
    return YES;
}


-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if ([super executeValidate:buildinfo withWidget:widget]) {
        
        NSObject  *value = [widget getResultDirectly];
        NSString *textString = (NSString *)value;
        if ([[buildinfo getMlen] integerValue] <= 0 || ([[buildinfo getMlen] integerValue] > 0 && [textString length] <= [[buildinfo getMlen] integerValue])) {
            return YES;
        }else{
            [self showContentTemplateOfOK:[NSString stringWithFormat:@"【%@】%@",[buildinfo getQuestName],NSLocalizedString(@"input_digits_max", @"")] withWidget:widget];
            return NO;
        }
    }else{
        
        return NO;
    }
    return YES;
}


- (void) showContentTemplateOfOK:(NSString *)content withWidget:(WSWidget *)widget
{
    NSMutableArray *btns =[[NSMutableArray alloc] init];
    [btns addObject:NSLocalizedString(@"confirm", nil)];
    WSMessageObject *messageobject = [self getMessageObject:content AndTitle:nil andButtons:btns andDelegate:widget messageId:@"" messageType:MESSAGE_TYPE_OK];
    [[WSMessageCenter shareInstance] showMessageView:messageobject];
    
}
@end
