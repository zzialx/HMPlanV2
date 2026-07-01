//
//  WSBaseAcvtQstTable.m
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseAcvtQstTable.h"

@implementation WSBaseAcvtQstTable

static WSBaseAcvtQstTable *baseStoreTable = nil;

+ (WSBaseAcvtQstTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseAcvtQstTable alloc] init];
        });
    }
    return baseStoreTable;
}


@end
