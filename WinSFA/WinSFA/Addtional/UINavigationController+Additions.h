//
//  UINavigationController+Additions.h
//  WinSFA
//
//  Created by Stephanie on 16/8/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const NavigationBarBackgroudColor;

extern NSString *const NavigationBarTitleColor;
extern NSString *const NavigationBarTitleFont;

extern NSString *const NavigationBarButtonTitleColor;
extern NSString *const NavigationBarButtonTitleFont;


@interface UINavigationController (Additions)

/**
 *  设置所有navi bar的样式
 *
 *  @param dic 样式 dic
 */
+ (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic;

/**
 *  设置所有navi bar在splitViewController中的样式
 *
 *  @param dic 样式 dic
 */
+ (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic whenContainedIn:(Class)cls;

/**
 *  设置某一个navi bar的样式
 *
 *  @param dic 样式 dic
 */
- (void)setNavigationBarUIStyleWithDictionary:(NSDictionary *)dic;

// 获取自定义标题两边左右边距
- (CGFloat)getNavTitleMargin;

@end
