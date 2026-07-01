//
//  UIView+WSPITableView.m
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "UIView+WSPITableView.h"

@implementation UIView (WSPITableView)

- (void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor *)color {
    CGRect f = self.frame;
    f.size.height += width;
    self.frame = f;
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - width, self.frame.size.width, width)];
    bottomLine.backgroundColor = color;
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bottomLine];
}

- (void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor *)color drawWidth:(CGFloat)drawWidth {
    CGRect f = self.frame;
    f.size.height += width;
    self.frame = f;
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - width, drawWidth - width, width)];
    bottomLine.backgroundColor = color;
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bottomLine];
}

- (void)addTopLineWithWidth:(CGFloat)width bgColor:(UIColor *)color {
    CGRect f = self.frame;
    f.size.height += width;
    self.frame = f;
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, width)];
    topLine.backgroundColor = color;
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:topLine];
}

- (void)addTopLineWithWidth:(CGFloat)width bgColor:(UIColor *)color drawWidth:(CGFloat)drawWidth
{
    CGRect f = self.frame;
    f.size.height += width;
    self.frame = f;
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, drawWidth, width)];
    topLine.backgroundColor = color;
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:topLine];
}

- (UIView *)addVerticalLineWithWidth:(CGFloat)width bgColor:(UIColor *)color atX:(CGFloat)x {
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, 0.0f, width, self.bounds.size.height)];
    line.backgroundColor = color;
    line.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:line];
    return line;
}

@end
