//
//  WSCameraControlView.h
//  WinSFA
//
//  Created by Alicia on 2017/8/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define kFocusImgWH         77
#define kCameraControlColor         [UIColor colorWithRed:254.0f/255 green:202.0f/255 blue:47.0f/255 alpha:1.0f]

@interface WSCameraControlView : UIView

@property (nonatomic, assign) BOOL isExposureLeft;  // 曝光条是否在左边显示

- (instancetype)initWithDevice:(AVCaptureDevice *)device;

- (void)cancelHide;
- (void)hideAfterDelay;
- (void)resetDevice:(AVCaptureDevice *)device;
- (void)resetExposureSliderValue;

@end
