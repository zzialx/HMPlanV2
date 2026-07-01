//
//  UIView+WSAnimation.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "UIView+WSAnimation.h"
#import <objc/runtime.h>


NSString * const KCompletionBlock = @"CompletionBlock";



@implementation UIView (WSAnimation)

@dynamic completionBlock;

- (void)setCompletionBlock:(AnimationCompletionBlock)CompletionBlock{
    
    objc_setAssociatedObject(self, (__bridge const void *)(KCompletionBlock), CompletionBlock  ,OBJC_ASSOCIATION_COPY);
}

- (AnimationCompletionBlock )stateUrl{
    
    return (AnimationCompletionBlock )objc_getAssociatedObject(self, (__bridge const void *)(KCompletionBlock));
}

//淡入
- (void)fadeInWithTime:(NSTimeInterval)time{
    self.alpha = 0;
    [UIView animateWithDuration:time animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
//淡出
- (void)fadeOutWithTime:(NSTimeInterval)time{
    self.alpha = 1;
    [UIView animateWithDuration:time animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
//缩放
- (void)scalingWithTime:(NSTimeInterval)time andscal:(CGFloat)scal{
    
    [UIView animateWithDuration:time animations:^{
        self.transform = CGAffineTransformMakeScale(scal,scal);
    }];
}
//旋转
- (void)RevolvingWithTime:(NSTimeInterval)time andDelta:(CGFloat)delta{
    [UIView animateWithDuration:time animations:^{
        self.transform = CGAffineTransformMakeRotation(delta);
    }];
}

- (void)showInViewUsingSpringWithDampingWithTime:(NSTimeInterval)time withCompletion:(AnimationCompletionBlock)block{
    
    if (block) {
        self.completionBlock = block ;
    }
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height + y - self.frame.origin.y, width, height);
    self.alpha = 0.0;
    
    [UIView animateWithDuration:time delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:25 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1;
        self.frame = CGRectMake(x, y, width, height);
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
        
    }];
}

- (void)disMissViewWithTime:(NSTimeInterval)time withCompletion:(AnimationCompletionBlock)block{
    
    if (block) {
        self.completionBlock = block ;
    }
    CGFloat x = self.frame.origin.x;
    CGFloat y = self.frame.origin.y;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.frame = CGRectMake(x,  y, width, height);
    self.alpha = 1.0;
    [UIView animateWithDuration:time animations:^{
        self.alpha = 1.0;
        self.frame = CGRectMake(x, [UIScreen mainScreen].bounds.size.height - self.frame.origin.y + y, width, height);
    } completion:^(BOOL finished) {
        if (block) {
            block();
        }
        [self removeFromSuperview];
    }];
}

@end
