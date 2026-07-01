//
//  WSBaseAcvtQstOptTable.m
//  WinSFA
//
//  Created by weida on 15/12/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseAcvtQstOptTable.h"

@implementation WSBaseAcvtQstOptTable

static WSBaseAcvtQstOptTable *baseStoreTable = nil;

+ (WSBaseAcvtQstOptTable  *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseAcvtQstOptTable alloc] init];
        });
    }
    return baseStoreTable;
}

@end
