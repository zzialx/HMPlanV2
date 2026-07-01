//
//  WSPopViewBar.h
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//
#define WSBOTTOMHEIGHT ((50.0 / [UIScreen mainScreen].bounds.size.height) * [UIScreen mainScreen].bounds.size.height)
#import <UIKit/UIKit.h>

typedef void (^CloseClick)();

@interface WSPopViewBar : UIView

@property (nonatomic,copy) CloseClick closeClick;

@end
