//
//  WinRPMapTool.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapTool.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NSString *const WinMapPoiAreaCodeCityMrak = @"citycode";  //定义 地图poi区号-市标示
NSString *const WinMapPoiAreaCodeAdMrak = @"adcode";      //定义 地图poi区号-区标示
NSString *const WinMapPoiAreaCodeTownMrak = @"towncode";  //定义 地图poi区号-镇标示
//=================================================================================================================================

#pragma mark - RP地图工具
@implementation WinRPMapTool

#pragma mark - 获取中国多边形范围方法
+ (NSMutableArray *)getChinaPolygonRange {
    
    static NSMutableArray *polygonOfChina = nil;
    static dispatch_once_t onceToken;
    NSString *configFileString = [[NSBundle mainBundle] pathForResource:@"OutChinaPoint" ofType:@"plist"];
    NSArray *pointArray = [[NSArray alloc] initWithContentsOfFile:configFileString];
    
    dispatch_once(&onceToken, ^{
        polygonOfChina = [[NSMutableArray alloc] init];
        for (NSString *str in pointArray) {
            NSArray *array = [str componentsSeparatedByString:@","];
            [polygonOfChina addObject:[NSValue valueWithCGPoint:CGPointMake([array[0] doubleValue], [array[1] doubleValue])]];
        }
    });
    return polygonOfChina;
}

#pragma mark - 判断范围是否满足中国方法
+ (BOOL)isRangeSatisfyChina:(CLLocationCoordinate2D)location {
    
    NSMutableArray *chinaPolygonRange = [WinRPMapTool getChinaPolygonRange];
    CGPoint point = CGPointMake(location.latitude, location.longitude);
    BOOL flag = NO;
    NSInteger j = chinaPolygonRange.count - 1;
    
    for (NSInteger i = 0; i < chinaPolygonRange.count; i++) {
        CGPoint polygonPointi = [chinaPolygonRange[i] CGPointValue];
        CGPoint polygonPointj = [chinaPolygonRange[j] CGPointValue];
        BOOL condition1 = (polygonPointi.y < point.y && polygonPointj.y >= point.y);
        BOOL condition2 = (polygonPointj.y < point.y && polygonPointi.y >= point.y);
        BOOL condition3 = (polygonPointi.x <= point.x || polygonPointj.x <= point.x);
        if ((condition1 || condition2) && condition3) {
            flag ^= (polygonPointi.x + (point.y - polygonPointi.y) / (polygonPointj.y - polygonPointi.y) * (polygonPointj.x - polygonPointi.x) < point.x);
        }
        j = i;
    }
    return flag;
}

#pragma mark - 84坐标转换02坐标方法
+ (CLLocationCoordinate2D)getGcj02coordinateWithWgs84coordinate:(CLLocationCoordinate2D)wgs84coordinate {
    
    return [CoordinateTransform transCoordinate:wgs84coordinate from:@"wgs84" to:@"gcj02"];
}

#pragma mark - 02坐标转换84坐标方法
+ (CLLocationCoordinate2D)getWgs84coordinateWithGcj02coordinate:(CLLocationCoordinate2D)gcj02coordinate {
    
    return [CoordinateTransform transCoordinate:gcj02coordinate from:@"gcj02" to:@"wgs84"];
}

#pragma mark - 连接省市区方法(通过AMapReGeocode数据源)
+ (NSString *)connectProvinceCityDistricyWithMapReGeocode:(AMapReGeocode *)mapReGeocode {
    
    if (!mapReGeocode) {
        return nil;
    }
    
    NSString *city = (mapReGeocode.addressComponent.city.length > 0) ? mapReGeocode.addressComponent.city : @"";
    NSString *province = (mapReGeocode.addressComponent.province.length > 0) ? mapReGeocode.addressComponent.province : city;
    NSString *district = (mapReGeocode.addressComponent.district.length > 0) ? mapReGeocode.addressComponent.district : @"";
    NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@%@%@", province, LUA_SEPARATOR, city, LUA_SEPARATOR, district];
    return splicingResult;
}

#pragma mark - 连接省市区方法(通过AMapPOI数据源)
+ (NSString *)connectProvinceCityDistricyWithMapPOI:(AMapPOI *)mapPOI {
    
    if (!mapPOI) {
        return nil;
    }
    
    NSString *city = (mapPOI.city.length > 0) ? mapPOI.city : @"";
    NSString *province = (mapPOI.province.length > 0) ? mapPOI.province : city;
    NSString *district = (mapPOI.district.length > 0) ? mapPOI.district : @"";
    NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@%@%@", province, LUA_SEPARATOR, city, LUA_SEPARATOR, district];
    return splicingResult;
}

#pragma mark - 连接省市区方法(通过CLPlacemark数据源)
+ (NSString *)connectprovinceCityDistricyWithPlacemark:(CLPlacemark *)placemark {
    
    if (!placemark) {
        return nil;
    }
    
    NSString *city = (placemark.locality.length > 0) ? placemark.locality : @"";
    NSString *province = (placemark.administrativeArea.length > 0) ? placemark.administrativeArea : city;
    NSString *districy = (placemark.subLocality.length > 0) ? placemark.subLocality : @"";
    NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@%@%@", province, LUA_SEPARATOR, city, LUA_SEPARATOR, districy];
    return splicingResult;
}

#pragma mark - 拼接地址方法(通过AMapPOI数据源)
+ (NSString *)connectAddressWithMapPOI:(AMapPOI *)mapPOI {
    
    if (!mapPOI) {
        return nil;
    }
    
    NSString *province = (mapPOI.province.length > 0) ? mapPOI.province : @"";
    NSString *city = (mapPOI.city.length > 0) ? mapPOI.city : @"";
    NSString *district = (mapPOI.district.length > 0) ? mapPOI.district : @"";
    NSString *address = (mapPOI.address.length > 0) ? mapPOI.address : @"";
    
    if ([province isEqualToString:city]) {
        NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@", province, district, address];
        return splicingResult;
    }
    
    NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@%@", province, city, district, address];
    return splicingResult;
}

#pragma mark - 拼接地址方法(通过CLPlacemark数据源)
+ (NSString *)connectAddressWithPlacemark:(CLPlacemark *)placemark {
    
    if (!placemark) {
        return nil;
    }
    
    NSString *administrativeArea = (placemark.administrativeArea.length > 0) ? placemark.administrativeArea : @"";
    NSString *locality = (placemark.locality.length > 0) ? placemark.locality : @"";
    NSString *subLocality = (placemark.subLocality.length > 0) ? placemark.subLocality : @"";
    NSString *name = (placemark.name.length > 0) ? placemark.name : @"";
    NSString *splicingResult = [NSString stringWithFormat:@"%@%@%@%@", administrativeArea, locality, subLocality, name];
    return splicingResult;
}

#pragma mark - 连接区号方法(通过AMapReGeocode数据源)
+ (NSDictionary *)connectAreaCodeWithMapReGeocode:(AMapReGeocode *)mapReGeocode {
    
    if (!mapReGeocode) {
        return nil;
    }
    
    NSString *citycode = (mapReGeocode.addressComponent.citycode.length > 0) ? mapReGeocode.addressComponent.citycode : @"";
    NSString *adcode = (mapReGeocode.addressComponent.adcode.length > 0) ? mapReGeocode.addressComponent.adcode : @"";
    NSString *towncode = (mapReGeocode.addressComponent.towncode.length > 0) ? mapReGeocode.addressComponent.towncode : @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: citycode, WinMapPoiAreaCodeCityMrak,
                         adcode, WinMapPoiAreaCodeAdMrak, towncode, WinMapPoiAreaCodeTownMrak, nil];
    return dic;
}

#pragma mark - 连接区号方法(通过AMapPOI数据源)
+ (NSDictionary *)connectAreaCodeWithMapPOI:(AMapPOI *)mapPOI {
    
    if (!mapPOI) {
        return nil;
    }
    
    NSString *citycode = (mapPOI.citycode.length > 0) ? mapPOI.citycode : @"";
    NSString *adcode = (mapPOI.adcode.length > 0) ? mapPOI.adcode : @"";
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys: citycode, WinMapPoiAreaCodeCityMrak,
                         adcode, WinMapPoiAreaCodeAdMrak, nil];
    return dic;
}

#pragma mark - 连接区号方法(通过CLPlacemark数据源)
+ (NSDictionary *)connectAreaCodeWithPlacemark:(CLPlacemark *)placemark {
    
    if (!placemark) {
        return nil;
    }
    
    NSDictionary *dic = [[NSDictionary alloc] init];
    return dic;
}

#pragma mark - 计算距离方法
+ (NSString *)calculationDistanceWithLocationA:(CLLocation *)locationA locationB:(CLLocation *)locationB {
    
    CLLocationDistance distanc = [locationA distanceFromLocation:locationB];
    if (distanc > 1000) {
        return [NSString stringWithFormat:@"%lu公里", (long)distanc / 1000];
    }
    return [NSString stringWithFormat:@"%lu米", (long)distanc];
}

@end
//=================================================================================================================================

