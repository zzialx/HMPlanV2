//
//  WSAddAcvtTable.m
//  WinSFA
//
//  Created by zhangke on 14/8/25.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAddAcvtTable.h"

@implementation WSAddAcvtTable

static WSAddAcvtTable *addStoreTable=nil;

+ (WSAddAcvtTable *)sharedTable
{
    if (addStoreTable==nil) {
        addStoreTable= [[WSAddAcvtTable alloc]init];
    }
    return  addStoreTable;
}

@end
