//
//  UIImage+CameraTintColor.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "UIImage+CameraTintColor.h"
//=============================================================================================================================

#pragma mark - UIImage延展(色调颜色)
@implementation UIImage (CameraTintColor)

#pragma mark - 设置图片色调颜色方法
- (UIImage *)tintImageWithColor:(UIColor *)tintColor {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, self.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

@end
//=============================================================================================================================
