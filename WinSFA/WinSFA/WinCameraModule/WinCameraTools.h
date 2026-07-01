//
//  WinCameraTools.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//宏定义 获取指定bundle内国际化语言方法
#ifndef WinCameraLocalizedStrings
#define WinCameraLocalizedStrings(key) \
[[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"WinCameraLanguage" ofType:@"bundle"]] localizedStringForKey:(key) value:@"" table:@"Localizable"]
#endif

#define WIN_CAMERA_CONTAINER_BAR_HEIGHT         65.0f //内容栏高度
#define WIN_CAMERA_CONTAINER_BAR_ELEMENT_MARGIN 25.0f //内容栏元素边距
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^authDoneBlock)(BOOL isAuth); //定义是否授权闭包

#pragma mark - 相机工具
@interface WinCameraTools : NSObject

+ (CGFloat)safeAreaInsetsTopHeight;                                                                     //获取顶部安全区域高度方法
+ (CGFloat)safeAreaInsetsBottomHeight;                                                                  //获取底部安全区域高度方法

+ (void)authCameraWithBlock:(authDoneBlock)doneBlock;                                                   //相机授权方法
+ (void)authPhotoLibraryWithBlock:(authDoneBlock)doneBlock;                                             //相册授权方法

+ (NSArray<AVCaptureDevice *> *)captureDevices;                                                         //获取捕获设备集合方法
+ (AVCaptureDevice *)frontCaptureDevice;                                                                //获取前置摄像头方法
+ (AVCaptureDevice *)backCaptureDevice;                                                                 //获取后置摄像头方法
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;          //转换击打点方法

+ (UIImage *)scaleImageToWidth:(UIImage *)image targetWidth:(CGFloat)targetWidth;                       //等比缩放图片方法
+ (UIImage *)imageFromView:(UIView *)view;                                                              //视图转图片方法
+ (UIImage *)mergeImage:(UIImage *)baseImage withOverlayImage:(UIImage *)overlayImage;                  //合成图片方法
+ (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;   //裁切图片方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
