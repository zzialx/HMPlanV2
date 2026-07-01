//
//  WSSetAcvtEnableByQstValueExecutor.m
//  WinSFA
//
//  Created by Alicia on 2017/8/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSetAcvtEnableByQstValueExecutor.h"
#import "WSAcvtView.h"
#import "WSAcvtViewController.h"

@implementation WSSetAcvtEnableByQstValueExecutor


-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock {
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj, ...) {
        __strong __typeof(wself) sself = wself;
        if (firstObj) {
            if (sself.delegate) {
                WSAcvtView *acvtView = (WSAcvtView *)sself.delegate;
                WSAcvtViewController *acvtViewController = (WSAcvtViewController *)acvtView.delegate;
                
                
                va_list argslist;
                va_start(argslist, firstObj);
                id secondObj = va_arg(argslist, id);
                NSString *paramString = [NSString stringWithFormat:@"%@",secondObj];
                va_end(argslist);
                
                [acvtViewController setAcvtReadOnlyByParam:paramString];
            }
            
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
    
}
@end
