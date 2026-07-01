//
//  UINavigationController+Additions.m
//  WinSFA
//
//  Created by Stephanie on 16/8/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "UINavigationController+Additions.h"
#import <objc/runtime.h>


NSString *const NavigationBarBackgroudColor = @"NavigationBarBackgroudColor";

NSString *const NavigationBarTitleColor = @"NavigationBarTitleColor";
NSString *const NavigationBarTitleFont = @"NavigationBarTitleFont";

NSString *const NavigationBarButtonTitleColor = @"NavigationBarButtonTitleColor";
NSString *const NavigationBarButtonTitleFont = @"NavigationBarButtonTitleFont";

@interface UINavigationController () <UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL viewTransitionInProgress;

@end


@implementation UINavigationController (Additions)

+ (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic
{
    //navigation bar title color and font
    UIColor *navBarTitleColor = [dic objectForKey:NavigationBarTitleColor]; //获取导航的颜色
    if (!navBarTitleColor) {
        navBarTitleColor = [UIColor blackColor];
    }
    UIFont *navBarTitleFont = [dic objectForKey:NavigationBarTitleFont]; //获取导航的字体
    if (!navBarTitleFont) {
        navBarTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 22 : 20];
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    //设置navigationbar的字体和颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: navBarTitleColor, NSShadowAttributeName: shadow, NSFontAttributeName : navBarTitleFont} ];
    
    //navigation bar background color
    UIColor *navBarBackgroudColor = [dic objectForKey:NavigationBarBackgroudColor];
    if (navBarBackgroudColor) {
        if (IOS7_OR_LATER) {
            //设置titlebar的背景色,大于等于7.0的情况
//            [[UINavigationBar appearance] setBarTintColor:navBarBackgroudColor];
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageFromColor:navBarBackgroudColor with:CGRectMake(0, 0, 1024, 64)] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            //设置titlebar的背景色
            [[UINavigationBar appearance] setTintColor:navBarBackgroudColor];
        }
    }
    
    //navigation bar button title color and font
    UIColor *navBarButtonTitleColor = [dic objectForKey:NavigationBarButtonTitleColor];//获取navigationbarbtntitle的颜色
//    if (!IOS7_OR_LATER) {
//        navBarButtonTitleColor = nil;
//    }
    UIFont *navBarButtonTitleFont = [dic objectForKey:NavigationBarButtonTitleFont]; //获取navigationbarbtntitlefont的颜色
    NSMutableDictionary *navBarButtonTitleDic = [[NSMutableDictionary alloc] init];
    if (!navBarButtonTitleFont) {
        navBarButtonTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 20 : 18];
    }
    if (navBarButtonTitleColor) {
        [navBarButtonTitleDic setObject:navBarButtonTitleColor forKey:NSForegroundColorAttributeName];
    }
    if (navBarButtonTitleFont) {
        [navBarButtonTitleDic setObject:navBarButtonTitleFont forKey:NSFontAttributeName];
    }
    if (navBarButtonTitleColor) {
        [[UIBarButtonItem appearance] setTintColor:navBarButtonTitleColor];//设置UIBarButtonItem显示的背景色
        [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:navBarButtonTitleColor];//设置UIButton在UINavigationBar中的显示颜色
        if (IOS7_OR_LATER) {//大于等于7.0时
            [[UINavigationBar appearance] setTintColor:navBarButtonTitleColor];//显示的颜色
        }
    }
    if ([navBarButtonTitleDic count] > 0) {
        [navBarButtonTitleDic setObject:shadow forKey:NSShadowAttributeName];//设置文本的阴影颜色
        [[UIBarButtonItem appearance] setTitleTextAttributes:navBarButtonTitleDic forState: UIControlStateNormal];//设置UIBarButtonItem的文本显示颜色
    }
    
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState: UIControlStateDisabled];
}

+ (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic whenContainedIn:(Class)cls
{
    
    //navigation bar title color and font
    UIColor *navBarTitleColor = [dic objectForKey:NavigationBarTitleColor]; //获取导航的颜色
    if (!navBarTitleColor) {
        navBarTitleColor = [UIColor blackColor];
    }
    UIFont *navBarTitleFont = [dic objectForKey:NavigationBarTitleFont]; //获取导航的字体
    if (!navBarTitleFont) {
        navBarTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 22 : 20];
    }
    
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    //设置navigationbar的字体和颜色
    [[UINavigationBar appearanceWhenContainedIn:cls,nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: navBarTitleColor, NSShadowAttributeName: shadow, NSForegroundColorAttributeName : navBarTitleFont} ];
    
    //navigation bar background color
    UIColor *navBarBackgroudColor = [dic objectForKey:NavigationBarBackgroudColor];
    if (navBarBackgroudColor) {
        if (IOS7_OR_LATER) {
            //设置titlebar的背景色,大于等于7.0的情况
//            [[UINavigationBar appearanceWhenContainedIn:cls,nil] setBarTintColor:navBarBackgroudColor];
            
            [[UINavigationBar appearanceWhenContainedIn:cls,nil] setBackgroundImage:[UIImage imageFromColor:navBarBackgroudColor with:CGRectMake(0, 0, 1024, 64)] forBarMetrics:UIBarMetricsDefault];
            
        }
        else
        {
            //设置titlebar的背景色
//            [[UINavigationBar appearanceWhenContainedIn:cls,nil] setTintColor:navBarBackgroudColor];
            [[UINavigationBar appearanceWhenContainedIn:cls,nil] setBackgroundImage:[UIImage imageFromColor:navBarBackgroudColor with:CGRectMake(0, 0, 1024, 44)] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    //navigation bar button title color and font
    UIColor *navBarButtonTitleColor = [dic objectForKey:NavigationBarButtonTitleColor];//获取navigationbarbtntitle的颜色
//    if (!IOS7_OR_LATER) {
//        navBarButtonTitleColor = nil;
//    }
    UIFont *navBarButtonTitleFont = [dic objectForKey:NavigationBarButtonTitleFont]; //获取navigationbarbtntitlefont的颜色
    NSMutableDictionary *navBarButtonTitleDic = [[NSMutableDictionary alloc] init];
    if (!navBarButtonTitleFont) {
        navBarButtonTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 20 : 18];
    }
    if (navBarButtonTitleColor) {
        [navBarButtonTitleDic setObject:navBarButtonTitleColor forKey:NSForegroundColorAttributeName];
    }
    if (navBarButtonTitleFont) {
        [navBarButtonTitleDic setObject:navBarButtonTitleFont forKey:NSFontAttributeName];
    }
    if (navBarButtonTitleColor) {
        [[UIBarButtonItem appearanceWhenContainedIn:cls,nil] setTintColor:navBarButtonTitleColor];//设置UIBarButtonItem显示的背景色
        [[UIButton appearanceWhenContainedIn:cls,nil] setTintColor:navBarButtonTitleColor];//设置UIButton在UINavigationBar中的显示颜色
        if (IOS7_OR_LATER) {//大于等于7.0时
            [[UINavigationBar appearanceWhenContainedIn:cls,nil] setTintColor:navBarButtonTitleColor];//显示的颜色
        }
    }
    if ([navBarButtonTitleDic count] > 0) {
        [navBarButtonTitleDic setObject:shadow forKey:NSShadowAttributeName];//设置文本的阴影颜色
        [[UIBarButtonItem appearanceWhenContainedIn:cls,nil] setTitleTextAttributes:navBarButtonTitleDic forState: UIControlStateNormal];//设置UIBarButtonItem的文本显示颜色
    }
    
    
    [[UIBarButtonItem appearanceWhenContainedIn:cls,nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState: UIControlStateDisabled];
}

- (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic
{
    //navigation bar title color and font
    UIColor *navBarTitleColor = [dic objectForKey:NavigationBarTitleColor]; //获取导航的颜色
    if (!navBarTitleColor) {
        navBarTitleColor = [UIColor blackColor];
    }
    UIFont *navBarTitleFont = [dic objectForKey:NavigationBarTitleFont]; //获取导航的字体
    if (!navBarTitleFont) {
        navBarTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 22 : 20];
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    //设置navigationbar的字体和颜色
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: navBarTitleColor, NSShadowAttributeName: shadow, NSFontAttributeName : navBarTitleFont} ];
    
    //navigation bar background color
    UIColor *navBarBackgroudColor = [dic objectForKey:NavigationBarBackgroudColor];
    if (navBarBackgroudColor) {
        if (IOS7_OR_LATER) {
            //设置titlebar的背景色,大于等于7.0的情况
//            [self.navigationBar setBarTintColor:navBarBackgroudColor];
            [self.navigationBar setBackgroundImage:[UIImage imageFromColor:navBarBackgroudColor with:CGRectMake(0, 0, 1024, 64)] forBarMetrics:UIBarMetricsDefault];
        }
        else
        {
            //设置titlebar的背景色
            [self.navigationBar setTintColor:navBarBackgroudColor];
        }
    }
    
    //navigation bar button title color and font
    
    NSMutableArray *barButtonArray = [NSMutableArray array];
    [barButtonArray addObject:self.navigationItem.leftBarButtonItems];
    [barButtonArray addObject:self.navigationItem.rightBarButtonItems];
    
    
    UIColor *navBarButtonTitleColor = [dic objectForKey:NavigationBarButtonTitleColor];//获取navigationbarbtntitle的颜色
    if (!IOS7_OR_LATER) {
        navBarButtonTitleColor = nil;
    }
    UIFont *navBarButtonTitleFont = [dic objectForKey:NavigationBarButtonTitleFont]; //获取navigationbarbtntitlefont的颜色
    NSMutableDictionary *navBarButtonTitleDic = [[NSMutableDictionary alloc] init];
    if (!navBarButtonTitleFont) {
        navBarButtonTitleFont = [UIFont mainFontOfSize:INTERFACE_IS_PAD ? 20 : 18];
    }
    if (navBarButtonTitleColor) {
        [navBarButtonTitleDic setObject:navBarButtonTitleColor forKey:NSForegroundColorAttributeName];
    }
    if (navBarButtonTitleFont) {
        [navBarButtonTitleDic setObject:navBarButtonTitleFont forKey:NSFontAttributeName];
    }
    if (navBarButtonTitleColor) {
        
        for (UIBarButtonItem *item in barButtonArray) {
            [item setTintColor:navBarButtonTitleColor];//设置UIBarButtonItem显示的背景色
        }

        if (IOS7_OR_LATER) {//大于等于7.0时
            [self.navigationBar setTintColor:navBarButtonTitleColor];//显示的颜色
        }
    }
    if ([navBarButtonTitleDic count] > 0) {
        [navBarButtonTitleDic setObject:shadow forKey:NSShadowAttributeName];//设置文本的阴影颜色
        
        for (UIBarButtonItem *item in barButtonArray) {
            [item setTitleTextAttributes:navBarButtonTitleDic forState: UIControlStateNormal];//设置UIBarButtonItem的文本显示颜色
        }
    }
}

- (CGFloat)getNavTitleMargin {
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    
    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
    return maxWidth * 2;
}


/////////////////////////////////////////
+ (void)load {
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(pushViewController:animated:)),
                                   class_getInstanceMethod(self, @selector(safePushViewController:animated:)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(popViewControllerAnimated:)),
                                   class_getInstanceMethod(self, @selector(safePopViewControllerAnimated:)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(popToRootViewControllerAnimated:)),
                                   class_getInstanceMethod(self, @selector(safePopToRootViewControllerAnimated:)));
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(popToViewController:animated:)),
                                   class_getInstanceMethod(self, @selector(safePopToViewController:animated:)));
    
}

#pragma mark - setter & getter
- (void)setViewTransitionInProgress:(BOOL)property {
    
    NSNumber *number = [NSNumber numberWithBool:property];
    
    objc_setAssociatedObject(self, @selector(viewTransitionInProgress), number, OBJC_ASSOCIATION_RETAIN);
    
}

- (BOOL)viewTransitionInProgress {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(viewTransitionInProgress));
    
    return [number boolValue];
}

#pragma mark - Intercept Pop, Push, PopToRootVC
- (NSArray *)safePopToRootViewControllerAnimated:(BOOL)animated {
    
    if (self.viewTransitionInProgress) return nil;
    
    if (animated) {
        
        self.viewTransitionInProgress = YES;
    }
    
    NSArray *viewControllers = [self safePopToRootViewControllerAnimated:animated];
    
    if (viewControllers.count == 0) {
        
        self.viewTransitionInProgress = NO;
    }
    
    return viewControllers;
}

- (NSArray *)safePopToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewTransitionInProgress) return nil;
    
    if (animated){
        
        self.viewTransitionInProgress = YES;
    }
    
    NSArray *viewControllers = [self safePopToViewController:viewController animated:animated];
    
    if (viewControllers.count == 0) {
        
        self.viewTransitionInProgress = NO;
    }
    
    return viewControllers;
}

- (UIViewController *)safePopViewControllerAnimated:(BOOL)animated {
    
    if (self.viewTransitionInProgress) return nil;
    
    if (animated) {
        
        self.viewTransitionInProgress = YES;
    }
    
    UIViewController *viewController = [self safePopViewControllerAnimated:animated];
    
    if (viewController == nil) {
        
        self.viewTransitionInProgress = NO;
    }
    
    return viewController;
}

- (void)safePushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewTransitionInProgress == NO) {
        
        [self safePushViewController:viewController animated:animated];
        
        if (animated) {
            
            self.viewTransitionInProgress = YES;
        }
    }
}

@end


@implementation UIViewController (SafeTransitionLock)

+ (void)load {
    
    Method m1;
    Method m2;
    
    m1 = class_getInstanceMethod(self, @selector(safeViewDidAppear:));
    m2 = class_getInstanceMethod(self, @selector(viewDidAppear:));
    
    method_exchangeImplementations(m1, m2);
}

- (void)safeViewDidAppear:(BOOL)animated {
        self.navigationController.viewTransitionInProgress = NO;
    
    [self safeViewDidAppear:animated];
}

@end
