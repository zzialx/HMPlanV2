//
//  WinCameraNavigationController.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinCameraNavigationController.h"
//=============================================================================================================================

#pragma mark - 相机导航控制器
@implementation WinCameraNavigationController

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationBarHidden = YES;
}

#pragma mark - 获取prefersStatusBarHidden方法
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - 获取supportedInterfaceOrientations方法
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 获取preferredInterfaceOrientationForPresentation方法
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

@end
//=============================================================================================================================
