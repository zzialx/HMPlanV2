//
//  WSLargePointBtn.m
//  WinSFA
//
//  Created by admin on 2022/10/29.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSLargePointBtn.h"
#import "UIButton+EnlagerTouchPoint.h"

@implementation WSLargePointBtn

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    // 若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat deltaW = MAX(44 - bounds.size.width, 0);
    CGFloat deltaH = MAX(44 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -deltaW * 0.5, -deltaH * 0.5);
    return CGRectContainsPoint(bounds, point);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
