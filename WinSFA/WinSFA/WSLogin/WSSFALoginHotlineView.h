//
//  WSSFALoginHotlineView.h
//  WinSFA
//
//  Created by yuanji on 2017/12/25.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//===================================================================================================================================================================

#pragma mark - SFA登陆视图热线视图
@interface WSSFALoginHotlineView : UIView

@property (nonatomic, strong) UILabel *hotlineLabel;            //热线标签
@property (nonatomic, strong) UIButton *hotlineTelephoneButton; //热线电话按键

@property (nonatomic, assign) CGFloat hotlineSpace;             //热线间隔

#pragma mark - 更新登陆热线方法
- (void)updateLoginHotline;

@end
//===================================================================================================================================================================
