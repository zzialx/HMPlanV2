//
//  WSLuaExecutor.h
//  WinSFA
//
//  Created by winchannel on 15/4/9.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "I_Lua_Executor.h"
#import "I_Lua_Executor_Delegate.h"
#import "I_Lua_Target_Operator.h"

@class WSLuaScriptEnter;

@class WSWidget;


@interface WSLuaExecutor : NSObject<I_Lua_Executor>


@property (nonatomic,weak) id<I_Lua_Executor_Delegate>  delegate;

@property (nonatomic,weak) id<I_Lua_Target_Operator> currentTargetObject;


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock;

-(void)setCurrentDelegate:(id)delegate;

-(void)setCurrentOperator:(id)currentOperator;


@end
