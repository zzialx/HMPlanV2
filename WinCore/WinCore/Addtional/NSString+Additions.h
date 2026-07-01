//
//  NSString+Additions.h
//  WinCore
//
//  Created by Alicia on 16/11/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSString *)stringByAppendingNameScale:(CGFloat)scale;
- (NSString *)stringByAppendingPathScale:(CGFloat)scale;

// 计算文字的大小
- (CGSize)ws_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGSize)ws_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)ws_sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
- (CGSize)ws_sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGFloat)ws_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width margin:(CGFloat)margin;
- (CGFloat)ws_sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width margin:(CGFloat)margin lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
