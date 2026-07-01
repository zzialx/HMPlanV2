//
//  WSUserBehaviorStatisticsTable.m
//  WinSFA
//
//  Created by yang on 17/5/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSUserBehaviorStatisticsTable.h"

static WSUserBehaviorStatisticsTable *baseTable = nil;

@implementation WSUserBehaviorStatisticsTable

+ (WSUserBehaviorStatisticsTable *)sharedTable{
    if (baseTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseTable = [[WSUserBehaviorStatisticsTable alloc] init];
        });
    }
    return baseTable;
}

@end
