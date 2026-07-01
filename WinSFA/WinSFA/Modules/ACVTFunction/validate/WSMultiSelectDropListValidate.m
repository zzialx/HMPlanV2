//
//  WSMultiSelectDropListValidate.m
//  WinSFA
//
//  Created by Alicia on 2017/6/29.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMultiSelectDropListValidate.h"
#import "WSWidget.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"

@implementation WSMultiSelectDropListValidate

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget {
    if (![super executeValidate:buildinfo withWidget:widget]) {
        return NO;
    }
    
    NSInteger min = [[buildinfo getSnumx] integerValue];
    if (min == 0) {
       return YES;
    }
    
    NSString *resultDirectly = (NSString *)[widget getResultDirectly];
    
    NSArray *valueArray = [resultDirectly componentsSeparatedByString:@";"];
    NSInteger count = valueArray.count;
    
    if (min > 0 && count < min && !widget.isHidden) {
        NSString *tips = NSLocalizedString(@"select_the_minimum_number_is", nil);
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"【%@】%@:%ld", nil),[buildinfo getQuestName], tips, (long)min];
        
        WSMessageObject *messageobject = [self getMessageObject:msg AndTitle:@"" andButtons:nil andDelegate:nil messageId:@"" messageType:MESSAGE_TYPE_AUTO_HIDE_FAILED];
        [[WSMessageCenter shareInstance] showMessageView:messageobject];
        return NO;
    }
    
    return YES;
}


@end
