//
//  WSSFALoginRememberButton.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - SFA登陆视图记住按键
@interface WSSFALoginRememberButton : UIView

@property (nonatomic, strong) UIButton *iconButton; //图标按键
@property (nonatomic, strong) UIButton *titleButton;//标题按键

@property (nonatomic, assign) CGFloat elementSpace; //元素间隔

#pragma mark - 更新登陆记住按键方法
- (void)updateLoginRememberButton;

@end
//===================================================================================================================================================================
