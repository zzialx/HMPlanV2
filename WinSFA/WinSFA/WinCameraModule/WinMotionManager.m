//
//  WinMotionManager.m
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import "WinMotionManager.h"
#import <CoreMotion/CoreMotion.h>
//=============================================================================================================================

#pragma mark - 运动管理器 延展(内部)
@interface WinMotionManager ()

@property (nonatomic, strong) CMMotionManager *motionManager;       //管理器
@property (nonatomic, assign) UIDeviceOrientation lastOrientation;  //最后方向
@property (nonatomic, strong) NSOperationQueue *accelerometerQueue; //加速器队列

@end
//=============================================================================================================================

#pragma mark - 运动管理器
@implementation WinMotionManager

#pragma mark - 单例方法
+ (instancetype)sharedManager {
    
    static WinMotionManager *sharedManager = nil;
    static dispatch_once_t predicate = 0;
    dispatch_once(&predicate, ^{
        sharedManager = [[WinMotionManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - 获取motionManager方法
- (CMMotionManager *)motionManager {
    
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

#pragma mark - 重写init方法
- (id)init {
    
    self = [super init];
    if (self) {
        _accelerometerQueue = [[NSOperationQueue alloc] init];
        _accelerometerQueue.name = @"AccelerometerQueue";
    }
    return self;
}

#pragma mark - 开启设备运动处理方法
- (void)startMotionHandler {
    
    if (!self.motionManager.isAccelerometerAvailable) {
        return;
    }
    
    if (self.motionManager.accelerometerActive) {
        return;
    }
    
    self.motionManager.accelerometerUpdateInterval = 0.2f;
    
    __weak typeof(self) weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:self.accelerometerQueue
                                             withHandler:^(CMAccelerometerData * __nullable accelerometerData, NSError * __nullable error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [strongSelf stopMotionHandler];
                
                if (strongSelf.motionRotationHandler) {
                    strongSelf.motionRotationHandler(strongSelf.lastOrientation, error);
                }
            });
            
            return;
        }
        
        CGFloat xx = accelerometerData.acceleration.x;
        CGFloat yy = -accelerometerData.acceleration.y;
        CGFloat zz = accelerometerData.acceleration.z;
        CGFloat device_angle = M_PI / 2.0f - atan2(yy, xx);
        UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
        
        if (device_angle > M_PI) {
            device_angle -= 2 * M_PI;
        }
        
        if ((zz < -.60f) || (zz > .60f)) {
            
            if (UIDeviceOrientationIsLandscape(strongSelf.lastOrientation)) {
                orientation = strongSelf.lastOrientation;
            }
            else {
                orientation = UIDeviceOrientationUnknown;
            }
        }
        else {
            
            if ((device_angle > -M_PI_4) && (device_angle < M_PI_4)) {
                orientation = UIDeviceOrientationPortrait;
            }
            else if ((device_angle < -M_PI_4) && (device_angle > -3 * M_PI_4)) {
                orientation = UIDeviceOrientationLandscapeLeft;
            }
            else if ((device_angle > M_PI_4) && (device_angle < 3 * M_PI_4)) {
                orientation = UIDeviceOrientationLandscapeRight;
            }
            else {
                orientation = UIDeviceOrientationPortraitUpsideDown;
            }
        }
        
        if (orientation != strongSelf.lastOrientation) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf deviceOrientationDidChangeTo:orientation];
            });
        }
    }];
}

#pragma mark - 结束设备运动处理方法
- (void)stopMotionHandler {
    
    if (self.motionManager.accelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

#pragma mark - 处理方向改变方法
- (void)deviceOrientationDidChangeTo:(UIDeviceOrientation)orientation {
    
    self.lastOrientation = orientation;
    
    if (self.motionRotationHandler) {
        self.motionRotationHandler(self.lastOrientation, nil);
    }
}

@end
//=============================================================================================================================
