//
//  WSSplitViewController.h
//  WinSFA
//
//  Created by Stephanie on 16/8/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  UISplitViewController在iOS6不能present,因此自己封装一个简单的。
 */
@interface WSSplitViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *leftViewController;

@property (nonatomic, strong, readonly) UIViewController *rightViewController;

@property (nonatomic, assign) CGFloat leftControllerWidth;

@property (nonatomic, strong) UIColor *separatorLineColor;

- (instancetype)initWithLeftController:(UIViewController *)leftController rightController:(UIViewController *)rightController;

- (void)showRightController:(UIViewController *)rightController;


@end
