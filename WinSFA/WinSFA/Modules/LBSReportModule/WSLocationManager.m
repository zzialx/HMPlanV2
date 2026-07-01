//
//  WSLocationManager.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-6-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSLocationManager.h"
#import <CoordinateTransform/CoordinateTransform.h>
#import "WSResolveAddressManager.h"
#import "WSEnvrionment.h"
#import "WSBdLocationDataTable.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#define LOCATION_ACCURACY_NUMBER [[[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_ACCURACY] integerValue]

static const double Ea = 6378137;           //赤道半径标识
static const double Eb = 635672;            //极半径标识
static const double kDistanceFilterFg = 300;//前台定位距离标识
static const double kDistanceFilterBg = 500;//后台定位距离标识
//=============================================================================================================================================================================================

#pragma mark - 定位信息描述基地
@implementation WSLocationDescribe

#pragma mark - 根据距角度离计算新位置方法
+ (CLLocationCoordinate2D)getOffLocationWithAngle:(double)angle distance:(double)distance location:(CLLocationCoordinate2D)location {
    
    double dx = distance * sin(angle * M_PI / 180.0);
    double dy = distance * cos(angle * M_PI / 180.0);
    double ec = Eb + (Ea - Eb) * (90.0 - location.latitude) / 90.0;
    double ed = ec * cos(location.latitude * M_PI / 180);
    double newLon = (dx / ed + location.longitude * M_PI / 180.0) * 180.0 / M_PI;
    double newLat = (dy / ec + location.latitude * M_PI / 180.0) * 180.0 / M_PI;
    
    CLLocationCoordinate2D newLocation;
    newLocation.latitude = newLat;
    newLocation.longitude = newLon;
    return newLocation;
}

#pragma mark - 自定义初始化方法1
- (id)initWithCachedLocation:(CLLocation *)location error:(NSError *)error {
    
    self = [super init];
    if (self) {
        
        if (error) {
            self.locationError = error;
            self.location = location;
            return self;
        }
        
        NSUserDefaults *describeDefaults = [NSUserDefaults standardUserDefaults];
        self.detailAddress = [describeDefaults objectForKey:kGlobalAddress];
        self.cityName = [describeDefaults objectForKey:kGlobalCityName];
        self.provinceName = [describeDefaults objectForKey:kGlobalProvinceName];
    }
    
    return self;
}

#pragma mark - 自定义初始化方法2
- (id)initWithLocation:(CLLocation *)location cityName:(NSString *)cityName detailAddress:(NSString *)detailAddress error:(NSError *)error {
    
    self = [super init];
    if (self) {
        
        self.location = location;
        self.cityName = cityName;
        self.detailAddress = detailAddress;
        self.locationError = error;
    }
    
    return self;
}

@end
//=============================================================================================================================================================================================

#pragma mark - 地图注释大头针基地
@implementation Annotation
@synthesize typeCode = _typeCode;

#pragma mark - 自定义初始化方法
- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    
    self = [super init];
    if (self) {
        self.coordinate = coord;
    }
    return self;
}

#pragma mark - 设置中心点方法
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    
    self.coordinate = newCoordinate;
}

#pragma mark - 获取typeCode方法
- (NSString *)typeCode {
    
    return _typeCode;
}

#pragma mark - 获取title方法
- (NSString *)title {
    
    return self.typeCode;
}

@end
//=============================================================================================================================================================================================

#pragma mark - 定位管理器 延展(内部)
@interface WSLocationManager () {
    
    BOOL isLocationActive;              //是否主动获取定位标识
    BOOL isLocationForeground;          //是否APP活跃状态(前台)标识
    BOOL isUpdatingLocation;            //是否正在定位标识
    CLLocationCoordinate2D curLocation; //当前定位完成的坐标
}

@property (nonatomic, strong) CLLocationManager *locationManager;       //定位管理器
@property (nonatomic, strong) NSDate *lastSuccessReverseLocationDate;   //最后逆地理编码时间

@end
//=============================================================================================================================================================================================

#pragma mark - 定位管理器
@implementation WSLocationManager

#pragma mark - 获取共享实例方法
+ (WSLocationManager *)getInstance {
    
    static WSLocationManager *instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            
            instance = [[WSLocationManager alloc] init];
        }
        return instance;
    }
}

#pragma mark - 获取locationManager方法
- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.distanceFilter = 100.0f;
    }
    return _locationManager;
}

#pragma mark - 开始定位方法 isActive:主动获取/被动获取
- (void)startUpdatingLocationWithActive:(BOOL) isActive {
    
    LogInfo(@"WSLocationManager startUpdatingLocationWithActive isActive = %d", isActive);
    
    //判断app登陆下发标识 强制关闭定位服务时处理
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    if (![enableLocation isEqualToString:@"1"]) {
        
        LogInfo(@"WSLocationManager startUpdatingLocationWithActive enableLocation = %@ return", enableLocation);

        NSError *error = [NSError errorWithDomain:@"GPS" code:-1 userInfo:nil];
        [self locationManager:self.locationManager didFailWithError:error];
    
        return;
    }
    
    //判断app系统定位标识 未开启定位服务时处理
    if (![CLLocationManager locationServicesEnabled]) {
        
        LogInfo(@"WSLocationManager startUpdatingLocationWithActive locationServicesEnabled APP未启用定位权限服务(设置-隐私与安全性-关闭定位服务) return");
        
        NSError *error = [NSError errorWithDomain:@"GPS" code:-1 userInfo:nil];
        [self locationManager:self.locationManager didFailWithError:error];
        
        //延迟15秒后 再次尝试定位
        [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(performUpdateLocation) object:nil];
        [self performSelector:@selector(performUpdateLocation) withObject:nil afterDelay:15.0f];
        
        return;
    }
    
    //判断app定位权限 用户尚未对此应用程序做出选择时处理(未弹框)
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        
        BOOL passiveLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_PASSIVE_LOCATION] boolValue];
        LogInfo(@"WSLocationManager startUpdatingLocationWithActive kCLAuthorizationStatusNotDetermined passiveLocation = %d", passiveLocation);
        
        if (passiveLocation) {
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager performSelector:@selector(requestAlwaysAuthorization)];
            }
        }
        else {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            }
        }
    }
    
    //当前正在定位时处理 1.当前正在定位是主动定位(直接退出) 2.本次定位是被动定位(直接退出)
    if (isUpdatingLocation) {
        
        LogInfo(@"WSLocationManager startUpdatingLocationWithActive isUpdatingLocation = YES isLocationActive = %d isActive = %d", isLocationActive, isActive);
        
        if (isLocationActive) {
            return;
        }
        if (!isActive) {
            return;
        }
    }
    
    //清除定位信息
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(performUpdateLocation) object:nil];
    
    //启动定位
    isUpdatingLocation = YES;
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startLocationWithActive:isActive];
    });
    LogInfo(@"WSLocationManager startUpdatingLocationWithActive startLocation isActive = %d", isActive);
}

#pragma mark - 启动定位方法
- (void)startLocationWithActive:(BOOL)isActive {
    
    isUpdatingLocation = YES;
    isLocationForeground = [self isStateActive];
    isLocationActive = isActive;
    
    if (isLocationForeground) {
        self.locationManager.distanceFilter = kDistanceFilterFg;
    }
    else {
        self.locationManager.distanceFilter = kDistanceFilterBg;
    }
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    LogInfo(@"WSLocationManager startLocationWithActive isLocationForeground = %d isLocationActive = %d", isLocationForeground, isLocationActive);
}

#pragma mark - 停止定位方法
- (void)stopUpdatingLocationWithActive:(BOOL)isActive {
    
    LogInfo(@"WSLocationManager stopUpdatingLocationWithActive");
    
    isUpdatingLocation = NO;
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(performUpdateLocation) object:nil];
    [self performSelector:@selector(performUpdateLocation) withObject:nil afterDelay:kLocationRefreshTimeInterval];
}

#pragma mark - 实现locationManager:didFailWithError:协议(获取位置错误回调)
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    LogInfo(@"WSLocationManager locationManager:didFailWithError: error = %@", error);
    [self stopUpdatingLocationWithActive:NO];

    NSDictionary *userInfo = @{LBSManagerDidUpdatedLocationFinishedErrorKey : error};
    [[NSNotificationCenter defaultCenter] postNotificationName:LBSManagerDidUpdatedLocationFinishedNotification object:self userInfo:userInfo];
    
    NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
    [dateInfo setObject:error forKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:locationAddressManagerDidUpdatedFinishedNotification object:self userInfo:dateInfo];
    
    WSLocationDescribe *locationDescribe = nil;
    locationDescribe = [[WSLocationDescribe alloc] initWithLocation:nil cityName:nil detailAddress:nil error:error];
    locationDescribe.errorDescriptMessage = NSLocalizedString(@"gps_fail_lable", nil);

    if (self.locationBlock) {
        self.locationBlock(locationDescribe, error);
        self.locationBlock = nil;
    }
    
    if (self.cityInfoBlock) {
        self.cityInfoBlock(locationDescribe, error);
        self.cityInfoBlock = nil;
    }
}

#pragma mark - 实现locationManager:didUpdateLocations:协议(获取新位置后回调)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    LogInfo(@"WSLocationManager locationManager:didUpdateLocations: location = %@", location);
    [self locationManager:manager dealWithUpdatedLocation:location];
}

#pragma mark - 处理定位数据方法
- (void)locationManager:(CLLocationManager *)locationManager dealWithUpdatedLocation:(CLLocation *)updatedlocation {
    
    LogInfo(@"WSLocationManager locationManager:dealWithUpdatedLocation: updatedlocation = %@", updatedlocation);
    [self stopUpdatingLocationWithActive:isLocationForeground];
        
    CLLocation *wgs84Location = [[CLLocation alloc] initWithLatitude:updatedlocation.coordinate.latitude longitude:updatedlocation.coordinate.longitude];
    CLLocation *setupLocation = nil;
    
    //根据使用地图类型 进行对坐标设定
    if ([WSEnvrionment getUseBaiduMap]) {
            
        CLLocationCoordinate2D wgs84Coord = CLLocationCoordinate2DMake(wgs84Location.coordinate.latitude, wgs84Location.coordinate.longitude);
        CLLocationCoordinate2D bd09Coord = BMKCoordTrans(wgs84Coord, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
        setupLocation = [[CLLocation alloc] initWithLatitude:bd09Coord.latitude longitude:bd09Coord.longitude];
        LogInfo(@"WSLocationManager locationManager:dealWithUpdatedLocation: baidu updatedlocation = %@ wgs84Location = %@ setupLocation = %@", updatedlocation, wgs84Location, setupLocation);
    }
    else {
        
        if (![WSLocationManager isLocationOutOfChina:wgs84Location.coordinate]) {
            
            CLLocationCoordinate2D wgs84Coord = CLLocationCoordinate2DMake(wgs84Location.coordinate.latitude, wgs84Location.coordinate.longitude);
            CLLocationCoordinate2D gcj02Coord = [CoordinateTransform transCoordinate:wgs84Coord from:@"wgs84" to:@"gcj02"];
            setupLocation = [[CLLocation alloc] initWithLatitude:gcj02Coord.latitude longitude:gcj02Coord.longitude];
            LogInfo(@"WSLocationManager locationManager:dealWithUpdatedLocation: other 1 updatedlocation = %@ wgs84Location = %@ setupLocation = %@", updatedlocation, wgs84Location, setupLocation);
        }
        else {
            
            CLLocationCoordinate2D wgs84Coord = CLLocationCoordinate2DMake(wgs84Location.coordinate.latitude, wgs84Location.coordinate.longitude);
            setupLocation = [[CLLocation alloc] initWithLatitude:wgs84Coord.latitude longitude:wgs84Coord.longitude];
            LogInfo(@"WSLocationManager locationManager:dealWithUpdatedLocation: other 2 updatedlocation = %@ wgs84Location = %@ setupLocation = %@", updatedlocation, wgs84Location, setupLocation);
        }
    }
    
    WSLocationDescribe *locationDescribe = [[WSLocationDescribe alloc] initWithLocation:setupLocation cityName:nil detailAddress:nil error:nil];
    LogInfo(@"WSLocationManager locationManager:dealWithUpdatedLocation: locationDescribe = %@ isLocationForeground = %d 精度 = %f", locationDescribe, isLocationForeground, updatedlocation.horizontalAccuracy);
    
    double lat = setupLocation.coordinate.latitude;
    double lon = setupLocation.coordinate.longitude;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setDouble:lat forKey:kGlobalLatitude];
    [prefs setDouble:lon forKey:kGlobalLongitude];
    [prefs synchronize];
    
    curLocation = setupLocation.coordinate;
    [self reverseGeocodeLocation:locationDescribe];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:setupLocation forKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:LBSManagerDidUpdatedLocationFinishedNotification object:self userInfo:userInfo];

    if (isLocationForeground) {

        if (self.locationBlock) {
            self.locationBlock(locationDescribe, nil);
            self.locationBlock = nil;
        }
    }
}

#pragma mark - 逆地理编码方法
- (void)reverseGeocodeLocation:(WSLocationDescribe *)locationDes {
    
    CLLocationCoordinate2D actualCoordinate = locationDes.location.coordinate;
    LogInfo(@"WSLocationManager reverseGeocodeLocation 1 latitude = %.6f longitude = %.6f", actualCoordinate.latitude, actualCoordinate.longitude);
    
    if ([WSEnvrionment getuseGeoAmap]) {
        
        LogInfo(@"WSLocationManager reverseGeocodeLocation GeoAmap");
        __weak __typeof__(self) weakSelf = self;
        [[WSResolveAddressManager shareInstance] startGetFormattedAddressWith:actualCoordinate withBlock:^(AMapReGeocode *regeocode, NSError *error) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            LogInfo(@"WSLocationManager reverseGeocodeLocation GeoAmap result regeocode = %@, error = %@", regeocode, error);
            
            if (!error) {
                
                NSString *administrativeArea = regeocode.addressComponent.province;
                                 
                NSString *address = regeocode.formattedAddress;
                if (address) {
                    [[NSUserDefaults standardUserDefaults] setObject:address forKey:kGlobalAddress];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                                 
                NSString *cityName = regeocode.addressComponent.city;
                if (cityName.length == 0) {
                    cityName = administrativeArea;
                }
                [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:kGlobalCityName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                                 
                NSString *district = regeocode.addressComponent.district;
                if (district) {
                    [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:kGlobalDistrict];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                NSString * poiName = @"";
                if (regeocode.pois.count >0) {
                    AMapPOI * poiModel = regeocode.pois.firstObject;
                    poiName = poiModel.name;
                }
                
                locationDes.cityName = cityName;
                locationDes.detailAddress = address;
                locationDes.provinceName = administrativeArea?administrativeArea:cityName;
                locationDes.district = district;
                locationDes.subLocality = regeocode.addressComponent.district;
                locationDes.poiName = poiName;
                strongSelf.lastLocation = locationDes;
                
                WSBdLocationDataTable *bdLocationDataTable = [[WSBdLocationDataTable alloc] init];
                [bdLocationDataTable insertWithLocation:locationDes
                                          withTimeStamp:[NSNumber numberWithDouble:[[WSCurrentTime getTimeMillisString] doubleValue]]
                                     withDateTimeString:[WSCurrentTime getDateTime]];
                
                if (strongSelf.cityInfoBlock) {
                    strongSelf.cityInfoBlock(locationDes, nil);
                    strongSelf.cityInfoBlock = nil;
                }
   
                NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
                [dateInfo setObject:locationDes forKey:locationAddressManagerDidUpdatedFinishedKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:locationAddressManagerDidUpdatedFinishedNotification object:strongSelf userInfo:dateInfo];

                strongSelf.lastSuccessReverseLocationDate = [NSDate date];
            }
            else {
                
                locationDes.locationError = error;
                locationDes.errorDescriptMessage = NSLocalizedString(@"解析地理位置失败", nil);
                strongSelf.lastLocation = locationDes;
                                
                if (strongSelf.cityInfoBlock) {
                    strongSelf.cityInfoBlock(locationDes, error);
                    strongSelf.cityInfoBlock = nil;
                }
                                
                NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
                [dateInfo setObject:locationDes forKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:locationAddressManagerDidUpdatedFinishedNotification object:strongSelf userInfo:dateInfo];
            }
        }];
        
        return;
    }
    
    LogInfo(@"WSLocationManager reverseGeocodeLocation iOS原生");
    __weak __typeof__(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:locationDes.location completionHandler:^(NSArray *array, NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LogInfo(@"WSLocationManager reverseGeocodeLocation iOS原生 result placemark = %@, error = %@", [array firstObject], error);
        
        if (array.count > 0) {
            
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSString *administrativeArea = placemark.administrativeArea;
            NSString *locality = placemark.locality;
            NSString *subLocality = placemark.subLocality;
             
            NSString *address = placemark.name;
            address = [NSString headAppendExtraSourceStr:address withExtralStr:placemark.subThoroughfare];
            address = [NSString headAppendExtraSourceStr:address withExtralStr:placemark.thoroughfare];
            address = [NSString headAppendExtraSourceStr:address withExtralStr:placemark.subLocality];
            address = [NSString headAppendExtraSourceStr:address withExtralStr:placemark.locality];
            address = [NSString headAppendExtraSourceStr:address withExtralStr:placemark.administrativeArea];
             
            if (address) {
                [[NSUserDefaults standardUserDefaults] setObject:address forKey:kGlobalAddress];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
             
            NSString *cityName;
            if (locality) {
                cityName = locality;
            }
            else if (administrativeArea) {
                cityName = administrativeArea;
            }
            else {
                cityName = @"";
            }
             
            if (cityName) {
                [[NSUserDefaults standardUserDefaults] setObject:cityName forKey:kGlobalCityName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
     
            if (administrativeArea) {
                [[NSUserDefaults standardUserDefaults] setObject:administrativeArea forKey:kGlobalProvinceName];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
             
            locationDes.cityName = cityName;
            locationDes.detailAddress = address;
            locationDes.subLocality = subLocality;
            locationDes.provinceName = administrativeArea?administrativeArea:cityName;
            locationDes.subLocality = placemark.subLocality;
            strongSelf.lastLocation = locationDes;
             
            WSBdLocationDataTable *bdLocationDataTable = [[WSBdLocationDataTable alloc] init];
            [bdLocationDataTable insertWithLocation:locationDes withTimeStamp:[NSNumber numberWithDouble:[[WSCurrentTime getTimeMillisString] doubleValue]] withDateTimeString:[WSCurrentTime getDateTime]];
                 
            if (strongSelf.cityInfoBlock) {
                strongSelf.cityInfoBlock(locationDes, nil);
                strongSelf.cityInfoBlock = nil;
            }
                 
            NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
            [dateInfo setObject:locationDes forKey:locationAddressManagerDidUpdatedFinishedKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:locationAddressManagerDidUpdatedFinishedNotification object:strongSelf userInfo:dateInfo];

            strongSelf.lastSuccessReverseLocationDate = [NSDate date];
        }
        else {
            
            locationDes.locationError = error;
            locationDes.errorDescriptMessage = NSLocalizedString(@"解析地理位置失败", nil);
            strongSelf.lastLocation = locationDes;
                            
            if (strongSelf.cityInfoBlock) {
                strongSelf.cityInfoBlock(locationDes,error);
                strongSelf.cityInfoBlock = nil;
            }

            NSMutableDictionary *dateInfo = [NSMutableDictionary dictionary];
            [dateInfo setObject:locationDes forKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:locationAddressManagerDidUpdatedFinishedNotification object:strongSelf userInfo:dateInfo];
        }
    }];
}



#pragma mark - 执行更新定位方法
- (void)performUpdateLocation {
    
    if ([self isStateActive]) {
        [self startUpdatingLocationWithActive:NO];
    }
}

#pragma mark - 获取当前app应用状态是否为活跃状态(正在前台运行)方法
- (BOOL)isStateActive {
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    return (state == UIApplicationStateActive);
}

#pragma mark - 判断是不是在中国方法(算法参考：http://www.cnblogs.com/luxiaoxun/p/3722358.html)
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location {
    
    CGPoint point = CGPointMake(location.latitude, location.longitude);
    BOOL oddFlag = NO;
    NSInteger j = [self polygonOfChina].count - 1;
    
    for (NSInteger i = 0; i < [self polygonOfChina].count; i++) {

        CGPoint polygonPointi = [[self polygonOfChina][i] CGPointValue];
        CGPoint polygonPointj = [[self polygonOfChina][j] CGPointValue];
        if (((polygonPointi.y < point.y && polygonPointj.y >= point.y) || (polygonPointj.y < point.y && polygonPointi.y >= point.y)) &&
            (polygonPointi.x <= point.x || polygonPointj.x <= point.x)) {
            
            oddFlag ^= (polygonPointi.x + (point.y - polygonPointi.y) / (polygonPointj.y - polygonPointi.y) * (polygonPointj.x - polygonPointi.x) < point.x);
        }
        j = i;
    }
    
    return !oddFlag;
}

#pragma mark - 获取中国大陆坐标多边形方法(因为港澳台地区使用WGS坐标，所以多边形不包含港澳台地区)
+ (NSMutableArray *)polygonOfChina {
    
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



#pragma mark - 实时获取用户位置信息方法(地址位置)
- (void)startUpdateUserLocationWithBlock:(LUpdatesLocationInfoBlock)block {
    
    [self startUpdateUserLocationWithLocationBlock:nil cityInfoBlock:block];
}

#pragma mark - 实时获取用户位置信息方法(地址/逆编码)
- (void)startUpdateUserLocationWithLocationBlock:(LUpdatesLocationInfoBlock)locationBlock cityInfoBlock:(LUpdatesLocationInfoBlock)cityInfoBlock {
    
    if (locationBlock) {
        self.locationBlock = locationBlock;
    }
    if (cityInfoBlock) {
        self.cityInfoBlock = cityInfoBlock;
    }
    
    [self startUpdatingLocationWithActive:YES];
}

#pragma mark - 获得定位信息方法(优先返回缓存信息)
- (WSLocationDescribe *)startUpdatesCityInfoWithBlock:(LUpdatesLocationInfoBlock)block {

    if (block) {
        self.cityInfoBlock = block;
    }
    
    WSLocationDescribe *locationDescribe = [[WSLocationDescribe alloc] init];
    CLLocationCoordinate2D locationCoordinate2D;
    locationCoordinate2D.latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kGlobalLatitude];
    locationCoordinate2D.longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kGlobalLongitude];
    locationDescribe.location = [[CLLocation alloc]initWithLatitude:locationCoordinate2D.latitude longitude:locationCoordinate2D.longitude];
    locationDescribe.cityName = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];
    locationDescribe.detailAddress = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalAddress];
    locationDescribe.provinceName = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalProvinceName];
   
    [self startUpdatingLocationWithActive:NO];
    
    LogInfo(@"WSLocationManager startUpdatesCityInfoWithBlock locationDescribe = %@", locationDescribe);
    return locationDescribe;
}



#pragma mark - 登陆检测gps方法
- (NSDictionary *)checkLoginGps:(NSString *)gValue {
    
    BOOL allowToLogin = YES;
    NSMutableDictionary *checkDicionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *remindDictionary = nil;
    if ([gValue isEqualToString:@"0"]) {
        
        allowToLogin = YES;
    }
    else if([gValue isEqualToString:@"1"]) {
        
        remindDictionary = [self remindStartGPSAccordingTheConfig];
        allowToLogin = YES;
    }
    else if ([gValue isEqualToString:@"2"]) {
        
        remindDictionary = [self remindStartGPSAccordingTheConfig];
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            allowToLogin = YES;
        }
        else {
            allowToLogin = NO;
        }
    }
    else {
        allowToLogin = YES;
    }
    
    if (remindDictionary == nil) {
        [checkDicionary setObject:@"" forKey:@"remindMsg"];
    }
    else {
        [checkDicionary setObject: remindDictionary forKey:@"remindMsg"];
    }
    [checkDicionary setObject:[NSNumber numberWithBool:allowToLogin] forKey:@"allowToLogin"];
    
    LogInfo(@"WSLocationManager checkLoginGps gValue = %@ checkDicionary = %@", gValue, checkDicionary);
    return (NSDictionary *)checkDicionary;
}

#pragma mark - 提醒没有GPS访问权限则提示进入设置开启方法
- (BOOL)alterToForceObtainGPSWhenEnterOrLeaveStore {
    
    BOOL isRemindStartGps = NO;
    NSString *title = nil;
    NSString *message = nil;
    NSString *cancelButtonTitle = nil;
    if ([CLLocationManager locationServicesEnabled]) {
        
        BOOL isAuthorizedGPS = YES;
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse &&
            [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            isAuthorizedGPS = NO;
        }

        if (!isAuthorizedGPS) {
            
            title = NSLocalizedString(@"need_open_gps", nil);
            message = [NSString stringWithFormat:@"%@>%@",NSLocalizedString(@"default_gps_tip", nil),APP_DISPLAY_NAME];
            cancelButtonTitle = NSLocalizedString(@"confirm", nil);
            isRemindStartGps = YES;
        }
    }
    else {
        
        title = NSLocalizedString(@"need_authorize_gps", nil);
        message = NSLocalizedString(@"gps_setting_open", nil);
        cancelButtonTitle = NSLocalizedString(@"confirm", nil);
        isRemindStartGps = YES;
    }
    
    if (isRemindStartGps) {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
        [alert addButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{}];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert show];
    }
    
    return isRemindStartGps;
}

#pragma mark - 获取是否开启了定位功能方法
- (BOOL)currentLocationServicesEnabled {
    
    BOOL locationEnabled = NO;
    CLAuthorizationStatus authorizationState = [CLLocationManager  authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] &&
        ((authorizationState == kCLAuthorizationStatusAuthorizedAlways)||(authorizationState == kCLAuthorizationStatusAuthorizedWhenInUse)||(authorizationState == kCLAuthorizationStatusNotDetermined))) {
        locationEnabled = YES;
    }
    return locationEnabled;
}

#pragma mark - 检测gps定位配置方法
- (BOOL)checkConfigAndAuthorizationGps:(NSString *)isGps showAlert:(NSString *)partTitle {
    
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    if (!enableLocation || ![@"1" isEqualToString:enableLocation]) {
        return YES;
    }
    
    if (![isGps isEqualToString:@"R"]) {
        return YES;
    }
    
    return ![self alterToForceObtainGPSWhenEnterOrLeaveStore];
}

#pragma mark - 根据配置启动gps方法
- (NSMutableDictionary *)remindStartGPSAccordingTheConfig {
    
    BOOL isRemindStartGps = NO;
    NSString *title = nil;
    NSString *message = nil;
    NSString *cancelButtonTitle = nil;
    NSMutableDictionary *remindDictionary = [NSMutableDictionary dictionary];
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways ) {
            
            isRemindStartGps = YES;
            title = NSLocalizedString(@"gps_permission_title", nil);
            message = [NSString stringWithFormat:@"%@>%@",NSLocalizedString(@"gps_permission_tip", nil),APP_DISPLAY_NAME];
            cancelButtonTitle = NSLocalizedString(@"confirm", nil);
        }
        
        BOOL passiveLocation = [[[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_PASSIVE_LOCATION] boolValue];
        if (passiveLocation && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            
            isRemindStartGps = YES;
            title = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ? NSLocalizedString(@"gps_permission_title_limited", nil) : NSLocalizedString(@"gps_permission_title", nil);
            message= [NSString stringWithFormat:@"%@>%@>%@",NSLocalizedString(@"gps_permission_tip", nil),APP_DISPLAY_NAME, NSLocalizedString(@"select_always", nil)];
            cancelButtonTitle = NSLocalizedString(@"confirm", nil);
        }
    }
    else {
        
        isRemindStartGps = YES;
        title = NSLocalizedString(@"gps_permission_disable", nil);
        message = NSLocalizedString(@"gps_permission_tip", nil);
        cancelButtonTitle = NSLocalizedString(@"confirm", nil);
    }
    
    if (isRemindStartGps) {
        
        [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
        [[WSLocationManager getInstance] stopUpdatingLocationWithActive:YES];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLogin"]) {
            [remindDictionary setObject:title forKey:@"title"];
            [remindDictionary setObject:message forKey:@"message"];
            [remindDictionary setObject:cancelButtonTitle forKey:@"cancelButtonTitle"];
        }
        else {
            remindDictionary =  nil;
        }
    }
    else {
        remindDictionary =  nil;
    }
    
    return remindDictionary;
}



#pragma mark - 门店距离转换方法
+ (NSString *)convertDistance:(double)distance {
    
    if (distance < 1000.0f) {
        return [NSString stringWithFormat:@"%.f%@", distance, NSLocalizedString(@"loc_acc_unit", nil)];
    }
    else {
        return [NSString stringWithFormat:@"%.1f%@", (distance / 1000.0), NSLocalizedString(@"loc_acc_unit_km", nil)];
    }
}

#pragma mark - 计算门店与指定位置距离方法
+ (WSStoreBean *)calculateDistanceWith:(WSStoreBean *)store func:(WSFuncsBean *)func locationDescribe:(WSLocationDescribe *)locationDescribe isStoreList:(BOOL)isStoreList {
    
    NSString *distanceStr;
    double f_distance = CGFLOAT_MAX;
    store.f_distance = f_distance;
    
    if (store.latitude && store.longitude && locationDescribe) {
        CLLocation *storeLocation = [[CLLocation alloc]initWithLatitude:store.latitude longitude:store.longitude];
        f_distance = [[WSLocationManager getInstance] distanceUserLocattion:locationDescribe.location fromStoreLocation:storeLocation];
        distanceStr = [self convertDistance:f_distance];
    }
    
    if (distanceStr) {
        store.distance = distanceStr;
        store.f_distance=f_distance;
    }
    
    return store;
}

#pragma mark - 计算两点坐标距离方法
- (CLLocationDistance)distanceUserLocattion:(CLLocation *)ulocation fromStoreLocation:(CLLocation *)sLocation {

    MKMapPoint currentPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(ulocation.coordinate.latitude, ulocation.coordinate.longitude));
    MKMapPoint storePoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(sLocation.coordinate.latitude, sLocation.coordinate.longitude));
    CLLocationDistance distance = MKMetersBetweenMapPoints(currentPoint, storePoint);
    return distance;
}



#pragma mark - 获取是否全天被动位置上传方法
- (BOOL)isPassiveLocationAllDay {
    
    NSNumber *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_START_TIME];
    NSNumber *endTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_END_TIME];
    if (startTime.integerValue == 0 && endTime.integerValue == 24) {
        return YES;
    }
    return NO;
}

#pragma mark - 获取定位的开始时间方法
- (NSDate *)getLocationBeginDate {
    
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSNumber *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_START_TIME];
    
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [NSString stringWithFormat:@"%@ %@:00:00", bizDate, startTime];
    NSDate *startDate = [formatTime dateFromString:strDate];
    return startDate;
}

#pragma mark - 获取定位的结束时间方法
- (NSDate *)getLocationEndDate {
    
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSNumber *endTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_END_TIME];
    
    NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
    [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [NSString stringWithFormat:@"%@ %@:00:00", bizDate, endTime];
    NSDate *endDate = [formatTime dateFromString:strDate];
    return endDate;
}

#pragma mark - 检测当前时间是否在定位的时间间隔之内方法
- (BOOL)isCurrentTimeInLocationPeriod {
    
    if ([self isPassiveLocationAllDay]) {
        return YES;
    }
    
    NSNumber *startTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_START_TIME];
    NSNumber *endTime = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_END_TIME];
    NSDateFormatter *fomatter = [NSDateFormatter standardDateFormatter];
    [fomatter setDateFormat:@"HH"];
    NSString *time = [fomatter stringFromDate:[WSCurrentTime getCurrentServerDate]];
    if ([time integerValue] >= [startTime integerValue] && [time integerValue] < [endTime integerValue]) {
        return YES;
    }
    return NO;
}



#pragma mark - 生成上传数据(根据地址)方法
+ (NSDictionary *)getLocationUploadDataWithLocation:(CLLocation *)location andAddress:(NSString *)address {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setValue:@"wgs84" forKey:GPS_TYPE];
    [dic setValue:[NSString stringNotNilWithValue:address] forKey:GPS_LOC_ADDR];
    [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.altitude]]  forKey:GPS_HEI];
    [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.horizontalAccuracy]] forKey:GPS_HO];
    [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.verticalAccuracy]] forKey:GPS_VO];
    [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.speed]] forKey:GPS_S];
    [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.course]] forKey:GPS_D];
    
    if (location) {
        [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.coordinate.longitude]] forKey:GPS_LON];
        [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:location.coordinate.latitude]] forKey:GPS_LAT];
    }
    else {
        [dic setObject:@"null" forKey:GPS_LAT];
        [dic setObject:@"null" forKey:GPS_LON];
    }
    
    if (location.timestamp) {
        [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:ABS([location.timestamp timeIntervalSince1970])]] forKey:GPS_LOC_TIME];
        [dic setObject:[NSString stringWithValue:[NSNumber numberWithDouble:ABS([location.timestamp timeIntervalSinceNow]) * 1000]] forKey:GPS_CACHE_DURATION];
    }
    
    NSString *enable_gps = [CLLocationManager locationServicesEnabled] ? @"1" : @"0";
    [dic setObject:enable_gps forKey:GPS_ENABLE_GPS];
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
            
        case NotReachable: {
            [dic setObject:@"0" forKey:NETWORK_VALID];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWiFi: {
            [dic setObject:@"1" forKey:NETWORK_VALID];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"1" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"WIFI" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWWAN: {
            [dic setObject:@"1" forKey:NETWORK_VALID];
            [dic setObject:@"1" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"MOBILE" forKey:NETWORK_TYPE];
        }
            break;
            
        default:
            break;
    }
    
    LogInfo(@"WSLocationManager getLocationUploadDataWithLocation:andAddress: dic = %@", dic);
    return [dic copy];
}

#pragma mark - 生成上传数据(根据定位)方法
+ (NSDictionary *)getLocationUploadDataWithLocation:(CLLocation *)location andLocationDescribe:(WSLocationDescribe *)locationDescribe {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setValue:@"wgs84" forKey:GPS_TYPE];
    [dic setValue:[NSString stringNotNilWithValue:locationDescribe.detailAddress] forKey:GPS_LOC_ADDR];
    [dic setValue:[NSString stringNotNilWithValue:locationDescribe.provinceName] forKey:GPS_PROVINCE];
    [dic setValue:[NSString stringNotNilWithValue:locationDescribe.cityName] forKey:GPS_CITY];
    [dic setValue:[NSString stringNotNilWithValue:locationDescribe.subLocality] forKey:GPS_DISTRICT];
    [dic setObject:[NSNumber numberWithDouble:location.altitude] forKey:GPS_HEI];
    [dic setObject:[NSNumber numberWithDouble:location.horizontalAccuracy] forKey:GPS_HO];
    [dic setObject:[NSNumber numberWithDouble:location.verticalAccuracy] forKey:GPS_VO];
    [dic setObject:[NSNumber numberWithDouble:location.speed] forKey:GPS_S];
    [dic setObject:[NSNumber numberWithDouble:location.course] forKey:GPS_D];
    
    if (location) {
        [dic setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:GPS_LON];
        [dic setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:GPS_LAT];
    }
    else {
        [dic setObject:@"null" forKey:GPS_LAT];
        [dic setObject:@"null" forKey:GPS_LON];
    }
    
    if (location.timestamp) {
        [dic setObject:[NSNumber numberWithDouble:ABS([location.timestamp timeIntervalSince1970])] forKey:GPS_LOC_TIME];
        [dic setObject:[NSNumber numberWithDouble:ABS([location.timestamp timeIntervalSinceNow]) * 1000] forKey:GPS_CACHE_DURATION];
    }
    
    NSString *enable_gps = [CLLocationManager locationServicesEnabled] ? @"1" : @"0";
    [dic setObject:enable_gps forKey:GPS_ENABLE_GPS];
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (status) {
            
        case NotReachable: {
            [dic setObject:@"0" forKey:NETWORK_VALID];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"" forKey:NETWORK_TYPE];
        }
            break;
    
        case ReachableViaWiFi: {
            [dic setObject:@"1" forKey:NETWORK_VALID];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"1" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"WIFI" forKey:NETWORK_TYPE];
        }
            break;
            
        case ReachableViaWWAN: {
            [dic setObject:@"1" forKey:NETWORK_VALID];
            [dic setObject:@"1" forKey:NETWORK_ENABLE_MOBILE];
            [dic setObject:@"0" forKey:NETWORK_ENABLE_WIFI];
            [dic setObject:@"MOBILE" forKey:NETWORK_TYPE];
        }
            break;
            
        default:
            break;
    }
    
    LogInfo(@"WSLocationManager getLocationUploadDataWithLocation:andLocationDescribe: dic = %@", dic);
    return [dic copy];
}

@end
//=============================================================================================================================================================================================
