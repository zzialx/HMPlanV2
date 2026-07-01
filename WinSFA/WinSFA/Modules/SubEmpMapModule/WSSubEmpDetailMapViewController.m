//
//  WSSubEmpDetailMapViewController.m
//  WinSFA
//
//  Created by yang on 16/3/3.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSubEmpDetailMapViewController.h"
//#import "WSMapView.h"
//#import "WSRequestHelper.h"
//#import "WSHttpRequestDefine.h"
//#import "WSBaseStoreTable.h"
//#import "WSBaseStoreDBService.h"
//#import "WSStoreHttpService.h"
//#import "SuperWorkSpaceViewController.h"
//
//
//#define kIsSearchAbleAuto         @"auto"
//#define kIsSearchAbleRemote         @"remote"
//
//#define kGetSubEmpDetailLocationDataNotifyName @"kGetSubEmpDetailLocationDataNotifyName"

//@interface WSSubEmpDetailMapViewController () <WSMapViewDelegate>
//
//@property (nonatomic, strong) WSMapView *mapView;
//
//@property (nonatomic, copy) NSString *subEmpID;
//
//@property (nonatomic, copy) NSString *objID;
//
//@property (nonatomic, copy) NSString *selected_biz_date;
//
//@property (nonatomic, strong) NSArray *empArray;
//
//@property (nonatomic , strong) NSArray * inplanArray;
//@property (nonatomic, strong) WSStoreHttpService *storeHttpService;
//
//@end

@implementation WSSubEmpDetailMapViewController

//- (instancetype)initWithSubEmpID:(NSString *)subEmpID empArray:(NSArray *)empArray
//{
//    self = [super init];
//
//    if (self) {
//        self.subEmpID = subEmpID;
//        self.empArray = empArray;
//    }
//
//    return self;
//}
//
//-(WSStoreHttpService *)storeHttpService{
//    if (!_storeHttpService) {
//        _storeHttpService = [[WSStoreHttpService alloc]init];
//    }
//    return _storeHttpService;
//}
//-(NSArray *)getInplanArrayWith:(NSString *)bize_date{
//    NSString * empId = self.subEmpID?: [WSAppData getObjectbyKey:APPDATA_EMPID];
//    //SFA-22747
//    //SFA泸州老窖】【iOS】工作轨迹中显示计划内的计划轨迹，当天并没有计划内门店
//    NSString * search_objId = self.currentFuncs.ds;
//    if (search_objId.length <= 0) {
//        search_objId = @"stores";
//    }
//    return [[WSBaseStoreDBService  shareInstance] queryInPlanStoresWithFuncCode:self.currentFuncs.fc empId:empId  search_objId:search_objId  styp:self.currentFuncs.styp biz_date:bize_date storeAccessMode:[self.subEmpID length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal otherDataDic:nil];
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.inplanArray = [self getInplanArrayWith:self.selected_biz_date?:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
//
//    if (self.isShowRefreshButton) {
//        [self addRefreshButton];
//    }
//
//    self.mapView = [[WSMapView alloc] initWithFrame:self.view.bounds funcs:self.currentFuncs stores:nil empArray:self.empArray isSubEmpTrail:YES];
//    self.mapView.isShowStoreDetailMsg = YES;
////    self.mapView.lineColor = [UIColor colorFromHexCode:@"#72d872"];
//    self.mapView.delegate = self;
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.mapView setEmpIdForPid:self.subEmpID];
//    [self.view addSubview:self.mapView];
//
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    //    SFA-23058 donghong
//    [self refreshMapData];
//}
//
//- (void) addRefreshButton{
//
//    UIButton * refreshButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
//    [refreshButton setImage:[UIImage scaledImageForName:@"refurbish_icon" ofType:@"png"] forState:UIControlStateNormal];
//    [refreshButton addTarget:self action:@selector(refreshMapData) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem  *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:refreshButton];
//    [self getNavigationItem].rightBarButtonItem = rightBarButtonItem;
//}
//
//-(void)refreshMapData{
//    // SFA-13151 刷新时只显示当前选择日期的轨迹
//    if (_selected_biz_date && _selected_biz_date.length > 0) {
//        [self refreshMapDataWith:_selected_biz_date andEmpId:self.subEmpID];
//    }else
//        [self refreshMapDataWith:[WSCurrentTime getDateString] andEmpId:self.subEmpID];
//}
//
//-(void)refreshMapDataWith:(NSString *)biz_date andEmpId:(NSString *)empid{
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
//
//    self.objID = @"stores:emptrack";
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    if (empid.length == 0) {
//        empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    }
//    [dic setObject:[NSString stringNotNilWithValue:empid] forKey:JSON_EMPID];
//    [dic setObject:@"1" forKey:JSON_COMPRESS];
//    [dic setObject:self.objID forKey:JSON_OBJID];
//    [dic setObject:[NSString stringNotNilWithValue:self.subEmpID] forKey:@"pid"];
//    [dic setObject:biz_date forKey:@"bizDate"];
//
//
//    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
//    [uploadMgr postRequestData:dic notifyName:kGetSubEmpDetailLocationDataNotifyName];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(finishRequest:)
//                                                 name:kGetSubEmpDetailLocationDataNotifyName
//                                               object:nil];
//
//}
//-(void)finishRequest:(NSNotification *)sender
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetSubEmpDetailLocationDataNotifyName object:nil];
//    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
//
//    NSError *error = [[sender userInfo] objectForKey:ERROR];
//
//    if (error) {
//        LogError(@"request error%@",error);
//        return;
//    }
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//
//    NSDictionary  *dataDic = [info objectFromJSONString];
//
//    NSArray *array = [dataDic objectForKey:self.objID];
//
//    // SFA-15325 对照安卓逻辑，此处将实时取得的数据入库，包含store节点的acvtdis问卷回显数据
//    NSString * search_ObjCode_Code = @"";
//
//    // 如果是 只显示服务器的和自动搜索的，需要加上时间戳作为条件用来保证每次回显的都是回显后台下发的。而不是按节点和搜索条件删除门店
//    if ([self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote] || [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto]) {
//        NSString  *timeString = [WSCurrentTime getTimestampString];
//        search_ObjCode_Code = [search_ObjCode_Code stringByAppendingString:timeString];
//
//    }
//
//    [[WSBaseStoreTable sharedTable] insertAllStoresWith:array searchObjId:self.objID searchObjCode:search_ObjCode_Code isPlan:@"0"];
//
//    NSMutableArray *dataArray = [NSMutableArray array];
//    NSMutableArray * inPlanMutableArray = [self.inplanArray mutableCopy];
//    for (WSStoreBean * inPlanStore in inPlanMutableArray) {
//        inPlanStore.row_number = inPlanStore.seq.stringValue;
//        inPlanStore.isShowMapCallout = YES;
//    }
//    NSArray * inplanStoreIds = [inPlanMutableArray valueForKeyPath:@"Id"];
//    int i = 1;
//    for (NSDictionary *dic in array) {
//        WSStoreBean *storeBean = [[WSStoreBean alloc] init];
//        storeBean.Id = [NSString stringWithValue:[dic objectForKey:@"id"]];
//        storeBean.name = [NSString stringWithValue:[dic objectForKey:@"name"]];
//        storeBean.longitude = [[NSString stringWithValue:[dic objectForKey:@"lon"]] doubleValue];
//        storeBean.latitude = [[NSString stringWithValue:[dic objectForKey:@"lat"]] doubleValue];
//        storeBean.empId = [NSString stringWithValue:[dic objectForKey:@"empId"]];
//        storeBean.code = [NSString stringWithValue:[dic objectForKey:@"cod"]];
//        storeBean.styp = [NSString stringWithValue:[dic objectForKey:@"styp"]];
//        storeBean.canClick = [NSString stringWithValue:[dic objectForKey:@"canClick"]];
//        // 上次拜访时间放在门店编码的位置
//        if ([[dic objectForKey:@"last_date"] length] > 0) {
//            storeBean.code = [NSString stringWithValue:[dic objectForKey:@"last_date"]];
//        }
//
//        storeBean.addr = [NSString stringWithValue:[dic objectForKey:@"addr"]];
//        storeBean.visitcontent = [NSString stringWithValue:[dic objectForKey:@"visitcontent"]];
//        if ([array indexOfObject:dic] == 0) {
//            storeBean.colorStr = @"red";
//        }else {
//            storeBean.colorStr = @"green";
//        }
//        storeBean.row_number = [NSString stringWithFormat:@"%d",i];
//        storeBean.follow = [NSString stringWithValue:[dic objectForKey:@"follow"]];//MN-1415 2018-03-26
//        i++;
//
////        storeBean.isSubEmpInfo = YES;
//        storeBean.isShowMapCallout = YES;
//        if ([inplanStoreIds containsObject:storeBean.Id]) { // 处理是计划内的并且是实际轨迹的
//            storeBean.isAcctuallyAndInPlanStore = YES;
//            for (WSStoreBean * store in inPlanMutableArray) {
//                if ([store.Id isEqualToString:storeBean.Id]) {
//                    [inPlanMutableArray removeObject:store];
//                    break;
//                }
//            }
//        }
//        //新增三个字段  SFA-22086 【泸州老窖】
//        storeBean.inTime = dic[@"INTIME"];
//        storeBean.outTime = dic[@"OUTTIME"];
//        storeBean.instore_time = dic[@"instore_time"];
//
//        storeBean.isAcctuallyRouteStore = YES;
//        [dataArray addObject:storeBean];
//
//    }
//
//
//    [self.mapView removeAllLine];
////    [self.mapView loadStoreAnnotationsWith:dataArray isAddLine:YES];
//    [dataArray addObjectsFromArray:inPlanMutableArray];
//    //今日拜访是否显示
//    [self.mapView loadStoresRoutingWith:dataArray todayVisitArray:nil actualVisitArray:nil];
//
//}
//
//#pragma mark - WSMapViewDelegate
//
////- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store
////{
////    NSLog(@"");
////    //  MN-286 拜访轨迹点击查看 今日表现
////    if (self.currentFuncs.funcsArray.count == 1) {
////        WSSubempstoreBean * subEmpStore ;
////
////        __block WSFuncsBean * func = [self.currentFuncs.funcsArray firstObject];
////        self.storeHttpService.objID = func.filter;
////        if ([func.fv isEqualToString:FV_TAB_V21001]) { // 如果
////            func = [func.funcsArray firstObject];
////
////            for (WSSubempstoreBean * storeBean in self.empArray) {
////                if ([storeBean.Id isEqualToString:self.subEmpID]) {
////                    subEmpStore = storeBean;
////                    break;
////                }
////            }
////        }
////
////        self.storeHttpService.storeBean = store;
////        self.storeHttpService.subEmpStoreBean = subEmpStore;
////        self.storeHttpService.jsEmpID = subEmpStore.Id;
////        //        如果没有选择时间为默认时间 董宏  MN-2659
////        NSString *bizDate = self.selected_biz_date ? self.selected_biz_date : [WSCurrentTime getDateString];
////        self.storeHttpService.bizDate = bizDate;
////        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
////        __weak typeof(self) wself = self;
////        [self.storeHttpService getOutplanStoreDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
////            if (!error) {
////                WCBaseViewController * con = [WCBaseViewController getControllerWithFuncsBean:func realSubFuncsBean:nil];
////                con.currentStore = store;
////                con.bizDate = bizDate;
////                if ([con isKindOfClass:[BaseViewController class]]) {
////                    ((BaseViewController *)con).currentSubEmpStore = subEmpStore;
////                }else if([con isKindOfClass:[SuperWorkSpaceViewController class]]){
////                    ((SuperWorkSpaceViewController *)con).subempStore = subEmpStore;
////                }
////
////                [wself.navigationController pushViewController:con animated:YES];
////            }
////
////            wself.storeHttpService = nil;
////        }];
////    }
////}
///*
// 百度
// */
//- (void)mapView:(BMKMapView *)mapView annotationStore:(WSStoreBean *)store
//{
//    NSLog(@"");
//    //  MN-286 拜访轨迹点击查看 今日表现
//    if (self.currentFuncs.funcsArray.count == 1) {
//        WSSubempstoreBean * subEmpStore ;
//
//        __block WSFuncsBean * func = [self.currentFuncs.funcsArray firstObject];
//        self.storeHttpService.objID = func.filter;
//        if ([func.fv isEqualToString:FV_TAB_V21001]) { // 如果
//            func = [func.funcsArray firstObject];
//
//            for (WSSubempstoreBean * storeBean in self.empArray) {
//                if ([storeBean.Id isEqualToString:self.subEmpID]) {
//                    subEmpStore = storeBean;
//                    break;
//                }
//            }
//        }
//
//        self.storeHttpService.storeBean = store;
//        self.storeHttpService.subEmpStoreBean = subEmpStore;
//        self.storeHttpService.jsEmpID = subEmpStore.Id;
//        //        如果没有选择时间为默认时间 董宏  MN-2659
//        NSString *bizDate = self.selected_biz_date ? self.selected_biz_date : [WSCurrentTime getDateString];
//        self.storeHttpService.bizDate = bizDate;
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
//        __weak typeof(self) wself = self;
//        [self.storeHttpService getOutplanStoreDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
//            if (!error) {
//                WCBaseViewController * con = [WCBaseViewController getControllerWithFuncsBean:func realSubFuncsBean:nil];
//                con.currentStore = store;
//                con.bizDate = bizDate;
//                if ([con isKindOfClass:[BaseViewController class]]) {
//                    ((BaseViewController *)con).currentSubEmpStore = subEmpStore;
//                }else if([con isKindOfClass:[SuperWorkSpaceViewController class]]){
//                    ((SuperWorkSpaceViewController *)con).subempStore = subEmpStore;
//                }
//
//                [wself.navigationController pushViewController:con animated:YES];
//            }
//
//            wself.storeHttpService = nil;
//        }];
//    }
//}
//-(void)requestSubEmpStoreAndReloadMapviewWith:(NSString *)biz_date andEmpId:(NSString *)empid{
//    _selected_biz_date = biz_date;
//    self.subEmpID = empid;
//    self.inplanArray = [self getInplanArrayWith:biz_date];
//    [self refreshMapDataWith:biz_date andEmpId:empid];
//}
//
//-(void)refreshTitle:(NSString * )tittle{
//    if (tittle.length > 0) {
//        self.title = tittle;
//    }
//}
@end
