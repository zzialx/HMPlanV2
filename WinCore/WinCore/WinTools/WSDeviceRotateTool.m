//
//  WSDeviceRotateTool.m
//  WinSFA
//
//  Created by sunhongfu on 2017/10/31.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDeviceRotateTool.h"

@implementation WSDeviceRotateTool
/*
 appdelegate里用来监听设备方向调用专用 用来处理支持横屏的特殊页面
 */
+ (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window application:(UIApplication *)application
{
    if (INTERFACE_IS_PAD)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        UIViewController *topmVC = [self getTopViewController];
        if ([[topmVC className] isEqualToString:@"WSSignatureViewController"])
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
}

/*
 返回是否能旋转
 */
+ (BOOL)shouldAutorotate
{
    if (INTERFACE_IS_PHONE) {
        return NO;
    } else {
        return YES;
    }
}

/*
 返回支持哪些方向
 */
+ (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (INTERFACE_IS_PAD)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

/*
 当是present时候走这个方法
 里面的vc是栈区里的最顶层视图也就是做present这个动作的VC 而不是 window上的最顶层VC
 */
+ (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIViewController *vc = [[self class] getPreferredViewController];
    return [vc preferredInterfaceOrientationForPresentation];
}

/*
 获得做present动作的Controller
 */
+ (UIViewController *)getPreferredViewController
{
    UIViewController *resultVC;
    resultVC = [[self class] getCurrentTopViewController];
    
    return resultVC;
}

/*
 获得想要的window最顶层视图
 */
+ (UIViewController *)getCurrentTopViewController
{
    /*
     当有多个window时候  不能用这个方式获得window  keyWindow默认获得最顶层Window 当用了alertview等提示框时候  在最初的window之上会有一个新的window 获得的最顶层controller就不是我们想要的那个controller
     [UIApplication sharedApplication].keyWindow
     */
    return [[self class] topViewController:[[[[UIApplication sharedApplication] delegate] window] rootViewController]];
}

/*
 判断是TabBarController还是NavigationController
 不同的类型的controller取最上层视图的方式不同
 */
+ (UIViewController *)topViewController:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        return [[self class] topViewController:[(UINavigationController *)vc topViewController]];
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        return [[self class] topViewController:[(UITabBarController *)vc selectedViewController]];
    }
    else
    {
        return vc;
    }
    return nil;
}

/*
 获得window最顶层视图
 */
+ (UIViewController *)getTopViewController
{
    UIViewController *resultVC;
    /*
     获得做present动作的Controller
     */
    resultVC = [[self class] getCurrentTopViewController];
    /*
     获得present出来的最上层的Controller
     */
    while (resultVC.presentedViewController)
    {
        resultVC = [[self class] topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
+ (UIViewController *)topmostViewController {
    // 获取应用的根窗口
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        // 兼容多窗口场景
        window = [[UIApplication sharedApplication].windows firstObject];
    }
    
    // 从根视图控制器开始查找
    UIViewController *topVC = window.rootViewController;
    
    // 处理模态弹出的视图控制器
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
        
        // 处理导航控制器
        if ([topVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topVC;
            topVC = nav.topViewController;
        }
        // 处理标签控制器
        else if ([topVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topVC;
            topVC = tab.selectedViewController;
        }
    }
    
    return topVC;
}

@end

