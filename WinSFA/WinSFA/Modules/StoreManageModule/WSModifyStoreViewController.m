//
//  ModifyStoreViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSModifyStoreViewController.h"
#import "WSAppData.h"
#import "WSModifyStoreInfoViewController.h"
#import "WSAcvtListViewController.h"
#import "WSAcvtViewController.h"
#import "WSVisitStoreActionTable.h"
#import "WSDistStore.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
//#import "ConfigFileController.h"
#import "WSFuncsBeanArray.h"
#import "WSFuncsBean_opt.h"
#import "WSFacTable.h"
#import "WSDictBean.h"
#import "WSEnvrionment.h"
#import "WSAcvtDBService.h"
#import "WSAddNewStoreViewController.h"
#import "WSNavigationBar.h"

#import "WSSelectListNewTableviewCell.h"
#import "WSMyCustomerTitleView.h"
#import "WSLeftMenuViewController.h"
#import "WSStoreDataProcessService.h"

#import "WSBaseStoreDBService.h"
#import "WSEnvrionment.h"
#import "WCPopListView.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSSearchBar.h"

#import "WSTestTools.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "MJRefresh.h"
#import "WSAcvtSearchStoreView.h"
#import "HZHSearchBar.h"
#import "WSStoreDataService.h"
#import "WSBaseStoreTable.h"

#define MODIFY_STORE_UPDATE_DATA @"modifyStoreUpdateData"
#define kRefreshStoreDataNotify @"RefreshStoreDataNotify"

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

#define k_SegmetWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 80 : (80 * UI_XFactor))
#define kView_Space_Left (INTERFACE_IS_PHONE ? 15 : 20)

@interface WSModifyStoreViewController ()<WSMyCustomerTitleViewDelegate,WCPopListViewDelegate,WSAcvtSearchStoreViewDelegate,HZHSearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *allStoreArray;
@property (nonatomic, strong) NSArray *searchResultStoreArray;


//@property (strong, nonatomic) WSSearchBar *searchBar;
@property (strong, nonatomic) HZHSearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic, strong) UITableView *storeListTableView;



@property (nonatomic, strong) NSArray *acvtArray;


@property (nonatomic, strong)NSArray *addAcvtArray;
@property (nonatomic , copy) NSString  *conditions; // SFA 联合利华 SFALHLH-1463
@property (nonatomic , assign) NSInteger  pageNumer; // 第几页
@property (nonatomic , strong) NSIndexPath * selectIndexPath; // 选择的IndexPath

@property (nonatomic , assign) BOOL shouldEndEditing;

@property (nonatomic,strong)WSAcvtSearchStoreView *acvtSearchStoreView;
@property (nonatomic,strong) WSAcvtBean *acvtBeanForSearchStore;


@end

@implementation WSModifyStoreViewController

@synthesize allStoreArray = _allStoreArray;
@synthesize searchResultStoreArray = _searchResultStoreArray;
@synthesize showStoreArray = _showStoreArray;

@synthesize searchBar = _searchBar;
@synthesize storeListTableView = _storeListTableView;

@synthesize alert = _alert;
@synthesize currentStore = _currentStore;

-(NSMutableArray *)allStoreArray{
    if (!_allStoreArray) {
        _allStoreArray = [[NSMutableArray alloc] init];
    }
    return _allStoreArray;
}
/**初始化全部门店*/
- (void)initAllModifyStoresFromDb {
    
    //[[WSTestTools getInstance] keepTimeWithKey:@"initAllModifyStoresFromDb"];
    
//    if (self.allStoreArray == nil) {
//        self.allStoreArray = [[NSMutableArray alloc] init];
//    }
    if (self.showStoreArray == nil) {
        self.showStoreArray = [[NSMutableArray alloc] init];
    }
    
    NSString *empId = [self getCurrentEmpId];
    NSString *funCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    
    NSString * search_objId = STORES;
    // 安卓门店修改查询门店的节点用的是filter 不是ds add by zhiqing
//    if ([self.currentFuncs.ds length] > 0 && ![self.currentFuncs.ds isEqualToString:@"acvt"]) {
//        search_objId = self.currentFuncs.ds;
//    }
    if (self.currentFuncs.filter && self.currentFuncs.filter.length >0) {
        //SFA-22874
        //备注：和安卓对逻辑：判断filter以逗号分割，在末尾拼接一个字符串，新增门店search_objId保存为空字符串
        if ([self.currentFuncs.filter containsString:@","]) {
            search_objId = [self.currentFuncs.filter stringByAppendingString:@","];
        } else {
            search_objId = self.currentFuncs.filter;
        }
    }
    
    NSArray *stores = [NSMutableArray arrayWithArray: [[WSBaseStoreDBService shareInstance] queryAllStoreForModifyWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:self.searchBar.text search_objId:search_objId pageNumber:self.pageNumer distanceSort:self.currentFuncs.opt.distancesSort]];
    if (stores.count < kStoreListPageCount) {
        [self.storeListTableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.storeListTableView.mj_footer endRefreshing];
    }
    [self.allStoreArray addObjectsFromArray:stores];
    
    if (self.allStoreArray != nil) {
        self.showStoreArray = [NSMutableArray arrayWithArray:self.allStoreArray];
    }
    NSInteger count = [[WSBaseStoreDBService shareInstance]queryAllStoreCountEmpId:empId styp:self.currentFuncs.styp searchStr:self.searchBar.text search_objId:search_objId isSearchable:NO acvtId:nil selctedQstValues:nil rangeConditions:nil distance:-1 otherDataDic:nil];
    [self resetTitle:count];
    //[[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"initAllModifyStoresFromDb"];
}

- (void)resetTitle:(NSInteger)count{
    NSString *title ;
    
    if ([self.currentFuncs.opt.hideCount isEqualToString:@"1"]) {
        title = [NSString stringWithFormat:@"%@", self.currentFuncs.name];
    }else{
        title = [NSString stringWithFormat:@"%@(%lu)", self.currentFuncs.name, (unsigned long)count];
    }
    
    [self refreshControllerTitle:title];
}
-(void)updragStoreData{
    NSLog(@"上拉加载");
    self.pageNumer += 1;
    [self initAllModifyStoresFromDb];
    [self.storeListTableView reloadData];

}

- (void)refreshData
{
    [self refreshDistance];
    [self queryStoresByCondition];
}

-(void)refreshModifyData:(NSNotification * )noti{
    
    if ( self.selectIndexPath.row < self.showStoreArray.count) {
        if (self.selectIndexPath) {
            WSStoreBean * store = [self.showStoreArray objectAtIndex:self.selectIndexPath.row];
            NSString *empId = [self getCurrentEmpId];
            NSString *funCode = self.currentFuncs.fc;
            if (self.subMenuFuncsCode) {
                funCode = self.subMenuFuncsCode;
            }
            
            NSString * search_objId = STORES;
            //        if ([self.currentFuncs.ds length] > 0 && ![self.currentFuncs.ds isEqualToString:@"acvt"]) {
            //            search_objId = self.currentFuncs.ds;
            //        }
            if (self.currentFuncs.filter && self.currentFuncs.filter.length >0) {
                search_objId = self.currentFuncs.filter;
            }
            store = [[[WSBaseStoreDBService shareInstance] queryStoreForModifyWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:nil search_objId:search_objId acvtId:self.currentAcvt.acvtId selctedQstValues:nil rangeConditions:nil pageNumber:-1 distanceSort:self.currentFuncs.opt.distancesSort storeId:store.Id] firstObject];
            //SFA-23734
            //SFA泸州老窖】【iOS】新增门店时，上传后闪退
            if (store) {
                [self.showStoreArray replaceObjectAtIndex:self.selectIndexPath.row withObject:store];
            }
            [self.storeListTableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
   
    // SFA-25643
    else{
            
        LogInfo(@"self.showStoreArray.count = %ld   self.selectIndexPath.row = %ld",self.showStoreArray.count,self.selectIndexPath.row);
    }

}

#pragma mark - View lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyStoreInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelieveStoreRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyStoreRefreshNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUploadFinish:) name:UPLOAD_ACVT_NOTIFY object:nil];
    
    //2017-09-29-yuanji-add
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relieveStoreRefresh:) name:RelieveStoreRefreshNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStoreList:) name:ModifyStoreRefreshNotification object:nil];
    
    self.shouldEndEditing = YES;
    
    self.storeListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.storeListTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.storeListTableView.backgroundView = nil;
    self.storeListTableView.tableFooterView = [[UIView alloc] init];

    self.storeListTableView.delegate = self;
    self.storeListTableView.dataSource = self;
    self.storeListTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(updragStoreData)];
    
    [self.storeListTableView.mj_footer beginRefreshing];
    
    //配置的下拉刷新节点名
    if ([self.currentFuncs.opt.refreshNodeName length] > 0) {
        
        self.storeListTableView.backgroundColor = [UIColor grayColor];
        
        __weak typeof(self) wself = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            [wself refreshStoreDataWithNodeName:wself.currentFuncs.opt.refreshNodeName];
            
        }];
        header.automaticallyChangeAlpha = YES;
        header.lastUpdatedTimeLabel.hidden = YES;
        self.storeListTableView.mj_header = header;
        
        //SFA 项目SFA-22831 【SFA泸州老窖】【iOS】进入客户管理的客户列表时没有请求数据，需要下拉刷新才显示
        [self queryStoresByCondition];
        if (self.showStoreArray.count == 0) {
            [self.storeListTableView.mj_header beginRefreshing];
        }
    }
    
    
    NSArray *dictArray = nil;
    
    if ([self.currentFuncs.storesFilter length] > 0) {
        
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        dictArray = [service queryDictsForAcvtGridWithFilter:self.currentFuncs.storesFilter];
    }
    
    if (dictArray.count > 0) {
        WSMyCustomerTitleView  *titleView = [[WSMyCustomerTitleView alloc]initWithFrame:CGRectZero style:WSMyCustomerTitleViewStyleMyCustomer withItems:dictArray];
        titleView.height = 60;
        titleView.delegate = self;
        titleView.backgroundColor = [UIColor colorWithRed:243/255.0 green:239/255.0 blue:238/255.0 alpha:1];
        self.storeListTableView.tableHeaderView = titleView;
    }else{
        self.storeListTableView.tableHeaderView = [self getTableHeaderView];
        
    }
   
    self.storeListTableView.backgroundColor = [UIColor whiteColor];
//    self.storeListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.storeListTableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:newStoreNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshModifyData:) name:ModifyStoreInfoNotification object:nil];
    self.isLoaded = NO;
}

- (UIView *)getTableHeaderView {
//    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:YES];
//    self.searchBar = searchBar;
//    self.searchBar.delegate = self;
//    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    HZHSearchBar *searchBar = [[HZHSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0)];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.textBackgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    searchBar.placeholder = NSLocalizedString(@"input_customer_info_search_hint", nil);
    searchBar.placeholderColor = [UIColor colorWithHexString:@"0x949494"];
    searchBar.placeholderFont = FONT_SIZE_PINGFANG_MEDIUM(13.0);
    searchBar.textFont = FONT_SIZE_PINGFANG_MEDIUM(13.0);
    searchBar.textFieldLeftMargin = 15.0;
    searchBar.textFieldRightMargin = 15.0;
    searchBar.textFieldTopMargin = 7.0;
    searchBar.textFieldBottomMargin = 7.0;
    searchBar.leftIconLeftMargin = 9.0;
    searchBar.leftIconRightMargin = 6.0;
    searchBar.cancelButtonText = NSLocalizedString(@"cancel_label", nil);
    searchBar.cancelButtonTextFont = FONT_SIZE_PINGFANG_MEDIUM(13.0);
    searchBar.cancelButtonTextColor = [UIColor colorWithHexString:@"0x949494"];
    searchBar.cancelButtonLeftMargin = 10.0;
    searchBar.leftIcon = [UIImage imageWithImage:[UIImage imageNamed:@"icon_search"] andTintColor:[UIColor colorWithHexString:@"0x949494"]];
    searchBar.delegate = self;
    //SFA-24545 zhaodanyang
    [searchBar setReturnKeyboardTypeWithReturnKey:UIReturnKeySearch];
    self.searchBar = searchBar;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE) {
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView  addSubview:self.searchBar];
    
//    self.searchBar.placeholder =NSLocalizedString(@"query_label", nil);
    return headerView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearAllNavBBI];
    
    //    SFA-18810 donghong
    [self refreshDistance];
}
- (void)clearAllNavBBI
{
    [self getNavigationItem].leftBarButtonItems = nil;
    [self getNavigationItem].rightBarButtonItems = nil;
    [self getNavigationItem].titleView = nil;
}
- (void)refreshDistance
{
    if (!self.currentFuncs.opt.isGps || [self.currentFuncs.opt.isGps isEqualToString:@"Y"]) {
        __weak typeof(self)weakSelf  = self;
        [[WSStoreDataService shareInstance] checkAndUpdateStoreDistanceWithCurrentFuncs:self.currentFuncs andSubEmpId:self.subempStore.Id andObjectId:nil withBlock:^(WSLocationDescribe * locationDescribe,BOOL isNeedRefresh) {
            if (isNeedRefresh) [weakSelf refreshData];
        }];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    LogTrace();
 
    if (!self.isLoaded) {
        [self queryStoresByCondition];
        self.isLoaded = YES;
    }
    
    NSMutableArray *barButtonItems = [[NSMutableArray alloc]init]; ;

    /*
     buttonName存在则显示按钮名字为其值，若不存在则不显示右上角的按钮
     */
    UIBarButtonItem *buttonItem = nil;
    NSString *buttonName =  self.currentFuncs.buttonName;
    
    buttonName = [buttonName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *isAddString = self.currentFuncs.opt.isAdd;
    BOOL isAdd = YES;
    if (isAddString && [isAddString isEqualToString:@"N"]) {
        isAdd = NO;
    }
    //添加参数 buttonName 值为Y是 按钮就显示为图片； 填了内容（按钮名称）就显示文字。
    if (isAdd) {
        if (buttonName && [buttonName length] >0) {
            if ([buttonName isEqualToString:@"Y"]) {
                buttonItem = [self barButtonItemImage:@"title-bar_create_icon" target:self action:@selector(addNewAcvt:)];

            }else{
                buttonItem = [self barButtonItemTitle:buttonName target:self action:@selector(addNewAcvt:)];
            }
            [barButtonItems addObject:buttonItem];
        } else {
            LogError(@"Not set button name");
        }
    }
    
    if (self.currentFuncs.opt.searchQuestion.length != 0 && self.currentFuncs.opt.acvtSearch.length != 0 ) {
        UIButton *filterStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterStoreButton setFrame:CGRectMake(0, 0, 25, 25)];
        [filterStoreButton addTarget:self action:@selector(filterStoreClicked) forControlEvents:UIControlEventTouchUpInside];
        [filterStoreButton setImage:[UIImage imageNamed:@"acvtSearchStore"] forState:UIControlStateNormal];
        UIBarButtonItem *filterStoreItem = [[UIBarButtonItem alloc] initWithCustomView:filterStoreButton];
        [barButtonItems addObject:filterStoreItem];

    }
    
    if (self.ownParentViewController)
    {
        self.ownParentViewController.navigationItem.rightBarButtonItems = barButtonItems;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = barButtonItems;
    }
    //    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
}


- (void)filterStoreClicked {
    
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
    }
    
    if (_acvtSearchStoreView == nil) {
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc]init];
        WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtCode:self.currentFuncs.opt.searchQuestion];
        _acvtBeanForSearchStore = acvtBean;
        CGRect rect = [UIScreen mainScreen].bounds;
        _acvtSearchStoreView = [[WSAcvtSearchStoreView alloc]initWithFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height) current:self.currentFuncs acvtBean:acvtBean];
        _acvtSearchStoreView.delegate = self;        
        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIView *rootView = delegate.window.rootViewController.view;
        [rootView addSubview:_acvtSearchStoreView];
        [self performSelector:@selector(moveAcvtSearchStoreView) withObject:nil afterDelay:0.01];
        [_acvtSearchStoreView requestStoreAcvtdisData];
        
    }else {
        [self.acvtSearchStoreView.superview bringSubviewToFront:self.acvtSearchStoreView];
        [self moveView:_acvtSearchStoreView.rightView offset:-self.acvtSearchStoreView.rightView.width];
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

- (void)addNewAcvt:(id)sender {
    LogTrace();
    
    NSString *isAdd = self.currentFuncs.opt.isAdd;
    if (!(isAdd && [isAdd isEqualToString:@"N"])) {
        
        if ([self.addAcvtArray count] == 1) {
            [self showAcvtViewController:[self.addAcvtArray firstObject]];
        }else if ([self.addAcvtArray count] > 1) {
            WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
            UIView *rootView = delegate.window.rootViewController.view;
            NSArray *acvtNameArray = [self.addAcvtArray valueForKeyPath:@"@unionOfObjects.acvtName"];
            

            WCPopListView *view = [[WCPopListView alloc] initWithTotalArry:acvtNameArray selectedArray:nil withSelectedMode:WCPopListSigleSelected animationType:WCPopListAnimationTypeFromPoint maxHeight:rootView.height -64];
            view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth;
            view.animationPoint = CGPointMake(rootView.width - 20, 40);
            view.autoHideWhenSelect = YES;
            [view setPopListViewColor:[UIColor clearColor]];
            view.iDelegate = self;
            
            
            CGFloat popListHeight = self.view.height;
            
            if ([acvtNameArray count] * WCROWHEIGHT <  popListHeight) {
                popListHeight = [acvtNameArray count] * WCROWHEIGHT;
            }
            
            if (!IOS8_OR_LATER && INTERFACE_IS_PAD) {
                
                [view showViewFromRect:CGRectMake(rootView.height - WCPOPLISTWIDTH, 64, WCPOPLISTWIDTH, popListHeight) inView:rootView animated:YES];
            }
            else{
                [view showViewFromRect:CGRectMake(rootView.width - WCPOPLISTWIDTH, 64, WCPOPLISTWIDTH, popListHeight) inView:rootView animated:YES];
                
            }
        }
        
    }
}

- (void)showAcvtViewController:(WSAcvtBean *)acvtBean
{
    WSAddNewStoreViewController *l_newStoreVC = [[WSAddNewStoreViewController alloc] initWithFuncs:self.currentFuncs acvtBean:acvtBean storeBean:nil];
    l_newStoreVC.title = ((acvtBean.acvtName.length > 0) ? acvtBean.acvtName : l_newStoreVC.title);//MMSH-3888 2018-03-26
    
    if (!l_newStoreVC.currentVisitAction) {
        l_newStoreVC.currentVisitAction = self.currentVisitAction;
    }
    LogInfo(@"Go into class WSAddNewStoreViewController");
    
    if (INTERFACE_IS_PAD) {
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:l_newStoreVC];
        [l_newStoreVC leftItemImage:@"icon_back" target:l_newStoreVC action:@selector(backAction)];
        
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        if(self.ownParentViewController)
        {
            [self.ownParentViewController.navigationController pushViewController:l_newStoreVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:l_newStoreVC animated:YES];
        }
    }
    
}

//- (void)dismissController
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (NSArray *)addAcvtArray {
    if (!_addAcvtArray || [_addAcvtArray count] == 0) {
        NSString *isAdd = self.currentFuncs.opt.isAdd;
        if (!(isAdd && [isAdd isEqualToString:@"N"])) {
            WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
            _addAcvtArray = [service queryAcvtsByFilter:self.currentFuncs.filter acvtCode:self.currentFuncs.opt.isAdd];
        }
    }
    
    return _addAcvtArray;
}



- (void)doUploadFinish:(id)sender{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPLOAD_ACVT_NOTIFY object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
//    NSDictionary *dic = [info objectFromJSONString];
    if (info == nil || error != 0) {
        
    }else{
        
    }

}

- (void)relieveStoreRefresh:(id)sender
{
    [self queryStoresByCondition];
}

- (void)refreshStoreList:(id)sender {
    NSDictionary * infoDic = [sender object];
    if (infoDic) {
        NSString *funcString = [infoDic objectForKey:@"func"];
        if (funcString.length > 0) {
            WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
            WSFuncsBean *funcBean = [funcsArray getFuncsBeanWithFC:funcString];
            self.currentFuncs = funcBean;
        }
    }
    if ([self.currentFuncs.opt.refreshNodeName length] > 0) {
        [self refreshStoreDataWithNodeName:self.currentFuncs.opt.refreshNodeName];
    }
}

- (void)refreshStoreDataWithNodeName:(NSString *)nodeName {
    NSString *AccessInforString = NSLocalizedString(@"刷新中...",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:AccessInforString  tips:nil tapTarget:self action:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStoreDataFinished:)
                                                 name:kRefreshStoreDataNotify
                                               object:nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringNotNilWithValue:[self getCurrentEmpId]] forKey:APPDATA_EMPIDBIGI];
    [dictionary setObject:nodeName forKey:APPDATA_OBJID];
    //24400
    if (self.searchBar.text.length > 0) {
        [dictionary setObject:self.searchBar.text forKey:APPDATA_KEYWORD];
    }
    [[WSRequestHelper shareInstance] postRequestData:dictionary notifyName:kRefreshStoreDataNotify];
}

- (void)refreshStoreDataFinished:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kRefreshStoreDataNotify
                                                  object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    [self.storeListTableView.mj_header endRefreshing];
    
    if (error) {
        
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
    }else {
        
        NSDictionary *dic = [info objectFromJSONString];
        
        NSArray *nodeNameArray = [self.currentFuncs.opt.refreshNodeName componentsSeparatedByString:@";"];
        
        BOOL hasNewData = NO;
        
        for (NSString *nodeName in nodeNameArray) {
            NSArray *dataArray = [dic objectForKey:nodeName];
            
            if (![dataArray isKindOfClass:[NSArray class]] || dataArray.count == 0) {
                continue;
            }
            
            hasNewData = YES;
            
            NSDictionary *firstObjectDic = [dataArray firstObject];
            NSString *jsonType = [firstObjectDic objectForKey:@"jsonType"];
            if ([jsonType isEqualToString:@"store"]) {
                [[WSBaseStoreTable sharedTable] insertAllStoresWith:dataArray searchObjId:nodeName searchObjCode:self.searchBar.text isPlan:@"0"];
            }
            else{
                if ([nodeName hasPrefix:STORES]) {
                    WSBaseStoreDBService *service = [[WSBaseStoreDBService alloc] init];
                    [service replaceToTableWithDicts:dataArray FromNode:nodeName hasNewData:YES];
                }else if ([nodeName hasPrefix:STOREACVTDIS] || [nodeName hasPrefix:ACVTDIS]) {
                    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                    [service replaceToTableWithDicts:dataArray FromNode:nodeName hasNewData:YES];
                }
            }
            
            
        }
        
        
        
        if (hasNewData) {
            // 如果有新数据的话，门店拜访的列表也需要重新刷列表数据
            [[NSNotificationCenter defaultCenter] postNotificationName:newStoreNotification object:nil];
        }
        
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_done_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
    }
    
}

#pragma mark - HZHSearchBarDelegate
- (void)searchBarTextDidBeginEditing:(HZHSearchBar *)searchBar
{
    
}

- (void)searchBar:(HZHSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.shouldEndEditing = NO;

    [self queryStoresByCondition];
    
    self.shouldEndEditing = YES;
}

- (void)searchBarSearchButtonClicked:(HZHSearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self queryStoresByCondition];
    
    //SFA-24400 当前没有数据时 需要向后台实时请求门店数据
    if (self.showStoreArray.count <= 0 && self.currentFuncs.opt.refreshNodeName.length > 0) {
        __weak __typeof(self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself refreshStoreDataWithNodeName:weakself.currentFuncs.opt.refreshNodeName];
        });
    }

}

- (void)searchBarCancelButtonClicked:(HZHSearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self queryStoresByCondition];
}

- (void)searchBarTextDidEndEditing:(HZHSearchBar *)searchBar
{
    
}


#pragma mark - UISearchBarDelegate
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
//    for(UIView *cc in [searchBar subviews])
//    {
//        for (UIView *views in [cc subviews]) {
//            if([views isKindOfClass:[UIButton class]])
//            {
//                UIButton *btn = (UIButton *)views;
//                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
//                [btn setTitle:CancelString  forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//                [btn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font - 2]];
//                break;
//            }
//        }
//
//    }
//}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    self.shouldEndEditing = NO;
//
//    [self queryStoresByCondition];
//
//    self.shouldEndEditing = YES;
//
//}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//
//    [searchBar resignFirstResponder];
//
//    [self queryStoresByCondition];
//}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    [searchBar setShowsCancelButton:NO animated:YES];
//    searchBar.text = @"";
//    [searchBar resignFirstResponder];
//    [self queryStoresByCondition];
//
//}

//-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    [searchBar setShowsCancelButton:NO animated:YES];
//
//}

// 搜索框查询门店数据
-(void)queryStoresByCondition{
    // 需要刷新的话 才做重新分页处理。
    self.pageNumer = 0;
    [self.allStoreArray removeAllObjects];
    
    [self initAllModifyStoresFromDb];
    if (_conditions) {
        
        [self queryStoresFromDBWithConditions:_conditions];
    }
    
    [self.storeListTableView setContentOffset:CGPointMake(0,0) animated:NO];
    [self.storeListTableView reloadData];
}

-(void)queryStoresFromDBWithConditions:(NSString *)conditions{
    _conditions = conditions;
    NSArray * conditionArray = [conditions componentsSeparatedByString:@";"];
    NSString * type = conditionArray[0];
    NSString * searchNameOrCode = conditionArray[1];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@ or SELF.code contains[cd] %@",searchNameOrCode, searchNameOrCode];
    NSPredicate * pre2 = [NSPredicate predicateWithFormat:@"SELF.storesFilter = %@",type];
    NSPredicate *predicate3 ;
    if (searchNameOrCode.length == 0 && type.length != 0) {
        predicate3 = pre2;
    }else if (searchNameOrCode.length != 0 && type.length == 0)
        predicate3 = predicate;
    else{
        predicate3 = [NSCompoundPredicate andPredicateWithSubpredicates:@[ pre2,predicate]];
    }
    
    NSArray *array = [self.allStoreArray filteredArrayUsingPredicate:predicate3];
    self.showStoreArray = array.mutableCopy;
    [self.storeListTableView reloadData];
    
    // 如果删除输入的搜索内容则 table应显示默认加载的数据
    if ([searchNameOrCode isEqualToString:@""] && type.length == 0) {
        [self initAllModifyStoresFromDb];
        [self.storeListTableView reloadData];
    }

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.showStoreArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSStoreBean *rowStore = [self.showStoreArray objectAtIndex:indexPath.row];
    
    return [WSSelectListNewTableviewCell  heightForRowWithStore:rowStore cellWidth:tableView.width isHavePrepareButton:NO withOpt:self.currentFuncs.opt];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"modifyStoreVCCell";

    WSSelectListNewTableviewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[WSSelectListNewTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier withFuncStyle:WSSelectListNewTableviewCellStyleStoreVisitList isStoreInfo:self.currentFuncs.isStoreInfo cellWidth:tableView.width];
    }
    
    WSStoreBean *store = [self.showStoreArray objectAtIndex:[indexPath row]];

//    cell.store = store;
    [cell setStore:store withOpt:self.currentFuncs.opt];

    // 设置拜访节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = store.Id;
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [self getCurrentEmpId];
    action.is_required = self.currentFuncs.required;
    action.title = self.currentFuncs.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    self.currentVisitAction = action;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndexPath = indexPath;
    
    WSStoreBean *l_store = [self.showStoreArray objectAtIndex:indexPath.row];
    self.currentStore = l_store;
    
    //SFALHLH-105【ios联合利华】新增参数sendRequest控制修改门店列表点击门店时是否实时请求
    if ([self.currentFuncs.sendRequest isEqualToString:@"0"]) {
        
        if (l_store.plan) {
            [self showNextControllerForSendRequest];
        }else {

            WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
            BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
            if (!isRequested) {
                isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
            }
            if (!isRequested) {
                [self startUpdata:l_store];
                
            }else {
                [self showNextControllerForSendRequest];
            }
        }
        
    }else {
        [self startGetStoreInfoBySotre:l_store];
    }
}

- (void)showNextControllerForSendRequest
{
    if ([self.currentFuncs.menuLayout isEqualToString:MENU_LAYOUT_LEFT] && [self.currentFuncs.funcsArray count] > 0) {
        
        [self showLeftMenuLayoutViewController];
        
    }else {
        
        [self showStoreInfoViewController];
    }
}

-(void)startUpdata:(WSStoreBean*)store
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:MODIFY_STORE_UPDATE_DATA
                                               object:nil];
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    
    [uploadMgr appUpdataOutPlanInfo:store subEmpStore:nil  notifyName:MODIFY_STORE_UPDATE_DATA];
    
    [self querying_messageTips];

}

-(void)finishRequest:(id)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MODIFY_STORE_UPDATE_DATA
                                                  object:nil];
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
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
        
        NSString *objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        
        if(self.currentStore != nil){
            
            [self.currentStore reSetStore:uploadState Key:objId];
            
            if ([WSEnvrionment  getStoreDataFromDb]) {
                        
                NSObject *tmpObject = uploadState[objId];
                NSDictionary *storeDicInfo = nil;
                if ([tmpObject isKindOfClass:[NSDictionary class]]) {
                    storeDicInfo = (NSDictionary *)tmpObject;
                }else if ([tmpObject isKindOfClass:[NSArray class]]) {
                    storeDicInfo = [(NSArray *)tmpObject firstObject];
                }
                [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
                
                NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[self getCurrentEmpId];
                [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id ];
            }
        }

//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        [self showNextControllerForSendRequest];
    }
}


- (void)showLeftMenuLayoutViewController
{
    WSLeftMenuViewController *con = [[WSLeftMenuViewController alloc] initWithFuncs:self.currentFuncs Store:self.currentStore];
    if (INTERFACE_IS_PAD) {
        WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:con];
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        if(self.ownParentViewController)
        {
            [self.ownParentViewController.navigationController pushViewController:con animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:con animated:YES];
        }
    }
}

- (void)showStoreInfoViewController
{
    NSString *className = [WSPlistHelper valueForKey:self.currentFuncs.ds withPlistName:kControllerMappingFileName];
    UIViewController* storeInfo = [[NSClassFromString(className) alloc] initWithFuncs:self.currentFuncs ];
    if (storeInfo) {
        self.refreshVisitFlagWhenBackTo = YES;
    }
    if ([storeInfo isKindOfClass:[WSAcvtListViewController class]]) {
        
        WSAcvtBean* l_acvtBean = [self.addAcvtArray firstObject];
        
        WSAcvtViewController *avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs:self.currentFuncs Store:self.currentStore md5:nil];
        
        avc.title = l_acvtBean.acvtName;
        
        // action应该是和当前选中的store相关
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = self.currentStore.Id;
        action.func_code = self.currentFuncs.fc;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [self getCurrentEmpId];
        action.title = self.currentFuncs.name;
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
        }else{
            
            action.module_fc = action.func_code;
        }
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        avc.currentVisitAction = action;
        
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
        
        
        if (INTERFACE_IS_PAD) {
            WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:avc];
            [avc leftItemImage:@"icon_back" target:avc action:@selector(backAction)];
            
            [self presentViewController:nav animated:YES completion:nil];
        }else {
            if(self.ownParentViewController)
            {
                [self.ownParentViewController.navigationController pushViewController:avc animated:YES];
            }
            else
            {
                [self.navigationController pushViewController:avc animated:YES];
            }
        }
        
        avc = nil;
        
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
        NSString *StoreInforString = NSLocalizedString(@"store_info", nil);
        storeInfo.title = StoreInforString;
        
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:storeInfo animated:YES];
    }
}


- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    [self.storeListTableView reloadData];
}

#pragma mark - WCPopListViewDelegate
- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex {
    [self showAcvtViewController:[self.addAcvtArray objectAtIndex:anIndex]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.shouldEndEditing) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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
        self.pageNumer = 0;
        [self.showStoreArray removeAllObjects];
        [self reloadStoreListBySearchConditon:conditions rangeConditions:rangeConditions distance:distance];
        [self.storeListTableView setContentOffset:CGPointMake(0,0) animated:NO];
//        [self resetTitle:self.showStoreArray.count];
        [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    });
}

-(void)reloadStoreListBySearchConditon:(NSMutableDictionary *)conditions rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance{
    
    NSString *currenteEmpId = [self getCurrentEmpId];
    
    NSString *subEmpId = self.subempStore.Id;
    
    NSString *empId = subEmpId?:currenteEmpId;
    
    NSString *funCode = self.currentFuncs.fc;
    
    if (self.subMenuFuncsCode) {
        funCode = self.subMenuFuncsCode;
    }
    NSString * search_objId = STORES;
    // 如果是筛选条件 查询门店的节点用 filter
    if ([self.currentFuncs.filter length] > 0) {
        search_objId = self.currentFuncs.filter;
    }
    
    NSArray *allArray = [[WSBaseStoreDBService shareInstance]queryStoreForModifyWithFuncCode:funCode empId:empId styp:self.currentFuncs.styp searchStr:self.searchBar.text search_objId:search_objId acvtId:self.acvtBeanForSearchStore.acvtId selctedQstValues:conditions rangeConditions:rangeConditions pageNumber:self.pageNumer  distanceSort:self.currentFuncs.opt.distancesSort storeId:nil];
    
    if (allArray.count < kStoreListPageCount) {
        [self.storeListTableView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.storeListTableView.mj_footer endRefreshing];
    }
    
    [self.showStoreArray addObjectsFromArray:allArray];
    //SFA-22541
    //【SFA泸州老窖】【iOS】客户管理，客户列表的筛选结果与预期不一致 
    NSInteger count = [[WSBaseStoreDBService shareInstance]queryAllStoreCountEmpId:empId styp:self.currentFuncs.styp searchStr:self.searchBar.text search_objId:search_objId isSearchable:NO acvtId:self.acvtBeanForSearchStore.acvtId selctedQstValues:conditions rangeConditions:rangeConditions distance:distance otherDataDic:nil];
    [self resetTitle:count];
    [self.storeListTableView reloadData];
    
}
@end
