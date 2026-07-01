//
//  WSAvAuthorizationManager.m
//  WinSFA
//
//  Created by zzialx on 2023/7/28.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import "WSAvAuthorizationManager.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const  MKF_Tips = @"您没有开启麦克风权限 无法进行通话。请在设置中开启麦克风权限。";

static NSString * const  CAM_Tips = @"您没有开启相机权限, 无法进行通话。请在设置中开启相机权限。";



@implementation WSAvAuthorizationManager


/// 获取麦克风权限
+ (void)getAudioAuthorizationComplete:(complete)block{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 if(block){
                                                     block(YES);
                                                 }
                                              
                                             } else {
                                                 [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:MKF_Tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                                             }
                                         });
                                     }];
        } else if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:MKF_Tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        } else if (authStatus == AVAuthorizationStatusAuthorized) {
            if(block){
                block(YES);
            }
    }
}


/// 获取相机权限
+ (void)getMediaTypeVideoAuthorizationComplete:(complete)block{
    AVAuthorizationStatus camera_authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (camera_authStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 if(block){
                                                     block(YES);
                                                 }
                                                 
                                             } else {
                                                 [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:CAM_Tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                                             }
                                         });
                                     }];
        } else if (camera_authStatus == AVAuthorizationStatusDenied || camera_authStatus == AVAuthorizationStatusRestricted) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:CAM_Tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        } else if (camera_authStatus == AVAuthorizationStatusAuthorized) {
            if(block){
                block(YES);
            }
    }
}


@end
