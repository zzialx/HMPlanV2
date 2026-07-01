//
//  WSLuaExecutor.m
//  WinSFA
//
//  Created by winchannel on 15/4/9.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSLuaExecutor.h"

@implementation WSLuaExecutor

- (void)setCurrentDelegate:(id)delegate {
    self.delegate = delegate;
}

- (void)setCurrentOperator:(id)currentOperator {
    self.currentTargetObject = currentOperator;
}

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    return nil;
}


@end
