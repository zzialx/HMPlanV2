//
//  WSCameraAuthHelper.m
//  WinSFA
//
//  Created by Alicia on 2017/9/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCameraAuthHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation WSCameraAuthHelper

- (void)authCameraWithBlock:(authDoneBlock)doneBlock; {
    if (IOS7_OR_LATER) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isOK;
                    if (granted) {
                        isOK = YES;
                    } else {
                        NSString* title= NSLocalizedString(@"js_alert_title", nil);
                        NSString* configureCamera= NSLocalizedString(@"photo_permission", nil);
                        NSString* OK = NSLocalizedString(@"confirm", nil);
                        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:configureCamera];
                        [alert setCancelButtonWithTitle:OK block:nil];
                        [alert show];
                        LogInfo(@"应用没有获得使用相机功能权限");
                        isOK = NO;
                    }
                    
                    if (doneBlock) {
                        doneBlock(isOK);
                    }
                });
            }];
            return;
        } else if (authStatus == AVAuthorizationStatusDenied) {
            NSString* title = NSLocalizedString(@"js_alert_title", nil);
            NSString* configureCamera= NSLocalizedString(@"photo_permission", nil);
            NSString* OK= NSLocalizedString(@"confirm", nil);
            BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:configureCamera];
            [alert setCancelButtonWithTitle:OK block:nil];
            [alert show];
            LogInfo(@"应用没有获得使用相机功能权限");
            
            if (doneBlock) {
                doneBlock(NO);
            }
            return;
        }
    }
    
    if (doneBlock) {
        doneBlock(YES);
    }
}
@end
