//
//  UIView+WSPITableView.h
//  WinSFA
//
//  Created by xiajl on 14-7-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WSPITableView)


/**
 *  加顶线
 *
 *  @param width  线条的粗
 *  @param color  宽度
 */
- (void)addTopLineWithWidth:(CGFloat)width bgColor:(UIColor *)color;

/**
 *  加顶线
 *
 *  @param width     线条的粗
 *  @param color
 *  @param drawWidth 宽度
 */
- (void)addTopLineWithWidth:(CGFloat)width bgColor:(UIColor *)color drawWidth:(CGFloat)drawWidth;

/**
 *  绘UIview的底线
 *
 *  @param width 线条的高度
 *  @param color 线条的颜色
 */
- (void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor *)color;

/**
 * 加底线
 *
 *  @param width     线条的粗
 *  @param color
 *  @param drawWidth 宽度
 */
- (void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor *)color drawWidth:(CGFloat)drawWidth;

/**
 *  在point(X,0)为起始点绘一条竖线
 *
 *  @param width 线条的粗
 *  @param color 线条的颜色
 *  @param x     x轴上某点
 *
 *  @return 
 */
- (UIView *)addVerticalLineWithWidth:(CGFloat)width bgColor:(UIColor *)color atX:(CGFloat)x;


@end
