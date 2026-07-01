//
//  WSNeighborStoreController.m
//  WinSFA
//
//  Created by Nemo on 14-3-5.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSNeighborStoreController.h"
#import "WSRequestHelper.h"

@interface WSNeighborStoreController ()

{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D coordinate;
    CLLocationDistance altitude;
    LOCATION_STATE locationState;
}

- (void)loadMapView;
- (void)configLocationManager;
- (void)upDateDatas;
- (void)neighborStoreResponse:(id)resp;

@end


@implementation WSNeighborStoreController

- (id)initWithFuncs:(WSFuncsBean *)funcs
{
    if (self = [super init])
    {
        self.currentFuncs = funcs;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self addFuncsOtherBeanView];
    [self addOptView];

    [self loadMapView];
    [self configLocationManager];
}

- (void)loadMapView
{
    CGRect mapRect = self.view.frame;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        mapRect.size = CGSizeMake(CGRectGetHeight(mapRect), CGRectGetWidth(mapRect));
    }
    
    mapView = [[MKMapView alloc] initWithFrame:mapRect];
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;

    MKCoordinateRegion region ={coordinate,span};
    [mapView setRegion:region];
    
    mapView.showsUserLocation = YES;
    [[self view] addSubview:mapView];
}


- (void)configLocationManager
{
    locationManager = [[CLLocationManager alloc]init];
    if (![CLLocationManager locationServicesEnabled]) {        
        NSString *title = NSLocalizedString(@"请开启定位功能", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else {
        // 设置状态
        locationState = LOCATION_STATE_GETTING;
        //设置代理
        [locationManager setDelegate:self];
        //设置精准度，
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager startUpdatingLocation];
    }
}


- (void)upDateDatas
{
    locationState = LOCATION_STATE_RECEIVED;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(neighborStoreResponse:)
                                                 name:NeighborStore_notify
                                               object:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (!empId) {
        empId = @"no data";
    }
    [dic setObject:empId forKey:@"empId"];
    [dic setObject:@"1" forKey:@"compress"];
    [dic setObject:@"neighborStore" forKey:@"objId"];
    [dic setObject:[[NSString alloc] initWithFormat:@"%f",coordinate.longitude] forKey:GPS_LON];
    [dic setObject:[[NSString alloc] initWithFormat:@"%f",coordinate.latitude] forKey:GPS_LAT];
    
    [[WSRequestHelper shareInstance] postRequestData:dic notifyName:NeighborStore_notify];
}



- (void)neighborStoreResponse:(id)resp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NeighborStore_notify object:nil];
    if (!resp) {        return;    }
    NSString *datas = [[resp userInfo] objectForKey:DATAS];
    if (!datas) {        return;    }
    NSDictionary *dic = [datas objectFromJSONString];
    if (!dic) {        return;    }
    NSArray *neighborStoreArray = [dic objectForKey:@"neighborStore"];
    if (!neighborStoreArray) {        return;    }
    
    NSMutableArray *storeArray = [[NSMutableArray alloc] initWithCapacity:neighborStoreArray.count];
    NSMutableArray *pinArr = [[NSMutableArray alloc] initWithCapacity:neighborStoreArray.count];
    for (NSDictionary *storeDic in neighborStoreArray) {
        // isPlan参数是乱写的 在此处没有意义
        WSStoreBean *store = [[WSStoreBean alloc] initNeighborStoreWithDic:storeDic];
        if (store) {
            [storeArray addObject:store];
            CLLocationCoordinate2D anndiante;
            anndiante.latitude = store.latitude + 0.00000011;
            anndiante.longitude = store.longitude + 0.00000012;
            WSNeighborPin *pin = [[WSNeighborPin alloc] initWithCoordinate2D:anndiante tittle:store.name subtitle:@""];
            [pinArr addObject:pin];
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mapView addAnnotations:pinArr];
    });
}


#pragma mark-
#pragma locationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    coordinate = [newLocation coordinate];
    altitude = [newLocation altitude];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    MKCoordinateRegion region ={coordinate,span};
    [mapView setRegion:region];
    
    if (locationState == LOCATION_STATE_RECEIVED) {
        [manager stopUpdatingLocation];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self upDateDatas];
    });
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{   //定位失败
}














@end
