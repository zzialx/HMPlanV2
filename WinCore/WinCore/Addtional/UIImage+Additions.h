//
//  UIImage+Additions.h
//  
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RNNDeterminateWidth,
    RNNDeterminateHeight,
    RNNDeterminateNo
}
RNNDeterminateLine;

@interface UIImage (Additions)

+ (UIImage *)scaleImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)getSubImage:(UIImage *)img rect:(CGRect)rect;
+ (UIImage *)middleStretchableImageWithKey:(NSString*)key ;
+ (UIImage *)middleStretchableImageWithOutSupportSkin:(NSString *)key;
+ (UIImage *)middleScaleImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)suitableScaleImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
+ (UIImage *)scaleToSize:(UIImage*)image size:(CGSize)size;
+ (UIImage *)scaleImageForImage:(UIImage *)image toScale:(float)scaleSize;
+ (UIImage *)getSubImage:(UIImage *)img scale:(CGFloat)scale rect:(CGRect)rect;
+ (UIImage *) zoomImageWithImage:(UIImage *)image;
+ (UIImage *)zoomUploadImageWithdImage:(UIImage *)image;
+ (UIImage *)imageForName:(NSString *)name;
+ (UIImage *)scaledImageForName:(NSString *)name ofType:(NSString *)type;
+ (UIImage *)scaledImageForName:(NSString *)name ofType:(NSString *)type bundleName:(NSString *)bundleName;
+ (UIImage *)imageFromColor:(UIColor *)color with:(CGRect)frame;
+ (UIImage *)createImageWithColor:(UIColor *)color;
+ (UIImage *)mergeImage:(UIImage *)newImage toImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)imageWithImage:(UIImage *)image  andTintColor:(UIColor *)tintColor;
+ (UIImage *)rotate90DegreesWithImage:(UIImage *)image;
+ (UIImage *)mergeToWaterImage:(UIImage *)newImage withWaterHeadHeight:(CGFloat)headHeight withImage:(UIImage *)image
                         width:(CGFloat)width height:(CGFloat)height;
+ (UIImage *)addTextsAndScaleImage:(UIImage *)image scaleToSize:(CGSize)size time:(NSString *)time date:(NSString *)date
                           empName:(NSString *)empName storeName:(NSString *)storeName storeAddr:(NSString *)storeAddr;
+ (UIImage *)addTextsAndScaleImage:(UIImage *)image scaleToSize:(CGSize)size time:(NSString *)time date:(NSString *)date
                           empName:(NSString *)empName storeName:(NSString *)storeName storeAddr:(NSString *)storeAddr
                      withLuaValue:(NSString *)luaVlaue;
- (UIImage *)fixOrientation;

@end
