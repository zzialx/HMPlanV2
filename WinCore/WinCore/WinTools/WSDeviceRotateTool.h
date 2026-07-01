//
//  WSDeviceRotateTool.h
//  WinSFA
//
//  Created by sunhongfu on 2017/10/31.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSDeviceRotateTool : NSObject
/*
 appdelegate里用来监听设备方向调用专用 用来处理支持横屏的特殊页面
 */
+ (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window application:(UIApplication *)application;

/*
 返回是否能旋转
 */
+ (BOOL)shouldAutorotate;

/*
 返回支持哪些方向
 */
+ (UIInterfaceOrientationMask)supportedInterfaceOrientations;

/*
 当是present时候走这个方法
 */
+ (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;

+ (UIViewController *)topmostViewController;

@end

