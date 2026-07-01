//
//  WSBaseView.m
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseView.h"
#import "WSSignatureViewController.h"
//===================================================================================================================================================================

#pragma mark - 基地视图 延展(工具)
@interface WSBaseView (Tools)

#pragma mark - 获取窗口当前显示视图管理器方法
- (UIViewController *)windowCurrentShowViewController;

#pragma mark - 从根视图管理器获取当前视图管理器方法 rootVC:根视图管理器
- (UIViewController *)getCurrentVCWithRootVC:(UIViewController *)rootVC;

@end
//===================================================================================================================================================================

#pragma mark - 基地视图
@implementation WSBaseView
@synthesize delegate;

#pragma mark - 重新initWithFrame:方法
- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

#pragma mark - 创建显示内容方法
- (void)buildDisplayContent
{
    //子类重写
}

#pragma mark - 是否布局方法
- (BOOL)isLayoutSubviews
{
    UIViewController *ViewController = [self windowCurrentShowViewController];
    if([ViewController isKindOfClass:[WSSignatureViewController class]])
        return NO;
    return YES;
}

@end
//===================================================================================================================================================================

#pragma mark - 基地视图 延展(工具)
@implementation WSBaseView (Tools)

#pragma mark - 获取窗口当前显示视图管理器方法
- (UIViewController *)windowCurrentShowViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *viewController = [self getCurrentVCWithRootVC:rootViewController];
    return viewController;
}

#pragma mark - 从根视图管理器获取当前视图管理器方法 rootVC:根视图管理器
- (UIViewController *)getCurrentVCWithRootVC:(UIViewController *)rootVC
{
    if ([rootVC presentedViewController])
        rootVC = [rootVC presentedViewController];
    
    UIViewController *currentVC = nil;
    if ([rootVC isKindOfClass:[UITabBarController class]])
        currentVC = [self getCurrentVCWithRootVC:[(UITabBarController *)rootVC selectedViewController]];
    else if ([rootVC isKindOfClass:[UINavigationController class]])
        currentVC = [self getCurrentVCWithRootVC:[(UINavigationController *)rootVC visibleViewController]];
    else
        currentVC = rootVC;
    
    return currentVC;
}

@end
//===================================================================================================================================================================
