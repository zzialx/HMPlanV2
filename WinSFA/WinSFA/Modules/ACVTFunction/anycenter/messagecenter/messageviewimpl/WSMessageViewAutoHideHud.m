//
//  WSMessageViewAutoHideHud.m
//  WinSFA
//
//  Created by yang on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMessageViewAutoHideHud.h"
#import "I_M_View.h"
#import <MBProgressHUD.h>
#import "I_M_Display.h"
#import "WSMessageCenter.h"

@implementation WSMessageViewAutoHideHud {
    
    MBProgressHUD *hud;
}

- (void)showCurrentMessageView:(NSObject<I_M_Display> *)messageobj
{
    MBProgressHUDMessageType type;
    
    switch ([messageobj getMessageType]) {
        case MESSAGE_TYPE_AUTO_HIDE_DONE:
            type = MBProgressHUDMessageTypeDone;
            break;
        case MESSAGE_TYPE_AUTO_HIDE_FAILED:
            type = MBProgressHUDMessageTypeFailed;
            break;
            
        default:
            type = MBProgressHUDMessageTypeDone;
            break;
    }
    if(type == MBProgressHUDMessageTypeFailed){
        [SVProgressHUD showHudMsg:[messageobj getDisplayMessage]];
    }else{
        hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[messageobj getDisplayMessage] tips:nil tapTarget:nil action:nil type:type];
    }
    
}

- (void)hiddenMessageView
{
    [hud hide:NO];
}

- (void)setMessageDelegate:(NSObject<I_M_ViewDelegate> *)operationdelegate
{
    
}

@end
