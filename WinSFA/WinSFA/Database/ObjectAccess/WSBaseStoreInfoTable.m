//
//  WSBaseStoreInfoTable.m
//  WinSFA
//
//  Created by HZH on 2017/11/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseStoreInfoTable.h"

@implementation WSBaseStoreInfoTable

static WSBaseStoreInfoTable *baseStoreInfoTable = nil;

+ (WSBaseStoreInfoTable *)sharedTable{
    if (baseStoreInfoTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreInfoTable = [[WSBaseStoreInfoTable alloc] init];
        });
    }
    return baseStoreInfoTable;
}

@end
