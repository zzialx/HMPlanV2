//
//  WinRPMapLocationManager.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapLocationManager.h"
#import "WinRPMapTool.h"
//=================================================================================================================================

#pragma mark - RP地图定位管理器 延展(内部)
@interface WinRPMapLocationManager ()

@property (nonatomic, assign) BOOL locationIsChina;                 //定位是否在中国范围内标示
@property (nonatomic, strong, readwrite) CLLocation *location;      //定位标示(国内02/国外84 编码不同)
@property (nonatomic, strong) CLLocationManager *locationManager;   //定位管理器

@end
//=================================================================================================================================

#pragma mark - RP地图定位管理器 延展(实现CLLocationManagerDelegate代理协议)
@interface WinRPMapLocationManager (locationManagerDelegate) <CLLocationManagerDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图定位管理器
@implementation WinRPMapLocationManager

#pragma mark - 重写init方法
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _locationManager.delegate = nil;
    [_locationManager stopUpdatingLocation];
}

#pragma mark - 启动定位方法
- (void)startLocation {
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - 停止定位方法
- (void)stopLocation {
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
}

@end
//=================================================================================================================================

#pragma mark - RP地图定位管理器 延展(实现CLLocationManagerDelegate代理协议)
@implementation WinRPMapLocationManager (locationManagerDelegate)

#pragma mark - 实现locationManager:didUpdateLocations:协议
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    self.locationIsChina = [WinRPMapTool isRangeSatisfyChina:currentLocation.coordinate];
    
    if (self.locationIsChina) {
        CLLocationCoordinate2D gcj02Coordinate = [WinRPMapTool getGcj02coordinateWithWgs84coordinate:currentLocation.coordinate];
        self.location = [[CLLocation alloc] initWithLatitude:gcj02Coordinate.latitude longitude:gcj02Coordinate.longitude];
    } else {
        self.location = [[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    }
    
    if ([self.delegate respondsToSelector:@selector(locationSuccess:successData:)]) {
        [self.delegate locationSuccess:self successData:self.location];
    }
}

#pragma mark - 实现locationManager:didFailWithError:协议
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if ([self.delegate respondsToSelector:@selector(locationFailed:failedData:)]) {
        [self.delegate locationFailed:self failedData:error];
    }
}

@end
//=================================================================================================================================

