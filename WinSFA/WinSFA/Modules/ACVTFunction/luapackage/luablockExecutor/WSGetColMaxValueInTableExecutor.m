//
//  WSGetColMaxValueInTableExecutor.m
//  WinSFA
//
//  Created by heju on 16/2/4.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetColMaxValueInTableExecutor.h"

#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"

@implementation WSGetColMaxValueInTableExecutor

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
            va_end(argsList);
            
            NSString *item = [NSString stringWithFormat:@"%@",secondObj];
            
            if ([methodName isEqualToString:@"getColMaxValueInTable"]) {
                LogInfo(@"getColMaxValueInTable,item:%@", item);
                
                NSString *colMax = 0;
                if ([sself.currentTargetObject respondsToSelector:@selector(getColMaxValueInTableByItem:)]) {
                    colMax = [sself.currentTargetObject getColMaxValueInTableByItem:item];
                }
                
                if ([colMax length] > 0) {
                    return colMax;
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

