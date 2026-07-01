//
//  WinMapCreator.h
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinMapBase.h"
#import "WinBaiduMap.h"
#import "WinSystemMap.h"

typedef NS_ENUM (NSUInteger, WinMapCreatorType) {   //地图创造器类型枚举
    WinMapCreatorTypeBaidu = 0,                     //百度地图
    WinMapCreatorTypeGaode,                         //高德地图
    WinMapCreatorTypeOther                          //其它地图
};
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 地图创造器
@interface WinMapCreator : NSObject

+ (WinMapBase *)mapCreatorWithMapType:(WinMapCreatorType)mapType; //根据类型创建地图方法

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
