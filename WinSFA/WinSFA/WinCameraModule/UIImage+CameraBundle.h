//
//  UIImage+CameraBundle.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
//=============================================================================================================================

#pragma mark - UIImage延展(相机束)
@interface UIImage (CameraBundle)

+ (UIImage *)imageInBundleNamed:(NSString *)name; //从Bundle获取图片方法

@end
//=============================================================================================================================
