//
//  WSAcvtPopView.h
//  WinSFA
//
//  Created by Stephanie on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAcvtPopView : UIView

@property (nonatomic, assign)SEL confirmSelector;

- (instancetype)initWithContentViewController:(UIViewController *)contentController;

- (void)showInView:(UIView *)view;

- (void)hide;

@end
