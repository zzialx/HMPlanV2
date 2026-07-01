//
//  WSBadgeValueTool.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBadgeValueTool : NSObject
/*
 设置tabBarBadge
 */
+ (void)changeTabBarItemBadgeValueWithNumber:(NSString *)badgeValue;
@end
