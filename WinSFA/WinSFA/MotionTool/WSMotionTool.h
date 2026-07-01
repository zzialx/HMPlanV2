//
//  WSMotionTool.h
//  WinSFA
//
//  Created by sunhongfu on 2017/11/13.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MotionBlock) (UIDeviceOrientation deviceOrientation);

@interface WSMotionTool : NSObject

//开启陀螺仪 监听设备方向改变
- (void)startMotionManagerGetDeviceOrientationWithInterval:(NSTimeInterval)updateInterval withBlock:(MotionBlock)deviceMotionBlock;
//停止监听设备方向改变
- (void)stopMotion;

@end
