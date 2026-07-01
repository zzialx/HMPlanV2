//
//  UIView+UIViewExt.h
//  core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface  UIView(UIViewAdditionsForViewController)

@property(nonatomic,readonly)UIViewController* viewController;


@end

@interface  UIView(UIViewAdditionsForScrollToTop)

-(void)disableScrollsToTopPropertyOnAllSubviews;

@end

@interface UIImage(UIImageAdditions)

+ (UIImage*)imageFromMainBundleFile:(NSString*)aFileName; 

CGRect swapWidthAndHeight(CGRect rect);
-(UIImage*)rotate:(UIImageOrientation)orient;

//	旋转视图
- (UIImage *)imageRotated:(UIImage*)img andByDegrees:(CGFloat)degrees;

// rotate and scale image from iphone camera
-(UIImage*)rotateAndScaleFromCameraWithMaxSize:(CGFloat)maxSize;

// scale this image to a given maximum width and height
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize;
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize
					quality:(CGInterpolationQuality)quality;


//截取部分图像  
+ (UIImage*)getSubImage:(UIImage *)img rect:(CGRect)rect;
//缩放图片
+ (UIImage *)scaleImage:(UIImage *)img toSize:(CGSize)size;

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end



/**
 * UIImageView的扩展方法类别
 */
@interface UIImageView (UIImageViewAdditions)

/*
 * 构造并返回一个以strechable image为内容的UIImageView对象。一般用于填充动态大小的区域。
 */
+ (UIImageView *)borderStretchedImageViewWithOriginalImageName:(NSString *)imageName leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end


// UIActionSheet扩展
@interface UIActionSheet(UIActionSheetShowInAppWindow)

- (void)showInMyAppDelegateWindow;
@end