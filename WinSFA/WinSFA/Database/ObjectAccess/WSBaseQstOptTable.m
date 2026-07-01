//
//  WSBaseQstOptTable.m
//  WinSFA
//
//  Created by heju on 16/8/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseQstOptTable.h"

@implementation WSBaseQstOptTable


static WSBaseQstOptTable *baseQstOptTable = nil;

+ (instancetype)shareInstance {
    if (baseQstOptTable == nil) {
        static dispatch_once_t once_Token;
        dispatch_once(&once_Token, ^{
            baseQstOptTable = [[self alloc] init];
        });
    }
    return baseQstOptTable;
}


@end
