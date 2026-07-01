//
//  WSDictTable.m
//  WinSFA
//
//  Created by zhangke on 14/9/16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSDictTable.h"

@implementation WSDictTable

static WSDictTable *fdtTable=nil;
+(WSDictTable*)sharedTable
{
    @synchronized(self) {
        if (fdtTable==nil) {
            fdtTable= [[WSDictTable alloc]init];
        }
    }
    return  fdtTable;
}

@end
