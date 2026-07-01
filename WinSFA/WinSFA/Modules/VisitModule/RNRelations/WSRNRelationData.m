//
//  WSRNRelationData.m
//  WinSFA
//
//  Created by HZH on 16/11/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSRNRelationData.h"
#import "YYModel.h"

@implementation WSRNRelationData

+ (WSRNRelationData*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static WSRNRelationData* _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

@end
