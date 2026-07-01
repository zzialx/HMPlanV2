//
//  WSDropListRoundedCell.m
//  WinSFA
//
//  Created by Alicia on 2018/3/22.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDropListRoundedCell.h"

@implementation WSDropListRoundedCell

// for autolayout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:self.contentButton.height * 0.5];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentButton.layer.mask = maskLayer;
}


@end
