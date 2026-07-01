//
//  UIView+Additions.m
//  WinSFA
//
//  Created by Alicia on 2017/8/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "UIView+Additions.h"

#define kBorderWidth    1

@implementation UIView (Additions)

- (UIImage*)convertViewToImage {
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)addTopBorder {
    [self addTopBorderWithOffset:0 width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (void)addLeftBorder {
    [self addLeftBorderWithOffset:0 width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (void)addRightBorder {
    [self addRightBorderWithOffset:0 width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (void)addBottomBorder {
    [self addBottomBorderWithOffset:0 width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (CALayer *)addTopBorderWithOffset:(CGFloat)offset {
    return [self addTopBorderWithOffset:offset width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}
- (CALayer *)addTopBorderWithOffset:(CGFloat)offset width:(CGFloat)width  color:(UIColor *)color {
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(offset, 0, self.width - offset * 2, width);
    border.backgroundColor =  color.CGColor;
    [self.layer addSublayer:border];
    return border;
}

- (CALayer *)addLeftBorderWithOffset:(CGFloat)offset {
    return [self addLeftBorderWithOffset:offset width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (CALayer *)addLeftBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color {
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(0, offset, width, self.height - offset * 2);
    border.backgroundColor =  color.CGColor;
    [self.layer addSublayer:border];
    return border;
}

- (CALayer *)addRightBorderWithOffset:(CGFloat)offset {
    return [self addRightBorderWithOffset:offset width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (CALayer *)addRightBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color {
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(self.width - width, offset, width, self.height - offset * 2);
    border.backgroundColor =  color.CGColor;
    [self.layer addSublayer:border];
    return border;
}

- (CALayer *)addBottomBorderWithOffset:(CGFloat)offset {
    return [self addBottomBorderWithOffset:offset width:kBorderWidth color:DETAIL_SEPERATE_LINE_COLOR];
}

- (CALayer *)addBottomBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color {
    CALayer *border = [CALayer layer];
    border.frame = CGRectMake(offset, self.height - width, self.width - offset * 2, width);
    border.backgroundColor =  color.CGColor;
    [self.layer addSublayer:border];
    return border;
}

@end

