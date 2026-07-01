//
//  WSVisitedMenuArray.m
//  WinSFA
//
//  Created by yang on 15/11/27.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSVisitedMenuArray.h"
#import "WSVisitedMenuBean.h"

@implementation WSVisitedMenuArray

- (NSString *)getDefaultParseKey
{
    return VISITED_MENU;
}

- (Class)getBeanSubclass
{
    return [WSVisitedMenuBean class];
}

- (BOOL)isFuncsCodeVisited:(NSString *)fc storeId:(NSString *)storeId parentFuncsCode:(NSString *)parentFc
{
    BOOL result = NO;
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    for (WSVisitedMenuBean *visitMenu in self.beanArray) {
        if ([visitMenu.store_id isEqualToString:storeId] &&
            [visitMenu.empId isEqualToString:empId] &&
            [visitMenu.func_code isEqualToString:fc] &&
            [visitMenu.pfc isEqualToString:parentFc]) {
            result = YES;
            break;
        }
    }
    
    return result;
}

@end
