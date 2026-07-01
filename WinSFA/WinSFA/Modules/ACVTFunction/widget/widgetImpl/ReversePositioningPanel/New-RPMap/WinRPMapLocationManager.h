//
//  WinRPMapLocationManager.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WinRPMapLocationManagerDelegate;

NS_ASSUME_NONNULL_BEGIN
//=================================================================================================================================

#pragma mark - RP地图定位管理器
@interface WinRPMapLocationManager : NSObject

@property (nonatomic, weak) id <WinRPMapLocationManagerDelegate> delegate;  //RP地图定位管理器代理指针
@property (nonatomic, assign, readonly) BOOL locationIsChina;               //定位是否在中国范围内标示
@property (nonatomic, strong, readonly) CLLocation *location;               //定位信息(国内02/国外84)

- (void)startLocation;  //启动定位方法
- (void)stopLocation;   //停止定位方法

@end
//=================================================================================================================================

#pragma mark - RP地图定位管理器代理协议
@protocol WinRPMapLocationManagerDelegate <NSObject>

@optional //可选
- (void)locationSuccess:(WinRPMapLocationManager *)manager successData:(CLLocation *)location;  //定位成功方法
- (void)locationFailed:(WinRPMapLocationManager *)manager failedData:(NSError *)error;          //定位失败方法

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================

