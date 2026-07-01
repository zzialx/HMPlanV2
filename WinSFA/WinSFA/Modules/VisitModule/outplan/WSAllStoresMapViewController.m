//
//  WSMapViewController.m
//  WinSFA
//
//  Created by heju on 14/12/24.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAllStoresMapViewController.h"
//#import "WSBaseAcvtDBService.h"
//#import "WSAcvtSearchStoreView.h"
//#import "WSBaseStoreDBService.h"
//#import "WSVisitStoreStatusTable.h"
//#import "WSStoreHttpService.h"
//#import "WSBaseStoreOtherDataDBService.h"

//@interface WSAllStoresMapViewController()<UISearchBarDelegate,WSAcvtSearchStoreViewDelegate>
//
//@property (nonatomic ,weak) WSFuncsBean *outPlanFuncs;
//@property (nonatomic ,weak) WSFuncsBean *inPlanFucns;
//@property (nonatomic ,copy) NSString *titleString;
//@property (nonatomic ,strong) NSArray *dataArray;
//@property (nonatomic ,strong) WSMapView *mapView;
//@property (nonatomic, strong) NSMutableArray *filterArray;
//@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
//@property (nonatomic, strong) NSString *currentCity;
//@property (nonatomic, strong) UIBarButtonItem *locationBarButton;
//@property (nonatomic , strong) WSStoreBean * selectStore; // 地图选择的门店对象
//@property (nonatomic , strong) WSSearchBar *searchBar ;
//@property (nonatomic , strong) WSStoreHttpService * storeHttpService;
//@property (nonatomic , strong) NSMutableDictionary * searchConditionDic;// 收索条件的
//@property (nonatomic, assign) BOOL isFilter; // 是否有筛选条件
//@property (nonatomic, assign) BOOL isSeLocation;
//
//
//@end

@implementation WSAllStoresMapViewController

//-(NSMutableArray *)filterArray{
//    if (!_filterArray) {
//        _filterArray = [[NSMutableArray alloc]init];
//    }
//    return _filterArray;
//}
//-(WSStoreHttpService *)storeHttpService{
//    if (!_storeHttpService) {
//        _storeHttpService = [[WSStoreHttpService alloc]init];
//    }
//    return _storeHttpService;
//}
//-(instancetype)initWithFuncs:(WSFuncsBean*)funcs inPlanFuncs:(WSFuncsBean *)inPlanfuncs{
//    if (funcs==nil) {
//        return nil;
//    }
//    self = [super init];
//    if(self)
//    {
//        self.outPlanFuncs =  funcs;
//        self.currentFuncs = funcs;
//        self.inPlanFucns = inPlanfuncs;
//        self.titleString = funcs.name;
//        return self;
//    }
//    return nil;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//    [self locationMe];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadVisitStore) name:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
//
//    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick:)];
//    self.locationBarButton = btn_right;
//    [self setBarButtonTitle];
//
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
//
//    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, btn_right, nil];
//
//    WSSearchBar *searchBar = [[WSSearchBar alloc]  initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44) isResetTextField:YES isResetBackgroundColor:YES isTop:YES];
//    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    searchBar.searchBar.delegate = self;
//    NSString * placeholder = self.currentFuncs.opt.searchHint;
//    if (placeholder.length == 0) {
//        placeholder = NSLocalizedString(@"query_hint_label", nil);
//    }
//    [searchBar setSearchBarPlaceholderWithText:placeholder color:[UIColor whiteColor]];
//    //        searchBar.searchBar.placeholder = placeholder;
//    //        UITextField *searchField = [searchBar.searchBar valueForKey:@"searchField"];
//    //        if (searchField) {
//    //            [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    //        }
//
//
//    self.searchBar = searchBar;
//    self.navigationItem.titleView = searchBar;
//
//    UIBarButtonItem *mapButtonItem ;
//    if (self.rightButtonName.length > 0) {
//        mapButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.rightButtonName style:UIBarButtonItemStylePlain target:self action:@selector(mapButtonItemClick:)];
//    } else if (self.currentFuncs.buttonName > 0) {
//        //        SFA-18941
//        //        【ios辉瑞医院】我的报表中地图的返回按钮，改为“返回”
//        mapButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.currentFuncs.buttonName style:UIBarButtonItemStylePlain target:self action:@selector(mapButtonItemClick:)];
//    } else {
//        //    MSTD-6353 xuhan 2017 1024
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
//        UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [mapButton setFrame:CGRectMake(5, 0, 25, 25)];
//        [mapButton addTarget:self action:@selector(mapButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
//        [mapButton setImage:[UIImage imageForName:@"storeListMode.png"] forState:UIControlStateNormal];
//        [view addSubview:mapButton];
//        mapButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
//    }
//    self.navigationItem.rightBarButtonItem = mapButtonItem;
//    [self addFilterStoreBarButtonItem];
//}
//
//- (void)setBarButtonTitle {
//    NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];
//    if (!currentCity) {
//        currentCity = NSLocalizedString(@"beijing", nil);
//    } else {
//        currentCity = NSLocalizedString(currentCity, nil);
//
//        self.currentCity = currentCity;
//    }
//    [self.locationBarButton setTitle:currentCity];
//}
//
//- (void)locationMe {
//
//    DDLogInfo(@"使用通知方式获取定位回调");
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
//}
//
//- (void)secondUpdateLocaiton {
//    [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
//        if (aLocationDescribe.location
//            && (aLocationDescribe.location.coordinate.longitude != 0
//                && aLocationDescribe.location.coordinate.latitude != 0)) {
//                self.locationDescribe = aLocationDescribe;
//            }
//
//        if (!self.currentCity) {
//            [self setBarButtonTitle];
//        }
//    }];
//}
//
//- (void)locationFinished:(NSNotification *)sender
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//
//    NSDictionary *userInfo = [sender userInfo];
//    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
//    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
//
//    if (error&&tmpLocationDescribe.location.coordinate.longitude == 0
//        && tmpLocationDescribe.location.coordinate.latitude == 0) {
//        LogError(@"定位失败");
//        if (!self.isSeLocation) {
//            self.isSeLocation = YES;
//            [self locationMe];
//        }
//    }else{
//        LogInfo(@"定位成功：aLocationDescribe=====%@",tmpLocationDescribe);
//        if (tmpLocationDescribe.location && (tmpLocationDescribe.location.coordinate.longitude != 0 && tmpLocationDescribe.location.coordinate.latitude != 0)) {
//            self.locationDescribe = tmpLocationDescribe;
//        }
//        if (!self.currentCity) {
//            [self setBarButtonTitle];
//        }
//    }
//
//}
//
//- (void)loadView {
//    [super loadView];
//    self.mapView = [[WSMapView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) funcs:self.outPlanFuncs stores:nil];
//    self.mapView.isShowStoreDetailMsg = YES;
//    self.mapView.delegate = self;
//    [self.view addSubview:self.mapView];
//
////    [self reloadMapViewWith:self.dataArray];
//}
//
//- (void)viewDidLayoutSubviews {
//    self.mapView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) ;
//}
//
//- (void)reloadMapViewWith:(NSArray *)stores {
//
//    if (self.routeMapId) {
//        [self.mapView loadStoreAnnotationsWith:stores];
//        return;
//    }
//
//    if (self.mapView) {
//        // SFA-19510 屏蔽之前的判断，已经废弃
//        // 配置hidePlanOrbit 为Y 时隐藏路线
////        if (!self.currentFuncs.opt.hidePlanOrbit) {
//            if (self.currentFuncs.readonly && self.currentFuncs.iParentFuncsBean.funcsArray.count == 1) {
//                [self.mapView loadStoreAnnotationsWith:stores];
//            }else{
//                [self.mapView loadStoresRoutingWith:stores todayVisitArray:nil actualVisitArray:nil];
//            }
//
//
////        }else{
////            [self.mapView loadStoreAnnotationsWith:stores];
////        }
//    }
//}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:YES];
//
//    // MSTD-7055
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self initAllStoreData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.dataArray.count) {
//                [self reloadMapViewWith:self.dataArray];
//            }else if (self.storeMap){
//                [self reloadMapViewWith:@[self.storeMap]];
//            }
//        });
//
//    });
//}
//
//-(void)initAllStoreData{
//
//    if (self.routeMapId) {
//        NSString * search_objId = STORES;
//        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//
//        NSArray * routePlanArray = [[WSBaseStoreDBService  shareInstance] queryRoutePlanStoresByFuncCode:self.currentFuncs.fc SearchObjId:search_objId empId:empId route_id:self.routeMapId];
//        int i = 1;
//        for (WSStoreBean  *store in routePlanArray) {
//            store.row_number = [NSString stringWithFormat:@"%d",i];
//            i++;
//        }
//        self.dataArray = routePlanArray;
//        return;
//    }
//
//    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *subEmpId = self.subempStoreId;
//    NSString *empId = subEmpId?:currenteEmpId;
//    NSString *funCode = self.currentFuncs.fc;
//
//    if (self.subMenuFuncsCode) {
//        funCode = self.subMenuFuncsCode;
//    }
//
//    // SFA-18916 节点名称使用当前的节点名称，有可能此处节点数据不是以STORES节点名下发
//    NSString * search_objId = STORES;
//    if (self.searchObjId.length > 0) {
//        search_objId = self.searchObjId;
//    }
//    if ([self.currentFuncs.fv isEqualToString:@"TAB_V2002"]) {
//        if ([self.currentFuncs.ds length] > 0) {
//            search_objId = self.currentFuncs.ds;
//        }
//    }else{
//        if ([self.currentFuncs.filter length] > 0) {
//             search_objId = self.currentFuncs.filter;
//        }
//    }
//
//    BOOL isSearchable  = [self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
//    NSString *searchStr = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
////    if (self.searchObjId && isSearchable ) {
////        search_objId = self.searchObjId;
////        if (searchStr.length == 0) searchStr = self.searchBar.searchBar.text;
////
////    }else{
////        searchStr = self.searchBar.searchBar.text;
////    }
//
//    //  donghong 与安卓逻辑一致 在离线情况下 显示所有的门店没有 code的限制 YIHAIKERRY-2609
//    if (!self.isFilter) {
//        searchStr = self.searchBar.searchBar.text.length > 0 ? self.searchBar.searchBar.text : nil ;
//        isSearchable = NO;
//    }
//
//    // 查询门店的条数
//    self.dataArray = [[WSBaseStoreDBService shareInstance]queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:searchStr search_objId:search_objId isSearchable:isSearchable storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal acvtId:nil selectedQstValues:nil rangeConditions:nil distance:0 pageNumber:-1 distanceSort:nil otherDataDic:nil parentStoreFc:self.currentFuncs.opt.parentStoreFc];
//
//    self.isFilter = NO;
//
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//// 进离店的时候，刷新地图的显示状态-
//
//-(void)reloadVisitStore{
//    self.selectStore.actionState = [[WSVisitStoreStatusTable shareInstance]queryStatusWithStoreId:self.selectStore.Id];
//    for (WSStoreBean * store in self.dataArray) {
//        if ([store.Id isEqualToString:self.selectStore.Id]) {
//            store.actionState = self.selectStore.actionState;
//            break;
//        }
//    }
//
//    [self reloadMapViewWith:self.dataArray];
//    [self.mapView showDetailViewWith:self.selectStore];
//}
//- (void)addFilterStoreBarButtonItem {
//
//    if ([self.currentFuncs.opt.searchQuestion length] == 0) {
//        LogInfo(@"self.currentFuncs.opt.searchQuestion is nil");
//        return;
//    }
//    //YIHAIKERRY-3427  zhangmin  用searchQuestion 控制  acvtSearch 是本地的 也有可能实时
////    if ([self.currentFuncs.opt.acvtSearch length] == 0) {
////        LogInfo(@"self.currentFuncs.opt.acvtSearch is nil");
////        return;
////    }
//
//    NSMutableArray *barButtonItems = [NSMutableArray array];
//    barButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
//    UIButton *filterStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [filterStoreButton setFrame:CGRectMake(0, 0, 25, 25)];
//    [filterStoreButton addTarget:self action:@selector(filterStoreClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [filterStoreButton setImage:[UIImage imageNamed:@"acvtSearchStore"] forState:UIControlStateNormal];
//
//    UIBarButtonItem *filterStoreItem = [[UIBarButtonItem alloc] initWithCustomView:filterStoreButton];
//    [barButtonItems addObject:filterStoreItem];
//
//    self.navigationItem.rightBarButtonItems = barButtonItems;
//
//}
//
//-(void)leftBarButtonClick:(UIBarButtonItem *)sender{
//    NSLog(@"只显示定位的城市");
//}
//
//-(void)mapButtonItemClick:(UIBarButtonItem *)sender{
//
//    NSLog(@"跳回门店列表");
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)moveAcvtSearchStoreView {
//
//    [self moveView:self.acvtSearchStoreView.rightView offset:-self.acvtSearchStoreView.rightView.width];
//}
//
//-(void)moveView:(UIView *)view offset:(CGFloat)offset {
//    if (offset <= 0) {
//        [self.acvtSearchStoreView setHidden:NO];
//    }
//
//    CGRect frame = view.frame;
//    frame.origin.x += offset;
//    [UIView animateWithDuration:0.3 animations:^{
//        view.frame = frame;
//    } completion:^(BOOL finished) {
//        self.acvtSearchStoreView.blockView.alpha = 0.6;
//        if (offset > 0) {
//            [self.acvtSearchStoreView setHidden:YES];
//        }
//    }];
//
//}
//
//-(void)filterStoreClicked:(UIBarButtonItem *)sender{
//     NSLog(@"弹出leftview");
//    if (_searchBar.isFirstResponder) {
//         [_searchBar resignFirstResponder];
//    }
//    if (_acvtSearchStoreView == nil) {
//        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc]init];
//        WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtCode:self.currentFuncs.opt.searchQuestion];
//        _acvtBeanForSearchStore = acvtBean;
//        CGRect rect = [UIScreen mainScreen].bounds;
//        _acvtSearchStoreView = [[WSAcvtSearchStoreView alloc]initWithFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height) current:self.currentFuncs acvtBean:acvtBean];
//        _acvtSearchStoreView.delegate = self;
//        _acvtSearchStoreView.locationDescribe = self.locationDescribe;
//
//        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
//        UIView *rootView = delegate.window.rootViewController.view;
//        [rootView addSubview:_acvtSearchStoreView];
//        [self performSelector:@selector(moveAcvtSearchStoreView) withObject:nil afterDelay:0.01];
//        [_acvtSearchStoreView requestStoreAcvtdisData];
//
//    }else {
//        [self moveView:_acvtSearchStoreView.rightView offset:-self.acvtSearchStoreView.rightView.width];
//    }
//
//}
//
//#pragma mark WSMapViewDelegate Methods
//
////- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store {
////
////    if (store) {
////        self.selectStore = store;
////        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:store forKey:SELECTED_MAP_STORE];
////        NSString * notificationName = [NSString stringWithFormat:@"%@_%@",SELECT_MAP_STORE_NOTIFICATION,self.currentFuncs.fc];
////        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
////    }
////}
///**
// 百度
// */
//- (void)mapView:(BMKMapView *)mapView annotationStore:(WSStoreBean *)store {
//
//    if (store) {
//        self.selectStore = store;
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:store forKey:SELECTED_MAP_STORE];
//        NSString * notificationName = [NSString stringWithFormat:@"%@_%@",SELECT_MAP_STORE_NOTIFICATION,self.currentFuncs.fc];
//        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
//    }
//}
//#pragma mark - UISearchBarDelegate
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//  //  [searchBar setShowsCancelButton:YES animated:YES];
//
//    for(UIView *cc in [searchBar subviews])
//    {
//        for (UIView *views in [cc subviews]) {
//            if([views isKindOfClass:[UIButton class]])
//            {
//                UIButton *btn = (UIButton *)views;
//                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
//                [btn setTitle:CancelString  forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//                break;
//            }
//        }
//
//    }
//
//}
//
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    searchBar.text=@"";
//
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    [self queryDataAndReloadMapViewWith:searchBar.text];
//
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchText.length == 0) {
//        [self queryDataAndReloadMapViewWith:@""];
//    }
//
//}
//
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    [self queryDataAndReloadMapViewWith:searchBar.text];
//}
//
//-(void)queryDataAndReloadMapViewWith:(NSString *)searchText{
//    // 地图页面可以配置为实时请求门店 MMSH-3235 add by zhiqing
//    if (self.searchObjId && ([self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto] || [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote])) {
//        [self requestDataWith:searchText];
//        return;
//    }
//
//    if (self.routeMapId) {
//        [self searchUnitbyString:searchText];
//        return;
//    }
//    [self initAllStoreData];
//    [self reloadMapViewWith:self.dataArray];
//}
//
//- (void)searchUnitbyString:(NSString *)search{
//    NSArray * storeArray = nil;
//    if (search == nil || [search isEqualToString:@""]) {
//        storeArray = self.dataArray;
//        [self reloadMapViewWith:self.dataArray];
//        return;
//    }
//
//    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (searchArray != nil) {
//        NSMutableString *format = [NSMutableString stringWithCapacity:4];
//        int i = 0;
//        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
//        for (NSString *item in searchArray) {
//            if (![item isEqualToString:@""]) {
//                if (i == 0) {
//                    [format appendString:@"((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
//                    [formatArray addObject:item];
//                    [formatArray addObject:item];
//
//                }else{
//
//                    [format appendString:@" AND ((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
//                    [formatArray addObject:item];
//                    [formatArray addObject:item];
//
//                }
//                i++;
//            }
//
//        }
//        if ([formatArray count] > 0) {
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
//            storeArray = [self.dataArray filteredArrayUsingPredicate:predicate];
//        }
//    }
//    if (storeArray.count > 0) {
//        WSStoreBean * store = [storeArray firstObject];
//        CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(store.latitude, store.longitude);
////        CLLocationCoordinate2D gcj02StoreCoordinate = [CoordinateTransform transCoordinate:coordinate from:@"wgs84" to:@"gcj02"];
//        CLLocationCoordinate2D actualStoreCoordinate = [WSLocationManager getActualCoordinateWithWgs84:coordinate];
//        [self.mapView setRegion:actualStoreCoordinate];
//    }
//}
//
//-(void)requestDataWith:(NSString *)searchText{
//    [self querying_messageTips];
//    self.storeHttpService.objID = self.searchObjId;
//    self.storeHttpService.currentFunc = self.currentFuncs;
//    self.storeHttpService.currentCity = self.currentCity;
//    self.storeHttpService.searchString = searchText;
//    self.storeHttpService.location = self.locationDescribe.location.coordinate;
//    self.storeHttpService.subMenuFuncsCode = self.subMenuFuncsCode;
//    BOOL uploadGeoLocationInfo = YES;
//    if ([@"N" isEqualToString:self.currentFuncs.opt.isOpenGeo]) uploadGeoLocationInfo = NO;
//    self.storeHttpService.isUploadLocationInfo = uploadGeoLocationInfo;
//    self.storeHttpService.searchConditionDic = self.searchConditionDic;
//    self.storeHttpService.cityCode = nil;
//    self.storeHttpService.distance = 0;
//
//    //YIHAIKERRY-2888
//    CLLocationCoordinate2D tempLocation = self.storeHttpService.location;
//    if([self.currentFuncs.opt.downByMap isEqualToString:@"1"] || [self.currentFuncs.opt.downByMap isEqualToString:@"2"])
//    {
//        double distance = [[[NSUserDefaults standardUserDefaults] objectForKey:SEARCH_STORE_RANGE] doubleValue];
//
//        CLLocationCoordinate2D location0 = [WSLocationDescribe getOffLocationWithAngle:0 distance:distance location:tempLocation];
//        CLLocationCoordinate2D location180 = [WSLocationDescribe getOffLocationWithAngle:180 distance:distance location:tempLocation];
//        CLLocationCoordinate2D location90 = [WSLocationDescribe getOffLocationWithAngle:90 distance:distance location:tempLocation];
//        CLLocationCoordinate2D location_90 = [WSLocationDescribe getOffLocationWithAngle:-90 distance:distance location:tempLocation];
//
//        self.storeHttpService.maxLat = location0.latitude;
//        self.storeHttpService.minLat = location180.latitude;
//        self.storeHttpService.maxLon = location90.longitude;
//        self.storeHttpService.minLon = location_90.longitude;
//    }
//
//    __weak typeof(self)weakSelf = self;
//    [self.storeHttpService getCustomerQueryStoreListDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
//        if (dic && !error) {
//            [weakSelf initAllStoreData];
//            [weakSelf reloadMapViewWith:self.dataArray];
//        }
//         [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
//    }];
//}
//
//#pragma mark WSAcvtSearchStoreViewDelegate Method
//
//- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView isShow:(BOOL)isShow {
//    if (!isShow) {
//        [self moveView:self.acvtSearchStoreView.rightView offset:self.acvtSearchStoreView.rightView.width];
//    }
//}
//
//- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView searchStoreWithCondition:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance searchStoreType:(NSString *)storeType {
//
//    WSAcvtBean * acvtBean = storeView.acvtBean;
//    NSArray * acvtQstIdArray = [conditions allKeys];
//    self.searchConditionDic = [[NSMutableDictionary alloc]initWithCapacity:acvtQstIdArray.count];
//    if (acvtQstIdArray.count > 0) {
//        self.isFilter = YES;
//        for (NSString * acvtQstId in acvtQstIdArray) {
//            WSAcvtBean_qst * qst = [acvtBean getQstBeanByAcvtQstID:acvtQstId];
//            [self.searchConditionDic setObject:[conditions objectForKey:acvtQstId] forKey:qst.qstCod];
//        }
//    } else {
//        self.isFilter = NO;
//    }
//
//    if (![self.currentFuncs.opt.downByMap isEqualToString:@"1"]) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self acvtSearchFilterStoreWithCondition:conditions rangeConditions:rangeConditions distance:distance];
//        });
//    } else {
//        [self requestDataWith:nil];
//        self.searchConditionDic = nil;
//    }
//}
//
//- (void)acvtSearchFilterStoreWithCondition:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance {
//    /*filter DB  dataSource*/
//    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//
//    NSString *subEmpId = self.subempStoreId;
//
//    NSString *empId = subEmpId?:currenteEmpId;
//
//    NSString *funCode = self.currentFuncs.fc;
//
//    if (self.subMenuFuncsCode) {
//        funCode = self.subMenuFuncsCode;
//    }
////    NSString * search_objId = STORES;
//    NSString *search_objId = self.searchObjId;
//
//    if ([self.currentFuncs.filter length] > 0) {
//        search_objId = self.currentFuncs.filter;
//    }
//    NSArray *allArray = [[WSBaseStoreDBService shareInstance]queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:self.searchBar.searchBar.text search_objId:search_objId acvtId:self.acvtBeanForSearchStore.acvtId selctedQstValues:conditions rangeConditions:rangeConditions pageNumber:-1 distanceSort:nil distance:distance otherDataDic:nil];
//
//    self.dataArray = [allArray mutableCopy];
//    [self reloadMapViewWith:self.dataArray];
//    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
//}
//
//-(void)dealloc{
//    self.mapView = nil;
//}

@end
