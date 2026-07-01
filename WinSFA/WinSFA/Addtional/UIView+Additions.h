//
//  UIView+Additions.h
//  WinSFA
//
//  Created by Alicia on 2017/8/21.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (UIImage*)convertViewToImage;

- (void)addTopBorder;
- (void)addLeftBorder;
- (void)addRightBorder;
- (void)addBottomBorder;

- (CALayer *)addLeftBorderWithOffset:(CGFloat)offset;
- (CALayer *)addRightBorderWithOffset:(CGFloat)offset;
- (CALayer *)addTopBorderWithOffset:(CGFloat)offset;
- (CALayer *)addBottomBorderWithOffset:(CGFloat)offset;

- (CALayer *)addLeftBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color;
- (CALayer *)addRightBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color;
- (CALayer *)addTopBorderWithOffset:(CGFloat)offset width:(CGFloat)width color:(UIColor *)color;
- (CALayer *)addBottomBorderWithOffset:(CGFloat)offset width:(CGFloat)width  color:(UIColor *)color;

@end

