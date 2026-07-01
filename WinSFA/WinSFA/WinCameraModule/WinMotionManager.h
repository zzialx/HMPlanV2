//
//  WinMotionManager.h
//  LLSimpleCameraExample
//
//  Created by yuanji on 2025/12/30.
//  Copyright © 2025 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//=============================================================================================================================

NS_ASSUME_NONNULL_BEGIN

typedef void (^WinMotionManagerRotationHandler)(UIDeviceOrientation orientation, NSError * __nullable error); //定义旋转处理闭包

#pragma mark - 运动管理器
@interface WinMotionManager : NSObject

@property (nonatomic, copy) WinMotionManagerRotationHandler motionRotationHandler; //旋转处理闭包

+ (instancetype)sharedManager;  //单例方法
- (void)startMotionHandler;     //开启设备运动处理方法
- (void)stopMotionHandler;      //结束设备运动处理方法

@end

NS_ASSUME_NONNULL_END
//=============================================================================================================================
