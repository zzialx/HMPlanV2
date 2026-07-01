//
//  WSComputeColSumExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/17.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSComputeColSumExecutor.h"

@implementation WSComputeColSumExecutor

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
            NSString *colName = [NSString stringWithFormat:@"%@",secondObj];
            
            if ([methodName isEqualToString:@"computeColSum"]) {
                LogInfo(@"computeColSum,colName:%@", colName);
                
                double sum = 0;
                if ([sself.currentTargetObject respondsToSelector:@selector(getSumByColName:)]) {
                    sum = [sself.currentTargetObject getSumByColName:colName];
                }
                return [NSString stringWithFormat:@"%lf",sum];
                
            }
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
