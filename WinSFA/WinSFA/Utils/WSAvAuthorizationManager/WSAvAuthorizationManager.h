//
//  WSAvAuthorizationManager.h
//  WinSFA
//
//  Created by zzialx on 2023/7/28.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^complete)(BOOL isSuccess);

NS_ASSUME_NONNULL_BEGIN

@interface WSAvAuthorizationManager : NSObject


/// 获取麦克风权限
/// - Parameter block: 回调
+ (void)getAudioAuthorizationComplete:(complete)block;


/// 获取相机权限
/// - Parameter block: 回调
+ (void)getMediaTypeVideoAuthorizationComplete:(complete)block;

@end

NS_ASSUME_NONNULL_END
