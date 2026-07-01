//
//  WSCheckBoxWithReasonValidate.m
//  WinSFA
//
//  Created by yang on 16/10/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCheckBoxWithReasonValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSCheckBoxWithReasonValidate


-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    WSMessageObject *messageobject;
    
    if ([self isRequire:buildinfo] && ![[buildinfo getIsHidden] isEqualToString:@"1"]) {
    
        NSString *resultDirectly = (NSString *)[widget getResultDirectly];
        
        LogInfo(@"resultDirectly %@",resultDirectly);
        
        BOOL result = YES;
        
        NSArray *valueArray = [resultDirectly componentsSeparatedByString:@";"];
        
        for (NSString *valueObj in valueArray) {
            NSArray *itemArray = [valueObj componentsSeparatedByString:@","];
            NSString *isSelect = nil;
            NSString *reasonStr = nil;
            
            if ([itemArray count] > 1) {
                isSelect = itemArray[1];
            }
            if ([itemArray count] > 2) {
                reasonStr = itemArray[2];
            }
            
            if ([isSelect isEqualToString:@"0"] && !reasonStr) {
                result = NO;
            }
            
            if (!result) {
                NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"%@: 未选中事项请填写原因", nil),[buildinfo getQuestName]];
                
                messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                
                return NO;
            }
        }
        
    }
    
    return YES;
}

@end
