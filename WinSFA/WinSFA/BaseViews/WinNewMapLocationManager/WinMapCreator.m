//
//  WinMapCreator.m
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WinMapCreator.h"
//================================================================================================================================================================================================

#pragma mark - 地图创造器
@implementation WinMapCreator

#pragma mark - 根据类型创建地图方法
+ (WinMapBase *)mapCreatorWithMapType:(WinMapCreatorType)mapType {
    
    if (mapType == WinMapCreatorTypeBaidu) {
        return [[WinBaiduMap alloc] init];
    }
    
    if (mapType == WinMapCreatorTypeOther) {
        return [[WinSystemMap alloc] init];
    }
    
    return [[WinMapBase alloc] init];
}

@end
//================================================================================================================================================================================================
