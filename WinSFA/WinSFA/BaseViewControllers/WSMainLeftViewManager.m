//
//  WSMainLeftViewManager.m
//  WinSFA
//
//  Created by mac on 2017/11/9.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMainLeftViewManager.h"

static WSMainLeftViewManager *mainLeftViewManager = nil;

@implementation WSMainLeftViewManager
+(instancetype)getInstance{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        mainLeftViewManager = [[WSMainLeftViewManager alloc]init];
    });
    return mainLeftViewManager;
}
@end
