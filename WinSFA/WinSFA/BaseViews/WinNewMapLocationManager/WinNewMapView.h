//
//  WinNewMapView.h
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WinNewMapViewDelegate;
@class WSStoreBean;
//================================================================================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 地图视图
@interface WinNewMapView : UIView

@property (nonatomic, weak) id<WinNewMapViewDelegate> delegate; //代理协议

- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D)coordinate storeId:(NSString *)storeId
          storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress
       locationType:(NSString *)locationType isDropFullScreen:(BOOL)isDropFullScreen;                                       //自定义初始化方法
- (void)setAddress:(NSString *)address;                                                                                     //设置地址方法
- (void)addCurrentPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate;                                         //添加当前点注释方法
- (void)addStoreAnotationWithCoordinate:(CLLocationCoordinate2D)coordinate withStoreBean:(WSStoreBean *)aStore;             //添加门店点注释方法

@end
//================================================================================================================================================================================================

#pragma mark - 新地图视图代理协议
@protocol WinNewMapViewDelegate <NSObject>

@optional
- (void)mapViewRefreshButtonClick:(WinNewMapView *)mapView; //刷新按键点击协议

@end

NS_ASSUME_NONNULL_END
//================================================================================================================================================================================================
