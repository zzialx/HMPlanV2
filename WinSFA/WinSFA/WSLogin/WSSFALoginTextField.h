//
//  WSSFALoginTextField.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - SFA登陆视图文本框
@interface WSSFALoginTextField : UIView

@property (nonatomic, strong) UIImageView *iconImageView;   //图标视图
@property (nonatomic, strong) UITextField *textField;       //文本输入框
@property (nonatomic, strong) UIView *borderLineView;       //边境线视图

@property (nonatomic, assign) CGFloat elementSpace;         //元素间隔
@property (nonatomic, assign) CGFloat lineHeight;           //线高度

#pragma mark - 更新登陆文本框方法
- (void)updateLoginTextField;

#pragma mark - 关闭输入框方法
- (void)closecTextField;

@end
//===================================================================================================================================================================
