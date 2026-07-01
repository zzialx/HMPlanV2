//
//  WSSetTableColValueByProIdExecutor.m
//  WinSFA
//
//  Created by heju on 16/9/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSetTableColValueByProIdExecutor.h"

#import "WSAcvtDataGridViewPanel.h"
#import "WSOtherDutyViewController.h"
@implementation WSSetTableColValueByProIdExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        NSString *prodId = [NSString stringWithFormat:@"%@" ,firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        NSString *textValue = [NSString stringWithFormat:@"%@",secondObj];
        
        
        id thirdObj = va_arg(argsList, id);
        va_end(argsList);
        NSString *paramCol = [NSString stringWithFormat:@"%@",thirdObj];
        
        
        if ([self.currentTargetObject isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *acvtdataGridViewPanel = (WSAcvtDataGridViewPanel *)self.currentTargetObject;
            if ([acvtdataGridViewPanel respondsToSelector:@selector(setTableColValueByProId:textValue:col:)]) {
                [acvtdataGridViewPanel setTableColValueByProId:prodId textValue:textValue col:paramCol];
            }
            
        }else if([self.currentTargetObject isKindOfClass:[WSOtherDutyViewController class]]){
            WSOtherDutyViewController * otherDuty = (WSOtherDutyViewController *)self.currentTargetObject;
            if ([otherDuty respondsToSelector:@selector(setTableColValueByProId:textValue:col:)]) {
                [otherDuty setTableColValueByProId:prodId textValue:textValue col:paramCol];

            }
        }
        return  @"";
    };
    return [paramExpanedBlock copy];
}


@end
