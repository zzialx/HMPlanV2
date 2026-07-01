//
//  WSSFALoginLogo.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - SFA登陆视图图标
@interface WSSFALoginLogo : UIView

@property (nonatomic, strong) UIImageView *logoImageView;   //标志图片视图
@property (nonatomic, strong) UILabel *appTypeLabel;        //应用程序类型标签

#pragma mark - 更新登陆图标方法
- (void)updateLoginLogo;

@end
//===================================================================================================================================================================
