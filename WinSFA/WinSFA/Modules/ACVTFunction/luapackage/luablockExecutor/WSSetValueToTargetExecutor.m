//
//  WSSetValueToTargetExecutor.m
//  WinSFA
//
//  Created by heju on 16/6/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSetValueToTargetExecutor.h"

@implementation WSSetValueToTargetExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        NSString *colSum = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        NSString *qstName = [NSString stringWithFormat:@"%@",secondObj];
        if (qstName){
        
            NSObject<I_Lua_Target_Operator>  * tempoperator =  [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstName];
            [tempoperator setValueForCurrentObject:colSum];
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
