//
//  WSMapPanel.m
//  WinSFA
//
//  Created by winchannel on 15/3/12.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMapPanel.h"
#import "WinNewMapView.h"
#import "WinNewLocationManager.h"
#import "WSStoreBean.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"
#import "WSUserAnnotationView.h"
#import "WSInterAction.h"
#import "WSNestedAcvtModel.h"
#import "WSCenterAnotationView.h"
#import "CoordinateTransform.h"
#import "WSEnterStoreAcvtViewController.h"
#import "WSResolveAddressManager.h"
#import "WSEnvrionment.h"
#import "WSAcvtScrollView.h"
#import "I_W_BuildInfo.h"
#import "I_Lua_Target_Operator.h"
#import "I_W_DisplayValue.h"
//=============================================================================================================================================================

#pragma mark - 地图面板 延展(内部)
@interface WSMapPanel ()

@property (nonatomic, strong) WinNewMapView *mapView;                   //地图视图(新的)
@property (nonatomic, strong) WinNewLocationManager *locationManager;   //定位管理器(新的)
@property (nonatomic, assign) CLLocationCoordinate2D storedisCoordinate;//门店坐标
@property (nonatomic, assign) BOOL mapIsMoved;                          //地图是否移动过
@property (nonatomic, assign) BOOL isUploading;                         //当前是否正在上传(上传过程中不需要定位)
@property (nonatomic, assign) BOOL isUserLastRedis;                     //使用上次定位数据
@property (nonatomic, assign) BOOL isSign;                              //标识是否点击签到
@property (nonatomic, copy) NSString *distanceRange;                    //记录脚本传的异常打卡范围
@property (nonatomic, copy) NSString *valueForLua;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) BOOL isRefreshLocation;                   //是否二次刷新

@end
//=============================================================================================================================================================

#pragma mark - 地图面板 延展(工具)
@interface WSMapPanel (Tools)

- (void)requestLocationWithIsHUD:(BOOL)isHUD;                                           //请求定位方法
- (void)locationFailWithError:(NSError *)error;                                         //定位失败方法
- (void)locationSuccessWithLocationDescribe:(WinNewLocationDescribe *)locationDescribe; //定位成功方法

@end
//=============================================================================================================================================================

#pragma mark - 地图面板 延展(实现WinNewMapViewDelegate代理协议)
@interface WSMapPanel (newMapViewDelegate) <WinNewMapViewDelegate>

@end
//=============================================================================================================================================================

#pragma mark - 地图面板
@implementation WSMapPanel

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    
    return [super initWithFrame:frame];
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    _locationManager = nil;
    _mapView.delegate = nil;
    _mapView = nil;
}

#pragma mark - 重写layoutSubviews方法
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat mapview_x = MAIN_PADDING;
    CGFloat mapview_y = MAIN_PADDING;
    self.mapView.frame = CGRectMake(mapview_x, mapview_y, self.width - 2 * mapview_x, self.height - 2 * mapview_y);
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    self.currentStore = model.currentStore;
    self.mapReadOnly = [xbuildInfo getReadOnly];
    self.mapInitDate = [NSDate date];
    self.mapIsMoved = NO;
    
    double latitud = 0;
    double longtitud = 0;
    NSString *latLonArray = (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if ([latLonArray isKindOfClass:[NSString class]] && [latLonArray length] > 0) {
        
        NSArray *valueArray = [latLonArray componentsSeparatedByString:@","];
        if ([valueArray count] == 2) {
            latitud = [[valueArray firstObject] doubleValue];
            longtitud = [[valueArray lastObject] doubleValue];
            self.storedisCoordinate = CLLocationCoordinate2DMake(latitud, longtitud);
            self.hasRedisLocation = YES;
        }
        
        if (latitud == 0 && longtitud == 0) {
            NSMutableDictionary *dict = [latLonArray mutableObjectFromJSONString];
            latitud = [[dict objectForKey:@"lat"] doubleValue];
            longtitud = [[dict objectForKey:@"lon"] doubleValue];
            self.storedisCoordinate = CLLocationCoordinate2DMake(latitud, longtitud);
            self.hasRedisLocation = YES;
        }
    }
    
    BOOL isCenterForStoreLocation = YES;
    if ([(WSEnterStoreAcvtViewController *)model.ownAcvtViewController isKindOfClass:[WSEnterStoreAcvtViewController class]] || [self.mapReadOnly isEqualToString:@"1"]) {
        isCenterForStoreLocation = NO;
    }
    if ([[xbuildInfo getLocationType] isEqualToString:@"0"] || [[xbuildInfo getLocationType] isEqualToString:@"2"]) {
        isCenterForStoreLocation = YES;
    }
    
    BOOL isShowAddress = YES;
    NSString *description = [xbuildInfo getQstDescription];
    if ([description containsString:@"IS_NOT_SHOW_ADDRESS"]) {
        isShowAddress = NO;
    }
    
    CGFloat mapview_x = MAIN_PADDING;
    CGFloat mapview_y = MAIN_PADDING;
    CGRect rect = CGRectMake(mapview_x, mapview_y, self.width - 2 * mapview_x, MAP_CELL_HEIGHT - 2 * mapview_y);
    _mapView = [[WinNewMapView alloc] initWithFrame:rect storeCoordinate:self.storedisCoordinate storeId:self.currentStore.Id
                                          storeName:self.currentStore.name isCenterForStoreLocation:isCenterForStoreLocation
                                      isShowAddress:isShowAddress locationType:[xbuildInfo getLocationType]
                                   isDropFullScreen:NO];
    _mapView.delegate = self;
    _mapView.layer.borderWidth = 2;
    _mapView.layer.borderColor = [UIColor colorWithHexString:@"#d8d8d8"].CGColor;
    _mapView.layer.cornerRadius = 5.0f;
    _mapView.clipsToBounds = YES;
    [self addSubview:_mapView];
    
    _locationManager = [[WinNewLocationManager alloc] init];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, MAP_CELL_HEIGHT)];
    
    [self addCollectUserLocationPlaclyAlert];
}

#pragma mark - 重写widgetDidLoadFinish方法(视图加载完成执行)
- (void)widgetDidLoadFinish {
    
    [self requestLocationWithIsHUD:YES];
}

#pragma mark - 重写setCurrentValueWithPresentation:方法
- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation {
    
    if ([[xbuildInfo getLocationType] isEqualToString:@"0"]) {
        
        NSArray *valueArray = [valuePresentation componentsSeparatedByString:@","];
        double latitud = 0.0;
        double longtitud = 0.0;
        NSString *addr = nil;
        if (valueArray.count > 0) {
            
            latitud = [[valueArray firstObject] doubleValue];
            longtitud  = [[valueArray objectAtIndex:1] doubleValue];
            if (valueArray.count >= 3) {
                addr = [valueArray objectAtIndex:2];
            }
        }
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitud, longtitud);
        if (latitud > 0 && longtitud > 0) {
            
            WSStoreBean *storeBean = [[WSStoreBean alloc]init];
            storeBean = [self.currentStore copy];
            storeBean.longitude = longtitud;
            storeBean.addr = addr;
            [self.mapView setAddress:addr];
            
            self.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            self.storedisCoordinate = coordinate;
            [self.mapView addStoreAnotationWithCoordinate:coordinate withStoreBean:storeBean];
        }
    }
    else {
        
        self.valueForLua = valuePresentation;
    }
}

#pragma mark - 实现getCurrentValue方法
- (NSObject *)getCurrentValue {
    
    NSDictionary *dict = (NSDictionary *)[self getResultDirectly];
    return [dict JSONString];
}

#pragma mark - 重写getResultDirectly方法
- (NSObject *)getResultDirectly {
    
    NSString *address = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalAddress];
    if (self.isUserLastRedis) {
        
        if (self.storedisCoordinate.latitude > 0 && self.storedisCoordinate.longitude > 0) {
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:self.storedisCoordinate.latitude longitude:self.storedisCoordinate.longitude];
            if (self.isSign) {
                return [WSLocationManager getLocationUploadDataWithLocation:location andAddress:address];
            }
            
            return [WSLocationManager getLocationUploadDataWithLocation:location andAddress:self.address];
        }
        
        return nil;
    }
    
    [self setRealLocation];
    
    if ([[xbuildInfo getNeedUploadData] isEqualToString:@"0"]) {
        return nil;
    }
    
    if ((self.hasRedisLocation && self.isSign) || !self.hasRedisLocation) {
        self.locationDescribe.detailAddress = address;
    }
    
    return [WSLocationManager getLocationUploadDataWithLocation:self.location andLocationDescribe:self.locationDescribe];
}

#pragma mark - 重写getResultPresentation方法
- (NSObject *)getResultPresentation {
    
    if (self.isUserLastRedis) {
        
        if (self.storedisCoordinate.latitude > 0 && self.storedisCoordinate.longitude > 0) {
            return [NSString stringWithFormat:@"%f,%f", self.storedisCoordinate.latitude, self.storedisCoordinate.longitude];
        }
        return nil;
    }
    
    [self setRealLocation];
    
    if (self.location) {
        return [NSString stringWithFormat:@"%f,%f", self.location.coordinate.latitude, self.location.coordinate.longitude];
    }
    
    return nil;
}

#pragma mark - 设置实际位置方法
- (void)setRealLocation {
    
    if (!self.mapIsMoved) {
        
        if (!([[xbuildInfo getLocationType] isEqualToString:@"2"] && self.isGpsReady)) {
            if (self.storedisCoordinate.latitude > 0 && self.storedisCoordinate.longitude > 0) {
                
                self.location = [[CLLocation alloc] initWithLatitude:self.storedisCoordinate.latitude longitude:self.storedisCoordinate.longitude];
            }
        }
    }
}

#pragma mark - 重写setReadonly:方法
- (void)setReadonly:(NSString *)readonly{
    
    [super setReadonly:readonly];
    self.mapReadOnly = [xbuildInfo getReadOnly];
}

#pragma mark - 重写readyToUpload方法(准备上传)
- (void)readyToUpload {
    
    [super readyToUpload];
    self.isUploading = YES;
}

#pragma mark - 重写loadBuildInfo:方法
- (void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo {
    
    [super loadBuildInfo:buildInfo];
}

#pragma mark - 重写performClickButton:方法(点击地图中的重新定位按钮)
- (void)performClickButton:(NSString *)param {
    
    if ([param isEqualToString:@"notUseUserLastRedis"]) {
        [self updateQstView:param];
    }else{
        self.isUserLastRedis = YES;
        self.isSign = YES;
        [self updateQstView:param];
    }
}

#pragma mark - 更新问题视图方法(功能相当于点击地图中的重新定位按钮)
- (void)updateQstView:(NSString *)param {
    
    [self requestLocationWithIsHUD:NO];
}

#pragma mark - 重写showStoreFence:方法
- (void)showStoreFence:(NSString *)distanceRange {
    
    NSArray *array = [distanceRange componentsSeparatedByString:@"@#"];
    self.distanceRange = [NSString stringWithFormat:@"%@", [array firstObject]];
    if (array.count == 4) {
        self.valueForLua = [NSString stringWithFormat:@"%@,%@,%@", array[1], array[2], array[3]];
    }
}

#pragma mark - 重写getGpsAndUploadData:方法
- (void)getGpsAndUploadData:(NSString *)acvtQstId {
    
    if ([acvtQstId length] > 0) {
        
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
        model.extralData = acvtQstId;
        if ([model isKindOfClass:[WSNestedAcvtModel class]]) {
            WSNestedAcvtModel *nestModel = (WSNestedAcvtModel *)model;
            nestModel.parentModel.extralData = acvtQstId;
        }
    }
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    NSString *text = NSLocalizedString(@"gps_wait_lable", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithCompletionBlock:^(WinNewLocationDescribe *_Nullable locationDescribe, NSError *_Nullable error) {
        
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];

        if (error) {
            self.location = nil;
        }
        else {
            CLLocationDegrees latitude = locationDescribe.locationCoordinate.latitude;
            CLLocationDegrees longitude = locationDescribe.locationCoordinate.longitude;
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            self.location = location;
        }

        WSInterAction *interaction = [[WSInterAction alloc] init];
        [interaction setExecute_method:@selector(beginToVisitStore:)];
        [interaction setDirect_type:DIRECT_TYPE_METHOD_WITH_SINGLEPARAM];

        if ([weakSelf.delegate respondsToSelector:@selector(executeInterAction:)]) {
            [weakSelf.delegate executeInterAction:interaction];
        }
    }];
}
#pragma mark - #  隐私权限
- (void)addCollectUserLocationPlaclyAlert{
    
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString * visitPrivacyPolicyFlag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
    if(visitPrivacyPolicyFlag!=nil&&!visitPrivacyPolicyFlag.boolValue){
        
        NSString * visitPrivacyPolicyMsg = [[WSAppData sharedManager].datas objectForKey:VISITPRIVACYMESSAGE];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"通知" message:visitPrivacyPolicyMsg];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            if(self.delegate&&[self.delegate respondsToSelector:@selector(cancleAgreePrivacyPolicyMesage)]){
                [self.delegate cancleAgreePrivacyPolicyMesage];
            }
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"approval", nil) block:^{
            LogInfo(@"同意手机用户定位信息");
            [WSRequestTools requestAgreeAppCollectingPrivacySuccess:^(BOOL success) {
                NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithValue:@"1"] forKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
                [[NSUserDefaults standardUserDefaults] synchronize];
               
                
            }];
            

        }];
        [alert show];
    }
}

- (void)refeshLocation:(NSString *)params {
    
    self.isRefreshLocation = YES;
    [self requestLocationWithIsHUD:NO];
}

@end
//=============================================================================================================================================================

#pragma mark - 地图面板 延展(工具)
@implementation WSMapPanel (Tools)

#pragma mark - 请求定位方法
- (void)requestLocationWithIsHUD:(BOOL)isHUD {
    
    if (isHUD) {
        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
        NSString *text = NSLocalizedString(@"gps_wait_lable", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil];
    }
    
    __weak typeof(self) weakSelf = self;
    [self.locationManager requestLocationWithCompletionBlock:^(WinNewLocationDescribe *_Nullable locationDescribe, NSError *_Nullable error) {

        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];

         if (error) {
             [weakSelf locationFailWithError:error];
         }
         else {
             [weakSelf locationSuccessWithLocationDescribe:locationDescribe];
         }
     }];
}

#pragma mark - 定位失败方法
- (void)locationFailWithError:(NSError *)error {
    
    self.location = nil;
    self.locationDescribe = nil;
    self.resultCheck = [NSString stringWithFormat:@"%@%@%@", LUA_SEPARATOR, LUA_SEPARATOR, LUA_SEPARATOR];
    
    [self.mapView setAddress:NSLocalizedString(@"gps_fail_lable", nil)];
    
    if (self.isRefreshLocation) {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)] &&
            !([[xbuildInfo getIsHidden] isEqualToString:@"0"] && [self.mapReadOnly isEqualToString:@"0"])) {
            
            [self.delegate executeLuaScript:self.xbuildInfo script:[self.xbuildInfo getLuaScript] funcName:@"refeshLocation" widget:self];
        }
        
        self.isRefreshLocation = NO;
    }
    else {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)] &&
            !([[xbuildInfo getIsHidden] isEqualToString:@"0"] && [self.mapReadOnly isEqualToString:@"0"])) {
            
            NSString *luaScriptForsetValue = [WSLuaExecutorManager getSubLuaScriptWith:[self.xbuildInfo getLuaScript] ByFuntionName:@"excuseAction"];
            [self.delegate executeLuaScript:self.xbuildInfo script:luaScriptForsetValue funcName:@"excuseAction" widget:self];
        }
    }
}

#pragma mark - 定位成功方法
- (void)locationSuccessWithLocationDescribe:(WinNewLocationDescribe *)locationDescribe {
    
    CLLocationDegrees latitude = locationDescribe.locationCoordinate.latitude;
    CLLocationDegrees longitude = locationDescribe.locationCoordinate.longitude;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    WSLocationDescribe *aLocationDescribe = [[WSLocationDescribe alloc] initWithLocation:location cityName:nil detailAddress:nil error:nil];
    aLocationDescribe.detailAddress = locationDescribe.address;
    aLocationDescribe.cityName = locationDescribe.city;
    aLocationDescribe.provinceName = locationDescribe.province;
    aLocationDescribe.district = locationDescribe.district;
    aLocationDescribe.subLocality = locationDescribe.locality;
    aLocationDescribe.poiName = locationDescribe.poiName;
    self.locationDescribe = aLocationDescribe;
    self.location = location;
    self.isGpsReady = YES;
    self.resultCheck = [NSString stringWithFormat:@"%lf%@%lf%@%@%@%@%@%@", self.location.coordinate.latitude, LUA_SEPARATOR,
                        self.location.coordinate.longitude, LUA_SEPARATOR, self.currentStore.Id, LUA_SEPARATOR,
                        (self.locationDescribe.detailAddress ? self.locationDescribe.detailAddress : @""),LUA_SEPARATOR,
    self.locationDescribe.poiName];
    
    [self.mapView setAddress:self.locationDescribe.detailAddress];
    [self.mapView addCurrentPointAnnotationWithCoordinate:self.location.coordinate];
    
    WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
    double latitud = 0.0;
    double longtitud = 0.0;
    NSString *storeName = nil;
    NSString *addr = nil;
    
    if (self.valueForLua && self.valueForLua.length > 0) {
        
        NSArray *latitudAndLongtitud = [self.valueForLua componentsSeparatedByString:@","];
        latitud = [[latitudAndLongtitud firstObject] doubleValue];
        longtitud = [[latitudAndLongtitud objectAtIndex:1] doubleValue];
        storeName = [latitudAndLongtitud objectAtIndex:2];
        if (latitudAndLongtitud.count >= 4) {
            addr = [latitudAndLongtitud objectAtIndex:3];
        }
    }
    else if ([model.currentFuncs.fv isEqualToString:ENTERSTORE_FV] || [model.currentFuncs.fv isEqualToString:LEAVESTORE_FV]) {
         
        latitud = model.currentStore.latitude;
        longtitud = model.currentStore.longitude;
    }
    else if ([model.currentFuncs.fv isEqualToString:DAY_VISIT]) {
        
      latitud = self.location.coordinate.latitude;
      longtitud = self.location.coordinate.longitude;
    }
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitud, longtitud);
    if (latitud > 0 && longtitud > 0 && aLocationDescribe.location.coordinate.latitude > 0 && aLocationDescribe.location.coordinate.longitude > 0) {
        
        WSStoreBean *aStore = nil;
        if (self.valueForLua && self.valueForLua.length > 0) {
        
            WSStoreBean *storeBean = [[WSStoreBean alloc] init];
            storeBean.latitude = latitud;
            storeBean.longitude = longtitud;
            storeBean.name = storeName;
            storeBean.addr = addr;
            aStore = storeBean;
        }
        else if ([model.currentFuncs.fv isEqualToString:ENTERSTORE_FV] || [model.currentFuncs.fv isEqualToString:LEAVESTORE_FV]) {
                
            aStore = model.currentStore;
        }
        else if ([model.currentFuncs.fv isEqualToString:DAY_VISIT]) {
            
            self.storedisCoordinate = coordinate;
        }
        
        aStore.isShowStoreDetailCallout = YES;
        aStore.detail_info = @"storeLocation";
        
        if (!_distanceRange) {
            _distanceRange = @"0";
        }
        [self.mapView addStoreAnotationWithCoordinate:coordinate withStoreBean:aStore];
    }
    
    if (self.isRefreshLocation) {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)] &&
            !([[xbuildInfo getIsHidden] isEqualToString:@"0"] && [self.mapReadOnly isEqualToString:@"0"])) {
            
            [self.delegate executeLuaScript:self.xbuildInfo script:[self.xbuildInfo getLuaScript] funcName:@"refeshLocation" widget:self];
        }
        
        self.isRefreshLocation = NO;
    }
    else {
        
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)] &&
            !([[xbuildInfo getIsHidden] isEqualToString:@"0"] && [self.mapReadOnly isEqualToString:@"0"])) {
            
            NSString *luaScriptForsetValue = [WSLuaExecutorManager getSubLuaScriptWith:[self.xbuildInfo getLuaScript] ByFuntionName:@"excuseAction"];
            [self.delegate executeLuaScript:self.xbuildInfo script:luaScriptForsetValue funcName:@"excuseAction" widget:self];
        }
    }
}

@end
//=============================================================================================================================================================

#pragma mark - 地图面板 延展(实现WinNewMapViewDelegate代理协议)
@implementation WSMapPanel (newMapViewDelegate)

#pragma mark - 刷新按键点击协议
- (void)mapViewRefreshButtonClick:(WinNewMapView *)mapView {
    
    self.mapIsMoved = YES;
    [self requestLocationWithIsHUD:YES];
}

@end
//=============================================================================================================================================================
