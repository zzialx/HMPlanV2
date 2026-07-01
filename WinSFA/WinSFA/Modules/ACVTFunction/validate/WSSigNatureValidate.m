//
//  WSSigNatureValidate.m
//  WinSFA
//
//  Created by mac on 17/3/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSigNatureValidate.h"
#import "I_W_BuildInfo.h"
#import "I_W_Validate.h"
#import "WSWidget.h"
#import "WSSignaturepanel.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSSigNatureValidate

-(BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget{
    
    if ([[buildinfo getISRequire] isEqualToString:@"1"]) {
        
        if ([widget isKindOfClass:[WSSignaturepanel class]]) {
            WSSignaturepanel * signature = (WSSignaturepanel *)widget;
            if (signature.imageIDArray.count > 0) {
                return YES;
            }else{
                NSString  *message =[NSString stringWithFormat:NSLocalizedString(@"%@  未填写!", nil),[buildinfo getQuestName]];
                WSMessageObject *messageobject = [self getMessageObject:message AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
                [[WSMessageCenter shareInstance] showMessageView:messageobject];
                return NO;
            }
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
