//
//  WSTodayVisitViewController.m
//  WinSFA
//
//  Created by xiajl on 14-8-14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSFuncsBean_opt.h"
#import "WSTodayVisitViewController.h"
#import "WSFuncsBean.h"
#import "WSInPlanViewController.h"
#import "WSInPlanStoreBean.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSWorkFlowViewController.h"
#import "WSStoreInfoViewController.h"
#import "WSFuncsBeanArray.h"
#import "WSAddNewStoreViewController.h"
#import "WCOptionalSource.h"
#import "WSCurrentTime.h"
#import "WSInoutStoreTable.h"
//TODO:对上层依赖，需要重构
//#import "MyModifyStoreInfoViewController.h"
//#import "ConfigFileController.h"
#import "WSVisitStoreActionTable.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSRequestHelper.h"
#import "WSStoreInfoBeanArray.h"
#import "WSStoreAcvtDisBean.h"
#import "WSSelectListTableViewCell.h"
#import "WSCustomerVistViewController.h"
#import "WSConstant.h"
#import "WSFunsShortCutData.h"

#import "WSBaseStoreTable.h"

#import "WSManagV_LISTViewController.h"
#import "WSStoreDataProcessService.h"

#import "WSBaseStoreTable.h"

#import "WSBaseStoreVisitPlanTable.h"

#import "WSBaseStoreTable.h"

#import "WSSelectListNewTableviewCell.h"
#import "WSNavigationBar.h"

#import "WSCalendarView.h"
#import "WSStoreInfoMapViewController.h"

#import "WSMyCustomerTitleView.h"

#import "WSEnvrionment.h"

#import "WSSpecialAcvtListViewController.h"

#import "WSEMSDKManager.h"
#import "WSChartConst.h"
#import "WSChartViewController.h"
#import "WSTestTools.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSNewStoreListTool.h"

#import "WSMainLeftViewManager.h"
#import "WSBaseAcvtdisDBService.h"

#define INPLAN_UPDATA_NOTIFY @"INPLAN_UPDATA_NOTIFY"

#define UPDATA_NOTIFY       @"outPlan_notify"

static NSString *category;


@interface WSTodayVisitViewController ()<WSSelectListTableViewCellDelegate,WSMyCustomerTitleViewDelegate,WSCalendarViewDelegate>
@property (nonatomic, assign) BOOL isInitOtherFuncBeans;
//@property (nonatomic, strong) NSMutableArray *addVisitedStores;
//@property (nonatomic, assign) NSInteger allSubempInplanCount;


@property (nonatomic, strong) NSArray *shortCutArray;

@property (nonatomic, assign) NSInteger allInPlanStoreCount;


@end

@implementation WSTodayVisitViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.subMenuFuncsBean = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:self.currentFuncs];
    
    self.subMenuFuncsCode = self.subMenuFuncsBean.fc;
    
    [self initnavigatBarItem];
    [self addAddedStores];
    if (self.hasVisitType)
    {
        [self generateVisitInfoArray];
    }
    self.isInitOtherFuncBeans = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // SFA-13380
    [self clearAllNavBBI];
    [self addBackBarButtonItem];
    [self addRightButtonItem];
    
    if (self.isLoaded == NO) {
        self.isLoaded = YES;
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
    }
    
}

- (void)addBackBarButtonItem {
    
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    //SFA-16546
    if ([self getNavigationController].viewControllers.count <=1) {

    }else{
    
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

- (void)addRightButtonItem {
    
    if ([self.currentFuncs.opt.isJumpCallPlan length] > 0) {
        UIBarButtonItem *rightBN = [[UIBarButtonItem alloc] initWithImage:[UIImage scaledImageForName:@"icon_callplan" ofType:@"png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked)];
        
        [self getNavigationItem].rightBarButtonItems = @[rightBN];
    }
    
}

- (void)rightBarButtonClicked
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *jumpFuncBean = [funcsBeanArray getFuncsBeanWithFC:self.currentFuncs.opt.isJumpCallPlan];
    if (jumpFuncBean) {
        NSString *className = [WSPlistHelper valueForKey:jumpFuncBean.fv withPlistName:kControllerMappingFileName];
        WCBaseViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:jumpFuncBean];
        vc.hidesBottomBarWhenPushed = YES;
        if (self.ownParentViewController) {
            [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
        } else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)sortStoreFromDB
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableArray *notStartArray = [NSMutableArray array];
    NSMutableArray *completerArray = [NSMutableArray array];
    
    for (WSStoreBean *storeBean in self.storeArray) {
        if ([storeBean.actionState isEqualToString:ActionWorking]) {
            [array addObject:storeBean];
        }else if ([storeBean.actionState isEqualToString:ActionDone]){
            [completerArray addObject:storeBean];
        }else {
            [notStartArray addObject:storeBean];
        }
    }
    
    [array addObjectsFromArray:notStartArray];
    [array addObjectsFromArray:completerArray];
    
    self.storeArray = array;
}

//YIHAIKERRY-5109 门店列表统一按距离排序
- (void)sortStoreByDistance
{
    NSArray *sortArray;
    NSMutableArray *tmpArrayWorking = [NSMutableArray new];//存放正在拜访中的门店
    NSMutableArray *tmpArrayOne = [NSMutableArray new];//存放距离不为空需要排序的门店
    NSMutableArray *tmpArrayTwo = [NSMutableArray new];//存放距离为空的门店
    
    for (WSStoreBean *storeBean in self.storeArray) {
        if ([storeBean.actionState isEqualToString:ActionWorking]) {
            [tmpArrayWorking addObject:storeBean];
        }else if (storeBean.distance && storeBean.distance.length > 0) {
            [tmpArrayOne addObject:storeBean];
        }else{
            [tmpArrayTwo addObject:storeBean];
        }
    }
    
    sortArray =   [tmpArrayOne sortedArrayUsingComparator:^NSComparisonResult(WSStoreBean * obj1, WSStoreBean * obj2) {
        
        NSComparisonResult result = [[NSNumber numberWithInt:[obj1.distance intValue]]compare:[NSNumber numberWithInt:[obj2.distance intValue]]];
        return  result;
    }];
    
    [self.storeArray removeAllObjects];
    [self.storeArray addObjectsFromArray:tmpArrayWorking];
    [self.storeArray addObjectsFromArray:sortArray];
    [self.storeArray addObjectsFromArray:tmpArrayTwo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    [self reloadStoreList];
    
    // YIHAIKERRY-2633
    if (!self.isLoaded && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"] && self.storeArray.count == 1) {
        if ([self respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.isLoaded = YES;
}

-(void)reloadStoreList {
    
    //[[WSTestTools getInstance] keepTimeWithKey:@"todayVisit-getStoreDataFromDb"];
    [self initDataArrayFromDb];
    //[[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"todayVisit-getStoreDataFromDb"];
    
    //[self initOtherFuncsBean];
    
    //[self loadAddNewStore];
    
    for (WSFuncsBean *fucsBean in self.currentFuncs.iParentFuncsBean.funcsArray) {
        
        if ([fucsBean.fc isEqualToString:self.currentFuncs.fc]) {
            NSString * funcCode = fucsBean.fc;
            if (self.currentFuncs.opt.parentStoreFc==nil) {
                //门店互通
                NSArray * fcList = [[[WSSqliteUtil alloc]init] queryParentfcWithCurrentfc:self.currentFuncs.fc];
                if (fcList.count>0) {
                    funcCode = [fcList componentsJoinedByString:@","];
                }
            }
            [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:fucsBean funcode:funcCode];
        }
    }
    
    
    
    //    if (self.outPlanFuncsBean) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.outPlanFuncsBean];
    //
    //    }
    //    if (self.outPlanFuncsBean_FC_IS_TAB_F2002 && ![self.outPlanFuncsBean_FC_IS_TAB_F2002.fc isEqualToString:self.outPlanFuncsBean.fc]) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.outPlanFuncsBean_FC_IS_TAB_F2002];
    //
    //    }
    //
    //    if (self.subempOutPlanFuncsBean) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.subempOutPlanFuncsBean];
    //
    //
    //    }
    //
    //    if (self.outPlanSearchFuncsBean) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.outPlanSearchFuncsBean];
    //
    //    }
    //    if (self.newstoreFuncsBean) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.newstoreFuncsBean];
    //
    //    }
    //    if (self.outPlanSearchFuncsBean2) {
    //
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.outPlanSearchFuncsBean2];
    //    }
    //    if (self.managV_OutPlanFucsBean) {
    //        [self addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:self.managV_OutPlanFucsBean];
    //    }
    
    // 查出来的门店去重    SFA 项目 SFA-7955
    self.storeArray =  [self DuplicateRemoval:self.storeArray];
    
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        NSMutableArray *unVisitArray = [NSMutableArray array];
        NSMutableArray *visitArray = [NSMutableArray array];
        [self.storeArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[WSStoreBean class]]) {
                WSFuncsBean *fb = self.currentFuncs;
                if (fb.fc) {
                    if ([[WSInoutStoreTable sharedTable] isEnterStore:obj andOtherParam:[NSString stringWithFormat:@"'%@'",fb.fc]
                                                         andParamType:EParameterType_ParentFC]) {
                        
                        if([[WSInoutStoreTable sharedTable] isLeaveStore:obj andOtherParam:[NSString stringWithFormat:@"'%@'",fb.fc]
                                                            andParamType:EParameterType_ParentFC])
                        {
                            [visitArray addObject:obj];
                        }else{
                            [unVisitArray addObject:obj];
                        }
                    }else {
                        [unVisitArray addObject:obj];
                    }
                }
            }
        }];
        
        if (unVisitArray.count > 0 && visitArray.count > 0) {
            [self.storeArray removeAllObjects];
            [self.storeArray addObjectsFromArray:unVisitArray];
            [self.storeArray addObjectsFromArray:visitArray];
        }
    }
    
    /**
     *  计划内门店要按照拜访计划的顺序排序
     */
    // winSFA MSTD-4007  今日拜访的门店列表跟安卓一致，只需要根据门店的seq进行排序，不需要再根据拜访计划顺序重拍一次。（此处注释）
    // self.storeArray = [[self sortInplanStoreArrayByVisitPlan:self.storeArray] mutableCopy];
    if (![WSEnvrionment  getStoreDataFromDb]) {
        self.storeArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.storeArray]];
        if (self.subempStore == nil) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == nil"];
            self.storeArray = [NSMutableArray arrayWithArray:[self.storeArray filteredArrayUsingPredicate:predicate]];
        }
    }else {
        if ([self.currentFuncs.opt.distancesSort isEqualToString:@"3"]) {
            [self sortStoreByDistance];
        }else{
            [self sortStoreFromDB];
        }
    }
    
    NSInteger visitcount = [self getCount:self.storeArray withVisitActionStatus:ActionDone] ;
    /*(已拜访或拜访中的门店/计划内的门店)   和安卓保持一致*/
    NSInteger inplanCount = self.allInPlanStoreCount;
    
    /*Jira - SFA-14583 allSubempInplanCount 这个字段赋值已经是注释掉的,没用了 把下面注掉 否则inplanCount 会被覆盖 create by sunhongfu 2017-11-28 */
    //    if (self.subempStore) {
    //        inplanCount = self.allSubempInplanCount;
    //    }
    
    //MN-933 IOS端拜访-今日拜访门店数量与实际显示的门店数量不一致 修改总数量逻辑(每次获取当前self.storeArray.count)
    NSString *title = [NSString stringWithFormat:@"%@(%lu/%ld)", self.currentFuncs.name, (unsigned long)visitcount, inplanCount];
    [self refreshControllerTitle:title];
    [self.tableView reloadData];
    
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        if ([self.storeArray count] == 0) {
            if (!self.empty) {
                [self addEmptyView];
                
            }
        }else{
            [self.empty removeFromSuperview];
            self.empty = nil;
        }
    }
    else {
        
        if ([self.notVisitStoreArray count] == 0 && [self.visitedStoreArray count] == 0) {
            if (!self.empty) {
                [self addEmptyView];
            }
        }else{
            [self.empty removeFromSuperview];
            self.empty = nil;
        }
    }
    
}

#pragma mark - 计划路线的门店  SFA-13481
-(void)queryRoutePlanStore{
    
    NSArray * routeArray = [[[NSUserDefaults standardUserDefaults]objectForKey:ROUTE_PLAN_ID] componentsSeparatedByString:@"@"];
    NSString * bizeDate = [routeArray lastObject];
    NSString * routePlanId;
    if ([bizeDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]) {
        routePlanId = [routeArray firstObject];
    }
    
    if (!routePlanId) return;
    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    NSString *empId = [self getCurrentEmpId];
    if (self.subempStore != nil && self.subempStore.Id.length > 0) {
        empId = self.subempStore.Id;
    }
    NSString * funcCode = self.currentFuncs.fc;
    if (self.currentFuncs.opt.parentStoreFc==nil) {
        //门店互通
        NSArray * fcList = [[[WSSqliteUtil alloc]init] queryParentfcWithCurrentfc:self.currentFuncs.fc];
        if (fcList.count>0) {
            funcCode = [fcList componentsJoinedByString:@","];
        }
    }
    NSArray * routePlanArray = [[WSBaseStoreDBService  shareInstance] queryRoutePlanStoresByFuncCode:funcCode SearchObjId:search_objId empId:empId route_id:routePlanId];
    
    NSMutableArray *storesCopy = [NSMutableArray array];
    for (WSStoreBean *storeBean in  routePlanArray) {
        WSStoreBean *object = [storeBean copy];
        object.mappingStoreFc = self.currentFuncs.fc;
        [storesCopy addObject:object];
    }
    [self.storeArray addObjectsFromArray:storesCopy];
    
}

#pragma mark - initData
//modify by wangdongyan 2012-02-16

/*
 1.searchobjId 下属的拼接
 2.sty 拼接
 3.
 */
- (void)initDataArrayFromDb {
    self.shortCutArray = [self filterShortCutFuncsBean];
    NSString * search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    NSString *empId = [self getCurrentEmpId];
    if (self.subempStore != nil && self.subempStore.Id.length > 0) {
        empId = self.subempStore.Id;
    }
    self.storeArray = [self queryStoresFromDbWithFuncs:self.currentFuncs searchObjId:search_objId empId:empId];
    
    // 计划路线的门店 --- 辉瑞医院功能
    [self queryRoutePlanStore];
    self.storeArray =  [self DuplicateRemoval:self.storeArray];
    self.allInPlanStoreCount = [self.storeArray count];
}


//-(void)initOtherFuncsBean
//{
//    // 目前情况是funcsBeanDic 里最多有两种funcsBean.如果超过两种再订方案 主要是 sortStoreListArrayByVisitAction 方法排序使用。
//    if (!self.funcsBeanDic) {
//        self.funcsBeanDic = [[NSMutableDictionary alloc] initWithCapacity:4];
//    }
//
//    switch (self.todayVisitCategory) {
//        case WSTodayVisitCategoryInPlan: //只有计划内
//        {
//            if (self.currentFuncs) {
//                [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V2001"];
//            }
//        }
//            break;
//        default:
//        {
//
//            if (!self.isInitOtherFuncBeans) {
//
//                self.isInitOtherFuncBeans = YES;
//                WSFuncsBean *superBarFuncsBean = nil;
//                NSString *stringFC = nil;
//                /*其他模块下(非主界面TB_V20模块下的) 新增即拜访的门店加入今日拜访列表中*/
//                WSFuncsBeanArray * newfba = [WSAppData getObjectbyKey:FUNCS];
//                for (WSFuncsBean *funcs in newfba.funcsArray) {
//                    if ([funcs.fc isEqualToString:@"TB_F60"] ) {
//                        for (WSFuncsBean *funcBean in funcs.funcsArray) {
//                            if ([funcBean.fv isEqualToString:@"TAB_V8003"] && [funcBean.fc isEqualToString:@"FAC_001"]) {
//                                self.storeListFucsBean = funcBean;
//                                if (self.storeListFucsBean) {
//                                    [self.funcsBeanDic setObject:self.storeListFucsBean forKey:@"TAB_V8003"];
//                                }
//                                break;
//                            }
//                        }
//                        break;
//                    }
//                }
//
//                if(self.ownParentViewController && ([self.ownParentViewController isKindOfClass:[WSCustomerVistViewController class]]|| [self.ownParentViewController isKindOfClass:[WSManagV_LISTViewController class]])){
//                    WSCustomerVistViewController *controller = (WSCustomerVistViewController *)self.ownParentViewController;
//                    stringFC = controller.currentFuncs.fc;
//                }
//
//                // FCbean : 计划内    ，计划外，    新门店，             动态搜索计划外
//                // key    : TAB_V2001  TAB_V2002  TAB_V2002_newstore TAB_V11001(TAB_V21002)
//                if (self.currentFuncs) {
//                    [self.funcsBeanDic setObject:self.currentFuncs forKey:@"TAB_V2001"];
//                }
//
//                WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
//                for (WSFuncsBean *funcs in fba.funcsArray) {
//                    if ([funcs.fv isEqualToString:@"TB_V20"] && [funcs.fc isEqualToString:stringFC]) {
//                        superBarFuncsBean = funcs;
//                        break;
//                    }
//                }
//                if(self.ownParentViewController &&  [self.ownParentViewController isKindOfClass:[WSManagV_LISTViewController class]]){
//                    WSCustomerVistViewController *controller = (WSCustomerVistViewController *)self.ownParentViewController;
//                    superBarFuncsBean = controller.currentFuncs;
//                }else if (self.ownParentViewController && [self.ownParentViewController isKindOfClass:[self.ownParentViewController class]]) {
//                    WSSpecialAcvtListViewController *specialAcvtListViewController = (WSSpecialAcvtListViewController *)self.ownParentViewController;
//                    superBarFuncsBean = specialAcvtListViewController.currentFuncs;
//                }
//
//
//                if (superBarFuncsBean) {
//
//                    for (WSFuncsBean* fb in superBarFuncsBean.funcsArray) {
//
//                        if ([fb.fv isEqualToString:@"TAB_V2002"] && (!fb.ds || [fb.ds length] < 1 || ![fb.ds isEqualToString:@"newstore"])) { //资源是固定的，所以硬编码 TAB_V2002【门店清单】。
//                            self.outPlanFuncsBean = fb;
//                            if (self.outPlanFuncsBean && ![fb.fc isEqualToString:@"TAB_F2002"]) {
//                                [self.funcsBeanDic setObject:self.outPlanFuncsBean forKey:@"TAB_V2002"];
//                            }
//
//                            if ([fb.fc rangeOfString:@"TAB_F2002"].location != NSNotFound) {
//                                self.outPlanFuncsBean_FC_IS_TAB_F2002 = fb;
//                                [self.funcsBeanDic setObject:self.outPlanFuncsBean_FC_IS_TAB_F2002 forKey:@"TAB_V2002_FC_IS_TAB_F2002"];
//                            }
//
//                            if ([fb.fc isEqualToString:@"TAB_F2002_AT01"]) {
//                                self.subempOutPlanFuncsBean = fb;
//                                [self.funcsBeanDic setObject:self.subempOutPlanFuncsBean forKey:@"TAB_V2002_sumemp"];
//                            }
//
//                        }else if ([fb.fv isEqualToString:@"TAB_V2002"] && (fb.ds && [fb.ds rangeOfString:@"newstore"].location != NSNotFound)) { //资源是固定的，所以硬编码 TAB_V2002 + newstore(ds)【新门店】。
//                            self.newstoreFuncsBean = fb;
//                            if (self.newstoreFuncsBean) {
//                                [self.funcsBeanDic setObject:self.newstoreFuncsBean forKey:@"TAB_V2002_newstore"];
//                            }
//                        }else if ([fb.fv isEqualToString:@"TAB_V11001"]) { //资源是固定的，所以硬编码 TAB_V11001【计划外搜索】。 与 TAB_V21002 用的是同一个页面。暂作兼容
//                            self.outPlanSearchFuncsBean = fb;
//                            if (self.outPlanSearchFuncsBean) {
//                                [self.funcsBeanDic setObject:self.outPlanSearchFuncsBean forKey:@"TAB_V11001"];
//                            }
//                        }else if ([fb.fv isEqualToString:@"TAB_V21002"]){
//                            self.outPlanSearchFuncsBean2 = fb;
//                            if (self.outPlanSearchFuncsBean2) {
//                                [self.funcsBeanDic setObject:self.outPlanSearchFuncsBean2 forKey:@"TAB_V21002"];
//                            }
//
//                        } else if ([fb.fv isEqualToString:@"TAB_V13001"]){ // 资源固定所以 硬编码
//                            self.managV_OutPlanFucsBean = fb;
//                            if (self.managV_OutPlanFucsBean) {
//                                [self.funcsBeanDic setObject:self.managV_OutPlanFucsBean forKey:@"TAB_V13001"];
//                            }
//                        }
//                    }
//                }
//
//            }
//        }
//            break;
//    }
//
//
//}

//获取计划外搜索出来的门店 && 计划外随访实时搜索出来的门店
-(void)addOutPlanStoreNotContainActionNotStartFromDataBaseWithFuncBean:(WSFuncsBean *)funcsBean funcode:(NSString*)funcode{
    
    NSString *empId = self.subempStore ? self.subempStore.Id : [self getCurrentEmpId];
    
    //NSString *modelFc = [self getFuncCodeWithFuncBean:funcsBean andFunBeanDic:self.funcsBeanDic];
    
    WSFuncsBean* subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:funcsBean];
    NSString *modelFc = subMenuFB.fc.length > 0 ? subMenuFB.fc : funcode;
    WSBaseStoreDBService *baseStoreDBSevice = [[WSBaseStoreDBService alloc] init];
//    donghong SFA-22828
    NSArray *visitedStores = [baseStoreDBSevice queryOutPlanVisitingAndVisvitedStoresWithFuncCode:modelFc empId:empId ds:self.currentFuncs.ds];
    
    NSMutableArray *storesCopy = [NSMutableArray array];
    for (WSStoreBean *storeBean in  visitedStores) {
        WSStoreBean *object = [storeBean copy];
        object.mappingStoreFc = funcsBean.fc;
        [storesCopy addObject:object];
        
    }
    [self.storeArray addObjectsFromArray:storesCopy];
}

//-(void)addOutPlanStoreNotContainActionNotStartWithFuncBean:(WSFuncsBean *)funcsBean
//{
//    // (辉瑞医院)
//    NSString *noteNameStr = STORES;
//    if (funcsBean.ds && [funcsBean.ds length] > 0) {
//        noteNameStr = funcsBean.ds;
//    }
//    if (funcsBean.filter && [funcsBean.filter length] > 0) {
//        noteNameStr = funcsBean.filter;
//    }
//    NSArray *noteNameArray = [noteNameStr componentsSeparatedByString:@","];
//    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:1];
//
//
//   WSAbstArrayStoreBean* outstoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
//  if ([funcsBean.styp isKindOfClass:[NSString class]] && [funcsBean.styp length] >0) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp",funcsBean.styp];
//        NSArray *array = [outstoreArray.storesArray filteredArrayUsingPredicate:predicate];
//        [dataArray addObjectsFromArray:array];
//
//  }else{
//      for (NSString *noteName in noteNameArray) {
//          NSString *noteNameString = noteName;
//          if (![noteName isEqualToString:STORES]) {
//              if ([noteName rangeOfString:@"stores:"].location != NSNotFound) {
//                  noteNameString = noteName;
//
//              }else{
//                  noteNameString = [NSString stringWithFormat:@"%@:%@", STORES, noteName];
//              }
//          }
//          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.noteName == %@",noteNameString];
//          NSArray *array = [outstoreArray.storesArray filteredArrayUsingPredicate:predicate];
//          [dataArray addObjectsFromArray:array];
//      }
//
//  }
//   /*过滤掉属于其下属的店*/
//    if (self.currentSubempBean) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == %@",self.currentSubempBean.Id];
//        dataArray = [NSMutableArray arrayWithArray:[dataArray filteredArrayUsingPredicate:predicate]];
//    }
//
//    dataArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:dataArray storeFromFuncs:funcsBean  andFuncsBeanDic:self.funcsBeanDic]];
//
//    for (WSStoreBean *store in dataArray) {
//        if (![store.actionState isEqualToString:ActionNotStart]
//            && ![self.storeArray containsObject:store]) {
//            [self.storeArray addObject:store];
//        }
//    }
//}


//- (void)addNotSearchsubempStoreNotContainActionNotStartWithFuncBean:(WSFuncsBean *)funcsBean {
//    NSMutableArray *subempoutPlanArray = [NSMutableArray array];
//     NSArray *noteArray = [funcsBean.ds componentsSeparatedByString:@","];
//    WSAbstArrayStoreBean* outstoreArray = [WSAppData getObjectbyKey:OUTPLANSTORE];
//
//    if ([funcsBean.styp isKindOfClass:[NSString class]])
//    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp",self.currentFuncs.styp];
//        NSArray *array = [outstoreArray.storesArray filteredArrayUsingPredicate:predicate];
//        [subempoutPlanArray addObjectsFromArray:array];
//    }
//    else {
//
//        for (NSString *noteName in noteArray) {
//            NSString *noteNameString = noteName;
//            if (![noteName isEqualToString:STORES]) {
//                noteNameString = [NSString stringWithFormat:@"%@:%@", STORES, noteName];
//            }
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.noteName == %@",noteNameString];
//            NSArray *array = [outstoreArray.storesArray filteredArrayUsingPredicate:predicate];
//            [subempoutPlanArray addObjectsFromArray:array];
//        }
//
//    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == %@",self.currentSubempBean.Id];
//    subempoutPlanArray = [NSMutableArray arrayWithArray:[subempoutPlanArray filteredArrayUsingPredicate:predicate]];
//    subempoutPlanArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:subempoutPlanArray storeFromFuncs:funcsBean  andFuncsBeanDic:self.funcsBeanDic]];
//    for (WSStoreBean *store in subempoutPlanArray) {
//        if (![store.actionState isEqualToString:ActionNotStart]) {
//            if (![self.storeArray containsObject:store]) {
//                [self.storeArray addObject:store];
//            }
//
//        }
//
//    }
//
//}

//- (void)addSubempStoreNotContainActionNotStartWithFuncBean:(WSFuncsBean *)funcsBean {
//
//    NSMutableArray *allSearchStores = [NSMutableArray array];
//    NSArray *subempStores =  [self querySubEmpStoresFromeDb];
//    NSArray *outPlanSearchedStores = [self queryOutPlanSearchedStoresFromeDb];
//    [allSearchStores addObjectsFromArray:subempStores];
//    [allSearchStores addObjectsFromArray:outPlanSearchedStores];
//    NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:allSearchStores storeFromFuncs:funcsBean  andFuncsBeanDic:self.funcsBeanDic]];
//
//
//    /*排重*/
//    for (WSStoreBean *queryStore in dataArray) {
//        if (![queryStore.actionState isEqualToString:ActionNotStart])
//        {
//
//
//            NSMutableArray *tmpArray = [NSMutableArray array];
//            for (WSStoreBean *tmpStore in self.storeArray)
//            {
//                if (queryStore.Id && tmpStore.Id && [queryStore.Id isEqualToString:tmpStore.Id])
//                {
//                    [tmpArray addObject:tmpStore];
//                }
//            }
//            [self.storeArray removeObjectsInArray:tmpArray];
//
//            /*对于在计划外查询出的计划内门店   显示在计划内时需替换*/
//            WSInPlanStoreBean *inplanStoreBean = [WSAppData getObjectbyKey:INPLANSTORE];
//            WSStoreBean *store = [inplanStoreBean getStoreBeanByID:queryStore.Id];
//            if (store) {
//                store.actionState = queryStore.actionState;
//                if (![self.storeArray containsObject:store]) {
//                    [self.storeArray addObject:store];
//                }
//
//            }else {
//                [self.storeArray addObject:queryStore];
//            }
//        }
//    }
//}

//新增及拜访出现在今日拜访
//- (void)loadAddNewStore{
//
//    NSMutableArray *addStoreVisitedArray =[self filterAddStoreVisited];
//    if (addStoreVisitedArray.count >0) {
//        [self.storeArray addObjectsFromArray:addStoreVisitedArray];
//    }
//}

//- (NSMutableArray *)filterAddStoreVisited{
//
//    if (_addVisitedStores == nil) {
//        _addVisitedStores = [NSMutableArray array];
//    }
//
//    NSMutableArray *addStoreVisitedArray = [[NSMutableArray alloc]init];
//新增及拜访
//    NSString *currentTime =[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];

//！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
/*
 NSArray* newstores = [[WSAddStoreTable sharedTable] queryWithNames:@[@"biz_date"] ArgumentsValue:@[currentTime]];
 if (newstores != nil && newstores.count >0) {
 for (WSAddStoreObject *object in newstores) {
 NSString* storeid = object.store_id;
 NSString* stroename = object.store_name;
 NSString* isplan = object.is_planed;
 WSStoreBean* newstore = [[WSStoreBean alloc] initStoreWithObject:stroename IsPlan:[isplan boolValue]];
 newstore.Id = storeid;
 newstore.name = stroename;
 newstore.plan = [isplan boolValue];
 newstore.mappingStoreListFV = [NSString stringNotNilWithValue:object.func_view];
 
 //排重
 BOOL isNeedAdd = YES;
 for (WSStoreBean *storebean in self.storeArray) {
 if ([storebean.Id isEqualToString:storeid]) {
 isNeedAdd = NO;
 break;
 }
 }
 if (!isNeedAdd ) {
 continue;
 }
 WSFuncsBean *fb = self.currentFuncs;
 WSFuncsBean *subMenuFb = nil;
 
 if ([newstore isKindOfClass:[WSStoreBean class]]) {
 WSFuncsBean *fb_temp =[self selectedOutPlanFuncsBeanWithStore:newstore];
 if (fb_temp ) {
 fb = fb_temp;
 
 WSFuncsBean *nextFb = [fb_temp.funcsArray firstObject];
 if (nextFb  && nextFb.submenu) {
 subMenuFb = [self getSubMenu:nextFb.submenu];
 }
 }
 }
 
 NSString *module_fc = subMenuFb.fc ? subMenuFb.fc :fb.fc;
 //对应新增门店列表的mdule_fc
 //            if (object.func_view && [object.func_view isEqualToString:@"TAB_V8003"]) {
 //                module_fc = object.func_code;
 //            }
 if (module_fc && newstore.Id.length >0) {
 //SFA-562
 if (self.currentFuncs.opt.isUseParentFunc) {
 if ([[WSInoutStoreTable sharedTable] isEnterStore:newstore andOtherParam:module_fc andParamType:EParameterType_ParentFC]) {
 [addStoreVisitedArray addObject:newstore];
 [self.addVisitedStores addObject:newstore];
 
 }
 }
 }
 //
 //            //新增门店列表 新增即拜访的门店也加入今日拜访中
 //            if ([object.func_view isEqualToString:@"TAB_V8003"]) {
 //                module_fc = object.func_code;
 //                if ([[WSInoutStoreTable sharedTable] isEnterStore:newstore andOtherParam:module_fc andParamType:EParameterType_ParentFC]) {
 //
 //                    if ([[WSInoutStoreTable sharedTable] isLeaveStore:newstore andOtherParam:module_fc andParamType:EParameterType_ParentFC]) {
 //
 //                        [addStoreVisitedArray addObject:newstore];
 //                    }
 //                }
 //            }
 
 }
 }
 */
//    return addStoreVisitedArray;
//
//}


#pragma mark - tableview
/*
 旧的重复代码,已整合---sunhongfu 2018-1-16
 旧的跳转逻辑
 - (BOOL) gotoNextPageWithStoreBean:(WSStoreBean*)store
 {
 self.currentStore = store;
 
 WSFuncsBean *fb = nil;
 
 WSFuncsBean *subMenuFB = nil;
 
 BOOL isPlan = NO;
 
 if (store.plan) {
 
 fb = self.currentFuncs;
 isPlan = YES;
 
 }else{
 
 //        if ([store.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
 //            fb = self.storeListFucsBean;
 //        } else {
 fb = [self selectedOutPlanFuncsBeanWithStore:store];
 
 subMenuFB = [WSFuncsBeanFilterLogicService getSubMenuFuncsBeanByCurrentFB:fb];
 //}
 
 
 isPlan = NO;
 }
 
 if(![self anyStoreHasNotLeave:store andModuleFC:subMenuFB.fc ? subMenuFB.fc : fb.fc])
 
 return NO;
 
 if (isPlan) {
 
 //! 中粮特有
 //  是否可以重复访店，默认和 R 为可以，N 为不可以
 
 if (self.currentFuncs.repeatvisit != nil && [self.currentFuncs.repeatvisit isEqualToString:@"N"]) {
 if ([self isVisitedStore:store]) {
 
 NSString *cannotRepeatVisit = NSLocalizedString(@"该店已完成今日稽核数据提报，您不能再进店查看或修改。", nil);
 
 [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:cannotRepeatVisit tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
 
 return NO;
 }
 }
 
 //设置拜访节点
 NSLog(@"==>>>>> %@",self.currentVisitAction);
 WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
 action.parent_action_id = self.currentVisitAction.ID;
 NSString *entryid = [store isKindOfClass:[WSStoreBean class]] ? store.Id:@"";
 action.store_id = entryid //self.currentStore.Id;
 action.func_code = self.currentFuncs.fc;
 action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
 action.emp_id = [self getCurrentEmpId];
 action.title = self.currentFuncs.name;
 action.module_fc = action.func_code;
 action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
 
 WSWorkFlowViewController* wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs
 Store:store
 subEmpStore:self.subempStore ? self.subempStore :nil];
 wfvc.input_reflect_code = self.currentFuncs.fc ;
 self.currentViewController = wfvc;
 //Add title
 wfvc.title = store.name;
 wfvc.currentVisitAction = action;
 wfvc.moduleFC = action.func_code;
 LogInfo(@"Going to class WSWorkFlowViewController");
 
 //计划内随访时需要实时请求数据
 if (store.storeAccessMode == WSStoreAccessModeSubEmp || (store.noteName && [store.noteName rangeOfString:@"subemp"].location != NSNotFound)) {
 
 [self startUpdata:store];
 
 return YES;
 }
 
 [self gotoWorkFlowController:wfvc];
 
 self.currentViewController = nil;
 
 }else{
 
 NSString *noteName = OUTPLANSTORE;
 if (fb.filter && [fb.filter length] > 0) {
 noteName = fb.filter;
 }
 
 if (![fb.opt.isIntentToStore isEqualToString:@"Y"]) {
 if(![self anyStoreHasNotLeave:store andModuleFC:subMenuFB.fc ? subMenuFB.fc : fb.fc])
 return NO;
 
 WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
 NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
 BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
 if (!isRequested) {
 [self startUpdataOutPlan:store];
 
 }else {
 [self goOutPlanNextWorkView];
 }
 }
 else
 {
 WSFuncsBean* nextfb = [fb.funcsArray objectAtIndex:0];
 NSString *className = [WSPlistHelper valueForKey:nextfb.fv withPlistName:kControllerMappingFileName];
 UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:nextfb Store:self.currentStore];
 
 //设置访问节点
 WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
 action.parent_action_id = self.currentVisitAction.ID;
 
 
 action.store_id = self.currentStore.Id;
 action.func_code = fb.fc;
 action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
 action.emp_id = [self getCurrentEmpId];
 action.title = fb.name;
 action.module_fc = subMenuFB.fc ? subMenuFB.fc : fb.fc;
 action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
 
 vc.currentVisitAction = action;
 if ([vc isKindOfClass:[WSWorkFlowViewController class]]) {
 
 WSWorkFlowViewController* wsvc = (WSWorkFlowViewController *)vc;
 wsvc.moduleFC = action.func_code;
 
 }
 
 vc.hidesBottomBarWhenPushed = YES;
 
 if (self.ownParentViewController) {
 [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
 } else {
 [self.navigationController pushViewController:vc animated:YES];
 }
 }
 }
 return YES;
 }
 */

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
    NSString* funcCode = self.subMenuFuncsCode ? self.subMenuFuncsCode : self.currentFuncs.fc;
    
    if (![WSNewStoreListTool anyStoreHasNotLeave:store andModuleFC:funcCode withCurrentFuncs:self.currentFuncs]) return;
    
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
    action.emp_id = [self getCurrentEmpId];
    action.title = self.currentFuncs.name;
    action.module_fc = action.func_code;
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    if (isSelf)
    {
        //如果是计划内或者isIntentToStore不等于Y的时候初始化一样的VC
        if (store.plan || ![fb.opt.isIntentToStore isEqualToString:@"Y"])
        {
            wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:[self getRealFuncBeanNeedSubMenu:YES]Store:store subEmpStore:self.subempStore ? self.subempStore :nil unredo:self.currentFuncs.unredo];
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
                UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:nextfb Store:self.currentStore unredo:self.currentFuncs.unredo ? :nil];
                vc.currentVisitAction = action;
                if ([vc isKindOfClass:[WSWorkFlowViewController class]])
                {
                    wfvc = (WSWorkFlowViewController *)vc;
                    wfvc.moduleFC = action.func_code;
                    self.currentViewController = wfvc;
                }
                //Y的时候不需要设置 title input_reflect_code等的值
                return vc;
            }
        }
    }
    else
    {
        wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:[self getRealFuncBeanNeedSubMenu:YES] Store:store];
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

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSStoreBean* store = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems]) {
        store = [self.storeArray objectAtIndex:indexPath.row];
    }
    else {
        if (0 == indexPath.section) {
            store = [self.notVisitStoreArray objectAtIndex:indexPath.row];
        }
        else {
            store = [self.visitedStoreArray objectAtIndex:indexPath.row];
        }
    }
    
    if ([store.state isEqualToString:@"0"]) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"此门店为不活跃门店，请修改门店状态", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    if (self.prepareFuncBean && [self.prepareFuncBean.required isEqualToString:@"R"]) {
        WSStorePrepareState prepareState = [self getPrepareStateByStore:store];
        if (prepareState == WSStorePrepareStateNotPrepare) {
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"prepare_before_visit", nil)  tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }

    if (self.currentFuncs.opt.storeListAcvtCode.length > 0) {
        WSBaseAcvtdisDBService *acvtdisDBService = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *array = [acvtdisDBService queryAcvtDisWithStoreId:store.Id acvtCode:self.currentFuncs.opt.storeListAcvtCode qstType:@"T"];
        store.auxiliaryInfoArray = array;
    }
    
    BOOL isForceLeaveStore = [[WSInoutStoreTable sharedTable] isForceLeaveStoreWithStore:store];
    if (isForceLeaveStore) {
        NSString *str = NSLocalizedString(@"forceLeaveStore_tip", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    BOOL isExistStoreOptRemind = [self isExistStoreOptRemindWithStoreBean:store];
    if (isExistStoreOptRemind) {
        return;
    }
    
    NSString *jumpFc = [[NSUserDefaults standardUserDefaults] objectForKey:TAB_JUMP_FC];
    if (jumpFc.length > 0) {
        [self checkNeedRequestAndGoSpecialController:store withFc:jumpFc];
    }
    else {
        [self gotoNextPageWithStoreBean:store];
    }
}

- (void)checkNeedRequestAndGoSpecialController:(WSStoreBean *)store withFc:(NSString *)fc {
    
    self.currentStore = store;
    
    if (store.storeAccessMode == WSStoreAccessModeSubEmp || (store.noteName && [store.noteName rangeOfString:@"subemp"].location != NSNotFound)) {
        [self startUpdata:store];
    }
    else {
        [self gotoSpecialViewController:store withFc:fc];
    }
}

-(void)startUpdataOutPlan:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequestOutPlan:)
                                                 name:UPDATA_NOTIFY
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataOutPlanInfo:store subEmpStore:nil notifyName:UPDATA_NOTIFY];
    
    [self querying_messageTips];
    
}

-(void)finishRequestOutPlan:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UPDATA_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    //NSLog(@"outplan is %@",info);
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        NSObject *tmpObject = uploadState[[self getOutPlanObjID]];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
        }
        
        if(self.currentStore != nil){
            [self.currentStore reSetStore:uploadState Key:[self getOutPlanObjID]];
            if ([WSEnvrionment  getStoreDataFromDb]) {
                
                [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
            }
        }
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        //获得要跳转的VC
        WCBaseViewController *vc = (WCBaseViewController *)[self generateNextVCWithFuncsBean:self.currentFuncs store:self.currentStore isSelf:YES];
        
        [self gotoWorkFlowController:vc];
    }
}

- (NSString *)getOutPlanObjID
{
    //    NSString *objId;
    //    WSFuncsBean * fb = [self selectedOutPlanFuncsBeanWithStore:self.currentStore];
    //    WSFuncsBean *subFunc = nil;
    //    if (fb.funcsArray != nil && [fb.funcsArray count] > 0) {
    //          subFunc = [fb.funcsArray objectAtIndex:0];
    //    }
    ////    if (self.outPlanFuncsBean.funcsArray != nil && [self.outPlanFuncsBean.funcsArray count] > 0) {
    ////        subFunc = [self.outPlanFuncsBean.funcsArray objectAtIndex:0];
    ////    }
    //
    //    if (subFunc != nil && subFunc.filter != nil && [subFunc.filter length] > 0) {
    //        objId = subFunc.filter;
    //    }
    //    else{
    //        objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    //    }
    //
    //    NSLog(@"getObjID :%@",subFunc.filter);
    
    //    return objId;
    // 今日拜访模块  计划外门店请求数据统一用 ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME 节点名
    return ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
}

/*
 旧的重复代码,已整合---sunhongfu 2018-1-16
 - (UIViewController *)generateNextVCWithFuncsBean:(WSFuncsBean *)fb   store:(WSStoreBean*)store {
 self.currentStore = store;
 self.currentFuncs = fb;
 
 //设置拜访节点
 NSLog(@"==>>>>> %@",self.currentVisitAction);
 WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
 action.parent_action_id = self.currentVisitAction.ID;
 NSString *entryid = [store isKindOfClass:[WSStoreBean class]] ? store.Id:@"";
 action.store_id = entryid  //self.currentStore.Id;
 action.func_code = self.currentFuncs.fc;
 action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
 action.emp_id = [self getCurrentEmpId];
 action.title = self.currentFuncs.name;
 action.module_fc = action.func_code;
 action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
 
 WSWorkFlowViewController* wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:store];
 wfvc.input_reflect_code = self.currentFuncs.fc ;
 self.currentViewController = wfvc;
 //Add title
 wfvc.title = store.name;
 wfvc.currentVisitAction = action;
 wfvc.moduleFC = action.func_code;
 LogInfo(@"Going to class WSWorkFlowViewController");
 return wfvc;
 }
 
 -(void)goOutPlanNextWorkView
 {
 // 如果进入到了 此页面无论这家门店是从何处来的，那么他最后引用的菜单一定是  当前的funcs 不用去找对应的菜单
 WSWorkFlowViewController* wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:self.currentStore subEmpStore:self.subempStore ? self.subempStore : nil];
 // Add UIViewController
 if ([self.currentStore.name isKindOfClass:[NSString class]] && ![self.currentStore.name isEqualToString:@""]) {
 wfvc.title = self.currentStore.name;
 }
 
 //设置访问节点
 WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
 action.parent_action_id = self.currentVisitAction.ID;
 action.store_id = self.currentStore.Id;
 action.func_code = self.currentFuncs.fc;
 action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
 action.emp_id = [self getCurrentEmpId];
 action.title = self.currentFuncs.name;
 action.module_fc = self.currentFuncs.fc;
 action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
 wfvc.currentVisitAction = action;
 wfvc.moduleFC = self.currentFuncs.fc;
 
 LogInfo(@"Going to class WSWorkFlowViewController");
 
 [self gotoWorkFlowController:wfvc];
 
 self.currentViewController = nil;
 
 }
 */

- (WSFuncsBean*) selectedOutPlanFuncsBeanWithStore:(WSStoreBean *)store
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsBeanArray getFuncsBeanWithFC:store.mappingStoreFc];
    
    //    if (!store.plan) {
    //        if (store.noteName  && [store.noteName isEqualToString:@"newstore"]) {
    //            fb = self.newstoreFuncsBean;
    //        }else if ([store.mappingStoreListFV isEqualToString:@"TAB_V8003"]){
    //            fb = self.storeListFucsBean;
    //        }else if (store.mappingStoreListFC != nil && [store.mappingStoreListFC rangeOfString:@"TAB_F2002"].location != NSNotFound){
    //            fb = self.outPlanFuncsBean_FC_IS_TAB_F2002;
    //        } else{
    //            if (self.outPlanSearchFuncsBean) {
    //                fb = self.outPlanSearchFuncsBean;
    //            }else if (self.outPlanSearchFuncsBean2){
    //                fb = self.outPlanSearchFuncsBean2;
    //            }else if (self.outPlanFuncsBean) {
    //                fb = self.outPlanFuncsBean;
    //            }else if (self.managV_OutPlanFucsBean){
    //                fb = self.managV_OutPlanFucsBean;
    //            }
    //        }
    //    }
    
    return fb;
}

//- (NSArray *)gainImmediatelyVistStoreListWithFuncsBean:(WSFuncsBean *) fb andStoreArray:(NSArray *)storeArray {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
//    NSArray *newStoreArray = [[WSAddStoreTable sharedTable] queryImmediatelyVistStore];
//
//    if (newStoreArray) {
//        BOOL isNewStorePage = NO;
//        if (fb.ds && [fb.ds isEqualToString:@"newstore"]) {
//            isNewStorePage = YES;
//        }
//
//        for (WSAddStoreObject *object in newStoreArray) {
//            NSString *storeid = object.store_id;
//            if ( storeid && ![storeid isEqualToString:@"<null>"])
//            {
//                BOOL needAdd = NO;
//                NSString *isPlaned = object.is_planed;
//                if (isNewStorePage && isPlaned && [isPlaned isEqualToString:@"1"]) {
//                    needAdd = YES;
//                }else if (!isNewStorePage && isPlaned && [isPlaned isEqualToString:@"0"]) {
//                    needAdd = YES;
//                }
//
//                if (needAdd) {
//                    BOOL isExist = NO;
//                    //排重
//                    for (WSStoreBean *storeBean in storeArray) {
//                        if ([storeBean.Id isEqualToString:storeid]) {
//                            isExist = YES;
//                            break;
//                        }
//                    }
//
//                    if (isExist) {
//                        continue;
//                    }
//
//                    WSStoreBean *item = [[WSStoreBean alloc] init];
//                    item.styp = object.store_type;
//                    item.sv = @"";
//                    item.name = object.store_name;
//                    item.code = object.store_code;
//                    item.Id = storeid;
//                    item.plan = NO;
//                    item.noteName = @"newstore";
//                    [array addObject:item];
//                }
//            }
//        }
//    }
//    if (!array) {
//        return nil;
//    }
//    return [NSArray arrayWithArray:array];
//}
#pragma mark - old code

+(void)setCurrentCategory:(NSString *)aCategory
{
    category = aCategory;
}

+(NSString *) currentCategory
{
    return category;
}

-(BOOL)isEnterStoreBeforeToday:(WSStoreBean *)aStore
{
    double enterTime = [[[WSInoutStoreTable sharedTable] getEnterStoreTime:aStore andOtherParam:self.currentFuncs.iParentFuncsBean.fc andParamType:EParameterType_ParentFC] doubleValue];
    double currentTime = [[WSCurrentTime getServerTime] doubleValue];
    
    NSDateFormatter *formatDate = [NSDateFormatter standardDateFormatter];
    [formatDate setDateFormat:@"yyyy-MM-dd"];
    
    NSString *enterDate = [formatDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:enterTime ]];
    NSString *currentDate = [formatDate stringFromDate:[NSDate dateWithTimeIntervalSince1970:currentTime ]];
    
    if ([enterDate isEqualToString:currentDate]) {
        return false;
    }
    return true;
    
}

- (void)generateVisitInfoArray {
    self.visitedStoreArray = [[NSMutableArray alloc] init];
    self.notVisitStoreArray = [[NSMutableArray alloc] init];
    
    for (WSStoreBean *item in self.storeArray)
    {
        
        if (!item.name || item.name == (NSString*)[NSNull null])
        {
            continue;
        }
        
        if ([[WSInoutStoreTable sharedTable] isEnterStore:item andOtherParam:self.currentFuncs.iParentFuncsBean.fc andParamType:EParameterType_ParentFC] && ![self isEnterStoreBeforeToday:item])
        {
            [self.visitedStoreArray addObject:item];
        }
        else
        {
            [self.notVisitStoreArray addObject:item];
        }
    }
    
}
- (void)addFinished
{
    [self.storeArray removeAllObjects];
    
    [self initDataArrayFromDb];
    [self addAddedStores];
    if (self.hasVisitType) {
        [self generateVisitInfoArray];
    }
    [self.tableView reloadData];
}

- (void)uploadWithName:(NSString *)storename {
    self.currentAddStoreName = storename;
}
#pragma mark - init
//
-(instancetype)initWithFuncs:(WSFuncsBean*)funcs Stores:(NSArray *)stores{
    if (funcs==nil||stores==nil) {
        return nil;
    }
    self = [super init];
    if(self)
    {
        self.todayVisitCategory = WSTodayVisitCategoryInPlan;
        self.currentFuncs=funcs;
        self.title=funcs.name;
        
        [self.storeArray addObjectsFromArray:stores];
        return self;
    }
    return nil;
}


-(instancetype)initWithFuncs:(WSFuncsBean*)funcs SubempStoreBean:(WSSubempstoreBean *)subempStoreBean {
    if (funcs == nil || subempStoreBean == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.todayVisitCategory = WSTodayVisitCategoryNormal;
        self.currentFuncs=funcs;
        self.subempStore = subempStoreBean;
        self.title=funcs.name;
        //        if ([WSEnvrionment  getStoreDataFromDb]) {
        //            [self addSubEmpInplanStoresFromDb];
        //        }else {
        //            [self addSubEmpInplanStores];
        //        }
        
        //        if ([self.currentFuncs.styp isKindOfClass:[NSString class]])
        //        {
        //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp",self.currentFuncs.styp];
        //            self.storeArray = [NSMutableArray arrayWithArray:[self.storeArray filteredArrayUsingPredicate:predicate]];
        //        }
        return self;
    }
    return nil;
}


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.todayVisitCategory = WSTodayVisitCategoryNormal;
        self.currentFuncs = funcs;
        self.title = funcs.name;
        
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:self.currentFuncs.fv];
        
        return self;
    }
    return nil;
}

-(void)initnavigatBarItem{
    if (self.ownParentViewController) {
        self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
        self.ownParentViewController.navigationItem.rightBarButtonItems= nil;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItems=nil;
    }
}

/*searchObjId 初始化数据不一样  还有empId值不一样*/
//- (void)addSubEmpInplanStoresFromDb{
//    self.storeArray = [[NSMutableArray alloc]init];
//    NSString *defalutSearch_objId = STORES_SUBEMPINSTORE;
//    NSString *empId = self.subempStore.Id;
//    self.storeArray = [self queryStoresFromDbWithFuncs:self.currentFuncs searchObjId:defalutSearch_objId empId:empId];
//    self.allSubempInplanCount = [self.storeArray count];
//}

//- (void)addSubEmpInplanStores
//{
//    self.storeArray = [[NSMutableArray alloc]init];
//
//    NSString *noteName = INPLANSTORE;
//
//    // 辉瑞医院 hos 节点单独处理
//    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
//    if (projectName != nil && [projectName isEqualToString:@"pfizer"] && [self.currentFuncs.ds isEqualToString:@"hos"]) {
//        noteName = @"hos";
//    } else if (self.currentFuncs.filter) {
//        noteName = self.currentFuncs.filter;
//    }
//    WSInPlanStoreBean* inPanStores = [WSAppData getObjectbyKey:noteName];
//    if ([WSTodayVisitViewController currentCategory] == nil)
//    {
//        if ([self.currentFuncs.styp isKindOfClass:[NSString class]] || [self.currentFuncs.styp  isKindOfClass:[NSString class]])
//        {
//            NSString *filterStyp = self.currentFuncs.styp ? self.currentFuncs.styp:self.currentFuncs.styp;
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp",filterStyp];
//            NSArray *array = [inPanStores.storesArray filteredArrayUsingPredicate:predicate];
//            [self.storeArray addObjectsFromArray:array];
//        }
//        else
//        {
//            [self.storeArray addObjectsFromArray:inPanStores.storesArray];
//        }
//    }
//    else
//    {
//        for (WSStoreBean *storebean in inPanStores.storesArray)
//        {
//            if ([storebean.name isKindOfClass:[NSString class]] && [storebean.styp isEqualToString:[WSTodayVisitViewController currentCategory]])
//            {
//                [self.storeArray addObject:storebean];
//            }
//        }
//    }
//
//
//    /*过滤掉属于其下属的店*/
//    if (self.currentSubempBean) {
//        if (self.currentFuncs.ds) {
//            //配了ds：就根据节点去找
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == %@ and self.noteName = %@",self.currentSubempBean.Id,self.currentFuncs.ds];
//            self.storeArray = [NSMutableArray arrayWithArray:[self.storeArray filteredArrayUsingPredicate:predicate]];
//        }else{
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == %@",self.currentSubempBean.Id];
//            self.storeArray = [NSMutableArray arrayWithArray:[self.storeArray filteredArrayUsingPredicate:predicate]];
//        }
//
//    }else {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.srid == nil"];
//        self.storeArray = [NSMutableArray arrayWithArray:[self.storeArray filteredArrayUsingPredicate:predicate]];
//    }
//
//    self.allSubempInplanCount = [self.storeArray count];
//}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addFinished) name:newStoreNotification object:nil];
    //在iOS 6和 之后 UITableViewStyleGrouped有很大的差别
    UITableView* tv;
    
    if ([WSEnvrionment getStoreDataFromDb]) {
        tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        //        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else {
        if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
            
            tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
            
        } else {
            
            tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        }
    }
    
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    tv.backgroundColor = [UIColor whiteColor];
    
    if (INTERFACE_IS_PAD) {
        tv.backgroundColor = RGBCOLOR(246, 246, 246);
    }
    
    tv.backgroundView = nil;
    
    tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tv setDelegate:self];
    
    [tv setDataSource:self];
    //    WSMyCustomerTitleView  *cusView = [[WSMyCustomerTitleView alloc]initWithFrame:CGRectZero style:WSMyCustomerTitleViewStyleAddNewVisit];
    //    cusView.delegate = self;
    //    cusView.height = 60;
    //    tv.tableHeaderView = cusView;
    
    //    WSCalendarView * calendar = [[WSCalendarView alloc]initWithFrame:CGRectZero];
    //    calendar.delegate = self;
    //    calendar.height = 60;
    //    tv.tableHeaderView = calendar;
    self.tableView = tv;
    
    tv.scrollEnabled = YES;
    
    [self.view addSubview:self.tableView];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
#endif
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newStoreNotification object:nil];
}
- (BOOL)categoryInNoTypeItems
{
    BOOL ret = FALSE;
    for (NSString *item in self.noTypeItems)
    {
        if ([category isEqualToString:item])
        {
            ret = TRUE;
            break;
        }
    }
    return ret;
}
#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.hasVisitType || [self categoryInNoTypeItems]) {
        return 1;
    }
    else
    {
        if (![self.visitedStoreArray count]) {
            return 1;
        }
        return 2;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        return nil;
    }
    else
    {
        if (0 == section) {
            return @"未访问";
        } else {
            return @"已访问";
        }
    }
}
//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        return [self.storeArray count];
    }
    else {
        if (0 == section) {
            return [self.notVisitStoreArray count];
        } else {
            return [self.visitedStoreArray count];
        }
    }
    
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id item = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        item = [self.storeArray objectAtIndex:indexPath.row];
    }
    else
    {
        if (0 == indexPath.section)
        {
            item = [self.notVisitStoreArray objectAtIndex:indexPath.row];
        }
        else
        {
            item = [self.visitedStoreArray objectAtIndex:indexPath.row];
        }
    }
    
    if ([item isKindOfClass:[WSStoreBean class]]) {
        WSStoreBean *rowStore = item;
        if ([self.currentFuncs.opt.showStyle isEqualToString:@"compactStyle"])
        {
            return [WSNewTodayVisitAndAllStoreCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
        }
        else
        {
            return UITableViewAutomaticDimension;

//            return [WSSelectListNewTableviewCell  heightForRowWithStore:rowStore cellWidth:self.tableView.width isHavePrepareButton:self.prepareFuncBean?YES:NO withOpt:self.currentFuncs.opt];
            
        }
        
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    WSStoreBean* store = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        store = [self.storeArray objectAtIndex:indexPath.row];
    }
    else
    {
        if (0 == indexPath.section) {
            store = [_notVisitStoreArray objectAtIndex:indexPath.row];
        }
        else {
            store = [_visitedStoreArray objectAtIndex:indexPath.row];
        }
    }
    
    UIViewController *storeInfo = nil;
    
    if ([self.currentFuncs.isStoreInfo isEqualToString:@"1"]) {
        storeInfo = [[WSStoreInfoViewController alloc]
                     initWithStoreInfo:store];
    }
    else if ([self.currentFuncs.isStoreInfo isEqualToString:@"3"])
    {
        storeInfo = [[WSPfizerEtripModifyStoreInfoViewController alloc] initWithFuncs:self.currentFuncs store:store storeInfoDic:nil];
    }
    
    
    NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
    storeInfo.title = StoreInforString;
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:storeInfo animated:YES];
}

//获取门店名称
- (NSString *)getContentWithCurrentBean:(WSFuncsBean *)currentFuncsbean withCurrentStoreBean:(WSStoreBean *)storeBean{
    
    NSString *content = nil;
    if ([currentFuncsbean.opt.isCode isKindOfClass:[NSString class]] && [currentFuncsbean.opt.isCode isEqualToString:@"0"])
    {
        if (storeBean)
        {
            content = storeBean.name;
        }
    }
    else
    {
        if (storeBean)
        {
            content = [NSString stringWithFormat:@"%@",storeBean.name];
            if (storeBean.code && [storeBean.code length] > 0)
            {
                content = [NSString stringWithFormat:@"%@-%@", storeBean.code, storeBean.name];
            }
            if (storeBean.bfnum && [storeBean.bfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@-%@", content, [NSString stringWithFormat:@"拜访%@",storeBean.bfnum]];
            }
            if (storeBean.sfnum && [storeBean.sfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@%@%@", content, [storeBean.bfnum length] > 0 ? @"/" : @"-",[NSString stringWithFormat:@"随访%@",storeBean.sfnum]];
            }
            
        }
    }
    
    return content ;
}


#pragma mark - private API
- (void)addAddedStores
{
    if (category)
    {
        NSString *setFilter = [self.shouldAddFilters objectForKey:category];
        if (setFilter)
        {
            UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_label",nil)
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(addStore:)];
            if (self.ownParentViewController)
            {
                self.ownParentViewController.navigationItem.rightBarButtonItem = buttonItem;
            }
            else
            {
                self.navigationItem.rightBarButtonItem = buttonItem;
            }
            [self.storeArray addObjectsFromArray:[self generateAddedArray]];
        }
    }
}

/**/
- (NSMutableArray *)queryStoresFromDbWithFuncs:(WSFuncsBean *)funcsBean searchObjId:(NSString *)search_objId empId:(NSString *)empId {
    NSString *styp = self.currentFuncs.styp;
    // SFA-15730 所有门店才需要使用 filter
    //    if ([funcsBean.filter length] >  0) {
    //        search_objId = self.currentFuncs.filter;
    //    }else if ([funcsBean.ds length] > 0) {
    //        search_objId = self.currentFuncs.ds;
    //    }
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSDictionary *otherDic = @{kStoreDBOtherData_isFollowStore : [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore]};
    
    NSString* funcCode = self.subMenuFuncsCode ? self.subMenuFuncsCode : self.currentFuncs.fc;

    if (self.currentFuncs.opt.parentStoreFc==nil) {
        //门店互通
        NSArray * fcList = [[[WSSqliteUtil alloc]init] queryParentfcWithCurrentfc:self.currentFuncs.fc];
        if (fcList.count>0) {
            funcCode = [fcList componentsJoinedByString:@","];
        }
    }
    
    return [[WSBaseStoreDBService  shareInstance] queryInPlanStoresWithFuncCode:funcCode empId:empId  search_objId:search_objId styp:styp biz_date:biz_date storeAccessMode:[self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal otherDataDic:otherDic];
}

/*计划外搜索出来的门店*/
/*- (NSArray *)queryOutPlanSearchedStoresFromeDb {
 NSMutableDictionary *outPlanSearchDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:OUT_PAN_SEARCH_STORE];
 NSString *objId = [outPlanSearchDictionary objectForKey:@"objId"];
 NSString *empId = [self getCurrentEmpId];
 return [self queryStoreWithObjId:objId empId:empId];
 }*/

/**
 获取计划外随访实时搜索出来的门店
 */
/*- (NSMutableArray *)querySubEmpStoresFromeDb {
 NSString * serch_objID=@"subempoutstore";
 if(self.currentFuncs.ds && [self.currentFuncs.ds rangeOfString:@"stores:"].length>0){
 serch_objID=@"stores:subempoutstore";
 }
 if(self.managV_OutPlanFucsBean.filter && self.managV_OutPlanFucsBean.filter.length>0){
 serch_objID=[NSString stringWithString:self.managV_OutPlanFucsBean.filter];
 }
 return [self queryStoreWithObjId:serch_objID empId:self.currentSubempBean.Id];
 }*/


/*- (NSMutableArray *)queryStoreWithObjId:(NSString *)objId  empId:(NSString *)empId{
 NSMutableArray *stores = [NSMutableArray array];
 NSArray *names = [NSArray arrayWithObjects:@"search_objId",@"empid",nil];
 NSArray *values = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:objId], [NSString stringNotNilWithValue:empId],nil];
 NSArray *baseStores = [[WSBaseStoreTable sharedTable] queryWithNames:names ArgumentsValue:values];
 [baseStores enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
 WSStoreBean *currentStore = [[WSStoreBean alloc] init];
 [currentStore setStoreWith:(WSBaseStoreObject *)obj];
 currentStore.noteName = objId;
 [stores addObject:currentStore];
 }];
 return stores;
 
 }*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0f)];
    return headView;
}



#pragma - mark WSMyCustomerTitleViewDelegate
-(void)queryStoresFromDBWithConditions:(NSString *)conditions{
    NSArray * conditionArray = [conditions componentsSeparatedByString:@";"];
    //    NSString * type = conditionArray[0];
    NSString * searchNameOrCode = conditionArray[1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.code = %@ and SELF.name contains[cd] %@ or SELF.code contains[cd] %@",@"10000329" ,searchNameOrCode, searchNameOrCode];
    NSArray *array = [self.storeArray filteredArrayUsingPredicate:predicate];
    self.storeArray = array.mutableCopy;
    [self.tableView reloadData];
    
    // 如果删除输入的搜索内容则 table应显示默认加载的数据
    if ([searchNameOrCode isEqualToString:@""]) {
        [self initDataArrayFromDb];
        [self.tableView reloadData];
    }
    
}
#pragma - mark WSCalendarViewDelegate   点击日历根据日期过滤拜访计划
-(void)queryDataFromDBByDate:(NSDate *)date{
    NSDateFormatter * formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString * searchDate = [formatter stringFromDate:date];
    NSString *empId = [self getCurrentEmpId];
    NSString *styp = self.currentFuncs.styp;
    NSString * search_objId = STORES ;
    
    if ([self.currentFuncs.filter length] >  0)
        search_objId = self.currentFuncs.filter;
    else if ([self.currentFuncs.ds length] > 0)
        search_objId = self.currentFuncs.ds;
    
    NSDictionary *otherDic = @{kStoreDBOtherData_isFollowStore : [NSString stringNotNilWithValue:self.currentFuncs.opt.followStore]};
    
    self.storeArray =  [[WSBaseStoreDBService  shareInstance] queryInPlanStoresWithFuncCode:self.currentFuncs.fc empId:empId  search_objId:search_objId styp:styp biz_date:searchDate storeAccessMode:[self.subempStore.Id length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal otherDataDic:otherDic];
    [self.tableView reloadData];
    
}
- (void)addStore:(id)sender
{
    if (category)
    {
        WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *l_fb;
        NSString *funcPath = [self.shouldAddFilters objectForKey:category];
        l_fb = [fba getFuncsBeanFromSubFC:funcPath];
        
        WSAddNewStoreViewController *l_newStoreVC = [[WSAddNewStoreViewController alloc] initWithFuncs:l_fb ];
        l_newStoreVC.currentStore=self.currentStore;
        if(self.ownParentViewController)
        {
            self.ownParentViewController.hidesBottomBarWhenPushed = YES;
            [self.ownParentViewController.navigationController pushViewController:l_newStoreVC animated:YES];
        }
        else
        {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:l_newStoreVC animated:YES];
        }
    }
}


- (NSArray *)generateAddedArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
    //    NSArray* objectArray=[[WSAddStoreTable sharedTable] queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID"] ArgumentsValue:@[[WSCurrentTime getDateString],@"1",[WSAppData getObjectbyKey: APPDATA_EMPID]]];
    //    for (WSAddStoreObject *object in objectArray)
    //    {
    //        WSStoreBean *item = [[WSStoreBean alloc] init];
    //        NSString *storeType = object.store_type;
    //        if (category != nil) {
    //            if (storeType && [storeType respondsToSelector:@selector(rangeOfString:)]&& ([storeType rangeOfString:category].location != NSNotFound)) {
    //                item.styp = category;
    //                item.sv = @"";
    //                item.name = object.store_name;
    //                item.Id = object.store_id;
    //                item.code = object.store_code;
    //                [array addObject:item];
    //            }
    //        }
    //    }
    return [NSArray arrayWithArray:array];
}

#pragma mark - 随访时计划内需要实时获取数据

-(void)startUpdata:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:INPLAN_UPDATA_NOTIFY
                                               object:nil];
    
    NSString* empId = [self getCurrentEmpId];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:@"1" forKey:@"compress"];
    
    [dic setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    
    [dic setObject: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME forKey:@"objId"];
    
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    
    //空岗时候没有empId，传@""即可
    [dic setObject:[NSString stringNotNilWithValue:store.empId] forKey:@"empId"];
    /*
     [dic setValue:self.currentSubempBean.Id forKey:@"srid"];
     */
    
    [[WSRequestHelper shareInstance] uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:INPLAN_UPDATA_NOTIFY md5:nil isUpload:NO];
    
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    [self querying_messageTips];
    
}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:INPLAN_UPDATA_NOTIFY
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        
        NSDictionary *uploadState = [info objectFromJSONString];
        
        NSDictionary* vflag=[[uploadState objectForKey: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME] firstObject];
        if([vflag objectForKey:@"vflag"]){
            NSNumber* vflagNumber=[vflag objectForKey:@"vflag"];
            if(vflagNumber.integerValue==0){
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"代表未进店" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                return;
            }
            
        }
        
        if (self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp) {
            [self.currentStore reSetStore:uploadState Key: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
        }
        if ([WSEnvrionment  getStoreDataFromDb]) {
            NSObject *tmpObject = uploadState[ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
            NSDictionary *storeDicInfo = nil;
            if ([tmpObject isKindOfClass:[NSDictionary class]]) {
                storeDicInfo = (NSDictionary *)tmpObject;
            }else if ([tmpObject isKindOfClass:[NSArray class]]) {
                storeDicInfo = [(NSArray *)tmpObject firstObject];
            }
            if ([[storeDicInfo allKeys] count] > 0) {
                [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
                NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
                [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
            }else {
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"提示！" tips:@"返回门店数据为空!" tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:1.50f];
                return;
            }
        }
        //        // 处理回显节点数据内容
        ////        [self dealWithStoreDictdis:uploadState];
        //        [WSStoreDataProcessService processStoreDisDataWithDic:uploadState objID: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME storeID:self.currentStore.Id];
        //        // 处理巡访提醒节点
        ////        [self dealWithStoreInfo:uploadState withNodeName: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME withFilter:self.currentFuncs.filter];
        //        [WSStoreDataProcessService processStoreInfoDataWithDic:uploadState objID: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME filter:self.currentFuncs.filter];
        //
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        NSString *jumpFc = [[NSUserDefaults standardUserDefaults] objectForKey:TAB_JUMP_FC];
        if (jumpFc.length > 0) {
            [self gotoSpecialViewController:self.currentStore withFc:jumpFc];
        }else{
            [self gotoWorkFlowController:self.currentViewController];
            self.currentViewController = nil;
        }

    }
    
}


//过滤shortCut拜访项
- (NSArray *)filterShortCutFuncsBean{
    
    WSFunsShortCutData *data = [[WSFunsShortCutData alloc]init];
    
    NSArray *array = [[NSArray alloc]init];
    
    array = [data filterShortCutData:self.currentFuncs];
    
    return array;
    
}

#pragma mark - 辉瑞零售详情快捷键

- (void)selectListTableViewCell:(WSSelectListTableViewCell *)cell withSlectFunsbean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    UIViewController *viewController = [self nextPageWithFunsBean:bean withINdexStore:storeBean];
    
    [self gotoNextPageWithViewController:viewController withFuncsBean:bean withStoreBean:storeBean withAutoJump:YES];
    
}

#pragma mark - WSSelectListNewTableviewCellDelegate

-(void)chatButtonPressDown:(WSStoreBean*)store{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString * storeimage=@"";
    if(store.storeImg && store.storeImg.length>0){
        storeimage=[WSHttpURLHelper getImageCompleteURL:store.storeImg];
    }
    NSString * storeName=@"";
    if(store.name && store.name.length>0){
        storeName=store.name;
    }
    NSString * storeID=@"";
    if(store.Id && store.Id.length>0){
        storeID=store.Id;
    }
    NSString * local_ImageID=@"";
    if(store.local_ImageID && store.local_ImageID.length>0){
        local_ImageID=store.local_ImageID;
    }
    NSString * nickname=[[WSEMSDKManager sharedInstance]getChatNickName];
    if(nickname==nil || nickname.length<=0){
        nickname=@"";
    }
    NSString * headImageUrl=[[WSEMSDKManager sharedInstance]getChatHeadImageLRL];
    if(headImageUrl==nil || headImageUrl.length<=0){
        headImageUrl=@"";
    }
    
    NSMutableDictionary * extDic=[[NSMutableDictionary alloc] init];
    [extDic setObject:storeimage forKey:WS_MSG_toStoreUrl];
    [extDic setObject:storeID forKey:WS_MSG_toStoreId];
    [extDic setObject:storeName forKey:WS_MSG_toStoreName];
    [extDic setObject:nickname forKey:WS_MSG_fromChatrealName];
    [extDic setObject:headImageUrl forKey:WS_MSG_fromChatHeadImgUrl];
    //取得该商店对应业代聊天账号
    WSUserInfo * storeUserInfo=[[WSEMSDKManager sharedInstance]getUserInfoWithStoreID:store.Id andEmpId:store.empId];
    NSString * conversation=storeUserInfo.wschatID;
    
    NSString * toChartHeadURL=@"";
    if(storeUserInfo.wsheadImageURL && storeUserInfo.wsheadImageURL.length>0){
        toChartHeadURL=[WSHttpURLHelper getImageCompleteURL:storeUserInfo.wsheadImageURL];
    }
    NSString * toChartName=@"";
    if(storeUserInfo.wsname && storeUserInfo.wsname.length>0){
        toChartName=storeUserInfo.wsname;
    }
    [extDic setObject:toChartHeadURL forKey:WS_MSG_toChatHeadImgUrl];
    [extDic setObject:toChartName forKey:WS_MSG_toChatrealName];
    
    NSString * jsonStr=[extDic JSONString];
    [dict setObject:jsonStr forKey:WS_MSG_protyKey];
    
    WSChartViewController * wfvc=[[WSChartViewController alloc]initWithConversationChatter:conversation conversationType:EMConversationTypeChat extertDic:dict];
    wfvc.store = store;
    wfvc.navigationItem.title=store.name;
    wfvc.hidesBottomBarWhenPushed = YES;
    
    if (self.ownParentViewController==nil) {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
    }else{
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    
}

-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
    
    NSMutableArray * storeArray =  [[NSMutableArray alloc]init];
    NSMutableArray * storeIdArray = [[NSMutableArray alloc]init];
    for (WSStoreBean * store in array) {
        if (![storeIdArray containsObject:store.Id]) {
            [storeArray addObject:store];
            [storeIdArray addObject:store.Id];
        }else{
            NSInteger index = [storeIdArray indexOfObject:store.Id];
            [storeArray replaceObjectAtIndex:index withObject:store];
        }
    }
    return storeArray;
}

#pragma mark - toast
- (void)toastHUDTypeFaildWithString:(NSString *)str
{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:str tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

@end

