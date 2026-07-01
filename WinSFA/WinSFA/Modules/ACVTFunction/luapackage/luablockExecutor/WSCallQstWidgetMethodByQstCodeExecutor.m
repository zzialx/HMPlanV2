//
//  WSCallQstWidgetMethodByQstCodeExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/4/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCallQstWidgetMethodByQstCodeExecutor.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"
#import "WSAcvtView.h"

@implementation WSCallQstWidgetMethodByQstCodeExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        
        NSArray *qstCodeArray = [firstObjectString componentsSeparatedByString:@","];
        NSMutableArray *widgetArray = [NSMutableArray arrayWithCapacity:[qstCodeArray count]];
        for (NSString *qstCode in qstCodeArray) {
            id widget = [[sself.delegate getQstCodeAndWidgetMapping] valueForKey:qstCode];
            if (widget) {
                [widgetArray addObject:widget];
            }
        }
        
        // 如果qstCode为"allQst"则表示脚本方法对acvtview所有控件都生效
        if ([firstObjectString isEqualToString:@"allQst"]) {
            WSAcvtView *acvtView = (WSAcvtView *)wself.delegate;
            widgetArray = acvtView.widgetArray;
            
        }
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        NSString *methodStr = [NSString stringWithFormat:@"%@",secondObj];
        
        
        if (methodStr){
            id args = va_arg(argsList, id);
            va_end(argsList);
            
            
            
            NSString *result = [self batchCallWidgets:widgetArray method:methodStr paramObj:args];
            
            LogInfo(@"%@,qstNameString:%@,methodStr:%@, args:%@, 调用结果：%@", [self class],firstObjectString, methodStr, args, result);
            
            return result;
            
        } else {
            va_end(argsList);
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}
@end
