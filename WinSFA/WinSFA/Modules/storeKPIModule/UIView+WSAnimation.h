//
//  UIView+WSAnimation.h
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationCompletionBlock)(void);

@interface UIView (WSAnimation)

@property (nonatomic, copy)AnimationCompletionBlock completionBlock;

//淡入
- (void)fadeInWithTime:(NSTimeInterval)time;
//淡出
- (void)fadeOutWithTime:(NSTimeInterval)time;
//缩放
- (void)scalingWithTime:(NSTimeInterval)time andscal:(CGFloat)scal;
//旋转
- (void)RevolvingWithTime:(NSTimeInterval)time andDelta:(CGFloat)delta;

- (void)showInViewUsingSpringWithDampingWithTime:(NSTimeInterval)time withCompletion:(AnimationCompletionBlock)block;

- (void)disMissViewWithTime:(NSTimeInterval)time withCompletion:(AnimationCompletionBlock)block;

@end
