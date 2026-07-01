//
//  WSAllStoresViewController.m
//  WinSFA
//
//  Created by xiajl on 14-8-18.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAllStoresViewController.h"
#import "WSOutPlanStoreBean.h"
#import "WSWorkFlowViewController.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"
#import "WSStoreInfoViewController.h"
#import "WSRequestHelper.h"
#import "WSStoreAcvtDisBean.h"
#import "WSAddStoreTable.h"
#import "WCOptionalSource.h"
#import "WCOptionalSource.h"
#import "WSAddNewStoreViewController.h"
#import "WSStoreInfoBeanArray.h"
#import "WSVisitStoreActionTable.h"
#import "UIDevice+Addtional.h"
#import "WSAppData.h"
#import "WSSearchBar.h"
#import "WSPlistHelper.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSStoreDataSource.h"
#import "WSTodayVisitViewController.h"
#import "WSCustomerVistViewController.h"
#import "WSStoreManagerViewController.h"
#import "WSStoreBeans.h"
#import "WSFunsShortCutData.h"
#import "WSBaseStoreTable.h"
#import "WSStoreDataProcessService.h"
#import "WSSelectListNewTableviewCell.h"
#import "WSEnvrionment.h"
#import "WSInoutStoreTable.h"
#import "WSManagV_LISTViewController.h"
#import "WSSpecialAcvtListViewController.h"
#import "WSChartConst.h"
#import "WSChartViewController.h"
#import "WSEMSDKManager.h"
#import "WSAcvtSearchStoreView.h"
#import "WSBaseAcvtDBService.h"
#import "WSTestTools.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSActionListView.h"
#import "NSString+Additions.h"
#import "WSBaseDictsDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSStoreFilterView.h"
#import "WSPopMenuView.h"
#import "WSStoreListDataSourceTool.h"
#import "WSBaseAcvtdisDBService.h"
#import "NSArray+SQL.h"
#import "WSRPMapViewController.h"
#import "WSNewStoreListTool.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSRouteStoreTableViewCell.h"
#import "WSAllStoresViewController+Tools.h"

#define INPLAN_UPDATA_NOTIFY    @"INPLAN_UPDATA_NOTIFY"
#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 200 : (210 * UI_XFactor))
//===================================================================================================================================================

@interface WSAllStoresViewController () <WSStoreFilterViewDelegate, WSPopMenuViewDelegate, WSSelectListNewTableviewCellDelegate,
WSAcvtSearchStoreViewDelegate, WSAddNewStoreViewControllerDelegate> {
    
    WSSearchBar *_searchBar;
    WSAcvtBean_qst *currentAcvtBean_qstObj;
    WSStoreFilterView *storeFilterView;
    NSMutableDictionary *lastDic;
    NSMutableDictionary *currentDic;
    NSMutableDictionary *nextDic;
    NSMutableDictionary *allDic;
    NSString *sortStr;
}

@property (nonatomic, strong) WSWorkFlowViewController *currentViewController;
@property (nonatomic, strong) WSActionListView *actionListView;
@property (nonatomic, strong) NSMutableArray *rightButtonInfoArray;
@property (nonatomic, strong) NSMutableArray *leftButtonInfoArray;
@property (nonatomic, strong) NSMutableArray *menuViewDataArray;
@property (nonatomic, strong) NSMutableArray *storeFilterViewDataArray;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, assign) BOOL isRefreshLocation;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) BOOL isRequestingDataForPrepare;
@property (nonatomic, assign) BOOL isShowTips;
@property (nonatomic, assign)WSHelpSalesAlertButtonType selectVisitType;
@end
//===================================================================================================================================================

@implementation WSAllStoresViewController

#pragma mark - 自定义初始化方法initWithFuncs:Stores:
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores {
    
    if (!funcs || !stores) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.title = funcs.name;
        self.currentFuncs = funcs;
        self.allStoreCategory = WSAllStoresCategoryOutPlan;
        self.storeArray = [NSMutableArray arrayWithArray:stores];
        
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:funcs.fv];
    }
    return self;
}

#pragma mark - 自定义初始化方法initWithFuncs:
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs {
    
    if (!funcs) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        self.title = funcs.name;
        self.currentFuncs = funcs;
        self.subMenuFuncsCode = funcs.fc;
        self.storeArray = [[NSMutableArray alloc] init];
        self.filterArray = [[NSMutableArray alloc] init];
        self.todayVisitStoreArray = [[NSMutableArray alloc] init];
        self.actualVisitStoreArray = [[NSMutableArray alloc] init];
        self.allStoreCategory = WSAllStoresCategoryNormal;
        self.shortCutArray = [self filterShortCutFuncsBean:funcs];
        self.subMenuFuncsBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
        
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:funcs.fv];
    }
    return self;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self clearAllNavBBI];
    if (self.subempid == nil && self.subempStore.Id) {
        self.subempid = self.subempStore.Id;
    }
    
    self.isFirstLoad = YES;

    self.rightButtonInfoArray = [NSMutableArray arrayWithCapacity:3];
    self.leftButtonInfoArray = [NSMutableArray arrayWithCapacity:2];
    self.menuViewDataArray = [NSMutableArray array];
    self.storeFilterViewDataArray = [NSMutableArray array];
    lastDic = [NSMutableDictionary dictionary];
    currentDic = [NSMutableDictionary dictionary];
    nextDic = [NSMutableDictionary dictionary];
    allDic = [NSMutableDictionary dictionary];
    
    if ((self.currentFuncs.opt && self.currentFuncs.opt.isMap) || !self.currentFuncs.opt) {

        NSString *notificationName = [NSString stringWithFormat:@"%@_%@", SELECT_MAP_STORE_NOTIFICATION, self.currentFuncs.fc];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapMapViewRightCalloutAccessoryView:) name:notificationName object:nil];
    }
    
    self.isAutoEnterStorePage = YES;
    
    WSAcvtBean *acvtBean = [[[WSBaseAcvtDBService alloc]init] queryAcvtWithAcvtCode:self.currentFuncs.opt.searchQuestion];
    for (WSAcvtBean_qst *obj in acvtBean.qsts) {
        
        if (![obj.qstType isEqualToString:@"DV"] && ![obj.isHidden isEqualToString:@"1"]) {
            [_storeFilterViewDataArray removeAllObjects];
            break;
        }
        
        if ([obj.qstType isEqualToString:@"DV"] && ![obj.isHidden isEqualToString:@"1"]) {
            [_storeFilterViewDataArray addObject:obj];
        }
    }
    _acvtBeanForSearchStore = acvtBean;
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewStoreApplySuccess:) name:kAddNewStoreApply object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRefreshStoreList) name:CustomerQueryRefreshNotification object:nil];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ((!IOS11_OR_LATER && !_isFirstLoad) || IOS11_OR_LATER) {
        [self addToolBar];
    }
    self.isShowTips = YES;
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
   
    if (self.isFirstLoad) {
        [self addAllNavBBI];
    }
    self.isFirstLoad = NO;

    if (self.isLoaded == NO) {
        
        if (self.filterArray && [self.filterArray count] == 1 && self.isAutoEnterStorePage && [self.currentFuncs.opt.autoJumpNext length] > 0 && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"] && !self.isPageSegmentView) {
            
            WSStoreBean *store = [self.filterArray firstObject];
            [self checkStateAndGoWorkflow:store];
        }
    }
    
    if (self.isChooseCityViewDidAppear) {
        
        self.isChooseCityViewDidAppear = NO;
        [self querying_messageTips];
    }
    
    if (_sectionView) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _sectionView.address = [NSString stringWithFormat:@"最新下载地址:%@", [userDefaults objectForKey:LOCATION_ADDRESS]];
        [userDefaults synchronize];
    }
}

#pragma mark - 重写viewWillDisappear:方法
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.isLoaded = YES;
    self.isFirstLoad = YES;

    if (self.ownSearchBar.isFirstResponder) {
        [self.ownSearchBar resignFirstResponder];
    }
}

#pragma mark - 重写viewDidDisappear:协议
- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    self.isShowTips = NO;
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    NSString *notificationName = [NSString stringWithFormat:@"%@_%@", SELECT_MAP_STORE_NOTIFICATION, self.currentFuncs.fc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - 重写reloadStoreList(重载门店列表)方法
-(void)reloadStoreList {
    
    if ((self.conditions.count > 0) || (self.distance > 0) || [self.rangeConditions count] > 0) {
    
        if (self.ownSearchBar.searchBar.isFirstResponder && self.ownSearchBar.searchBar.text.length > 0 &&
            (![self.currentFuncs.opt.filterStyle isEqualToString:@"1"])) {
            
            self.conditions = nil;
            self.rangeConditions = nil;
            self.distance = 0;
            [_acvtSearchStoreView celearData];
        }

        [self.filterArray removeAllObjects];
        [self reloadStoreListBySearchConditon:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:self.distance withSortStr:@""];
        
        return;
    }
    
    self.pageNumer = 0;
    self.filterArray = [NSMutableArray array];
    [self refreshData];
    [self.tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];

    if (self.isShowTips) {
        [self isShowEmptyView];
    }
}

#pragma mark - 重载门店列表(通过额外信息)方法
- (void)reloadStoreListBySearchConditon:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions
                               distance:(CGFloat)distance  withSortStr:(NSString *)sortStr {
    
    NSString *empId = [self getCurrentEmpId];
    NSString *funCode = [self getRealFuncCode];
    NSArray *allArray = [NSArray new];
    NSMutableDictionary *otherDic = [@{kStoreDBOtherData_isFollowStore : [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore],
                                       kStoreDBOtherData_storeClassCondition : [self getStoreClassFilterCondition]} mutableCopy];
    
    if (_storeFilterViewDataArray.count == 3) {
        [otherDic setValue:@"1" forKey:kStoreDBOtherData_isMengNiu];
    }
    else {
        [otherDic setValue:@"0" forKey:kStoreDBOtherData_isMengNiu];
    }
    
    NSString *search_objId = [self getSearchObjectId];
    allArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp
                                                                     searchStr:self.ownSearchBar.searchBar.text search_objId:search_objId
                                                                        acvtId:self.acvtBeanForSearchStore.acvtId selctedQstValues:conditions
                                                               rangeConditions:rangeConditions pageNumber:self.pageNumer
                                                                  distanceSort:sortStr.length ? sortStr:self.currentFuncs.opt.distancesSort
                                                                      distance:distance otherDataDic:otherDic];

    self.titleNumer = [[WSBaseStoreDBService shareInstance] queryAllStoreCountEmpId:empId styp:self.currentFuncs.styp
                                                                          searchStr:self.ownSearchBar.searchBar.text search_objId:search_objId
                                                                       isSearchable:NO acvtId:self.acvtBeanForSearchStore.acvtId
                                                                   selctedQstValues:conditions rangeConditions:rangeConditions distance:distance
                                                                       otherDataDic:otherDic];

    if (allArray.count < kStoreListPageCount) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    else {
        [self.tableView.mj_footer endRefreshing];
    }
    
    [self.filterArray addObjectsFromArray:allArray];
    self.storeArray = [self.filterArray mutableCopy];
    [self resetTitle];
    [self.tableView reloadData];
}

#pragma mark - 刷新数据方法
- (void)refreshData {
    
    [self initAllDataFromDb];
    [self resetTitle];

    for (WSStoreBean *store in self.filterArray) {
        
        if (store.Id) {
            [self.foldStateDic setObject:@"0" forKey:store.Id];
        }
    }
    
    [self.tableView reloadData];
}













- (NSString *)getSearchObjectId{
    NSString * search_objId = STORES;
    // YIHAIKERRY-1970 补充上面安卓筛选条件逻辑
    if ([self.currentFuncs.fv isEqualToString:@"TAB_V2002"]) {
        if ([self.currentFuncs.ds length] > 0){
            search_objId = self.currentFuncs.ds;
        }
    }else if ([self.currentFuncs.fv isEqualToString:@"TAB_V21002"]){
        if ([self.currentFuncs.filter length] > 0)
        {
            search_objId = self.currentFuncs.filter;
        }
    }
    return search_objId;
}

- (NSString *)getRealFuncCode{
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    return funCode;
}

#pragma -mark MN-1651 是否需要实时请求门店信息,根据安卓逻辑修改。
-(BOOL)isNeedRequest{
    BOOL isRemote = [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleAuto] || [self.currentFuncs.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
    //YIHAIKERRY-3339 SFA 益海嘉里-传统渠道【200家门店列表】【IOS】进入门店列表，门店加载完成
    if (isRemote && ![self.currentFuncs.opt.downByMap isEqualToString:@"2"] ) {
        return isRemote;
    }
    BOOL isRequested = [self isRequested];
    if (!isRequested) {
        // YIHAIKERRY-3586 设置 timeout 时间超时也请求
        if (self.currentFuncs.opt.requestTimeout > 0) {
            return YES;
        }
    }
    
    return isRequested;
}

- (BOOL)isRequested {
    WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
    BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
    if (!isRequested) {
        isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
    }
    return !isRequested;
}


//申请门店成功的通知  SFA-23646 IOS：SFA立白【经销商】手机端闭店重开有效需求——点击开店申请弹出提示
- (void)addNewStoreApplySuccess:(NSNotification *)sender {
    
    NSDictionary *dic = sender.userInfo;
    
    if([dic[@"autoFc"] isEqualToString:self.currentFuncs.fc]) {
        
        [dic setValue:[NSString stringNotNilWithValue:dic[@"store_id"]] forKey:@"store_id" ]; //id是long 转为string
        
        NSDictionary *storeDic = @{@"storeId":dic[@"store_id"],@"name":dic[@"store_name"],@"code":dic[@"store_code"]};
        WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
        [service insertOrUpdateStoreWithDataDic:storeDic acvtGenId:@""];
        
        [self refreshData ];
        
        WSStoreBean *store = [[WSStoreBean alloc]initNeighborStoreWithDic:dic];
        //判断是否有正在拜访中没离店的
        if (![WSNewStoreListTool anyStoreHasNotLeave:store andModuleFC:[self getRealModuleFC:store] withCurrentFuncs:self.currentFuncs]) {
            return;
        }
        self.currentStore = store;
        [self startUpdata:store];
        
    }
}

- (BOOL)isUseFilterArray
{
    return YES;
}

- (void)resortStoreAndReloadData {
    
    if (self.locationDescribe) {
        if ([self.currentFuncs.opt.distancesSort isEqualToString:@"1"]) {
            [self resortStoreWithDistance];
        }
    }
//    [self resetTitle];
    [self.tableView reloadData];
}

-(WSStoreHttpService *)storeHttpService{
    if (!_storeHttpService) {
        _storeHttpService = [[WSStoreHttpService alloc]init];
    }
    return _storeHttpService;
}

- (void)addNewActBarButtonItem
{
    //新增门店按钮
    NSString *isAdd = self.currentFuncs.opt.isAdd;

    if ([isAdd length] > 0) {
        
        NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].rightBarButtonItems] ;

        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(0, 0, 25, 25)];
        [rightButton addTarget:self action:@selector(addNewStoreAction) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:[UIImage scaledImageForName:@"icon_addstore" ofType:@"png"] forState:UIControlStateNormal];
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [barButtonItems addObject:rightItem];

        [self getNavigationItem].rightBarButtonItems = barButtonItems;
        
        NSDictionary *dic = @{kActionInfoDicTitleKey:@"新增门店", kActionInfoDicImageKey:@"icon_addstore", kActionInfoDicSelectorKey:@"addNewStoreAction"};
        [self.rightButtonInfoArray addObject:dic];
        
    }
    
}

- (void)addNewStoreAction
{
    NSString *fc = self.currentFuncs.opt.isAdd;
    WSFuncsBeanArray *funcBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *funcBean = [funcBeanArray getHideFuncsBeanWithFC:fc];
    if (funcBean) {
        
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        WSAcvtBean *acvtBean = [service queryAcvtByFilter:funcBean.filter acvtCode:funcBean.opt.isAdd];
        
        if (acvtBean) {
            WSAddNewStoreViewController *controller = [[WSAddNewStoreViewController alloc] initWithFuncs:funcBean acvtBean:acvtBean storeBean:nil];
            controller.delegate = self;
            controller.hidesBottomBarWhenPushed = YES;
            [[self getNavigationController] pushViewController:controller animated:YES];
        }
        
    }
}

- (void)refreshRightButtonsByCount
{
    if ([[self getNavigationItem].rightBarButtonItems count] > 2) {
        [self getNavigationItem].rightBarButtonItems = nil;
        [self getNavigationItem].rightBarButtonItem = [self barButtonItemImage:@"icon_more" target:self action:@selector(moreButtonAction)];
    }
}



- (void)moreButtonAction
{
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    [self.actionListView showOnView:rootView fromPoint:CGPointMake(rootView.width - 20, 60)];
}

- (void)addSearchBarToNavigationTitleView {
    
    if (!_searchBar) {
        
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        _searchBar = [[WSSearchBar alloc]  initWithFrame:rect isResetTextField:YES isResetBackgroundColor:NO isTop:YES];
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        _searchBar.searchBar.delegate = self;
        
        NSString *placeholder = self.currentFuncs.opt.searchHint;
        if (placeholder.length == 0) {
            placeholder = NSLocalizedString(@"query_hint_label", nil);
        }
        [_searchBar setSearchBarPlaceholderWithText:placeholder color:[UIColor blackColor]];
        //        _searchBar.searchBar.placeholder = placeholder;
        //        UITextField *searchField = [_searchBar.searchBar valueForKey:@"searchField"];
        //        if (searchField) {
        //            [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        //        }
        self.ownSearchBar = _searchBar;
    }
    
    [self getNavigationItem].titleView = _searchBar;
    _searchBar.alpha = 0;
}


//必须放在 leftBarButtonItem和rightBarButtonItem初始化之后调用

//- (void)setDisplayCustomTitleText:(NSString*)text
//
//{
//
//    // Init views with rects with height and y pos
//
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//
//    // Use autoresizing to restrict the bounds to the area that the titleview allows
//
//    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//
//    titleView.autoresizesSubviews = YES;
//
//    titleView.backgroundColor = [UIColorclearColor];
//
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//
//    titleLabel.tag = kUIVIEWCONTROLLER_LABEL_TAG;
//
//    titleLabel.backgroundColor = [UIColor clearColor];
//
//    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
//
//    titleLabel.textAlignment = UITextAlignmentCenter;
//
//    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//    titleLabel.textColor = TC_CNavigationTitleColor;
//
//    titleLabel.lineBreakMode = UILineBreakModeClip;
//
//    titleLabel.textAlignment = UITextAlignmentCenter;
//
//    titleLabel.autoresizingMask = titleView.autoresizingMask;
//
//
//
//    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
//
//    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
//
//
//
//    CGRect frame;
//
//    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
//
//    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
//
//
//
//    frame = titleLabel.frame;
//
//    frame.size.width = 320 - maxWidth * 2;
//
//    titleLabel.frame = frame;
//
//
//
//    frame = titleView.frame;
//
//    frame.size.width = 320 - maxWidth * 2;
//
//    titleView.frame = frame;
//
//    // Set the text
//
//    titleLabel.text = text;
//
//    // Add as the nav bar's titleview
//
//    [titleView addSubview:titleLabel];
//
//    self.navigationItem.titleView = titleView;
//
//
//
//}


- (void)removeSearchBarFromNavigationTitleView
{
    [self getNavigationItem].titleView = nil;
}

/**初始化全部门店*/
- (void)initAllDataFromDb {
    [self initOtherFuncsBean];
    NSString *empId = [self getCurrentEmpId];
    NSString *funCode = [self getRealFuncCode];
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    if(self.currentFuncs.opt.parentStoreFc && self.currentFuncs.opt.parentStoreFc.length > 0)
    {
        funCode = self.currentFuncs.opt.parentStoreFc;

    }

    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    BOOL isSearchable  = NO;//[self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
    NSString *routeID = [self.currentFuncs.fc isEqualToString:@"TAB_F2001_AT01"] ? @"1" : @"0";
    NSDictionary *otherDic = @{kStoreDBOtherData_isFollowStore : [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore],
                               kStoreDBOtherData_storeClassCondition : [self getStoreClassFilterCondition],
                               kStoreDBOtherData_visitTimeSort : [NSString stringNotNilWithValue:self.currentFuncs.opt.visitTimeSort],
                               kStoreDBOtherData_RouteID : routeID};
    
    // 查询门店的条数
    self.titleNumer = [[WSBaseStoreDBService shareInstance] queryAllStoreCountEmpId:empId styp:self.currentFuncs.styp searchStr:self.ownSearchBar.searchBar.text search_objId:search_objId isSearchable:isSearchable acvtId:nil selctedQstValues:nil rangeConditions:nil distance:0 otherDataDic:otherDic];
    NSArray *allArray = [[WSBaseStoreDBService shareInstance]queryAllStoreWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:self.ownSearchBar.searchBar.text search_objId:search_objId isSearchable:isSearchable storeAccessMode:[self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal acvtId:nil selectedQstValues:nil rangeConditions:nil distance:0 pageNumber:self.pageNumer distanceSort:self.currentFuncs.opt.distancesSort otherDataDic:otherDic parentStoreFc:self.currentFuncs.opt.parentStoreFc];
   
    
    
    //MN-288 2018-02-07
    if([self.currentFuncs.opt.followStore isEqualToString:@"1"] && [self.currentFuncs.opt.showSub isEqualToString:@"1"])
    {
        WSSubempstoreBeanArray *subempstoreBeanArray = [WSAppData getObjectbyKey:SUBEMPSTORES];
        for (WSStoreBean *storeBean in allArray)
        {
            for(int i = 0; i < subempstoreBeanArray.subempstoreArray.count; ++i)
            {
                WSSubempstoreBean *tempBean = [subempstoreBeanArray.subempstoreArray objectAtIndex:i];
                if([tempBean.Id isEqualToString:storeBean.empId])
                {
                    storeBean.last_man = tempBean.name;
                    break;
                }
            }
        }
    }

    if (allArray.count < kStoreListPageCount) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
    //SFA-33992
    //角色TSKF用2.0的处理逻辑，角色pch用3.0的处理逻辑
        //3.0的逻辑
        //今日拜访门店（计划内）
        if ([self.currentFuncs.fv isEqualToString:@"TAB_Map"]) {
            if (self.currentFuncs.opt.resourceForm==nil||[self.currentFuncs.opt.resourceForm isEqualToString:APPUSERINFOTYPE_TSKF]) {
                [self configInPlanStoresAllArray:allArray planArray:nil];

            }
            if ([self.currentFuncs.opt.resourceForm isEqualToString:APPUSERINFOTYPE_PCH]) {
                NSString *isFollowStore = [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore];
                NSString *visitTimeSort = [NSString stringNotNilWithValue:self.currentFuncs.opt.visitTimeSort];
                NSDictionary *plan_otherDic = @{kStoreDBOtherData_isFollowStore : isFollowStore,
                                                    kStoreDBOtherData_storeClassCondition : [self getStoreClassFilterCondition],
                                                    kStoreDBOtherData_visitTimeSort : visitTimeSort,
                                                    kStoreDBOtherData_RouteID : @"1"};
                WSStoreAccessMode mode = [self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal;
                NSArray *planArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode
                                                                                                   empId:empId
                                                                                                    styp:self.currentFuncs.styp
                                                                                               searchStr:self.ownSearchBar.searchBar.text
                                                                                            search_objId:search_objId
                                                                                            isSearchable:isSearchable
                                                                                         storeAccessMode:mode
                                                                                                  acvtId:nil
                                                                                       selectedQstValues:nil
                                                                                         rangeConditions:nil
                                                                                                distance:0
                                                                                              pageNumber:-1
                                                                                            distanceSort:self.currentFuncs.opt.distancesSort
                                                                                            otherDataDic:plan_otherDic
                                                                                           parentStoreFc:self.currentFuncs.opt.parentStoreFc];
                    //处理计划内外数据
                    [self configInPlanStoresAllArray:allArray planArray:planArray];
                }
            //处理分页引起的实际拜访不显示问题
            [self configAllStoreListWithFuncode:funCode withEmpId:empId withSearchId:search_objId withIsSearchable:isSearchable];
            }else {
                
            [self.filterArray addObjectsFromArray:allArray];
                
        }
    
    // 如果有路线的功能才会走此处 --- SFA-13481
    NSString * bizeDate = [[[[NSUserDefaults standardUserDefaults]objectForKey:ROUTE_PLAN_ID] componentsSeparatedByString:@"@"]lastObject];
    if ([bizeDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]) {
        
        NSMutableArray * visitArray = [[NSMutableArray alloc]init];
        NSMutableArray * planArray =  [[NSMutableArray alloc]init];
        NSMutableArray * otherArray = [[NSMutableArray alloc]init];
        NSMutableArray * visitDoneArray = [[NSMutableArray alloc]init];
        NSMutableArray * storeArray = [NSMutableArray arrayWithCapacity:self.filterArray.count];
        for (WSStoreBean * storeBean in self.filterArray) {
            if ([storeBean.actionState isEqualToString:ActionWorking] ) {
                [visitArray addObject:storeBean];
            }else if ([storeBean.actionState isEqualToString:ActionDone] ){
                [visitDoneArray addObject:storeBean];
            }else if (storeBean.plan || (storeBean.isRouteStore && ![storeBean.isRouteStore isEqualToString:@"0"])){
                [planArray addObject:storeBean];
            }else{
                [otherArray addObject:storeBean];
            }
        }
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"isRouteStore" ascending:YES];
        planArray = [planArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]].mutableCopy;

        [storeArray addObjectsFromArray:visitArray];
        [storeArray addObjectsFromArray:planArray];
        [storeArray addObjectsFromArray:otherArray];
        [storeArray addObjectsFromArray:visitDoneArray];
        self.filterArray = storeArray.mutableCopy;
    }
    
    self.storeArray = [self.filterArray mutableCopy];
    

//    if ([self.ownSearchBar.text length] > 0) {
//        self.filterArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:self.ownSearchBar.text]];
//    }


    /*
     SFA-16255
     排序方式：从上到下
     从A级别医院到D级别医院
     从当月拜访次数为0的医院到当月拜访次数多次
     */
    if ([self.currentFuncs.opt.filterStyle isEqualToString:@"1"])
    {
        [WSStoreListDataSourceTool sortStoreWithDataArray:self.filterArray];
        [WSStoreListDataSourceTool sortStoreWithDataArray:self.storeArray];
    }
    
    
}

- (NSString *)getStoreClassFilterCondition {
    if ([self.currentFuncs.opt.addFilterType length]  == 0) {
        return @"";
    }
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean_qst *qst = [acvtService queryQstWithAcvtQstCode:@"storeClass"];
    if (!qst) {
        return @"";
    }
    WSBaseAcvtdisDBService *acvtDisService = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *dataArray = [acvtDisService queryStoreIdWithAnswer:self.currentFuncs.opt.addFilterType acvtQstID:qst.acvtQstId];
    if ([dataArray count] == 0) {
        return @"";
    }
    NSString *sql = [NSString stringWithFormat:@" and store.store_Id %@ ", [dataArray getInSqlString]];
    return sql;
}

- (void)saveAllStoreSCount {
    if ([self.filterArray count] > 0) {
        
        NSInteger allStoreCount = [self.filterArray count];
        
        NSNumber *allStoreNumber =[NSNumber numberWithInteger:allStoreCount];
        // 全日拜访（计划内）模块的总门店数量
        [FileManager setUserDefaults:allStoreNumber forKey:ALLSTOREOFOUTPLAN];
    
    }
}

- (void) initOtherFuncsBean
{
    // FCbean : 计划内    ，计划外，    新门店，             动态搜索计划外
    // key    : TAB_V2001  TAB_V2002  TAB_V2002_newstore TAB_V11001(TAB_V21002)
    
    if (!self.inPlanFuncsBean) {
        WSFuncsBean *superBarFuncsBean = nil;
        NSString *stringFC = nil;
        if(self.ownParentViewController && [self.ownParentViewController isKindOfClass:[WSCustomerVistViewController class]]){
            WSCustomerVistViewController *controller = (WSCustomerVistViewController *)self.ownParentViewController;
            stringFC = controller.currentFuncs.fc;
            
        }else if (self.ownParentViewController && [self.ownParentViewController isKindOfClass:[WSManagV_LISTViewController class]]){
            //随访计划
            WSManagV_LISTViewController *controller = (WSManagV_LISTViewController *)self.ownParentViewController;
            stringFC = controller.currentFuncs.fc;
        } else if (self.ownParentViewController && [self.ownParentViewController isKindOfClass:[WSSpecialAcvtListViewController class]]) {
            // 医生拜访
            WSSpecialAcvtListViewController *controller = (WSSpecialAcvtListViewController *)self.ownParentViewController;
            stringFC = controller.currentFuncs.fc;
        }
        else if (self.ownParentViewController && [self.ownParentViewController isKindOfClass:[WSStoreManagerViewController class]]){
            WSStoreManagerViewController *controller = (WSStoreManagerViewController *)self.ownParentViewController;
            stringFC = controller.currentFuncs.fc;
        }
        
        if (self.currentFuncs
            && self.currentFuncs.ds
            && [self.currentFuncs.ds isEqualToString:@"newstore"]) {
            
            [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V2002_newstore"];
            //新门店列表不包含其他funcsBean环境。
            return;
        }else if([self.currentFuncs.fv isEqualToString:@"TAB_V21002"]){
            
            [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V21002"];
        }else if([self.currentFuncs.fv isEqualToString:@"TAB_V11001"]){
            
            [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V11001"];
        }else{
            
            [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V2002"];
        }
        WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
        superBarFuncsBean = [fba getFuncsBeanWithFC:stringFC];
        /*
         for (WSFuncsBean *funcs in fba.funcsArray) {
         if ([funcs.fc isEqualToString:stringFC]){
         superBarFuncsBean = funcs;
         break;
         }
         for (WSFuncsBean *subFunc in funcs.funcsArray) {
         if ([subFunc.fv isEqualToString:@"TAB_V5003"] && [subFunc.fc isEqualToString:stringFC]){
         superBarFuncsBean = subFunc;
         break;
         }
         }
         
         }
         */
        if (superBarFuncsBean) {
            //判断是否需要引用菜单
            WSFuncsBean* nextfb = [self.currentFuncs.funcsArray firstObject];
            for (WSFuncsBean* fb in superBarFuncsBean.funcsArray) {
                
                if ([fb.fv isEqualToString:@"TAB_V2001"] && nextfb.submenu) { //资源是固定的，所以硬编码 TAB_V2001【计划内】。
                    self.inPlanFuncsBean = fb;
                    if (self.inPlanFuncsBean) {
                        [self.funcsBeanDic setObject:self.inPlanFuncsBean forKey:@"TAB_V2001"];
                    }
                    break;
                }
            }
        }
    
        if (!self.inPlanFuncsBean && self.subempStore) {

            self.inPlanFuncsBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
            
            if (self.inPlanFuncsBean) {
                [self.funcsBeanDic setObject:self.inPlanFuncsBean forKey:@"TAB_V2001"];
            }
        }
    }
}

#pragma mark - 菜单为TAB_F2001_AT01(今日路线)单元格点击检查方法(返回值YES通过 NO不通过)
- (BOOL)TABF2001AT01CellDidCheckWithStoreBean:(WSStoreBean *)storeBean{
    
    if (![self.currentFuncs.fc isEqualToString:@"TAB_F2001_AT01"]) {
        return YES;
    }
    if ([storeBean.actionState isEqualToString:ActionWorking]) {
        return YES;
    }
    
    NSString *routeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"];
    NSString *routeSql = [NSString stringWithFormat:@"select * from base_store_other_data bsod where bsod.store_id = '%@' and bsod.item1 = '%@' and bsod.type = '%@'",
                          storeBean.Id, routeId, @"visit_plan_route"];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *routeArray = [sqliteUtil queryAndReturnInfosBySql:routeSql andClassName:@"WSBaseStoreOtherDataObject"];
    WSBaseStoreOtherDataObject *object = [routeArray firstObject];
    if ([object.item4 isEqualToString:@"审批中"]) {
        NSString * tips = @"审批中路线无法拜访";
        if (self.selectVisitType == WSHelpSalesAlertButtonType_HelpSales) {
            tips = @"审批中路线无法助销";
        }
        [SVProgressHUD showHudMsg:tips];
        return NO;
    }
    return YES;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self endEdit];
    if(self.filterArray.count==0){
        LogError(@"用户搜索过程中，过快点击出现的闪退问题");
        return;
    }

    self.selectIndexPath = indexPath;
    WSStoreBean *store = [self.filterArray objectAtIndex:indexPath.row];
    
    if ([ISNULL(self.currentFuncs.opt.salesAssistanceMenu) length] == 0) {
        LogInfo(@"没有配置助销菜单，只执行正常拜访");
        self.selectVisitType = WSHelpSalesAlertButtonType_Visit;
        [self pushVisitModuleWithStore:store];
        return;
    }
    
    if (![WSNewStoreListTool anyStoreHasNotLeave:store andModuleFC:[self getRealModuleFC:store] withCurrentFuncs:self.currentFuncs]) {
        return;
    }
    BOOL isVisitUserInteractionEnabled = YES;
    BOOL isHelpSalesUserInteractionEnabled = YES;
    if (store.fromModuleName&&store.fromModuleName.length>0) {
        if ([store.fromModuleName isEqualToString:kHelpSalesName]) {
            //助销未完成
            isVisitUserInteractionEnabled = NO;
        }else{
            isVisitUserInteractionEnabled = YES;
        }
    }else{
        if ([store.actionState isEqualToString:ActionWorking]) {
            //拜访未完成
            isHelpSalesUserInteractionEnabled = NO;
        }else{
            isHelpSalesUserInteractionEnabled = YES;
        }
    }
    if (!isVisitUserInteractionEnabled) {
        LogInfo(@"继续助销Action");
        self.selectVisitType = WSHelpSalesAlertButtonType_HelpSales;
        [self pushVisitModuleWithStore:store];
        return;
    }
    if (!isHelpSalesUserInteractionEnabled) {
        LogInfo(@"继续拜访");
        self.selectVisitType = WSHelpSalesAlertButtonType_Visit;
        [self pushVisitModuleWithStore:store];
        return;
    }
    @weakify_self;
    [WSHelpSalesAlertView showHelpSalesViewInView:kApplicationWinddow config:^WSHelpSalesViewConfig * _Nonnull{
        return [[WSHelpSalesViewConfig alloc]init]
            .setDefaultConfig(@"")
            .setBgColor(UIColor.clearColor)
            .setIsCanSelectVisitModule(isVisitUserInteractionEnabled)
            .setIsCanSelectHelpSalesModule(isHelpSalesUserInteractionEnabled);
    } callback:^(WSHelpSalesAlertButtonType clickType){

        LogInfo(@"选中拜访类型：%@",clickType == WSHelpSalesAlertButtonType_Visit?@"拜访":@"助销");
        @strongify_self;
        self.selectVisitType = clickType;
        [self pushVisitModuleWithStore:store];
    } tipsCallBack:^(WSHelpSalesTipsType tipType) {
        LogInfo(@"选中拜访类型提醒：%@",tipType == WSHelpSalesTipsType_Visit?@"助销":@"拜访");
        if (tipType == WSHelpSalesTipsType_Visit) {
            [SVProgressHUD showHudMsg:@"请完成拜访"];
        } if (tipType == WSHelpSalesTipsType_HelpSales) {
            [SVProgressHUD showHudMsg:@"请完成助销"];
        }
    }];

    
}
#pragma mark - # 拜访功能
- (void)pushVisitModuleWithStore:(WSStoreBean*)store{
    
    BOOL TAB_F2001_AT01_CellDidCheck = [self TABF2001AT01CellDidCheckWithStoreBean:store];
    if (!TAB_F2001_AT01_CellDidCheck) {
        return;
    }
    BOOL isForceLeaveStore = [[WSInoutStoreTable sharedTable] isForceLeaveStoreWithStore:store];
    if (isForceLeaveStore) {
        NSString *str = NSLocalizedString(@"forceLeaveStore_tip", nil);
        if(self.selectVisitType == WSHelpSalesAlertButtonType_HelpSales){
            str =  NSLocalizedString(@"forceLeaveStore_help_tip", nil);
        }
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    if(self.selectVisitType != WSHelpSalesAlertButtonType_HelpSales){
        if (self.currentFuncs.opt.visitMax.length > 0 && [self.currentFuncs.opt.visitMax isEqualToString:@"1"] ) {
            if ([store.actionState isEqualToString:ActionDone] || [store.optName containsString:@"今日已访"] || [store.optName containsString:@"无效拜访"]) {
                [SVProgressHUD showHudMsg:NSLocalizedString(@"un_visit_tip", nil)];
                return;
            }
        }
        
        BOOL isExistStoreOptRemind = [self isExistStoreOptRemindWithStoreBean:store];
        if (isExistStoreOptRemind) {
            return;
        }
    }else{
        LogInfo(@"助销不需要校验拜访的进店规则");
    }
    
   
    NSString *jumpFc = [[NSUserDefaults standardUserDefaults] objectForKey:TAB_JUMP_FC];
    if (jumpFc.length > 0) {
        [self checkNeedRequestAndGoSpecialController:store withFc:jumpFc];
    }
    else {
        [self checkStateAndGoWorkflow:store];
    }
}
- (void)checkNeedRequestAndGoSpecialController:(WSStoreBean *)store withFc:(NSString *)fc {
    
    self.currentStore = store;
    
    if ([self isNeedRequest]) {
        [self startUpdata:store];
    }
    else {
        [self gotoSpecialViewController:store withFc:fc];
    }
}

- (void)checkStateAndGoWorkflow:(WSStoreBean *)aStore{
    
    if (![WSNewStoreListTool anyStoreHasNotLeave:aStore andModuleFC:[self getRealModuleFC:aStore] withCurrentFuncs:self.currentFuncs]) {
        return;
    }
    
    self.currentStore = aStore;
    
    if (self.currentFuncs.opt.storeListAcvtCode.length > 0) {
        
        WSBaseAcvtdisDBService *acvtdisDBService = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *array = [acvtdisDBService queryAcvtDisWithStoreId:aStore.Id acvtCode:self.currentFuncs.opt.storeListAcvtCode qstType:@"T"];
        self.currentStore.auxiliaryInfoArray = array;
    }

    aStore = [WSLocationManager calculateDistanceWith:aStore func:self.currentFuncs locationDescribe:self.locationDescribe isStoreList:NO];
    if ([self.currentStore.state isEqualToString:@"0"]) {
        
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"此门店为不活跃门店，请修改门店状态", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if (self.prepareFuncBean && [self.prepareFuncBean.required isEqualToString:@"R"]) {
        
        WSStorePrepareState prepareState = [self getPrepareStateByStore:aStore];
        if (prepareState == WSStorePrepareStateNotPrepare) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"prepare_before_visit", nil)  tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }
    
    if ([self.currentFuncs.opt.downByMap isEqualToString:@"1"]) {
        [self goNextWorkView:NO];
        return;
    }
    
    [self didSelectStore:aStore notification:nil];
}


#pragma -mark MN-1651 获取门店的ModuleFC
-(NSString *)getRealModuleFC:(WSStoreBean *)store{
  
    NSString *moduleFC = nil;
//    if (self.inPlanFuncsBean.fc) {
//        moduleFC = self.inPlanFuncsBean.fc;
//    }
//
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        moduleFC = self.currentVisitAction.module_fc;
    }
  
    if (!moduleFC) {
        if(self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0){
            moduleFC = self.subMenuFuncsCode;
        }else {
            moduleFC = self.currentFuncs.fc;
        }
    }

    if (store.mappingStoreListFV && [store.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        moduleFC = store.mappingStoreListFC;
    }

    return moduleFC;
}

- (void)didSelectStore:(WSStoreBean *)store  notification:(NSNotification *)notificaiton{
    if ((store.plan && ![self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) || [self.currentFuncs.filter isEqualToString:ALL_STORE_FILTER_FLAG])
    {
        if(![self anyStoreHasNotLeave:store andModuleFC:[self getRealModuleFC:store]])
            return;
        /*! 中粮特有
         *  是否可以重复访店，默认和 R 为可以，N 为不可以
         */
        if (self.inPlanFuncsBean.repeatvisit != nil && [self.inPlanFuncsBean.repeatvisit isEqualToString:@"N"]) {
            if ([self isVisitedStore:store]) {
                NSString *cannotRepeatVisit = NSLocalizedString(@"该店已完成今日稽核数据提报，您不能再进店查看或修改。", nil);;
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:cannotRepeatVisit tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
        }

        
        WSFuncsBean *nextfb = [self getRealFuncBeanNeedSubMenu:YES];
        BOOL isRemote = [nextfb.opt.isSearchable isEqualToString:kIsSearchAbleAuto] || [nextfb.opt.isSearchable isEqualToString:kIsSearchAbleRemote];
        if (isRemote) {
            [self startUpdata:store];
            return;
        }
        //计划内随访时需要实时请求数据

        if (store.storeAccessMode == WSStoreAccessModeSubEmp || (store.noteName && [store.noteName rangeOfString:@"subemp"].location != NSNotFound)) {
            if ([self isNeedRequest]) {
                [self startUpdata:store];
                return;
            }
        }
        
        [self goNextWorkView:YES];
    }
    else{
        
        if (![self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {

            if(![self.currentFuncs.opt.checkCallingStore isEqualToString:@"N"] && ![self anyStoreHasNotLeave:store andModuleFC:[self getRealModuleFC:store]])
                
                return;
            if ([self isNeedRequest]) {
                [self startUpdata:store];
            }else {
                [self goNextWorkView:NO];
            }
            
        }
        else
        {
            WSFuncsBean* nextfb = nil;
            if (self.currentFuncs.funcsArray.count > 0) {
                nextfb = [self.currentFuncs.funcsArray objectAtIndex:0];
            } else {
                if (self.subMenuFuncsBean) {
                    nextfb = self.subMenuFuncsBean;
                }
            }
            NSString *className = [WSPlistHelper valueForKey:nextfb.fv withPlistName:kControllerMappingFileName];
            UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:nextfb Store:self.currentStore];
            
            vc.currentVisitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:self.currentVisitAction andStoreId:self.currentStore.Id subMenuFuncsCode:nil];
            vc.hidesBottomBarWhenPushed = YES;
            if (self.ownParentViewController) {
                [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
            } else {
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
//    if (notificaiton) {
//        // 再次注册通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapMapViewRightCalloutAccessoryView:) name:SELECT_MAP_STORE_NOTIFICATION object:nil];
//    }
}

#pragma mark -  old code
-(void)goNextWorkView:(BOOL)plan{
    
    if (self.selectVisitType == WSHelpSalesAlertButtonType_HelpSales) {
        LogInfo(@"push 助销模块");
        [self gotoHelpSalesMoudleWithStore:self.currentStore];
        return;
    }

    WSWorkFlowViewController* wfvc = nil;
    WSFuncsBean *realFuncBean = [self getRealFuncBeanNeedSubMenu:YES];
    WSFuncsBean *realFuncBeanOld;
    //    SFA-26110 董宏
    if (self.currentFuncs.funcsArray.count == 1) {
        realFuncBeanOld = [self.currentFuncs.funcsArray firstObject];
    }
    // SFA-30042 (添加一个funcsArray的判断)
    if (realFuncBeanOld && realFuncBean && [realFuncBeanOld.fc isEqualToString:realFuncBean.fc] && realFuncBean.funcsArray.count == 0 ) {
        if (!realFuncBean.readonly) {
            [self selectListTableViewCell:nil withSlectFunsbean:realFuncBean withStoreBean:self.currentStore];
            return;
        }
    }else if (self.currentFuncs.opt.isJumpCallPlan && self.currentFuncs.opt.isJumpCallPlan.length > 0){
        WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *jumpFuncBean = [funcsBeanArray getFuncsBeanFromAllFucsWithFC:self.currentFuncs.opt.isJumpCallPlan];
        [self selectListTableViewCell:nil withSlectFunsbean:jumpFuncBean withStoreBean:self.currentStore];
        return;
    }
    if (self.subempStore && ![self.currentFuncs.iParentFuncsBean.opt.isSrid isEqualToString:@"0"]) {
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:realFuncBean Store:self.currentStore subEmpStore:self.subempStore];
    }else{
        // 因为realFuncBean 是根据当前funcs 的submenu查的 而unredo是需要当前的funcs的unredo
        // 下一级的菜单是根据realFuncBean 显示的，所以有可能不一样
        wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:realFuncBean Store:self.currentStore unredo:self.currentFuncs.unredo];
    }
    
    if (self.subMenuFuncsBean) {
        wfvc.input_reflect_code = self.subMenuFuncsCode;
        /*针对即拜访的门店加入今日拜访*/
        if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
            wfvc.input_reflect_code = self.currentStore.mappingStoreListFC;
        }
    }
    
    if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
        
        NSString *title = nil;
        if ([self.currentStore.code isKindOfClass:[NSString class]] && [self.currentStore.code length] > 0) {
             title = [NSString stringWithFormat:@"%@-%@", self.currentStore.code, self.currentStore.name];
        } else {
             title = self.currentStore.name;
        }
        wfvc.title = title;
    }
    //设置访问节点
//    wfvc.currentVisitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:self.currentVisitAction andStoreId:self.currentStore.Id subMenuFuncsCode:subMenuFB.fc];
    WSVisitStoreActionObject * visitAction = [self findActionIDAndCreateNextAction:self.currentFuncs andCurrentVisitAction:self.currentVisitAction andStoreId:self.currentStore.Id subMenuFuncsCode:self.subMenuFuncsCode];
    // 把当前的visitAction 传下去，下级页面可能会有级联关系（区分主页进入，还是从其他的方式进入（MVList））
    wfvc.currentVisitAction = self.currentVisitAction ? self.currentVisitAction : visitAction;
    visitAction.fromModuleName = @"拜访";
    wfvc.moduleFC = visitAction.func_code;
    wfvc.realParentFuncsCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode != nil && self.subMenuFuncsCode.length > 0) {
        wfvc.moduleFC = self.subMenuFuncsCode;
    }
    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        wfvc.moduleFC = self.currentStore.mappingStoreListFC;
    }
//    if(self.inPlanFuncsBean)
//    {
//        wfvc.moduleFC = self.inPlanFuncsBean.fc;
//        wfvc.input_reflect_code = self.inPlanFuncsBean.fc;
//    }
    
    
    if (INTERFACE_IS_PHONE && [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] isEqualToString:@"HWDJIOS"]) {
        WCBaseViewController *subCon = [wfvc getDefaultShowController];
        if (subCon) {
            [self gotoWorkFlowController:subCon];
            return;
        }
    }
    
    [self gotoWorkFlowController:wfvc];
}

#pragma mark - MN-1578 2018-04-08 根据最新逻辑点击计划外门店查看详情时做修改(以下为wiki地址)
#pragma mark - http://wiki.winchannel.net/xwiki/bin/view
- (NSString *)getObjIDToStoreInfo
{
    WSFuncsBean *funcsBean = self.currentFuncs;
    if (funcsBean.funcsArray && funcsBean.funcsArray.count == 1)
    {
        WSFuncsBean *tempFuncsBean = [funcsBean.funcsArray firstObject];
        //SFA 项目SFA-22323 SFA泸州老窖】【iOS】新增打假动作时，问卷显示无数据 (下一级为报表时不使用下一级的filter。安卓没有使用下一级filter逻辑，filter取得是当前级的filter) V20A01
        //TODO:SFA 项目SFA-22622 【SFA泸州老窖】【iOS】新增门店后立即拜访时门店问卷显示无数据(注意验证当前使用的FUNCS是不是正确)
        if (![tempFuncsBean.fv isEqualToString:REPOPRT_FV] && ![tempFuncsBean.fv isEqualToString:DAY_VISIT]) {
            return ((tempFuncsBean.filter.length > 0) ? tempFuncsBean.filter : ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME);
        }else{
            return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        }
    }
    else
        return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
}

-(void)requestMethed:(WSStoreBean*)aStore
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataOutPlanInfo:aStore subEmpStore:nil notifyName:UPDATA_NOTIFY];
}

-(void)startUpdata:(WSStoreBean*)store
{
    
    [self startUpdata:store storeIds:nil];

}
- (void)startUpdata:(WSStoreBean*)store storeIds:(NSString *)storeIds
{
    
    if(_sectionView)
    {
        _sectionView.address = self.locationDescribe.detailAddress;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.locationDescribe.detailAddress forKey:LOCATION_ADDRESS];
        [userDefaults synchronize];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    
    NSInteger timeout = 0;
    if (![self isRequested] && !self.isLoadingNearInfo) {  //YIHAIKERRY-4215 1.下载附近门店详情。不设置timeout
        timeout = self.currentFuncs.opt.requestTimeout;
    }
    
    if (self.currentFuncs.styp  && [self.currentFuncs.styp length] > 0) {
        
        NSString *styp = [self.currentFuncs.styp copy];
        [uploadMgr appUpdataManagerInfo:store StoreIds:storeIds subempId:self.subempid withObjId:[self getObjIDToStoreInfo] notifyName:UPDATA_NOTIFY styp:styp timeout:timeout];

    }else{
        [uploadMgr appUpdataManagerInfo:store StoreIds:storeIds subempId:self.subempid withObjId:[self getObjIDToStoreInfo] notifyName:UPDATA_NOTIFY styp:nil timeout:timeout];
    }
    
    
    if ([self isNewDownloadNearInfo]) {
    }else {
         [self querying_messageTips];
    }

}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        
        if ([self isNewDownloadNearInfo]) {
             _isLoadingNearInfo = NO;
            [self closeProgressView];
            NSString *tipsString = NSLocalizedString(@"data_download_failure", nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
        
        // YIHAIKERRY-3586 不需要请求设置了超时时间则直接进店
        if (![self isRequested] && self.currentFuncs.opt.requestTimeout > 0) {
            if (self.currentStore != nil) {
                [self goNextWorkView:NO];
                return;
            }
        }
        
        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        
        NSString *objId = [self getObjIDToStoreInfo];
        
        NSObject *tmpObject = uploadState[objId];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
//            if ([(NSArray *)tmpObject count] > 1 || ([(NSArray *)tmpObject count] == 1 && [self isNewDownloadNearInfo])) {  //YIHAIKERRY-4123  下载1条详细数据的特殊处理 //数据详情下载成功，隐藏进度条，刷新UI
//                [self uploadStoreInfo:(NSArray*)tmpObject];
//                return;
//            }
        }
        if(self.currentStore != nil){
            [self.currentStore reSetStore:uploadState Key:objId];

            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
            
            NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
            [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id ];
            
        }
//
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        if (self.isRequestingDataForPrepare) {
            self.isRequestingDataForPrepare = NO;
            [self showVisitTypeControllerWithStore:self.currentStore date:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
        }else if (self.currentStore != nil) {
            
            NSString *jumpFc = [[NSUserDefaults standardUserDefaults] objectForKey:TAB_JUMP_FC];
            if (jumpFc.length > 0) {
                [self gotoSpecialViewController:self.currentStore withFc:jumpFc];
            }else{
                // YIHAIKERRY-3054
                // SFA 益海嘉里-传统渠道-【ios】【门店筛选】当筛选结果只有一家时，会自动进入该门店
                [self goNextWorkView:NO];
            }

            
            //YIHAIKERRY-3481  不在每次刷新，所以下载详细数据后，刷新点击的cell
            NSInteger selectRow = self.selectIndexPath.row;
            if (self.selectIndexPath && selectRow < self.filterArray.count ) {
                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.selectIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
           
        }
        
    }
}
- (void)uploadStoreInfo:(NSArray*)storeInfoArr
{
    /* 修改为下面的批量存储
    for (NSDictionary *dic in storeInfoArr) {
        for (NSInteger i = 0 ; i < self.filterArray.count ; i++) {
            WSStoreBean *storeBean =  self.filterArray[i];
            if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]] isEqualToString:storeBean.Id]) {
                [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dic];
                NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
                [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:storeBean.Id];
                break;
            }
        }
    }
    */
    
    NSArray *storeIdArray = [storeInfoArr valueForKeyPath:@"id"];
    NSString *empId = ([self.subempStore.Id length] > 0) ? self.subempStore.Id : [self getCurrentEmpId];
    NSDictionary *storesDicInfo = [WSStoreDataProcessService convertStoresInfoDictionaryFromStores:storeInfoArr];
    [WSStoreDataProcessService processStoreInfoDataToDbWithStoresInfo:storesDicInfo storeID:nil genId:nil isRemoteSearch:NO];
    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeIdArray:storeIdArray];
    
    
    
    //数据详情下载成功，隐藏进度条，刷新UI。
    if ([self isNewDownloadNearInfo]) {
        /* 上面的逻辑中实现
        //YIHAIKERRY-3319 下载附近100家的详情保存到db中
        for (NSDictionary *dic in storeInfoArr) {
            for (NSInteger i = 0 ; i < self.needLoadList.count ; i++) {
                WSStoreBean *storeBean =  self.needLoadList[i];
                if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"id"]] isEqualToString:storeBean.Id]) {
                    [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dic];
                    NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
                    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:storeBean.Id];
                    break;
                }
            }
        }
        */
        
        _isLoadingNearInfo = NO;
        [self closeProgressView];
        [self.tableView reloadData];
    }
   

}

- (BOOL) isNewStorePage
{
    if (self.currentFuncs.ds && [self.currentFuncs.ds isEqualToString:@"newstore"]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    NSString *className = [WSPlistHelper valueForKey:self.currentFuncs.fv withPlistName:kControllerMappingFileName];
    UITableView* tv;
    if ([WSEnvrionment getStoreDataFromDb]) {
        tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    }else {
        if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0) && [className isEqualToString:@"WSNewStoreListViewController"]) {
            tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        } else {
            tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        }
    }
    //tableview
    tv.backgroundColor = [UIColor whiteColor];
    tv.tableFooterView = [[UIView alloc] init];
    tv.backgroundView = nil;
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tv setDelegate:self];
    [tv setDataSource:self];
    //tv.tableHeaderView = [self getTableHeaderView];// headerView;
    self.filterArray = [NSMutableArray arrayWithArray:self.storeArray];
    self.tableView = tv;
    [self.view addSubview:self.tableView];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(updragStoreData)];
    
    [self.tableView.mj_footer beginRefreshing];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 240.0;
    [self.tableView registerClass:[WSRouteStoreTableViewCell class] forCellReuseIdentifier:@"NewTableviewCellIdentifier"];

    if (INTERFACE_IS_PAD) {
        tv.backgroundColor = RGBCOLOR(246, 246, 246);
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
#endif
    
    // MSTD-7155
    [self addLocationObserver];
}

- (void) addOptMapView
{
    UIBarButtonItem *rightItem  =  nil;
    //地图按钮
    if ((self.currentFuncs.opt && self.currentFuncs.opt.isMap) || !self.currentFuncs.opt) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(5, 0, 25, 25)];
        [rightButton addTarget:self action:@selector(mapButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:[UIImage imageNamed:@"storeMapMode"] forState:UIControlStateNormal];
        
        rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        
        [self getNavigationItem].rightBarButtonItem = rightItem;
        
        NSDictionary *dic = @{kActionInfoDicTitleKey:@"售点地图", kActionInfoDicImageKey:@"storeMapMode", kActionInfoDicSelectorKey:@"mapButtonItemClick"};
        [self.rightButtonInfoArray addObject:dic];

    }
    
    
}

- (void)addFilterStoreBarButtonItem {
    
    if ([self.currentFuncs.opt.searchQuestion length] == 0) {
        LogInfo(@"self.currentFuncs.opt.searchQuestion is nil");
        return;
    }
//    YIHAIKERRY-1572 董宏 注视 searchQuestion 控制 acvtSearch 是本地的 也有可能实时
//    if ([self.currentFuncs.opt.acvtSearch length] == 0) {
//        LogInfo(@"self.currentFuncs.opt.acvtSearch is nil");
//        return;
//    }
    
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].rightBarButtonItems] ;

    UIButton *filterStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterStoreButton setFrame:CGRectMake(0, 0, 25, 25)];
    [filterStoreButton addTarget:self action:@selector(filterStoreClicked) forControlEvents:UIControlEventTouchUpInside];
    [filterStoreButton setImage:[UIImage imageNamed:@"acvtSearchStore"] forState:UIControlStateNormal];
    UIBarButtonItem *filterStoreItem = [[UIBarButtonItem alloc] initWithCustomView:filterStoreButton];
    [barButtonItems addObject:filterStoreItem];
    

    [self getNavigationItem].rightBarButtonItems = barButtonItems;

    NSDictionary *dic = @{kActionInfoDicTitleKey:@"条件筛选", kActionInfoDicImageKey:@"icon_filter", kActionInfoDicSelectorKey:@"filterStoreClicked"};
    [self.rightButtonInfoArray addObject:dic];
 
}

- (void)addLocationBarButtonItem {
    
    if ([self isUploadGeoLocationInfo]) {
        NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
        
        if (!_locationButton) {
            UIBarButtonItem *locBBI = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonClicked)];
            if ([self.navigationController.navigationBar.backgroundColor isEqual:[UIColor whiteColor]] || [self.navigationController.navigationBar.backgroundColor isEqual:[UIColor clearColor]]) {
                [locBBI setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
            }else
                [locBBI setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:UI_Font]} forState:UIControlStateNormal];
            
            _locationButton = locBBI;
        }
        
        [barButtonItems addObject:_locationButton];
        if (self.allCitys.count == 0) {
            WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
            NSString *levelCod = self.currentFuncs.opt.gpsCityLevel ? self.currentFuncs.opt.gpsCityLevel : @"2";
            self.allCitys = [service queryCityListByFilter:@"geography" levelCode:levelCod];
        }
        
        if (self.allCitys.count > 0 && [self isKindOfClass:[WSCustomerQueryViewController class]]) {
//            UIBarButtonItem *locImageItem = [[UIBarButtonItem alloc]initWithImage:[UIImage scaledImageForName:@"carat-open" ofType:@"png"] style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonClicked)];
//            [barButtonItems addObject:locImageItem];
//            MSTD-6353 xuhan 2017 1024
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 40)];
            
            UIBarButtonItem *viewItem = [[UIBarButtonItem alloc]initWithCustomView:view];
            [barButtonItems addObject:viewItem];
            
        }
        
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
        
        NSDictionary *dic = @{kActionInfoDicTitleKey:@"所在城市", kActionInfoDicImageKey:@"", kActionInfoDicSelectorKey:@"locationButtonClicked"};
        [self.leftButtonInfoArray addObject:dic];
    }

    
}

- (void)addBackBarButtonItem {
    
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    
    // SFA-9343
    if ([self getNavigationController].viewControllers.count <= 1) {

    }else{
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBBIClicked)];
        [barButtonItems addObject:backBBI];
        
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
        
        NSDictionary *dic = @{kActionInfoDicTitleKey:@"所在城市", kActionInfoDicImageKey:@"", kActionInfoDicSelectorKey:@"locationButtonClicked"};
        [self.leftButtonInfoArray addObject:dic];
    }
}

- (void)backBBIClicked
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)locationButtonClicked
{
    NSLog(@"重新定位并显示所在城市：%@", self.currentCity);
//    [_locationButton setTitle:@"beijing"];
    [self locationMe];
}

- (BOOL)isUploadGeoLocationInfo {
    
    if ([@"N" isEqualToString:self.currentFuncs.opt.isOpenGeo]){
        return NO;
    }
    return YES;
}

- (void)setBarButtonTitle {
    NSString *currentCity = [[NSUserDefaults standardUserDefaults] stringForKey:kGlobalCityName];

    if (!currentCity) {
        currentCity = NSLocalizedString(@"beijing", nil);
    } else {
        currentCity = NSLocalizedString(currentCity, nil);
        self.currentCity = currentCity;
    }
    if (currentCity.length > 4) {
        NSString  *temString = [currentCity substringToIndex:3];
        currentCity = [NSString stringWithFormat:@"%@...",temString];
    }
    [_locationButton setTitle:currentCity];
    [UIView animateWithDuration:0.4 animations:^{
        _searchBar.alpha = 1;
    }];
    
}

- (void)locationMe {
    
    DDLogInfo(@"（wsallstoresviewcontroller）: 使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
}

// sfa-29036 去掉原有逆地理方法，使用wslocationmanager类已经解析到的地址
- (void)locationFinished:(NSNotification *)sender{
    
    DDLogInfo(@"（locationFinished）:通知回来了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    self.locationDescribe = tmpLocationDescribe;
    
    if (error) {
        // MSTD-7155
        if ([self isKindOfClass:[WSCustomerQueryViewController class]] && ![[WSLocationManager getInstance] currentLocationServicesEnabled]) {
            self.isRefreshLocation = YES;
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"turn_on_gps", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
        
        LogError(@"（wsallstoresviewcontroller）: 当前城市获取位置失败,class:%@,error:%@",[self class], error);
        
    }else{
        
        DDLogInfo(@"（locationFinished）: city:%@ latitude:%f, longitude:%f",tmpLocationDescribe.cityName, self.locationDescribe.location.coordinate. latitude,self.locationDescribe.location.coordinate.longitude);
        [self resetLocation:tmpLocationDescribe.provinceName locality:tmpLocationDescribe.cityName subLocality:tmpLocationDescribe.subLocality];
        self.isRefreshLocation = NO;
    }
}

- (void)addLocationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshLocation)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}

- (void)refreshLocation {
    if (self.isRefreshLocation) {
        [self locationMe];
    }
}

- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality {
    
//    if(_sectionView)
//    {
//        _sectionView.address = self.locationDescribe.detailAddress;
//    }
    if (locality.length > 4) {
        NSString  *temString = [locality substringToIndex:3];
        locality = [NSString stringWithFormat:@"%@...",temString];
    }
    [_locationButton setTitle:locality];
    
    if (self.allCitys == nil) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        NSString *levelCod = self.currentFuncs.opt.gpsCityLevel ? self.currentFuncs.opt.gpsCityLevel : @"2";
        self.allCitys = [service queryCityListByFilter:@"geography" levelCode:levelCod];
    }
    
}

- (void)secondUpdateLocaiton {
    [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        if (aLocationDescribe.location
            && (aLocationDescribe.location.coordinate.longitude != 0
                && aLocationDescribe.location.coordinate.latitude != 0)) {
                self.locationDescribe = aLocationDescribe;
            }
    }];
}

- (UIView *)getTableHeaderView {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:YES isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE){
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView addSubview:self.ownSearchBar];
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    return headerView;
}

- (void)addRightBarButtons
{
    [self navBarClearRightBarButtonItems];
    
    [self addOptMapView];
    if (self.storeFilterViewDataArray.count != 3) {
        [self addFilterStoreBarButtonItem];
    }
    [self addNewActBarButtonItem];
    [self addRefreshButton];

    [self refreshRightButtonsByCount];
}
// 添加地图刷新按钮
-(void)addRefreshButton{
    
}
- (void)addLeftBarButtons
{
    [self navBarClearLeftBarButtonItems];
    
    [self addBackBarButtonItem];
    [self addLocationBarButtonItem];
}

-(void)updragStoreData{
    NSLog(@"上拉加载");
    self.pageNumer += 1;
    
    // 如果有筛选条件 或者 筛选距离则使用带有条件的方法刷新列表
    if ((self.conditions.count > 0) || (self.distance > 0) || self.rangeConditions.count > 0) {
//        [self reloadStoreListBySearchConditon:self.conditions.mutableCopy distance:self.distance];旧的
        [self reloadStoreListBySearchConditon:self.conditions.mutableCopy rangeConditions:self.rangeConditions distance:self.distance withSortStr:@""];
    }else{
        [self refreshData];
    }
}
- (void)addToolBar {
//    [self clearAllNavBBI];
    [self addAllNavBBI];
}

- (void)addAllNavBBI
{
    [self addRightBarButtons];
    [self addLeftBarButtons];
    // SFA-21233 赵丹阳
    if (![self.currentFuncs.opt.isShowSubArea isEqualToString:@"1"] || !self.currentFuncs.opt.isOpenSubTrackMap) {
        [self addSearchBarToNavigationTitleView];
    }

    [self setBarButtonTitle];
    
    if ([self.currentFuncs.value isEqualToString:@"manualQuery"]) {
        [self clearAllNavBBI];
    }
}

- (void)clearAllNavBBI
{
    [self navBarClearRightBarButtonItems];
    [self navBarClearLeftBarButtonItems];
    [self removeSearchBarFromNavigationTitleView];
}

// SFA-5115 清除右侧按钮，否则会反复出现或者反复添加
- (void)navBarClearRightBarButtonItems
{
    [self getNavigationItem].rightBarButtonItems = nil;
    [self.rightButtonInfoArray removeAllObjects];
}

- (void)navBarClearLeftBarButtonItems
{
    [self getNavigationItem].leftBarButtonItems = nil;
    [self.leftButtonInfoArray removeAllObjects];
}

- (void)mapButtonItemClick{
    
    WSAllStoresMapViewController * storeMapVc = [[WSAllStoresMapViewController alloc]initWithFuncs:self.currentFuncs inPlanFuncs:self.inPlanFuncsBean];
    storeMapVc.subempStoreId = self.subempStore.Id;
    storeMapVc.subMenuFuncsCode = self.subMenuFuncsCode;
    if ([self isKindOfClass:[WSCustomerQueryViewController class]]) {
        storeMapVc.searchObjId = [(WSCustomerQueryViewController *)self getObjIDToStoreList];
    }
    storeMapVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:storeMapVc animated:YES];
    
}

- (void)filterStoreClicked {
    
    if (_searchBar.searchBar.isFirstResponder) {
         [_searchBar.searchBar resignFirstResponder];
    }
   
    if (_acvtSearchStoreView == nil) {
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc]init];
        WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtCode:self.currentFuncs.opt.searchQuestion];
        _acvtBeanForSearchStore = acvtBean;
        CGRect rect = [UIScreen mainScreen].bounds;
        _acvtSearchStoreView = [[WSAcvtSearchStoreView alloc]initWithFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height) current:self.currentFuncs acvtBean:acvtBean];
        _acvtSearchStoreView.delegate = self;
        _acvtSearchStoreView.locationDescribe = self.locationDescribe;

        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIView *rootView = delegate.window.rootViewController.view;
        [rootView addSubview:_acvtSearchStoreView];
        [self performSelector:@selector(moveAcvtSearchStoreView) withObject:nil afterDelay:0.01];
        [_acvtSearchStoreView requestStoreAcvtdisData];
        
    }else {
        [self.acvtSearchStoreView.superview bringSubviewToFront:self.acvtSearchStoreView];
        [self moveView:_acvtSearchStoreView.rightView offset:-self.acvtSearchStoreView.rightView.width];
        //YIHAIKERRY-3767
        //SFA 益海嘉里-传统渠道 -【IOS】账号门店列表下载成功，关闭手机网络，然后进入“门店下载中心”将当前城市门店清除，返回门店列表，高级筛选里的内容没有清空
        if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
            [self.acvtSearchStoreView refreshStoreAcvtDataSource];  //刷新数据源
        }

    }
    
}

- (void)moveAcvtSearchStoreView {

    [self moveView:self.acvtSearchStoreView.rightView offset:-self.acvtSearchStoreView.rightView.width];
}

-(void)moveView:(UIView *)view offset:(CGFloat)offset {
    if (offset <= 0) {
        [self.acvtSearchStoreView setHidden:NO];
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = view.frame;
        frame.origin.x += offset;
        view.frame = frame;
    } completion:^(BOOL finished) {
        self.acvtSearchStoreView.blockView.alpha = 0.6;
        if (offset > 0) {
            [self.acvtSearchStoreView setHidden:YES];
        }
    }];
    
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)pushMap
{
    WSRPMapViewController * rpMap = [[WSRPMapViewController alloc]init];
    rpMap.storeHttpService = self.storeHttpService;
    rpMap.currentFuncs = self.currentFuncs;
    rpMap.subempStore = self.subempStore;
    rpMap.subMenuFuncsCode = self.subMenuFuncsCode;
    rpMap.hidesBottomBarWhenPushed = YES;
    rpMap.downByMap = self.currentFuncs.opt.downByMap;
    [self.navigationController pushViewController:rpMap animated:YES];
}
#pragma mark tableViewDelegate

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [self.filterArray count];//[self.storeArray count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSStoreBean *rowStore = [self.filterArray objectAtIndex:indexPath.row];
    
    if ([self.currentFuncs.opt.showStyle isEqualToString:@"compactStyle"])
    {
        return [WSNewTodayVisitAndAllStoreCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
    }
    else
    {
        return UITableViewAutomaticDimension;
        
      // return [WSSelectListNewTableviewCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headHeight = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        headHeight = 1.0f;
    }
    if ([self.currentFuncs.opt.downByMap isEqualToString:@"1"]) {
        headHeight = 68;
    }else if([self.currentFuncs.opt.downByMap isEqualToString:@"2"]){
        headHeight = 44;
        if (_isLocationFail) {
            headHeight = 86;
        }
    }
    return headHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat viewHeight  = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        viewHeight = 1.0f;
    }
    UIView *headView = [[UIView alloc]init];
    [headView setFrame:CGRectMake(0,0, tableView.frame.size.width, viewHeight)];
    if ([self.currentFuncs.opt.downByMap isEqualToString:@"1"]) {
        viewHeight = 68;
        [headView setFrame:CGRectMake(0,0, tableView.frame.size.width, viewHeight)];
        headView.backgroundColor = [UIColor whiteColor];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * str = [NSString stringWithFormat:@"最新下载地址:%@",[userDefaults objectForKey:LOCATION_ADDRESS]];
        [userDefaults synchronize];
        _sectionView = [[WSAllStoreSectionView alloc] initWithFrame:headView.bounds andAddress: str.length > 0 ? str : @""];
        __weak typeof(self) weakSelf = self;
        _sectionView.resultIndex = ^(NSInteger index) {
            [weakSelf pushMap];
        };
        [headView addSubview:_sectionView];
    }else if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
        viewHeight = 86;
        
        [headView setFrame:CGRectMake(0,0, tableView.frame.size.width, viewHeight)];
        headView.backgroundColor = [UIColor whiteColor];
        
        //配置中的最大下载数量
        NSInteger maxLoadNum = [self.currentFuncs.opt.downloadInfoNum  integerValue];
        _sectionView = [[WSAllStoreSectionView alloc] initWithFrame:headView.bounds andLoadNum:(self.titleNumer > maxLoadNum ? maxLoadNum : self.titleNumer)];
        
        if (_isLocationFail) {
            _sectionView.titleLabel.hidden = NO;
        }else {
            _sectionView.titleLabel.hidden = YES;
        }
        [_sectionView.leftButton addTarget:self action:@selector(downloadNearStoreInfoData) forControlEvents:UIControlEventTouchDown];
        [_sectionView.rightButton addTarget:self action:@selector(refreshStoreList) forControlEvents:UIControlEventTouchDown];
        
        [headView addSubview:_sectionView];

    }
    return headView;
}
#pragma mark - 顶部下载详情和刷新清单这两个按钮的点击方法  YIHAIKERRY-3241
- (void)downloadNearStoreInfoData {
}
-(void)refreshStoreList {
}
//移除下载进度条
- (void)closeProgressView
{
}

#pragma mark - 帮助函数
//200家新功能，且正在下载附近门店列表
-(BOOL)isNewDownloadNearInfo {
    return ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]&& _isLoadingNearInfo) ;
}
#pragma mark - WSStoreFilterViewDelegate
- (void)storeFilterButonDidClick:(UIButton *)filterBtn
{
    if (storeFilterView.filterStyle == WSStoreFilterViewMengNiuStyle)
    {
        [self.menuViewDataArray removeAllObjects];
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        currentAcvtBean_qstObj =_storeFilterViewDataArray[filterBtn.tag-500];
        //查询出筛选条件model
        _menuViewDataArray = (NSMutableArray *)[service queryDictsWithParentId:currentAcvtBean_qstObj.memo filter:currentAcvtBean_qstObj.filter];
        // MN-1858 蒙牛去除全部类型选择，如果配置了默认值，则用默认值作为第一项。
        if (_menuViewDataArray.count && currentAcvtBean_qstObj.defaultValue.length > 0) {
            WSDictBean * dictBean = [[WSDictBean alloc]init];
            dictBean.name = currentAcvtBean_qstObj.defaultValue;
            dictBean.Id = @"-1";
            [_menuViewDataArray insertObject:dictBean atIndex:0];
        }
        [WSPopMenuView showRelyOnView:filterBtn titles:_menuViewDataArray icons:nil menuWidth:filterBtn.width withClickBtn:filterBtn delegate:self];
    }
    else
    {
        //辉瑞医院筛选
        WSDictBean *dictBean = nil;
        NSMutableDictionary *filterDict = nil;
        if (filterBtn.selected) {
            dictBean = _storeFilterViewDataArray[filterBtn.tag-500];
            filterDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:dictBean.Id?dictBean.Id:@"",currentAcvtBean_qstObj.acvtQstId?currentAcvtBean_qstObj.acvtQstId:@"", nil];
        }
        [self acvtSearchFilterStoreWithCondition:filterDict rangeConditions:nil distance:0 withSortStr:sortStr];
    }
}

#pragma mark - WSPopMenuViewViewDelegate
- (void)wsPopupMenuDidSelectedAtIndex:(NSInteger)index popupMenu:(WSPopMenuView *)popupMenu
{
    NSInteger objIndex = [_storeFilterViewDataArray indexOfObject:currentAcvtBean_qstObj];
    WSDictBean *dictBean = _menuViewDataArray[index];
    BOOL isHasDefaultValue = currentAcvtBean_qstObj.defaultValue.length;
    switch (objIndex) {
        case 0:
            
            if (index == 0 && isHasDefaultValue)
            {
                /*全部时候去掉筛选条件*/
                [lastDic removeAllObjects];
            }
            else
            {
                [lastDic setValue:dictBean.Id?dictBean.Id:@"" forKey:currentAcvtBean_qstObj.acvtQstId?currentAcvtBean_qstObj.acvtQstId:@""];
            }
            
            break;
            
        case 1:
            if (index == 0 && isHasDefaultValue)
            {
                [currentDic removeAllObjects];
            }
            else
            {
                [currentDic setValue:dictBean.Id?dictBean.Id:@"" forKey:currentAcvtBean_qstObj.acvtQstId?currentAcvtBean_qstObj.acvtQstId:@""];
            }
            break;
            
        case 2:
            if (index == 0)
            {
                [nextDic removeAllObjects];
                if ([dictBean.name isEqualToString:@"离我最近"])
                {
                    sortStr = self.currentFuncs.opt.distancesSort;
                }
            }
            else
            {
                [nextDic setValue:dictBean.Id?dictBean.Id:@"" forKey:currentAcvtBean_qstObj.acvtQstId?currentAcvtBean_qstObj.acvtQstId:@""];
                if ([dictBean.name isEqualToString:@"最近访问"])
                {
                    sortStr = @"call.acvt_qst_answer ,";
                }
                else if ([dictBean.name isEqualToString:@"拜访次数"])
                {
                    sortStr = @"number.acvt_qst_answer ,";
                }
                else if ([dictBean.name isEqualToString:@"门店销量"])
                {
                    sortStr = @"sales.acvt_qst_answer ,";
                }
                
            }
            break;
            
        default:
            break;
    }
    //每次点击 都要删除之前存过的筛选条件
    [allDic removeAllObjects];
    //筛选条件加入统一的字典
    [allDic addEntriesFromDictionary:lastDic];
    [allDic addEntriesFromDictionary:currentDic];
    [self acvtSearchFilterStoreWithCondition:allDic rangeConditions:nil distance:0 withSortStr:sortStr];
    
}

- (WSVisitStoreActionObject*) findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                        andCurrentVisitAction:(WSVisitStoreActionObject *)currentAction
                                                   andStoreId:(NSString *)store_id
                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode
{

    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = currentAction.ID;
    action.store_id = store_id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = self.subempStore.Id ? self.subempStore.Id : [self getCurrentEmpId];
    action.title = funcsBean.name;
    
    NSString *moduleFC;
    if ([currentAction.module_fc length] > 0) {
        moduleFC = currentAction.module_fc;
    }else if([subMenuFuncsCode length] > 0){
        moduleFC = subMenuFuncsCode;
    }else {
        moduleFC = funcsBean.fc;
    }
    
    action.module_fc = moduleFC;

    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        action.module_fc = self.currentStore.mappingStoreListFC;
    }

    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

#pragma mark WSAllStoresMapViewController Notification
- (void)tapMapViewRightCalloutAccessoryView:(NSNotification*)notifiction {
    NSDictionary *userInfo = [notifiction userInfo];
    WSStoreBean *store = [userInfo objectForKey:SELECTED_MAP_STORE];
    if (store) {
        self.currentStore = store;
    }
//    donghong   YIHAIKERRY-2595 在离线模式情况下 地图的门店列表也要支持 离线
    if([self.currentFuncs.opt.downByMap isEqualToString:@"1"])
    {
        [self checkStateAndGoWorkflow:store];

    }
    else
    {
        [self didSelectStore:store notification:notifiction];
    }
}

//过滤shortCut拜访项
- (NSArray *)filterShortCutFuncsBean:(WSFuncsBean *)currentFuncs{
    
    WSFuncsBean* nextfb = [currentFuncs.funcsArray firstObject];
    
    WSFuncsBean* subMenuFB = nil ;
    
    //在计划外，未拜访new 引用 subMenuFB ；
    if (nextfb.submenu.length >0 ) {
        
        subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByFuncsCode:nextfb.submenu];
        
    }
   
    else {
         //OTC 随访 不会引用 subMenuFB ，直接走的funcsArray ；
        subMenuFB = nextfb ;
        
    }
   
    WSFunsShortCutData *data = [[WSFunsShortCutData alloc]init];
    
    NSArray *array = [[NSArray alloc]init];
    
    array = [data filterShortCutData:subMenuFB];
    
    return array;
    
}

//- (void)acvtSearchFilterStoreWithCondition:(NSMutableDictionary *)conditions distance:(CGFloat)distance
- (void)acvtSearchFilterStoreWithCondition:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance withSortStr:(NSString *)sortStr{
    /*filter DB  dataSource*/
    self.conditions = conditions.copy;
    self.rangeConditions = rangeConditions;
    self.distance = distance;
    self.pageNumer = 0;
    [self.filterArray removeAllObjects];
    [self reloadStoreListBySearchConditon:conditions rangeConditions:rangeConditions distance:distance withSortStr:sortStr];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
//    [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
}

- (void)resetTitle {
    NSString *title ;
    
    if ([self.currentFuncs.opt.hideCount isEqualToString:@"1"]) {
        title = [NSString stringWithFormat:@"%@", self.currentFuncs.name];
    }else{
        title = [NSString stringWithFormat:@"%@(%lu)", self.currentFuncs.name, (unsigned long)self.titleNumer];
    }
    
    [self refreshControllerTitle:title];
}

#pragma mark - 辉瑞零售详情快捷键
- (void)selectListTableViewCell:(WSSelectListTableViewCell *)cell withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    UIViewController *viewController = [self nextPageWithFunsBean:bean withINdexStore:storeBean];
    
    [self gotoNextPageWithViewController:viewController withFuncsBean:bean withStoreBean:storeBean withAutoJump:YES];
    
}



#pragma mark - WSSelectListNewTableviewCellDelegate

- (void)storePrepareWith:(WSStoreBean *)store withDate:(NSString *)date{
    
    self.currentStore = store;
    
    self.isRequestingDataForPrepare = YES;
    
    if (store.plan) {
        [super storePrepareWith:store withDate:date];
    }else {
        
//        WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
//        NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
//        BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
//        if (!isRequested) {
//            isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
//        }
        if ([self isNeedRequest]) {
            
            // SFA-23630  IOS：SFA立白【经销商】门店列表增加订单详情按钮入口，直接跳转到最近三次订单页面最近三次订单  --2018/9/21
            if ([self.prepareFuncBean.ds isEqualToString:@"acvt"]) {
                [self startUpdata:store];
            }else {
                [super storePrepareWith:store withDate:date];
            }

        }else {
            [super storePrepareWith:store withDate:date];
        }
    }
}

#pragma mark WSAcvtSearchStoreViewDelegate Method

- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView isShow:(BOOL)isShow {
    if (!isShow) {
        [self moveView:self.acvtSearchStoreView.rightView offset:self.acvtSearchStoreView.rightView.width];
    }
}

- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView searchStoreWithCondition:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance searchStoreType:(NSString *)storeType {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self acvtSearchFilterStoreWithCondition:conditions rangeConditions:rangeConditions distance:distance withSortStr:@""];
    });
}
#pragma mark
#pragma mark  click function
-(void)chatButtonPressDown:(WSStoreBean*)store{
    // 规范变量命名 zhaodanyang
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *storeimage=@"";
    if(store.storeImg && store.storeImg.length>0){
        storeimage=[WSHttpURLHelper getImageCompleteURL:store.storeImg];
    }
    NSString *storeName=@"";
    if(store.name && store.name.length>0){
        storeName=store.name;
    }
    NSString *storeID=@"";
    if(store.Id && store.Id.length>0){
        storeID=store.Id;
    }
    NSString *local_ImageID=@"";
    if(store.local_ImageID && store.local_ImageID.length>0){
        local_ImageID=store.local_ImageID;
    }
    NSString *nickname=[[WSEMSDKManager sharedInstance]getChatNickName];
    if(nickname==nil || nickname.length<=0){
        nickname=@"";
    }
    NSString *headImageUrl=[[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
    if(headImageUrl==nil || headImageUrl.length<=0){
        headImageUrl=@"";
    }

    NSString *sourceFrom = WS_MSG_SOURCENEEDNOTIFICATION;
        NSMutableDictionary *extDic=[[NSMutableDictionary alloc] init];
    [extDic setObject:storeimage forKey:WS_MSG_toStoreUrl];
    [extDic setObject:storeID forKey:WS_MSG_toStoreId];
    [extDic setObject:storeName forKey:WS_MSG_toStoreName];
    [extDic setObject:nickname forKey:WS_MSG_fromChatrealName];
    [extDic setObject:headImageUrl forKey:WS_MSG_fromChatHeadImgUrl];
    [extDic setObject:sourceFrom forKey:WS_MSG_sourceFrom];
    //取得该商店对应业代聊天账号
    WSUserInfo *storeUserInfo=[[WSEMSDKManager sharedInstance]getUserInfoWithStoreID:store.Id andEmpId:store.empId];
    NSString *conversation=storeUserInfo.wschatID;
    
    NSString *toChartHeadURL=@"";
    if(storeUserInfo.wsheadImageURL && storeUserInfo.wsheadImageURL.length>0){
        toChartHeadURL=[WSHttpURLHelper getImageCompleteURL:storeUserInfo.wsheadImageURL];
    }
    NSString *toChartName=@"";
    if(storeUserInfo.wsname && storeUserInfo.wsname.length>0){
        toChartName=storeUserInfo.wsname;
    }
    [extDic setObject:toChartHeadURL forKey:WS_MSG_toChatHeadImgUrl];
    [extDic setObject:toChartName forKey:WS_MSG_toChatrealName];

    NSString *jsonStr=[extDic JSONString];
    
    
    [dict setObject:jsonStr forKey:WS_MSG_protyKey];

    WSChartViewController *chartViewController=[[WSChartViewController alloc]initWithConversationChatter:conversation conversationType:EMConversationTypeChat extertDic:dict];
    chartViewController.store = store;
    chartViewController.navigationItem.title=store.name;
    chartViewController.hidesBottomBarWhenPushed = YES;
    if (self.ownParentViewController==nil) {
        [self.navigationController pushViewController:chartViewController animated:YES];
    }else{
        [self.ownParentViewController.navigationController pushViewController:chartViewController animated:YES];
    }

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)isShowEmptyView
{
    if([self.currentFuncs.opt.downByMap isEqualToString:@"1"]||[self.currentFuncs.opt.downByMap isEqualToString:@"2"])
    {
        return;
    }
    if ([self.filterArray count] == 0 &&
        ![self.className isEqualToString:@"WSSubEmpMapViewController"])
    {
        if (!self.empty)
            [self addEmptyView];
        
        if ([self.currentFuncs.fc isEqualToString:@"TAB_F2001_AT01"]) {
//            [MBProgressHUD showHUDAddedTo:self.view withText:@"" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            NSString * msg = @"暂无数据，请选择路线，点击跳转到我的路线";
            [SVProgressHUD showHudMsg:msg];
        }
    }
    else{
        [self.empty removeFromSuperview];
        self.empty = nil;
    }
}
#pragma mark- WSAddNewStoreViewControllerDelegate
- (void)toBeVisitedStore:(WSStoreBean *)storeBean
{
    [self checkStateAndGoWorkflow:storeBean];
}





//------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------

#pragma mark - 实现searchBarTextDidEndEditing:协议
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - 实现searchBarTextDidBeginEditing:协议
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    for (UIView *cc in [searchBar subviews]) {
        for (UIView *views in [cc subviews]) {
            if ([views isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)views;
                [btn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                break;
            }
        }
    }
}

#pragma mark - 实现searchBarCancelButtonClicked:协议
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [self reloadStoreList];
    [self searchOperationRefresh];
}

#pragma mark - 实现searchBar:textDidChange:协议
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self reloadStoreList];
    [self searchOperationRefresh];
}

#pragma mark - 实现searchBarSearchButtonClicked:协议
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    
    [self reloadStoreList];
    [self searchOperationRefresh];
}

#pragma mark - 搜索操作刷新方法(针对子类刷新)
- (void)searchOperationRefresh {
    //子类实现逻辑
}

#pragma mark - 今日拜访数据
- (void)configInPlanStoresAllArray:(NSArray *)allArray planArray:(NSArray *)planArray {
    
    [self.filterArray addObjectsFromArray:allArray];
    
    [self.todayVisitStoreArray removeAllObjects];
    
    self.todayVisitStoreArray = [NSMutableArray arrayWithArray:planArray];
}

#pragma mark - 实际拜访轨迹所有门店
- (void)configAllStoreListWithFuncode:(NSString *)funCode withEmpId:(NSString *)empId withSearchId:(NSString *)search_objId
                     withIsSearchable:(BOOL)isSearchable {
    
    NSString *isFollowStore = [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore];
    NSString *visitTimeSort = [NSString stringNotNilWithValue:self.currentFuncs.opt.visitTimeSort];
    NSDictionary *plan_otherDic = @{kStoreDBOtherData_isFollowStore : isFollowStore,
                                    kStoreDBOtherData_storeClassCondition : [self getStoreClassFilterCondition],
                                    kStoreDBOtherData_visitTimeSort : visitTimeSort,
                                    kStoreDBOtherData_RouteID : @"0"};
    
    WSStoreAccessMode mode = [self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal;
    NSArray *allActualStoreArray = [[WSBaseStoreDBService shareInstance] queryAllStoreWithFuncCode:funCode
                                                                                             empId:empId
                                                                                              styp:self.currentFuncs.styp
                                                                                         searchStr:self.ownSearchBar.searchBar.text
                                                                                      search_objId:search_objId
                                                                                      isSearchable:isSearchable
                                                                                   storeAccessMode:mode
                                                                                            acvtId:nil
                                                                                 selectedQstValues:nil
                                                                                   rangeConditions:nil
                                                                                          distance:0
                                                                                        pageNumber:-1
                                                                                      distanceSort:self.currentFuncs.opt.distancesSort
                                                                                      otherDataDic:plan_otherDic
                                                                                     parentStoreFc:self.currentFuncs.opt.parentStoreFc];
    [self.actualVisitStoreArray removeAllObjects];    self.actualVisitStoreArray = [NSMutableArray arrayWithArray:allActualStoreArray];
}
#pragma mark-------LoadLazyView------
- (WSActionListView *)actionListView
{
    if (!_actionListView) {
        _actionListView = [[WSActionListView alloc] initWithFrame:CGRectMake(0, 0, 160, 0) actionDicInfoList:self.rightButtonInfoArray target:self];
    }
    
    return _actionListView;
}

@end
//===================================================================================================================================================
