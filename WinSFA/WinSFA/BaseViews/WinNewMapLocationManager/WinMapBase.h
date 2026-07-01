//
//  WinMapBase.h
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSStoreBean;
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 地图基地
@interface WinMapBase : UIView

- (void)addCurrentPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate;                             //添加当前点位置方法
- (void)addStoreAnotationWithCoordinate:(CLLocationCoordinate2D)coordinate withStoreBean:(WSStoreBean *)aStore; //添加门店点位置方法

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
