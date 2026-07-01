//
//  WSAcvtTabButtonCell.m
//  WinSFA
//
//  Created by Alicia on 2018/1/31.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtTabButtonCell.h"

@implementation WSAcvtTabButtonCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                               cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.contentView.layer.mask = maskLayer;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    //  YIHAIKERRY-1837 要求不一致
    if (selected) {
        [self setSelectedTextColor];
    }
}
@end
