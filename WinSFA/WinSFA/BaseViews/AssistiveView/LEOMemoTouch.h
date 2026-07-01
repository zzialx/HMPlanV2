//
//  LEOMemoTouch.h
//  WinSFA
//
//  Created by yuanji on 2025/8/5.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
//===========================================================================================================================================

NS_ASSUME_NONNULL_BEGIN
typedef void(^mainBtnClickedCallback)(); //定义点击闭包

#pragma mark - 辅助按键(备忘录)
@interface LEOMemoTouch : NSObject

@property (nonatomic, copy) mainBtnClickedCallback mainBtnClickedCallbackBlock; //点击闭包

+ (instancetype)rootSharedInstance;         //单例方法(针对根视图)
+ (instancetype)subSharedInstance;          //单例方法(针对指定视图)
+ (NSString *)isShowMemoURL;                //判断是否显示备忘录网页方法
- (void)setMainBtnImage:(UIImage *)image;   //设置主按键图片方法
- (void)show;                               //显示方法
- (void)hide;                               //隐藏方法
- (void)resetWindowFrame;                   //复位窗口位置方法

@end

NS_ASSUME_NONNULL_END
//===========================================================================================================================================
