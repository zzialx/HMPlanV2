//
//  WinRPMapTool.h
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMapPOI;
@class AMapReGeocode;

extern NSString *const WinMapPoiAreaCodeCityMrak;   //地图poi区号-市标示
extern NSString *const WinMapPoiAreaCodeAdMrak;     //地图poi区号-区标示
extern NSString *const WinMapPoiAreaCodeTownMrak;   //地图poi区号-镇标示
//=================================================================================================================================

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RP地图工具
@interface WinRPMapTool : NSObject

+ (NSMutableArray *)getChinaPolygonRange;                                                                   //获取中国多边形范围方法
+ (BOOL)isRangeSatisfyChina:(CLLocationCoordinate2D)location;                                               //判断范围是否满足中国方法

+ (CLLocationCoordinate2D)getGcj02coordinateWithWgs84coordinate:(CLLocationCoordinate2D)wgs84coordinate;    //84坐标转换02坐标方法
+ (CLLocationCoordinate2D)getWgs84coordinateWithGcj02coordinate:(CLLocationCoordinate2D)gcj02coordinate;    //02坐标转换84坐标方法

+ (NSString *)connectProvinceCityDistricyWithMapReGeocode:(AMapReGeocode *)mapReGeocode;                    //连接省市区方法(通过AMapReGeocode数据源)
+ (NSString *)connectProvinceCityDistricyWithMapPOI:(AMapPOI *)mapPOI;                                      //连接省市区方法(通过AMapPOI数据源)
+ (NSString *)connectprovinceCityDistricyWithPlacemark:(CLPlacemark *)placemark;                            //连接省市区方法(通过CLPlacemark数据源)

+ (NSString *)connectAddressWithMapPOI:(AMapPOI *)mapPOI;                                                   //拼接地址方法(通过AMapPOI数据源)
+ (NSString *)connectAddressWithPlacemark:(CLPlacemark *)placemark;                                         //拼接地址方法(通过CLPlacemark数据源)

+ (NSDictionary *)connectAreaCodeWithMapReGeocode:(AMapReGeocode *)mapReGeocode;                            //连接区号方法(通过AMapReGeocode数据源)
+ (NSDictionary *)connectAreaCodeWithMapPOI:(AMapPOI *)mapPOI;                                              //连接区号方法(通过AMapPOI数据源)
+ (NSDictionary *)connectAreaCodeWithPlacemark:(CLPlacemark *)placemark;                                    //连接区号方法(通过CLPlacemark数据源)

+ (NSString *)calculationDistanceWithLocationA:(CLLocation *)locationA locationB:(CLLocation *)locationB;   //计算距离方法

@end

NS_ASSUME_NONNULL_END
//=================================================================================================================================

