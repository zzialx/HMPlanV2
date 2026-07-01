//
//  WSConfigParamHelper.m
//  WinSFA
//
//  Created by yang on 2017/7/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSConfigParamHelper.h"

@implementation WSConfigParamHelper

+ (NSString *)getParamByKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (BOOL)getIsCheckLeaveStore {
    NSString *string = [WSConfigParamHelper getParamByKey:CHECK_LEAVE_STORE];
    if ([string isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

@end
