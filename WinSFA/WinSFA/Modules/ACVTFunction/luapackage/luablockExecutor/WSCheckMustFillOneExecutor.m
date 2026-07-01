//
//  WSCheckMustFillOneExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/7/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCheckMustFillOneExecutor.h"
#import "WSDataSourceManager.h"

@implementation WSCheckMustFillOneExecutor

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    
     __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj, ...) {
        
        __strong __typeof(wself) sself = wself;
        NSArray *mustFillQstNames = (NSArray *)firstObj;
        NSMutableArray *notFillQstNames = [[NSMutableArray alloc] init];
        BOOL hasValue = NO;
        
        for (NSString *qstName in mustFillQstNames) {
            NSObject<I_Lua_Target_Operator> *tempoperator = [[sself.delegate getQstNameAndWidgetMapping] valueForKey:qstName];
            NSString *tempValue = (NSString *)[tempoperator getValuePresentationForCurrentObject];
            if (tempValue == nil || [tempValue isEqualToString:@""]) {
                [notFillQstNames addObject:qstName];
            } else {
                hasValue = YES;
                break;
            }
        }
        
        if (!hasValue) {
            NSString *notFillQstNameStr = [notFillQstNames componentsJoinedByString:@","];
            NSString *msg = [NSString stringWithFormat:@"not_filled %@", notFillQstNameStr];
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:msg tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
           
            [WSLuaExecutorManager shareInstance].isErrorFromScript = YES;
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
}

@end
