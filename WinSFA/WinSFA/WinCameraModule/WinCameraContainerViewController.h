//
//  WinCameraContainerViewController.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinWatermarkInfo.h"
@class WinCameraContainerViewController;
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 相机容器代理协议
@protocol WinCameraContainerDelegate <NSObject>

@optional
- (void)camera:(WinCameraContainerViewController *)vc didFinishWithImage:(UIImage *)image;  //完成拍照协议

@end

#pragma mark - 相机容器控制器
@interface WinCameraContainerViewController : UIViewController

@property (nonatomic, weak) id <WinCameraContainerDelegate> delegate;           //代理指针
@property (nonatomic, strong) UIColor *tintColor;                               //普通色调颜色
@property (nonatomic, strong) UIColor *selectedTintColor;                       //选中色调颜色
@property (nonatomic, strong) NSArray<WinWatermarkInfo *> *topWatermarkInfos;   //上方水印信息
@property (nonatomic, strong) NSArray<WinWatermarkInfo *> *bottomWatermarkInfos;//下方水印信息
@property (nonatomic, assign) CGFloat scaleWidth;                               //缩放宽度(默认手机屏幕宽度)

- (void)handleCameraDismiss;//处理相机解除视图方法
- (void)continueTakePhoto;  //继续拍照方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
