//
//  WSSetTipExecutor.m
//  WinSFA
//
//  Created by yang on 15/12/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSetTipExecutor.h"
#import "WSDataSourceManager.h"

@implementation WSSetTipExecutor

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj, ...) {
        
        if ([firstObj isKindOfClass:[NSString class]] && [firstObj isEqualToString:@"setTip"]) {
            
            va_list argsList;
            va_start(argsList, firstObj);
            id secondObj = va_arg(argsList, id);
            NSString *msg = [NSString stringWithFormat:@"%@",secondObj];
            va_end(argsList);
            
            if ([wself.currentTargetObject respondsToSelector:@selector(specialHandleLuaTip:)]) {
                if ([wself.currentTargetObject specialHandleLuaTip:msg]) {
                    return @"";
                }
            }

            if ([msg length] > 0) {
                
                [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                
                if ([msg isEqualToString:@"return"]) {
                    [WSLuaExecutorManager shareInstance].isErrorFromScript = YES;
                }
                else {
                    [SVProgressHUD showHudMsg:msg];
                    [WSLuaExecutorManager shareInstance].isErrorFromScript = YES;
                }
            }
        }
        
        return @"";
    };
    
    return [paramExpanedBlock copy];
}

@end
