//
//  WSStoreListBaseViewController.m
//  WinSFA
//
//  Created by yang on 17/1/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreListBaseViewController.h"
#import "WSInoutStoreTable.h"
#import "WSDistStore.h"
#import "WSVisitStoreActionTable.h"
#import "WSFuncsBean_opt.h"
#import "WSStoreInfoBeanArray.h"
#import "WSFuncsBeanArray.h"
#import "WSNavigationBar.h"
#import "WSVisitPlanArray.h"
#import "WSStoreInfoMapViewController.h"
#import "WSSplitViewController.h"
#import "WSNextStepViewController.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtViewController.h"
#import "WSPopViewController.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSWorkFlowViewController.h"
#import "WSBaseStoreDBService.h"
#import "WSStoreDataService.h"
#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSNextStepFuncsViewController.h"
#import "WSRequestHelper.h"
#import "WSBaseStoreTable.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSConfigParamHelper.h"
#import "MJRefresh.h"
#import "WSCustomerQueryViewController.h"
#import "WSRouteStoreTableViewCell.h"
#import "WinJSBridgeViewController.h"
#import "WSStoreDataProcessService.h"

#define FOLLOW_NOTIFY @"follow_notify"
//===================================================================================================================================================

@interface WSStoreListBaseViewController () <WSPopViewControllerDelegate, WSNewTodayVisitAndAllStoreCellDelegate> {
    
    WSAcvtViewController *methodVisitController;
}

@property (nonatomic, assign) BOOL refreshLocationTag;                                      //返回当前页面刷新定位的通知标示
@property (nonatomic, strong) NSIndexPath *storeStateindexPath;                             //门店状态路径索引
@property (nonatomic, strong) WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService;

@end
//===================================================================================================================================================

@implementation WSStoreListBaseViewController

#pragma mark - 获取storeArray方法
- (NSMutableArray *)storeArray {
    
    if (!_storeArray) {
        _storeArray = [[NSMutableArray alloc] init];
    }
    return _storeArray;
}

#pragma mark - 获取foldStateDic方法
- (NSMutableDictionary *)foldStateDic {
    
    if (!_foldStateDic) {
        _foldStateDic = [[NSMutableDictionary alloc] init];
    }
    return _foldStateDic;
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStoreList) name:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshLocationAndStoreList) name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStoreList) name:ModifyStoreInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStoreList) name:CHANGE_STOREICON_RELOAD_STORE_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLocationAndStoreList) name:DOWN_OR_ClEAR_RELOAD_STORE_LIST object:nil];

    [self initializationPrepareFuncBeans];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    BOOL isAdditionalData = [self configurationRequestAdditionalData];
    if (!isAdditionalData) {
        [self myViewWillAppear];
    }
}

#pragma mark - 重写dealloc方法
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 重载门店列表方法
- (void)reloadStoreList {
    
    //子类重写实现业务逻辑
}

#pragma mark - 拉取数据完成方法
- (void)pullRefreshEnd {
    
    [self.tableView.mj_header endRefreshing];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
}

#pragma mark - 我的视图即将显示方法
- (void)myViewWillAppear {
    
    [self needGps];
}

#pragma mark - 定位方法
- (void)needGps {
    
    if (!self.currentFuncs.opt.isGps || [self.currentFuncs.opt.isGps isEqualToString:@"Y"]) {
        
        NSString *objId;
        if ([self isKindOfClass:[WSCustomerQueryViewController class]]) {
            objId = [(WSCustomerQueryViewController *)self getObjIDToStoreList];
        }
        
        __weak __typeof__(self) weakSelf = self;
        [[WSStoreDataService shareInstance] checkAndUpdateStoreDistanceWithCurrentFuncs:self.currentFuncs andSubEmpId:self.subempStore.Id andObjectId:objId
                                                                              withBlock:^(WSLocationDescribe *locationDescribe, BOOL isNeedRefresh) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.locationDescribe = locationDescribe;
            [strongSelf pullRefreshEnd];
            [strongSelf reloadStoreList];
            
            if ([strongSelf respondsToSelector:@selector(resetLocation:locality:subLocality:)]) {
                [strongSelf resetLocation:locationDescribe.provinceName locality:locationDescribe.cityName subLocality:locationDescribe.subLocality];
            }
        }];
        
        return;
    }
        
    [self pullRefreshEnd];
    [self reloadStoreList];
}

#pragma mark - 配置请求额外数据方法
- (BOOL)configurationRequestAdditionalData {
    
    if ([self.currentFuncs.opt.refreshNodeName isEqualToString:kWinStoreRouteInfoNodeObjId]) {
        
        [self loadRequestStoreRouteInfo];
        return YES;
    }
    return NO;
}

#pragma mark - 请求门店路线信息方法(opt-refreshNodeName配置storesRouteActivityInfos触发)
- (void)loadRequestStoreRouteInfo {
    
    [SVProgressHUD showLoading];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:@"bizDate"];
    [parameters setObject:kWinStoreRouteInfoNodeObjId forKey:@"objId"];
    
    __weak typeof(self) weakSelf = self;
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSDictionary *responseDic = [response jsonResponse];
        NSArray *responseArray = [responseDic objectForKey:kWinStoreRouteInfoNodeObjId];
        NSDictionary *resultDic = responseArray.firstObject;
        NSArray *storesRouteNamesList = [resultDic objectForKey:kWinStoreRouteResponseObjId];
        
        NSMutableArray *storeArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *storesRouteNamesDic in storesRouteNamesList) {
            
            [storeArr addObject:@{@"store_id" : [NSString stringWithFormat:@"%@", [storesRouteNamesDic objectForKey:@"sid"]],
                                  @"item1" : [NSString stringWithFormat:@"%@", [storesRouteNamesDic objectForKey:@"routeName"]],
                                  @"type" : kWinStoreRouteResponseObjId,
                                  @"emp_id" : [NSString stringWithFormat:@"%@",[storesRouteNamesDic objectForKey:@"empId"]]
                                  }];
        }
        if (storeArr.count > 0) {
            WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
            [service replaceToTableWithDicts:storeArr FromNode:kWinStoreRouteResponseObjId hasNewData:YES];
        }
        LogInfo(@"storesRouteActivityInfos response:%@",resultDic);
        [WSStoreDataProcessService processStoreInfoDataToDbWithStoresInfo:resultDic storeID:nil genId:nil isRemoteSearch:NO];
        
        [SVProgressHUD HideLoading];
        [strongSelf myViewWillAppear];
    }
                                                      failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [SVProgressHUD HideLoading];
        [strongSelf myViewWillAppear];
        
    }];
}
    
    










//下载或清除城市列表后，返回到当前页面再刷新的标识符 yes 需要刷新
- (void)refreshLocationAndStoreList{
    self.refreshLocationTag = YES;
    [self reloadStoreList];
}
#pragma makr - private method

- (void)initializationPrepareFuncBeans
{
    //兼容联合利华旧逻辑
    for (WSFuncsBean * bean in self.currentFuncs.funcsArray) {
        if ([bean.fv isEqualToString:UNILEVERREADYCALLPLAN_FV]) {
            self.prepareFuncBean = bean;
            break;
        }
    }
    
    //兼容联合利华旧逻辑
    if (!self.prepareFuncBean && self.subMenuFuncsBean) {
        for (WSFuncsBean *bean in self.subMenuFuncsBean.funcsArray) {
            if ([bean.fv isEqualToString:UNILEVERREADYCALLPLAN_FV]) {
                self.prepareFuncBean = bean;
                break;
            }
        }
    }
    
    
    //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
    if (!self.prepareFuncBean && [self.currentFuncs.opt.contextMenu length] > 0) {
        WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *funcsBean = [funcsArray getHideFuncsBeanWithFC:self.currentFuncs.opt.contextMenu];
        self.prepareFuncBean = funcsBean;
    }
    
    
    if (self.prepareFuncBean) {
        
        WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
        
        //回显准备状态的调查问卷
        //兼容联合利华旧逻辑
        self.prepareStateAcvtBean = [service queryAcvtWithAcvtCode:STORE_PREPARE_ACVT_CODE];
        if (!self.prepareStateAcvtBean) {
            //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
            self.prepareStateAcvtBean = [service queryAcvtByFilter:self.prepareFuncBean.filter acvtCode:nil];
        }
        
        //回显拜访方式的调查问卷
        //兼容联合利华旧逻辑
        WSAcvtBean *acvt = [service queryAcvtWithAcvtCode:VISIT_TYPE_ACVT_CODE];
        self.visitTypeAcvtBean = acvt;
        if (acvt) {
            
            for (WSFuncsBean *funcsBean in self.prepareFuncBean.funcsArray) {
                if ([funcsBean.filter isEqualToString:acvt.typ]) {
                    self.visitTypeFuncBean = funcsBean;
                    break;
                }
            }
            
        }
        
        //新逻辑见http://192.168.1.15/jira/browse/MSTD-4015
        if (!self.visitTypeFuncBean) {
            
            WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
            NSArray *subArray = [funcsArray getHideSubFuncBeanArrayWithPK:self.prepareFuncBean.pk];
            for (WSFuncsBean *funcsBean in subArray) {
                if ([funcsBean.opt.isTipsMenu isEqualToString:@"1"]) {
                    self.visitTypeFuncBean = funcsBean;
                    break;
                }
            }
            
            if (self.visitTypeFuncBean) {
                self.visitTypeAcvtBean = [service queryAcvtByFilter:self.visitTypeFuncBean.filter acvtCode:nil];
            }
        }
    }
}

#pragma mark - public method
- (void)addToolBar {
}

#pragma mar 在次判断是否访问过门店
-(void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store
{
    if (self.currentVisitAction) {
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:self.currentVisitAction.module_fc andParamType:EParameterType_ParentFC]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:self.currentVisitAction.module_fc andParamType:EParameterType_ParentFC])
            {
                UIImage *image = [UIImage imageNamed:@"visit_doing.png"];
                cell.imageView.image = image;
                return;
            }else{
                UIImage *image = [UIImage imageNamed:@"visit_done.png"];
                cell.imageView.image = image;
                return;
            }
        }
    }
    
    UIImage* image = [UIImage imageNamed:@"visit_not_start.png"];
    cell.imageView.image = image;
    
    
}


- (void)setAccessFlag:(UITableViewCell *)cell Store:(WSStoreBean *)store andParentFc:(NSString *)module_fc {
    return [self setAccessFlag:cell Store:store andParentFc:module_fc action:nil];
}


- (NSString *)getStoreVisitStatusWith:(WSStoreBean *)store andParentFc:(NSString *)module_fc {
    return [self getStoreVisitStatusWith:store andParentFc:module_fc action:nil];
}

-(void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store andParentFc:(NSString *)module_fc action:(WSVisitStoreActionObject *)action
{
    if (module_fc) {
        
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC])
            {
                UIImage *image = [UIImage imageNamed:@"visit_doing.png"];
                cell.imageView.image = image;
                return;
            }else{
                UIImage *image = [UIImage imageNamed:@"visit_done.png"];
                cell.imageView.image = image;
                return;
            }
        }
        return;
        
    }
    
    if (action) {
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
        
        if ([status isEqualToString:ActionDone]) {
            UIImage *image = [UIImage imageNamed:@"visit_done.png"];
            cell.imageView.image = image;
            return;
        }else if ([status isEqualToString:ActionWorking]) {
            UIImage *image = [UIImage imageNamed:@"visit_doing.png"];
            cell.imageView.image = image;
            return;
        }
    }
    
    UIImage* image = [UIImage imageNamed:@"visit_not_start.png"];
    cell.imageView.image = image;
}

- (NSString *)getStoreVisitStatusWith:(WSStoreBean *)store andParentFc:(NSString *)module_fc action:(WSVisitStoreActionObject *)action {
    
    NSString *resultStatus = @"0";
    if (module_fc) {
        
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC])
            {
                resultStatus = @"2";
                
            }else{
                resultStatus = @"1";            }
        }
        
    }
    
    if (action) {
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
        
        resultStatus = status;
    }
    return resultStatus;
}


- (NSString *)getStoreVisitStatusWith:(WSStoreBean *)store isNotUseParentFC:(BOOL)isNotUseParentFC {
    NSString *visitStatus = @"0";
    if (isNotUseParentFC) {
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:nil andParamType:EParameterType_NULL]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:nil andParamType:EParameterType_NULL])
            {
                visitStatus = @"2";
            }else{
                visitStatus = @"1";
            }
        }
    }
    return visitStatus;
}

- (void)setAccessFlag:(UITableViewCell *)cell Store:(WSStoreBean *)store isNotUseParentFC:(BOOL)isNotUseParentFC{
    
    if (isNotUseParentFC) {
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:nil andParamType:EParameterType_NULL]) {
            
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:nil andParamType:EParameterType_NULL])
            {
                UIImage *image = [UIImage imageNamed:@"visit_doing.png"];
                cell.imageView.image = image;
                return;
            }else{
                UIImage *image = [UIImage imageNamed:@"visit_done.png"];
                cell.imageView.image = image;
                return;
            }
        }
    }
    UIImage* image = [UIImage imageNamed:@"visit_not_start.png"];
    cell.imageView.image = image;
    
}
- (NSString *)getActionStateByStore:(WSStoreBean*)store andmodule_fc:(NSString *)module_fc
{
    if (module_fc) {
        if ([[WSInoutStoreTable sharedTable] isEnterStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC])
        {
            if(![[WSInoutStoreTable sharedTable] isLeaveStore:store andOtherParam:module_fc andParamType:EParameterType_ParentFC])
            {
                return ActionWorking;
            }
            else
            {
                return ActionDone;
            }
        }
    }
    return ActionNotStart;
    
}

- (NSInteger)getCount:(NSArray *)storeListArray withVisitActionStatus:(VisitActionStatus)visitActionStatus
{
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"self.actionState==%@ || self.optName CONTAINS %@",visitActionStatus,@"今日已访"];

    NSArray* filterArray = [storeListArray filteredArrayUsingPredicate:pre];
    return [filterArray count];
}

- (NSArray *)sortStoreListArrayByVisitAction:(NSArray *)storeListArray
{
    if (!storeListArray || [storeListArray count] == 0) {
        return storeListArray;
    }
    
    for (id obj in storeListArray) {
        if ([obj isKindOfClass:[WSStoreBean class]]) {
            WSStoreBean *storeBean = (WSStoreBean *)obj;
            if (![self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"])
            {
                NSString *fc = self.currentFuncs.fc;
                
                if (self.subMenuFuncsCode != nil && self.subMenuFuncsCode.length > 0) {
                    fc = self.subMenuFuncsCode;
                }
                /*针对即拜访的门店加入今日拜访*/
                if (storeBean.mappingStoreListFV && [storeBean.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
                    fc = storeBean.mappingStoreListFC;
                }
                
                storeBean.actionState = [self getActionStateByStore:storeBean andmodule_fc:fc];
            }
            else
            {
                VisitActionStatus status = ActionNotStart;
                if (self.currentVisitAction) {
                    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
                    action.parent_action_id = self.currentVisitAction.ID;
                    action.store_id = storeBean.Id;
                    action.func_code = self.currentFuncs.fc;
                    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
                    action.is_required = self.currentFuncs.required;
                    action.title = self.currentFuncs.name;
                    if (self.currentVisitAction
                        && self.currentVisitAction.module_fc
                        && [self.currentVisitAction.module_fc length] > 0) {
                        
                        action.module_fc = self.currentVisitAction.module_fc;
                    }else{
                        
                        action.module_fc = action.func_code;
                    }
                    /*针对即拜访的门店加入今日拜访*/
                    if (storeBean.mappingStoreListFV && [storeBean.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
                        action.module_fc = storeBean.mappingStoreListFC;
                    }
                    status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
                }
                storeBean.actionState = status;
            }
        }
        else if ([obj isKindOfClass:[WSSubempstoreBean class]])
        {
            WSSubempstoreBean *subempStoreBean = (WSSubempstoreBean *)obj;
            
            WSStoreBean *storeBean = [[WSStoreBean alloc]init];
            storeBean.Id  = subempStoreBean.Id;
            storeBean.styp  = subempStoreBean.styp;
            storeBean.acvtsArray =subempStoreBean.acvtArray;
            storeBean.name = [NSString stringWithFormat:@"%@%@",subempStoreBean.cod,subempStoreBean.name];
            
            subempStoreBean.actionState = ActionNotStart;
            if (self.currentVisitAction) {
                subempStoreBean.actionState = [self getActionStateByStore:storeBean andmodule_fc:self.currentVisitAction.module_fc];
            }
            
        }
        
    }
    
    storeListArray = [storeListArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WSStoreBean *store1 = (WSStoreBean *)obj1;
        WSStoreBean *store2 = (WSStoreBean *)obj2;
        if ([store1.actionState isEqualToString:ActionDone]) {
            return NSOrderedDescending;
        }
        if ([store2.actionState isEqualToString:ActionDone]) {
            
            
            return NSOrderedAscending;
        }
        
        return (-1)*[store1.actionState compare:store2.actionState];
    }];
    
    return storeListArray;
    
}


/*得到拜访过或者拜访中的显示在计划内门店的fc，因测试环境有限，有缺失。需添加可参考 - (NSArray *)sortStoreListArrayByVisitAction:(NSArray *)storeListArray storeFromFuncs:(WSFuncsBean *)storeFuncs andFuncsBeanDic:(NSDictionary *) fcBeanDic 方法*/
- (NSString *)getFuncCodeWithFuncBean:(WSFuncsBean *)storeFuncs  andFunBeanDic:(NSDictionary *)fcBeanDic{
    
    WSFuncsBean *fb = nil;
    if (storeFuncs) {
        fb = storeFuncs;
    }else {
        
        if ([fcBeanDic objectForKey:@"TAB_V21002"]){
            /**
             * TAB_V21002 实时搜索计划内，外店
             */
            fb = [fcBeanDic objectForKey:@"TAB_V21002"];
            
        }else if ([fcBeanDic objectForKey:@"TAB_V11001"]){
            /**
             *  通过沟通后了解到：一般来说实时搜索计划外和计划外不会同时存在。同时存在时讨论下处理方案。
             */
            fb = [fcBeanDic objectForKey:@"TAB_V11001"];
            
        }
        else if ([fcBeanDic objectForKey:@"TAB_V13001"]){
            /**
             *  随访计划外实时搜索。
             */
            fb = [fcBeanDic objectForKey:@"TAB_V13001"];
            
        }else{
            fb = [fcBeanDic objectForKey:@"TAB_V2002"];
        }
    }
    
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:fb];
    if (subMenuFB) {
        fb = subMenuFB;
    }
    
    return fb.fc;
}


-(BOOL)anyStoreHasNotLeave:(WSStoreBean*)aStore andModuleFC:(NSString *)store_moduleFC {
    
    if (![WSConfigParamHelper getIsCheckLeaveStore]) {
        return YES;
    }
    
    WSInoutStoreObject *inoutStoreObject = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    
    //required校验其他模块是否有未离的店
    BOOL isHaveStoreNotLeave = YES;
    if (inoutStoreObject ) {
        if (![inoutStoreObject.needtip isEqualToString:@"null"] ) {
            // 根据渠道过滤不校验的门店， needtip 记录了渠道条件的判断
            isHaveStoreNotLeave = YES;
        }
        //同一个模块，不同门店
        else if ([inoutStoreObject.modulefc isEqualToString:store_moduleFC]) {
            if (![inoutStoreObject.store_id isEqualToString:aStore.Id]) {
                isHaveStoreNotLeave = NO;
            }
        }else{
            
            //不同模块
            // MSTD-7672 winSFA标准产品【ios】 —— 工作→市场检查→地图：从地图上选择一家门店，并进店拜访，然后返回至地图页面，再次点击该家门店进入时，提示：“该家门店未离店”。预期：一家门店开始拜访后，从地图页面再次进入该门店时不应出现未离店提示。 需要问一下支庆,是不是这个控制状态
//            if (![self.currentFuncs.required isEqualToString:@"E"]) {
//                isHaveStoreNotLeave = NO;
//            }
            //parentStoreFc有值的话不可跳转，没值就可以跳转
            if ([self.currentFuncs.opt.parentStoreFc isEqualToString:@""]||self.currentFuncs.opt.parentStoreFc == nil) {
                if (![inoutStoreObject.store_id isEqualToString:aStore.Id]) {
                    isHaveStoreNotLeave = NO;
                }
            }else{
                isHaveStoreNotLeave = NO;
            }
            
        }
    }
    if (isHaveStoreNotLeave == NO) {
        NSString *LeaveString = NSLocalizedString(@"not_leave_store",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%@%@",inoutStoreObject.memo1,LeaveString] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
    return isHaveStoreNotLeave;
}

- (BOOL)isVisitedStore:(WSStoreBean *)aStore {
    return [[WSInoutStoreTable sharedTable] isLeaveStore:aStore andOtherParam:self.currentFuncs.iParentFuncsBean.fc andParamType:EParameterType_ParentFC];
}


/**
 *  计划内门店要按照拜访计划的顺序排序
 *
 *  @param storeArray 门店列表
 *
 *  @return 排序后的门店列表
 */
- (NSArray *)sortInplanStoreArrayByVisitPlan:(NSArray *)storeArray {
    
    WSVisitPlanArray *visitPlanArray = [WSAppData getObjectbyKey:STOREACVTDIS_VISITPLAN];
    NSArray *beanArray = visitPlanArray.beanArray;
    NSArray *sIDArray = [beanArray valueForKey:@"sId"];
    
    NSArray *resultArray = [storeArray sortedArrayUsingComparator:^NSComparisonResult(WSStoreBean *obj1, WSStoreBean *obj2) {
        
        NSInteger index1 = [sIDArray indexOfObject:obj1.Id];
        NSInteger index2 = [sIDArray indexOfObject:obj2.Id];
        
        NSComparisonResult result = NSOrderedAscending;
        if (index1 == index2) {
            result = NSOrderedSame;
        }else if (index1 > index2) {
            result = NSOrderedDescending;
        }
        
        return result;
    }];
    
    return resultArray;
}


- (void)gotoWorkFlowController:(WSWorkFlowViewController *)wfvc {
    BOOL isNextStep = [self.currentFuncs.opt.isIntentToStore isEqualToString:@"navigation"];
    if ((wfvc.currentFuncs.readonly && wfvc.currentFuncs.iParentFuncsBean.funcsArray.count == 1) ||
        !isNextStep) {
        [self gotToController:wfvc];
    } else {
        [self gotoNextStepFuncsControllerWithWfvc:wfvc];
    }
}

- (void)gotToController:(WCBaseViewController *)wfvc {

    
    LogInfo(@"Going to class WSWorkFlowViewController");
    
    if (INTERFACE_IS_PAD) {
        
        [self showWorkFlowInSplitViewController:wfvc];
        
    }else {
        
        wfvc.hidesBottomBarWhenPushed = YES;
        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
        } else {
            [self.navigationController pushViewController:wfvc animated:YES];
        }
    }
}

- (void)gotoNextStepFuncsControllerWithWfvc:(WSWorkFlowViewController *)wfvc {
    WSNextStepFuncsViewController *vc = [[WSNextStepFuncsViewController alloc] initWithFuncs:wfvc.currentFuncs store:self.currentStore subempStore:self.subempStore acvtNewStore:self.acvtNewStore moduleFC:wfvc.moduleFC];
    vc.currentVisitAction = wfvc.currentVisitAction;
    vc.input_reflect_code = wfvc.input_reflect_code;
    vc.realParentFuncsCode = wfvc.realParentFuncsCode;
    vc.isTabMode = YES;
    
    [self gotToController:vc];
}


- (void)showWorkFlowInSplitViewController:(WCBaseViewController *)controller {
    
    WCNavigationController *workFlowNav = [[WCNavigationController alloc] initWithRootViewController:controller];
    
    WCBaseViewController *rightCon = nil;
    
    if ([controller isKindOfClass:[WSWorkFlowViewController class]]) {
        WSWorkFlowViewController *workFlowCon = (WSWorkFlowViewController *)controller;
        rightCon = [workFlowCon getDefaultShowController];
    }
    
    if (!rightCon) {
        rightCon = [[WSStoreInfoMapViewController alloc] init];
    }
    
    WCNavigationController *rightNav = [[WCNavigationController alloc] initWithRootViewController:rightCon];
    
    [controller leftItemImage:@"icon_back" target:controller action:@selector(backAction)];
    
    WSSplitViewController *split = [[WSSplitViewController alloc] initWithLeftController:workFlowNav rightController:rightNav];
    CGFloat width = SPLITVIEW_LEFT_DEFAULT_WIDTH;
    
    if (controller.currentFuncs.wfcol > 0) {
        width = (CGFloat)controller.currentFuncs.wfcol;
    }
    split.leftControllerWidth = width;
    split.separatorLineColor = [UIColor colorWithHexString:@"#cdcdcd"];
    
    controller.wsSplitController = split;
    rightCon.wsSplitController = split;
    
    [self presentViewController:split animated:YES completion:nil];
    
}

#pragma mark - about store visit prepare

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

- (WSStorePrepareState)getPrepareStateByStore:(WSStoreBean *)store {
    return [self getPrepareStateByStore:store bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
}

- (WSStorePrepareState)getPrepareStateByStore:(WSStoreBean *)store bizDate:(NSString *)bizDate {
    WSStorePrepareState prepareState = WSStorePrepareStateNotPrepare;
    
    if ([store.prepareState length] > 0 && ![store.prepareState isEqualToString:PREPARE_STATE_READY] && ![store.prepareState isEqualToString:PREPARE_STATE_NOT_PREPARE] ) {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        WSDictBean *dict = [service queryDictWithID:store.prepareState];
        store.prepareState = dict.cod;
    }
    
    if ([store.prepareState isEqualToString:PREPARE_STATE_READY]) {
        prepareState = WSStorePrepareStateReady;
    }
    
    if (!store.hasGetStateData && prepareState == WSStorePrepareStateNotPrepare) {
        
        if (self.prepareStateAcvtBean) {
            
            if ([self.prepareStateAcvtBean.acvtCode isEqualToString:STORE_PREPARE_ACVT_CODE]) { //联合利华，使用固定问卷编码stores_zbzt
                //有stores_zbzt这个问卷才去过滤
                WSAcvtBean_qst *qst = [self.prepareStateAcvtBean getQstBeanByQstCod:STORE_PREPARE_ACVT_CODE];
                if (qst) {
                    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                    NSString *value = [service queryQstValueWithStoreId:store.Id acvtId:self.prepareStateAcvtBean.acvtId acvtQstId:qst.acvtQstId genId:nil isMatchGenId:NO bizDate:bizDate];
                    
                    if ([value length] > 0) {
                        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                        WSDictBean *db = [service queryDictWithID:value];
                        store.prepareState = db.cod;
                        if ([store.prepareState isEqualToString:PREPARE_STATE_READY]) {
                            prepareState = WSStorePrepareStateReady;
                        }
                    }
                }
            }else {//标准产品，可以随意配置问卷，只要问卷有回显值，就认为是已准备
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                if ([service hasValueForStoreId:store.Id acvtId:self.prepareStateAcvtBean.acvtId]){
                    store.prepareState = PREPARE_STATE_READY;
                    prepareState = WSStorePrepareStateReady;
                }
                
            }
            
        }
    }
    
    return prepareState;
}

- (NSString *)getVisitTypeByStore:(WSStoreBean *)store {
    return [self getVisitTypeByStore:store bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
}

- (NSString *)getVisitTypeByStore:(WSStoreBean *)store bizDate:(NSString *)bizDate {
    NSString *visitType = nil;
    
    if (self.visitTypeAcvtBean) {
        //有methodVisit这个问卷才去过滤
        WSAcvtBean_qst *qst = [self.visitTypeAcvtBean getQstBeanByQstCod:VISIT_TYPE_ACVT_CODE];
        if (qst) {
            WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
            NSString *value = [service queryQstValueWithStoreId:store.Id acvtId:self.visitTypeAcvtBean.acvtId acvtQstId:qst.acvtQstId genId:nil isMatchGenId:NO bizDate:bizDate];
            
            if ([value length] > 0) {
                WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                WSDictBean *db = [service queryDictWithID:value];
                visitType = db.cod;
            }
        }
    }
    
    store.visitType = visitType;
    
    return visitType;
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
    
    if (INTERFACE_IS_PAD) {
        
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:con];
        
        [con leftItemImage:@"icon_back" target:con action:@selector(backAction)];
        
        [self presentViewController:nav animated:YES completion:nil];
        
        
    }else {
        if (self.ownParentViewController) {
            self.ownParentViewController.hidesBottomBarWhenPushed = YES;
            [self.ownParentViewController.navigationController pushViewController:con animated:YES];
        } else {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:con animated:YES];
        }
    }
}

- (BOOL)isUseFilterArray {
    return NO;
}

#pragma mark - WSSelectListNewTableviewCellDelegate

-(void)storePrepareWith:(WSStoreBean *)store withDate:(NSString *)date{
    
    if (self.visitTypeAcvtBean && self.visitTypeFuncBean) {
        
        [self showVisitTypeControllerWithStore:store date:date];
        
    }else {
        
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

- (void)chatButtonPressDown:(WSStoreBean *)store {
    
}

- (void)queryStoreInfoByCell:(UITableViewCell *)cell {
    
}

#pragma mark - 是否关注按键点击 indexPath:索引路径
- (void)isFollowButtonClick:(NSIndexPath *)indexPath
{
    NSArray *array = [self isUseFilterArray] ? self.filterArray : self.storeArray;
    if(array.count <= indexPath.row)
        return;
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip", nil) tips:nil tapTarget:self action:nil];
    
    self.storeStateindexPath = indexPath;
    [self performSelector:@selector(delayRequestFollow) withObject:nil afterDelay:0.5f];
}

#pragma mark - 延迟请求关注方法
- (void)delayRequestFollow
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followFinishRequest:) name:FOLLOW_NOTIFY object:nil];
    
    NSArray *array = [self isUseFilterArray] ? self.filterArray : self.storeArray;
    WSStoreBean *storeBean = [array objectAtIndex:self.storeStateindexPath.row];
    
    [[WSRequestHelper shareInstance] uploadFollowStateWithContent:storeBean.follow storeId:storeBean.Id srid:self.subempStore.Id notifyName:FOLLOW_NOTIFY];
}

#pragma mark - 关注完成请求方法
- (void)followFinishRequest:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FOLLOW_NOTIFY object:nil];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dataDic = [info objectFromJSONString];
    NSString *flag = [NSString stringWithValue:[dataDic objectForKey:@"result"]];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSArray *array = [self isUseFilterArray] ? self.filterArray : self.storeArray;
    if((array.count <= self.storeStateindexPath.row) || error || ![flag isEqualToString:@"1"])
    {
        NSString *tmpString = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else
    {
        WSStoreBean *storeBean = [array objectAtIndex:self.storeStateindexPath.row];
        NSString *follow = ([storeBean.follow isEqualToString:@"0"]) ? @"1" : @"0";
        storeBean.follow = follow;
        [[WSBaseStoreTable sharedTable] updateWithNames:@[@"follow"] values:@[follow] whereName:@[@"store_Id", @"empId"] whereValue:@[storeBean.Id, storeBean.empId]];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.storeStateindexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - WSPopViewControllerDelegate

- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm
{
    if (isConfirm && controller.contentViewController == methodVisitController) {
        
        NSArray *prepareFuncsArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.prepareFuncBean.funcsArray withStore:methodVisitController.currentStore bizDate:methodVisitController.prepareVisitDate];
        
        if ([prepareFuncsArray count] > 0) {
            [self showPrepareControllerWithStore:methodVisitController.currentStore date:methodVisitController.prepareVisitDate];
        }
        
    }
    
    if (isConfirm) {
        [self reloadStoreList];
    }
    
    methodVisitController = nil;
}

#pragma mark - UITableViewDataSource

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.storeArray count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [self isUseFilterArray] ? self.filterArray : self.storeArray;
    WSStoreBean *storeBean = array[indexPath.row];
    static NSString *NewTableviewCellIdentifier = @"NewTableviewCellIdentifier";
    //益海嘉里定制view样式
    if ([self.currentFuncs.opt.showStyle isEqualToString:@"compactStyle"])
    {
        WSNewTodayVisitAndAllStoreCell * cell = [tableView dequeueReusableCellWithIdentifier:NewTableviewCellIdentifier];
        if (cell == nil)
        {
            cell = [[WSNewTodayVisitAndAllStoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewTableviewCellIdentifier cellWidth:tableView.width];
        }
        cell.delegate = self;
        [cell setStore:storeBean withOpt:self.currentFuncs.opt prepareFuncsBean:self.prepareFuncBean prepareAcvtBean:self.prepareStateAcvtBean];
        storeBean.hasGetStateData = YES;
        
        //判断已下载 YIHAIKERRY-3241 新增
        cell.loadTag.hidden = YES;
//        YIHAIKERRY-3384
//        SFA 益海嘉里-传统渠道【200家门店列表】【IOS】已下载详细数据门店进行拜访，签退完成后进入“今日拜访”，在“今日拜访”列表中“已下载”标签消失 （安卓没有加这个判断条件所以先去掉）
//        if ([self.currentFuncs.opt.downByMap isEqualToString:@"2"]) {
            BOOL isRequested = [self getDataInfoIsloadFromDB:storeBean.Id];
            if (isRequested) {
                cell.loadTag.hidden = NO;
            }
//        }
        
        return cell;
    }
    else {
        
        WSRouteStoreTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NewTableviewCellIdentifier];
        if (!cell) {
            cell = [[WSRouteStoreTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewTableviewCellIdentifier];
        }
        
        [cell setStore:storeBean withOpt:self.currentFuncs.opt foldState:self.foldStateDic[storeBean.Id]];
        
        @weakify_self;
        [cell setShowStoreAgreementAction:^(WSStoreBean *cellStoreBean, BOOL isExpend, WSRouteStoreTableViewCell *cell) {
            
            @strongify_self;
            [self.foldStateDic setObject:(isExpend ? @"1" : @"0") forKey:cellStoreBean.Id];
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
        [cell setJumpStoreInfoAction:^(WSStoreBean *cellStoreBean, WSRouteStoreTableViewCell *cell) {
            
            @strongify_self;
            if (self.currentFuncs.opt.jumpStoreInfoUrl) {
                
                WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
                vc.currentStore = cellStoreBean;
                vc.externalOpenUrl = self.currentFuncs.opt.jumpStoreInfoUrl;
                [self gotToController:vc];
            }
        }];
        
        return cell;
    }
}

// 如果根据距离排序后 还需要把拜访完成的放在最后面
-(void)resortByVisitStateAndDistance:(CGFloat )distance{
    
    NSMutableArray *allArray = [NSMutableArray arrayWithCapacity:self.filterArray.count];
    [allArray addObjectsFromArray:self.filterArray];
    [self.filterArray removeAllObjects];
    for (WSStoreBean *storeBean in allArray) {
        
        // 设置距离筛选则过滤掉大于设定距离的门店
        if (distance) {
            WSStoreBean *distanceStoreBean = [WSLocationManager calculateDistanceWith:storeBean func:self.currentFuncs locationDescribe:self.locationDescribe isStoreList:YES];
            if (distanceStoreBean.f_distance > distance) {
                continue;
            }
        }
        
        [self.filterArray addObject:storeBean];
    }
}

-(void)resortStoreWithDistance{
    if(self.filterArray==NULL || self.filterArray.count==0)
        return;
    NSMutableArray * storeArray=[[NSMutableArray alloc]init];
    for (WSStoreBean * store in self.filterArray) {
        // 去计算门店的distance
        WSStoreBean * tempstore = [WSLocationManager calculateDistanceWith:store func:self.currentFuncs locationDescribe:self.locationDescribe isStoreList:YES];
        [storeArray addObject:tempstore];
    }
    [self.filterArray removeAllObjects];
    NSArray *array = [storeArray sortedArrayUsingFunction:customSort context:nil];
    [self.filterArray addObjectsFromArray:array];
    
    [self resortByVisitStateAndDistance:0];
}

NSComparisonResult customSort(WSStoreBean * obj1, WSStoreBean * obj2,void* context){
    
    if (obj1.f_distance > obj2.f_distance) {
        return NSOrderedDescending;
    }
    
    if (obj1.f_distance < obj2.f_distance) {
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

-(WSBaseStoreOtherDataDBService *)baseStoreOtherDataDBService {
    if (!_baseStoreOtherDataDBService) {
        _baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
    }
    return _baseStoreOtherDataDBService;
}

//获取商店是否下载了详细数据
- (BOOL)getDataInfoIsloadFromDB:(NSString *)stroeID {
    NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
//    YIHAIKERRY-3400
//    SFA 益海嘉里-传统渠道【200家门店列表】【IOS】进入200家以下账号，门店列表的所有门店都不显示“已下载”标识
    BOOL isRequested = [self.baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:stroeID];
    if (!isRequested) {
        isRequested = [self.baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:stroeID];
    }
    return isRequested;
}

//SFA-26033 SFA立白【经销商】首页订单管理功能优化
-(void)gotoSpecialViewController:(WSStoreBean *)store withFc:(NSString *)fc{
    WSFuncsBeanArray* funcsArray=[WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean* fb=[funcsArray getFuncsBeanWithFC:fc];//MV_LIST_010
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:store];
    if ([vc isKindOfClass:[BaseViewController class]]) {
        BaseViewController *bsvc = (BaseViewController *)vc;
        bsvc.moduleFC = self.moduleFC;
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 是否存在门店提醒方法(方法内会直接弹出 SVProgressHUD)
- (BOOL)isExistStoreOptRemindWithStoreBean:(WSStoreBean *)storeBean {
    
    //存在线路并且门店是线路中的门店 进行逻辑操作
    NSString *routeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"];
    NSString *routeSql = [NSString stringWithFormat:@"select * from base_store_other_data bsod where bsod.store_id = '%@' and bsod.item1 = '%@' and bsod.type = '%@'",
                          storeBean.Id, routeId, @"visit_plan_route"];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *routeArray = [sqliteUtil queryAndReturnInfosBySql:routeSql andClassName:@"WSBaseStoreOtherDataObject"];
    if (routeArray.count == 0) {
        return NO;
    }
    
    //查询门店是否正在拜访中
    NSString *visitSql = [NSString stringWithFormat:@"select * from wch_inoutStore inoutStore where inoutStore.STORE_ID = '%@' and inoutStore.outtime = 'null' and inoutStore.emp_id = '%@'",
                          storeBean.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *visitArray = [sqliteUtil queryAndReturnInfosBySql:visitSql andClassName:@"WSInoutStoreObject"];
    WSInoutStoreObject *visitObject = [visitArray firstObject];
    
    //配置isReminderOperate 并且 门店在拜访中 进行逻辑操作
    NSString *optOperateStr = [NSString stringNotNilWithValue:self.currentFuncs.opt.isReminderOperate];
    if (visitObject && optOperateStr.length > 0) {
        
        if (![visitObject.modulefc isEqualToString:self.currentFuncs.fc]) {
            [SVProgressHUD showHudMsg:optOperateStr];
            return YES;
        }
    }
    
    //门店正在拜访 不进行其它逻辑操作
    if (visitObject) {
        return NO;
    }
    //门店已经拜访完成<后台数据下发>或者无效 不进行其它逻辑操作
    if ([storeBean.optName containsString:@"今日已访"] || [storeBean.optName containsString:@"无效拜访"]) {
        return NO;
    }
    
    //配置isReminderVisit 进行逻辑操作
    NSString *optVisitStr = [NSString stringNotNilWithValue:self.currentFuncs.opt.isReminderVisit];
    if (optVisitStr.length > 0) {
            
        NSString *visitAllSql = [NSString stringWithFormat:@"select * from wch_inoutStore inoutStore where inoutStore.STORE_ID = '%@' and inoutStore.emp_id = '%@'",
                                 storeBean.Id, [WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSArray *visitAllArray = [sqliteUtil queryAndReturnInfosBySql:visitAllSql andClassName:@"WSInoutStoreObject"];
        
        BOOL isFcSame = YES;
        for (int i = 0; i < visitAllArray.count; i++) {
                            
            WSInoutStoreObject *inoutStoreObject = [visitAllArray objectAtIndex:i];
            if (![inoutStoreObject.modulefc isEqualToString:self.currentFuncs.fc]) {
                isFcSame = NO;
                break;
            }
        }
        
        if (isFcSame) {
            [SVProgressHUD showHudMsg:optVisitStr];
            return YES;
        }
    }
    
    return NO;
}

- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality {
    
}

@end
//===================================================================================================================================================
