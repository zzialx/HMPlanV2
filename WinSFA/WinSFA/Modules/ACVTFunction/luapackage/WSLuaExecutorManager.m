//
//  WSLuaExecutor.m
//  WinSFA
//
//  Created by winchannel on 15/4/3.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSLuaExecutorManager.h"
#import "WSLuaScriptContext.h"
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSAcvtBean.h"
#import "WSLuaScriptEnter.h"
#import "NSString+Util.h"
#import "I_Lua_Target_Operator.h"
#import "WSLuaScript.h"

#define DEFAULT_EXECUTOR @"DefaultExecutor"

@implementation WSLuaExecutorManager {
    
    id<I_Lua_Executor_Delegate> originDelegate;
    id<I_Lua_Target_Operator> originOperator;
    
}


static WSLuaExecutorManager  *executor;


+ (WSLuaExecutorManager *)shareInstance{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        executor =[[WSLuaExecutorManager alloc] init];
        
    });

    return executor;
}

-(id)init{
    
    self = [super init];
    if (self) {
        
        NSString  *luafunction_config_file = [[NSBundle mainBundle] pathForResource:@"luafunction" ofType:@"plist"];
        
        executeBlockDict =[[NSMutableDictionary alloc] initWithContentsOfFile:luafunction_config_file];
        
        return self;
    }
    return nil;
}


-(void)setFuncsBean:(WSFuncsBean *)funcsBean{
    currentFuncsBean = funcsBean;
}

-(void)setStoreBean:(WSStoreBean *)storeBean{
    currentStoreBean = storeBean;
}

-(void)setAcvt:(WSAcvtBean *)acvtBean{
    
    currentAcvtBean = acvtBean;
    
}

- (void)executeLuaScript:(NSString *)luascript {
    [self executeLuaScript:luascript params:nil];
}

- (void)executeLuaScript:(NSString *)luascript params:(NSString *)params {
    [self executeLuaScript:luascript functionName:nil params:params];
}

#pragma mark - SFA-19722 2018-05-09 luascript:全部脚本 functionName:执行函数名 params:参数
- (void)executeLuaScript:(NSString *)luascript functionName:(NSString *)functionName params:(NSString *)params
{
    if((!luascript) || (luascript.length <= 0)) {
        return;
    }
    
    currentScriptStr = luascript;
    
    NSString *handleFunctionName;
    if (functionName && functionName.length > 0) {
        NSRange funcRange = [functionName rangeOfString:@"function "];
        if (funcRange.location != NSNotFound) {
            NSInteger begin = funcRange.location + funcRange.length;
            NSInteger end = [functionName indexOfString:@"("];
            NSRange endRange = NSMakeRange(begin, end - begin);
            handleFunctionName = [[functionName substringWithRange:endRange] stringByTrimmingWhitespace];
        }
    } else {
        NSRange funcRange = [luascript rangeOfString:@"function "];
        if (funcRange.location != NSNotFound) {
            NSInteger begin = funcRange.location + funcRange.length;
            NSInteger end = [luascript indexOfString:@"("];
            NSRange endRange = NSMakeRange(begin, end - begin);
            handleFunctionName = [[luascript substringWithRange:endRange] stringByTrimmingWhitespace];
        }
    }
    
    NSObject<I_Lua_Executor> *luaExecuteobj = [self getLuaExecutorWithFunctionName:DEFAULT_EXECUTOR];
    if (!luaExecuteobj) {
        return;
    }
    
    [luaExecuteobj setCurrentDelegate:_delegate];
    [luaExecuteobj setCurrentOperator:_currentoperator];
    WSLuaScriptContext *luaParserObjTest = [[WSLuaScriptContext alloc] initWithFuncsBean:currentFuncsBean
                                                                           withStoreBean:currentStoreBean
                                                                                withAcvt:currentAcvtBean];
    luaParserObjTest.luaScriptStr = currentScriptStr;
    luaParserObjTest.functionNameExecution = ((functionName && functionName.length > 0) ? handleFunctionName : nil);
    [luaParserObjTest initializationWithVariableParamsBlock:[luaExecuteobj getLuaScriptWithParamsExpandBlock]];
    WSLuaScriptEnter *luaEnter = [[WSLuaScriptEnter alloc] init];
    [luaEnter initializationLuaContextWithLuaScriptContext:luaParserObjTest];
    
    if ([handleFunctionName isEqualToString:@"showDialogAndExcuseAction"]) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                       message:[_currentoperator getDescriptionForCurrentObject]];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm_label", nil) block:^{
            if ([luaExecuteobj respondsToSelector:@selector(doExecute:withParam:)]) {
                NSString *value = (NSString *)[_currentoperator getValuePresentationForCurrentObject];
                [luaExecuteobj doExecute:luaEnter withParam:value];
            } else {
                [luaExecuteobj doExecute:luaEnter];
            }
        }];
        [alert show];
    } else {
        if ([luaExecuteobj respondsToSelector:@selector(doExecute:withParam:)]) {
            NSString *value = (NSString *)[_currentoperator getResultExecuteCheck];
            if (!_currentoperator && params) {
                value = params;
            } else if (!_currentoperator) {
                value = currentStoreBean.Id;
            }
            [luaExecuteobj doExecute:luaEnter withParam:value];
        } else {
            [luaExecuteobj doExecute:luaEnter];
        }
    }
}

- (NSObject<I_Lua_Executor> *)getLuaExecutorWithFunctionName:(NSString *)functionName {
    
    NSString  *executor_class = [executeBlockDict valueForKey:functionName];
    
    if (!executor_class || [executor_class length] == 0) {
        return nil;
    }
    
    NSObject<I_Lua_Executor>  *luaExecuteobj = [[NSClassFromString(executor_class) alloc] init];
    
    [luaExecuteobj setCurrentDelegate:_delegate];
    [luaExecuteobj setCurrentOperator:_currentoperator];
    
    return luaExecuteobj;
    
}


+ (NSString *)getSubLuaScriptWith:(NSString *)acvtluaScript ByFuntionName:(NSString *)funcionName {
    
    NSArray *scriptArray = [acvtluaScript componentsSeparatedByString:ACVT_INIT_LUA_FUNCTION_HEAD];
    
    for (NSInteger i = 1; i < [scriptArray count]; i++) {
        
        if (i < [scriptArray count]) {
            NSString *subluaScript = [NSString stringWithFormat:@"%@%@",ACVT_INIT_LUA_FUNCTION_HEAD,scriptArray[i]];
            NSRange range = [subluaScript rangeOfString:funcionName];
            if (range.location != NSNotFound) {
                return subluaScript;
            }
        }
    }
    return nil;
}

// 过滤掉脚本中 filterFuncNameArray 中存在的方法，返回脚本各函数的数组
+ (NSArray *)getFilterArrayScriptWith:(NSString *)luaScript filterFuncNameArray:(NSArray *)filterFuncNameArray {
    NSArray *scriptArray = [luaScript componentsSeparatedByString:ACVT_INIT_LUA_FUNCTION_HEAD];
    
    NSMutableArray *funcArray  = [NSMutableArray array];
    for (NSInteger i = 1; i < [scriptArray count]; i++) {
        if (i < [scriptArray count]) {
            NSString *subluaScript = [NSString stringWithFormat:@"%@%@",ACVT_INIT_LUA_FUNCTION_HEAD,scriptArray[i]];
            if ([filterFuncNameArray count] > 0) {
                BOOL isFilter = NO;
                for (NSInteger j = 0; j < [filterFuncNameArray count]; j++) {
                    NSString *funcName = filterFuncNameArray[j];
                    NSRange range = [subluaScript rangeOfString:funcName];
                    if (range.location != NSNotFound) {
                        isFilter = YES;
                        break;
                    }
                }
                if (!isFilter) {
                    [funcArray addObject:subluaScript];
                }
            } else {
                [funcArray addObject:subluaScript];
            }
        }
    }
    if ([funcArray count] > 0) {
        return [funcArray copy];
    }
    return nil;
}

+ (NSString *)getLocalLuaCriptStrForTest{
    
    NSBundle *bundle =  [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"luaFunctionForTest" ofType:@"txt"];
    NSString *localLuaCript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return localLuaCript;
}

@end
