//
//  WSCallQstWidgetMethodByQstNameExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSCallQstWidgetMethodByQstNameExecutor.h"

#import "I_W_BuildInfo.h"

#import "WSWidget.h"
#import "WSAcvtView.h"

@implementation WSCallQstWidgetMethodByQstNameExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *firstObjectString = [NSString stringWithFormat:@"%@" ,firstObj];
        
        NSArray *qstNameArray = [firstObjectString componentsSeparatedByString:@","];
        NSMutableArray *widgetArray = [NSMutableArray arrayWithCapacity:[qstNameArray count]];
        for (NSString *qstName in qstNameArray) {
//            id widget = [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstName];
//            if (widget) {
//                [widgetArray addObject:widget];
//            }
            // MN-1489  2018-3-29
            NSArray * qstNameWidgetArray = [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstName];
            if (qstNameWidgetArray.count > 0) {
                [widgetArray addObjectsFromArray:qstNameWidgetArray];
            }
        }
        
        //MN-316 2018-02-02 如果qstCode为"allQst"则表示脚本方法对acvtview所有控件都生效
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
