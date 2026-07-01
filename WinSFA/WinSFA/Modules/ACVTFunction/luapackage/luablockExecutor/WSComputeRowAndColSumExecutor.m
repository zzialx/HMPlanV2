//
//  WSComputeRowAndColSumExecutor.m
//  WinSFA
//
//  Created by heju on 16/2/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSComputeRowAndColSumExecutor.h"

@implementation WSComputeRowAndColSumExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock   paramExpanedBlock = ^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;
        
        if (firstObj) {
            NSString *methodName = nil;
            if ([firstObj isKindOfClass:[NSString class]]) {
                methodName = (NSString *)firstObj;
            }
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            id thirdObj = va_arg(argsList, id);
            va_end(argsList);
            NSString *prodNames = [NSString stringWithFormat:@"%@",secondObj];
            NSString *item = [NSString stringWithFormat:@"%@",thirdObj];
            
            if ([methodName isEqualToString:@"computeRowAndColSum"]) {
                LogInfo(@"computeRowAndColSum,prodNames:%@,item:%@", prodNames,item);
                
                NSString *rowAndColSum = nil;
                if ([sself.currentTargetObject respondsToSelector:@selector(computeRowAndColSumWith:item:)]) {
                    rowAndColSum = [sself.currentTargetObject computeRowAndColSumWith:prodNames item:item];
                }
                
                if ([rowAndColSum length] > 0) {
                    return rowAndColSum;
                }else {
                    return @"";
                }
            }
        }
        return @"";
    };
    return [paramExpanedBlock copy];
}


@end
