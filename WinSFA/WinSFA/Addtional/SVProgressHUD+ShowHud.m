//
//  SVProgressHUD+ShowHud.m
//  WinSFA
//
//  Created by admin on 2022/11/4.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "SVProgressHUD+ShowHud.h"

@implementation SVProgressHUD (ShowHud)

+(void)showHudMsg:(NSString*)msg{
    [SVProgressHUD setMaxSupportedWindowLevel:NSIntegerMax];
    [SVProgressHUD setContainerView:[UIApplication sharedApplication].delegate.window];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    [SVProgressHUD setBackgroundColor:RGBCOLOR(200, 200, 200)];
    [SVProgressHUD setCornerRadius:5];
    [SVProgressHUD showImage:[UIImage imageNamed:@""] status:msg];
    [SVProgressHUD dismissWithDelay:1.5];
}

+ (void)showLoading{
    NSString *tipsString = NSLocalizedString(@"querying_message",nil);
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setCornerRadius:20];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD showWithStatus:tipsString];
}

+ (void)HideLoading{
    [SVProgressHUD dismissWithDelay:1];
}

@end
