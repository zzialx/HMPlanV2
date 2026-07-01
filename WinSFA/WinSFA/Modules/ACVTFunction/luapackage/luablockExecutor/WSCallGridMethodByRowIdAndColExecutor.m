//
//  WSCallGridMethodByRowIdAndColExecutor.m
//  WinSFA
//
//  Created by heju on 2016/10/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCallGridMethodByRowIdAndColExecutor.h"

#import "I_W_BuildInfo.h"

#import "WSWidget.h"

#import "WSAcvtDataGridViewPanel.h"

@implementation WSCallGridMethodByRowIdAndColExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        
        NSString *rowId = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        id thirdObj = va_arg(argsList, id);
        id fourthObj = va_arg(argsList, id);
        va_end(argsList);
        NSString *col = [NSString stringWithFormat:@"%@",secondObj];
        NSString *methodName = [NSString stringWithFormat:@"%@",thirdObj];
        NSString *param = [NSString stringWithFormat:@"%@",fourthObj];
        NSString *result = nil;
        
        if ([methodName length] > 0){
            LogInfo(@"WSCallGridMethodByRowIdAndColExecutor,rowId:%@,col:%@,methodName:%@,param:%@", rowId, col,methodName ,param);
            
            WSAcvtDataGridViewPanel *currentDataGridViewPannel = (WSAcvtDataGridViewPanel *)sself.currentTargetObject;
            
            result = [currentDataGridViewPannel callGridMethodWithRowId:rowId col:col methodName:methodName param:param];
            
            if ([result length] > 0) {
                return result;
            }else {
                return @"";
            }

        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}


@end
