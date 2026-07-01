//
//  UIImage+CameraBundle.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "UIImage+CameraBundle.h"
#import "WinCameraContainerViewController.h"
//=============================================================================================================================

#pragma mark - UIImage延展(相机束)
@implementation UIImage (CameraBundle)

#pragma mark - 从Bundle获取图片方法
+ (UIImage *)imageInBundleNamed:(NSString *)name {
    
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        
        NSBundle *classBundle = [NSBundle bundleForClass:[WinCameraContainerViewController class]];
        return [UIImage imageNamed:name inBundle:classBundle compatibleWithTraitCollection:nil];
    }
    
    return [UIImage imageNamed:name];
}

@end
//=============================================================================================================================
