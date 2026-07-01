//
//  WinRPMapViewController.m
//  WinSFA
//
//  Created by yuanji on 2019/7/10.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WinRPMapViewController.h"
#import <MapKit/MapKit.h>
#import "WinRPMapUserAnnotation.h"
#import "WinRPMapUserAnnotationView.h"
#import "WinRPMapStoreAnnotation.h"
#import "WinRPMapStoreAnnotationView.h"
#import "WinRPMapTableViewCell.h"
#import "WinRPMapPOI.h"
#import "WinRPMapLocationManager.h"
#import "WinRPMapPoiManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "WinRPMapTool.h"
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(内部)
@interface WinRPMapViewController ()

@property (nonatomic, strong) WinRPMapLocationManager *locationManager; //定位管理器
@property (nonatomic, strong) WinRPMapPoiManager *poiManager;           //poi管理器
@property (nonatomic, strong) MKMapView *rpMapView;                     //地图视图
@property (nonatomic, strong) WSSearchBar *rpSearchBar;                 //搜索框
@property (nonatomic, strong) UIButton *rpResetButton;                  //重置按键
@property (nonatomic, strong) UITableView *rpTableView;                 //表视图
@property (nonatomic, strong) WinRPMapUserAnnotation *userAnnotation;   //用户注释
@property (nonatomic, strong) WinRPMapStoreAnnotation *storeAnnotation; //商户注释
@property (nonatomic, strong) NSMutableArray *poiArray;                 //poi数组
@property (nonatomic, assign) NSInteger currentSelectIndex;             //当前选择索引

- (void)uploadDataClick:(id)sender;                                     //上传数据按键响应方法
- (void)rpResetButtonClick:(id)sender;                                  //重置按键响应方法

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(工具)
@interface WinRPMapViewController (Tools)

- (void)bindView;                                                               //绑定视图方法
- (void)setupLayout;                                                            //设置布局方法
- (void)startLocation;                                                          //启动定位方法
- (void)setMapRegionCenterWithLocation:(CLLocationCoordinate2D)coordinate;      //设置地图中心点区域方法
- (void)reverseGeocodeLocation;                                                 //逆向地理编码位置方法
- (void)queryPeripheryPoi;                                                      //查询周围poi方法

- (void)createUserAnnotationWithMapPOI:(WinRPMapPOI *)mapPOI;                   //创建用户大头针方法
- (void)createStoreAnnotationWithMapPOI:(WinRPMapPOI *)mapPOI;                  //创建商户大头针方法
- (WinRPMapPOI *)createUserPoiWithMapReGeocode:(AMapReGeocode *)mapReGeocode;   //创建用户poi方法(针对高德解析)
- (WinRPMapPOI *)createUserPoiWithPlacemark:(CLPlacemark *)placemark;           //创建用户poi方法(针对系统解析)
- (void)createGaoDePoiItemWithArray:(NSArray *)array isSuccess:(BOOL)isSuccess; //创建poi项目方法(针高德)
- (void)createApplePoiItemWithArray:(NSArray *)array isSuccess:(BOOL)isSuccess; //创建poi项目方法(针系统)

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现WinRPMapLocationManagerDelegate代理协议)
@interface WinRPMapViewController (mapLocationManagerDelegate) <WinRPMapLocationManagerDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现WinRPMapPoiManagerDelegate代理协议)
@interface WinRPMapViewController (mapPoiManagerDelegate) <WinRPMapPoiManagerDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现MKMapViewDelegate代理协议)
@interface WinRPMapViewController (mapViewDelegate) <MKMapViewDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现UISearchBarDelegate代理协议)
@interface WinRPMapViewController (searchBarDelegate) <UISearchBarDelegate>

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现UITableViewDelegate/UITableViewDataSource代理协议)
@interface WinRPMapViewController (tableViewDelegateAndDataSource) <UITableViewDelegate, UITableViewDataSource>

@end
//=================================================================================================================================

#pragma mark - RP地图管理器
@implementation WinRPMapViewController

#pragma mark - 获取locationManager方法
- (WinRPMapLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[WinRPMapLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

#pragma mark - 获取poiManager方法
- (WinRPMapPoiManager *)poiManager {
    
    if (!_poiManager) {
        _poiManager = [[WinRPMapPoiManager alloc] init];
        _poiManager.delegate = self;
    }
    return _poiManager;
}

#pragma mark - 获取rpMapView方式
- (MKMapView *)rpMapView {
    
    if (!_rpMapView) {
        _rpMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _rpMapView.mapType = MKMapTypeStandard;
        _rpMapView.showsUserLocation = NO;
        _rpMapView.zoomEnabled = YES;
        _rpMapView.scrollEnabled = YES;
        _rpMapView.delegate = self;
    }
    return _rpMapView;
}

#pragma mark - 获取rpSearchBar方法
- (WSSearchBar *)rpSearchBar {
    
    if (!_rpSearchBar) {
        _rpSearchBar = [[WSSearchBar alloc] initWithFrame:CGRectZero];
        _rpSearchBar.backViewColor = [UIColor clearColor];
        _rpSearchBar.searchBar.delegate = self;
        _rpSearchBar.alpha = 0.9f;
        if (_searchPlaceholder && _searchPlaceholder.length > 0) {
            _rpSearchBar.searchBar.placeholder = NSLocalizedString(_searchPlaceholder, nil);
        } else {
            _rpSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
        }
    }
    return _rpSearchBar;
}

#pragma mark - 获取rpResetButton方法
- (UIButton *)rpResetButton {
    
    if (!_rpResetButton) {
        _rpResetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rpResetButton.backgroundColor = [UIColor clearColor];
        [_rpResetButton setImage:[UIImage imageForName:@"map_direction_locaton"] forState:UIControlStateNormal];
        [_rpResetButton addTarget:self action:@selector(rpResetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rpResetButton;
}

#pragma mark - 获取rpTableView方法
- (UITableView *)rpTableView {
    
    if (!_rpTableView) {
        _rpTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [_rpTableView setBackgroundColor:[UIColor whiteColor]];
        _rpTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _rpTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _rpTableView.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        _rpTableView.delegate = self;
        _rpTableView.dataSource = self;
    }
    return _rpTableView;
}

#pragma mark - 获取poiArray方法
- (NSMutableArray *)poiArray {
    
    if (!_poiArray) {
        _poiArray = [[NSMutableArray alloc] init];
    }
    return _poiArray;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self bindView];
    [self startLocation];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _locationManager.delegate = nil;
    _poiManager.delegate = nil;
    _rpMapView.delegate = nil;
    _rpTableView.delegate = nil;
    _rpTableView.dataSource = nil;
    _rpSearchBar.searchBar.delegate = nil;
    [_rpSearchBar resignFirstResponder];
}

#pragma mark - 重写viewWillLayoutSubviews方法
- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    [self setupLayout];
}

#pragma mark - 上传数据按键响应方法
- (void)uploadDataClick:(id)sender {
    
    if (self.confirmBlock) {
        WinRPMapPOI *poiData = [self.poiArray objectAtIndex:self.currentSelectIndex];
        if (self.locationManager.locationIsChina) {
            CLLocationCoordinate2D currentCoordinate = poiData.currentLocation.coordinate;
            CLLocationCoordinate2D wgs84Coordinate = [WinRPMapTool getWgs84coordinateWithGcj02coordinate:currentCoordinate];
            CLLocation *wgs84Location = [[CLLocation alloc] initWithLatitude:wgs84Coordinate.latitude longitude:wgs84Coordinate.longitude];
            poiData.wgs84Location = wgs84Location;
        } else {
            CLLocationCoordinate2D currentCoordinate = poiData.currentLocation.coordinate;
            CLLocation *wgs84Location = [[CLLocation alloc] initWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
            poiData.wgs84Location = wgs84Location;
        }
        self.confirmBlock(poiData);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 重置按键响应方法
- (void)rpResetButtonClick:(id)sender {
    
    self.currentSelectIndex = 0;
    [self.poiArray removeAllObjects];
    [self.rpTableView reloadData];
    
    if (self.userAnnotation) {
        [self.rpMapView removeAnnotation:self.userAnnotation];
        self.userAnnotation = nil;
    }
    if (self.storeAnnotation) {
        [self.rpMapView removeAnnotation:self.storeAnnotation];
        self.storeAnnotation = nil;
    }
    
    [self startLocation];
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(工具)
@implementation WinRPMapViewController (Tools)

#pragma mark - 绑定视图方法
- (void)bindView {
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"confirm", nil)
                                                                        style:UIBarButtonItemStylePlain target:self action:@selector(uploadDataClick:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.rpMapView];
    [self.view addSubview:self.rpSearchBar];
    [self.view addSubview:self.rpResetButton];
    [self.view addSubview:self.rpTableView];
}

#pragma mark - 设置布局方法
- (void)setupLayout {
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = CGRectGetHeight(self.view.frame) / 2;
    self.rpMapView.frame = CGRectMake(x, y, w, h);
    
    x = 15.0f;
    y = 10.0f;
    w = CGRectGetWidth(self.view.frame) - 30.0f;
    h = 32.0f;
    self.rpSearchBar.frame = CGRectMake(x, y, w, h);
    
    UIImage *image = [UIImage imageForName:@"map_direction_locaton"];
    x = 15.0f;
    y = CGRectGetMaxY(self.rpMapView.frame) - 20.0f - image.size.height;
    w = image.size.width;
    h = image.size.height;
    self.rpResetButton.frame = CGRectMake(x, y, w, h);
    
    x = 0.0f;
    y = CGRectGetMaxY(self.rpMapView.frame);
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.rpMapView.frame);
    self.rpTableView.frame = CGRectMake(x, y, w, h);
}

#pragma mark - 启动定位方法
- (void)startLocation {
    
    NSString *hudText = NSLocalizedString(@"update_data_tip", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:hudText tips:nil tapTarget:nil action:nil];
    __weak WinRPMapViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [weakSelf.locationManager startLocation];
    });
}

#pragma mark - 设置地图中心点区域方法
- (void)setMapRegionCenterWithLocation:(CLLocationCoordinate2D)coordinate {
    
    MKCoordinateRegion region;
    region.span = MKCoordinateSpanMake(0.002f, 0.002f);
    region.center = coordinate;
    [self.rpMapView setRegion:region animated:NO];
}

#pragma mark - 逆向地理编码位置方法
- (void)reverseGeocodeLocation {
    
    if (self.locationManager.locationIsChina) {
        [self.poiManager queryGaoDeReGoecodeSearchWithLocation:self.locationManager.location];
    } else {
        [self.poiManager queryAppleReGoecodeSearchWithLocation:self.locationManager.location];
    }
}

#pragma mark - 查询周围poi方法
- (void)queryPeripheryPoi {
    
    NSString *queryStr = @"";
    if (self.searchPOI && self.searchPOI.length > 0) {
        queryStr = self.searchPOI;
    }
    if (self.rpSearchBar.searchBar.text && self.rpSearchBar.searchBar.text.length > 0) {
        queryStr = self.rpSearchBar.searchBar.text;
    }
    
    if (self.searchRange.length == 0 && queryStr.length > 0) {
        if (self.locationManager.locationIsChina) {
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
            [infoDic setObject:queryStr forKey:WinMapPoiSearchKeywordsMrak];
            [self.poiManager queryGaoDePoiKeywordsSearchWithLocation:self.locationManager.location auxiliaryInfo:infoDic];
        } else {
            if (queryStr.length <= 0) {
                queryStr = NSLocalizedString(@"apple_poi_search", nil);
            }
            NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
            [infoDic setObject:queryStr forKey:WinMapPoiSearchKeywordsMrak];
            [self.poiManager queryApplePoiKeywordsSearchWithLocation:self.locationManager.location auxiliaryInfo:infoDic];
        }
        return;
    }
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    [infoDic setObject:(self.searchCount.length > 0 ? self.searchCount : @"20") forKey:WinMapPoiSearchCountMrak];
    [infoDic setObject:(self.searchRange.length > 0 ? self.searchRange : @"3000") forKey:WinMapPoiSearchRadiusMrak];
    if (self.locationManager.locationIsChina) {
        [infoDic setObject:queryStr forKey:WinMapPoiSearchKeywordsMrak];
        [self.poiManager queryGaoDePoiAroundSearchWithLocation:self.locationManager.location auxiliaryInfo:infoDic];
    } else {
        if (queryStr.length <= 0) {
            queryStr = NSLocalizedString(@"apple_poi_search", nil);
        }
        [infoDic setObject:queryStr forKey:WinMapPoiSearchKeywordsMrak];
        [self.poiManager queryApplePoiAroundSearchWithLocation:self.locationManager.location auxiliaryInfo:infoDic];
    }
}

#pragma mark - 创建用户大头针方法
- (void)createUserAnnotationWithMapPOI:(WinRPMapPOI *)mapPOI {
    
    if (self.userAnnotation) {
        [self.rpMapView removeAnnotation:self.userAnnotation];
        self.userAnnotation = nil;
    }
    if (self.storeAnnotation) {
        [self.rpMapView removeAnnotation:self.storeAnnotation];
        self.storeAnnotation = nil;
    }
    
    __weak WinRPMapViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf setMapRegionCenterWithLocation:mapPOI.currentLocation.coordinate];
        
        WinRPMapUserAnnotation *annotation = [[WinRPMapUserAnnotation alloc] init];
        annotation.title = mapPOI.name;
        annotation.subtitle = mapPOI.address;
        annotation.coordinate = mapPOI.currentLocation.coordinate;
        [weakSelf.rpMapView addAnnotation:annotation];
        weakSelf.userAnnotation = annotation;
        [weakSelf.rpMapView selectAnnotation:annotation animated:NO];
    });
}

#pragma mark - 创建商户大头针方法
- (void)createStoreAnnotationWithMapPOI:(WinRPMapPOI *)mapPOI {
    
    if (self.storeAnnotation) {
        [self.rpMapView removeAnnotation:self.storeAnnotation];
        self.storeAnnotation = nil;
    }
    
    __weak WinRPMapViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf setMapRegionCenterWithLocation:mapPOI.currentLocation.coordinate];
        
        WinRPMapStoreAnnotation *annotation = [[WinRPMapStoreAnnotation alloc] init];
        annotation.title = mapPOI.name;
        annotation.subtitle = mapPOI.address;
        annotation.coordinate = mapPOI.currentLocation.coordinate;
        [self.rpMapView addAnnotation:annotation];
        self.storeAnnotation = annotation;
        [self.rpMapView selectAnnotation:annotation animated:NO];
    });
}

#pragma mark - 创建用户poi方法(针对高德解析)
- (WinRPMapPOI *)createUserPoiWithMapReGeocode:(AMapReGeocode *)mapReGeocode {
    
    if (!mapReGeocode) {
        WinRPMapPOI *mapPOI = [[WinRPMapPOI alloc] init];
        mapPOI.name = [NSString stringWithFormat:@"%@", NSLocalizedString(@"map_current", nil)];
        mapPOI.currentLocation = self.locationManager.location;
        return mapPOI;
    }
    
    WinRPMapPOI *mapPOI = [[WinRPMapPOI alloc] init];
    mapPOI.name = [NSString stringWithFormat:@"%@", NSLocalizedString(@"map_current", nil)];
    mapPOI.address = (mapReGeocode.formattedAddress.length > 0) ? mapReGeocode.formattedAddress : @"";
    mapPOI.currentLocation = self.locationManager.location;
    mapPOI.provinceCityDistricy = [WinRPMapTool connectProvinceCityDistricyWithMapReGeocode:mapReGeocode];
    mapPOI.areaCodeDic = [WinRPMapTool connectAreaCodeWithMapReGeocode:mapReGeocode];
    return mapPOI;
}

#pragma mark - 创建用户poi方法(针对系统解析)
- (WinRPMapPOI *)createUserPoiWithPlacemark:(CLPlacemark *)placemark {
    
    if (!placemark) {
        WinRPMapPOI *mapPOI = [[WinRPMapPOI alloc] init];
        mapPOI.name = [NSString stringWithFormat:@"%@", NSLocalizedString(@"map_current", nil)];
        mapPOI.currentLocation = self.locationManager.location;
        return mapPOI;
    }
    
    WinRPMapPOI *mapPOI = [[WinRPMapPOI alloc] init];
    mapPOI.name = [NSString stringWithFormat:@"%@", NSLocalizedString(@"map_current", nil)];
    mapPOI.address = [WinRPMapTool connectAddressWithPlacemark:placemark];
    mapPOI.currentLocation = self.locationManager.location;
    mapPOI.provinceCityDistricy = [WinRPMapTool connectprovinceCityDistricyWithPlacemark:placemark];
    mapPOI.areaCodeDic = [WinRPMapTool connectAreaCodeWithPlacemark:placemark];
    return mapPOI;
}

#pragma mark - 创建poi项目方法(针高德)
- (void)createGaoDePoiItemWithArray:(NSArray *)array isSuccess:(BOOL)isSuccess {
    
    if (isSuccess) {
        for (AMapPOI *poi in array) {
            WinRPMapPOI *item = [[WinRPMapPOI alloc] init];
            item.name = poi.name;
            item.address = [WinRPMapTool connectAddressWithMapPOI:poi];
            item.provinceCityDistricy = [WinRPMapTool connectProvinceCityDistricyWithMapPOI:poi];
            item.areaCodeDic = [WinRPMapTool connectAreaCodeWithMapPOI:poi];
            item.currentLocation = [[CLLocation alloc] initWithLatitude:poi.location.latitude longitude:poi.location.longitude];
            item.distance = [WinRPMapTool calculationDistanceWithLocationA:self.locationManager.location locationB:item.currentLocation];
            [self.poiArray addObject:item];
        }
        
        [self.rpTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        if (array.count <= 0) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"no_store_can_choose", nil)
                                     tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
        }
        return;
    }
    
    [self.rpTableView reloadData];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"Failed_to_query_peripheral_data", nil)
                             tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

#pragma mark - 创建poi项目方法(针系统)
- (void)createApplePoiItemWithArray:(NSArray *)array isSuccess:(BOOL)isSuccess {
    
    if (isSuccess) {
        for (MKMapItem *mapItem in array) {
            WinRPMapPOI *item = [[WinRPMapPOI alloc] init];
            item.name = mapItem.name;
            item.address = [WinRPMapTool connectAddressWithPlacemark:mapItem.placemark];
            item.provinceCityDistricy = [WinRPMapTool connectAddressWithPlacemark:mapItem.placemark];
            item.areaCodeDic = [WinRPMapTool connectAreaCodeWithPlacemark:mapItem.placemark];
            item.currentLocation = [[CLLocation alloc] initWithLatitude:mapItem.placemark.location.coordinate.latitude
                                                              longitude:mapItem.placemark.location.coordinate.longitude];
            item.distance = [WinRPMapTool calculationDistanceWithLocationA:self.locationManager.location locationB:item.currentLocation];
            [self.poiArray addObject:item];
        }
        
        [self.rpTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
        if (array.count <= 0) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"no_store_can_choose", nil)
                                     tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeText];
        }
        return;
    }
    
    [self.rpTableView reloadData];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"Failed_to_query_peripheral_data", nil)
                             tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现WinRPMapLocationManagerDelegate代理协议)
@implementation WinRPMapViewController (mapLocationManagerDelegate)

#pragma mark - 定位成功方法
- (void)locationSuccess:(WinRPMapLocationManager *)manager successData:(CLLocation *)location {
    
    [self.locationManager stopLocation];
    [self reverseGeocodeLocation];
}

#pragma mark - 定位失败方法
- (void)locationFailed:(WinRPMapLocationManager *)manager failedData:(NSError *)error {
    
    [self.locationManager stopLocation];
    
    NSString *message = [NSString stringWithFormat:@"%@>%@", NSLocalizedString(@"gps_permission_title", nil), APP_DISPLAY_NAME];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现WinRPMapPoiManagerDelegate代理协议)
@implementation WinRPMapViewController (mapPoiManagerDelegate)

#pragma mark - 逆地址编码成功方法(针对高德)
- (void)queryGaoDeReGoecodeSearchSuccess:(WinRPMapPoiManager *)manager successData:(AMapReGeocode *)regeocode {
    
    WinRPMapPOI *userMapPOI = [self createUserPoiWithMapReGeocode:regeocode];
    [self.poiArray addObject:userMapPOI];
    [self createUserAnnotationWithMapPOI:userMapPOI];
    [self queryPeripheryPoi];
}

#pragma mark - 逆地址编码失败方法(针对高德)
- (void)queryGaoDeReGoecodeSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    WinRPMapPOI *userMapPOI = [self createUserPoiWithMapReGeocode:nil];
    [self.poiArray addObject:userMapPOI];
    [self createUserAnnotationWithMapPOI:userMapPOI];
    [self queryPeripheryPoi];
}

#pragma mark - poi成功方法(针对高德-周边查询)
- (void)queryGaoDePoiAroundSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray {
    
    [self createGaoDePoiItemWithArray:poiArray isSuccess:YES];
}

#pragma mark - poi失败方法(针对高德-周边查询)
- (void)queryGaoDePoiAroundSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    [self createGaoDePoiItemWithArray:nil isSuccess:NO];
}

#pragma mark - poi成功方法(针对高德-关键字查询)
- (void)queryGaoDePoiKeywordsSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray {
    
    [self createGaoDePoiItemWithArray:poiArray isSuccess:YES];
}

#pragma mark - poi失败方法(针对高德-关键字查询)
- (void)queryGaoDePoiKeywordsSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    [self createGaoDePoiItemWithArray:nil isSuccess:NO];
}

#pragma mark - 逆地址编码成功方法(针对苹果)
- (void)queryAppleReGoecodeSearchSuccess:(WinRPMapPoiManager *)manager successData:(CLPlacemark *)placemark {
    
    WinRPMapPOI *userMapPOI = [self createUserPoiWithPlacemark:placemark];
    [self.poiArray addObject:userMapPOI];
    [self createUserAnnotationWithMapPOI:userMapPOI];
    [self queryPeripheryPoi];
}

#pragma mark - 逆地址编码失败方法(针对苹果)
- (void)queryAppleReGoecodeSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    WinRPMapPOI *userMapPOI = [self createUserPoiWithPlacemark:nil];
    [self.poiArray addObject:userMapPOI];
    [self createUserAnnotationWithMapPOI:userMapPOI];
    [self queryPeripheryPoi];
}

#pragma mark - poi成功方法(针对苹果-周边查询)
- (void)queryApplePoiAroundSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray {
    
    [self createApplePoiItemWithArray:poiArray isSuccess:YES];
}

#pragma mark - poi失败方法(针对苹果-周边查询)
- (void)queryApplePoiAroundSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    [self createApplePoiItemWithArray:nil isSuccess:NO];
}

#pragma mark - poi成功方法(针对苹果-关键字查询)
- (void)queryApplePoiKeywordsSearchSuccess:(WinRPMapPoiManager *)manager successData:(NSArray *)poiArray {
    
    [self createApplePoiItemWithArray:poiArray isSuccess:YES];
}

#pragma mark - poi失败方法(针对苹果-关键字查询)
- (void)queryApplePoiKeywordsSearchFailed:(WinRPMapPoiManager *)manager failedData:(NSError *)error {
    
    [self createApplePoiItemWithArray:nil isSuccess:NO];
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现MKMapViewDelegate代理协议)
@implementation WinRPMapViewController (mapViewDelegate)

#pragma mark - 实现mapView:viewForAnnotation:协议方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[WinRPMapUserAnnotation class]]) {
        WinRPMapUserAnnotationView *annotationView = (WinRPMapUserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"mapUserAnnotation"];
        if (!annotationView) {
            annotationView = [[WinRPMapUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mapUserAnnotation"];
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[WinRPMapStoreAnnotation class]]) {
        WinRPMapStoreAnnotationView *annotationView = (WinRPMapStoreAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"mapStoreAnnotation"];
        if (!annotationView) {
            annotationView = [[WinRPMapStoreAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mapStoreAnnotation"];
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    
    return nil;
}

#pragma mark - 实现mapView:didDeselectAnnotationView:协议方法
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[WinRPMapUserAnnotationView class]]) {
        [(WinRPMapUserAnnotationView *)view hideCalloutView];
    } else if ([view isKindOfClass:[WinRPMapStoreAnnotationView class]]) {
        [(WinRPMapStoreAnnotationView *)view hideCalloutView];
    }
}

#pragma mark - 实现mapView:didSelectAnnotationView:协议方法
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view isKindOfClass:[WinRPMapUserAnnotationView class]]) {
        [(WinRPMapUserAnnotationView *)view showCalloutView];
    } else if ([view isKindOfClass:[WinRPMapStoreAnnotationView class]]) {
        [(WinRPMapStoreAnnotationView *)view showCalloutView];
    }
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现UISearchBarDelegate代理协议)
@implementation WinRPMapViewController (searchBarDelegate)

#pragma mark - 实现searchBarTextDidBeginEditing:协议
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - 实现searchBarCancelButtonClicked:协议
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark - 实现searchBarSearchButtonClicked:协议
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if (!self.locationManager.location) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"locate_the_current_location_first", nil)
                                 tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    [self rpResetButtonClick:nil];
}

@end
//=================================================================================================================================

#pragma mark - RP地图管理器 延展(实现UITableViewDelegate/UITableViewDataSource代理协议)
@implementation WinRPMapViewController (tableViewDelegateAndDataSource)

#pragma mark - 实现tableView:numberOfRowsInSection:协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.poiArray.count;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WinRPMapPOI *cellData = [self.poiArray objectAtIndex:indexPath.row];
    return [WinRPMapTableViewCell getCellHeightWithTableView:tableView data:cellData];
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *mapTableViewCellIdentifier = @"mapTableViewCellIdentifier";
    WinRPMapTableViewCell *mapTableViewCell = [tableView dequeueReusableCellWithIdentifier:mapTableViewCellIdentifier];
    if(!mapTableViewCell) {
        mapTableViewCell = [[WinRPMapTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mapTableViewCellIdentifier];
        [mapTableViewCell setBackgroundColor:[UIColor clearColor]];
        [mapTableViewCell setAccessoryType:UITableViewCellAccessoryNone];
        [mapTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    WinRPMapPOI *setCellData = [self.poiArray objectAtIndex:indexPath.row];
    BOOL isSelectState = (self.currentSelectIndex == indexPath.row) ? YES : NO;
    [mapTableViewCell setCellData:setCellData isSelectState:isSelectState];
    return mapTableViewCell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.currentSelectIndex == indexPath.row) {
        return;
    }
    
    self.currentSelectIndex = indexPath.row;
    [tableView reloadData];
    
    WinRPMapPOI *setCellData = [self.poiArray objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        [self createUserAnnotationWithMapPOI:setCellData];
    } else {
        [self createStoreAnnotationWithMapPOI:setCellData];
    }
}

@end
//=================================================================================================================================

