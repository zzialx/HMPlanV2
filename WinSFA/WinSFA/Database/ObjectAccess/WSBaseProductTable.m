//
//  WSBaseProductTable.m
//  WinSFA
//
//  Created by weida on 15/12/25.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseProductTable.h"

@implementation WSBaseProductTable

static WSBaseProductTable *baseStoreTable = nil;

+ (WSBaseProductTable *)sharedTable{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseStoreTable = [[WSBaseProductTable alloc] init];
    });
    return baseStoreTable;
}

@end
