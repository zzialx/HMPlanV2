//
//  WSAcvtScrollView.h
//  WinSFA
//
//  Created by yang on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSAcvtView,WSAcvtBean;

@interface WSAcvtScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) WSAcvtView *acvtView;
@property (nonatomic, assign) CGFloat scrollViewChangeHeight;

/*
 * MN-661 蒙牛项目时间有限，新加的 WSAcvtGroupViewController 逻辑需要 AcvtView 的变量，所以该控制器的视图暂时加到 AcvtView 上
 * WSAcvtGroupViewController 自己处理文本框输入时键盘遮挡问题，不需要该类处理。所以添加 isResetOffset
 * 稍后重构后可以把逻辑从视图移动到控制器后删除该变量
 */
@property (nonatomic, assign) BOOL isResetOffset;

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean;

- (id)initWithFrame:(CGRect)frame andAcvtBean:(WSAcvtBean *)acvtBean qstArray:(NSArray *)qstArray;

- (WSAcvtScrollView *)getSubScrollView;

@end
