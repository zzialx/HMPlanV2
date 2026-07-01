//
//  LEOAssistiveTouch.h
//  AssistiveTouch
//
//  Created by chinabkorse on 15/10/20.
//  Copyright © 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^mainBtnClickedCallback)(); //定义点击闭包
//===========================================================================================================================================

#pragma mark - 辅助按键(在线咨询)
@interface LEOAssistiveTouch : NSObject

@property (nonatomic, copy) mainBtnClickedCallback mainBtnClickedCallbackBlock; //点击闭包

+ (instancetype)sharedInstance;             //单例方法
+ (void)show;                               //显示浮窗方法
+ (void)hide;                               //隐藏浮窗方法
- (void)setMainBtnImage:(UIImage *)image;   //设置主按键图片方法

@end
//===========================================================================================================================================

