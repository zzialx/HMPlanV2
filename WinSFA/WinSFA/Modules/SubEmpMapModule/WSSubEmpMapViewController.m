//
//  WSSubEmpMapViewController.m
//  WinSFA
//
//  Created by yang on 16/3/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSubEmpMapViewController.h"
//#import "WSMapView.h"
//#import "WSRequestHelper.h"
//#import "WSHttpRequestDefine.h"
//#import "WSSubEmpDetailMapViewController.h"
//#import "WSInoutStoreTable.h"
//#import "WSBaseStoreDBService.h"
//#import "WSSubempstoreBeanArray.h"
//#import "WSSubempstoreBean.h"
//#import "WSBaseStoreTable.h"
//#import "WSBaseStoreDBService.h"
//#import "WSNewStoreListTool.h"
//
//#define kGetSubEmpLocationDataNotifyName    @"kGetSubEmpLocationDataNotifyName"
//#define kQueryStoresObjId                   @"stores:overlay"
//========================================================================================================================

//@interface WSSubEmpMapViewController () <WSMapViewDelegate, UIGestureRecognizerDelegate>
//
//@property (nonatomic, strong) WSMapView *mapView;
//@property (nonatomic, copy) NSString *objID;
//@property (nonatomic, copy) NSString *selectSrid;   //人员选择的人员id
//@property (nonatomic, copy) NSString *roleName;     //选择的角色名称 todo
//@property (nonatomic, copy) NSString *selectDate;   //选择的日期
//@property (nonatomic, strong) NSArray *empArray;
//
//@end
//========================================================================================================================

@implementation WSSubEmpMapViewController

//#pragma mark - 重写viewDidLoad方法
//- (void)viewDidLoad {
//
//    [super viewDidLoad];
//
//    [self addRefreshButton];
//
//    CGRect mapRect = CGRectMake(0, 0, self.view.width, self.view.height);
//    self.mapView = [[WSMapView alloc] initWithFrame:mapRect funcs:self.currentFuncs stores:nil];
//
//    [self loadEmpData];
//    self.mapView.empArray = self.empArray;
//    if (self.empArray.count > 0) {
//        [self.mapView loadSelectEmpButton];
//        [self.mapView loadSelectRoleButton];
//    }
//
//    self.mapView.isShowStoreDetailMsg = YES;
//    self.mapView.delegate = self;
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.view addSubview:self.mapView];
//
//    self.isAutoEnterStorePage = NO;
//}
//
//#pragma mark - 重写viewWillAppear:方法
//- (void)viewWillAppear:(BOOL)animated {
//
//    [super viewWillAppear:animated];
//
//    [self.filterArray removeAllObjects];
//    [self.todayVisitStoreArray removeAllObjects];
//    [self.actualVisitStoreArray removeAllObjects];
//    [self refreshMapViewSubViews];
//}
//
//#pragma mark - 添加刷新按键方法
//- (void)addRefreshButton {
//
//    if (self.currentFuncs.opt.isRefresh) {
//
//        UIButton *refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
//        [refreshButton setImage:[UIImage scaledImageForName:@"refurbish_icon" ofType:@"png"] forState:UIControlStateNormal];
//        [refreshButton addTarget:self action:@selector(refreshMapData) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
//        [self getNavigationItem].rightBarButtonItem = rightBarButtonItem;
//    }
//}
//
//#pragma mark - 加载emp(下属区域)数据方法
//- (void)loadEmpData {
//
//    NSString *objId = SUBEMPSTORES;
//    NSArray *dsArray = [self.currentFuncs.ds componentsSeparatedByString:@","];
//    NSString *empObjString = [dsArray firstObject];
//    if ([empObjString hasPrefix:SUBEMPSTORES] ) {
//        objId = empObjString;
//    }
//
//    WSSubempstoreBeanArray *subempstoreBeabArray = [WSAppData getObjectbyKey:objId];
//    self.empArray = subempstoreBeabArray.subempstoreArray;
//    self.mapView.roleArray = [subempstoreBeabArray.subempstoreArray valueForKeyPath:@"@distinctUnionOfObjects.self.jobTitle"];
//    if ([self.currentFuncs.opt.isShowSubArea isEqualToString:@"1"]) {
//        self.mapView.roleArray = nil;
//    }
//}
//
//#pragma mark - 刷新地图视图子视图方法
//- (void)refreshMapViewSubViews{
//
//    if ([self.currentFuncs.opt.isShowSubArea isEqualToString:@"1"]) {
//
//        [self loadStoreOverlay];
//        [self refreshMapData];
//    } else if (self.currentFuncs.opt.isOpenSubTrackMap || [self.currentFuncs.opt.isSearchable isEqualToString:@"auto"]) {
//
//        [self refreshMapData];
//    } else {
//
//        [self initAllDataFromDb];
//
//        NSMutableArray *planStores = [[NSMutableArray alloc]init];
//        for (WSStoreBean *store in self.filterArray) {
//
//            if ([store.actionState isEqualToString:@"1"]) {
//                store.last_date = [[WSInoutStoreTable sharedTable] getLeaveStoreTime:store andOtherParam:nil
//                                                                       andParamType:EParameterType_NULL];
//            }
//
//            if (![store.seq isEqualToNumber:@999]) {
//                store.row_number = store.seq.stringValue;
//            }
//
//            if (store.plan) {
//                [planStores addObject:store];
//            }
//        }
//
//        [self.mapView loadStoresRoutingWith:self.filterArray todayVisitArray:self.todayVisitStoreArray
//                           actualVisitArray:self.actualVisitStoreArray];
//        [self.mapView locateCurrentLocation];
//    }
//}
//
//#pragma mark - 加载下属片区方法
//-(void)loadStoreOverlay{
//
//    NSMutableArray *empIds = [NSMutableArray arrayWithCapacity:(self.empArray.count + 1)];
//    empIds = [self.empArray valueForKeyPath:@"@distinctUnionOfObjects.self.Id"];
//
//    NSString *currentEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    if (empIds) {
//        [empIds.mutableCopy addObject:currentEmpId];
//    } else {
//        empIds = @[currentEmpId].mutableCopy;
//    }
//
//    NSString *empIdString = [empIds componentsJoinedByString:@","];
//    NSArray *overlayStores = [[WSBaseStoreDBService shareInstance] queryStoreWithSearchObjId:kQueryStoresObjId
//                                                                                        styp:nil empId:empIdString];
//    NSMutableDictionary *overlayDic = [[NSMutableDictionary alloc] init];
//    for (WSStoreBean * store in overlayStores) {
//        NSString *keyString = [NSString stringWithFormat:@"%@%@", store.empId, store.styp];
//        NSMutableArray *array =  [overlayDic objectForKey:keyString];
//        if (!array) {
//            array = [[NSMutableArray alloc] init];
//        }
//        [array addObject:store];
//        [overlayDic setObject:array forKey:keyString];
//    }
//
//    NSArray *allOverlayKeys = [overlayDic allKeys];
//    for (NSString *key in allOverlayKeys) {
//        NSArray *array = [overlayDic objectForKey:key];
//        [self.mapView loadSubEmpResponsibleAreaOverlay:array.copy];
//    }
//}
//
//#pragma mark - 请求地图数据方法
//- (void)refreshMapData {
//
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)
//                             tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    if (self.subempStore.Id.length > 0) {
//        empid = self.subempStore.Id;
//    }
//    [dic setObject:empid forKey:JSON_EMPID];
//    [dic setObject:@"1" forKey:JSON_COMPRESS];
//
//    self.objID = self.currentFuncs.filter;
//    if (!self.objID) {
//        self.objID = @"stores:emploc";
//    }
//    if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
//        [dic setObject:self.selectDate forKey:@"selectDate"];
//        self.objID = self.currentFuncs.ds;
//    }
//    [dic setObject:self.objID forKey:JSON_OBJID];
//
//    if (self.selectSrid.length > 0) {
//        [dic setObject:self.selectSrid forKey:Store_srid];
//    }
//
//    if (self.roleName.length > 0) {
//        [dic setObject:self.roleName forKey:@"roleName"];
//    }
//
//    if (self.queryDate) {
//        [dic setObject:self.queryDate forKey:@"queryDate"];
//    }
//
//    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
//    [uploadMgr postRequestData:dic notifyName:kGetSubEmpLocationDataNotifyName];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishSubEmpRequest:)
//                                                 name:kGetSubEmpLocationDataNotifyName object:nil];
//}
//
//#pragma mark - 请求地图数据通知回调方法
//- (void)finishSubEmpRequest:(NSNotification *)sender {
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetSubEmpLocationDataNotifyName object:nil];
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
//
//    NSError *error = [[sender userInfo] objectForKey:ERROR];
//    if (error) {
//        LogError(@"request error%@",error);
//        return;
//    }
//
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//    NSDictionary *dataDic = [info objectFromJSONString];
//    NSArray *array = [dataDic objectForKey:self.objID];
//
//    [[WSBaseStoreDBService shareInstance]replaceToTableWithDicts:array FromNode:self.objID hasNewData:YES];
//
//    NSString *empid = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    if (self.subempStore.Id.length > 0) {
//        empid = self.subempStore.Id;
//    }
//
//    if ([self.currentFuncs.opt.isShowSubArea isEqualToString:@"1"] || (self.selectSrid && self.selectSrid.length > 0 && [self.currentFuncs.value isEqualToString:@"manualQuery"])) {
//
//        [self loadStoreDateWithEmpId:self.selectSrid];
//    } else {
//
//        WSStoreAccessMode accessMode = [self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal;
//        NSArray *storeArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:self.currentFuncs.fc
//                                                                                        empId:empid
//                                                                                         styp:self.currentFuncs.styp
//                                                                                    searchStr:self.ownSearchBar.searchBar.text
//                                                                                 search_objId:self.objID isSearchable:NO
//                                                                              storeAccessMode:accessMode acvtId:nil
//                                                                            selectedQstValues:nil rangeConditions:nil distance:0
//                                                                                   pageNumber:0
//                                                                                 distanceSort:self.currentFuncs.opt.distancesSort
//                                                                                 otherDataDic:nil
//                                                                                parentStoreFc:self.currentFuncs.opt.parentStoreFc];
//        for (WSStoreBean *storeBean in storeArray) {
//            storeBean.isSubEmpInfo = YES;
//        }
//        [self.mapView loadStoreAnnotationsWith:storeArray];
//    }
//}
//
//#pragma mark - 根据选择的人员加载门店方法
//- (void)loadStoreDateWithEmpId:(NSString *)empId {
//
//    NSString *search_objId = STORES;
//    if ([self.currentFuncs.ds length] > 0) {
//        search_objId = self.currentFuncs.ds;
//    }
//
//    NSArray *stores = [[WSBaseStoreDBService shareInstance] queryStoreWithSearchObjId:search_objId
//                                                                                 styp:self.currentFuncs.styp empId:empId];
//    [self.mapView loadStoresRoutingWith:stores todayVisitArray:nil actualVisitArray:self.actualVisitStoreArray];
//}
//
//#pragma mark - 重写addOptMapView方法
//- (void)addOptMapView {
//
//}
//
//#pragma mark -  重写父类方法，不添加门店数量统计数字
//- (void)resetTitle {
//
//    NSString *title = [NSString stringWithFormat:@"%@", self.currentFuncs.name];
//    [self refreshControllerTitle:title];
//}
//
//#pragma mark - 实现mapView:annotationStore:协议-百度地图底部弹框点击事件
//- (void)mapView:(BMKMapView *)mapView annotationStore:(WSStoreBean *)store {
//
//    BOOL isForceLeaveStore = [[WSInoutStoreTable sharedTable] isForceLeaveStoreWithStore:store];
//    if (isForceLeaveStore) {
//
//        NSString *str = NSLocalizedString(@"forceLeaveStore_tip", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil
//                                 type:MBProgressHUDMessageTypeFailed];
//        return;
//    }
//
//    if (self.currentFuncs.opt.isOpenSubTrackMap) {
//
//        WSSubEmpDetailMapViewController *con = [[WSSubEmpDetailMapViewController alloc] initWithSubEmpID:store.Id
//                                                                                                empArray:self.empArray];
//        WSFuncsBean *funcs = [self.currentFuncs.funcsArray firstObject];
//        con.currentFuncs = funcs ? : self.currentFuncs;
//        con.title = store.name;
//        if (self.currentFuncs.opt.isRefresh) {
//            con.isShowRefreshButton = YES;
//        }
//
//        [self.navigationController pushViewController:con animated:YES];
//        return;
//    }
//
//    self.currentStore = store;
//    [self didSelectStore:store notification:nil];
//}
////原系统地图协议
////- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store
////{
////    if (self.currentFuncs.opt.isOpenSubTrackMap) {
////        WSSubEmpDetailMapViewController *con = [[WSSubEmpDetailMapViewController alloc] initWithSubEmpID:store.Id empArray:self.empArray];
////        WSFuncsBean * funcs = [self.currentFuncs.funcsArray firstObject]; // 如果配置的下级菜单就使用下级菜单，否则使用当前的菜单
////        con.currentFuncs = funcs ?:self.currentFuncs;
////        con.title = store.name;
////        if (self.currentFuncs.opt.isRefresh) {
////            con.isShowRefreshButton = YES;
////        }
////
////        [self.navigationController pushViewController:con animated:YES];
////    }else {
////        self.currentStore = store;
////        [self didSelectStore:store notification:nil];
////    }
////}
//
//#pragma mark - 实现requestSubEmpStoreAndReloadMapviewWith:andEmpId:协议
//- (void)requestSubEmpStoreAndReloadMapviewWith:(NSString *)biz_date andEmpId:(NSString *)empid {
//
//    self.selectSrid = empid;
//    self.selectDate = biz_date;
//    [self refreshMapData];
//}
//
//#pragma mark - 重写checkStateAndGoWorkflow:方法
//- (void)checkStateAndGoWorkflow:(WSStoreBean *)aStore{
//
//    if (![WSNewStoreListTool anyStoreHasNotLeave:aStore andModuleFC:[self getRealModuleFC:aStore]
//                                withCurrentFuncs:self.currentFuncs]) {
//        return;
//    }
//
//    self.currentStore = aStore;
//
//    if (self.currentFuncs.opt.storeListAcvtCode.length > 0) {
//
//        WSBaseAcvtdisDBService *acvtdisDBService = [[WSBaseAcvtdisDBService alloc] init];
//        NSArray *array = [acvtdisDBService queryAcvtDisWithStoreId:aStore.Id acvtCode:self.currentFuncs.opt.storeListAcvtCode];
//        self.currentStore.auxiliaryInfoArray = array;
//    }
//
//    aStore = [WSLocationManager calculateDistanceWith:aStore func:self.currentFuncs locationDescribe:self.locationDescribe
//                                          isStoreList:NO];
//
//    if ([self.currentStore.state isEqualToString:@"0"]) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"此门店为不活跃门店，请修改门店状态", nil)
//                                 tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//        return;
//    }
//
//    if (self.prepareFuncBean && [self.prepareFuncBean.required isEqualToString:@"R"]) {
//
//        WSStorePrepareState prepareState = [self getPrepareStateByStore:aStore];
//        if (prepareState == WSStorePrepareStateNotPrepare) {
//            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"prepare_before_visit", nil) tips:nil
//                                tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            return;
//        }
//    }
//
//    if ([self.currentFuncs.opt.downByMap isEqualToString:@"1"]) {
//
//        [self goNextWorkView:NO];
//        return;
//    }
//
//    [self didSelectStore:aStore notification:nil];
//}
//
//#pragma mark - 获取模块fc方法
//- (NSString *)getRealModuleFC:(WSStoreBean *)store{
//
//    NSString *moduleFC = nil;
//
//    if (self.currentVisitAction && self.currentVisitAction.module_fc && [self.currentVisitAction.module_fc length] > 0) {
//        moduleFC = self.currentVisitAction.module_fc;
//    }
//
//    if (!moduleFC) {
//        if (self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0) {
//            moduleFC = self.subMenuFuncsCode;
//        } else {
//            moduleFC = self.currentFuncs.fc;
//        }
//    }
//
//    if (store.mappingStoreListFV && [store.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
//        moduleFC = store.mappingStoreListFC;
//    }
//
//    return moduleFC;
//}
//
//#pragma mark - 实现acvtSearchStoreView:searchStoreWithCondition:rangeConditions:distance:searchStoreType:协议
//- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView searchStoreWithCondition:(NSMutableDictionary *)conditions
//            rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance searchStoreType:(NSString *)storeType {
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self acvtSearchFilterStoreWithCondition:conditions rangeConditions:rangeConditions distance:distance];
//    });
//}
//
//#pragma mark - 实现acvtSearchFilterStoreWithCondition:rangeConditions:distance:协议
//- (void)acvtSearchFilterStoreWithCondition:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance {
//
//    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *subEmpId = self.subempStore.Id;
//    NSString *empId = subEmpId?:currenteEmpId;
//
//    NSString *funCode = self.currentFuncs.fc;
//    if (self.subMenuFuncsCode) {
//        funCode = self.subMenuFuncsCode;
//    }
//
//    NSString *search_objId = STORES;
//    if ([self.currentFuncs.ds length] > 0) {
//        search_objId = self.currentFuncs.ds;
//    }
//
//    NSArray *allArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId
//                                                                                   styp:self.currentFuncs.styp
//                                                                              searchStr:nil search_objId:search_objId
//                                                                                 acvtId:self.acvtBeanForSearchStore.acvtId
//                                                                       selctedQstValues:conditions
//                                                                        rangeConditions:rangeConditions pageNumber:-1
//                                                                           distanceSort:nil distance:distance
//                                                                           otherDataDic:nil];
//    self.filterArray = [NSMutableArray array];
//    [self.filterArray addObjectsFromArray:allArray];
//    self.storeArray = [self.filterArray mutableCopy];
//
//    [self reloadMapViewWith:self.storeArray];
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
//}
//
//#pragma mark - 重载地图方法
//- (void)reloadMapViewWith:(NSArray *)stores {
//
//    if (self.mapView) {
//        [self.mapView loadStoresRoutingWith:stores todayVisitArray:self.todayVisitStoreArray
//                           actualVisitArray:self.actualVisitStoreArray];
//    }
//}
//
//#pragma mark - 重写searchOperationRefresh方法(搜索操作刷新方法)
//- (void)searchOperationRefresh {
//
//    if (self.mapView) {
//        [self.mapView loadStoresRoutingWith:self.filterArray todayVisitArray:self.todayVisitStoreArray
//                           actualVisitArray:self.actualVisitStoreArray];
//    }
//}

@end
//========================================================================================================================
