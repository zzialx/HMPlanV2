//
//  WSSFALoginView.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HotlineClickBlock)(NSString *hotline);   //定义 热线点击闭包
//===================================================================================================================================================================

#pragma mark - SFA登陆视图
@interface WSSFALoginView : UIView

@property (nonatomic, assign) BOOL isShowOrgCode;               //是否显示机构代码
@property (nonatomic, assign) BOOL isShowWarning;               //是否显示警告
@property (nonatomic, assign) BOOL isShowRetrieve;              //是否显示找回
@property (nonatomic, assign) BOOL isShowHotline;               //是否显示热线
@property (nonatomic, copy) HotlineClickBlock hotlineClickBlock;//热线点击闭包

#pragma mark - 更新登陆视图方法
- (void)updateLoginView;

#pragma mark - 清除键盘方法
- (void)dispearKeyboard;

@end
//===================================================================================================================================================================
