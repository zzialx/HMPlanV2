 //
//  MV_LISTViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSMV_LISTViewController.h"
#import "WSFuncsBean.h"
#import "WSAcvtBean.h"
#import "WinSFA.h"
#import "WSAcvtViewController.h"
#import "WSVisitStoreActionTable.h"
#import "WSDictBean.h"
#import "WSProdGrideViewController.h"
#import "WSPlistHelper.h"
#import "WSLocationManager.h"
#import "WSFuncsBean_opt.h"
#import "WSNavigationBar.h"
#import "WSNewAddListViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSTitleTabView.h"
#import "UIImageView+WebCache.h"
#import "WSServerIPList.h"
#import "WSWorkFlowTableViewCell.h"
#import "WSBaseDictsDBService.h"
#import "WSRNMVListViewController.h"
#import "WSReportFormController.h"
#import "WSSplitViewController.h"
#import "WSDictGrideViewController.h"
#import "WSNewStoreListViewController.h"
#import "WSWorkFlowTableViewCell.h"
#import "WSBaseAcvtDBService.h"
#import "WSRequestHelper.h"
#import "NSString+ServerUrl.h"
#import "WSCompositeImageView.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSStoreOtherBean.h"
#import "WSRequestHelper.h"
#import "WSFuncsBeanArray.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSStatisticsManager.h"

#define CELL_LEFT_SPACE (INTERFACE_IS_PHONE ? 15.0f : 20.0f)


#define FUNCS_ICON_WIDTH 36.0f


typedef NS_ENUM(NSInteger, MV_LISTViewWorkMode) {
    MVListViewWorkInImageMode,
    MVListViewWorkInFunctionMode, 
    MVListViewWorkInProductMode
};

@interface WSMV_LISTViewController ()<WSTitleTabViewDelegate,WSCompositeImageViewDeleagte>

@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic, assign) MV_LISTViewWorkMode iWorkMode;
@property (nonatomic, strong) NSArray *iItemArray;
@property (nonatomic, strong) NSMutableArray *displayFuncsArray;
@property (nonatomic, strong) WSTitleTabView *titleTabView;
@property (nonatomic, strong) WSStoreOtherBean *currentOtherBean;
//YIHAIKERRY-3352 整体修改
@property (nonatomic, strong) NSMutableDictionary *controllerDic;

@property (nonatomic, assign) BOOL isFirstLoad; //是否第一次加载标示
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) NSInteger isSelectNum;


@end

@implementation WSMV_LISTViewController

@synthesize tbView = _tbView;
@synthesize iParentItemInfo = _iParentItemInfo;
@synthesize iWorkMode = _iWorkMode;
@synthesize iItemArray = _iItemArray;
@synthesize displayFuncsArray = _displayFuncsArray;


#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    if (INTERFACE_IS_PHONE) {// ipad 暂定不需要添加storenamelabel
        // todo...
        if (![self.currentFuncs.menuLayout isEqualToString:MENU_LAYOUT_TAB]) {
            [self loadStoreNameLabel];
        }
    }

    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    SFA-18484 董宏 
    [self clearAllNavBBI];
    if (self.iWorkMode != MVListViewWorkInImageMode) {
         [self.tbView reloadData];
        
    }
}
- (void)clearAllNavBBI
{
//    [self getNavigationItem].leftBarButtonItems = nil;
    [self getNavigationItem].rightBarButtonItems = nil;
    [self getNavigationItem].titleView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //MN-994 2018-03-06
    if(self.isFirstLoad)
    {
        self.isFirstLoad = NO;

        NSArray *array = [self getTitleArray];
        if(array.count == 1 && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"] && !self.isPageSegmentView)
        {
            UIViewController* vc = [self generateNextPageWithRow:0];
            if (vc)
            {
                [vc setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else
    {
        NSArray *array = [self getTitleArray];
        if(array.count == 1 && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"] && !self.isPageSegmentView)
            [self backToParent];
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isSelectNum = 0;
    
    self.isFirstLoad = YES;
    
    [self initData];
    
    if((MVListViewWorkInProductMode == self.iWorkMode && self.iItemArray.count == 0 ) || (MVListViewWorkInFunctionMode == self.iWorkMode && self.displayFuncsArray.count == 0)){
        [self addEmptyView];
    }else {
        if (self.iWorkMode == MVListViewWorkInImageMode) {

//            MMSH-4638
//            SFA玛氏中国iOS手机端门店拜访-计划外门店选择（测试门店57），点击进店，选择完美门店成功图像闪退
            if (self.iItemArray.count > 0) {

//            MMSH-3189
//            [玛氏中国MWC](ios)进店水印需显示指定的几个，其他页面不使用水印
            CGFloat imageWidth = [self.currentOtherBean.item4 floatValue];
            CGFloat imageHeight = [self.currentOtherBean.item5 floatValue];
            CGFloat maxHeight = self.view.bounds.size.height - self.y_point - 64;
            
            CGFloat maxWidth = self.view.bounds.size.width;
            
            
            float scaleY = maxHeight / imageHeight;
            float scaleX = maxWidth / imageWidth;
            float scale = scaleY > scaleX ? scaleX : scaleY;

            CGFloat height = imageHeight * scale;
            CGFloat width = imageWidth * scale;
            
            WSCompositeImageView *compositeImageView = [[WSCompositeImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width - width)/2.0, self.y_point, width, height) withSubImageArray:self.iItemArray withSubViewScale:scale];
            compositeImageView.userInteractionEnabled = YES;
            compositeImageView.delegate = self;
            [self.view addSubview:compositeImageView];
            NSString *url = [self.currentOtherBean.item6 buildupUrl];
            
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"load_image", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:url progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL) {
                
                [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
                
                if (image) {
                    compositeImageView.image = image;
                    }
                }];
            }
        }else if ([self.currentFuncs.menuLayout isEqualToString:MENU_LAYOUT_TAB]) {
            WSTitleTabView *tabView = [[WSTitleTabView alloc] initWithFrame:CGRectMake(0, self.y_point, self.view.width, TITLE_TAB_VIEW_HEIGHT) titleArray:[self getTitleArray] aligment:WSTitleTabViewAlignmentCenter];
            tabView.delegate = self;
            tabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.y_point += TITLE_TAB_VIEW_HEIGHT;
            self.titleTabView = tabView;
            [self.view addSubview:tabView];
            [self.titleTabView setSelectedIndex:0];
            
        }else {
            UITableView* tv = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, self.view.bounds.size.height - self.y_point) style:UITableViewStylePlain];
            tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            //    tv.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
            tv.delegate = self;
            tv.dataSource = self;
            self.tbView = tv;
            [self.view addSubview:tv];
        }
    }
}

- (NSArray *)getTitleArray
{
    NSArray *nameArray;
    if (MVListViewWorkInProductMode == self.iWorkMode) {
        nameArray = [self.iItemArray valueForKey:@"name"];
    }
    else if (MVListViewWorkInFunctionMode == self.iWorkMode)
    {
        nameArray = [self.displayFuncsArray valueForKey:@"name"];
    }
    
    return nameArray;
}

- (void)initData
{
    if ([self.currentFuncs.menuStyle isEqualToString:@"196196"]) {
        self.iWorkMode = MVListViewWorkInImageMode;
    }else if ((self.currentFuncs.filter == nil) || [self.currentFuncs.filter isEqualToString:@""] || [self.currentFuncs.filter isEqualToString:@"spestoreinfo"]) {
        self.iWorkMode = MVListViewWorkInFunctionMode;
    }else{
        self.iWorkMode = MVListViewWorkInProductMode;
    }
    
    if (MVListViewWorkInImageMode == self.iWorkMode) {
        WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc]init];
        _currentOtherBean = [[service querywithType:@"subMenuImg" withColName:@"item2" withColValue:self.currentFuncs.fc] firstObject];
        self.iItemArray = [service querywithType:@"subMenuImgCoordinate" withColName:@"item2" withColValue:self.currentOtherBean.item1];
    }else if (MVListViewWorkInProductMode == self.iWorkMode) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        
        if (self.iParentItemInfo !=nil ) {
            // self.iParentItmeInfo  为 非nil
            self.iItemArray = [service queryDictsWithParentId:[self.iParentItemInfo stringValue] filter:self.currentFuncs.filter];
        } else {
            // self.iParentItmeInfo 为nil
            self.iItemArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.filter];
        }
    }
    else if (MVListViewWorkInFunctionMode == self.iWorkMode)
    {
        if (self.displayFuncsArray == nil) {
            self.displayFuncsArray = [[NSMutableArray alloc] init];
            //SFA-16319 【IOS】拜访-迁移监控-我品信息-缺少库存上报。
            [self.displayFuncsArray addObjectsFromArray:[WSFuncsBeanFilterLogicService filterFuncsBean:self.currentFuncs.funcsArray withStore:self.currentStore bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
            for (WSFuncsBean *fb in self.currentFuncs.funcsArray)
            {
                
                //                if (!fb.styp) {
                //                    [self.displayFuncsArray addObject:fb];
                //                } else if ([self.currentStore.styp hasPrefix:fb.styp]) {
                //                    [self.displayFuncsArray addObject:fb];
                //                }else if(!self.currentStore){          // 门店为空，则加载所有工作拜访项。
                //                    [self.displayFuncsArray addObject:fb];
                //                }
                if(fb.icon && fb.icon.length>0){
                    [self loadImageForCachWithUrl:fb.icon];
                }
            }
        }
        NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"Id" ascending:YES];
        NSArray* sortArray = [[NSArray alloc] initWithObjects:sort, nil];
        self.iItemArray=[self.iItemArray sortedArrayUsingDescriptors:sortArray];
    }
    
    if ([self.currentFuncs.opt.batchUpload isEqualToString:@"1"]) {
        self.isBatchUpload = YES;
        //  YIHAIKERRY-2004 add by zhiqing
        NSArray * tempItemArray = self.iItemArray.count?self.iItemArray:self.displayFuncsArray;
        NSMutableArray * tempArray = [[NSMutableArray alloc]init];
        for (WSFuncsBean * func in tempItemArray) {
            NSArray * acvtArray = [[[WSBaseAcvtDBService alloc]init] queryAcvtsWithStoreId:self.currentStore.Id filter:func.filter];
            if (acvtArray.count > 0) {
                [tempArray addObject:func];
            }
        }
        
        if (self.iItemArray) {
            self.iItemArray = [tempArray copy];
        }else{
            self.displayFuncsArray = [tempArray mutableCopy];
        }
    }
    
    // YIHAIKERRY-2715 移除不需要显示的 Tab 和 Controller
    NSMutableArray *hiddenTabArray = [NSMutableArray arrayWithCapacity:self.displayFuncsArray.count];
    NSMutableArray *hiddenControllerArray = [NSMutableArray arrayWithCapacity:self.displayFuncsArray.count];
    for (NSInteger i = 0; i < [self itemCount]; i++) {
        UIViewController *vc = [self generateNextPageWithRow:i];
    
        if ([vc isKindOfClass:[WCBaseViewController class]]) {
            WCBaseViewController *baseVC = (WCBaseViewController *)vc;
            if ([baseVC isHiddenCurrentTab]) {
                [hiddenTabArray addObject:[self.displayFuncsArray objectAtIndex:i]];
                [hiddenControllerArray addObject:baseVC.currentFuncs.fc];
            }
        }
    }
    if ([hiddenTabArray count] > 0) {
        [self.displayFuncsArray removeObjectsInArray:hiddenTabArray];
    }
    if ([hiddenControllerArray count] > 0) {
        for (NSInteger i = 0 ; i < hiddenControllerArray.count ; i++) {
            [self.controllerDic removeObjectForKey:hiddenControllerArray[i]];
        }
    }
    
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return YES;
}

- (void)backAction
{
    //  SFA-22582 donghong
    NSArray *arr  = [self itemArray];
    if (arr.count==0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    WSFuncsBean *funcsBean = arr[_isSelectNum];
    UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];
    WSAcvtViewController *acvtController;
    if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
        acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];
    }
    
    if (self.isBatchUpload) {
        [self batchUploadBackAction];
    }
    else if (acvtController && acvtController.currentFuncs.opt.backDialog_tip.length > 0)
    {
        //SFA-23683  SFA-24698  合并
        if([acvtController isShowBackPrompt])
        {
            [self backActionMessage];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


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

-(UIViewController*)generateNextPageWithRow:(NSInteger)row
{
   
    
    WSFuncsBean* fb = nil;
    NSString *title = nil;
    NSString *itemCode = nil;
    NSString *func_code = nil;
    if (MVListViewWorkInImageMode == self.iWorkMode) {
        WSStoreOtherBean *otherbean = [self.iItemArray objectAtIndex:row];
        WSFuncsBeanArray* funcsArray=[WSAppData getObjectbyKey:FUNCS];
        fb=[funcsArray getFuncsBeanFromAllFucsWithFC:otherbean.item8];
        func_code = fb.fc;
        itemCode = otherbean.item3;
    }else if (MVListViewWorkInProductMode == self.iWorkMode) {
        if (self.iItemArray == nil || [self.iItemArray count] == 0) {
            return nil;
        }
        
        fb = [self.currentFuncs.funcsArray objectAtIndex:0];
        WSDictBean *bean = [self.iItemArray objectAtIndex:row];
        func_code = bean.Id;
        title = bean.name;
    }else{
        //        if(self.currentFuncs.funcsArray == nil|| [self.currentFuncs.funcsArray count]==0) return;
        fb = [self.displayFuncsArray objectAtIndex:row];
        func_code = fb.fc;
        title = fb.name;
    }
//    董宏 SFA-21362 e的状态需要每次重新生成 不能用缓存
    if(![self.currentFuncs.opt.isUseNewPage isEqualToString:@"1"]){
        if ([self.controllerDic count] > 0 && row < [self.controllerDic count] && ![fb.dateTyp isEqualToString:@"E"]) {
            UIViewController *controllerCache = [self.controllerDic objectForKey:fb.fc];
            LogDebug(@"取用缓存的vc，不会触发loadview方法");
            [self refreshAction:controllerCache funcCode:func_code title:title];
            if (controllerCache) {
                return controllerCache;
            }
        }
    }
    // 在ENABLE_LOCATION为1的前提下，如果opt中isGPS为R 且程序没有授权GPS服务/本机GPS服务不能用则禁止进入下一级页面.
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    WSFuncsBean_opt *opt = fb.opt;
    NSString *isGps = fb.opt.isGps;
    if (enableLocation !=nil && [enableLocation isEqualToString:@"1"]) {
        if (opt != nil && isGps !=nil ) {
            BOOL enterStore = [[WSLocationManager getInstance] checkConfigAndAuthorizationGps:isGps showAlert:fb.name];
            if (!enterStore) {
                return nil;
            }
        }
    } else {
        // 如果ENABLE_LOCATION 为0则允许进入下一级页面
    }
    
    
    //    UIViewController* vc = [[NSClassFromString([PropertyManager getPropertybyKey:fb.fv]) alloc] initWithFuncs:fb Store:self.currentStore];
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    UIViewController *vc = nil;
    
    BOOL isAddAcvt = NO;
    if ([fb.opt.isAdd isEqualToString:@"Y"]) {
        isAddAcvt = YES;
    }
    //        MN-2453
    //        主管协同拜访-业代评估-业代评估对业代评价完毕（ios手机）业务员（ios手机）无法查看主管对其的评估 主管xieyanjuan业务员xieqin（7600464）
    if (self.currentSubEmpStore){
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            WSSpecialAcvtViewController *specacvt=  (WSSpecialAcvtViewController *)vc ;
            [specacvt setSubempid:self.currentSubEmpStore.Id];
        }
    }
    
    if (self.currentStore) {
        
        if (!isAddAcvt) {
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
        }
//        if ([fb.fv isEqualToString:@"RN_001"]){
//            WSRNMVListViewController *rnMVListViewController = (WSRNMVListViewController*)vc;
//            WSDictBean *bean = [self.iItemArray objectAtIndex:row];
//            rnMVListViewController.dictItemStr = bean.Id;
//        }
        
    }else if (self.currentSubEmpStore){
        
        if (!isAddAcvt) {
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        }
        
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
           WSSpecialAcvtViewController *specacvt=  (WSSpecialAcvtViewController *)vc ;
            [specacvt setSubempid:self.currentSubEmpStore.Id];
        }else if ([vc isKindOfClass:[WSReportFormController class]]){
            //winSFA MSTD-4368 如果有currentSubEmpStore 则在次加载报表用SubEmpStore 的id去请求，与安卓逻辑一致
            WSReportFormController  *reportFormVc = (WSReportFormController *)vc ;
            reportFormVc.currentSubEmpStore = self.currentSubEmpStore;
        }
        
        
    }else {

        if (!isAddAcvt) {
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        }
    }
    
    if (vc != nil && [vc isKindOfClass:[WSMV_LISTViewController class]]) {
        WSDictBean *bean = [self.iItemArray objectAtIndex:row];
        WSMV_LISTViewController *listview = (WSMV_LISTViewController *)vc;
        if (bean.Id) {
            listview.iParentItemInfo = [NSNumber numberWithInteger:[bean.Id intValue]];
        }
    }
    
    if(vc == nil)
    {
        // we don't need to show acvtlist if "isAcvtList = 1", kind of server error define
        // however, we should follow this
        // 和从门店拜访项进入下一个页面的逻辑一样和安卓保持一致
        if (isAddAcvt) {
            
            if (self.currentStore) {
                vc = [[WSNewAddListViewController alloc]  initWithFuncs:fb Store:self.currentStore];
            }else {
                vc = [[WSNewStoreListViewController alloc] initWithFuncs:fb];
            }
            
        } else {
            if ([fb.isAcvtList isEqualToString:@"1"])
            {
                
                WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
                NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:fb.filter];
                
                WSAcvtBean *acvtBean = [filtersArray lastObject];
                if (self.currentSubEmpStore) {
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:fb subEmpStore:self.currentSubEmpStore];
                }else{
                    vc = [[WSAcvtViewController alloc]initWithAcvt:acvtBean Funcs:fb Store:self.currentStore];
                }

            }
            else
            { 
                NSString *className = [WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName];
                if (self.currentStore) {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
                } else if (self.currentSubEmpStore) {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:fb subEmpStore:self.currentSubEmpStore];
                } else {
                    vc =[[NSClassFromString(className) alloc] initWithFuncs:fb];
                }
                if (vc && MVListViewWorkInProductMode == self.iWorkMode) {
                    if ([vc isKindOfClass:[WSBaseGrideViewController class]]) {
                        WSBaseGrideViewController *productGrid = (WSBaseGrideViewController*)vc;
                        WSDictBean *bean = [self.iItemArray objectAtIndex:row];
                        productGrid.iBrandId = bean.Id;
                    }
                }
            }
        }        
        
    }
    
    if ([vc isKindOfClass:[WCBaseViewController class]]) {
        ((WCBaseViewController *)vc).wsSplitController = self.wsSplitController;
        ((WCBaseViewController *)vc).itemCode = itemCode;
    }
    
    if (vc) {
        [self refreshAction:vc funcCode:func_code title:title];

        vc.title = title;
        
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            [((WSSpecialAcvtViewController *)vc) setUploadStyle:self.currentFuncs.opt.uploadStyle];
        }
        
        if ([vc respondsToSelector:@selector(setRealParentFuncsCode:)]) {
            [vc performSelector:@selector(setRealParentFuncsCode:) withObject:self.realParentFuncsCode];
        }
        //SFA-21442  -2018-6-26
        if ((![fb.dateTyp isEqualToString:@"E"] && ![fb.opt.downByMap isEqualToString:@"3"] )||([fb.dateTyp isEqualToString:@"E"] && !self.isSelect)) {
            [self.controllerDic setObject:vc forKey:fb.fc];
        }
    }
    
    return vc;
}
- (void)refreshAction:(UIViewController*)vc funcCode:(NSString*)funcCode title:(NSString*)title
{
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    if (self.currentStore.Id) {
        action.store_id = self.currentStore.Id;
    } else if (self.currentSubEmpStore.Id) {
        action.store_id = self.currentSubEmpStore.Id;
    }
    
    action.func_code = funcCode;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = title;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    } else if (self.moduleFC && [self.moduleFC length] > 0)
    {
        action.module_fc = self.moduleFC;
    }else{
        
        action.module_fc = action.func_code;
    }
    if (self.fromModuleName && [self.fromModuleName length] > 0) {
        
        action.fromModuleName = self.fromModuleName;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    vc.currentVisitAction = action;
    
}
- (void)addControllerToCurrentTab:(UIViewController *)viewController {
    UIViewController *currentTabController = [self generateNextPageWithRow:self.titleTabView.selectedIndex];
    self.tempChildController = viewController;
    [currentTabController addChildViewController:viewController];
    viewController.view.frame = currentTabController.view.bounds;
    [currentTabController.view addSubview:viewController.view];
}


- (BOOL)removeOtherController {
    if (self.tempChildController) {
        [self titleTabView:self.titleTabView didSelectTitleAtIndex:self.titleTabView.selectedIndex];
        return YES;
    }
    return NO;
}

- (NSInteger)itemCount
{
    if (MVListViewWorkInProductMode == self.iWorkMode){
        return ((self.iItemArray != nil) ? [self.iItemArray count] : 0);
    }else{
        return [self.displayFuncsArray count];//((self.currentFuncs.funcsArray != nil) ? [self.currentFuncs.funcsArray count] : 0);
    }
}
- (NSArray*)itemArray
{
    if (MVListViewWorkInProductMode == self.iWorkMode){
        return self.iItemArray;
    }else{
        return self.displayFuncsArray ;
    }
}
- (BOOL)isValueChange
{
    if ([self.selectedController respondsToSelector:@selector(isValueChange)]) {
        return (BOOL)[self.selectedController performSelector:@selector(isValueChange)];
    }
    
    return NO;
}

- (void)setSelectedIndex:(NSInteger)index {
    if (self.titleTabView) {
        [self.titleTabView setSelectedIndex:index];
    }
}

#pragma mark - Batch Upload 批量上传相关操作
- (void)batchUpload {
    NSArray *arr  = [self itemArray];
    for (NSInteger i = 0; i < arr.count; i++) {
        WSFuncsBean *funcsBean = arr[i];

        UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];
            if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
                WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];

                UIButton *selectedButton = [self.titleTabView viewWithTag:kTitleTabViewTag + i];
                [self.titleTabView performSelector:@selector(buttonAction:) withObject:selectedButton];

                    BOOL isValid = [acvtController executeValidate];
                    if (!isValid) {
                        return;
                    }

        }
    }
    
    for (NSInteger i = 0; i < arr.count; i++) {
        WSFuncsBean *funcsBean = arr[i];

        UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];

            if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
                WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];
                    [acvtController checkSameMainTitleTipAndUpload];

        }
    }
}

- (void)batchUploadBackAction {
    BOOL isShowBackPromt = NO;
    
    NSArray *arr  = [self itemArray];

    for (NSInteger i = 0; i < arr.count; i++) {
        WSFuncsBean *funcsBean = arr[i];
        UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];
            // 如果有一个问卷要求
            BOOL shouldPauseBack = [acvtController shouldPauseBackAction];
            if (shouldPauseBack) {
                return;
            }
            // 判断是否有调查问卷需要回头返回提示，只要有一个问卷需要提示就需要提示
            if (!isShowBackPromt) {
                BOOL isPrompt = [acvtController isShowBackPrompt];
                if (isPrompt) {
                    isShowBackPromt = YES;
                }
            }
        }
    }
    
    if (isShowBackPromt) {
        //  Block 是 MRC 下 autorelease 的
        [self backActionMessage];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backActionMessage
{
    //  Block 是 MRC 下 autorelease 的
    [WSAcvtViewController backPromptWithFuncs:self.currentFuncs saveBlock:^{
        [self batchUploadBackToSave];
        
    } uploadBlock:^{
//        SFA-27021 
        if ([self.selectedController isKindOfClass:[WSSpecialAcvtViewController class]]&&[self.currentFuncs.opt.uploadStyle isEqualToString:@"noJump"]) {
            WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)self.selectedController) m_AcvtViewController];
            if([acvtController executeValidate])
            {
                [acvtController checkSameMainTitleTipAndUpload];
                
            }
            return;
        }
        [self batchUpload];
        
    } giveupBlock:^{
        [self batchUploadBackToGiveup];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}
- (NSString *)getUploadStyle {
    if (self.currentFuncs.opt) {
        return self.currentFuncs.opt.uploadStyle;
    } else {
        return nil;
    }
}


- (void)batchUploadBackToSave {
    NSArray *arr  = [self itemArray];

    for (NSInteger i = 0; i < arr.count; i++) {
        WSFuncsBean *funcsBean = arr[i];
        UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];
             [acvtController backToSave];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)batchUploadBackToGiveup {
    
    NSArray *arr  = [self itemArray];

    for (NSInteger i = 0; i < arr.count; i++) {
        WSFuncsBean *funcsBean = arr[i];
        UIViewController *vc = [self.controllerDic objectForKey:funcsBean.fc];
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            WSAcvtViewController *acvtController = [((WSSpecialAcvtViewController *)vc) m_AcvtViewController];
            [acvtController backToGiveup];
        }
    }
}


#pragma mark tableview delegate

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self itemCount];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    WSWorkFlowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[WSWorkFlowTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: SimpleTableIdentifier];
        cell.funcImageWidth = 20.0f;
        cell.cellHeight = MAIN_CELL_HEIGHT;
    }

    WSFuncsBean* fb = nil;
    NSInteger totalCount = 0;
    
    WSFuncsBean *contentFB = nil;
    
    if (MVListViewWorkInProductMode == self.iWorkMode){
        totalCount = [self.iItemArray count];
        fb = [self.currentFuncs.funcsArray firstObject];
        
        WSDictBean *bean = [self.iItemArray objectAtIndex:indexPath.row];
        contentFB = [[WSFuncsBean alloc] initFuncsWithObject:@{@"name":bean.name,@"fc":bean.Id}];

    }else{
        totalCount = [self.displayFuncsArray count];
        fb = [self.displayFuncsArray objectAtIndex:indexPath.row];
        contentFB = fb;
    }
    
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    if (self.currentStore.Id) {
        action.store_id = self.currentStore.Id;
    } else if (self.currentSubEmpStore.Id) {
        action.store_id = self.currentSubEmpStore.Id;
    }
    
    action.func_code = contentFB.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    // 字典项为数据的 不通过fb(fb.required) 判断必填
    if (MVListViewWorkInProductMode == self.iWorkMode) {
        action.is_required = @"O";
    } else {
        action.is_required = fb.required;
    }
    action.title = contentFB.name;

    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    if (self.currentVisitAction
        && self.currentVisitAction.fromModuleName
        && [self.currentVisitAction.fromModuleName length] > 0) {
        LogInfo(@"更新来源fromModuleName的action：%@",self.currentVisitAction.fromModuleName);
        action.fromModuleName = self.currentVisitAction.fromModuleName;
    }else{
        
        action.module_fc = action.func_code;
    }

    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
    BOOL hasTips = NO;
    WSBaseStoreOtherDataDBService *dataService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSInteger badgeCount = [dataService getFuncTipCountWithFC:fb.fc storeId:self.currentStore.Id];
    [cell setDataWithFuncsBean:contentFB store:self.currentStore visitActionStatus:status action:action hasTips:hasTips badgeCount:badgeCount indexPath:indexPath totalCount:totalCount];
    
    return cell;
}

#pragma mark - 实现tableView:didSelectRowAtIndexPath:协议
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [self generateNextPageWithRow:indexPath.row];
    
    if ([vc isKindOfClass:[WCBaseViewController class]]) {
        
        WCBaseViewController *tempVc = (WCBaseViewController *)vc;
        if (tempVc.currentFuncs.script.length > 0 && [tempVc.currentFuncs.opt.isCheckPushView isEqualToString:@"1"]) {

            WSLuaExecutorManager *tempLuaExecutor = [WSLuaExecutorManager shareInstance];
            tempLuaExecutor.isErrorFromScript = NO;
            tempLuaExecutor.sourceType = WSLuaExecuteSourceTypeQst;
            WSWidget *widget = [[WSWidget alloc] init];
            widget.resultCheck = [NSString stringWithFormat:@"%@@#%@", tempVc.currentStore.Id, tempVc.currentFuncs.fc];
            tempLuaExecutor.currentoperator = widget;
            [tempLuaExecutor executeLuaScript:tempVc.currentFuncs.script];
            
            if ([WSLuaExecutorManager shareInstance].isErrorFromScript) {
                return;
            }
        }
    }
    
    self.isSelect = YES;
    if (vc) {
        LogInfo(@"GOING TO CLASS :%@", vc);
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    WSDictBean *bean = [self.displayFuncsArray objectAtIndex:indexPath.row];
    WSStatisticsManager *manager = [WSStatisticsManager sharedInstance];
    [manager insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean
                            currentFuncBean:self.currentFuncs store:self.currentStore eventValue:bean.name
                                  startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil
                                      genId:[WSStatisticsManager getGenId]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return MAIN_CELL_HEIGHT;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headHeight = 0;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0)) {
        headHeight = 1.0f;
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
    return headView;
}

#pragma mark - WSTitleTabViewDelegate

static BOOL didEnd = NO;
static BOOL result = YES;

- (BOOL)titleTabView:(WSTitleTabView *)acvtTabView shouldSelectTitleAtIndex:(NSInteger)index {
    
    BOOL isNeedConfirm = NO;
    _isSelectNum = index;
    UIViewController *contenViewController = nil;
    if (self.wsSplitController) {
        WCNavigationController *currentCenterController = (WCNavigationController *)self.wsSplitController.rightViewController;
        if(currentCenterController){
            UIViewController *realContentTopViewController = [currentCenterController visibleViewController];
            
            if ([realContentTopViewController respondsToSelector:@selector(isValueChange)]) {
                
                contenViewController = realContentTopViewController;
                if ([(BaseViewController*)realContentTopViewController isValueChange]) {
                    isNeedConfirm = YES;
                }
            }
        }
    }
    
    result = YES;
    if (isNeedConfirm) {
        didEnd = NO;
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            didEnd = YES;
            result = NO;
        }];
        
        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            didEnd = YES;
            result = NO;
            
            UIViewController *realContentVC = contenViewController;
            
            if ([realContentVC isKindOfClass:[WSMV_LISTViewController class]]) {
                realContentVC = [((WSMV_LISTViewController *)realContentVC) selectedController];
            }
            //不用else if是因为WSMV_LISTViewController的selectedController可能还是个WSSpecialAcvtViewController
            if ([realContentVC isKindOfClass:[WSSpecialAcvtViewController class]]) {
                realContentVC = [((WSSpecialAcvtViewController *)realContentVC) m_AcvtViewController];
            }
            
            
            if ([realContentVC isKindOfClass:[WSAcvtViewController class]]) {
                WSAcvtViewController *acvtCon = (WSAcvtViewController *)realContentVC;
                [acvtCon performSelector:@selector(executeUpload) withObject:nil afterDelay:0.01];
            }else if ([realContentVC isKindOfClass:[WSDictGrideViewController class]]) {
                WSDictGrideViewController *gridCon = (WSDictGrideViewController *)realContentVC;
                [gridCon performSelector:@selector(upload) withObject:nil afterDelay:0.01];
            }else if ([realContentVC isKindOfClass:[WSProdGrideViewController class]]) {
                WSProdGrideViewController *gridCon = (WSProdGrideViewController *)realContentVC;
                [gridCon performSelector:@selector(upload) withObject:nil afterDelay:0.01];
            }
            
        }];
        
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            didEnd = YES;
            result = YES;
        }];
        [alert show];
        
        while (!didEnd) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
        
        return result;
    }
    return result;
}


- (void)titleTabView:(WSTitleTabView *)acvtTabView didSelectTitleAtIndex:(NSInteger)index {
    if (self.tempChildController) {
        [self.tempChildController.view removeFromSuperview];
        self.tempChildController = nil;
    }

    [self.selectedController removeFromParentViewController];
    [self.selectedController.view removeFromSuperview];
    
    WCBaseViewController* vc = (WCBaseViewController *) [self generateNextPageWithRow:index];
    vc.isTabMode = YES;
    vc.ownParentViewController = self;
    if ([vc isKindOfClass:[BaseViewController class]]) {
        [(BaseViewController *)vc setM_ParentViewController:self];
    }
    if ([vc isKindOfClass:[WCBaseViewController class]]) {
        [(WCBaseViewController *)vc setWsSplitController:self.wsSplitController];
    }
    [self addChildViewController:vc];
    vc.view.frame = CGRectMake(0, self.y_point, self.view.width, self.view.height - self.y_point);
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:vc.view];
    //打造标准 监听方法
    [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:vc.currentFuncs.iParentFuncsBean currentFuncBean:vc.currentFuncs store:vc.currentStore eventValue:vc.currentFuncs.name startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];

    self.selectedController = vc;
}
#pragma mark
#pragma mark WSCompositeImageView
- (void)selectItem:(NSInteger)row{
    
    UIViewController* vc = [self generateNextPageWithRow:row];
    if (vc) {
        LogInfo(@"GOING TO CLASS :%@", vc);
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
    }
    vc = nil;
}

#pragma mark
#pragma mark CommonUtils

//预加载图片
-(void)loadImageForCachWithUrl:(NSString *)url{
    NSURL * imageUrl=nil;
    if (url  && [url length]>0) {
//        imageUrl=[NSURL URLWithString:[self buildupUrl:url]];
        url = [url buildupUrl];
    }

    if(imageUrl){
        UIImageView * imageview=[[UIImageView alloc]init];
        
        [[WSRequestHelper shareInstance] downloadImageWithUrl:url imageView:imageview];
    }
}
//设定显示的Cell图片
-(void)resetCellImageFowShow:(UITableViewCell*)cell State:(VisitActionStatus)sate ImageURL:(NSURL *)url{
    //设定状态图片
    float width=0;
    if ([sate isEqualToString:ActionDone]) {
        cell.imageView.image  = [UIImage imageNamed:@"visit_action_done"];
        width=cell.imageView.image.size.width;
    } else if ([sate isEqualToString:ActionWorking]) {
        cell.imageView.image = nil;
    } else {
        cell.imageView.image = nil;
    }
    //设定网络图片
    if(url){
        UIImageView * imageview=[cell.contentView viewWithTag:2000];
        imageview.frame=CGRectMake(CELL_LEFT_SPACE+width, (cell.contentView.bounds.size.height - FUNCS_ICON_WIDTH)/2, FUNCS_ICON_WIDTH, FUNCS_ICON_WIDTH);

        [[WSRequestHelper shareInstance] downloadImageWithUrl:[url absoluteString] imageView:imageview];
        
        
        UILabel * lab=[cell.contentView viewWithTag:2001];
        lab.frame=CGRectMake(imageview.frame.origin.x+imageview.bounds.size.width+3, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height);
        imageview.hidden=NO;
        UIImageView * imageviewMust=[cell.contentView viewWithTag:2002];
        //展示必填图标
        if(imageviewMust){
            imageviewMust.frame=CGRectMake(lab.frame.origin.x+8+[lab.text stringSizeWithFont:lab.font width:600].width, imageviewMust.frame.origin.y, imageviewMust.bounds.size.width, imageviewMust.bounds.size.height);
        }
        
    }else{
        UIImageView * imageview=[cell.contentView viewWithTag:2000];
        imageview.hidden=YES;
        UILabel * lab=[cell.contentView viewWithTag:2001];
        lab.frame=CGRectMake(CELL_LEFT_SPACE+width, 0, cell.contentView.bounds.size.width, cell.contentView.bounds.size.height);
        UIImageView * imageviewMust=[cell.contentView viewWithTag:2002];
        if(imageviewMust){
           imageviewMust.frame=CGRectMake(lab.frame.origin.x+8+[lab.text stringSizeWithFont:lab.font width:600].width, imageviewMust.frame.origin.y, imageviewMust.bounds.size.width, imageviewMust.bounds.size.height);
        }
    }
}

#pragma mark - Properties

- (NSMutableDictionary *)controllerDic {
    if (!_controllerDic) {
        _controllerDic = [[NSMutableDictionary alloc] initWithCapacity:[self itemCount]];
    }
    return _controllerDic;
}
@end
