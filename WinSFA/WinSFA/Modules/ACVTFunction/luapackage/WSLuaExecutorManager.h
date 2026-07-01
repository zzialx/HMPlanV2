//
//  WSLuaExecutor.h
//  WinSFA
//
//  Created by winchannel on 15/4/3.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_Lua_Executor.h"

@class WSFuncsBean;
@class WSStoreBean;
@class WSAcvtBean;
@class WSLuaScriptContext;
@protocol I_Lua_Executor_Delegate;
@protocol I_Lua_Target_Operator;

typedef NS_ENUM(NSInteger, WSLuaExecuteSourceType) {
    
    WSLuaExecuteSourceTypeAcvt = 1,
    WSLuaExecuteSourceTypeQst,
    WSLuaExecuteSourceTypeGrid
};

@interface WSLuaExecutorManager : NSObject {
    
    WSLuaScriptContext *luaScriptContext;
    WSFuncsBean *currentFuncsBean;
    WSAcvtBean *currentAcvtBean;
    WSStoreBean *currentStoreBean;
    NSString *currentScriptStr;
    NSMutableDictionary *executeBlockDict;
}

@property (nonatomic, weak) id <I_Lua_Executor_Delegate> delegate;
@property (nonatomic, weak) id <I_Lua_Target_Operator> currentoperator;
@property (nonatomic, assign) WSLuaExecuteSourceType sourceType;
@property (nonatomic, assign) BOOL isErrorFromScript; //脚本是否执行报错标示(YES:错误 NO:正确)

+ (WSLuaExecutorManager *)shareInstance; //获取执行实例
+ (NSString *)getSubLuaScriptWith:(NSString *)acvtluaScript ByFuntionName:(NSString *)funcionName;
+ (NSString *)getLocalLuaCriptStrForTest;
+ (NSArray *)getFilterArrayScriptWith:(NSString *)luaScript filterFuncNameArray:(NSArray *)filterFuncNameArray;

- (void)setFuncsBean:(WSFuncsBean *)funcsBean;
- (void)setStoreBean:(WSStoreBean *)storeBean;
- (void)setAcvt:(WSAcvtBean *)acvtBean;
- (void)executeLuaScript:(NSString *)luascript;
- (void)executeLuaScript:(NSString *)luascript params:(NSString *)params;
- (void)executeLuaScript:(NSString *)luascript functionName:(NSString *)functionName params:(NSString *)params; //luascript:全部脚本 functionName:执行函数名 params:参数
- (NSObject <I_Lua_Executor>*)getLuaExecutorWithFunctionName:(NSString *)functionName;

@end
