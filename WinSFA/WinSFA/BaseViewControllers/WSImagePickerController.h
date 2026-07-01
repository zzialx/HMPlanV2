//
//  WSImagePickerController.h
//  WinSFA
//
//  Created by yang on 13-12-19.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WCBaseViewController.h"
#import "WSWatermarkOverlayView.h"

// MSTD-7860
#import "WSTipView.h"
#import "WSViewingView.h"

typedef enum {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
}AVCamSetupResult;


@class WSImagePickerController;

@protocol WSImagePickerControllerDelegate <NSObject>

- (void)imagePicker:(WSImagePickerController *)picker didFinishPickingImage:(UIImage *)image withDeviceOrientation:(UIDeviceOrientation)deviceOrientation withISCaptureDevicePositionFront:(BOOL)iSCaptureDevicePositionFront;

- (void)imagePickerDidCancel:(WSImagePickerController *)picker;

- (BOOL)imagePickerIsToMaxNum:(WSImagePickerController *)picker;//点击拍照按钮验证照片是否达到最大值

@end

@interface WSImagePickerController : WCBaseViewController

@property (nonatomic, assign) id<WSImagePickerControllerDelegate> delegate;

@property (nonatomic, strong) WSWatermarkOverlayView *cameraOverlayView;

// MSTD-7860
@property (nonatomic, strong) NSString *tip;        // 用于显示拍照导引提示
@property (nonatomic, strong) WSViewingView *viewingView;   // 新取景框
@property (nonatomic, strong) NSDictionary *dic;    // 参数字典

- (CGRect)getPreControlFrame;

//重拍
- (void)reTake;

// MSTD-7860
- (void)setTipView;
-(void)setViewingView;
@end
