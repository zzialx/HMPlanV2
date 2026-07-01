//
//  WSSetColDefaultValueWithColNameAndIndex.m
//  WinSFA
//
//  Created by yang on 16/10/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSetColDefaultValueWithColNameAndIndexExecutor.h"

@implementation WSSetColDefaultValueWithColNameAndIndexExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock   paramExpanedBlock = ^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;
        
        if (firstObj) {
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            va_end(argsList);
            NSString *colName = [NSString stringWithFormat:@"%@",firstObj];
            NSString *index = [NSString stringWithFormat:@"%@",secondObj];
            
            if ([sself.currentTargetObject respondsToSelector:@selector(setColDefaultValueWithColName:index:)]) {
                [sself.currentTargetObject setColDefaultValueWithColName:colName index:[index integerValue]];
            }
        }
        
        return nil;
    };
    return [paramExpanedBlock copy];
}

@end
