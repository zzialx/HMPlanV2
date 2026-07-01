//
//  WSCallQstWidgetMethodByQstCodeStartsExecutor.m
//  WinSFA
//
//  Created by winchannel on 2016/12/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCallQstWidgetMethodByQstCodeStartsExecutor.h"

#import "I_W_BuildInfo.h"
#import "WSWidget.h"

@implementation WSCallQstWidgetMethodByQstCodeStartsExecutor
-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        
        NSMutableArray *widgetArray = [NSMutableArray array];
        NSDictionary *widgetDict = [sself.delegate getQstCodeAndWidgetMapping];
        
        for (NSString *qstCode in widgetDict.allKeys) {
            if ([qstCode hasPrefix:firstObj]) {
                id widget = [widgetDict objectForKey:qstCode];
                if (widget) {
                    [widgetArray addObject:widget];
                }
            }
        }
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        NSString *methodStr = [NSString stringWithFormat:@"%@",secondObj];
        
        if (methodStr){
            id args = va_arg(argsList, id);
            va_end(argsList);
            
            LogInfo(@"%@,qstNameString:%@,methodStr:%@, args:%@", [self class],firstObjectString, methodStr, args);
            
            NSString *result = [self batchCallWidgets:widgetArray method:methodStr paramObj:args];
            
            LogInfo(@"调用结果：%@", result);
            
            return result;
            
        } else {
            va_end(argsList);
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}

@end
