//
//  UIImage+Eemporary.h
//  WinSFA
//
//  Created by wangzhiwei on 2018/5/11.
//  Copyright © 2018年 WinChannel. All rights reserved.
//
// 临时使用的文件为了能够引用文件
#import <Foundation/Foundation.h>
@interface UIImage (Eemporary)
+ (UIImage *)imageWithAcvtWidgetValues:(NSArray *)array width:(CGFloat)width;

+ (UIImage *)imageWithString:(NSString *)string width:(CGFloat)width;

@end
