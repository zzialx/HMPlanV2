//
//  WSArrayValueChangeChecker.m
//  WinSFA
//
//  Created by yang on 15/7/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSArrayValueChangeChecker.h"

@implementation WSArrayValueChangeChecker

- (BOOL)checkValueIsChange:(NSObject<I_W_ValueChangeObject> *)object
{
    NSArray *originValue;
    NSArray *currentValue;
  
    if ([[object getOriginalValue] isKindOfClass:[NSArray class]]) {
        originValue = (NSArray *)[object getOriginalValue];
    }
    
    if ([[object getCurrentValue] isKindOfClass:[NSArray class]]) {
        currentValue = (NSArray *)[object getCurrentValue];
    }
    
    if ((originValue == nil || [originValue count] == 0) && (currentValue == nil || [currentValue count] == 0)) {
        return NO;
    }
    
    if([originValue count] == [currentValue count]) {
        BOOL isEqual = YES;
        for (id obj in originValue) {
            if (![currentValue containsObject:obj]) {
                isEqual = NO;
                break;
            }
        }
        
        if (isEqual) {
            return NO;
        }
    }
    
    return YES;
}

@end
