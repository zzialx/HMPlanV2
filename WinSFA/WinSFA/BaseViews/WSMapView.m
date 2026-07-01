//
//  WSMapView.m
//  WinSFA
//
//  Created by heju on 14/12/12.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSMapView.h"
//#import "MKMapView+Addtions.h"
//#import "WSUserAnnotationView.h"
//#import "WSCalloutAnnotationView.h"
//#import "WSRoutingPlanAnnotationView.h"
//#import "WSMyPJPPolyline.h"
//#import "WSStoreAnnotationView.h"
//#import "WSSelectListNewTableviewCell.h"
//#import "WSMapBottomInfoView.h"
//#import "WSMapSubTrailView.h"
//#import "WSStoreBean+Plan.h"
//#import "MKAnnotationView+WebCache.h"
//#import "WCPopListView.h"
//#import "WSSubempstoreBeanArray.h"
//#import "WSDatePicker.h"
//#import "WSBaseAcvtdisDBService.h"
//#import "WSRequestHelper.h"
//#import "WSStoreAnnotationWithNameView.h"
//#import "WSStoreDetailInfoCalloutView.h"
//#import "WSPljygonModel.h"
//#import "WSBaseStoreTable.h"
//#import "WSInoutStoreTable.h"
//#import <BaiduMapAPI_Base/BMKBaseComponent.h>
//#import <BaiduMapAPI_Map/BMKMapComponent.h>
//#import "BMKMapView+Additions.h"
//#import "BMKAnnotationView+WebCache.h"
//
//#define K_BottomView_Height 46
//#define K_RefreshButtonX 0
//#define K_RefreshButtonY 0
//#define K_RefreshButtonHeight 46
//#define K_RefreshButtonWidth 46
//#define K_EmpButtonButtonWidth 50
//#define K_EmpButtonButtonHeight 28
//#define K_TimeLabelWidth 77
//#define K_EmpButtonTitleColor RGBCOLOR(51, 51, 51)
//#define K_EmpButtonTitleFont  [UIFont systemFontOfSize: ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?13:15)]
//#define K_EmpListViewWidth 111
//#define K_EmpListViewHeight 146
//#define K_BottomLocationLabelX    60
//#define K_BottomLocationLabelWidth   ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?175:664)
//#define K_BottomMidLabelHeight 46
//#define K_AccuracyMin 100.0f
//#define K_AccuracyMax 300.0f
//#define K_AccuracyMin_Color [UIColor colorWithRed:92.0f/255 green:211.0f/255 blue:60.0f/255 alpha:1.0f]
//#define K_AccuracyMid_Color [UIColor colorWithRed:252.0f/255 green:209.0f/255 blue:83.0f/255 alpha:1.0f]
//#define K_AccuracyMax_Color [UIColor colorWithRed:220.0f/255 green:40.0f/255 blue:45.0f/255 alpha:1.0f]
//#define K_AccuracyLabelWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?65:100)
//#define K_AlertLabelWidth  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?180:260)
//#define K_AlertLabelHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?50:60)
//#define K_BottomBgColor [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.6]
//#define K_MapViewBorderWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?1.0f:1.0f)
//#define K_AccessoryButtonWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?50.0f:50.0f)
//#define K_AccessoryButtonHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?50.0f:50.0f)
//#define ISIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
//#define K_SHOW_STORE_WIDTH 45
//#define K_SHOW_STORE_HEIGHT 45
//#define K_SCALE_BUTTON_WIDTH 26
//#define K_SCALE_BUTTON_HEIGHT 32
//#define ZoomButtonBgViewWidth 35
//#define ZoomButtonBgViewHeight 60
//#define K_SCALE_BUTTON_LEFT_SPACE 5
//#define K_SCALE_BUTTONS_MAGINS  10
//#define K_ENLARGE_BUTTON_Y  310
//#define K_SCALE_BUTON_BASE_TAG 100
//#define K_LOCATION_BTN_WIDTH  29
//#define K_LOCATION_BTN_HEIGHT  29
//#define K_LRSPACE_WIDTH 30
//#define K_PRECISION 0.00001
//#define K_SPANVALUEDE 0.003
//==============================================================================================================================

@implementation WSUserAnnotation
@end
//==============================================================================================================================

@implementation WSDirectUserAnnotation
@end
//==============================================================================================================================

//@interface WSMapView () <WCPopListViewDelegate, WSMapSubTrailViewDelegate, BMKMapViewDelegate>
//
//@property (nonatomic, weak) WSFuncsBean *currentFuncs;
//@property (nonatomic, weak) WSStoreBean *previousStore;
//@property (nonatomic, strong) BMKMapView *mapView;
//@property (nonatomic, strong) id <BMKOverlay> currentOverlay;
//@property (nonatomic, strong) id <BMKOverlay> storeOverlay;
//@property (nonatomic, strong) UILabel *locationLabel;
//@property (nonatomic, strong) UILabel *accuracyLabel;
//@property (nonatomic, strong) UIButton *enlargeBtn;
//@property (nonatomic, strong) UIButton *shrinkBtn;
//@property (nonatomic, strong) UIButton *locationBtn;
//@property (nonatomic, strong) UIView * dateBgView;
//@property (nonatomic, assign) CGSize currentSize;
//@property (nonatomic, assign) NSInteger drawLineCount;
//@property (nonatomic) CLLocationCoordinate2D gcj02Coordinate;
//@property (nonatomic, strong) WSUserAnnotation *currentUserAnnotation;
//@property (nonatomic, strong) MKPolyline *polyline;
//@property (nonatomic, assign) BOOL isCenterForStoreLocation;
//@property (nonatomic, assign) BOOL isFullScreen;
//@property (nonatomic, assign) BOOL isReloadLocation;
//@property (nonatomic, assign) CLLocationCoordinate2D wgs84StoreCoordinate2D;
//@property (nonatomic, assign) CLLocationCoordinate2D storeLocationCenter;
//@property (nonatomic, strong) WSStoreAnnotation *modifyStoreAnotation;
//@property (nonatomic, strong) WSSelectListNewTableviewCell *currentDetailView;
//@property (nonatomic, strong) WSStoreBean *selectedStore;
//@property (nonatomic, strong) CLLocation *directionLocation;
//@property (nonatomic, strong) WSDirectUserAnnotation *directUserAnnotation;
//@property (nonatomic, assign) CGFloat storeListCellHeight;
//@property (nonatomic, strong) WSMapBottomInfoView *bottomInfoView;
//@property (nonatomic, strong) NSString *locationType;
//@property (nonatomic, strong) UIButton *empButton;
//@property (nonatomic, strong) UIButton *RoleButton;
//@property (nonatomic, strong) UIButton *searchButton;
//@property (nonatomic, copy) NSString *timeLabelStr;
//@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic, copy) NSString *empid;
//@property (nonatomic, copy) NSString *roleName;
//@property (nonatomic, strong) UIView *zoomButtonBgView ;
//@property (nonatomic, assign) BOOL isSubEmpTrail;
//@property (nonatomic, strong) MBProgressHUD *hud;
//@property (nonatomic, strong) UIView *bottomView;
//@property (nonatomic, strong) UIButton *dropFullScreenButton;
//@property (nonatomic, assign) BOOL isDropFullScreen;
//@property (nonatomic, strong) NSArray *emplistArray;
//@property (nonatomic, assign) BOOL isLocationBtnClick;
//
//@property (nonatomic, strong) UILabel *inPlanBtn;           //计划内按键(标签+手势创建)
//@property (nonatomic, strong) UILabel *outPlanBtn;          //计划外按键(标签+手势创建)
//@property (nonatomic, strong) UILabel *actualyBtn;          //实际按键(标签+手势创建)
//@property (nonatomic, weak) BMKPolyline *inPolyline;        //计划内折线
//@property (nonatomic, weak) BMKPolyline *outPolyline;       //计划外折线
//@property (nonatomic, weak) BMKPolyline *actualyPolyline;   //计划外折线
//@property (nonatomic, strong) NSMutableArray *inPlanArray;  //计划内数据数组
//@property (nonatomic, strong) NSMutableArray *outPlanArray; //计划外数据数组
//@property (nonatomic, strong) NSMutableArray *actuallyArray;//实际数据数组
//
//@end
//==============================================================================================================================

@implementation WSMapView

//- (NSMutableArray *)allStores {
//
//    if (!_allStores) {
//        _allStores = [[NSMutableArray alloc]init];
//    }
//    return _allStores;
//}
//
//- (UIButton *)refreshButton {
//
//    if (!_refreshButton) {
//        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _refreshButton.backgroundColor = K_BottomBgColor;
//        [_refreshButton addTarget:self action:@selector(refreshUserLocation:) forControlEvents:UIControlEventTouchUpInside];
//        [_refreshButton setImage:[UIImage imageForName:@"refreshLocation.png"] forState:UIControlStateNormal];
//        [_refreshButton setImage:[UIImage imageForName:@"refreshLocation_pressed.png"] forState:UIControlStateHighlighted];
//    }
//    return _refreshButton;
//}
//
//- (UILabel *)locationLabel {
//
//    if (!_locationLabel) {
//        _locationLabel = [[UILabel alloc]init];
//        _locationLabel.textAlignment = NSTextAlignmentLeft;
//        _locationLabel.backgroundColor = [UIColor clearColor];
//        _locationLabel.contentMode = UIControlContentVerticalAlignmentCenter;
//        _locationLabel.numberOfLines = 0;
//        _locationLabel.lineBreakMode = NSLineBreakByCharWrapping;
//        _locationLabel.font = [UIFont systemFontOfSize:UI_Font - 4];
//        _locationLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    }
//    return _locationLabel;
//}
//
//- (UIView *)bottomView {
//
//    if (!_bottomView) {
//        _bottomView = [[UIView alloc]init];
//        _bottomView.backgroundColor = K_BottomBgColor;
//        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//    }
//    return _bottomView;
//}
//
//- (BMKMapView *)mapView {
//
//    if (!_mapView) {
//        _mapView = [[BMKMapView alloc]init];
//        _mapView.delegate = self;
//        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _mapView.mapType = BMKMapTypeStandard;
//        _mapView.showsUserLocation = NO;
//        _mapView.rotateEnabled = NO;
//        _mapView.scrollEnabled = YES;
//        _mapView.buildingsEnabled = NO;
//    }
//    return _mapView;
//}
//
//- (UIButton *)dropFullScreenButton {
//
//    if (!_dropFullScreenButton) {
//        _dropFullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _dropFullScreenButton.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
//        [_dropFullScreenButton addTarget:self action:@selector(dropFullScreen:) forControlEvents:UIControlEventTouchUpInside];
//        [_dropFullScreenButton setImage:[UIImage imageNamed:@"btn_unfold"] forState:UIControlStateNormal];
//        [_dropFullScreenButton setImage:[UIImage imageNamed:@"btn_fold"] forState:UIControlStateSelected];
//    }
//    return _dropFullScreenButton;
//}
//
//- (UIButton *)empButton {
//
//    if (!_empButton) {
//        _empButton = [self getSelectListButton];
//    }
//    return _empButton;
//}
//
//- (UIButton *)RoleButton {
//
//    if (!_RoleButton) {
//        _RoleButton = [self getSelectListButton];
//    }
//    return _RoleButton;
//}
//
//- (UIButton *)searchButton {
//
//    if (!_searchButton) {
//        _searchButton = [self getSearchButton];
//    }
//    return _searchButton;
//}
//
//- (UIButton *)getSelectListButton {
//
//    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.layer.cornerRadius = 5;
//    button.layer.borderWidth = 0.5;
//    button.layer.borderColor = RGBCOLOR(153, 153, 153).CGColor;
//    [button addTarget:self action:@selector(loadEmpListView:) forControlEvents:UIControlEventTouchUpInside];
//    button.backgroundColor = [UIColor whiteColor];
//    [button setTitleColor:K_EmpButtonTitleColor forState:UIControlStateNormal];
//    button.titleLabel.font = K_EmpButtonTitleFont;
//    return button;
//}
//
//- (UIButton *)getSearchButton {
//
//    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.layer.cornerRadius = 5;
//    button.layer.borderWidth = 0.5;
//    button.layer.borderColor = RGBCOLOR(153, 153, 153).CGColor;
//    [button addTarget:self action:@selector(searchDown) forControlEvents:UIControlEventTouchUpInside];
//    button.backgroundColor = [UIColor whiteColor];
//    [button setTitleColor:K_EmpButtonTitleColor forState:UIControlStateNormal];
//    button.titleLabel.font = K_EmpButtonTitleFont;
//    return button;
//}
//
//- (void)setLocationType:(NSString *)locationType {
//
//    _locationType = locationType;
//    if ([locationType isEqualToString:@"0"]) {
//        [self.refreshButton setEnabled:NO];
//    } else {
//        [self.refreshButton setEnabled:YES];
//    }
//}
//
//- (void)creatDateView:(CGRect)mapViewRect {
//
//    CGFloat bgViewWidth = K_EmpButtonButtonHeight +  K_TimeLabelWidth + 10;
//    CGFloat x = 0;
//    if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//        x = K_EmpButtonButtonWidth +15;
//    }
//    CGFloat bgViewX = mapViewRect.size.width  - bgViewWidth - self.empButton.width - 2 * 15 - x;
//    self.dateBgView = [[UIView alloc]initWithFrame:CGRectMake(bgViewX , 15,bgViewWidth, K_EmpButtonButtonHeight)];
//    self.dateBgView.backgroundColor = [UIColor whiteColor];
//    self.dateBgView.layer.cornerRadius = 5;
//    self.dateBgView.layer.borderWidth = 0.5;
//    self.dateBgView.layer.borderColor = RGBCOLOR(153, 153, 153).CGColor;
//
//    UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, K_TimeLabelWidth, K_EmpButtonButtonHeight)];
//    self.timeLabel = timeLabel;
//    timeLabel.userInteractionEnabled = YES;
//    timeLabel.text = [WSCurrentTime getDateString];
//    timeLabel.textAlignment = NSTextAlignmentCenter;
//    timeLabel.font = K_EmpButtonTitleFont;
//    timeLabel.textColor = K_EmpButtonTitleColor;
//    timeLabel.backgroundColor = [UIColor whiteColor];
//    UITapGestureRecognizer  *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadDateView)];
//    [timeLabel addGestureRecognizer:gesture];
//    [self.dateBgView addSubview:timeLabel];
//
//    UILabel * lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabel.right + 1, (K_EmpButtonButtonHeight -15) * 0.5, 1,
//                                                                   K_EmpButtonButtonHeight -15)];
//    lineLabel.backgroundColor = RGBCOLOR(240, 240, 240);
//    [self.dateBgView addSubview:lineLabel];
//
//    UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [dateButton addTarget:self action:@selector(loadDateView) forControlEvents:UIControlEventTouchUpInside];
//    dateButton.frame = CGRectMake(K_TimeLabelWidth + 5 + 2, 0, K_EmpButtonButtonHeight, K_EmpButtonButtonHeight);
//    [dateButton setImage:[UIImage scaledImageForName:@"date_select_icon_gray" ofType:@"png"] forState:UIControlStateNormal];
//    [dateButton setTitleColor:K_EmpButtonTitleColor forState:UIControlStateNormal];
//    dateButton.titleLabel.font = K_EmpButtonTitleFont;
//    dateButton.backgroundColor = [UIColor whiteColor];
//    [self.dateBgView addSubview:dateButton];
//
//    [self.mapView addSubview:self.dateBgView];
//}
//
//- (instancetype)init {
//
//    if (self = [super init]) {
//        _isCenterForStoreLocation = NO;
//        _storeListCellHeight = STORE_LIST_CELL_DEFAULT_HEIGHT;
//        return self;
//    }
//    return nil;
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect funcs:(WSFuncsBean *)funcs stores:(NSArray *)allStores {
//
//    self = [super initWithFrame:mapViewRect];
//    if (self) {
//        self.drawLineCount = 0;
//        self.currentSize = mapViewRect.size;
//        self.currentFuncs = funcs;
//        self.isSubEmpTrail = NO;
//
//        self.mapView.frame = CGRectMake(0, 0, mapViewRect.size.width, mapViewRect.size.height);
//        [self addSubview:self.mapView];
//
//        _storeListCellHeight = STORE_LIST_CELL_DEFAULT_HEIGHT;
//
//        if (allStores) {
//            [self loadStoreAnnotationsWith:allStores];
//        }
//
//        [self loadMapRoutingButtons];
//        [self loadMapZoomButtons];
//        [self loadDirectionCurrentLocationBtn];
//        [self locateDirectionCurrentLocationBtnClick:nil];
//
//        if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//            self.isSubEmpTrail = YES;
//            self.isOrder = YES;
//            [self loadSelectSearchButton];
//            [self loadSelectEmpButton];
//            [self creatDateView:mapViewRect];
//        }
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect funcs:(WSFuncsBean *)funcs stores:(NSArray *)allStores empArray:(NSArray *)empArray
//      isSubEmpTrail:(BOOL)isSubEmpTrail {
//
//    self = [self initWithFrame:mapViewRect funcs:funcs stores:allStores];
//    if (isSubEmpTrail) {
//        self.isSubEmpTrail = isSubEmpTrail;
//        [self loadSelectEmpButton];
//        [self loadSelectRoleButton];
//        [self loadMapRoutingButtons];
//        [self loadSubTrailView:mapViewRect];
//        self.empButton.hidden = YES;
//        self.empArray = empArray;
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D)coordinate storeId:(NSString *)storeId
//          storeName:(NSString *)storeName isFullScreen:(BOOL)isFullScreen {
//
//    _isFullScreen = isFullScreen;
//    _storeListCellHeight = STORE_LIST_CELL_DEFAULT_HEIGHT;
//    return [self initWithFrame:mapViewRect storeCoordinate:coordinate storeId:storeId storeName:storeName
//      isCenterForStoreLocation:NO isShowAddress:YES locationType:nil];
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId
//          storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress {
//
//    return [self initWithFrame:mapViewRect storeCoordinate:coordinate storeId:storeId
//                     storeName:storeName isCenterForStoreLocation:isCenterForStore isShowAddress:isShowAddress locationType:nil];
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId
//          storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress
//       locationType:(NSString *)locationType {
//
//    self = [super initWithFrame:mapViewRect];
//    if (self) {
//        _isCenterForStoreLocation = isCenterForStore;
//        _storeListCellHeight = STORE_LIST_CELL_DEFAULT_HEIGHT;
//
//        self.currentSize = mapViewRect.size;
//        self.mapView.frame = CGRectMake(0, 0, mapViewRect.size.width, mapViewRect.size.height);
//        [self addSubview:self.mapView];
//
//        if(coordinate.latitude > -90 &&coordinate.latitude < 90 && coordinate.latitude != 0 &&
//           coordinate.longitude >-180  && coordinate.longitude < 180  && coordinate.longitude != 0) {
//
//            _wgs84StoreCoordinate2D = coordinate;
//            NSString *isTransformCoordinate = [[NSUserDefaults standardUserDefaults] objectForKey:GAODE2WGS84];
//            if ([isTransformCoordinate isEqualToString:@"0"]) {
//                _modifyStoreAnotation = [[WSStoreAnnotation alloc] initWith:coordinate storeId:storeId storeName:storeName];
//            } else if ([isTransformCoordinate isEqualToString:@"1"]) {
//                _modifyStoreAnotation = [[WSStoreAnnotation alloc]initWithWgs84:coordinate storeId:storeId storeName:storeName];
//            }
//            [self.mapView addAnnotation:_modifyStoreAnotation];
//        } else {
//            LogError(@"门店的经纬度不对:经度:%f, 纬度:%f", coordinate.latitude, coordinate.longitude);
//        }
//
//        self.bottomView.frame = CGRectMake(K_MapViewBorderWidth, self.currentSize.height - K_BottomView_Height - K_MapViewBorderWidth,
//                                           self.currentSize.width - 2*K_MapViewBorderWidth, K_BottomView_Height);
//        [self.mapView addSubview:self.bottomView];
//
//        [self.refreshButton setFrame:CGRectMake(K_RefreshButtonX, K_RefreshButtonY, K_RefreshButtonWidth, K_RefreshButtonHeight)];
//        [self.refreshButton addTarget:self action:@selector(refreshUserLocation:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.bottomView addSubview:self.refreshButton];
//        [self.bottomView addSubview:self.locationLabel];
//        self.locationLabel.frame = CGRectMake(K_BottomLocationLabelX, 0, self.width - K_BottomLocationLabelX - 10, K_BottomMidLabelHeight);
//
//        if (isShowAddress == NO) {
//            self.locationLabel.hidden = YES;
//        }
//
//        if (_isFullScreen) {
//            self.bottomView.frame = CGRectMake(K_MapViewBorderWidth, 0, self.currentSize.width - 2*K_MapViewBorderWidth,
//                                               K_BottomView_Height);
//            self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//            self.bottomView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
//            self.bottomView.layer.shadowColor = [[UIColor blackColor] CGColor];
//            self.bottomView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
//            self.bottomView.layer.shadowOpacity = 0.3;//阴影透明度，默认0
//            self.bottomView.layer.shadowRadius = 2;
//            self.locationLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
//            self.accuracyLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
//            self.mapView.layer.borderWidth = 0.0f;
//            self.mapView.layer.borderColor = nil;
//        }
//
//        if (self.isCenterForStoreLocation && self.wgs84StoreCoordinate2D.latitude && self.wgs84StoreCoordinate2D.longitude &&
//            ![locationType isEqualToString:@"0"]) {
//            [self loadShowRedisStoreButton];
//        }
//
//        if ([locationType isEqualToString:@"0"] || [locationType isEqualToString:@"2"]) {
//            [self showRedisStoreInMapCenter];
//        }
//
//        [self setLocationType:locationType];
//
//        if (coordinate.latitude == 0 && coordinate.longitude == 0) {
//            [self locateCurrentLocationNoCache];
//        } else {
//            [self reloadStoreLoactionWithstoreCoordinate:coordinate withLoactionCoordinate:coordinate withStoreBean:nil
//                                       withDistanceRange:0];
//        }
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect storeCoordinate:(CLLocationCoordinate2D )coordinate storeId:(NSString *)storeId
//          storeName:(NSString *)storeName isCenterForStoreLocation:(BOOL)isCenterForStore isShowAddress:(BOOL)isShowAddress
//       locationType:(NSString *)locationType isDropFullScreen:(BOOL)isDropFullScreen {
//
//    if (self = [self initWithFrame:mapViewRect storeCoordinate:coordinate storeId:storeId storeName:storeName
//          isCenterForStoreLocation:isCenterForStore isShowAddress:isShowAddress locationType:locationType]) {
//
//        if (isDropFullScreen) {
//
//            [self loadMapZoomButtons];
//            self.bottomView.backgroundColor = [UIColor clearColor];
//            [self.refreshButton setTitle:@"重新定位" forState:UIControlStateNormal];
//            self.refreshButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 4];
//            self.refreshButton.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//            self.refreshButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//            [self.refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            [self.refreshButton setImage:[UIImage imageNamed:@"icon_position"] forState:UIControlStateNormal];
//            [self.refreshButton setBackgroundImage:[UIImage imageNamed:@"button_bj"] forState:UIControlStateNormal];
//            self.refreshButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            self.refreshButton.frame = CGRectMake(MAIN_PADDING,(K_BottomView_Height - 20 - ZoomButtonBgViewWidth) *0.5, K_TimeLabelWidth,
//                                                  ZoomButtonBgViewWidth);
//            [self.mapView addSubview:self.dropFullScreenButton];
//            self.isDropFullScreen = YES;
//        }
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)mapViewRect routePlanStores:(NSArray *)stores isOrder:(BOOL)isOrder {
//
//    self = [super initWithFrame:mapViewRect];
//    if (self) {
//        _allStores = stores.mutableCopy;
//        self.isOrder = isOrder;
//        self.currentSize = mapViewRect.size;
//        self.mapView.frame = CGRectMake(0, 0, mapViewRect.size.width, mapViewRect.size.height);
//        self.mapView.layer.borderWidth = K_MapViewBorderWidth;
//        UIColor *mainTintColor = MAIN_TINT_COLOT;
//        self.mapView.layer.borderColor = [mainTintColor CGColor];
//        self.mapView.showsUserLocation = YES;
//        [self addSubview:self.mapView];
//
//        _storeListCellHeight = STORE_LIST_CELL_DEFAULT_HEIGHT;
//        self.bottomView.frame =  CGRectMake(K_MapViewBorderWidth, self.currentSize.height - K_BottomView_Height - K_MapViewBorderWidth,
//                                            self.currentSize.width - 2*K_MapViewBorderWidth, K_BottomView_Height);
//        [self.mapView addSubview:self.bottomView];
//
//        [self.refreshButton setFrame:CGRectMake(K_RefreshButtonX, K_RefreshButtonY, K_RefreshButtonWidth, K_RefreshButtonHeight)];
//        [self.bottomView addSubview:self.refreshButton];
//
//        [self.bottomView addSubview:self.locationLabel];
//        self.locationLabel.frame = CGRectMake(K_BottomLocationLabelX, 0, self.width - K_AccuracyLabelWidth - K_BottomLocationLabelX - 10,
//                                              K_BottomMidLabelHeight);
//
//        self.accuracyLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bottomView.width - K_AccuracyLabelWidth, 0,
//                                                                       K_AccuracyLabelWidth, K_BottomMidLabelHeight)];
//        self.accuracyLabel.contentMode = UIControlContentVerticalAlignmentCenter;
//        self.accuracyLabel.textAlignment = NSTextAlignmentCenter;
//        self.accuracyLabel.backgroundColor = K_BottomBgColor;
//        self.accuracyLabel.font = [UIFont systemFontOfSize:UI_Font - 4];
//        self.accuracyLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        [self.bottomView addSubview:self.accuracyLabel];
//
//        [self loadStoreAnnotationsWith:stores isAddLine:YES];
//    }
//    return self;
//}
//
//- (void)layoutSubviews {
//
//    CGRect frame = self.bounds;
//    self.currentSize = frame.size;
//    self.mapView.frame = frame;
//    CGFloat y = (self.empButton.hidden?MAIN_BIG_PADDING:(K_SCALE_BUTTONS_MAGINS + self.empButton.bottom)) ;
//
//    if (self.inPlanArray.count > 0) {
//        self.inPlanBtn.hidden = NO;
//        self.inPlanBtn.frame = CGRectMake(self.mapView.width - K_SCALE_BUTTON_LEFT_SPACE - K_SHOW_STORE_HEIGHT, y,
//                                          K_SHOW_STORE_HEIGHT, K_SHOW_STORE_HEIGHT);
//        y += K_SHOW_STORE_HEIGHT + K_SCALE_BUTTONS_MAGINS;
//    } else {
//        self.inPlanBtn.hidden = YES;
//    }
//
//    if (self.actuallyArray.count > 0) {
//        self.actualyBtn.hidden = NO;
//        self.actualyBtn.frame = CGRectMake(self.mapView.width - K_SCALE_BUTTON_LEFT_SPACE - K_SHOW_STORE_HEIGHT, y,
//                                           K_SHOW_STORE_HEIGHT, K_SHOW_STORE_HEIGHT);
//        y += K_SHOW_STORE_HEIGHT +  K_SCALE_BUTTONS_MAGINS;
//    } else {
//        self.actualyBtn.hidden = YES;
//    }
//
//    if (self.outPlanArray.count > 0) {
//        self.outPlanBtn.hidden = NO;
//        self.outPlanBtn.frame = CGRectMake(self.mapView.width - K_SCALE_BUTTON_LEFT_SPACE - K_SHOW_STORE_HEIGHT, y,
//                                           K_SHOW_STORE_HEIGHT, K_SHOW_STORE_HEIGHT);
//    } else {
//        self.outPlanBtn.hidden = YES;
//    }
//
//    CGFloat bottomMargin = 20;
//    CGFloat originY = 0;
//    if (self.currentDetailView || self.bottomInfoView) {
//        originY = self.mapView.height  - ZoomButtonBgViewHeight - _storeListCellHeight - bottomMargin;
//    } else {
//        originY = self.mapView.height  - ZoomButtonBgViewHeight - bottomMargin;
//    }
//
//    self.zoomButtonBgView.frame = CGRectMake(self.mapView.width - ZoomButtonBgViewWidth - MAIN_PADDING, originY,
//                                             ZoomButtonBgViewWidth, ZoomButtonBgViewHeight);
//    self.locationBtn.frame = CGRectMake(bottomMargin,originY + K_SCALE_BUTTON_WIDTH, ZoomButtonBgViewWidth, ZoomButtonBgViewWidth);
//    self.dropFullScreenButton.frame = CGRectMake((self.width - 2.5 * ZoomButtonBgViewWidth) * 0.5,
//                                                 self.height - ZoomButtonBgViewWidth * 0.5,
//                                                 2.5 * ZoomButtonBgViewWidth, ZoomButtonBgViewWidth * 0.5);
//}
//
//- (void)loadSubTrailView:(CGRect)mapViewRect{
//
//    CGFloat bgViewWidth = K_EmpButtonButtonHeight + K_TimeLabelWidth + 10;
//    CGFloat bgViewX = mapViewRect.size.width - bgViewWidth - self.empButton.width - 2 * MAIN_BIG_PADDING;
//    WSMapSubTrailView *bgView = [[WSMapSubTrailView alloc]initWithFrame:CGRectMake(bgViewX , MAIN_BIG_PADDING,
//                                                                                   bgViewWidth, K_EmpButtonButtonHeight)];
//    bgView.delegate = self;
//    [self.mapView addSubview:bgView];
//}
//
//- (void)loadMapZoomButtons {
//
//    CGFloat y = K_ENLARGE_BUTTON_Y;
//    CGFloat x = self.mapView.width - ZoomButtonBgViewWidth - K_SCALE_BUTTON_LEFT_SPACE;
//    UIView *zoomButtonBgView = [[UIView alloc]initWithFrame:CGRectMake(x, self.mapView.height  - 2 * ZoomButtonBgViewHeight,
//                                                                       ZoomButtonBgViewWidth, ZoomButtonBgViewHeight)];
//    zoomButtonBgView.backgroundColor = [UIColor whiteColor];
//    zoomButtonBgView.layer.cornerRadius = 5;
//    zoomButtonBgView.layer.borderWidth = 0.5;
//    zoomButtonBgView.layer.borderColor = RGBCOLOR(153, 153, 153).CGColor;
//    self.zoomButtonBgView = zoomButtonBgView;
//    UIButton *enlargeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [enlargeBtn addTarget:self action:@selector(zoomMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [enlargeBtn setImage:[UIImage scaledImageForName:@"btn_zoom_inplus" ofType:@"png"] forState:UIControlStateNormal];
//    enlargeBtn.tag = K_SCALE_BUTON_BASE_TAG + 0;
//    enlargeBtn.frame = CGRectMake(K_SCALE_BUTTON_LEFT_SPACE, K_SCALE_BUTTON_LEFT_SPACE, K_SCALE_BUTTON_WIDTH, K_SCALE_BUTTON_WIDTH);
//    self.enlargeBtn = enlargeBtn;
//    [zoomButtonBgView addSubview:self.enlargeBtn];
//    y += K_SCALE_BUTTON_HEIGHT + K_SCALE_BUTTONS_MAGINS;
//
//    UILabel * lineLabel = [[UILabel alloc]initWithFrame:CGRectMake((ZoomButtonBgViewWidth - 15)*0.5, enlargeBtn.bottom, 15, 1)];
//    lineLabel.backgroundColor = RGBCOLOR(240, 240, 240);
//    [zoomButtonBgView addSubview:lineLabel];
//
//    UIButton *shrinkBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
//    [shrinkBtn addTarget:self action:@selector(zoomMapButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [shrinkBtn setImage:[UIImage scaledImageForName:@"btn_zoom_outdif" ofType:@"png"] forState:UIControlStateNormal];
//    shrinkBtn.tag = K_SCALE_BUTON_BASE_TAG + 1;
//    shrinkBtn.frame = CGRectMake(K_SCALE_BUTTON_LEFT_SPACE, K_SCALE_BUTTON_LEFT_SPACE + K_SCALE_BUTTON_WIDTH + 1,
//                                 K_SCALE_BUTTON_WIDTH, K_SCALE_BUTTON_WIDTH);
//    self.shrinkBtn = shrinkBtn;
//    [zoomButtonBgView addSubview:self.shrinkBtn];
//
//    [self.mapView addSubview:zoomButtonBgView];
//}
//
//- (void)loadSelectEmpButton {
//
//    [self.mapView addSubview:self.empButton];
//    CGFloat x = 0;
//    if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//        x = K_EmpButtonButtonWidth +15;
//    }
//    self.empButton.frame = CGRectMake(self.mapView.size.width - 15 - K_EmpButtonButtonWidth - x , 15,
//                                      K_EmpButtonButtonWidth, K_EmpButtonButtonHeight);
//    [self.empButton setTitle:@"人员" forState:UIControlStateNormal];
//}
//
//- (void)loadSelectSearchButton {
//
//    [self.mapView addSubview:self.searchButton];
//    self.searchButton.frame = CGRectMake(self.mapView.size.width - 15 - K_EmpButtonButtonWidth, 15,
//                                         K_EmpButtonButtonWidth, K_EmpButtonButtonHeight);
//    [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
//}
//
//- (void)loadSelectRoleButton {
//
//    if (self.roleArray.count > 0) {
//        [self.mapView addSubview:self.RoleButton];
//        self.RoleButton.frame = CGRectMake(self.mapView.size.width - self.empButton.width - 2 *15 - 2 * K_EmpButtonButtonWidth , 15,
//                                           2 * K_EmpButtonButtonWidth, K_EmpButtonButtonHeight);
//        [self.RoleButton setTitle:@"角色选择" forState:UIControlStateNormal];
//    }
//}
//
//- (void)loadDirectionCurrentLocationBtn {
//
//    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [locationBtn addTarget:self action:@selector(locateDirectionCurrentLocationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [locationBtn setImage:[UIImage scaledImageForName:@"icon_GPS" ofType:@"png"] forState:UIControlStateNormal];
//    self.locationBtn = locationBtn;
//    [self.mapView addSubview:self.locationBtn];
//}
//
//- (void)loadShowRedisStoreButton {
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button addTarget:self action:@selector(showRedisStoreInMapCenter) forControlEvents:UIControlEventTouchUpInside];
//    [button setImage:[UIImage imageForName:@"map_icon_cz.png"] forState:UIControlStateNormal];
//    button.frame = CGRectMake(0, 0, K_SHOW_STORE_WIDTH, K_SHOW_STORE_HEIGHT);
//    [self.mapView addSubview:button];
//}
//
//- (void)showRedisStoreInMapCenter {
//
//    if (self.wgs84StoreCoordinate2D.latitude > 0 && self.wgs84StoreCoordinate2D.longitude) {
//        CLLocationCoordinate2D actualCoordinate = [WSLocationManager getActualCoordinateWithWgs84:self.wgs84StoreCoordinate2D];
//        [self setMapRegionCenterWith:actualCoordinate];
//        if ([self.delegate respondsToSelector:@selector(mapView:locationCoordinate:)]) {
//            [self.delegate mapView:self.mapView locationCoordinate:self.wgs84StoreCoordinate2D];
//        }
//    }
//}
//
//- (void)reloadStoreLoactionWithstoreCoordinate:(CLLocationCoordinate2D )storecCoordinate withLoactionCoordinate:(CLLocationCoordinate2D)locationCoordinate withStoreBean:(WSStoreBean *)aStore withDistanceRange:(NSString *)distanceRange{
//
//    for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//        if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//            [self.mapView removeAnnotation:storeAnnotation];
//        }
//    }
//    WSStoreAnnotation *tmpStoreAnnotation;
//    NSString *isTransformCoordinate = [[NSUserDefaults standardUserDefaults] objectForKey:GAODE2WGS84];
//    if ([isTransformCoordinate isEqualToString:@"0"]) {
//        tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWith:storecCoordinate annotationStore:aStore];
//    }else if ([isTransformCoordinate isEqualToString:@"1"]){
//        tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:storecCoordinate annotationStore:aStore];
//    }
//    [self.mapView addAnnotation:tmpStoreAnnotation];
//
//    CLLocationCoordinate2D topLeftCoord = [WSLocationManager getActualCoordinateWithWgs84:storecCoordinate];
//    CLLocationCoordinate2D bottomRightCoord = [WSLocationManager getActualCoordinateWithWgs84:locationCoordinate];
//
//    BMKCoordinateRegion region;
//    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
//    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
//    region.span.latitudeDelta =  fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
//    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
//    if (self.isDropFullScreen) {
//        CLLocationCoordinate2D actualCoordinate2D = [WSLocationManager getActualCoordinateWithWgs84:locationCoordinate];
//        region.center = actualCoordinate2D;
//    }
//
//    if (region.span.latitudeDelta == 0 && region.span.longitudeDelta == 0) {
//        region.span = BMKCoordinateSpanMake(K_SPANVALUEDE, K_SPANVALUEDE);
//    }
//
//    if (CLLocationCoordinate2DIsValid(region.center)) {
//        [self.mapView setRegion:region animated:YES];
//    }
//
//    CLLocationCoordinate2D storeOverlayCoordinate = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude)*0.00001, topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) *0.00001);
//    // 以门店为圆心的区域
//    if (self.storeOverlay)
//    {
//        [self.mapView removeOverlay:self.storeOverlay];
//    }
//
//    BMKCircle *circle = [BMKCircle circleWithCenterCoordinate:storeOverlayCoordinate radius:[distanceRange doubleValue]];
//    self.storeLocationCenter = circle.coordinate;
//    self.storeOverlay = circle;
//    [self.mapView addOverlay:circle];
//}
//
//- (void)addStoreAnotationWithstoreCoordinate:(CLLocationCoordinate2D )storecCoordinate withStoreBean:(WSStoreBean *)aStore{
//
//    [self.mapView removeAnnotations:self.mapView.annotations];
//
//    WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:storecCoordinate annotationStore:aStore];
//
//    [self.mapView addAnnotation:tmpStoreAnnotation];
//
//    CLLocationCoordinate2D actualStoreCoordinate = [WSLocationManager getActualCoordinateWithWgs84:storecCoordinate];
//
//    [self setMapRegionCenterWith:actualStoreCoordinate];
//}
//
//- (void)zoomMapButtonClick:(UIButton *)button {
//
//    double latitudeDegrees = self.mapView.region.span.latitudeDelta;
//    double longitudeDegrees = self.mapView.region.span.longitudeDelta;
//    CGFloat coefficient = 5;
//    NSInteger tag = button.tag;
//    switch (tag - K_SCALE_BUTON_BASE_TAG) {
//        case 0:
//            latitudeDegrees = latitudeDegrees/coefficient;
//            longitudeDegrees = longitudeDegrees/coefficient;
//            break;
//
//        case 1:
//            latitudeDegrees = latitudeDegrees*coefficient;
//            longitudeDegrees = longitudeDegrees*coefficient;
//            break;
//
//        default:
//            break;
//    }
//    BMKCoordinateRegion region;
//    region.span = BMKCoordinateSpanMake(latitudeDegrees,longitudeDegrees);
//    region.center =  self.mapView.centerCoordinate;
//    /*超出范围会崩溃MKCoordinateSpanMake(236.72561014789778,240.31017075504082)*/
//    if (latitudeDegrees <= 230 && longitudeDegrees <= 230) {
//        [self.mapView setRegion:region animated:NO];
//    }else {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"提示!" tips:@"已缩放至最小!" tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
//    }
//}
//
//- (void)setMapRegionCenterWith:(CLLocationCoordinate2D)coordinate2D {
//    /*以当前位置为中心*/
//    BMKCoordinateRegion region;
//    region.span = BMKCoordinateSpanMake(K_SPANVALUEDE, K_SPANVALUEDE);
//    region.center =  coordinate2D;
//    [self.mapView setRegion:region animated:NO];
//}
//- (void)setRegion:(CLLocationCoordinate2D)coordinate2D{
//    BMKCoordinateRegion region = self.mapView.region;
//    region.center =  coordinate2D;
//    [self.mapView setRegion:region animated:YES];
//}
//
//- (void)loadStoreAnnotationsWith:(NSArray *)allStores{
//    [self loadStoreAnnotationsWith:allStores isAddLine:NO];
//}
//
//- (void)loadStoreAnnotationsWith:(NSArray *)allStores isAddLine:(BOOL)isAddLine {
//
//    for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//        if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//            [self.mapView removeAnnotation:storeAnnotation];
//        }
//    }
//
//    NSMutableArray *storeAnnotations = [NSMutableArray array];
//    if (allStores) {
//        self.allStores = allStores.mutableCopy;
//        BOOL isHadSelectStore = NO;
//        for (WSStoreBean *tmpStore in allStores) {
//            if (tmpStore.latitude && tmpStore.longitude) {
//                CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(tmpStore.latitude, tmpStore.longitude);
//
//                // MN-3667 蒙牛（ios）-片区查询坐标偏移
//                NSString *isTransformCoordinate = [[NSUserDefaults standardUserDefaults] objectForKey:GAODE2WGS84];
//                WSStoreAnnotation *tmpStoreAnnotation;
//                if ([isTransformCoordinate isEqualToString:@"0"]) {
//                    tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWith:tmpStoreCoordinate annotationStore:tmpStore];
//                }else if ([isTransformCoordinate isEqualToString:@"1"]){
//                    tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:tmpStore];
//                }
//                [storeAnnotations addObject:tmpStoreAnnotation];
//            }
//
//            // 如果之前点击过门店，显示了门店详情信息，下次刷新的时候，需要刷新数据
//            if (self.selectedStore &&  [self.selectedStore.Id isEqualToString:tmpStore.Id]) {
//                [self showDetailViewWith:tmpStore];
//                isHadSelectStore = YES;
//            }
//        }
//
//        if (!isHadSelectStore && self.currentDetailView) {
//            [self moveView:self.currentDetailView offset:_storeListCellHeight];
//        }
//    }
//
//    if ([storeAnnotations count] > 0) {
//        [self.mapView addAnnotations:storeAnnotations];
//
//        if (!isAddLine) {
//            int i = 0;
//            CLLocationCoordinate2D *locationCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [storeAnnotations count]);
//
//            for (WSStoreAnnotation *tmpStoreAnnotation in storeAnnotations) {
//                locationCoodinateArr[i] = tmpStoreAnnotation.coordinate;
//                i++;
//            }
//
//            BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:locationCoodinateArr count:storeAnnotations.count];
//            [self.mapView addOverlay:polyline];
//
//            free(locationCoodinateArr);
//        }
//    }
//    [self.mapView zoomToFitMapAnnotations];
//}
//
//- (void)removeAllLine{
//
//    [self.mapView removeOverlays:self.mapView.overlays];
//
//}
//- (void)loadStoreAnnotationsWithCallPlanDict:(NSDictionary *)callPlanDict withDateWeekStr:(NSString *)dateWeekStr withIsFitMap:(BOOL)isFitMap{
//
//    for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//        if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//            [self.mapView removeAnnotation:storeAnnotation];
//        }
//    }
//    [self.mapView removeOverlays:self.mapView.overlays];
//
//    self.callPlanDict = callPlanDict.mutableCopy;
//
//    NSArray * allStoreArray = [callPlanDict objectForKey:@"allStoreArray"];
//    NSMutableArray *outPlanAnnotations = [NSMutableArray array];
//    NSMutableArray *callPlanAnnotations = [NSMutableArray array];
//    for (WSStoreBean *store in allStoreArray) {
//        if (store.latitude && store.longitude) {
//            CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(store.latitude, store.longitude);
//            WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:store];
//            if (store.bPlanned) {
//                [callPlanAnnotations addObject:tmpStoreAnnotation];
//            }else{
//                [outPlanAnnotations addObject:tmpStoreAnnotation];
//            }
//        }
//    }
//
//    for (NSString *key in callPlanDict.allKeys) {
//        if ([key isEqualToString:@"allStoreArray"]) {
//            continue;
//        }
//        NSArray *stores = [callPlanDict objectForKey:key];
//        CLLocationCoordinate2D *locationCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [stores count]);
//        int i = 0;
//        for (WSStoreBean *tmpStore in stores) {
//            if (tmpStore.latitude && tmpStore.longitude) {
//
//                if ([key isEqualToString:dateWeekStr]) {
//                    for (WSStoreAnnotation * annotationin in callPlanAnnotations) {
//                        if ([annotationin.store.Id isEqualToString:tmpStore.Id]) {
//                            annotationin.store = tmpStore;
//                        }
//                    }
//                }
//                CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(tmpStore.latitude, tmpStore.longitude);
//                WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:tmpStore];
//                locationCoodinateArr[i] = tmpStoreAnnotation.coordinate;
//                    i++;
//            }
//        }
//
//        if (i > 0) {
//            WSMyPJPPolyline *polyline = [WSMyPJPPolyline polylineWithCoordinates:locationCoodinateArr count:i];
//            polyline.lineColor = [UIColor colorForKey:[NSString stringWithFormat:@"%@color",key]];
//            if ([dateWeekStr isEqualToString:key]) {
//                polyline.isSelected = YES;
//            }else{
//                polyline.isSelected = NO;
//            }
//            [self.mapView addOverlay:polyline];
//
//        }
//        free(locationCoodinateArr);
//    }
//
//    if ([outPlanAnnotations count] > 0) {
//        [self.mapView addAnnotations:outPlanAnnotations];
//    }
//    if ([callPlanAnnotations count] > 0) {
//        [self.mapView addAnnotations:callPlanAnnotations];
//    }
//    if (isFitMap) {
//        [self.mapView zoomToFitMapAnnotations];
//    }
//
//
//}
//
//-(void)loadStoreAnnotationsWith:(NSArray *)planStores andActureStores:(NSArray *)actureStores{
//    for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//        if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//            [self.mapView removeAnnotation:storeAnnotation];
//        }
//    }
//    [self.mapView removeOverlays:self.mapView.overlays];
//
//    NSMutableArray *storeAnnotations = [NSMutableArray array];
//    CLLocationCoordinate2D *planCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [planStores count]);
//    CLLocationCoordinate2D *actualCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [actureStores count]);
//    NSInteger i = 0 ,j = 0;
//    for (WSStoreBean *tmpStore in planStores)
//    {
//        if (tmpStore.latitude && tmpStore.longitude) {
//            CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(tmpStore.latitude, tmpStore.longitude);
//            WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:tmpStore];
//            [storeAnnotations addObject:tmpStoreAnnotation];
//            planCoodinateArr[i] = tmpStoreAnnotation.coordinate;
//            i++;
//        }
//    }
//
//    for (WSStoreBean * actualrouteBean in actureStores)
//    {
//        if (actualrouteBean.latitude && actualrouteBean.longitude)
//        {
//            CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(actualrouteBean.latitude, actualrouteBean.longitude);
//            WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:actualrouteBean];
//            actualCoodinateArr[j] = tmpStoreAnnotation.coordinate;
//            j++;
//
//        }
//        for (WSStoreBean * tempStore in planStores) {
//            if ([actualrouteBean.Id isEqualToString:tempStore.Id]) {
//                break;
//            }else{
//                CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(actualrouteBean.latitude, actualrouteBean.longitude);
//                WSStoreAnnotation *tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWithWgs84:tmpStoreCoordinate annotationStore:actualrouteBean];
//                [storeAnnotations addObject:tmpStoreAnnotation];
//            }
//        }
//    }
//
//    if ([storeAnnotations count] > 0) {
//        [self.mapView addAnnotations:storeAnnotations];
//    }
//    [self.mapView zoomToFitMapAnnotations];
//
//    WSMyPJPPolyline *polyline2 = [WSMyPJPPolyline polylineWithCoordinates:actualCoodinateArr count:actureStores.count];
//    [self.mapView addOverlay:polyline2];
//
//    WSMyPJPPolyline *polyline = [WSMyPJPPolyline polylineWithCoordinates:planCoodinateArr count:planStores.count];
//    [self.mapView addOverlay:polyline];
//
//    free(planCoodinateArr);
//    free(actualCoodinateArr);
//}
//
//-(void)routingPlanLableClickWith:(UIRoutingPlanType)type{
//
//    [self loadRoutingPlanWithType:type withPlanArray:nil andActuallyArray:nil];
//}
//
//#pragma mark-------实际拜访门店处理
//- (void)configActuallyStoreArray:(NSArray*)actuallyStoreArray{
//
//    for (WSStoreBean * bean in actuallyStoreArray) {
//        if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//            if ([bean.is_plan isEqualToString:@"0"]) {
//                [self.actuallyArray addObject:bean];
//            }
//        }else{
//            //显示实际轨迹按钮 actionstate拜访状态
//            if ([bean.actionState isEqualToString:@"1"] || bean.isAcctuallyRouteStore) {
//                [self.actuallyArray addObject:bean];
//            }
//        }
//    }
//}
//
//-(void)loadVisitedStoreRoutingWith:(NSArray *)visitedStores{
//
//    CLLocationCoordinate2D *visitedCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [visitedStores count]);
//
//    int i = 0;
//    for (WSStoreBean *tmpStore in visitedStores)
//    {
//        if (tmpStore.latitude && tmpStore.longitude) {
//            CLLocationCoordinate2D tmpStoreCoordinate = CLLocationCoordinate2DMake(tmpStore.latitude, tmpStore.longitude);
//
//            visitedCoodinateArr[i] = tmpStoreCoordinate;
//            i++;
//        }
//    }
//
//    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:visitedCoodinateArr count:i];
//    [self.mapView addOverlay:polyline];
//    free(visitedCoodinateArr);
//}
//
//- (void)reloadPolyIineWithDateofWeekStr:(NSString *)dateWeekStr{
//
//    [self loadStoreAnnotationsWithCallPlanDict:(NSDictionary *)_callPlanDict withDateWeekStr:dateWeekStr withIsFitMap:NO];
//
//    for (WSMyPJPPolyline *poline in self.mapView.overlays) {
//        if (poline.isSelected ) {
//            [self.mapView insertOverlay:poline atIndex:self.mapView.overlays.count];
//            break;
//        }
//    }
//}
//
//- (void)locateDirectFinished:(NSNotification *)sender
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
//
//    NSDictionary *userInfo = [sender userInfo];
//    NSError *error = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedErrorKey];
//    CLLocation *location = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
//    if (error) {
//        LogInfo(@"定位失败：locateDirectFinished");
//    }
//    if (location) {
//        if (self.directUserAnnotation) {
//            [self.mapView removeAnnotation:self.directUserAnnotation];
//        }
//
//        NSString *userTitle = NSLocalizedString(@"map_current", nil);
//        self.directionLocation = location;
//        WSDirectUserAnnotation *userAnnotation = [[WSDirectUserAnnotation alloc] initWithWgs84:location.coordinate title:userTitle];
//        self.directUserAnnotation = userAnnotation;
//        [self.mapView addAnnotation:userAnnotation];
//
//        if (self.isLocationBtnClick) {
//            CLLocationCoordinate2D actualCoordinate2D = [WSLocationManager getActualCoordinateWithWgs84:location.coordinate];
//            [self setMapRegionCenterWith:actualCoordinate2D];
//        }
//
//        [self.mapView zoomToFitMapAnnotations];
//    }
//}
//
///*定位当前位置 for 地图模式显示门店列表*/
//- (void)locateDirectionCurrentLocationBtnClick:(UIButton *)sender  {
//    LogTrace();
//
//    DDLogInfo(@"使用通知方式获取定位回调");
//    if (sender) {
//        self.isLocationBtnClick = YES;
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateDirectFinished:) name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
//    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
//}
//
//- (void)locateCurrentLocation {
//    [self locateCurrentLocationWithLoading:NO];
//}
//
//- (void)startUpdatingLocation{
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationFinished:) name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAddressFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
//}
//
//// isLoading 是否显示加载中的弹框
//- (void)locateCurrentLocationWithLoading:(BOOL)isLoading {
//
//    if (isLoading && !self.hud) {
//        self.hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"gps_wait_lable", nil) tips:nil tapTarget:nil action:nil];
//    }
//
//    if (isLoading && !self.hud) {
//        self.hud = [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"gps_wait_lable", nil) tips:nil tapTarget:nil action:nil];
//    }
//
//    DDLogInfo(@"（wsmapview）:使用通知方式获取定位回调");
//    [self startUpdatingLocation];
//}
//
//- (void)updateLocationFinished:(NSNotification *)sender
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
//
//    NSDictionary *userInfo = [sender userInfo];
//    NSError *error = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedErrorKey];
//    CLLocation *location = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
//    WSLocationDescribe *aLocationDescribe = [[WSLocationDescribe alloc] initWithLocation:location cityName:nil detailAddress:nil error:error];
//
//    if (self.hud) {
//        [self.hud hideAnimated:YES];
//        self.hud = nil;
//    }
//
//    NSString *text;
//    if (aLocationDescribe.locationError && ![[WSLocationManager getInstance]  currentLocationServicesEnabled]) {
//        text = [self locationServiceNotAvailableMessage];
//    }else if (aLocationDescribe.errorDescriptMessage) {
//        text = aLocationDescribe.errorDescriptMessage;
//    }
//
//    if (aLocationDescribe.location) {
//
//        if (!text) {
//            text = NSLocalizedString(@"location_reversing", nil);
//        }
//        [self resetBottomViewWith:aLocationDescribe.location adress:text];
//
//    }else {
//        if (!text) {
//            text = NSLocalizedString(@"gps_fail_lable", nil);
//        }
//        [self resetMessageLabelText:text];
//    }
//
//    if ([self.delegate respondsToSelector:@selector(mapView:locationDescribe:)]) {
//        [self.delegate mapView:self locationDescribe:aLocationDescribe];
//    }
//}
//
//- (void)locationAddressFinished:(NSNotification *)sender
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//
//    NSDictionary *userInfo = [sender userInfo];
//    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
//    WSLocationDescribe *aLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
//
//    if (self.hud) {
//        [self.hud hideAnimated:YES];
//        self.hud = nil;
//    }
//
//    if (error || aLocationDescribe.location == nil) {
//        // 解析失败提示
//        NSString *text = @"";
//        if (aLocationDescribe.locationError && ![[WSLocationManager getInstance]  currentLocationServicesEnabled]) {
//            text = [self locationServiceNotAvailableMessage];
//        }else if (aLocationDescribe.errorDescriptMessage) {
//            text = aLocationDescribe.errorDescriptMessage;
//        }
//        self.locationLabel.text = text;
//
//        if (aLocationDescribe.location) {
//            [self resetBottomViewWith:aLocationDescribe.location adress:text];
//            if ([self.delegate respondsToSelector:@selector(mapView:locationDescribe:)]) {
//                [self.delegate mapView:self locationDescribe:aLocationDescribe];
//            }
//        }
//    } else {
//        [self resetBottomViewWith:aLocationDescribe.location adress:aLocationDescribe.detailAddress];
//        if ([self.delegate respondsToSelector:@selector(mapView:locationDescribe:)]) {
//            [self.delegate mapView:self locationDescribe:aLocationDescribe];
//        }
//    }
//}
//
//- (void)locateCurrentLocationNoCache {
//
//    LogTrace();
//    DDLogInfo(@"使用通知方式获取定位回调");
//    [self startUpdatingLocation];
//}
//
//- (NSString *)locationServiceNotAvailableMessage {
//
//    NSString *message= [NSString stringWithFormat:@"%@>%@",NSLocalizedString(@"gps_setting_open", nil),APP_DISPLAY_NAME];
//    return message;
//}
//
//- (void)resetBottomViewWith:(CLLocation *)currentLocaton adress:(NSString *)userAdress {
//
//    if (currentLocaton && userAdress) {
//        // 当前位置
//        [self resetMessageLabelText:userAdress];
//
//        // 水平精度
//        self.accuracyLabel.text = [NSString stringWithFormat:@"%@:%.2f",NSLocalizedString(@"accuracy", nil),currentLocaton.horizontalAccuracy];
//
//        if (currentLocaton.horizontalAccuracy) {
//            if (currentLocaton.horizontalAccuracy < K_AccuracyMin) {
//                self.accuracyLabel.textColor = K_AccuracyMin_Color;
//            } else if (currentLocaton.horizontalAccuracy >= K_AccuracyMin && currentLocaton.horizontalAccuracy < K_AccuracyMax) {
//                self.accuracyLabel.textColor = K_AccuracyMid_Color;
//            } else if (currentLocaton.horizontalAccuracy >= K_AccuracyMax) {
//                self.accuracyLabel.textColor = K_AccuracyMax_Color;
//            }
//        }
//
//        if (self.currentUserAnnotation) {
//            [self.mapView removeAnnotation:self.currentUserAnnotation];
//        }
//        // 当前位置标注
//        NSString *userTitle = NSLocalizedString(@"map_current", nil);
//        WSUserAnnotation *userAnnotation = [[WSUserAnnotation alloc] initWithWgs84:currentLocaton.coordinate title:userTitle];
//        [self.mapView addAnnotation:userAnnotation];
//        self.currentUserAnnotation = userAnnotation;
//
//        self.gcj02Coordinate = [WSLocationManager getActualCoordinateWithWgs84:currentLocaton.coordinate];
//        if (self.currentOverlay) {
//            [self.mapView removeOverlay:self.currentOverlay];
//        }
//
//        BMKCircle *circle = [BMKCircle circleWithCenterCoordinate:self.gcj02Coordinate radius:currentLocaton.horizontalAccuracy];
//
//        self.currentOverlay = circle;
//
//        [self.mapView addOverlay:circle];
//
//        if (self.isCenterForStoreLocation) {
//            if (self.wgs84StoreCoordinate2D.longitude > 0 && self.wgs84StoreCoordinate2D.latitude > 0) {
//                CLLocationCoordinate2D actualStoreCoordinate = [WSLocationManager getActualCoordinateWithWgs84:self.wgs84StoreCoordinate2D];
//                if (self.isReloadLocation) {
//                    [self setMapRegionCenterWith: self.gcj02Coordinate];
//
//                }else{
//
//                    [self setMapRegionCenterWith:actualStoreCoordinate];
//                }
//            }else {
//                [self setMapRegionCenterWith: self.gcj02Coordinate];
//            }
//        }else
//        {
//            [self setMapRegionCenterWith: self.gcj02Coordinate];
//        }
//    }
//}
//
//- (void)resetMessageLabelText:(NSString *)text
//{
//    if (text.length > 0) {
//        self.locationLabel.text = text;
//    }
//}
//
//- (void)setAddress:(NSString *)address
//{
//    [self resetMessageLabelText:address];
//}
//
//-(void)setEmpIdForPid:(NSString *)empId{
//    self.empid = empId;
//    for (WSSubempstoreBean * storeBean in self.empArray) {
//        if ([storeBean.Id isEqualToString:empId]) {
//            [self.empButton setTitle:storeBean.name forState:UIControlStateNormal];
//            break;
//        }
//    }
//}
//
//-(void) loadSubEmpResponsibleAreaOverlay:(NSArray *)overlayStores{
//    if (overlayStores.count == 0) return;
//    CLLocationCoordinate2D *locationCoodinateArr = malloc(sizeof(CLLocationCoordinate2D) * [overlayStores count]);
//    int i = 0;
//    for (WSStoreBean  *store in overlayStores) {
//        locationCoodinateArr[i] = [WSLocationManager getActualCoordinateWithWgs84:CLLocationCoordinate2DMake(store.latitude, store.longitude)];
//        i++;
//    }
//    WSStoreBean  *storeBean = [overlayStores firstObject];
//    NSArray * colorArray = [storeBean.name componentsSeparatedByString:@","];
//    WSPljygonModel * model = [WSPljygonModel polygonWithCoordinates:locationCoodinateArr count:[overlayStores count]];
//    model.lineWidth = 5;
//    model.strokeColor = [UIColor colorWithHexString:[colorArray firstObject]];
//    if (colorArray.count == 2) {
//        model.fillColor = [UIColor colorWithHexString:[colorArray lastObject]];
//    }
//    [self.mapView addOverlay:model];
//
//    free(locationCoodinateArr);
//
//    [self.mapView zoomToFitMapAnnotations];
//}
//
//- (void)refreshUserLocation:(id)sender {
//    UIButton* button=sender;
//    button.enabled=NO;
//
//    if (sender) {
//        WSBaseAnnotation *userAnnotation;
//        for (WSBaseAnnotation *annotation in self.mapView.annotations) {
//            if ([annotation isKindOfClass:[WSUserAnnotation class]]) {
//                userAnnotation = annotation;
//                break;
//            }
//        }
//        if(userAnnotation){
//            [self.mapView removeAnnotation:userAnnotation];
//            if (self.directUserAnnotation) {
//                [self.mapView removeAnnotation:self.directUserAnnotation];
//            }
//        }
//
//        self.locationLabel.text = NSLocalizedString(@"gps_wait_lable", nil);
//        self.accuracyLabel.text = @"...";
//    }
//    self.isReloadLocation = YES;
//    [self  locateCurrentLocationNoCache];
//    if ([self.delegate respondsToSelector:@selector(mapViewIsClickLocationButton)]) {
//        [self.delegate mapViewIsClickLocationButton];
//    }
//    [self performSelector:@selector(abledButton:) withObject:button afterDelay:2.0];
//}
//
//-(void)abledButton:(UIButton*)button
//{
//    button.enabled=YES;
//}
//
//-(void)dropFullScreen:(UIButton*)button{
//    button.selected = !button.selected;
//    if ([self.delegate respondsToSelector:@selector(mapView:dropFullScreen:)]) {
//        [self.delegate mapView:self.mapView dropFullScreen:button.selected];
//    }
//}
//
//-(void)dealloc
//{
//    if (self.mapView.annotations) {
//        [self.mapView removeAnnotations:self.mapView.annotations];
//    }
//    if (self.mapView.overlays) {
//        [self.mapView removeOverlays:self.mapView.overlays];
//    }
//    [self.locationLabel removeFromSuperview];
//    self.locationLabel=nil;
//    [self.accuracyLabel removeFromSuperview];
//    self.accuracyLabel=nil;
//    self.mapView.delegate = nil;
//    self.mapView = nil;
//    [self removeAllSubviews];
//}
//
//- (void)showDetailViewWith:(WSStoreBean *)store {
//    if (store.storeImg.length == 0) {
//        store.storeImg = [[[WSBaseAcvtdisDBService alloc]init] queryStoreImageUrlWithStoreId:store.Id imgType:WSStoreImgTypeSmall];
//    }
//
//    self.selectedStore = store;
//
//    if ([self.delegate respondsToSelector:@selector(mapViewIsClickLocationButton:)]) {
//        [self.delegate mapViewIsClickLocationButton:self.selectedStore];
//    }
//
//    if (self.selectedStore.distance.length == 0 && store.latitude && store.longitude) {
//        CLLocation * storeLocation = [[CLLocation alloc]initWithLatitude:store.latitude longitude:store.longitude];
//        double distance = [[WSLocationManager getInstance] distanceUserLocattion:self.directionLocation fromStoreLocation:storeLocation];
//        self.selectedStore.distance = [WSLocationManager convertDistance:distance];
//    }
//    if (store.isSubEmpInfo) {
//
//        CGFloat height = [WSMapBottomInfoView heightForStore:store width:self.width];
//
//        if (!self.bottomInfoView) {
//            self.bottomInfoView = [[WSMapBottomInfoView alloc] initWithFrame:CGRectMake(0, self.mapView.height, self.width, height)];
//            [self.mapView addSubview:self.bottomInfoView];
//
//            UITapGestureRecognizer *recognizer =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
//            [self.bottomInfoView addGestureRecognizer:recognizer];
//        }
//
//        self.bottomInfoView.frame = CGRectMake(0, self.mapView.height, self.width, height);
//        [self moveView:self.bottomInfoView offset:-height];
//        [self.bottomInfoView setStore:store];
//        _storeListCellHeight = height;
//        [self setNeedsLayout];
//        [self setRoleNameAndEmpNameWithEmpId:store.Id];
//
//        return;
//    }
//
//    if (_currentDetailView == nil)
//    {
//        _currentDetailView = [[WSSelectListNewTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil
//                                                                   withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:@"0" cellWidth:self.width];
//        _currentDetailView.backgroundColor = [UIColor whiteColor];
//        CGFloat cellHeight = [WSSelectListNewTableviewCell heightForRowWithStore:store cellWidth:self.width isHavePrepareButton:NO withOpt:self.currentFuncs.opt];
//        _currentDetailView.isDistance = YES;
//        _currentDetailView.frame = CGRectMake(0, self.mapView.height, self.width, cellHeight);
//        _currentDetailView.delegate = self;
//        [self.mapView addSubview:_currentDetailView];
//
//        UITapGestureRecognizer *recognizer =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
//        [_currentDetailView addGestureRecognizer:recognizer];
//    }
//    [self.currentDetailView setStore:store withOpt:self.currentFuncs.opt];
//
//    CGFloat cellHeight = [WSSelectListNewTableviewCell  heightForRowWithStore:store cellWidth: self.width isHavePrepareButton:NO withOpt:self.currentFuncs.opt];
//    _currentDetailView.frame = CGRectMake(0, self.mapView.height, self.width, cellHeight);
//    _storeListCellHeight = cellHeight;
//    [self setNeedsLayout];
//
//    if (FLOAT_IS_EQUAL(self.currentDetailView.origin.y,self.mapView.height)) {
//        [self moveView:self.currentDetailView offset:- cellHeight];
//
//        CGFloat bottomMargin = 20;
//
//        self.zoomButtonBgView.frame = CGRectMake(self.mapView.width - ZoomButtonBgViewWidth - MAIN_PADDING, self.mapView.height  - ZoomButtonBgViewHeight - _storeListCellHeight - bottomMargin, ZoomButtonBgViewWidth, ZoomButtonBgViewHeight);
//        self.locationBtn.frame = CGRectMake( 20,self.mapView.height - ZoomButtonBgViewWidth - bottomMargin - _storeListCellHeight, ZoomButtonBgViewWidth, ZoomButtonBgViewWidth);
//    }
//}
//
//-(void)moveView:(UIView *)view offset:(CGFloat)offset{
//
//    NSTimeInterval animationDuration = 1.0f;
//    CGRect frame = view.frame;
//    frame.origin.y +=offset;
//    view.frame = frame;
//    [UIView beginAnimations:@"ResizeView" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    view.frame = frame;
//    [UIView commitAnimations];
//}
//
//- (void)tapClick:(UIGestureRecognizer *)gesture {
//
//    if ([self.selectedStore.canClick isEqualToString:@"0"]||[self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//        return;
//    }
//
//    if ([self.currentFuncs.opt.isJumpCallPlan isEqualToString:@"0"]) return;
//
//    if (!self.selectedStore.isRouteStore) {
//        if ([_delegate respondsToSelector:@selector(mapView:annotationStore:)]) {
//            [_delegate mapView:self.mapView annotationStore:self.selectedStore];
//        }
//    }
//}

//-(void)loadEmpListView:(UIButton *)btn{
//    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
//    UIView *rootView = delegate.window.rootViewController.view;
//
//    NSMutableArray *empListArray = [NSMutableArray arrayWithCapacity:self.empArray.count];
//    NSInteger  popListViewTag ;
//
//    if (btn == self.RoleButton) {
//        empListArray = self.roleArray.mutableCopy;
//        popListViewTag = PopViewTypeRolelist;
//    }else{
//        if (self.roleArray.count > 0 && ![self.RoleButton.titleLabel.text isEqualToString:@"角色选择"]) {
//            for (WSSubempstoreBean  *subStore in self.empArray) {
//                if ([subStore.jobTitle isEqualToString:self.roleName]) {
//                    [empListArray addObject:subStore.name];
//                }
//            }
//
//        }else{
//            empListArray = [self.empArray valueForKeyPath:@"name"];
//
//        }
//        popListViewTag = PopViewTypeEmplist;
//    }
//    self.emplistArray = empListArray.copy;
//    WCPopListView *view = [[WCPopListView alloc] initWithTotalArry:empListArray selectedArray:nil withSelectedMode:WCPopListSigleSelected animationType:WCPopListAnimationTypeFromPoint maxHeight:K_EmpListViewHeight];
//    view.tag = popListViewTag;
//
//    [view setITableViewTextColor:RGBCOLOR(51, 51, 51)];
//    [view setRowHeight:30];
//    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
//    view.animationPoint = CGPointMake(rootView.width - 20 - WCROWHEIGHT, 80);
//    view.autoHideWhenSelect = YES;
//    [view setPopListViewColor:[UIColor clearColor]];
//    view.iDelegate = self;
//
//    CGFloat popListHeight = K_EmpListViewHeight;
//    if ([empListArray count] * WCROWHEIGHT <  popListHeight) {
//        popListHeight = [empListArray count] * 30;
//    }
//
//    CGFloat width = [view getMaxWidth] + K_LRSPACE_WIDTH ;
//    if (!IOS8_OR_LATER && INTERFACE_IS_PAD) {
//        [view showViewFromRect:CGRectMake(btn.right - width, 64 + btn.bottom , width, popListHeight + 20) inView:rootView animated:YES];
//    }
//    else{
//        [view showViewFromRect:CGRectMake(btn.right - width, 64 + btn.bottom , width, popListHeight + 20) inView:rootView animated:YES];
//    }
//    [view setBackgroundImage:[UIImage imageNamed:@"menu_bj_white"]];
//}
//
//#pragma -mark  WSMapSubTrailViewDelegate (代理方法)
//-(void)didSelectDate:(NSString *)biz_date{
//
//    self.timeLabelStr = biz_date;
//    self.timeLabel.text = biz_date;
//    [self querySubEmpStoreWithDate];
//}
//
//-(void)querySubEmpStoreWithDate{
//
//    if ([self.delegate respondsToSelector:@selector(requestSubEmpStoreAndReloadMapviewWith:andEmpId:)]) {
//        [self.delegate requestSubEmpStoreAndReloadMapviewWith:self.timeLabel.text ? : self.timeLabelStr andEmpId:self.empid];
//    }
//
//}
//- (void)searchDown
//{
//    if (self.empid && self.empid.length > 0) {
//        [self.bottomInfoView removeAllSubviews];
//        [self.bottomInfoView  removeFromSuperview];
//        [_currentDetailView removeAllSubviews];
//        [_currentDetailView removeFromSuperview];
//        self.bottomInfoView = nil;
//        _currentDetailView = nil;
//        [self setNeedsLayout];
//        [self querySubEmpStoreWithDate];
//    }
//    else
//    {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请选择人员" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//
//    }
//
//}
//- (void)removeStorea;
//{
//    [_currentDetailView removeAllSubviews];
//    [_currentDetailView removeFromSuperview];
//    _currentDetailView = nil;
//    [self setNeedsLayout];
//}
//#pragma -mark  WCPopListViewDelegate
//- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex{
//
//    if (self.isSubEmpTrail)     // MN-286
//    {
//        if (popListView.tag == PopViewTypeEmplist)
//        {
//            WSSubempstoreBean *bean = [self getSubempStoreBeanWithName:self.emplistArray[anIndex]] ;
//            self.empid = bean.Id;
//            self.roleName = bean.name;
//            [self.empButton setTitle:bean.name forState:UIControlStateNormal];
//
//            if ([self.delegate respondsToSelector:@selector(refreshTitle:)]) {
//                [self.delegate refreshTitle:bean.name];
//            }
//        }else{
//            self.empid = nil;
//            self.roleName = self.roleArray[anIndex];
//            [self.RoleButton setTitle:self.roleName forState:UIControlStateNormal];
//            [self.empButton setTitle:@"人员" forState:UIControlStateNormal];
//        }
//        if (![self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//            [self querySubEmpStoreWithDate];
//        }
//
//    }else
//    { // 实时点名的话 选择人员把选择的人员放在地图中心，选择角色把属于当前角色的人员显示在地图上
//        for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//            if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//                [self.mapView removeAnnotation:storeAnnotation];
//            }
//        }
//
//        if (popListView.tag == PopViewTypeEmplist) {
//            WSSubempstoreBean *bean = [self getSubempStoreBeanWithName:self.emplistArray[anIndex]] ;
//            [self.empButton setTitle:bean.name forState:UIControlStateNormal];
//            if ([self.currentFuncs.opt.isShowSubArea isEqualToString:@"1"]) {
//                self.empid = bean.Id;
//                [self querySubEmpStoreWithDate];
//                return;
//            }
//            if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//                self.empid = bean.Id;
//            }
//
//            for (WSStoreBean * storeBean in self.allStores) {
//                if ([storeBean.Id isEqualToString:bean.Id]) {
//                    if (storeBean.latitude > 0 && storeBean.longitude > 0) {
//                        //MN-4035 网点采集，地理位置偏差 蒙牛需要用GAODE2WGS84判断
//                        WSStoreAnnotation *tmpStoreAnnotation;
//                        NSString *isTransformCoordinate = [[NSUserDefaults standardUserDefaults] objectForKey:GAODE2WGS84];
//                        if ([isTransformCoordinate isEqualToString:@"0"]) {
//                            tmpStoreAnnotation = [[WSStoreAnnotation alloc] initWith:CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude) annotationStore:storeBean];
//                        }else if ([isTransformCoordinate isEqualToString:@"1"]){
//                            tmpStoreAnnotation = [[WSStoreAnnotation alloc]initWithWgs84:CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude) annotationStore:storeBean];
//                        }
//
//                        [self.mapView addAnnotation:tmpStoreAnnotation];
//                        [self setMapRegionCenterWith:tmpStoreAnnotation.coordinate];
//                        [self showDetailViewWith:storeBean];
//                        return;
//                    }
//                }
//            }
//        }else{
//            self.roleName = self.roleArray[anIndex];
//            NSMutableArray * peopelForRoleAnnotation = [[NSMutableArray alloc]init];
//            for (WSSubempstoreBean * subempStore in self.empArray) {
//                if ([subempStore.jobTitle isEqualToString:self.roleName]) {
//                    for (WSStoreBean * storeBean in self.allStores) {
//                        if ([storeBean.Id isEqualToString:subempStore.Id]) {
//                            WSStoreAnnotation * annotation = [[WSStoreAnnotation alloc]initWithWgs84:CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude) annotationStore:storeBean];
//                            [peopelForRoleAnnotation addObject:annotation];
//                        }
//                    }
//                }
//            }
//
//            [self.mapView addAnnotations:peopelForRoleAnnotation];
//
//            [self.mapView zoomToFitMapAnnotations];
//            [self.RoleButton setTitle:self.roleName forState:UIControlStateNormal];
//            [self.empButton setTitle:@"人员" forState:UIControlStateNormal];
//        }
//    }
//
//}
//
//-(WSSubempstoreBean *)getSubempStoreBeanWithName:(NSString *)name{
//    for (WSSubempstoreBean  *bean in self.empArray) {
//        if ([bean.name isEqualToString:name]) {
//            return bean;
//        }
//    }
//    return nil;
//}
//
//-(void)setRoleNameAndEmpNameWithEmpId:(NSString *)empid{
//    for (WSSubempstoreBean *subEmp in self.empArray) {
//        if ([subEmp.Id isEqualToString:empid]) {
//            self.roleName = subEmp.jobTitle;
//            [self.RoleButton setTitle:subEmp.jobTitle forState:UIControlStateNormal];
//            [self.empButton setTitle:subEmp.name forState:UIControlStateNormal];
//            break;
//        }
//    }
//}
//
//
//
//
//
//
//
////------------------------------------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------------------
////关注部分代码整理-----------------------------------------------------------------------------------------------------------------
//#pragma mark - 是否关注按键点击 indexPath:索引路径
//- (void)isFollowButtonClick:(NSIndexPath *)indexPath {
//
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip", nil) tips:nil
//                        tapTarget:self action:nil];
//    [self performSelector:@selector(delayRequestFollow) withObject:nil afterDelay:0.5f];
//}
//
//#pragma mark - 延迟请求关注方法
//- (void)delayRequestFollow {
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followFinishRequest:) name:@"mapView_follow_notify"
//                                               object:nil];
//    [[WSRequestHelper shareInstance] uploadFollowStateWithContent:self.selectedStore.follow storeId:self.selectedStore.Id
//                                                             srid:self.empid notifyName:@"mapView_follow_notify"];
//}
//
//#pragma mark - 关注完成请求方法
//- (void)followFinishRequest:(id)sender {
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mapView_follow_notify" object:nil];
//
//    NSError *error = [[sender userInfo] objectForKey:ERROR];
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//    NSDictionary *dataDic = [info objectFromJSONString];
//    NSString *flag = [NSString stringWithValue:[dataDic objectForKey:@"result"]];
//
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//
//    if (error || ![flag isEqualToString:@"1"]) {
//        NSString *tmpString = NSLocalizedString(@"refresh_failure", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil
//                                 type:MBProgressHUDMessageTypeFailed];
//    } else {
//        NSString *follow = ([self.selectedStore.follow isEqualToString:@"0"]) ? @"1" : @"0";
//        self.selectedStore.follow = follow;
//        [[WSBaseStoreTable sharedTable] updateWithNames:@[@"follow"] values:@[follow] whereName:@[@"store_Id", @"empId"]
//                                             whereValue:@[self.selectedStore.Id, self.selectedStore.empId]];
//        [self.currentDetailView setStore:self.selectedStore withOpt:self.currentFuncs.opt];
//    }
//}
//
////------------------------------------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------------------
////地图代理代码整理-----------------------------------------------------------------------------------------------------------------
//
//#pragma mark - 实现mapView:didDeselectAnnotationView:代理协议
//- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
//
//    if ([view.annotation isKindOfClass:[WSStoreAnnotation class]]) {
//
//        WSStoreAnnotationView *annotationView = (WSStoreAnnotationView *)view;
//        annotationView.storeAnnotation = view.annotation;
//
//        [_currentDetailView removeAllSubviews];
//        [_currentDetailView removeFromSuperview];
//        _currentDetailView = nil;
//        [self setNeedsLayout];
//    }
//}
//
//#pragma mark - 实现mapView:didSelectAnnotationView:代理协议
//- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
//
//    if (self.isShowStoreDetailMsg && [view.annotation isKindOfClass:[WSStoreAnnotation class]]) {
//
//        if ([view isKindOfClass:[WSStoreAnnotationView class]]) {
//            WSStoreAnnotationView *annotationView = (WSStoreAnnotationView *)view;
//            [annotationView setAnnotatinViewImage:[UIImage imageForName:@"map_select_blue"]];
//
//            WSStoreAnnotation *annotation = view.annotation;
//            [self showDetailViewWith:annotation.store];
//        }
//    }
//}
//
//#pragma mark - 实现mapView:viewForAnnotation:代理协议
//- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
//
//    if ([annotation isKindOfClass:[BMKUserLocation class]]) {
//        return nil;
//    }
//
//    if ([annotation isKindOfClass:[WSUserAnnotation class]]) {
//
//        NSString *identifier = @"UserAnnotationView";
//        WSUserAnnotationView *view = (WSUserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (!view) {
//            view = [[WSUserAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//            [view setCanShowCallout:YES];
//        } else {
//            view.annotation = annotation;
//        }
//        return view;
//    }
//
//    if ([annotation isKindOfClass:[WSDirectUserAnnotation class]]) {
//
//        NSString *identifier = @"DirectionAnnotationView";
//        BMKAnnotationView *view = (WSUserAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (!view) {
//            view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//            //view.image = [UIImage scaledImageForName:@"icon_current_location" ofType:@"png"];
//        } else {
//            view.annotation = annotation;
//        }
//        return view;
//    }
//
//    if ([annotation isKindOfClass:[WSStoreAnnotation class]]) {
//
//        NSString *identifier = @"storeAnnotationIndentifier";
//        WSStoreAnnotationView *view = (WSStoreAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (!view) {
//            view = [[WSStoreAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//        } else {
//            view.annotation = annotation;
//        }
//        view.storeAnnotation = annotation;
//        return view;
//    }
//
//    return nil;
//}
//
//#pragma mark - 实现mapView:viewForOverlay:代理协议
//- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay {
//
//    if ([overlay isKindOfClass:[BMKPolyline class]]) {
//
//        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
//        if ([overlay isEqual:self.inPolyline]) {
//            polylineView.lineWidth = 6.0f;
//            polylineView.strokeColor = [UIColor greenColor];
//            polylineView.lineDashType = kBMKLineDashTypeNone;
//        } else if ([overlay isEqual:self.actualyPolyline]) {
//            polylineView.lineWidth = 6.0f;
//            polylineView.strokeColor = [UIColor redColor];
//            polylineView.lineDashType = kBMKLineDashTypeNone;
//        }
//        return polylineView;
//    }
//
//    return nil;
//}
//
////------------------------------------------------------------------------------------------------------------------------------
////------------------------------------------------------------------------------------------------------------------------------
////地图绘制代码整理-----------------------------------------------------------------------------------------------------------------
//#pragma mark - 加载地图线路按键组方法
//- (void)loadMapRoutingButtons {
//
//    NSString *text = NSLocalizedString(@"plan_orbit", nil);
//    UIColor *color = [UIColor greenColor];
//    NSInteger tag = (K_SCALE_BUTON_BASE_TAG + 2);
//    self.inPlanBtn = [self addRoutingPlanWith:text Color:color tag:tag];
//    [self.mapView addSubview:self.inPlanBtn];
//
//    text = NSLocalizedString(@"visited_orbit", nil);
//    color = [UIColor redColor];
//    tag = (K_SCALE_BUTON_BASE_TAG + 3);
//    self.actualyBtn = [self addRoutingPlanWith:text Color:color tag:tag];
//    [self.mapView addSubview:self.actualyBtn];
//
//    text = NSLocalizedString(@"unplan_store", nil);
//    color = [UIColor colorWithHexString:@"#0093d0"];
//    tag = (K_SCALE_BUTON_BASE_TAG + 4);
//    self.outPlanBtn  = [self addRoutingPlanWith:text Color:color tag:tag];
//    [self.mapView addSubview:self.outPlanBtn];
//}
//
//#pragma mark - 生成通用线路按键方法(标签转按键)
//- (UILabel *)addRoutingPlanWith:(NSString *)title Color:(UIColor *)color tag:(NSInteger)tag {
//
//    UILabel *label = [[UILabel alloc] init];
//    label.backgroundColor = color;
//    label.numberOfLines = 2;
//    label.textColor = [UIColor whiteColor];
//    label.text = title;
//    label.alpha = 0.4;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.layer.cornerRadius = 5;
//    label.clipsToBounds = YES;
//    label.tag = tag;
//
//    label.userInteractionEnabled = YES;
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick:)];
//    [label addGestureRecognizer:gesture];
//    return label;
//}
//
//#pragma mark - 地图线路按键点击事件
//- (void)labelClick:(UITapGestureRecognizer *)gesture {
//
//    UILabel *label = (UILabel *)gesture.view;
//    label.highlighted = !label.highlighted;
//
//    if (label.tag == K_SCALE_BUTON_BASE_TAG + 2) {
//        label.backgroundColor = (label.highlighted ? [UIColor grayColor] : [UIColor greenColor]);
//    } else if (label.tag == K_SCALE_BUTON_BASE_TAG + 3) {
//        label.backgroundColor = (label.highlighted ? [UIColor grayColor] : [UIColor redColor]);
//    } else if (label.tag == K_SCALE_BUTON_BASE_TAG + 4) {
//        label.backgroundColor = (label.highlighted ? [UIColor grayColor] : [UIColor colorWithHexString:@"#0093d0"]);
//    }
//    [self loadRoutingPlanWithType:UIRoutingPlanTypeNew withPlanArray:nil andActuallyArray:nil];
//}
//
//#pragma mark - 加载门店线路方法 allStores:当前页码门店数据 todayVisitArray:今日拜访门店数据 actualVisitArray:全部门店数据
//- (void)loadStoresRoutingWith:(NSArray *)allStores todayVisitArray:(NSArray *)todayVisitArray
//             actualVisitArray:(NSArray *)actualVisitArray {
//    //角色a用2.0的处理逻辑，角色b用3.0的处理逻辑
//    //SFA-34002
//    if ([self.currentFuncs.opt.resourceForm isEqualToString:APPUSERINFOTYPE_TSKF]||self.currentFuncs.opt.resourceForm == nil) {
//        [self p_loadTSKFMapViewWithAllStoreArray:allStores todayVisitArray:todayVisitArray actualVisitArray:actualVisitArray];
//    }
//    if ([self.currentFuncs.opt.resourceForm isEqualToString:APPUSERINFOTYPE_PCH]) {
//        [self p_loadPCHMapViewWithAllStoreArray:allStores todayVisitArray:todayVisitArray actualVisitArray:actualVisitArray];
//    }
//
//}
//#pragma mark---------角色TSKFMap 2.0逻辑---------
//- (void)p_loadTSKFMapViewWithAllStoreArray:(NSArray *)allStores todayVisitArray:(NSArray *)todayVisitArray
//                   actualVisitArray:(NSArray *)actualVisitArray{
//    self.inPlanArray = [NSMutableArray arrayWithCapacity:0];
//    self.outPlanArray = [NSMutableArray arrayWithCapacity:0];
//    self.actuallyArray = [NSMutableArray arrayWithCapacity:0];
//    self.allStores = [allStores mutableCopy];
//
//    for (WSStoreBean * bean in allStores) {
//        if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//            if ([bean.is_plan isEqualToString:@"0"]) {
//                [self.actuallyArray addObject:bean];
//            }
//            else if ([bean.is_plan isEqualToString:@"1"])
//            {
//                [self.inPlanArray addObject:bean];
//
//            }
//            else if ([bean.is_plan isEqualToString:@"2"])
//            {
//                [self.outPlanArray addObject:bean];
//            }
//        }
//        else
//        {
//
//            if (bean.seq && ![bean.seq isEqualToNumber:@999] && ![bean.seq isEqualToNumber:@0]) {
//                bean.row_number = bean.seq.stringValue;
//            }
//
//            if (bean.plan || bean.bPlanned) {
//                //            bean.row_number = bean.visitPlanMapOrder;
//                [self.inPlanArray addObject:bean];
//            }else{
//                // 如果来自实时点名第二层拜访轨迹的的门店，则认为是实际路线。此地方的拜访轨迹没有计划外数据。
//                if (!bean.isAcctuallyRouteStore) {
//                    [self.outPlanArray addObject:bean];
//                }
//            }
//            if ([bean.actionState isEqualToString:@"1"] || bean.isAcctuallyRouteStore) {
//                [self.actuallyArray addObject:bean];
//            }
//        }
//    }
//    NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"last_date" ascending:YES];
//    NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
//    self.actuallyArray = [[self.actuallyArray sortedArrayUsingDescriptors:descriptorArray] mutableCopy];
//    for (int i = 1 ; i < self.actuallyArray.count + 1; i++) {
//        WSStoreBean * store = self.actuallyArray[i-1];
//        if (!store.isAcctuallyRouteStore) {
//            store.row_number = [NSString stringWithFormat:@"%d",i];
//        }
//    }
//    UIRoutingPlanType type;
//    if (self.inPlanArray.count > 1 && self.actuallyArray.count > 1) {
//        type = UIRoutingPlanTypeAll;
//    }else if (self.inPlanArray.count > 1 && self.actuallyArray.count < 2){
//        type = UIRoutingPlanTypeInPlan;
//    }else if (self.inPlanArray.count < 2   && self.actuallyArray.count > 1){
//        type = UIRoutingPlanTypeActually;
//    }else{
//        type =  UIRoutingPlanTypeNone ;
//    }
//
//
//    if (self.currentFuncs.opt.hidePlanOrbit.length > 0) { // 修改参数 与安卓一致
//        NSInteger hidePlanOrbit = [self.currentFuncs.opt.hidePlanOrbit integerValue];
//        BOOL isHidePlan = (hidePlanOrbit & WSHidePlanOrBitPlan);
//        BOOL isHideActually = (hidePlanOrbit & WSHidePlanOrBitActually);
//        BOOL isHideOutPlan = (hidePlanOrbit & WSHidePlanOrBitOutPlan);
//        if (isHidePlan) { //按与计算 相等 隐藏计划内
//            [self.inPlanArray removeAllObjects];
//        }
//        if (isHideActually) { //按与计算 相等 隐藏实际
//            [self.actuallyArray removeAllObjects];
//        }
//
//        if (isHideOutPlan) { //按与计算 相等 隐藏计划外
//            [self.outPlanArray removeAllObjects];
//        }
//
//        if (isHidePlan && isHideOutPlan && isHideActually) { // 如果都隐藏则只显示门店坐标点 没有连线
//            type = UIRoutingPlanTypeNone;
//        }
//    }
//
//    [self loadRoutingPlanWithType:type withPlanArray:self.inPlanArray andActuallyArray:self.actuallyArray];
//}
//#pragma mark---------角色TSKFMap 3.0逻辑---------
//- (void)p_loadPCHMapViewWithAllStoreArray:(NSArray *)allStores todayVisitArray:(NSArray *)todayVisitArray
//                          actualVisitArray:(NSArray *)actualVisitArray{
//    NSMutableDictionary *storeIdDic = [[NSMutableDictionary alloc] init];
//    for (int i = 0; i < todayVisitArray.count; ++i) {
//
//        WSStoreBean *storeBean = [todayVisitArray objectAtIndex:i];
//        [storeIdDic setObject:storeBean.Id forKey:storeBean.Id];
//    }
//    NSMutableArray *opArray = [[NSMutableArray alloc] init];
//    NSMutableArray *aArray = [[NSMutableArray alloc] init];
//    for (int i = 0; i < actualVisitArray.count; ++i) {
//
//        WSStoreBean *storeBean = [actualVisitArray objectAtIndex:i];
//        if ([storeBean.actionState isEqualToString:ActionDone] || [storeBean.actionState isEqualToString:ActionWorking]) {
//            [aArray addObject:storeBean];
//        }
//
//        NSString *todayStoreId = [storeIdDic objectForKey:storeBean.Id];
//        if (todayStoreId.length > 0) {
//            continue;
//        /}
//        [opArray addObject:storeBean];
//    }
//
//    //全部门店数据
//    [self.allStores removeAllObjects];
//    self.allStores = [NSMutableArray arrayWithArray:actualVisitArray];
//
//    //计划内数据数组(今日拜访列表内数据)
//    [self.inPlanArray removeAllObjects];
//    self.inPlanArray = [NSMutableArray arrayWithArray:todayVisitArray];
//
//    //计划外数据数组(门店列表数据 - 今日拜访列表数据)
//    [self.outPlanArray removeAllObjects];
//    self.outPlanArray = [NSMutableArray arrayWithArray:opArray];
//
//    //实际轨迹数组(已访门店 + 未离店)
//    NSString *empIdStr = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *bizDateStr = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray *whereNames = [NSArray arrayWithObjects:@"emp_id", @"biz_date", nil];
//    NSArray *whereValues = [NSArray arrayWithObjects:empIdStr, bizDateStr, nil];
//    NSArray *inoutStores = [[WSInoutStoreTable sharedTable] queryWithNames:whereNames ArgumentsValue:whereValues];
//    NSSortDescriptor *carNameDesc = [NSSortDescriptor sortDescriptorWithKey:@"last_date" ascending:YES];
//    NSArray *descriptorArray = [NSArray arrayWithObjects:carNameDesc, nil];
//
//    [self.actuallyArray removeAllObjects];
//    self.actuallyArray = [NSMutableArray arrayWithArray:[aArray sortedArrayUsingDescriptors:descriptorArray]];
//    for (int i = 0; i < self.actuallyArray.count; i++) {
//
//        WSStoreBean *store = self.actuallyArray[i];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"store_id CONTAINS %@", store.Id];
//        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[inoutStores filteredArrayUsingPredicate:predicate]];
//        WSInoutStoreObject *obj = [resultArray firstObject];
//        if (obj.out_lon.length > 0 && obj.out_lat.length) {
//            store.actualVisitLongitude = [obj.out_lon doubleValue];
//            store.actualVisitLatitude = [obj.out_lat doubleValue];
//        } else if (obj.in_lon.length > 0 && obj.in_lat.length) {
//            store.actualVisitLongitude = [obj.in_lon doubleValue];
//            store.actualVisitLatitude = [obj.in_lat doubleValue];
//        }
//
//        if (!store.isAcctuallyRouteStore) {
//            store.row_number = [NSString stringWithFormat:@"%d", (i + 1)];
//        }
//    }
//
//    [self loadRoutingPlanWithType:UIRoutingPlanTypeNew withPlanArray:nil andActuallyArray:nil];
//}
//#pragma mark - 绘制门店线路方法
//- (void)loadRoutingPlanWithType:(UIRoutingPlanType)type withPlanArray:(NSArray *)planArray
//               andActuallyArray:(NSArray *)actuallyArray {
//
//    [_currentDetailView removeFromSuperview];
//    _currentDetailView = nil;
//
//    //需要删除之前画的线和大头针
//    for (WSStoreAnnotation *storeAnnotation in self.mapView.annotations) {
//        if ([storeAnnotation isKindOfClass:[WSStoreAnnotation class]]) {
//            [self.mapView removeAnnotation:storeAnnotation];
//        }
//    }
//    [self.mapView removeOverlays:self.mapView.overlays];
//
//    //绘制计划外门店(由按键outPlanBtn控制展示与隐藏)
//    if (!self.outPlanBtn.highlighted && self.outPlanArray.count > 0) {
//
//        NSMutableArray *annotations = [[NSMutableArray alloc] init];
//        for (int i = 0; i < self.outPlanArray.count; ++i) {
//            WSStoreBean *storeBean = [self.outPlanArray objectAtIndex:i];
//            CLLocationCoordinate2D storeCoordinate = CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude);
//            if (storeBean.latitude != 0 && storeBean.longitude != 0 && CLLocationCoordinate2DIsValid(storeCoordinate)) {
//                WSStoreAnnotation *storeAnnotation = [[WSStoreAnnotation alloc] initWith:storeCoordinate annotationStore:storeBean];
//                storeAnnotation.isNewSet = YES;
//                storeAnnotation.annotationImgStr = @"map_gray";
//                storeAnnotation.isShowRowNumber = NO;
//                [annotations addObject:storeAnnotation];
//            }
//        }
//        if (annotations.count > 0) {
//            [self.mapView addAnnotations:annotations];
//        }
//    }
//
//    //绘制计划内门店(存在数据就展示)
//    if (!self.inPlanBtn.highlighted &&self.inPlanArray.count > 0) {
//
//        NSMutableArray *annotations = [[NSMutableArray alloc] init];
//        for (int i = 0; i < self.inPlanArray.count; ++i) {
//            WSStoreBean *storeBean = [self.inPlanArray objectAtIndex:i];
//            CLLocationCoordinate2D storeCoordinate = CLLocationCoordinate2DMake(storeBean.latitude, storeBean.longitude);
//            if (storeBean.latitude != 0 && storeBean.longitude != 0 && CLLocationCoordinate2DIsValid(storeCoordinate)) {
//                WSStoreAnnotation *storeAnnotation = [[WSStoreAnnotation alloc] initWith:storeCoordinate annotationStore:storeBean];
//                storeAnnotation.isNewSet = YES;
//                storeAnnotation.annotationImgStr = @"map_green";
//                storeAnnotation.isShowRowNumber = NO;
//                [annotations addObject:storeAnnotation];
//            }
//        }
//
//        if (annotations.count > 0) {
//            [self.mapView addAnnotations:annotations];
//        }
//        if (!self.inPlanBtn.highlighted) {
//            [self dealWithStores:self.inPlanArray withType:UIRoutingPlanLineTypeNewInPlan];
//        }
//    }
//
//    //绘制路线轨迹门店(存在数据就展示)
//
//    NSString *empIdStr = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *bizDateStr = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    NSArray *whereNames = [NSArray arrayWithObjects:@"emp_id", @"biz_date", nil];
//    NSArray *whereValues = [NSArray arrayWithObjects:empIdStr, bizDateStr, nil];
//    NSArray *inoutStores = [[WSInoutStoreTable sharedTable] queryWithNames:whereNames ArgumentsValue:whereValues];
//
//    if (self.actuallyArray.count > 0) {
//
//        NSMutableArray *annotations = [[NSMutableArray alloc] init];
//        for (int i = 0; i < self.actuallyArray.count; ++i) {
//            WSStoreBean *storeBean = [self.actuallyArray objectAtIndex:i];
//
//
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"store_id CONTAINS %@", storeBean.Id];
//            NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[inoutStores filteredArrayUsingPredicate:predicate]];
//            WSInoutStoreObject *obj = [resultArray firstObject];
//            if (obj.out_lon.length > 0 && obj.out_lat.length) {
//                storeBean.actualVisitLongitude = [obj.out_lon doubleValue];
//                storeBean.actualVisitLatitude = [obj.out_lat doubleValue];
//            } else if (obj.in_lon.length > 0 && obj.in_lat.length) {
//                storeBean.actualVisitLongitude = [obj.in_lon doubleValue];
//                storeBean.actualVisitLatitude = [obj.in_lat doubleValue];
//            }
//            double longitude = storeBean.actualVisitLongitude;
//            double latitude = storeBean.actualVisitLatitude;
//            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
//            if (latitude != 0 && longitude != 0 && CLLocationCoordinate2DIsValid(coordinate)) {
//                WSStoreAnnotation *storeAnnotation = [[WSStoreAnnotation alloc] initWith:coordinate annotationStore:storeBean];
//                storeAnnotation.isNewSet = YES;
//                storeAnnotation.annotationImgStr = @"map_red";
//                storeAnnotation.isShowRowNumber = YES;
//                [annotations addObject:storeAnnotation];
//            }
//        }
//
//        if (annotations.count > 0) {
//            [self.mapView addAnnotations:annotations];
//        }
//        if (!self.actualyBtn.highlighted) {
//            [self dealWithStores:self.actuallyArray withType:UIRoutingPlanLineTypeNewActuallyPlan];
//        }
//    }
//
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weakSelf.mapView zoomToFitMapAnnotations];
//    });
//
//    [self setNeedsLayout];
//}
//
//#pragma mark - 绘制门店线路轨迹方法
//- (void)dealWithStores:(NSArray *)array withType:(UIRoutingPlanLineType)type {
//
//    if (array.count <= 1) {
//        return;
//    }
//
//    NSInteger count = 0;
//    CLLocationCoordinate2D *coodinateArray = malloc(sizeof(CLLocationCoordinate2D) * array.count);
//    for (int i = 0; i < array.count; ++i) {
//
//        WSStoreBean *storeBean = [array objectAtIndex:i];
//        double longitude = storeBean.longitude;
//        double latitude = storeBean.latitude;
//        if (type == UIRoutingPlanLineTypeNewActuallyPlan) {
//            longitude = storeBean.actualVisitLongitude;
//            latitude = storeBean.actualVisitLatitude;
//        }
//
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
//        if (longitude != 0 && latitude != 0 && CLLocationCoordinate2DIsValid(coordinate)) {
//            coodinateArray[count] = coordinate;
//            count++;
//        }
//    }
//
//    if (count > 0) {
//
//        BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coodinateArray count:count];
//        [self.mapView addOverlay:polyline];
//
//        if (type == UIRoutingPlanLineTypeNewInPlan) {
//            self.inPolyline = polyline;
//        } else if (type == UIRoutingPlanLineTypeNewActuallyPlan) {
//            self.actualyPolyline = polyline;
//        }
//    }
//    free(coodinateArray);
//}

@end
//==============================================================================================================================
