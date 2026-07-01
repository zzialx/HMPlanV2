//
//  WSMotionTool.m
//  WinSFA
//
//  Created by sunhongfu on 2017/11/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSMotionTool.h"
#import <CoreMotion/CoreMotion.h>

@interface WSMotionTool ()
{
    UIDeviceOrientation deviceOrientation;
}

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation WSMotionTool

- (id)init
{
    self = [super init];
    if (self) {
        deviceOrientation = UIDeviceOrientationPortrait;
    }
    return self;
}

- (CMMotionManager *)motionManager {
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

//开启陀螺仪 监听设备方向改变
- (void)startMotionManagerGetDeviceOrientationWithInterval:(NSTimeInterval)updateInterval withBlock:(MotionBlock)deviceMotionBlock {

    self.motionManager.deviceMotionUpdateInterval = updateInterval;
    if (self.motionManager.deviceMotionAvailable) {
        
        __weak __typeof(self) weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    if (!error) {
                                                        [weakSelf handleDeviceMotion:motion];
                                                    }
                                                    if (deviceMotionBlock) {
                                                        deviceMotionBlock(deviceOrientation);
                                                    }
                                                }];
        
        if (![self.motionManager isDeviceMotionActive]) {
            if (deviceMotionBlock) {
                deviceMotionBlock(deviceOrientation);
            }
        }
    }
    else {
        self.motionManager = nil;
        if (deviceMotionBlock) {
            deviceMotionBlock(deviceOrientation);
        }
    }
}

//判断设备方向根据 X 和 Y 的值判断设备当前的方向
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion {
    
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
        }
        else {
            deviceOrientation = UIDeviceOrientationPortrait;
        }
    }
    else {
        if (x >= 0) {
            deviceOrientation = UIDeviceOrientationLandscapeRight;
        }
        else {
            deviceOrientation = UIDeviceOrientationLandscapeLeft;
        }
    }
}

//停止监听设备方向改变
- (void)stopMotion {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)dealloc {
    [self stopMotion];
}

@end
