//
//  WinCameraViewController.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WinWatermarkInfo.h"
@class WinCameraViewController;

typedef enum : NSUInteger {
    WinCameraErrorCodePermission = 70001,       //授权失败
    WinCameraErrorCodeHardware = 70002,         //设备失败
    WinCameraErrorCodeSwitchCamera = 70003,     //切换摄像头失败
    WinCameraErrorCodeTakePhotoProgress = 70004,//拍照错误(正在处理拍照)
    WinCameraErrorCodeTakeConnection = 70005,   //拍照连接失败
    WinCameraErrorCodeGestureScale = 70006,     //手势捏合失败
    WinCameraErrorCodeFocus = 70007             //聚焦错误
} WinCameraErrorCode;
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

extern NSString *const WinCameraErrorDomain; //错误领域标识

#pragma mark - 相机数据源
@protocol WinCameraDataSource <NSObject>

@optional
- (NSArray<WinWatermarkInfo *> *)topWatermarksInCameraVc:(WinCameraViewController *)vc;   //获取顶部水印信息数据源
- (NSArray<WinWatermarkInfo *> *)bottomWatermarksInCameraVc:(WinCameraViewController *)vc;//获取底部水印信息数据源

@end

#pragma mark - 相机控制器
@interface WinCameraViewController : UIViewController

@property (nonatomic, copy) void (^onError)(WinCameraViewController *camera, NSError *error);       //错误闭包
@property (nonatomic, copy) void (^onTakePhoto)(WinCameraViewController *camera, UIImage *image);   //拍照闭包
@property (nonatomic, weak) id <WinCameraDataSource> dataSource;                                    //数据源
@property (nonatomic, copy) NSString *cameraQuality;                                                //相机质量标识

- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;  //附加控制器方法
- (void)startCamera;                                                            //启动相机方法
- (void)stopCamera;                                                             //停止相机方法
- (void)switchCameraWithPosition:(AVCaptureDevicePosition)position;             //切换相机方法
- (void)switchFlashWithMode:(AVCaptureFlashMode)mode;                           //切换闪光灯方法
- (void)takePhotoWithOrientation:(UIDeviceOrientation)deviceOrientation;        //拍照方法
- (void)deviceRotateWithOrientation:(UIDeviceOrientation)deviceOrientation;     //设备旋转方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
