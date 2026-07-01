//
//  WSUpdateStoreMapViewController.m
//  WinSFA
//
//  Created by mac on 2019/9/19.
//  Copyright © 2019年 WinChannel. All rights reserved.
//

#import "WSUpdateStoreMapViewController.h"
//#import "WSStoreHttpService.h"
//#import "WSBaseStoreDBService.h"
//#import "WSBaseStoreOtherDataDBService.h"
//#import "WSRequestHelper.h"
//#import "WSStoreDataProcessService.h"
//#import "WSWorkFlowViewController.h"
//#import "WSFuncsBeanFilterLogicService.h"
//#import "WSRPMapViewTablCell.h"



//#define UPDATA_NOTIFY       @"outPlan_notify"
//
//@interface WSUpdateStoreMapViewController ()<UISearchBarDelegate,MKMapViewDelegate>
//@property (nonatomic, strong) NSString *currentCity;
//@property (nonatomic, strong) UIBarButtonItem *locationBarButton;
//@property (nonatomic , strong) WSSearchBar *searchBar ;
//@property (nonatomic ,strong) WSMapView *mapView;
//@property (nonatomic, assign) BOOL isSeLocation;
//@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
//@property (nonatomic , strong) WSStoreHttpService * storeHttpService;
//@property (nonatomic ,strong) NSArray *dataArray;
//@property (nonatomic , copy) NSString *subempStoreId;
//@property (nonatomic , copy) NSString *subMenuFuncsCode;
//@property (nonatomic , copy) NSString *searchObjId;     //MMSH-3235  实时收索时请求的和查询数据的节点 add by zhiqing
//@property (nonatomic, assign) BOOL isFilter; // 是否有筛选条件
//@property (nonatomic, strong) WSFuncsBean *subMenuFuncsBean;
//@property(nonatomic,strong)UITableView * tabView;
//@property (nonatomic , strong) NSMutableArray * storeTableArray;
//@property (nonatomic , strong) NSString * searchText;
//
//
//
//
//@end

@implementation WSUpdateStoreMapViewController
//-(WSStoreHttpService *)storeHttpService{
//    if (!_storeHttpService) {
//        _storeHttpService = [[WSStoreHttpService alloc]init];
//    }
//    return _storeHttpService;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relodData) name:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
//
//    self.subMenuFuncsBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
//
//    self.subMenuFuncsCode = self.subMenuFuncsBean.fc;
//
//    [self addTableView];
//
//    [self locationMe];
//
//    UIBarButtonItem *btn_right = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick:)];
//    self.locationBarButton = btn_right;
//    [self setBarButtonTitle];
//
//    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
//
//    [barButtonItems addObject:btn_right];
//
//    [self getNavigationItem].leftBarButtonItems = barButtonItems;
//
//
//    // Do any additional setup after loading the view.
//}
//-(void)addTableView{
//    _tabView = [[UITableView alloc]init];
//    _tabView.delegate = self;
//    _tabView.dataSource = self;
//    [self.view addSubview:_tabView];
//    CGFloat bottomMargin = 0;
//
//    if (self.storeTableArray.count>0)
//    {
//        bottomMargin = 45;
//    }
//    _tabView.frame = CGRectMake(0, self.view.size.height - 200, self.view.frame.size.width,  200);
//}
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
//
//
//    WSSearchBar *searchBar = [[WSSearchBar alloc]  initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44) isResetTextField:YES isResetBackgroundColor:YES isTop:YES];
//    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    searchBar.searchBar.delegate = self;
//    NSString * placeholder = self.currentFuncs.opt.searchHint;
//    if (placeholder.length == 0) {
//        placeholder = NSLocalizedString(@"query_hint_label", nil);
//    }
//    searchBar.searchBar.placeholder = placeholder;
//    UITextField *searchField = [searchBar.searchBar valueForKey:@"searchField"];
//    if (searchField) {
//        [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    }
//
//    self.searchBar = searchBar;
//
//    [self getNavigationItem].titleView = searchBar;
//
//}
//- (void)locationMe {
//
//    DDLogInfo(@"使用通知方式获取定位回调");
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
//    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
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
//
//            [self requestDataWith:@""];
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
//    self.mapView = [[WSMapView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) funcs:self.currentFuncs stores:nil];
//    self.mapView.isShowStoreDetailMsg = YES;
//    self.mapView.delegate = self;
//    [self.view addSubview:self.mapView];
//}
//
//- (void)viewDidLayoutSubviews {
//    self.mapView.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height) ;
//}
//-(void)initAllStoreData{
//
//    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString *subEmpId = self.subempStoreId;
//    NSString *empId = subEmpId?:currenteEmpId;
//    NSString *funCode = self.currentFuncs.fc;
//
//    if (self.subMenuFuncsCode) {
//        funCode = self.subMenuFuncsCode;
//    }
//    // SFA-18916 节点名称使用当前的节点名称，有可能此处节点数据不是以STORES节点名下发
//    NSString * search_objId = STORES;
//    if (self.searchObjId.length > 0) {
//        search_objId = self.searchObjId;
//    }
//    if ([self.currentFuncs.ds length] > 0) {
//        search_objId = self.currentFuncs.ds;
//    }
//    if ([self.currentFuncs.filter length] > 0) {
//            search_objId = self.currentFuncs.filter;
//    }
//
//    BOOL isSearchable  = [self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
//    NSString *searchStr = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG empId:empId funcode:funCode];
//
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
//-(void)requestDataWith:(NSString *)searchText{
//    self.searchText = searchText;
//    [self querying_messageTips];
//    self.storeHttpService.objID = self.currentFuncs.ds;
//    self.storeHttpService.currentFunc = self.currentFuncs;
//    self.storeHttpService.searchString = searchText;
//    self.storeHttpService.location = self.locationDescribe.location.coordinate;
//    BOOL uploadGeoLocationInfo = YES;
//    self.storeHttpService.isUploadLocationInfo = uploadGeoLocationInfo;
//    self.storeHttpService.cityCode = nil;
//    self.storeHttpService.distance = 0;
//
//    __weak typeof(self)weakSelf = self;
//    [self.storeHttpService getCustomerQueryStoreListDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
//        if (dic && !error) {
//            [weakSelf initAllStoreData];
//            [weakSelf reloadMapViewWith:self.dataArray];
//            [weakSelf.mapView removeStorea];
//            weakSelf.tabView.hidden = NO;
//            [weakSelf.tabView reloadData];
//        }
//        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
//    }];
//}
//- (void)reloadMapViewWith:(NSArray *)stores {
//    if (self.mapView) {
//        [self.mapView loadStoreAnnotationsWith:stores isAddLine:YES];
//    }
//}
//- (void)relodData
//{
//    [self initAllStoreData];
//    [self.mapView removeStorea];
//    [self reloadMapViewWith:self.dataArray];
//}
//#pragma mark - UISearchBarDelegate
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    //  [searchBar setShowsCancelButton:YES animated:YES];
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
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    searchBar.text=@"";
//
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    [self requestDataWith:searchBar.text];
//
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    if (searchText.length == 0) {
//        [self requestDataWith:@""];
//    }
//}
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    [self requestDataWith:searchBar.text];
//}
//
//#pragma mark WSMapViewDelegate Methods
//
////- (void)mapView:(MKMapView *)mapView annotationStore:(WSStoreBean *)store {
////
////    if (store) {
////        [self startUpdata:store storeIds:nil];
////        self.currentStore = store;
////    }
////}
///**
// 百度
// */
//- (void)mapView:(BMKMapView *)mapView annotationStore:(WSStoreBean *)store {
//
//    if (store) {
//        [self startUpdata:store storeIds:nil];
//        self.currentStore = store;
//    }
//}
//- (void)mapViewIsClickLocationButton:(WSStoreBean *)store
//{
//    self.tabView.hidden = YES;
//}
//
//
//- (void)startUpdata:(WSStoreBean*)store storeIds:(NSString *)storeIds
//{
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(finishRequest:)
//                                                 name:UPDATA_NOTIFY
//                                               object:nil];
//    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
//
//
//    [uploadMgr appUpdataManagerInfo:store StoreIds:storeIds subempId:[WSAppData getObjectbyKey:APPDATA_EMPID] withObjId:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME notifyName:UPDATA_NOTIFY styp:nil timeout:0];
//
//    [self querying_messageTips];
//
//}
//-(void)finishRequest:(id)sender
//{
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UPDATA_NOTIFY
//                                                  object:nil];
//
//    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
//
//    NSString *info = [[sender userInfo] objectForKey:DATAS];
//    //NSLog(@"outplan is %@",info);
//    NSError *error = [[sender userInfo] objectForKey:ERROR];
//    if (error.code != 0) {
//        NSString *tmpString = [error ws_localizedDescription];
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//        return;
//    }
//    else
//    {
//        NSDictionary *uploadState = [info objectFromJSONString];
//
//        NSString *objId = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
//
//        NSObject *tmpObject = uploadState[objId];
//        NSDictionary *storeDicInfo = nil;
//        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
//            storeDicInfo = (NSDictionary *)tmpObject;
//        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
//            storeDicInfo = [(NSArray *)tmpObject firstObject];
//            if ([(NSArray *)tmpObject count] > 1 || ([(NSArray *)tmpObject count] == 1 )) {  //YIHAIKERRY-4123  下载1条详细数据的特殊处理 //数据详情下载成功，隐藏进度条，刷新UI
//                [self uploadStoreInfo:(NSArray*)tmpObject];
//                return;
//            }
//        }
////        if(self.currentStore != nil){
////            [self.currentStore reSetStore:uploadState Key:objId];
////
////            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
////
////            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
////            [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id ];
////
////        }
//
//
////            [self goNextWorkView:NO];
//
//    }
//}
//
//
//
//
//- (void)uploadStoreInfo:(NSArray*)storeInfoArr
//{
//    NSArray *storeIdArray = [storeInfoArr valueForKeyPath:@"id"];
//    NSString *empId =  [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSDictionary *storesDicInfo = [WSStoreDataProcessService convertStoresInfoDictionaryFromStores:storeInfoArr];
//    [WSStoreDataProcessService processStoreInfoDataToDbWithStoresInfo:storesDicInfo storeID:nil genId:nil isRemoteSearch:NO];
//    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeIdArray:storeIdArray];
//    [self goNextWorkView:NO];
//
//}
//
//#pragma mark -  old code
//-(void)goNextWorkView:(BOOL)plan;
//{
//    WSWorkFlowViewController* wfvc = nil;
//    wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.subMenuFuncsBean Store:self.currentStore unredo:self.currentFuncs.unredo];
//
//    if (self.subMenuFuncsBean) {
//        wfvc.input_reflect_code = self.subMenuFuncsBean.fc;
//        /*针对即拜访的门店加入今日拜访*/
//        if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
//            wfvc.input_reflect_code = self.currentStore.mappingStoreListFC;
//        }
//    }
//
//    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
//
//        NSString *title = nil;
//        if ([self.currentStore.code isKindOfClass:[NSString class]] && [self.currentStore.code length] > 0) {
//            title = [NSString stringWithFormat:@"%@-%@", self.currentStore.code, self.currentStore.name];
//        } else {
//            title = self.currentStore.name;
//        }
//        wfvc.title = title;
//    }
//    //设置访问节点
//    //    wfvc.currentVisitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:self.currentVisitAction andStoreId:self.currentStore.Id subMenuFuncsCode:subMenuFB.fc];
//    WSVisitStoreActionObject * visitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:self.currentVisitAction andStoreId:self.currentStore.Id subMenuFuncsCode:self.subMenuFuncsBean.fc];
//    // 把当前的visitAction 传下去，下级页面可能会有级联关系（区分主页进入，还是从其他的方式进入（MVList））
//    wfvc.currentVisitAction = self.currentVisitAction ? self.currentVisitAction : visitAction;
//    wfvc.moduleFC = visitAction.func_code;
//    wfvc.realParentFuncsCode = self.currentFuncs.fc;
//    if (self.subMenuFuncsCode != nil && self.subMenuFuncsCode.length > 0) {
//        wfvc.moduleFC = self.subMenuFuncsCode;
//    }
//    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
//        wfvc.moduleFC = self.currentStore.mappingStoreListFC;
//    }
//
////    if (INTERFACE_IS_PHONE && [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] isEqualToString:@"HWDJIOS"]) {
////        WCBaseViewController *subCon = [wfvc getDefaultShowController];
////        if (subCon) {
////            [self gotoWorkFlowController:subCon];
////            return;
////        }
////    }
//
////    [self gotoWorkFlowController:wfvc];
//    [self.mapView removeStorea];
//    wfvc.hidesBottomBarWhenPushed = YES;
//    if (self.ownParentViewController) {
//        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
//    } else {
//        [self.navigationController pushViewController:wfvc animated:YES];
//    }
//}
//
//
//- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
//                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
//                                                   andStoreId:(NSString *)store_id
//                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode
//{
//
//    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
//    action.parent_action_id = currentAction.ID;
//    action.store_id = store_id;
//    action.func_code = funcsBean.fc;
//    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    action.title = funcsBean.name;
//
//    NSString *moduleFC;
//    if ([currentAction.module_fc length] > 0) {
//        moduleFC = currentAction.module_fc;
//    }else if([subMenuFuncsCode length] > 0){
//        moduleFC = subMenuFuncsCode;
//    }else {
//        moduleFC = funcsBean.fc;
//    }
//
//    action.module_fc = moduleFC;
//
//    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
//        action.module_fc = self.currentStore.mappingStoreListFC;
//    }
//
//    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
//
//    return action;
//}
//
//#pragma mark ---  UITableViewDelegate,UITableViewDataSource
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//       return self.dataArray.count;
//}
//
//-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    static NSString * reuserId = @"UITableViewCell";
//    WSRPMapViewTablCell * cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
//    if (!cell) {
//        cell = [[WSRPMapViewTablCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
//    }
//    cell.store = self.dataArray[indexPath.row];
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//      WSStoreBean *storeBean = self.dataArray[indexPath.row];
//    [self.mapView showDetailViewWith:storeBean];
//
//}
//
//// 设置cell的行高
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return [WSRPMapViewTablCell heightForcellStore:self.dataArray[indexPath.row]];
//
//}
//-(void)dealloc{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
@end
