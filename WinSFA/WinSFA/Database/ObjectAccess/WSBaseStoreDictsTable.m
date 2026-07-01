//
//  WSBaseStoreDictsTable.m
//  WinSFA
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDictsTable.h"

static WSBaseStoreDictsTable *baseStoreTable = nil;

@implementation WSBaseStoreDictsTable
+ (WSBaseStoreDictsTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseStoreDictsTable alloc] init];
        });
    }
    return baseStoreTable;
}
@end
