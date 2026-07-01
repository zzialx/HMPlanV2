//
//  WSNewTodayVisitViewController.m
//  WinSFA
//
//  Created by sunhongfu on 2017/12/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNewTodayVisitViewController.h"
#import "WCOptionalSource.h"
#import "WSInoutStoreTable.h"
#import "WSRequestHelper.h"
#import "WSStoreDataProcessService.h"
#import "WSEMSDKManager.h"
#import "WSChartConst.h"
#import "WSChartViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WSStoreInfoMapViewController.h"
#import "WSSplitViewController.h"
#import "WSAcvtViewController.h"
#import "WSNextStepViewController.h"
#import "WSStoreDataService.h"
#import "WSStoreListDataSourceTool.h"

static NSString *identifierForCell = @"todayVisitAndAllStoreCell";
@interface WSNewTodayVisitViewController ()
{
    WSAcvtViewController *methodVisitController;//记录初始化弹出框popview时作为参数的那个acvtViewController
}
@property (nonatomic, strong) WSWorkFlowViewController *currentViewController;//当需要发起网络请求后才能跳转时,记录当时的要跳转的vc 请求成功后直接跳转
@end

@implementation WSNewTodayVisitViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init初始化

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil) return nil;
    return [self initWithFuncs:funcs Stores:nil subempStoreBean:nil];
}

-(instancetype)initWithFuncs:(WSFuncsBean*)funcs Stores:(NSArray *)stores
{
    if (funcs==nil||stores==nil) return nil;
    return [self initWithFuncs:funcs Stores:stores subempStoreBean:nil];
}

-(instancetype)initWithFuncs:(WSFuncsBean*)funcs SubempStoreBean:(WSSubempstoreBean *)subempStoreBean
{
    if (funcs == nil || subempStoreBean == nil) return nil;
    return [self initWithFuncs:funcs Stores:nil subempStoreBean:subempStoreBean];
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores subempStoreBean:(WSSubempstoreBean *)subempStoreBean
{
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.storeDataArray = [NSMutableArray array];
        if (stores.count) [self.storeDataArray addObjectsFromArray:stores];
        
        if (!stores && !subempStoreBean)
        {
            [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:self.currentFuncs.fv];
        }
    }
    return self;
}

#pragma mark - 视图创建完成后
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // SFA-13380
    [self clearAllNavBBI];
    [self addBackBarButtonItem];
    [self addRightButtonItem];
    if (!self.currentFuncs.opt.isGps || [self.currentFuncs.opt.isGps isEqualToString:@"Y"]) {
        __weak typeof(self)weakSelf  = self;
        [[WSStoreDataService shareInstance] checkAndUpdateStoreDistanceWithCurrentFuncs:self.currentFuncs andSubEmpId:self.subempStore.Id andObjectId:nil withBlock:^(WSLocationDescribe * locationDescribe,BOOL isNeedRefresh) {
            if (isNeedRefresh)  [weakSelf reloadStoreListData];
           
        }];
    }
    //说是防止刚开始进入页面取数据时候页面空白不好看  感觉没啥意义
    if (self.isLoaded == NO) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isLoaded == NO)
    {
        [self reloadStoreListData];
    }
    self.isLoaded = YES;
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
}
- (void)loadView
{
    [super loadView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStoreListData) name:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadStoreListData) name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStoreListData) name:ModifyStoreInfoNotification object:nil];
    [self initnavigatBarItem];
    [self initializationPrepareFuncBeans];
    [self createUI];
}

-(void)initnavigatBarItem
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = nil;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storeDataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WSNewTodayVisitAndAllStoreCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierForCell];
    if (cell == nil)
    {
        cell = [[WSNewTodayVisitAndAllStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierForCell cellWidth:tableView.width];
    }
    cell.delegate = self;
    
    WSStoreBean *storeBean = _storeDataArray[indexPath.row];
    
    [cell setStore:storeBean withOpt:self.currentFuncs.opt prepareFuncsBean:self.prepareFuncBean prepareAcvtBean:self.prepareStateAcvtBean];
    storeBean.hasGetStateData = YES;
    
    return cell;
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = nil;
    item = [self.storeDataArray objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[WSStoreBean class]])
    {
        WSStoreBean *rowStore = item;
        return [WSNewTodayVisitAndAllStoreCell  heightForRowWithStore:rowStore cellWidth:self.todayVisitTableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0f)];
    return headView;
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    WSStoreBean* store = nil;
    store = [self.storeDataArray objectAtIndex:indexPath.row];
    WSNewTodayVisitAndAllStoreCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([store.state isEqualToString:@"0"])
    {
        [self toastHUDTypeFaildWithString:NSLocalizedString(@"此门店为不活跃门店，请修改门店状态", nil)];
        return;
    }
    
    if (self.prepareFuncBean && [self.prepareFuncBean.required isEqualToString:@"R"])
    {
        WSNewStorePrepareState prepareState = cell.prepareState;
        if (prepareState == WSNewStorePrepareStateNotPrepare)
        {
            [self toastHUDTypeFaildWithString:NSLocalizedString(@"prepare_before_visit", nil)];
            return;
        }
    }
    [self gotoNextPageWithStoreBean:store];
}

#pragma mark - WSNewTodayVisitAndAllStoreCellDelegate
-(void)storePrepareWith:(WSStoreBean *)store withDate:(NSString *)date{
    
    if (self.visitTypeAcvtBean && self.visitTypeFuncBean)
    {
        [self showVisitTypeControllerWithStore:store date:date];
    }
    else
    {
        
        if ([self.prepareFuncBean.ds isEqualToString:@"acvt"]) {
            //联合利华有很多步准备  下一步
            [self showPrepareControllerWithStore:store date:date];
            
        }else {
            if (!self.prepareFuncBean) {
                return;
            }
            // SFA-23630  IOS：SFA立白【经销商】门店列表增加订单详情按钮入口，直接跳转到最近三次订单页面最近三次订单  --2018/9/21
            WCBaseViewController * con = [WCBaseViewController getControllerWithFuncsBean:self.prepareFuncBean realSubFuncsBean:nil];
            con.currentStore = store;
            //SFA-24647 (解决推到下个页面返回后下方tabBar消失不见的问题)
            con.hidesBottomBarWhenPushed = YES;
            if (self.ownParentViewController) {
                [self.ownParentViewController.navigationController pushViewController:con animated:YES];
            } else {
                [self.navigationController pushViewController:con animated:YES];
            }
        }

    }
}

- (void)showVisitTypeControllerWithStore:(WSStoreBean *)store date:(NSString *)date {
    if (!self.visitTypeFuncBean || !self.visitTypeAcvtBean) {
        return;
    }
    
    WSAcvtViewController *controller = [[WSAcvtViewController alloc] initWithAcvt:self.visitTypeAcvtBean Funcs:self.visitTypeFuncBean Store:store];
    controller.prepareVisitDate = date;
    
    methodVisitController = controller;
    
    WSPopViewController *popCon = [[WSPopViewController alloc] initWithContentViewController:controller];
    popCon.confirmSelector = @selector(executeUpload);
    popCon.popViewSize = CGSizeMake(INTERFACE_IS_PHONE ? 300 : 400, 300);
    popCon.delegate = self;
    
    if (IOS8_OR_LATER) {
        popCon.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }else {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        kApplicationWinddow.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    }
    
    [self presentViewController:popCon animated:YES completion:nil];
}

- (void)showPrepareControllerWithStore:(WSStoreBean *)store date:(NSString *)date {
    if (!self.prepareFuncBean) {
        return;
    }
    
    NSArray *prepareFuncsArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.prepareFuncBean.funcsArray withStore:methodVisitController.currentStore bizDate:methodVisitController.prepareVisitDate];
    if (!prepareFuncsArray.count) {
        return;
    }
    
    // 准备或修改准备
    NSString *className = [WSPlistHelper valueForKey:self.prepareFuncBean.fv withPlistName:kControllerMappingFileName];
    WSNextStepViewController *con = [[NSClassFromString(className) alloc] initWithFuncs:self.prepareFuncBean Store:store];
    con.currentVisitAction = [self getPrepareFuncBeanVisitActionByStore:store];
    con.prepareVisitDate = date;
    
    if (INTERFACE_IS_PAD)
    {
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:con];
        [con leftItemImage:@"icon_back" target:con action:@selector(backAction)];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        if (self.ownParentViewController)
        {
            self.ownParentViewController.hidesBottomBarWhenPushed = YES;
            [self.ownParentViewController.navigationController pushViewController:con animated:YES];
        }
        else
        {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:con animated:YES];
        }
    }
}

- (WSVisitStoreActionObject *)getPrepareFuncBeanVisitActionByStore:(WSStoreBean *)store {
    return [self getPrepareFuncBeanVisitActionByStore:store bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
}

- (WSVisitStoreActionObject *)getPrepareFuncBeanVisitActionByStore:(WSStoreBean *)store bizDate:(NSString *)bizDate {
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = store.Id;
    action.func_code = self.prepareFuncBean.fc;
    action.biz_date = bizDate;
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.prepareFuncBean.name;
    
    NSString *moduleFC;
    if ([self.currentVisitAction.module_fc length] > 0) {
        moduleFC = self.currentVisitAction.module_fc;
    }else if([self.subMenuFuncsCode length] > 0){
        moduleFC = self.subMenuFuncsCode;
    }else {
        moduleFC = self.currentFuncs.fc;
    }
    action.module_fc = moduleFC;
    
    if (self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        action.module_fc = self.currentStore.mappingStoreListFC;
    }
    action.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

//聊天按钮点击
-(void)chatButtonPressDown:(WSStoreBean*)store
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    NSString * storeimage = @"";
    if(store.storeImg && store.storeImg.length > 0) storeimage = [WSHttpURLHelper getImageCompleteURL:store.storeImg];
    
    NSString * storeName = @"";
    if(store.name && store.name.length > 0) storeName = store.name;
    
    NSString * storeID = @"";
    if(store.Id && store.Id.length > 0) storeID = store.Id;
    
    NSString * local_ImageID = @"";
    if(store.local_ImageID && store.local_ImageID.length>0) local_ImageID = store.local_ImageID;
    
    NSString * nickname = [[WSEMSDKManager sharedInstance]getChatNickName];
    if(nickname == nil || nickname.length <= 0) nickname = @"";
    
    NSString * headImageUrl = [[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
    if(headImageUrl == nil || headImageUrl.length <= 0) headImageUrl = @"";
    
    //取得该商店对应业代聊天账号
    WSUserInfo * storeUserInfo = [[WSEMSDKManager sharedInstance]getUserInfoWithStoreID:store.Id andEmpId:store.empId];
    NSString * conversation = storeUserInfo.wschatID;
    
    NSString * toChartHeadURL = @"";
    if(storeUserInfo.wsheadImageURL && storeUserInfo.wsheadImageURL.length > 0) toChartHeadURL = [WSHttpURLHelper getImageCompleteURL:storeUserInfo.wsheadImageURL];
    
    NSString * toChartName = @"";
    if(storeUserInfo.wsname && storeUserInfo.wsname.length > 0) toChartName=storeUserInfo.wsname;
    
    NSMutableDictionary * extDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:storeimage,WS_MSG_toStoreUrl,storeID,WS_MSG_toStoreId,storeName,WS_MSG_toStoreName,nickname,WS_MSG_fromChatrealName,headImageUrl,WS_MSG_fromChatHeadImgUrl,toChartHeadURL,WS_MSG_toChatHeadImgUrl,toChartName,WS_MSG_toChatrealName, nil];
    
    NSString * jsonStr = [extDic JSONString];
    [dict setObject:jsonStr forKey:WS_MSG_protyKey];
    
    WSChartViewController * wfvc = [[WSChartViewController alloc]initWithConversationChatter:conversation conversationType:EMConversationTypeChat extertDic:dict];
    wfvc.store = store;
    wfvc.navigationItem.title = store.name;
    wfvc.hidesBottomBarWhenPushed = YES;
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:wfvc animated:YES];
}

#pragma mark - WSPopViewControllerDelegate
- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm
{
    if (isConfirm && controller.contentViewController == methodVisitController)
    {
        NSArray *prepareFuncsArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.prepareFuncBean.funcsArray withStore:methodVisitController.currentStore bizDate:methodVisitController.prepareVisitDate];
        
        if ([prepareFuncsArray count] > 0)
        {
            [self showPrepareControllerWithStore:methodVisitController.currentStore date:methodVisitController.prepareVisitDate];
        }
    }
    
    if (isConfirm)
    {
        [self reloadStoreListData];
    }
    methodVisitController = nil;
}

#pragma mark - pravite
//初始化UI
- (void)createUI
{
    self.todayVisitTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _todayVisitTableView.delegate = self;
    _todayVisitTableView.dataSource = self;
    _todayVisitTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _todayVisitTableView.backgroundColor = [UIColor whiteColor];
    if (INTERFACE_IS_PAD)
    {
        _todayVisitTableView.backgroundColor = RGBCOLOR(246, 246, 246);
    }
    _todayVisitTableView.backgroundView = nil;
    _todayVisitTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if ([_todayVisitTableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        _todayVisitTableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
#endif
    [self.view addSubview: _todayVisitTableView];
}

- (void)initializationPrepareFuncBeans
{
    //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
    if (!self.prepareFuncBean && [self.currentFuncs.opt.contextMenu length] > 0) {
        WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *funcsBean = [funcsArray getHideFuncsBeanWithFC:self.currentFuncs.opt.contextMenu];
        self.prepareFuncBean = funcsBean;
    }
    
    if (self.prepareFuncBean)
    {
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        //回显准备状态的调查问卷
        if (!self.prepareStateAcvtBean)
        {
            //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
            self.prepareStateAcvtBean = [service queryAcvtByFilter:self.prepareFuncBean.filter acvtCode:nil];
        }
        
        //回显拜访方式的调查问卷
        //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
        if (!self.visitTypeFuncBean)
        {
            WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
            NSArray *subArray = [funcsArray getHideSubFuncBeanArrayWithPK:self.prepareFuncBean.pk];
            for (WSFuncsBean *funcsBean in subArray) {
                if ([funcsBean.opt.isTipsMenu isEqualToString:@"1"])
                {
                    self.visitTypeFuncBean = funcsBean;
                    break;
                }
            }
            
            if (self.visitTypeFuncBean)
            {
                self.visitTypeAcvtBean = [service queryAcvtByFilter:self.visitTypeFuncBean.filter acvtCode:nil];
            }
        }
    }
}

- (void)addBackBarButtonItem {
    
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    
    if ([self navigationController].viewControllers.count > 1)
    {
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backBBIClicked)];
        [barButtonItems addObject:backBBI];
        
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
    }
}

- (void)backBBIClicked
{
    [self backToParent];
}

- (void)clearAllNavBBI
{
    [self getNavigationItem].leftBarButtonItems = nil;
    [self getNavigationItem].rightBarButtonItems = nil;
    [self getNavigationItem].titleView = nil;
}

- (void)addRightButtonItem
{
    if ([self.currentFuncs.opt.isJumpCallPlan length] > 0)
    {
        UIBarButtonItem *rightBN = [[UIBarButtonItem alloc] initWithImage:[UIImage scaledImageForName:@"icon_callplan" ofType:@"png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
        [self getNavigationItem].rightBarButtonItems = @[rightBN];
    }
}

- (void)rightBarButtonClicked
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *jumpFuncBean = [funcsBeanArray getFuncsBeanWithFC:self.currentFuncs.opt.isJumpCallPlan];
    if (jumpFuncBean)
    {
        NSString *className = [WSPlistHelper valueForKey:jumpFuncBean.fv withPlistName:kControllerMappingFileName];
        WCBaseViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:jumpFuncBean];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -  网络请求 或者 数据库 操作数据
#pragma mark - 数据库获得数据
- (void)reloadStoreListData
{
    [self.storeDataArray removeAllObjects];
    //获得去重和排序后直接使用的数据
    [self.storeDataArray addObjectsFromArray: [WSStoreListDataSourceTool initStoreListDataSourceWithFuncBean:self.currentFuncs withSubempstoreBean:self.subempStore]];
    
    //visitcount已经离店完成拜访的个数
    NSInteger visitcount = [WSNewStoreListTool getCount:self.storeDataArray withVisitActionStatus:ActionDone] ;
    /*(已拜访或拜访中的门店/计划内的门店)   和安卓保持一致*/
    //inplanCount计划内的个数
    NSInteger inplanCount = [WSStoreListDataSourceTool getInPlanNumber];
    
    /*刷新title*/
    NSString *title = [NSString stringWithFormat:@"%@(%lu/%ld)", self.currentFuncs.name, (unsigned long)visitcount, (long)inplanCount];
    [self refreshControllerTitle:title];
    [self.todayVisitTableView reloadData];
    
    if ([self.storeDataArray count] == 0)
    {
        if (!self.empty)
        {
            [self addEmptyView];
        }
    }
    else
    {
        [self.empty removeFromSuperview];
    }
}

#pragma mark - 计划内网络数据请求开始  随访时计划内需要实时获取数据
-(void)startUpdata:(WSStoreBean*)store
{
    [self querying_messageTips];
    //发起网络请求
    [WSStoreListDataSourceTool requestInPlanWithStoreBean:store successCallBack:^(NSDictionary *uploadState) {
        
        NSDictionary* vflag=[[uploadState objectForKey: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME] firstObject];
        /*判断代表是否进店,没进店提示后return 不再进行任何操作*/
        if([vflag objectForKey:@"vflag"])
        {
            NSNumber* vflagNumber=[vflag objectForKey:@"vflag"];
            if(vflagNumber.integerValue==0)
            {
                [self toastHUDTypeFaildWithString:@"代表未进店"];
                return;
            }
        }
        
        /*如果是随访的下属的店 重置门店的信息*/
        if (self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp)
        {
            [self.currentStore reSetStore:uploadState Key: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
        }
        
        NSDictionary *storeDicInfo = [self getStoreDicInfoWithUploadState:uploadState];
        
        if ([[storeDicInfo allKeys] count] > 0)
        {
            /*处理更新计划内门店数据库中的相关数据*/
            [WSNewStoreListTool saveInPlanStoreRequestFlagWithSubempStore:self.subempStore withCurrentStore:self.currentStore withStoreDicInfo:storeDicInfo];
        }
        else
        {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"提示！" tips:@"返回门店数据为空!" tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.50f];
            return;
        }
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self gotoWorkFlowController:self.currentViewController];
    } failCallback:^(NSString *error) {
        
        [self toastHUDTypeFaildWithString:error];
    }];
}

#pragma mark - 计划外网络请求数据
-(void)startUpdataOutPlan:(WSStoreBean*)store
{
    [self querying_messageTips];
    /*计划外网络请求*/
    [WSStoreListDataSourceTool requestOutPlanWithStoreBean:store successCallBack:^(NSDictionary *uploadState) {
        
        NSDictionary *storeDicInfo = [self getStoreDicInfoWithUploadState:uploadState];
        if(self.currentStore != nil)
        {
            [self.currentStore reSetStore:uploadState Key:[self getOutPlanObjID]];
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
        }
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [self gotoWorkFlowController:self.currentViewController];
        
    } failCallback:^(NSString *error) {
        
        [self toastHUDTypeFaildWithString:error];
    }];
}

- (NSDictionary *)getStoreDicInfoWithUploadState:(NSDictionary *)uploadState
{
    NSObject *tmpObject = uploadState[ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
    NSDictionary *storeDicInfo = nil;
    if ([tmpObject isKindOfClass:[NSDictionary class]])
    {
        storeDicInfo = (NSDictionary *)tmpObject;
    }
    else if ([tmpObject isKindOfClass:[NSArray class]])
    {
        storeDicInfo = [(NSArray *)tmpObject firstObject];
    }
    return storeDicInfo;
}

- (NSString *)getOutPlanObjID
{
    // 今日拜访模块  计划外门店请求数据统一用 ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME 节点名
    return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
}

#pragma mark - 跳转下级页面
- (void)gotoNextPageWithStoreBean:(WSStoreBean*)store
{
    WSFuncsBean *fb = nil;
    WSFuncsBean *subMenuFB = nil;
    //store.plan 是否是计划内
    if (store.plan)
    {
        /*! 中粮特有
         *  是否可以重复访店，默认和 R 为可以，N 为不可以
         */
        if (self.currentFuncs.repeatvisit != nil && [self.currentFuncs.repeatvisit isEqualToString:@"N"])
        {
            if ([WSNewStoreListTool isVisitedStore:store withCurrentFuncs:self.currentFuncs])
            {
                NSString *cannotRepeatVisit = NSLocalizedString(@"该店已完成今日稽核数据提报，您不能再进店查看或修改。", nil);
                [self toastHUDTypeFaildWithString:cannotRepeatVisit];
                return;
            }
        }
        fb = self.currentFuncs;
    }
    else
    {
        //由fc取得store的 fb 递归方法
        fb = [WSNewStoreListTool getSelectedOutPlanFuncsBeanWithStore:store];
        subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:fb];
    }
    
    //判断是否有正在拜访中没离店的
    if (![WSNewStoreListTool anyStoreHasNotLeave:store andModuleFC:subMenuFB.fc ? subMenuFB.fc : fb.fc withCurrentFuncs:self.currentFuncs]) return;
    
    //获得要跳转的VC
    WCBaseViewController *vc = (WCBaseViewController *)[self generateNextVCWithFuncsBean:self.currentFuncs store:store isSelf:YES];
    
    if (store.plan)
    {
        //计划内随访时需要实时请求数据
        if (store.storeAccessMode == WSStoreAccessModeSubEmp || (store.noteName && [store.noteName rangeOfString:@"subemp"].location != NSNotFound))
        {
            [self startUpdata:store];
            return;
        }
    }
    else
    {
        //如果没有请求过数据,就要请求完数据再跳转
        if (![WSNewStoreListTool isOutPlanRequestWithSubempstoreBean:self.subempStore withCurrentStore:self.currentStore])
        {
            [self startUpdataOutPlan:store];
            return;
        }
    }
    //不需要请求数据的话 直接跳转
    [self gotoWorkFlowController:vc];
}

/*
 获得要跳转的VC
 params
 isSelf 是否是本类自己调用的
 */
- (UIViewController *)generateNextVCWithFuncsBean:(WSFuncsBean *)fb   store:(WSStoreBean*)store isSelf:(BOOL)isSelf
{
    self.currentStore = store;
    self.currentFuncs = fb;
    WSWorkFlowViewController *wfvc;
    WSFuncsBean *subMenuFB;
    //设置拜访节点
    NSLog(@"==>>>>> %@",self.currentVisitAction);
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    NSString *entryid = [store isKindOfClass:[WSStoreBean class]] ? store.Id:@"";
    action.store_id = entryid/*self.currentStore.Id*/;
    action.func_code = fb.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.currentFuncs.name;
    action.module_fc = action.func_code;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    if (isSelf)
    {
        //如果是计划内或者isIntentToStore不等于Y的时候初始化一样的VC
        if (store.plan || ![fb.opt.isIntentToStore isEqualToString:@"Y"])
        {
            wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:store subEmpStore:self.subempStore ? self.subempStore :nil];
        }
        else
        {
            //设置访问节点
            if ([fb.opt.isIntentToStore isEqualToString:@"Y"])
            {
                subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:fb];
                action.module_fc = subMenuFB.fc ? subMenuFB.fc : fb.fc;
                WSFuncsBean* nextfb = [fb.funcsArray objectAtIndex:0];
                NSString *className = [WSPlistHelper valueForKey:nextfb.fv withPlistName:kControllerMappingFileName];
                UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:nextfb Store:self.currentStore];
                vc.currentVisitAction = action;
                if ([vc isKindOfClass:[WSWorkFlowViewController class]])
                {
                    wfvc = (WSWorkFlowViewController *)vc;
                    wfvc.moduleFC = action.func_code;
                }
                //Y的时候不需要设置 title input_reflect_code等的值
                return vc;
            }
        }
    }
    else
    {
        wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:store];
    }
    
    //当前列表计划内和superBarVC里调用的时候都设置的参数
    if ((isSelf && store.plan) || !isSelf)
    {
        wfvc.input_reflect_code = action.func_code;;
        self.currentViewController = wfvc;
    }
    
    //Add title
    //当前列表计划计划内/计划外/superBarVC里都设置的
    wfvc.title = store.name;
    wfvc.currentVisitAction = action;
    wfvc.moduleFC = action.func_code;
    LogInfo(@"Going to class WSWorkFlowViewController");
    
    return wfvc;
}

- (void)gotoWorkFlowController:(WCBaseViewController *)wfvc {
    
    LogInfo(@"Going to class WSWorkFlowViewController");
    
    if (INTERFACE_IS_PAD)
    {
        [self showWorkFlowInSplitViewController:wfvc];
    }
    else
    {
        wfvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}

- (void)showWorkFlowInSplitViewController:(WCBaseViewController *)controller
{
    WCNavigationController *workFlowNav = [[WCNavigationController alloc] initWithRootViewController:controller];
    
    WCBaseViewController *rightCon = nil;
    
    if ([controller isKindOfClass:[WSWorkFlowViewController class]])
    {
        WSWorkFlowViewController *workFlowCon = (WSWorkFlowViewController *)controller;
        rightCon = [workFlowCon getDefaultShowController];
    }
    
    if (!rightCon)
    {
        rightCon = [[WSStoreInfoMapViewController alloc] init];
    }
    
    WCNavigationController *rightNav = [[WCNavigationController alloc] initWithRootViewController:rightCon];
    
    [controller leftItemImage:@"icon_back" target:controller action:@selector(backAction)];
    
    WSSplitViewController *split = [[WSSplitViewController alloc] initWithLeftController:workFlowNav rightController:rightNav];
    CGFloat width = SPLITVIEW_LEFT_DEFAULT_WIDTH;
    
    if (controller.currentFuncs.wfcol > 0)
    {
        width = (CGFloat)controller.currentFuncs.wfcol;
    }
    split.leftControllerWidth = width;
    split.separatorLineColor = [UIColor colorWithHexString:@"#cdcdcd"];
    
    controller.wsSplitController = split;
    rightCon.wsSplitController = split;
    
    [self presentViewController:split animated:YES completion:nil];
}

#pragma mark - toast
- (void)toastHUDTypeFaildWithString:(NSString *)str
{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
