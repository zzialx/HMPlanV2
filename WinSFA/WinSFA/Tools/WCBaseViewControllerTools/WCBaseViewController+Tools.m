//
//  WCBaseViewController+Tools.m
//  WinSFA
//
//  Created by zzialx on 2023/7/27.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WCBaseViewController+Tools.h"
#import "WSRequestTools.h"
#import "MBProgressHUD+TapAction.h"
#import "WSAppData.h"

@implementation WCBaseViewController (Tools)

- (void)loginOutApp{
    
    [self querying_messageTips];
    [WSRequestTools requestUnBindDeviceTokenSuccess:^(BOOL success) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:LOGOUT object:nil];
        //退出登录还需要显示调查问卷
        if ([WSAppData sharedManager].showHomePage) {
             [WSAppData sharedManager].showHomePage = NO;
        }
        
        } failure:^(NSString *errorTips) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:self.view withText:errorTips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }];
    
}

- (void)clearAppDataSuccess:(handlerSuccess)block{
    [self querying_messageTips];
    [WSRequestTools requestUnBindDeviceTokenSuccess:^(BOOL success) {
        if(block){
            block();
        }

        } failure:^(NSString *errorTips) {
            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
            [MBProgressHUD showHUDAddedTo:self.view withText:errorTips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }];
}


@end
