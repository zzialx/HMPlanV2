//
//  WCSearchRoutesInMapViewController.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 5/10/13.
//
//

#import <MapKit/MapKit.h>

#import "WSSearchRoutesInMapViewController.h"
#import "WSBasicAnnotation.h"

#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSInPlanStoreBean.h"
#import "WSOutPlanStoreBean.h"
#import "WSStoreBean.h"

#import "WSMKCallOutAnnotationView.h"
#import "WSAnnotationContentView.h"
#import "WCPopListView.h"
#import "WSPromptView.h"
#import "WSRequestHelper.h"
#import "WSLocationManager.h"

#define kFetchNearByStoreNotifyName @"fetchNearByStoreNotifyName"

#define kLocationThreshold 0.0001

#define kMapSpan 40000

enum {
    WCSearchRouteTypeBaiduMapApp = 0,
     WCSearchRouteTypeGoogleMapApp,
    WCSearchRouteTypeBaiduMapWeb,
    WCSearchRouteTypeGoogleMapWeb
};
typedef NSUInteger WCSearchType;

#define WC_BAIDUMAPWEB_SEARCHROUTE  @"http://api.map.baidu.com/direction?origin=latlng:%.12f,%.12f|name:%@&destination=latlng:%.12f,%.12f|name:%@&mode=transit&origin_region=北京&destination_region=北京&output=html"





#define WC_BAIDUMAPAPP_SEARCHROUTE  @"baidumap://map/direction?origin=latlng:%.12f,%.12f|name:%@&destination=latlng:%.12f,%.12f|name:%@&mode=transit"

#define WC_GOOGLEMAPAPP_SEARCHROUTE @"comgooglemaps://?saddr=%@@%.12f,%.12f&daddr=%@@%.12f,%.12f&directionsmode=transit"


@interface WSSearchRoutesInMapViewController ()<MKMapViewDelegate, annotationContentViewDelegate,WCPopListViewDelegate>

@property (nonatomic, strong)WSFuncsBean *currentFuncsBean;
@property (nonatomic, strong)MKMapView *iMapView;
@property (nonatomic, strong)NSMutableArray *basicAnnotations;
@property (nonatomic, strong)WSBasicAnnotation *callOutAnnotation;
@property (nonatomic, strong)WSBasicAnnotation *startAnnotation;
@property (nonatomic, strong)WSBasicAnnotation *endAnnotation;
@property (nonatomic, strong)NSMutableArray *searchTypes;
@property (nonatomic, assign)NSInteger selectMapType;
@property (nonatomic, strong)WSLocationDescribe *currentLocationDescribe;
@property (nonatomic, assign)BOOL hasUpdateUserLocation;

- (void)loadStoresInfo;
- (void)addAnnotationsToMapView;
- (void)showPromptView:(NSString *)aPrompt;

@end

@implementation WSSearchRoutesInMapViewController
@synthesize currentFuncsBean = _currentFuncsBean;
@synthesize iMapView = _iMapView;
@synthesize basicAnnotations = _basicAnnotations;
@synthesize callOutAnnotation = _callOutAnnotation;
@synthesize startAnnotation = _startAnnotation;
@synthesize endAnnotation = _endAnnotation;
@synthesize searchTypes = _searchTypes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean
{
    self = [super init];
    if (self) {
        self.currentFuncsBean = aFuncsBean;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    CGRect mapRect = [[UIScreen mainScreen] applicationFrame];
    self.iMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, mapRect.size.width, mapRect.size.height)];
    self.iMapView.delegate = self;
    self.iMapView.showsUserLocation = YES;
    self.iMapView.zoomEnabled = YES;
    self.iMapView.scrollEnabled = YES;
    [self.view addSubview:self.iMapView];
    
    [[WSLocationManager getInstance] startUpdatesCityInfoWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        BOOL isNeedGetData = NO;
        if (self.currentLocationDescribe) {
            if (fabs(self.currentLocationDescribe.location.coordinate.latitude - aLocationDescribe.location.coordinate.latitude) > kLocationThreshold ||
                fabs(self.currentLocationDescribe.location.coordinate.longitude - aLocationDescribe.location.coordinate.longitude) > kLocationThreshold ||
                ![self.currentLocationDescribe.cityName isEqualToString:aLocationDescribe.cityName]) {
                isNeedGetData = YES;
            }
        }
        else
        {
            isNeedGetData = YES;
        }
        
        self.currentLocationDescribe = aLocationDescribe;
        
        if (isNeedGetData) {
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNearByStoreFinished:) name:kFetchNearByStoreNotifyName object:nil];
            
            NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] init];
            NSString *latitude = [NSString stringWithFormat:@"%f",aLocationDescribe.location.coordinate.latitude];
            NSString *longitude = [NSString stringWithFormat:@"%f",aLocationDescribe.location.coordinate.latitude];
            if (latitude != nil && [latitude length] > 0 && longitude != nil && [longitude length] > 0) {
                if (latitude) {
                    [paramsDic setObject:latitude forKey:GPS_LAT];
                }
                
                if (longitude) {
                    [paramsDic setObject:longitude forKey:GPS_LON];
                }
            }
            if (aLocationDescribe.cityName) {
                [paramsDic setObject:aLocationDescribe.cityName forKey:@"cityName"];
            }
            [paramsDic setObject:@"storelineinfo" forKey:@"objId"];
            if ([WSAppData getObjectbyKey:APPDATA_EMPID]) {
                [paramsDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
            }
            
            
            WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
            [uploadMgr postRequestData:paramsDic notifyName:kFetchNearByStoreNotifyName];
            
        };
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithTitle:@"地图类型" style:UIBarButtonItemStylePlain target:self action:@selector(selectMapType:)];
    self.navigationItem.rightBarButtonItem = selectItem;
    selectItem = nil;
    
//    self.iSearchTypes = [NSArray arrayWithObjects:@"百度地图App", @"百度地图Web",@"GoogleMap App", nil];
    self.searchTypes = [NSMutableArray arrayWithObjects:@"百度地图App", @"GoogleMap App", nil];
    
    //Add inplane and outplane store
    //[self loadStoresInfo];
    
    // Add annotations to map view
    //[self addAnnotationsToMapView];
}

- (void)loadStoresInfo
{
    self.basicAnnotations = [[NSMutableArray alloc] initWithCapacity:8];
    
    WSInPlanStoreBean* inPlanStoreArray = [WSAppData getObjectbyKey:INPLANSTORE];
    for (WSStoreBean *instore in inPlanStoreArray.storesArray) {
//        instore.latitude = 39.9652516549;
//        instore.longitude = 116.3389165548;
        NSLog(@"lat = %@ long = %@", [NSNumber numberWithDouble:instore.latitude], [NSNumber numberWithDouble:instore.longitude]);
        if (instore.latitude && instore.longitude) //?
        {
            WSBasicAnnotation *annotation = [[WSBasicAnnotation alloc] init];
            [annotation setTitle:instore.name]; // Stroe Name
            [annotation setSubtitle:instore.addr]; // Store address
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(instore.latitude, instore.longitude);
            [annotation setCoordinate:location];
            annotation.pinAnnotationColor = MKPinAnnotationColorGreen;
            annotation.annotationType = WCMKAnnotationPinType;
            [self.basicAnnotations addObject:annotation];
            annotation = nil;
        }
//        break; // for temp
    }
    
    WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
    for (WSStoreBean *outStore in outPlanStoreArray.storesArray) {
//        outStore.latitude = 39.90960456049752;
//        outStore.longitude = 116.3972282409668;
        if (outStore.latitude && outStore.longitude) { // ?
            WSBasicAnnotation *annotation = [[WSBasicAnnotation alloc] init];
            [annotation setTitle:outStore.name]; // Stroe Name
            [annotation setSubtitle:outStore.addr]; // Store address
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(outStore.latitude, outStore.longitude);
            [annotation setCoordinate:location];
            annotation.pinAnnotationColor = MKPinAnnotationColorRed;
            annotation.annotationType = WCMKAnnotationPinType;
            [self.basicAnnotations addObject:annotation];
            annotation = nil;
        }
    }
}

- (void)addAnnotationsToMapView
{
    [self.basicAnnotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        WSBasicAnnotation *annotation = (WSBasicAnnotation *)obj;
        
        // Set region
//        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, kMapSpan, kMapSpan);
//        MKCoordinateRegion adjustedRegion = [self.iMapView regionThatFits:region];
//        [self.iMapView setRegion:adjustedRegion animated:YES];
        
        // Add annotation
        [self.iMapView addAnnotation:annotation];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.iMapView.showsUserLocation = YES;
    
    [self showPromptView:@"请点击图钉或当前位置,选择起点和终点"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.iMapView.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (![self isViewLoaded]) {
        self.iMapView = nil;
        self.basicAnnotations = nil;
        self.callOutAnnotation = nil;
        self.startAnnotation = nil;
        self.endAnnotation = nil;
        self.searchTypes = nil;
    }
}


#pragma mark - private function
- (void)showPromptView:(NSString *)aPrompt
{
    WSPromptView *view = [[WSPromptView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, 33)];
    [view setPrompt:aPrompt];
    [self.view addSubview:view];
    [view show];
}

#pragma mark - MKMapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *pinIndentify = @"net.winchannel.sfa.map.pin";
    static NSString *calloutIndentify = @"net.winchannel.sfa.map.callout";
    // User location
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }

    if ([annotation isKindOfClass:[WSBasicAnnotation class]]) {
        WSBasicAnnotation *basic = (WSBasicAnnotation *)annotation;
        if (basic.annotationType == WCMKAnnotationPinType) {
            MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIndentify];
            if (!pin) {
                pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIndentify];
            }
            pin.canShowCallout = NO;
            pin.pinColor = basic.pinAnnotationColor;
            pin.annotation = basic;
            return pin;
        }else if (basic.annotationType == WCMKAnnotationCallOutType || basic.annotationType == WCMKUserLocationType){
            WSMKCallOutAnnotationView *callout = (WSMKCallOutAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:calloutIndentify];
            if (!callout) {
                callout = [[WSMKCallOutAnnotationView alloc] initWithAnnotation:basic reuseIdentifier:calloutIndentify];
            }
            if (basic.annotationType == WCMKUserLocationType ) {
                callout.centerOffset = CGPointMake(0, -65);
            }else{
                callout.centerOffset = CGPointMake(0, -90);
            }
            callout.canShowCallout = NO;
            callout.annotation = basic;
             WSAnnotationContentView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"WSAnnotationContentView" owner:self options:nil] objectAtIndex:0];
            [contentView.iClearBtn setTitle:NSLocalizedString(@"clear_label", nil) forState:UIControlStateNormal];
//            contentView.iClearBtn.titleLabel.backgroundColor = [UIColor grayColor];
            [contentView.iSearchBtn setTitle:NSLocalizedString(@"query_label", nil) forState:UIControlStateNormal];
            contentView.iSearchBtn.backgroundColor = [UIColor clearColor];
//            contentView.iSearchBtn.tintColor = [UIColor redColor];
            contentView.iTitle.text = basic.title;
            contentView.iSubTitle.text = ( basic.subtitle != nil) ? [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"address", nil),basic.subtitle] : [NSString stringWithFormat:@"%@:",NSLocalizedString(@"address", nil)];
            contentView.iStartPosition.text = (self.startAnnotation != nil) ? ([NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"start_point", nil),self.startAnnotation.title]) : [NSString stringWithFormat:@"%@:",NSLocalizedString(@"start_point", nil)];
            contentView.iEndPosition.text = (self.endAnnotation != nil) ? [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"end_point", nil),self.endAnnotation.title ] :[NSString stringWithFormat:@"%@:",NSLocalizedString(@"end_point", nil)];
            contentView.iActionDelegate = self;
            [callout.iContentView addSubview:contentView];
            return callout;
        }
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[WSBasicAnnotation class]]) {
        WSBasicAnnotation *annotation = (WSBasicAnnotation *)view.annotation;
        if (annotation.annotationType == WCMKAnnotationPinType) {
            if (self.callOutAnnotation != nil) {
                if (self.callOutAnnotation.coordinate.latitude == annotation.coordinate.latitude &&
                    self.callOutAnnotation.coordinate.longitude == annotation.coordinate.longitude) {
                    return;
                }
            }
            
            if (self.callOutAnnotation != nil ) {
                [self.iMapView removeAnnotation:self.callOutAnnotation];
                self.callOutAnnotation = nil;
            }
            
            self.callOutAnnotation = [[WSBasicAnnotation alloc] init];
            [self.callOutAnnotation setTitle:annotation.title];
            [self.callOutAnnotation setSubtitle:annotation.subtitle];
            self.callOutAnnotation.annotationType = WCMKAnnotationCallOutType;
            [self.callOutAnnotation setCoordinate:annotation.coordinate];
            
            if (self.startAnnotation == nil) {
                self.startAnnotation = self.callOutAnnotation;
                [self showPromptView:@"请选择终点"];
            }else{
                self.endAnnotation = self.callOutAnnotation;
                if ([self.startAnnotation.title isEqualToString:self.endAnnotation.title]) {
                    [self showPromptView:@"起点和终点好象一样吧!"];
                }else{
                    [self showPromptView:@"终点已经选择，请搜索公交"];
                }
            }
            
            [self.iMapView addAnnotation:self.callOutAnnotation];
            
            //Ceter CallOut Annotation
            [self.iMapView setCenterCoordinate:self.callOutAnnotation.coordinate animated:YES];
        }else if(annotation.annotationType == WCMKAnnotationCallOutType){
            // Do nothing or remove self.iCallOutAnnotation
        }
    }else if ([view.annotation isKindOfClass:[MKUserLocation class]]){
        MKUserLocation *userLocation = view.annotation;
        if (self.callOutAnnotation != nil) {
            if (self.callOutAnnotation.coordinate.latitude == userLocation.coordinate.latitude &&
                self.callOutAnnotation.coordinate.longitude == userLocation.coordinate.longitude) {
                return;
            }
        }
        
        if (self.callOutAnnotation != nil ) {
            [self.iMapView removeAnnotation:self.callOutAnnotation];
            self.callOutAnnotation = nil;
        }
            
        self.callOutAnnotation = [[WSBasicAnnotation alloc] init];
        [self.callOutAnnotation setTitle:userLocation.title];
        [self.callOutAnnotation setSubtitle:userLocation.subtitle];
        self.callOutAnnotation.annotationType = WCMKUserLocationType;
        [self.callOutAnnotation setCoordinate:userLocation.coordinate];
        
        if (self.startAnnotation == nil) {
            self.startAnnotation = self.callOutAnnotation;
            [self showPromptView:@"请选择终点"];
        }else{
            self.endAnnotation = self.callOutAnnotation;
            if ([self.startAnnotation.title isEqualToString:self.endAnnotation.title]) {
                [self showPromptView:@"起点和终点好象一样吧!"];
            }else{
                [self showPromptView:@"终点已经选择，请搜索公交"];
            }
        }
        
        [self.iMapView addAnnotation:self.callOutAnnotation];
        //Ceter CallOut Annotation
        [self.iMapView setCenterCoordinate:self.callOutAnnotation.coordinate animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (self.callOutAnnotation != nil && ![view isKindOfClass:[WSMKCallOutAnnotationView class]]) {
        [mapView removeAnnotation:self.callOutAnnotation];
        self.callOutAnnotation = nil;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    for (MKAnnotationView *annotationView in views) {
        if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
            annotationView.canShowCallout = NO;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.hasUpdateUserLocation) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, kMapSpan, kMapSpan);
        MKCoordinateRegion adjustedRegion = [self.iMapView regionThatFits:region];
        [self.iMapView setRegion:adjustedRegion animated:YES];
        self.hasUpdateUserLocation = YES;
    }
}


#pragma mark - annotation view delegate

- (void)clearStartAndEndPositionAction
{
    NSLog(@"%s\n", __FUNCTION__);
    
    [self showPromptView:@"起点和终点已经清除，请重新选择吧!"];
    
    self.startAnnotation = nil;
    self.endAnnotation = nil;
    if (self.callOutAnnotation != nil) {
        [self.iMapView removeAnnotation:self.callOutAnnotation];
        self.callOutAnnotation = nil;
    }
}

- (void)searchRoutesAction
{
    NSLog(@"%s\n", __FUNCTION__);
    
    if (self.startAnnotation == nil || self.endAnnotation == nil) {
        NSMutableString *tip = [NSMutableString string];
        if (self.startAnnotation == nil) {
            [tip appendFormat:@"请选择 起点"];
        }
        
        if (self.endAnnotation == nil) {
            if (self.startAnnotation == nil) {
                [tip appendString:@"end_point"];
            }else{
                [tip appendString:@"请您选择 终点"];
            }
        }
        
//        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:tip message:nil delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil,nil] autorelease];
//        [alert show];
        [self showPromptView:tip];
        return;
    }
        
    NSString *startPositionName = nil;
    NSString *endPositionName = nil;
    NSString *formatString = nil;
    //Search type
    NSInteger type = self.selectMapType;
    if (type == WCSearchRouteTypeBaiduMapApp) {
        formatString = WC_BAIDUMAPAPP_SEARCHROUTE;
    }else if (type == WCSearchRouteTypeBaiduMapWeb){
        formatString = WC_BAIDUMAPWEB_SEARCHROUTE;
    }else{
        formatString = WC_GOOGLEMAPAPP_SEARCHROUTE;
    }
        
    startPositionName = self.startAnnotation.title;
    endPositionName = self.endAnnotation.title;
    
    // Open URL
    NSString *source = nil;
    if (type != WCSearchRouteTypeGoogleMapApp) {
        source = [NSString stringWithFormat:formatString, self.startAnnotation.coordinate.latitude, self.startAnnotation.coordinate.longitude,startPositionName,self.endAnnotation.coordinate.latitude,self.endAnnotation.coordinate.longitude,endPositionName];
    }else{
        source = [NSString stringWithFormat:formatString, startPositionName,self.startAnnotation.coordinate.latitude, self.startAnnotation.coordinate.longitude,endPositionName,self.endAnnotation.coordinate.latitude,self.endAnnotation.coordinate.longitude];
    }
    
    NSString *dealwithSource = [source stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *rul = [NSURL URLWithString:dealwithSource];
    BOOL bOpen = [[UIApplication sharedApplication] canOpenURL:rul];
    if (!bOpen) {
        NSString *searchType = [self.searchTypes objectAtIndex:type];
        NSString *alertStr = [NSString stringWithFormat:@"查看是否安装 %@", searchType];
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alertStr tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    BOOL bflag = [[UIApplication sharedApplication] openURL:rul];
    if (!bflag) {
        NSString *title = NSLocalizedString(@"search_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}

- (void)fetchNearByStoreFinished:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFetchNearByStoreNotifyName object:nil];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error && error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        
        if (self.basicAnnotations == nil) {
            self.basicAnnotations = [[NSMutableArray alloc] init];
        }
        else
        {
            [self.basicAnnotations removeAllObjects];
        }
        NSString *info = [[sender userInfo] objectForKey:DATAS];
        NSDictionary *dic = [info objectFromJSONString];
        
        NSArray *storeInfoArray = [dic objectForKey:@"storelineinfo"];
        for (NSDictionary *storeInfo in storeInfoArray) {
            WSBasicAnnotation *annotation = [[WSBasicAnnotation alloc] init];
            
            annotation.pinAnnotationColor = MKPinAnnotationColorGreen;
            annotation.annotationType = WCMKAnnotationPinType;
            
            [annotation setTitle:[storeInfo objectForKey:@"name"]]; // Stroe Name
            [annotation setSubtitle:[storeInfo objectForKey:@"addr"]]; // Store address
            NSString *latitudeString = [storeInfo objectForKey:@"LAST_LAT"];
            NSString *longitudeString = [storeInfo objectForKey:@"LAST_LON"];
            NSScanner *scanner1 = [NSScanner scannerWithString:latitudeString];
            NSScanner *scanner2 = [NSScanner scannerWithString:longitudeString];
            double latitude,longitude;
            if ([scanner1 scanDouble:&latitude] && [scanner2 scanDouble:&longitude]) {
                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
                [annotation setCoordinate:location];
                [self.basicAnnotations addObject:annotation];
                
            }
        }

        if ([self.basicAnnotations count] > 0) {
            [self addAnnotationsToMapView];
        }
    }
}

#pragma mark - select map type

- (void)selectMapType:(id)sender
{
    NSArray *subViews = [self.view subviews];
    for (UIView *item in subViews) {
        if ([item isKindOfClass:[WCPopListView class]]) {
            return;
        }
    }
    
    NSArray *selectedItems = [NSArray arrayWithObject:[self.searchTypes objectAtIndex:self.selectMapType]];
    WCPopListView *view = [[WCPopListView alloc] initWithTotalArry:self.searchTypes selectedArray:selectedItems withSelectedMode:WCPopListSigleSelected];
    [view setPopListViewColor:[UIColor whiteColor]];
    view.iDelegate = self;
    [view showSpecialInView:self.view animated:YES];
}

#pragma mark - WCPopListView delegate
- (void)popListViewDidSelectedEnd:(WCPopListView *)popListView
{    
    NSArray *selectedArray = [popListView getSelectedArray];
    NSString *selectedType = [selectedArray objectAtIndex:0];
    for (int i = 0; i < [self.searchTypes count]; i++) {
        NSString *typeName = [self.searchTypes objectAtIndex:i];
        if ([typeName isEqualToString:selectedType]) {
            self.selectMapType = i;
            break;
        }
    }
    
}


@end
