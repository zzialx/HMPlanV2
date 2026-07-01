//
//  BGLogation.m
//  WinSFA
//
//  Created by mac on 2018/8/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "BGLogation.h"
#import "BGTask.h"
#import "WSInoutStoreTable.h"
#import "WSRequestHelper.h"
#import "WSVisitStoreStatusTable.h"
#import "WSApplicationWindowsRelationManager.h"

@interface BGLogation()
{
    BOOL isCollect;
}
@property (strong , nonatomic) BGTask *bgTask; //后台任务
@property (strong , nonatomic) NSTimer *restarTimer; //重新开启后台任务定时器
@property (strong , nonatomic) NSTimer *closeCollectLocationTimer; //关闭定位定时器 （减少耗电）
@end
@implementation BGLogation
//初始化
-(instancetype)init
{
    if(self == [super init])
    {
        //
        _bgTask = [BGTask shareBGTask];
        isCollect = NO;
        //监听进入后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endStore) name:END_STORE object:nil];

    }
    return self;
}
+(CLLocationManager *)shareBGLocation
{
    static CLLocationManager *_locationManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //_locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    });
    return _locationManager;
}
//后台监听方法
-(void)applicationEnterBackground
{
    NSLog(@"come in background");
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];

    if (!inOutStoreObj.memo1) {
        return;
    }
    CLLocationManager *locationManager = [BGLogation shareBGLocation];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    [_bgTask beginNewBackgroundTask];
}
//重启定位服务
-(void)restartLocation
{
    NSLog(@"重新启动定位");
    CLLocationManager *locationManager = [BGLogation shareBGLocation];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // 不移动也可以后台刷新回调
    if ([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    [self.bgTask beginNewBackgroundTask];
}
//开启服务
- (void)startLocation {
    NSLog(@"开启定位");
    
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            
            CLLocationManager *locationManager = [BGLogation shareBGLocation];
            locationManager.delegate = self;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            if([[UIDevice currentDevice].systemVersion floatValue]>= 8.0) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
    }
}

//停止后台定位
-(void)stopLocation
{
    NSLog(@"停止定位");
    isCollect = NO;
    CLLocationManager *locationManager = [BGLogation shareBGLocation];
    [locationManager stopUpdatingLocation];
}
#pragma mark --delegate
//定位回调里执行重启定位和关闭定位
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    
    //旧址
    CLLocation *currentLocation = [locations lastObject];
    
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (!inOutStoreObj.memo1) {
        return;
    }
    CLLocation *orig=[[CLLocation alloc] initWithLatitude:[inOutStoreObj.in_lat doubleValue]  longitude:[inOutStoreObj.in_lon doubleValue]];
    CLLocation* dist=[[CLLocation alloc] initWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    CLLocationDistance distance=[orig distanceFromLocation:dist];

    NSLog(@"现在的距离有多少%lf",distance);
    //如果正在10秒定时收集的时间，不需要执行延时开启和关闭定位
    if (isCollect) {
        return;
    }
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]  objectForKey:AUTOMATIC_DEPARTURE];
    NSInteger time = [[dic objectForKey:@"time"] integerValue];
    NSInteger remindDistance = [[dic objectForKey:@"distance"] integerValue];
    NSInteger autoDistance = [[dic objectForKey:@"autoDistance"] integerValue];


    if (distance > remindDistance) {

        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        BOOL result = (state == UIApplicationStateBackground);
        NSString *title = NSLocalizedString(@"js_alert_title", nil);
        
        NSString *message = [NSString stringWithFormat:@"您距离门店的位置已经超过%ld米，超过%ld米会自动离店",remindDistance,autoDistance];
        
        if(distance > autoDistance)
        {
            message = [NSString stringWithFormat:@"您距离门店的位置已经超过%ld米，已离开%@",autoDistance,inOutStoreObj.memo1];
            [self popToRoot];
        }
        if (!result) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            WSAppDelegate * deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
            
            [deleget createLocalNotificationWithTitle:title message:message];
        }
        
        if(distance > autoDistance)
            [self upload:currentLocation inoutStoreTable:inOutStoreObj];
    }
    [self performSelector:@selector(restartLocation) withObject:nil afterDelay:time];
    [self performSelector:@selector(stopLocation) withObject:nil afterDelay:10];
    isCollect = YES;//标记正在定位
}
- (void)popToRoot
{
    UIViewController *con =  [self windowCurrentShowViewController];
    //            UIViewController *crm = [self getCurrentVC];
    LogError(@"没有跳转的情况的试图%@",con);
    [con.navigationController popToRootViewControllerAnimated:NO];
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (!inOutStoreObj.memo1) {
        return;
    }

    switch([error code])
    {

        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启后台服务" message:@"应用没有不可以定位，需要在在设置/通用/后台应用刷新开启" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [self popToRoot];
            [self outStore:@"" administrativeArea:@"" cityName:@"" subLocality:@"" location:nil inoutStoreTable:inOutStoreObj];
        }
            break;
        default:
        {
            if([self dateTimeDifferenceWithStartTime:[inOutStoreObj.intime doubleValue]])
            {
                return;
            }
            [self popToRoot];
            [self outStore:@"" administrativeArea:@"" cityName:@"" subLocality:@"" location:nil inoutStoreTable:inOutStoreObj];
        }
            break;
    }
}
- (void)upload:(CLLocation*)location inoutStoreTable:(WSInoutStoreObject*)inoutStoreTable
{
    if (!inoutStoreTable.memo1) {
        return;
    }
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __weak __typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
        
        if (array.count > 0) {
            LogInfo(@"解析地理位置成功---- [array count] == %ld",(unsigned long)[array count]);
            //显示用gcj02
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSString *administrativeArea = placemark.administrativeArea; // state, eg. CA
            NSString *locality = placemark.locality; // city, eg. Cupertino
            NSString *subLocality = placemark.subLocality;
            NSString *address = placemark.name;
            // 详细地址
            if (address) {
                [[NSUserDefaults standardUserDefaults] setObject:address forKey:kGlobalAddress];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            // 城市名称
            // 取城市名称，如果没有取省份名称
            NSString *cityName;
            if (locality) {
                cityName = locality;
            } else if(administrativeArea) {
                cityName = administrativeArea;
            }else{
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
            [weakSelf outStore:address administrativeArea:administrativeArea cityName:cityName subLocality:subLocality location:location inoutStoreTable:inoutStoreTable];

        }
        else
        {
            LogInfo(@"解析地理位置失败---- error:%@",error.localizedDescription);
            if([self dateTimeDifferenceWithStartTime:[inoutStoreTable.intime doubleValue]])
            {
                return;
            }

            [self popToRoot];
            [self outStore:@"" administrativeArea:@"" cityName:@"" subLocality:@"" location:location inoutStoreTable:inoutStoreTable];

        }
    }];
}
- (void)outStore:(NSString*)address administrativeArea:(NSString*)administrativeArea cityName:(NSString*)cityName subLocality:(NSString*)subLocality location:(CLLocation*)location inoutStoreTable:(WSInoutStoreObject*)inoutStoreTable
{

    NSMutableDictionary *jsonData = [NSMutableDictionary dictionaryWithCapacity:0];
    [jsonData setObject:[NSString stringNotNilWithValue:address] forKey:@"loc_addr"];
    [jsonData setObject:[NSString stringNotNilWithValue:administrativeArea?administrativeArea:cityName] forKey:@"province"];
    [jsonData setObject:[NSString stringNotNilWithValue:cityName] forKey:@"city"];
    [jsonData setObject:[NSString stringNotNilWithValue:subLocality]  forKey:@"district"];
    [jsonData setObject:[NSString stringNotNilWithValue:address] forKey:@"loc_addr"];
    [jsonData setObject: location ? [NSString stringWithFormat:@"%lf",location.coordinate.latitude] : @"" forKey:@"lat"];
    [jsonData setObject: location ? [NSString stringWithFormat:@"%lf",location.coordinate.longitude] : @"" forKey:@"lon"] ;
    //            [jsonData setObject:[NSString stringWithFormat:@"%lf",location.coordinate.longitude] forKey:@"locTime"];
    
    NSMutableDictionary *enterleave = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [enterleave setObject:[NSString stringNotNilWithValue:inoutStoreTable.visit_id] forKey:@"id"];
    [enterleave setObject:@"V20S99" forKey:@"fv"];
    [enterleave setObject:[NSString stringNotNilWithValue:inoutStoreTable.store_id] forKey:@"store"];
    [enterleave setObject:jsonData ? :@"" forKey:@"jsonData"];

    [enterleave setObject:@"F20S01_99" forKey:@"method"];
    [enterleave setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"account"];
    [enterleave setObject:[WSCurrentTime getTimeMillisString] forKey:@"mobileClickTime"];
    [enterleave setObject:@"F20S01_99" forKey:@"index"];
    [enterleave setObjectSafe:[WSAppData getObjectbyKey:SERVERREQUIRE]  forKey:SERVERREQUIRE];
    [enterleave setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"syncDate"];
    NSString *sysTime = [WSCurrentTime getTimeString];
    [enterleave setObject:[NSString stringNotNilWithValue:sysTime] forKey:@"syncTime"];
    
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,@"V20S99"];
    //            BOOL insertDataSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:inoutStoreTable.visit_id IsPhoto:NO NotifyName:notifyID];
    //            if (!insertDataSucceed) {
    //                return insertDataSucceed;
    //            }
    
    
    BOOL insertDataSucceed = [[WSOffLineUploadTable sharedTable] insertUploadData:[enterleave JSONString] URL:URL_UPLOAD MD5:inoutStoreTable.visit_id IsPhoto:NO NotifyName:notifyID];
    
    if (!insertDataSucceed) {
        LogInfo(@"本地保存自动离线数据失败");
        return ;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:AUTO_END_STORE object:nil userInfo:nil];
    
    [self endLocation];
    
    [[WSCustomTimeTable sharedTable] updateCustomTimeFinishedWithStoreId:inoutStoreTable.store_id withVisitId:inoutStoreTable.visit_id];
    
    
    [[WSRequestHelper shareInstance] postRequestOnEnterLeaveStorebyData: [enterleave JSONString]
                                                                    md5:inoutStoreTable.visit_id
                                                             notifyName:notifyID];
    [[WSVisitStoreStatusTable shareInstance] updateStatusWithStoreId:inoutStoreTable.store_id funcCode:inoutStoreTable.modulefc empId:inoutStoreTable.emp_id withStatus:@"1"];
    
    [[WSVisitStoreActionTable sharedTable] updateStatusWithStoreId:inoutStoreTable.store_id funcCode:inoutStoreTable.func_code empId:inoutStoreTable.emp_id withStatus:@"1"];
    
    [[WSInoutStoreTable sharedTable] updateLeaveStoreTime:inoutStoreTable.store_id andOtherParam:inoutStoreTable.visit_id];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
    


}
- (void)endStore
{
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    NSString *unLeavedStoreName = inOutStoreObj.memo1;
    if (!unLeavedStoreName) {
        [self endLocation];
    }
}
- (void)endLocation
{
    [self stopLocation];
    
    [_bgTask endBackGroundTask:YES];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
#pragma mark - 获取窗口当前显示视图管理器方法
- (UIViewController *)windowCurrentShowViewController
{
//    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    UIViewController *viewController = [self getCurrentVCWithRootVC:rootViewController];
    return viewController;
}

#pragma mark - 从根视图管理器获取当前视图管理器方法 rootVC:根视图管理器
- (UIViewController *)getCurrentVCWithRootVC:(UIViewController *)rootVC
{
    if ([rootVC presentedViewController])
        rootVC = [rootVC presentedViewController];
    
    UIViewController *currentVC = nil;
    if ([rootVC isKindOfClass:[UITabBarController class]])
        currentVC = [self getCurrentVCWithRootVC:[(UITabBarController *)rootVC selectedViewController]];
    else if ([rootVC isKindOfClass:[UINavigationController class]])
        currentVC = [self getCurrentVCWithRootVC:[(UINavigationController *)rootVC visibleViewController]];
    else
        currentVC = rootVC;
    
    return currentVC;
}
//SFA-24621 【SFA泸州老窖】【iOS】无网络情况下进店，会直接离店，日志见附件
- (BOOL)dateTimeDifferenceWithStartTime:(double)startTime{
    
    NSDate *after = [NSDate date];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:startTime];
    
    NSInteger timeL = [after timeIntervalSinceDate:date];
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]  objectForKey:AUTOMATIC_DEPARTURE];
    NSInteger time = [[dic objectForKey:@"time"] integerValue];
    return time > timeL;
    LogInfo(@"结束拜访耗时比较耗时:%f",[after timeIntervalSinceDate:date]);
    
}

//- (UIViewController *)getCurrentVC {
//
//    UIViewController *result = nil;
//
//    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//    do {
//        if ([rootVC isKindOfClass:[UINavigationController class]]) {
//            UINavigationController *navi = (UINavigationController *)rootVC;
//            UIViewController *vc = [navi.viewControllers lastObject];
//            result = vc;
//            rootVC = vc.presentedViewController;
//            continue;
//        } else if([rootVC isKindOfClass:[UITabBarController class]]) {
//            UITabBarController *tab = (UITabBarController *)rootVC;
//            result = tab;
//            rootVC = [tab.viewControllers objectAtIndex:tab.selectedIndex];
//            continue;
//        } else if([rootVC isKindOfClass:[UIViewController class]]) {
//            result = rootVC;
//            rootVC = nil;
//        }
//    } while (rootVC != nil);
//
//    return result;
//}
@end

