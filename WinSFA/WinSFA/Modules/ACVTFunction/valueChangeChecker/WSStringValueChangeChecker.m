//
//  WSStringValueChangeChecker.m
//  WinSFA
//
//  Created by yang on 15/7/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStringValueChangeChecker.h"

@implementation WSStringValueChangeChecker

- (BOOL)checkValueIsChange:(NSObject<I_W_ValueChangeObject> *)object
{
    NSString *originValue;
    NSString *currentValue;
    
    if ([[object getOriginalValue] isKindOfClass:[NSString class]]) {
        originValue = (NSString *)[object getOriginalValue];
    }
    
    if ([[object getCurrentValue] isKindOfClass:[NSString class]]) {
        currentValue = (NSString *)[object getCurrentValue];
    }
    
    if ((originValue == nil || [originValue length] == 0) && (currentValue == nil || [currentValue length] == 0)) {
        return NO;
    }
    if ([originValue isEqualToString:currentValue]) {
        return NO;
    }
    
    return YES;
}

@end
