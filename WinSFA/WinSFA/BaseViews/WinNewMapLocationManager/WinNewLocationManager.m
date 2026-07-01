//
//  WinNewLocationManager.m
//  WinSFA
//
//  Created by yuanji on 2020/5/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WinNewLocationManager.h"
#import "WSEnvrionment.h"
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import "WSBdLocationDataTable.h"
//================================================================================================================================================================================================

#pragma mark - 位置管理器 延展(内部)
@interface WinNewLocationManager ()

@property (nonatomic, assign) BOOL isLocation;                          //是否定位标示
@property (nonatomic, strong) BMKLocationManager *baiduLocationManager; //百度定位管理器

@end
//================================================================================================================================================================================================

#pragma mark - 位置管理器 延展(工具)
@interface WinNewLocationManager (Tools)

- (void)baiduLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock;    //百度定位方法
- (void)systemLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock;   //系统定位方法

@end
//================================================================================================================================================================================================

#pragma mark - 位置管理器 延展(实现BMKLocationManagerDelegate协议)
@interface WinNewLocationManager (locationManagerDelegate) <BMKLocationManagerDelegate>

@end
//================================================================================================================================================================================================

#pragma mark - 位置管理器
@implementation WinNewLocationManager

#pragma mark - 获取baiduLocationManager方法
- (BMKLocationManager *)baiduLocationManager {
    
    if (!_baiduLocationManager) {
        
        _baiduLocationManager = [[BMKLocationManager alloc] init];
        _baiduLocationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _baiduLocationManager.distanceFilter = kCLDistanceFilterNone;
        _baiduLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _baiduLocationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _baiduLocationManager.pausesLocationUpdatesAutomatically = NO;
        _baiduLocationManager.locationTimeout = 10.0f;
        _baiduLocationManager.reGeocodeTimeout = 10.0f;
        _baiduLocationManager.delegate = self;
    }
    return _baiduLocationManager;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    if (_baiduLocationManager) {
        
        [_baiduLocationManager stopUpdatingLocation];
        _baiduLocationManager.delegate = nil;
        _baiduLocationManager = nil;
    }
}

#pragma mark - 启动定位方法  completionBlock:完成闭包
- (void)requestLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock {
    
    if (self.isLocation) {
            
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:WinNewLocationManagerErrorTypeLocationProgress userInfo:@{NSLocalizedDescriptionKey : @"定位进行中"}];
        completionBlock(nil, error);
        return;
    }
    
    if ([WSEnvrionment getUseBaiduMap]) {
        
        self.isLocation = YES;
        [self baiduLocationWithCompletionBlock:completionBlock];
        return;
    }
    
    if ([WSEnvrionment getuseGeoAmap]) {
        
        self.isLocation = YES;
        [self systemLocationWithCompletionBlock:completionBlock];
        return;
    }
    
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:WinNewLocationManagerErrorTypeLocationOption userInfo:@{NSLocalizedDescriptionKey : @"定位无选项"}];
    completionBlock(nil, error);
}

@end
//================================================================================================================================================================================================

#pragma mark - 位置管理器 延展(工具)
@implementation WinNewLocationManager (Tools)

#pragma mark - 百度定位方法
- (void)baiduLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock {
    
    __weak typeof(self) weakSelf = self;
    [self.baiduLocationManager requestLocationWithReGeocode:YES withNetworkState:YES
                                                completionBlock:^(BMKLocation *location, BMKLocationNetworkState state, NSError *error) {
            
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isLocation = NO;
        [strongSelf.baiduLocationManager stopUpdatingLocation];
        
        if (error) {
            
            NSError *errorBlock = [NSError errorWithDomain:NSURLErrorDomain code:error.code userInfo:@{NSLocalizedDescriptionKey : error.localizedDescription}];
            completionBlock(nil, errorBlock);
            return;
        }
        
        if (!location) {
            
            NSError *errorBlock = [NSError errorWithDomain:NSURLErrorDomain code:WinNewLocationManagerErrorTypeLocationUnknown userInfo:@{NSLocalizedDescriptionKey : @"定位信息未知"}];
            completionBlock(nil, errorBlock);
            return;
        }
        
        CLLocationDegrees latitude = location.location.coordinate.latitude;
        CLLocationDegrees longitude = location.location.coordinate.longitude;

        WSBdLocationDataTable *bdLocationDataTable = [[WSBdLocationDataTable alloc] init];
        WSLocationDescribe *locationDescribeDB = [[WSLocationDescribe alloc] init];
        locationDescribeDB.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [bdLocationDataTable insertWithLocation:locationDescribeDB
                                  withTimeStamp:[NSNumber numberWithDouble:[[WSCurrentTime getTimeMillisString] doubleValue]]
                             withDateTimeString:[WSCurrentTime getDateTime]];
        
        BMKLocationPoi *poi = [location.rgcData.poiList firstObject];
        BMKLocationReGeocode *locationReGeocode = location.rgcData;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setDouble:latitude forKey:kGlobalLatitude];
        [userDefaults setDouble:longitude forKey:kGlobalLongitude];
        if (poi.addr) {
            [userDefaults setObject:poi.addr forKey:kGlobalAddress];
        }
        if (locationReGeocode.city) {
            [userDefaults setObject:locationReGeocode.city forKey:kGlobalCityName];
        }
        if (locationReGeocode.district) {
            [userDefaults setObject:locationReGeocode.district forKey:kGlobalDistrict];
        }
        [userDefaults synchronize];
        
        WinNewLocationDescribe *locationDescribe = [[WinNewLocationDescribe alloc] init];
        locationDescribe.locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        locationDescribe.address = poi.addr;
        locationDescribe.province = locationReGeocode.province;
        locationDescribe.city = locationReGeocode.city;
        locationDescribe.district = locationReGeocode.district;
        locationDescribe.locality = locationReGeocode.locationDescribe;
        completionBlock(locationDescribe, nil);
    }];
}

#pragma mark - 系统定位方法
- (void)systemLocationWithCompletionBlock:(WinLocatingCompletionBlock _Nonnull)completionBlock {
    
    __weak typeof(self) weakSelf = self;
    [[WSLocationManager getInstance] startUpdateUserLocationWithLocationBlock:nil cityInfoBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isLocation = NO;
        
        if (error) {
                    
            NSError *errorBlock = [NSError errorWithDomain:NSURLErrorDomain code:error.code userInfo:@{NSLocalizedDescriptionKey : error.localizedDescription}];
            completionBlock(nil, errorBlock);
            return;
        }
                
        if (!aLocationDescribe.location) {
                    
            NSError *errorBlock = [NSError errorWithDomain:NSURLErrorDomain code:WinNewLocationManagerErrorTypeLocationUnknown userInfo:@{NSLocalizedDescriptionKey : @"定位信息未知"}];
            completionBlock(nil, errorBlock);
            return;
        }
        
        WinNewLocationDescribe *locationDescribe = [[WinNewLocationDescribe alloc] init];
        locationDescribe.locationCoordinate = aLocationDescribe.location.coordinate;
        locationDescribe.address = aLocationDescribe.detailAddress;
        locationDescribe.province = aLocationDescribe.provinceName;
        locationDescribe.city = aLocationDescribe.cityName;
        locationDescribe.district = aLocationDescribe.district;
        locationDescribe.locality = aLocationDescribe.subLocality;
        locationDescribe.poiName = aLocationDescribe.poiName;
        completionBlock(locationDescribe, nil);
    }];
}

@end
//================================================================================================================================================================================================

#pragma mark - 位置管理器 延展(实现BMKLocationManagerDelegate协议)
@implementation WinNewLocationManager (locationManagerDelegate)

#pragma mark - 实现BMKLocationManager:doRequestAlwaysAuthorization:协议
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager doRequestAlwaysAuthorization:(CLLocationManager * _Nonnull)locationManager {
    
    [locationManager requestAlwaysAuthorization];
}

@end
//================================================================================================================================================================================================
