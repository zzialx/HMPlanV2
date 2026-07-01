//
//  WinCameraPhotoViewController.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 相机照片控制器
@interface WinCameraPhotoViewController : UIViewController

@property (nonatomic, copy) void (^onUsePhoto)(UIImage *image); //使用照片闭包

- (void)setupShowDetailWithImage:(UIImage *)image; //设置显示详情方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
