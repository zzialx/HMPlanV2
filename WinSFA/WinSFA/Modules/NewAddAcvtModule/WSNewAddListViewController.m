//
//  WSNewAddListViewController.m
//  SKSHU
//
//  Created by heju on 14-4-10.
//  Copyright (c) 2014年 Com.Winchannel. All rights reserved.
//

#import "WSNewAddListViewController.h"
#import "WSNewAddAcvtViewController.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSAcvtBean_qst.h"
#import "WSStoreAcvtDisBean.h"
#import "WSEnvrionment.h"
#import "WSStoreInfoTableViewCell.h"
#import "WSAcvtListDataItem.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSSplitViewController.h"
#import "WSWorkFlowViewController.h"
#import "WSEmptyViewCell.h"
#import "WSNewAddAcvtModel.h"
#import "WSNextStepFuncsViewController.h"
#import "LEOAssistiveTouch.h"
#import "WSNewAddProdsWithSeriesViewController.h"
#import "MoreProductViewController.h"
#import "WSAcvtDataGridViewPanel.h"
#import "WSAcvtVCManager.h"
#import "WSInterAction.h"

#define SELECT_MORE_PRODUCT_CONTROLLER   @"MoreProductViewController"
#define TREE_NODE_SELECT_MORE_PRODUCT_CONTROLLER   @"WSNewAddProdsWithSeriesViewController"

#define KDelayTime                  0.01
#define kHeaderLabelTag             1000
#define KHeaderSubmarrayTag         10001

@interface WSNewAddListViewController () <WCBaseViewControllerDelegate>{
    NSMutableArray *sectionHeaderViewArray;
    WSNewAddAcvtViewController *_currentNewAcvtVC;
}

@property (nonatomic, assign) BOOL isBack;      // MENGNIU-206 是否返回页面
@end

@implementation WSNewAddListViewController


- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore {
    if(funcs==nil){
        return nil;
    }
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.currentStore = aStore;
        
        self.serverceDisArray =[[NSMutableArray alloc]init];
        return self;
        
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore withSubEmpId:(NSString *)subEmpId{
    if(funcs==nil){
        return nil;
    }
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.currentStore = aStore;
        [self setSubempid:subEmpId];
        
        self.serverceDisArray =[[NSMutableArray alloc]init];
        return self;
        
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewAcvtFinish:) name:NEWADDACVTSUCCEED object: nil];
    sectionHeaderViewArray = [NSMutableArray array];
    self.isFirstLoad = YES;
    self.filterAcvts = [self getAcvtBeansWithFilter:self.currentFuncs.filter];
    [self initializationBackItemAction];
    
    self.currentAcvtBen = [self.addAcvtArray firstObject];
    [self createHeaderSearchView];
    
}

// YIHAIKERRY-1286 解决tab切换时返回按钮被重置点击不了的问题
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //MN-1284 返回上级页面未给出没有离店的提示 增加逻辑(是八步骤时 先忽略重置leftBarButtonItems逻辑)
    if (![self.ownParentViewController isKindOfClass:[WSNextStepFuncsViewController class]])
    {
        [self navBarClearLeftBarButtonItems];
        [self addBackBarButtonItem];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)navBarClearLeftBarButtonItems {
    [self getNavigationItem].leftBarButtonItems = nil;
}

- (void)addBackBarButtonItem {
    NSMutableArray *barButtonItems = [NSMutableArray arrayWithArray:[self getNavigationItem].leftBarButtonItems] ;
    
    if ([self navigationController].viewControllers.count <= 1) {
    } else{
        UIBarButtonItem *backBBI = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        [barButtonItems addObject:backBBI];
        
        [self getNavigationItem].leftBarButtonItems = barButtonItems;
    }
}

-(void)subclassReloadData{
    WSSplitViewController *splitController = self.wsSplitController;
    if (splitController && [splitController.leftViewController isKindOfClass:[WCNavigationController class]])
    {
        WCNavigationController *nav = (WCNavigationController *)splitController.leftViewController;
        if ([[nav.viewControllers firstObject] isKindOfClass:[WSWorkFlowViewController class]])
        {
            WSWorkFlowViewController *con = (WSWorkFlowViewController *)[nav.viewControllers firstObject];
            [con reloadView];
        }
    }
    
    
    [self reloadData];
    
    if (self.isFirstLoad)
        [self autoJumpToNextViewController]; //MN-1863_2018-04-19 逻辑统一挪到WSBaseNewAcvtListViewController
    //[self checkAndShowAddNewAcvtController];
    else
        [self performSelector:@selector(autoBackParent) withObject:nil afterDelay:KDelayTime];
    
    self.isFirstLoad = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isBack = YES;
    self.needRefresh = nil;
}

- (void)autoBackParent{
    // MENGNIU-206 & MENGNIU-1644
    if (self.isBack && !self.isTabMode && !self.isPageSegmentView) {
        if ([self.dataArray count] < 1) {
            NSString *autoJumpNext  = self.currentFuncs.opt.autoJumpNext;
            if ([autoJumpNext isEqualToString:@"1"]) {
                [self backToParent];
            }
        }
        self.isBack = NO;
        self.isFirstLoad = YES;
    }
}

-(void)initializationBackItemAction
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:nil target:nil];
    }
}

- (void)addDutyPlanNewAcvt:(WSAcvtBean *)acvtBean {
    
    self.currentAcvtBen = acvtBean;
    WSNewAddAcvtViewController *newAcvt = [[WSNewAddAcvtViewController alloc] initWithAcvt:self.currentAcvtBen Funcs:self.currentFuncs Store:self.currentStore md5:nil];
    newAcvt.moduleFC = self.moduleFC;
    newAcvt.currentVisitAction = self.currentVisitAction;
    LogInfo(@"Goint to class name WSNewAddAcvtViewController");
    
    [self gotoViewController:newAcvt];
}

// MN-2527
- (void)gotoViewController:(UIViewController *)controller
{
    BOOL isNextFuncs = NO;
    
    //MN-2821 增加opt.refresh逻辑判断
    if([self.currentFuncs.opt.refresh isEqualToString:FUNCS_OPT_REFRESH])
    {
        NSInteger count = [self.navigationController.viewControllers count];
        if (count > 1)
        {
            UIViewController *lastVC =  self.navigationController.viewControllers[count - 1];
            if ([lastVC isKindOfClass:[WSNextStepFuncsViewController class]])
            {
                WSNextStepFuncsViewController *nextStepFuncsVC = (WSNextStepFuncsViewController *)lastVC;
                [nextStepFuncsVC addOtherControllerToView:controller];
                isNextFuncs = YES;
            }
        }
    }

    if (!isNextFuncs)
        [self.navigationController pushViewController:controller animated:YES];
}


- (void)addNewAcvtFinish:(NSNotification*)sender {
    
    self.needRefresh = @"1";
    [self refreshData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    SFA-17601 董宏  删除 订单编码 与金额的段头 （蒙牛售前临时增加实际不需要于添加人张昊核实）
    if(self.isGroupStyle && self.groupStyleDataArray.count)
    {
        //YIHAIKERRY-1142益海嘉里深圳分组需求
        return 44.0;
    }
    else
    {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView;
    UILabel *nameTitleLabel;
    //缓存各自的sectionHeaderView 防止每次都重新创建
    if (sectionHeaderViewArray.count > section)
    {
        //YIHAIKERRY-1142益海嘉里深圳分组需求
        headerView = sectionHeaderViewArray[section];
        if (headerView) {
            UIView *nameTitleLabel = [headerView viewWithTag:kHeaderLabelTag + section];
            if ([nameTitleLabel isKindOfClass:[UILabel class]]) {
                WSNewAddAcvtModel *model = self.groupStyleDataArray[section];
                WSNewAddAcvtModel *cacheModel = self.cacheDataArray[section];
//                YIHAIKERRY-2813
//                SFA 益海嘉里-传统渠道【iOS】【订单管理】订单列表页面，日期后括号内当日订单总数归零
                NSInteger modelArrayCount = model.subModelArray.count > 0 ? model.subModelArray.count : cacheModel.subModelArray.count ;
                UILabel *titleLabel = (UILabel *)nameTitleLabel;
                [titleLabel setText:[NSString stringWithFormat:@"%@ (%lu)",model.titleStr,modelArrayCount]];
            }
            UIView *summaryLabel = [headerView viewWithTag:KHeaderSubmarrayTag + section];
            if ([summaryLabel isKindOfClass:[UILabel class]]) {
                WSNewAddAcvtModel *model = self.groupStyleDataArray[section];
                UILabel *rightTitleLabel = (UILabel *)summaryLabel;
                [rightTitleLabel setText:model.rightStr];
            }
        }
        
        return headerView;
    }
    
    if(self.isGroupStyle && self.groupStyleDataArray.count)
    {
        //YIHAIKERRY-1142益海嘉里深圳分组需求
        WSNewAddAcvtModel *model = self.groupStyleDataArray[section];
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
        
        nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0 , 0.0, SCREEN_WIDTH/2, headerView.height)];
        nameTitleLabel.font = [UIFont systemFontOfSize:14.0];
        nameTitleLabel.text = [NSString stringWithFormat:@"%@ (%lu)",model.titleStr,(unsigned long)model.subModelArray.count];
        nameTitleLabel.textColor = [UIColor blackColor];
        nameTitleLabel.tag = kHeaderLabelTag + section;
//        YIHAIKERRY-1818 董宏
        CGSize size = [nameTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(SCREEN_WIDTH/2, headerView.height) lineBreakMode:NSLineBreakByWordWrapping];
        nameTitleLabel.frame = CGRectMake(nameTitleLabel.frame.origin.x, (headerView.height-size.height)/2,size.width, size.height);
        
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameTitleLabel.right , 0.0, SCREEN_WIDTH-nameTitleLabel.right-40, headerView.height)];
        summaryLabel.font = [UIFont systemFontOfSize:14.0];
        summaryLabel.textAlignment = NSTextAlignmentRight;
        summaryLabel.text = model.rightStr;
        summaryLabel.textColor = [UIColor blackColor];
        summaryLabel.tag = KHeaderSubmarrayTag + section;
        
        UIButton *unfoldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        unfoldBtn.frame =CGRectMake(SCREEN_WIDTH - 40, 0, 40, headerView.height);
        [unfoldBtn setImage:[UIImage imageNamed:@"icon_arrow_up"] forState:UIControlStateNormal];
        [unfoldBtn setImage:[UIImage imageNamed:@"icon_arrow_down"] forState:UIControlStateSelected];
        unfoldBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [unfoldBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
        unfoldBtn.tag = 300+section;
        [unfoldBtn addTarget:self action:@selector(unfoldBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerView addSubview:nameTitleLabel];
        [headerView addSubview:unfoldBtn];
        [headerView addSubview:summaryLabel];
        headerView.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
        [sectionHeaderViewArray addObject:headerView];
        return headerView;
    }
    return nil;
}

- (void)unfoldBtnDidClick:(UIButton *)unfoldBtn
{
    WSNewAddAcvtModel *model = self.groupStyleDataArray[unfoldBtn.tag-300];
    WSNewAddAcvtModel *cacheModel = self.cacheDataArray[unfoldBtn.tag-300];
    if (!unfoldBtn.selected)
    {
        unfoldBtn.selected = YES;
        [model.subModelArray removeAllObjects];
    }
    else
    {
        unfoldBtn.selected = NO;
        if (!model.subModelArray.count)
        {
            [model.subModelArray addObjectsFromArray:cacheModel.subModelArray];
        }
    }
    
    NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:unfoldBtn.tag-300];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDelegate Methods
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count <= 0)
    {
        static NSString *EmptyViewCellIdentifier = @"concernsCelEmptyViewCellIdentifierlIdentifier";
        WSEmptyViewCell *emptyViewCell = [tableView dequeueReusableCellWithIdentifier:EmptyViewCellIdentifier];
        if(emptyViewCell == nil)
        {
            emptyViewCell = [[WSEmptyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyViewCellIdentifier];
            [emptyViewCell setBackgroundColor:[UIColor whiteColor]];
            [emptyViewCell setAccessoryType:UITableViewCellAccessoryNone];
            [emptyViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        [emptyViewCell setupEmptyViewCellFromFuncsBean:self.currentFuncs];
        return emptyViewCell;
    }
    
    WSStoreInfoTableViewCell *cell = (WSStoreInfoTableViewCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    WSAcvtListDataItem *obj;
    
    if (self.isGroupStyle)
    {
        WSNewAddAcvtModel *addAcvtModel = self.groupStyleDataArray[indexPath.section];
        obj = [addAcvtModel.subModelArray objectAtIndex:indexPath.row];
    }
    else
    {
        obj = [self.dataArray objectAtIndex:indexPath.row];
    }
    //设置访问节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = self.currentStore.Id;
    action.newstore_id = obj.newstoreid;
    action.dict_id = obj.acvtID;
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = obj.genID;
    
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
        
    }else if (self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0){
        
        action.module_fc = self.subMenuFuncsCode;
        
    }else {
        action.module_fc = self.currentFuncs.fc;
    }
    
    //MN-2149 2018-04-26
    if([self.currentFuncs.opt.acvtVisitStatus isEqualToString:@"1"])
    {
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action isQueryTitle:YES];
        cell.isVisited = [status isEqualToString:ActionDone];
    }
    else
        cell.isVisited = NO;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.dataArray.count <= 0)
        return;
    
    WSAcvtListDataItem *obj;
    if (self.isGroupStyle)
    {
        WSNewAddAcvtModel *addAcvtModel = self.groupStyleDataArray[indexPath.section];
        obj = [addAcvtModel.subModelArray objectAtIndex:indexPath.row];
    }
    else
    {
        obj = [self.dataArray objectAtIndex:indexPath.row];
    }
    [self pushNewAddAcvtViewController:obj];
}


- (void) pushNewAddAcvtViewController:(WSAcvtListDataItem *)item
{
    if (!item.genID) {
        [self addDutyPlanNewAcvt:[self.addAcvtArray firstObject]];
    }else{
        
        WSStoreBean *acvtNewStore;
        if ([item.newstoreid length] > 0) {
            acvtNewStore = [[WSStoreBean alloc] init];
            acvtNewStore.Id = item.newstoreid;
            acvtNewStore.name = item.mainTitle;
            
            self.currentVisitAction.newstore_id = item.newstoreid;
        }
        
        //        acvtNewStore.typ = item.store_type;
        //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，不知道以下代码的具体用处，遇见问题时请根据实际情况修改
        
        //        NSMutableDictionary *storeInfoDic = [self.storesDicExtendedInfo objectForKey:addObj.update_md5id];
        //        NSArray *newStoreAcvtsInfo = [storeInfoDic  objectForKey:kStoreInfoDicKeyStoreinfo];
        
        //        LogInfo(@" addObj.update_md5id:%@", addObj.update_md5id);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteStoreSucceed:) name:DeleteNewAddStoreSucceed object:nil];
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *qstDisArray = [service queryAcvtQstDatasByGenId:item.genID];
        
        /*
         for (WSAcvtBean *ab in self.addAcvtArray) {
         if ([ab.acvtId isEqualToString:item.acvtID]) {
         self.currentAcvtBen = ab;
         }
         }
         */
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
        WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtID:item.acvtID];
        if (acvtBean) {
            self.currentAcvtBen = acvtBean;
        }
        WSNewAddAcvtViewController *newAcvt = [[WSNewAddAcvtViewController alloc]initWithAcvt:self.currentAcvtBen Funcs:self.currentFuncs Store:self.currentStore acvtNewStore:acvtNewStore newStoreAcvtInfos:qstDisArray  md5:item.genID];
        newAcvt.wsSplitController = self.wsSplitController;
        newAcvt.acvtNameMainTitle = item.mainTitle;
        
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = self.currentStore.Id;
        action.dict_id = item.acvtID;
        action.newstore_id = item.newstoreid;
        action.func_code = self.currentFuncs.fc;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = item.genID;
        
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
            
        }else if (self.subMenuFuncsCode && [self.subMenuFuncsCode length] > 0){
            
            action.module_fc = self.subMenuFuncsCode;
            
        }else {
            action.module_fc = self.currentFuncs.fc;
        }
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        newAcvt.currentVisitAction = action;
        
        LogInfo(@"Go into class WSNewAddAcvtViewController");
        
        [self gotoViewController:newAcvt];
    }
}

// 删除门店成功时候重新加载数据
- (void)deleteStoreSucceed:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteNewAddStoreSucceed object:nil];
    NSString *deleteStoreMd5 = [[notification userInfo] objectForKey:DelteStoreMD5_Key];
    if (self.dataArray) {
        /*和删除店相关的问卷问题信息删除*/
        //        NSPredicate* acvtDisPre=[NSPredicate predicateWithFormat:@"self.gen_id!=%@",deleteStoreMd5];
        //        NSArray *acvtDisBeans = [self.currentStore.acvtDisArray filteredArrayUsingPredicate:acvtDisPre];
        //        self.currentStore.acvtDisArray = [NSMutableArray arrayWithArray:acvtDisBeans];
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        [service deleteServerDataWithGenId:deleteStoreMd5];
        [service deleteLocalDataWithGenId:deleteStoreMd5];
    }
}



////暂时针对于史克医院项目
//- (BOOL)dbIsExistServerceStoreWithAcvtObject:(WSAddAcvtObject *)addAcvtObject{
//    //tskfhos
//
////    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
////    if (projectName != nil && [projectName isEqualToString:@"tskfhos"] ) {
//
//        if ( [self.currentFuncs.fc isEqualToString:@"FAC_100004"]) {//医生拜访不显示在医生信息管理的模块新增的医院
//            BOOL isExistStore = NO;
//            for (WSAcvtListDataItem *object in self.serverceDisArray) {
//
//                if ([object.newstoreid isEqualToString:addAcvtObject.acvt_newstoreid]) {
//                    isExistStore = YES;
//                    break ;
//                }
//            }
//
//            return isExistStore;
//        }
//        else{
//            return YES;
//        }
////    }
////    else{
////
////        return  YES;
////    }
//
//
//}

@end
