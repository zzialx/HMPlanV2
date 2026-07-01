//
//  WSNumberTextVaildate.m
//  WinSFA
//
//  Created by winchannel on 15/4/1.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSNumberTextVaildate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"


@implementation WSNumberTextVaildate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo{
    
    
    
    return YES;
}

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value{
    
    
    return YES;
}

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget
{
    if([super executeValidate:buildinfo withWidget:widget] == YES)
    {
        WSMessageObject *messageobject;
        NSMutableArray *btns = [[NSMutableArray alloc] init];
        [btns addObject:NSLocalizedString(@"confirm", nil)];
        
        NSString *value = (NSString *)[widget getResultDirectly];
        if([(NSString *)value length] > 0)
        {
            if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", NUMERIC_REG] evaluateWithObject:value] == YES)
            {
                // YIHAIKERRY-3836
                if([buildinfo getSnumx] && [value integerValue] < [[buildinfo getSnumx] integerValue]) {
                    NSString *title = [NSString stringWithFormat:@"最小值只能输入:%@", [buildinfo getSnumx]];
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    return NO;
                }
                return YES;
            } else {
                messageobject = [self getMessageObject:@"请输入正确的数字格式！" AndTitle:@"" andButtons:btns andDelegate:widget messageId:@"" messageType:MESSAGE_TYPE_OK];
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                return NO;
            }
        }
    }
    else
        return NO;
    
    return YES;
}
@end
