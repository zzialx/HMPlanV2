//
//  WSLocationManager.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-6-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "WSStoreBean.h"
#import "WSFuncsBean.h"

#define kLocationRefreshTimeInterval 480.0f //前台定位间隔时间

//定位完成通知标识
static NSString *const LBSManagerDidUpdatedLocationFinishedNotification = @"LBSManagerDidUpdatedLocationFinishedNotification";
static NSString *const LBSManagerDidUpdatedLocationFinishedLocationKey = @"LBSManagerDidUpdatedLocationFinishedLocationKey";
static NSString *const LBSManagerDidUpdatedLocationFinishedErrorKey = @"LBSManagerDidUpdatedLocationFinishedErrorKey";
//逆地理编码完成通知标识
static NSString *const locationAddressManagerDidUpdatedFinishedNotification = @"locationAddressManagerDidUpdatedFinishedNotification";
static NSString *const locationAddressManagerDidUpdatedFinishedKey = @"locationAddressManagerDidUpdatedFinishedKey";
static NSString *const locationAddressManagerDidUpdatedFinishedNotificationErrorKey = @"locationAddressManagerDidUpdatedFinishedNotificationErrorKey";
//================================================================================================================================================================================================

#pragma mark - 定位信息描述基地
@interface WSLocationDescribe : NSObject

@property (nonatomic, copy) NSString *cityName;                 //城市名称
@property (nonatomic, copy) NSString *detailAddress;            //详细地址
@property (nonatomic, copy) NSString *provinceName;             //省份名称
@property (nonatomic, copy) NSString *district;                 //地区
@property (nonatomic, copy) NSString *subLocality;              //子级区域
@property (nonatomic, copy) NSString *poiName;                  //模糊区域

@property (nonatomic, strong) CLLocation *location;             //位置
@property (nonatomic, strong) NSError *locationError;           //位置错误信息
@property (nonatomic, strong) NSString *errorDescriptMessage;   //错误描述信息

+ (CLLocationCoordinate2D)getOffLocationWithAngle:(double)angle distance:(double)distance
                                         location:(CLLocationCoordinate2D)location;         //根据距角度离计算新位置方法
- (id)initWithCachedLocation:(CLLocation *)location error:(NSError *)error;                 //自定义初始化方法1
- (id)initWithLocation:(CLLocation *)location cityName:(NSString *)cityName
         detailAddress:(NSString *)detailAddress error:(NSError *)error;                    //自定义初始化方法2

@end
//================================================================================================================================================================================================

#pragma mark - 地图注释大头针基地
@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;                        //标题
@property (nonatomic, copy) NSString *subtitle;                     //子标题
@property (nonatomic, copy) NSString *locationType;                 //定位类型
@property (nonatomic, readonly, copy) NSString *typeCode;           //类型编码
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;  //位置信息
    
- (id)initWithLocation:(CLLocationCoordinate2D)coord;       //自定义初始化方法
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;//设置中心点方法

@end
//================================================================================================================================================================================================

typedef void(^LUpdatesLocationInfoBlock)(WSLocationDescribe* aLocationDescribe, NSError *error); //定义更新定位完成闭包

#pragma mark - 定位管理器
@interface WSLocationManager : NSObject <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, copy) LUpdatesLocationInfoBlock locationBlock;//定位完成闭包
@property (nonatomic, copy) LUpdatesLocationInfoBlock cityInfoBlock;//逆地理编码完成闭包
@property (nonatomic, strong) WSLocationDescribe *lastLocation;     //最后一次定位信息

+ (WSLocationManager *)getInstance;                                                                             //获取共享实例方法
- (void)startUpdatingLocationWithActive:(BOOL)isActive;                                                         //开始定位方法 isActive:主动获取/被动获取
- (void)stopUpdatingLocationWithActive:(BOOL)isActive;                                                          //停止定位方法

- (void)startUpdateUserLocationWithBlock:(LUpdatesLocationInfoBlock)block;                                      //实时获取用户位置信息方法(地址位置)
- (void)startUpdateUserLocationWithLocationBlock:(LUpdatesLocationInfoBlock)locationBlock
                                   cityInfoBlock:(LUpdatesLocationInfoBlock)cityInfoBlock;                      //实时获取用户位置信息方法(地址/逆编码)
- (WSLocationDescribe *)startUpdatesCityInfoWithBlock:(LUpdatesLocationInfoBlock)block;                         //获得定位信息方法

- (NSDictionary *)checkLoginGps:(NSString *)gValue;                                                             //登陆检测gps方法
- (BOOL)alterToForceObtainGPSWhenEnterOrLeaveStore;                                                             //提醒没有GPS访问权限则提示进入设置开启方法
- (BOOL)currentLocationServicesEnabled;                                                                         //获取是否开启了定位功能方法
- (BOOL)checkConfigAndAuthorizationGps:(NSString *)isGps showAlert:(NSString *)partTitle;                       //检测gps定位配置方法

+ (NSString *)convertDistance:(double)distance;                                                                 //门店距离转换方法
+ (WSStoreBean *)calculateDistanceWith:(WSStoreBean *)store func:(WSFuncsBean *)func
                      locationDescribe:(WSLocationDescribe *)locationDescribe isStoreList:(BOOL)isStoreList;    //计算门店与指定位置距离方法
- (CLLocationDistance)distanceUserLocattion:(CLLocation *)ulocation fromStoreLocation:(CLLocation *)sLocation;  //计算两点坐标距离方法

- (BOOL)isPassiveLocationAllDay;                                                                                //获取是否全天被动位置上传方法
- (NSDate *)getLocationBeginDate;                                                                               //获取定位的开始时间方法
- (NSDate *)getLocationEndDate;                                                                                 //获取定位的结束时间方法
- (BOOL)isCurrentTimeInLocationPeriod;                                                                          //检测当前时间是否在定位的时间间隔之内方法

+ (NSDictionary *)getLocationUploadDataWithLocation:(CLLocation *)location andAddress:(NSString *)address;      //生成上传数据(根据地址)方法
+ (NSDictionary *)getLocationUploadDataWithLocation:(CLLocation *)location
                                andLocationDescribe:(WSLocationDescribe *)locationDescribe;                     //生成上传数据(根据定位)方法


@end
//================================================================================================================================================================================================
