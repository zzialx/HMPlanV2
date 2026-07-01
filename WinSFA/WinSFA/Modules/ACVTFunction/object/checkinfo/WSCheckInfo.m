//
//  WSCheckInfo.m
//  WinSFA
//
//  Created by yang on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCheckInfo.h"

@implementation WSCheckInfo {
    
    NSString *checkType;
    
    NSObject *checkObject;
    
}

- (void)setCheckerObject:(NSObject *)checkerObject
{
    checkObject = checkerObject;
}

- (void)setCheckerType:(NSString *)checkerType
{
    checkType = checkerType;
}

- (NSObject *)getCheckerObject
{
    return checkObject;
}

- (NSString *)getCheckerType
{
    return checkType;
}

@end
