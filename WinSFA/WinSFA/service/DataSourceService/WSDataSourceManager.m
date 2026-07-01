//
//  WSDataSourceManager.m
//  WinSFA
//
//  Created by yang on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSDataSourceManager.h"

static WSDataSourceManager *instance;

@implementation WSDataSourceManager

+ (WSDataSourceManager*)sharedInstance
{
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSDataSourceManager alloc] init];
        });
    }

    return instance;
}

@end
