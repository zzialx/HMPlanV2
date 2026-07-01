//
//  WSBaseChecker.m
//  WinSFA
//
//  Created by yang on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseChecker.h"

@implementation WSBaseChecker

- (BOOL)checkObjectIsValidate:(NSObject *)checkobject
{
    return YES;
}

- (void)setCheckDelegate:(NSObject<I_Checker_Delegate> *)chekerDelegates
{
    if (_delegate != chekerDelegates) {
        _delegate = chekerDelegates;
    }
}

@end
