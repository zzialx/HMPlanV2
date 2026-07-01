//
//  WSGetTableColValueByProIdExecutor.m
//  WinSFA
//
//  Created by heju on 16/9/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetTableColValueByProIdExecutor.h"

#import "WSAcvtDataGridViewPanel.h"
#import "WSOtherDutyViewController.h"

@implementation WSGetTableColValueByProIdExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    
    LuaScriptWithParamsExpandBlock   paramExpanedBlock=^NSString *(id firstObj, ...) {
        
        NSString *prodId = [NSString stringWithFormat:@"%@" ,firstObj];
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        va_end(argsList);
        
        NSString *paramCol = [NSString stringWithFormat:@"%@",secondObj];
        
        if ([self.currentTargetObject isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *acvtdataGridViewPanel = (WSAcvtDataGridViewPanel *)self.currentTargetObject;
            if ([acvtdataGridViewPanel respondsToSelector:@selector(getTableColValueByProId:col:)]) {
                return [acvtdataGridViewPanel performSelector:@selector(getTableColValueByProId:col:) withObject:prodId withObject:paramCol];
            }
            
        }else if([self.currentTargetObject isKindOfClass:[WSOtherDutyViewController class]]){
            WSOtherDutyViewController * otherDuty = (WSOtherDutyViewController *)self.currentTargetObject;
            if ([otherDuty respondsToSelector:@selector(getTableColValueByProId:col:)]) {
                return [otherDuty performSelector:@selector(getTableColValueByProId:col:) withObject:prodId withObject:paramCol];
            }
        }
        return  @"";
    };
    return [paramExpanedBlock copy];
}




@end
