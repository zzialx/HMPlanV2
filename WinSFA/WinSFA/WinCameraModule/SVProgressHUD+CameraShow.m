//
//  SVProgressHUD+CameraShow.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "SVProgressHUD+CameraShow.h"
//=============================================================================================================================

#pragma mark - SVProgressHUD延展(相机展示)
@implementation SVProgressHUD (CameraShow)

#pragma mark - 显示信息方法
+ (void)showWithInfo:(NSString *)info {
    
    if (info.length == 0) {
        return;
    }
    
    __block UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        window = windowScene.windows.firstObject;
    }
    else if (@available(iOS 11.0, *)) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }
    
    __block NSString *blockInfo = info;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD setContainerView:window];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setCornerRadius:5.0f];
        [SVProgressHUD showImage:[UIImage imageNamed:@""] status:blockInfo];
        [SVProgressHUD dismissWithDelay:1.5f];
    });
}

@end
//=============================================================================================================================
