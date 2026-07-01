//
//  LEOAssistiveWindow.m
//  AssistiveTouch
//
//  Created by liuwenjie on 15/10/24.
//  Copyright © 2015年 Leo. All rights reserved.
//

#import "LEOAssistiveWindow.h"
#import <objc/runtime.h>
//===========================================================================================================================================

@interface LEOAssistiveWindow ()

@property (nonatomic, assign) CGPoint startPoint;   //触摸起始点标识
@property (nonatomic, assign) BOOL isMove;          //是否移动标识

@end
//===========================================================================================================================================

@implementation LEOAssistiveWindow

#pragma mark - 设置mainButton主按键方法
- (void)setMainButton:(LEOAssistiveWindowMainItem *)mainButton {
    
    mainButton.userInteractionEnabled = NO;
    
    [_mainButton removeFromSuperview];
    _mainButton = mainButton;
    [self addSubview:mainButton];
}

#pragma mark - 重写layoutSubviews方法
-(void)layoutSubviews {
    
    [super layoutSubviews];
    [_mainButton setFrame:CGRectMake(0, self.frame.size.height / 2 - kDragMainItemWidth / 2, kDragMainItemWidth, kDragMainItemWidth)];
}

#pragma mark - 重写touchesBegan:withEvent:方法 移动开始
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    _isMove = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _startPoint = point;

    if (CGRectContainsPoint(_mainButton.frame, point)) {
        _mainButton.highlighted = YES;
    }
}

#pragma mark - 重写touchesMoved:withEvent:方法 移动过程中
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - _startPoint.x;
    float dy = point.y - _startPoint.y;
    
    if (dx != 0 || dy != 0) {
        _isMove = YES;
    }

    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    float halfx = CGRectGetMidX(self.bounds);
    newcenter.x = MIN([UIScreen mainScreen].bounds.size.width - halfx, newcenter.x);
    float halfy = CGRectGetMidY(self.bounds);
    newcenter.y = MIN([UIScreen mainScreen].bounds.size.height - halfy, newcenter.y);

    self.center = newcenter;
}

#pragma mark - 重写touchesEnded:withEvent:方法 移动结束
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (_isMove) {
        
        _mainButton.highlighted = NO;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_mainButton.frame, point)) {

        _mainButton.highlighted = NO;
        
        if ([self.assistiveDelegate respondsToSelector:@selector(assistiveWindowMainButtonEvent:)]) {
            [self.assistiveDelegate assistiveWindowMainButtonEvent:self];
            
        }
    }
}

#pragma mark - 重写touchesCancelled:withEvent:方法 取消触摸
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_mainButton.frame, point)) {
        _mainButton.highlighted = NO;
    }
}

@end
//===========================================================================================================================================

