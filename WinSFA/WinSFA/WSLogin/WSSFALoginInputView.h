//
//  WSSFALoginInputView.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSSFALoginInputView;
@class WSSFALoginTextField;
@class WSSFALoginRememberButton;
@class JFTakeCountButton;
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图数据源
@protocol WSSFALoginInputViewDataSource <NSObject>

- (BOOL)isShowOrgCodeInLoginInputView:(WSSFALoginInputView *)loginInputView;    //获取是否显示机构代码数据
- (BOOL)isShowWarningInLoginInputView:(WSSFALoginInputView *)loginInputView;    //获取是否显示警告数据
- (BOOL)isShowRetrieveInLoginInputView:(WSSFALoginInputView *)loginInputView;   //获取是否显示取回数据

@end
//===================================================================================================================================================================

#pragma mark - SFA登陆视图输入视图
@interface WSSFALoginInputView : UIView

@property (nonatomic, strong) UIView *bgView;                               //背景视图
@property (nonatomic, strong) WSSFALoginTextField *nameTextField;           //用户名输入框
@property (nonatomic, strong) WSSFALoginTextField *passwdTextField;         //密码输入框
@property (nonatomic, strong) WSSFALoginTextField *orgCodeTextField;        //机构代码输入框
@property (nonatomic, strong) WSSFALoginRememberButton *rememberButton;     //记住按键
@property (nonatomic, strong) JFTakeCountButton *loginButton;               //登陆按键
@property (nonatomic, strong) UILabel *warningLabel;                        //警告标签
@property (nonatomic, strong) UIButton *retrieveButton;                     //取回按键
@property (nonatomic, strong) UIButton *aboutButton;                        //关于按键
@property (nonatomic, weak) id<WSSFALoginInputViewDataSource> dataSource;   //数据源代理

#pragma mark - 获取指定宽度范围内登陆视图输入视图高度方法 maxWidth:指定宽度
- (CGFloat)getLoginInputViewHeightWithWidth:(CGFloat)maxWidth;

#pragma mark - 更新登陆输入方法
- (void)updateLoginInput;

@end
//===================================================================================================================================================================
