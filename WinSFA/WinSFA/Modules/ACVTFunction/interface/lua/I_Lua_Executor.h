
//
//  I_Lua_Executor.h
//  WinSFA
//
//  Created by winchannel on 15/4/8.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_I_Lua_Executor_h
#define WinSFA_I_Lua_Executor_h

#import "WSLuaScriptContext.h"

//typedef NSString*(^LuaScriptExpandBlock)(id keyObj);
//typedef NSArray*(^LuaScriptAcvtTBCotextBlock)();        //WSAcvtDataGridComponentDataSource
//typedef NSString*(^LuaScriptWithParamsExpandBlock)(id firstObj,... ); //不定参数 最少一个
typedef id(^LuaScriptWithParamsExpandBlock)(id firstObj,... );

@class WSLuaScriptEnter;

@protocol I_Lua_Executor <NSObject>

@optional;

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock;

-(void)setCurrentDelegate:(id)delegate;

-(void)setCurrentOperator:(id)currentOperator;

-(NSString *)doExecute:(WSLuaScriptEnter *)executerEnter;

-(NSString *)doExecute:(WSLuaScriptEnter *)executerEnter withParam:(NSString *)param;

@end


#endif
