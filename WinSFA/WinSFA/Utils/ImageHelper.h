//
//  ImageHelper.h
//  menu
//
//  Created by Niu Zhaowang on 11/8/12.
//  Copyright (c) 2012 Niu Zhaowang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageHelper : NSObject

+ (NSString *)pathForItemNamed:(NSString *)fname inFolder:(NSString *)path;
+ (UIImage *)imageNamed:(NSString *)aName;
+ (UIImage *)imageFromURLString:(NSString *)urlstring;
+ (CGSize)fitSize: (CGSize)thisSize inSize: (CGSize)aSize;
+ (UIImage *)image: (UIImage *)image fitInSize: (CGSize) viewsize;
+ (UIImage *)image: (UIImage *) image centerInSize: (CGSize) viewsize;
+ (UIImage *) image: (UIImage *)image fillSize: (CGSize) viewsize;
+ (UIImage *) imageFromView: (UIView *) theView;
+ (UIImage *) grayscaleImage: (UIImage *)image;
//指定宽度按比例缩放
+ (UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
@end
