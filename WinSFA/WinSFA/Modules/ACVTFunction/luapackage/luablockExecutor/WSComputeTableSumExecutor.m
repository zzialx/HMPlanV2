//
//  WSComputeTableSumExecutor.m
//  WinSFA
//
//  Created by heju on 16/2/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSComputeTableSumExecutor.h"

@implementation WSComputeTableSumExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        if (firstObj) {
            NSString *methodName = nil;
            if ([firstObj isKindOfClass:[NSString class]]) {
                methodName = (NSString *)firstObj;
            }
            
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            va_end(argsList);
            
            NSString *expression = [NSString stringWithFormat:@"%@",secondObj];
            
            if ([methodName isEqualToString:@"computeTableSum"]) {
                LogInfo(@"computeTableSum:%@", expression);
                
                float sum = 0;
                if ([sself.currentTargetObject respondsToSelector:@selector(getSumByExpression:)]) {
                    sum = [sself.currentTargetObject getSumByExpression:expression];
                }
                if (sum != 0) {
                     return [NSString stringWithFormat:@"%f",sum];
                }
                else{
                    return @"0";
                    
                }
                
            }
        }
        return @"0";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
