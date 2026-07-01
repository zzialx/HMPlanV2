//
//  WSBaseFunsTable.m
//  WinSFA
//
//  Created by weida on 15/12/25.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseFunsTable.h"

//#define kbaseFunKey_spec        (@"spec")

@implementation WSBaseFunsTable

static WSBaseFunsTable *baseStoreTable = nil;

+ (WSBaseFunsTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseFunsTable alloc] init];
        });
    }
    return baseStoreTable;
}


@end
