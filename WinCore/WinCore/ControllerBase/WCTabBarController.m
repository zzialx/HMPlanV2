//
//  WCTabBarController.m
//  WinCore
//
//  Created by Alicia on 17/1/16.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WCTabBarController.h"
#import "WSDeviceRotateTool.h"
@interface WCTabBarController ()

@end

@implementation WCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - About rotate

// iOS6以前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (INTERFACE_IS_PAD) {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    return [WSDeviceRotateTool shouldAutorotate];
    //    if (INTERFACE_IS_PHONE) {
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [WSDeviceRotateTool supportedInterfaceOrientations];
    //    if (INTERFACE_IS_PAD) {
    //        return UIInterfaceOrientationMaskLandscape;
    //    } else {
    //        return UIInterfaceOrientationMaskPortrait;
    //    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [WSDeviceRotateTool preferredInterfaceOrientationForPresentation];
    /*
     UIViewController *vc = self.viewControllers[self.selectedIndex];
     if ([vc isKindOfClass:[UINavigationController class]])
     {
     UINavigationController *nav = (UINavigationController *)vc;
     return [nav.topViewController preferredInterfaceOrientationForPresentation];
     }
     else
     {
     return [vc preferredInterfaceOrientationForPresentation];
     }
     return self.interfaceOrientation ios8 之后已经废弃 create by 孙洪福
     return self.interfaceOrientation;
     */
}


@end
