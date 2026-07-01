//
//  WSEmptyView.h
//  WinSFA
//
//  Created by yuanji on 18/1/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
//==========================================================================================================================================================

#pragma mark - 空视图
@interface WSEmptyView : UIView

#pragma mark - 自定义初始化方法 frame:边框 funcsBean:功能块
- (instancetype)initWithFrame:(CGRect)frame andFuncsBean:(WSFuncsBean *)funcsBean;

#pragma mark - 自定义更新方法 funcsBean:功能块
- (void)updateFromFuncsBean:(WSFuncsBean *)funcsBean;

@end
//==========================================================================================================================================================
