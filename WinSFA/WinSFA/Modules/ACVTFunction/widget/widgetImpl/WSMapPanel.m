//
//  WSMapPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMapPanel.h"
#import "WSMapView.h"
#import "I_W_BuildInfo.h"
#import "WSLocationManager.h"
#import  "WSStoreBean.h"

@interface WSMapPanel ()<WSMapViewDelegate>
{
    WSMapView  *mapView;
}

@end
@implementation WSMapPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    [self checkGpsIsStartOrNot:buildInfo];
    
    self.currentStore = [buildInfo getCurrentStore];
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.currentStore.latitude, self.currentStore.longitude);
    
    mapView = [[WSMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, k_MapViewWidth - 2*k_MapViewMargin, k_MapViewHeight) storeCoordinate:coordinate storeId:self.currentStore.Id storeName:self.currentStore.name];
    
    mapView.delegate = self;
    
    [mapView   locateCurrentLocation];
    
    [self addSubview:mapView];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, k_MapViewHeight+SPACEHEIGTH)];
}


-(void)checkGpsIsStartOrNot:(NSObject<I_W_BuildInfo> *)qst {
    
    if ([[qst getISRequire] isEqualToString:@"1"] &&  ![[WSLocationManager getInstance] currentLocationServicesEnabled]) {
        [self checkGpsAlertShow];
    }
    
}

- (void)checkGpsAlertShow {
    
    
    
    NSString*disPlayName =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    NSString *title= [NSString stringWithFormat:@"%@>%@",NSLocalizedString(@"应贵公司要求该模块需要强制开启GPS,开启路径:设置>隐私>定位服务", nil),disPlayName];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:nil];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"重试", nil) block:^{
        
        if ([[WSLocationManager getInstance] currentLocationServicesEnabled]) {
            
            [self   locationMe];
            
        } else {
            
            [self checkGpsAlertShow];
        }
    }];
    
    [alert addButtonWithTitle:NSLocalizedString(@"返回", nil) block:^{
        
       // [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [alert show];
}

-(void)locationMe{
    __weak typeof(self)  baseView = self;
    [[WSLocationManager getInstance] startGetLocationByAcceptableTimeInterval:kLocationRefreshTimeInterval * 0.5 withBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        __strong typeof(baseView) tmpBaseView = baseView;
        if (aLocationDescribe.location
            && (aLocationDescribe.location.coordinate.longitude != 0
                && aLocationDescribe.location.coordinate.latitude != 0)) {
                tmpBaseView.locationDescribe = aLocationDescribe;
                tmpBaseView.location = aLocationDescribe.location;
                
                tmpBaseView.isGpsReady = YES;
            
            } else if (error
                       && (aLocationDescribe.location.coordinate.longitude == 0
                           && aLocationDescribe.location.coordinate.latitude == 0)) {
                           LogError(@"获取位置失败,class:%@,error:%@",[tmpBaseView class], error);
                           [tmpBaseView secondUpdateLocaiton];
            
                       }
    }];
}


- (void)secondUpdateLocaiton {
    __weak typeof(self)  baseView = self;
    [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        __strong typeof(baseView) secondBaseView = baseView;
        if (aLocationDescribe.location
            && (aLocationDescribe.location.coordinate.longitude != 0
                && aLocationDescribe.location.coordinate.latitude != 0)) {
                secondBaseView.locationDescribe = aLocationDescribe;
                secondBaseView.location = aLocationDescribe.location;
                secondBaseView.isGpsReady = YES;
            }
    }];
}

#pragma mark -
#pragma mark WSMapViewDelegate method
- (void)mapView:(WSMapView *)mapView locationDescribe:(WSLocationDescribe *)aLocationDescribe{
    
    if (aLocationDescribe.location) {
        self.locationDescribe = aLocationDescribe;
        self.location = aLocationDescribe.location;
        self.isGpsReady = YES;
    } else {
        // 定位失败log
        LogInfo(@"locationDescribe.locationError---%@",aLocationDescribe.locationError);
    }
    
}

- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store{
    
    if (store) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:store forKey:SELECTED_MAP_STORE];
        [[NSNotificationCenter defaultCenter] postNotificationName:SELECT_MAP_STORE_NOTIFICATION object:nil userInfo:userInfo];
    }
}


-(NSObject *)getResultDirectly{
    
    return nil;
}
@end
