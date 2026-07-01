//
//  WSNextStepFuncsView.h
//  WinSFA
//
//  Created by Alicia on 2017/12/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WSNextStepFuncsViewStyle) {
    WSNextStepFuncsUnderLineScroll, // 第二版设计扩展下划线能滑动的样式
    WSNextStepFuncsUnderLine,       // 第二版设计下划线的样式
    WSNextStepFuncsArrow            // 第一版设计带箭头的样式
};

@protocol WSNextStepFuncsDelegate

- (void)gotoFuncs:(WSFuncsBean *)funcs index:(NSInteger)index;

- (BOOL)isValidController:(UIViewController *)vc index:(NSInteger)index;

@end

@interface WSNextStepFuncsView : UIView


@property (nonatomic, strong) NSArray *funcsArray;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)setHasVisitedIndex:(NSInteger)index;

- (void)setViewStyle:(WSNextStepFuncsViewStyle)viewStyle vcArray:(NSArray *)vcArray;

- (void)moveToVisibleWithIndex:(NSInteger)index;

- (void)resetVCFrameWithIndex:(NSInteger)index frame:(CGRect)frame;

- (UIViewController *)getViewControllerByIndex:(NSInteger)index;


@end
