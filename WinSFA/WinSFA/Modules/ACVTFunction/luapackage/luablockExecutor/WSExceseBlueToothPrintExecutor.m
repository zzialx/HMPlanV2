//
//  WSExceseBlueToothPrintExecutor.m
//  WinSFA
//
//  Created by winchannel on 2017/11/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSExceseBlueToothPrintExecutor.h"
#import "WSAcvtView.h"
#import "WSAcvtViewController.h"

@implementation WSExceseBlueToothPrintExecutor

- (LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    __weak __typeof(self) wself = self;
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
        __strong __typeof(wself) sself = wself;
        if (firstObj) {
            if (sself.delegate) {
                WSAcvtView *acvtView = (WSAcvtView *)sself.delegate;
                WSAcvtViewController *acvtViewController = (WSAcvtViewController *)acvtView.delegate;
                [acvtViewController showBlueToothListViewWithParam:firstObj];
            }
            
        }
        return @"";
    };
    return [paramExpanedBlock copy];
}
@end
