//
//  WSNextStepFuncsItemButton.h
//  WinSFA
//
//  Created by Alicia on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNextStepArrowWidth     20
#define kNextStepOffsetX        15
#define kNextStepMinWidth       (kNextStepOffsetX * 4)

@interface WSNextStepFuncsItemButton : UIButton

@property (nonatomic, strong) WSFuncsBean *funcsBean;
// 当前 FuncsBean 在父级 FuncsBean 下 funcsArray 的 index
@property (nonatomic, assign) NSInteger currentIndex;
// 是否是最后一个按钮，最后一个按钮样式不同
@property (nonatomic, assign) BOOL isLastItem;



// 设置为已经拜访过，该状态按钮图标状态不同
- (void)setHasVisited;

@end
