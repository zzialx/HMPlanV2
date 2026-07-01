//
//  WSTLAlertManager.m
//  WinSFA
//
//  Created by mwj on 2021/8/10.
//  Copyright © 2021 WinChannel. All rights reserved.
//

#import "WSTLAlertManager.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSEnvrionment.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <AMapLocationKit/AMapLocationCommonObj.h>

@implementation WSTLAlertManager

#pragma mark - 添加导航选择提示框方法
+ (void)addMapNavigationCustomAlertViewWithStorebean:(WSStoreBean *)storebean {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"please_select", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *baiduAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"baidu_map_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [WSTLAlertManager jumpBaiduMapWithLatitude:storebean.latitude longitude:storebean.longitude];
    }];
    UIAlertAction *gaodeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"gaode_map_title", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [WSTLAlertManager jumpGaodeMapWithLatitude:storebean.latitude longitude:storebean.longitude];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel_label", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:baiduAction];
    [alertController addAction:gaodeAction];
    [alertController addAction:cancelAction];
    
    UIViewController *currentVC = [[WSApplicationWindowsRelationManager sharedManager] getCurrentVC];
    [currentVC presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 跳转百度地图方法
+ (void)jumpBaiduMapWithLatitude:(double)latitude longitude:(double)longitude {
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"install_baidu", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *urlString = nil;
    if ([WSEnvrionment getUseBaiduMap]) {
        
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", latitude, longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D bd09Coord = BMKCoordTrans(coordinate, BMK_COORDTYPE_COMMON, BMK_COORDTYPE_BD09LL);
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", bd09Coord.latitude, bd09Coord.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D bd09Coord = BMKCoordTrans(coordinate, BMK_COORDTYPE_GPS, BMK_COORDTYPE_BD09LL);
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=bd09ll", bd09Coord.latitude, bd09Coord.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
    LogInfo(@"WSTLAlertManager jumpBaiduMapWithLatitude: urlString %@  latitude = %f longitude = %f", urlString, latitude, longitude);
}

#pragma mark - 跳转高德地图方法
+ (void)jumpGaodeMapWithLatitude:(double)latitude longitude:(double)longitude {
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"install_gaode", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *urlString = nil;
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *urlScheme = @"winsfa";
    
    if ([WSEnvrionment getUseBaiduMap]) {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D gaodeCoordinate = AMapLocationCoordinateConvert(coordinate, AMapLocationCoordinateTypeBaidu);
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, gaodeCoordinate.latitude, gaodeCoordinate.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else if ([WSEnvrionment getuseGeoAmap]) {
        
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, latitude, longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationCoordinate2D gaodeCoordinate = AMapLocationCoordinateConvert(coordinate, AMapLocationCoordinateTypeGPS);
        urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dev=0&m=0&t=0",
                               appName, urlScheme, gaodeCoordinate.latitude, gaodeCoordinate.longitude];
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    
    LogInfo(@"WSTLAlertManager jumpGaodeMapWithLatitude urlString %@  latitude = %f longitude = %f", urlString, latitude, longitude);
}

@end
