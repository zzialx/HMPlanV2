//
//  WSGetEmpNameExecutor.m
//  WinSFA
//
//  Created by Alicia on 2017/8/10.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSGetEmpNameExecutor.h"

@implementation WSGetEmpNameExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
    
        return [WSAppData getObjectbyKey:EMPNAME];
    };
    
    return [paramExpanedBlock copy];
}

@end
