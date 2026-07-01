//
//  WSSetTableColByOtherTableColExecutor.m
//  WinSFA
//
//  Created by HZH on 2017/10/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSetTableColByOtherTableColExecutor.h"
#import "WSAcvtDataGridViewPanel.h"

@implementation WSSetTableColByOtherTableColExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        NSString *funcCode = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        NSString *paramCol = [NSString stringWithFormat:@"%@",secondObj];
        
        
        id thirdObj = va_arg(argsList, id);
        va_end(argsList);
        NSString *acvtQstCode = [NSString stringWithFormat:@"%@",thirdObj];
        
        
        if ([self.currentTargetObject isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *acvtdataGridViewPanel = (WSAcvtDataGridViewPanel *)self.currentTargetObject;
            if ([acvtdataGridViewPanel respondsToSelector:@selector(setTableColByOtherTableCol:funcCode:acvtQstCode:)]) {
                [acvtdataGridViewPanel setTableColByOtherTableCol:paramCol funcCode:funcCode acvtQstCode:acvtQstCode];
            }
            
        }
        return  @"";
    };
    return [paramExpanedBlock copy];
}

@end
