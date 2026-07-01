//
//  WSBadgeValueTool.m
//  WinSFA
//
//  Created by sunhongfu on 2017/12/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBadgeValueTool.h"

@implementation WSBadgeValueTool

+ (void)changeTabBarItemBadgeValueWithNumber:(NSString *)badgeValue
{
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarVC = (UITabBarController *)rootViewController;
        for (UIViewController* viewController in tabBarVC.viewControllers )
        {
            if ([viewController.title isEqualToString:@"我的"])
            {
                if ([badgeValue intValue]>0)
                {
                    viewController.tabBarItem.badgeValue = badgeValue;
                }
                else
                {
                    viewController.tabBarItem.badgeValue = nil;
                }
            }
        }
    }
}
@end
