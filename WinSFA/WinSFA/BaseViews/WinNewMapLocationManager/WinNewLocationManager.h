//
//  WinNewLocationManager.h
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinNewLocationDescribe.h"

typedef NS_ENUM(NSUInteger, WinNewLocationManagerErrorType) {   //错误类型枚举
    WinNewLocationManagerErrorTypeLocationProgress = 900100,    //定位进行中错误
    WinNewLocationManagerErrorTypeLocationOption,               //定位选项错误
    WinNewLocationManagerErrorTypeLocationUnknown,              //定位未知
};

typedef void (^WinLocatingCompletionBlock)(WinNewLocationDescribe * _Nullable locationDescribe, NSError * _Nullable error); //定义完成闭包
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 位置管理器
@interface WinNewLocationManager : NSObject

- (void)requestLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock; //启动定位方法 completionBlock:完成闭包

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
