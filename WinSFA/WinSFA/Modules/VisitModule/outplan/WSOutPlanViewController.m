 //
//  OutPlanViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#import "WSOutPlanViewController.h"
#import "WSOutPlanStoreBean.h"
#import "WSWorkFlowViewController.h"
#import "WSStoreBean.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"
#import "WSStoreInfoViewController.h"
#import "WSRequestHelper.h"
//#import "ConfigFileController.h"
#import "WSStoreAcvtDisBean.h"
#import "WSAddStoreTable.h"
#import "WCOptionalSource.h"
//TODO:对上层依赖，需要重构
//#import "MyModifyStoreInfoViewController.h"
#import "WCOptionalSource.h"
#import "WSAddNewStoreViewController.h"
#import "WSStoreInfoBeanArray.h"
#import "WSVisitStoreActionTable.h"
#import "UIDevice+Addtional.h"
#import "WSAppData.h"
#import "WSSearchBar.h"
#import "WSPlistHelper.h"
#import "WSPfizerEtripModifyStoreInfoViewController.h"
#import "WSInPlanStoreBean.h"
#import "WSStoreDataSource.h"
#import "WSSelectListTableViewCell.h"

#import "WSStoreDataProcessService.h"

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

@implementation WSOutPlanViewController
@synthesize tableView = _tableView;
@synthesize currentFuncs = _currentFuncs;
@synthesize ownParentViewController = _ownParentViewController;
@synthesize ownSearchBar = _ownSearchBar;
@synthesize dataArray = _dataArray;
@synthesize currentStore = _currentStore;
@synthesize alert;
@synthesize resultArray;
@synthesize filterArray;
@synthesize canVisitNewStore = _canVisitNewStore;
@synthesize shouldAddFilters = _shouldAddFilters;

#pragma mark 私有方法

-(void)goNextWorkView
{
    //以下code因submenu而改
    if ([self.currentFuncs.funcsArray count]<1) {
        return;
    }
    
    WSWorkFlowViewController* wfvc = nil;
    WSFuncsBean* nextfb = [self.currentFuncs.funcsArray objectAtIndex:0];
    WSFuncsBean* subMenuFB = [self getSubMenu:nextfb.submenu];
    
    if(subMenuFB==nil){
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:nextfb Store:self.currentStore];
    }
    else {
        wfvc = [[WSWorkFlowViewController alloc]initWithFuncs:subMenuFB Store:self.currentStore];
    }
    
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
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = self.currentFuncs.name;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    wfvc.currentVisitAction = action;
    
    LogInfo(@"Going to class WSWorkFlowViewController");
    
    if (self.ownParentViewController) {
        self.ownParentViewController.hidesBottomBarWhenPushed = YES;
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    } else {
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}
- (NSString *)getObjID
{
    
    NSString *objId;
    WSFuncsBean *subFunc = nil;
    if (self.currentFuncs.funcsArray != nil && [self.currentFuncs.funcsArray count] > 0) {
        subFunc = [self.currentFuncs.funcsArray objectAtIndex:0];
    }
    
    if (subFunc != nil && subFunc.filter != nil && [subFunc.filter length] > 0) {
        objId = subFunc.filter;
    }
    else{
        objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
    }
    
    NSLog(@"getObjID :%@",objId);
    return objId;
}

-(void)requestMethed:(WSStoreBean*)aStore
{
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataOutPlanInfo:aStore subEmpStore:nil  notifyName:UPDATA_NOTIFY];
}

-(void)startUpdata:(WSStoreBean*)store
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishRequest:)
                                                 name:UPDATA_NOTIFY 
                                               object:nil];    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataOutPlanInfo:store subEmpStore:nil notifyName:UPDATA_NOTIFY];
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.hidesWhenStopped = YES;
    [aiv startAnimating];
    [self querying_messageTips];

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
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
       [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    else
    {
        NSDictionary *uploadState = [info objectFromJSONString];
        if(self.currentStore != nil)
            [self.currentStore reSetStore:uploadState Key:[self getObjID]];
    
        // 处理回显节点数据内容
//        [self dealWithStoreDictdis:uploadState];
        [WSStoreDataProcessService processStoreDisDataWithDic:uploadState objID:[self getObjID] storeID:self.currentStore.Id];
        // 处理巡访提醒节点
//        [self dealWithStoreInfo:uploadState withNodeName:[self getObjID] withFilter:self.currentFuncs.filter];
        [WSStoreDataProcessService processStoreInfoDataWithDic:uploadState objID:[self getObjID] filter:self.currentFuncs.filter];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [self goNextWorkView];
    }
}



- (WSFuncsBean*)getSubMenu:(NSString*)subMenu
{
    if(subMenu == nil)
        return nil;

    WSFuncsBeanArray* fbArray = [WSAppData getObjectbyKey:FUNCS];
    if (fbArray ==nil) {
        return nil;
    }
    WSFuncsBean* resultFB =[fbArray getFuncsBeanFromSubFC:subMenu];
    
    return resultFB;
}

- (NSArray *)searchUnitbyString:(NSString *)search{
    
    if (search == nil || [search isEqualToString:@""]) {
        return self.dataArray;
    }
    
    NSArray *searchArray = [search componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchArray != nil) {
        NSMutableString *format = [NSMutableString stringWithCapacity:4];
        int i = 0;
        NSMutableArray *formatArray = [[NSMutableArray alloc] initWithCapacity:4];
        for (NSString *item in searchArray) {
            if (![item isEqualToString:@""]) {
                if (i == 0) {
                    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
                        [format appendString:@"(SELF.name contains[cd] %@)"];
                        [formatArray addObject:item];
                    }else{
                        [format appendString:@"((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
                        [formatArray addObject:item];
                        [formatArray addObject:item];
                    }

                }else{
                    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
                        [format appendString:@" AND (SELF.name contains[cd] %@)"];
                        [formatArray addObject:item];
                    }else{
                        [format appendString:@" AND ((SELF.name contains[cd] %@) OR (SELF.code contains[cd] %@))"];
                        [formatArray addObject:item];
                        [formatArray addObject:item];
                    }
                }
                i++;
            }

        }
        if ([formatArray count] > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:format argumentArray:formatArray];
            return [self.dataArray filteredArrayUsingPredicate:predicate];
        }
    }
    return nil;
}

- (BOOL) isNewStorePage
{
    if (self.currentFuncs.ds && [self.currentFuncs.ds isEqualToString:@"newstore"]) {
        return YES;
    }
    
    return NO;
}

-(void)initDataArray
{
    [self.dataArray removeAllObjects];
    
    if ([self isNewStorePage]) {
        //新门店页面
        WSStoreDataSource* newStoreSource = [WSAppData getObjectbyKey:NEWSTORE];
        if ([self.currentFuncs.styp isKindOfClass:[NSString class]]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.styp==%@", self.currentFuncs.styp];
            NSArray *array = [newStoreSource.storesArray filteredArrayUsingPredicate:predicate];
            [self.dataArray addObjectsFromArray:array];
        } else {
            [self.dataArray addObjectsFromArray:newStoreSource.storesArray];
        }
    }else {
        // 默认为 outplanstore 节点
        // 如果 filter 有参数，则为 filter 中配置的节点名称
        // (辉瑞医院)
        NSString *noteName = OUTPLANSTORE;
        if (self.currentFuncs.filter) {
            noteName = self.currentFuncs.filter;
        }
        
        //辉瑞etrip新增，如果opt的isIntentToStore字段为Y，则该页面也要加上计划内的门店，根据styp过滤
        if ([self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {
            WSInPlanStoreBean* inPanStores = [WSAppData getObjectbyKey:INPLANSTORE];
            
            if ([self.currentFuncs.styp isKindOfClass:[NSString class]]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.styp==%@", self.currentFuncs.styp];
                NSArray *array = [inPanStores.storesArray filteredArrayUsingPredicate:predicate];
                [self.dataArray addObjectsFromArray:array];
            } else {
                [self.dataArray addObjectsFromArray:inPanStores.storesArray];
            }
        }
        
        WSOutPlanStoreBean* outPlanStoreArray = [WSAppData getObjectbyKey:noteName];
        if ([self.currentFuncs.styp isKindOfClass:[NSString class]])
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp",self.currentFuncs.styp];
            NSArray *array = [outPlanStoreArray.storesArray filteredArrayUsingPredicate:predicate];
            [self.dataArray addObjectsFromArray:array];
        }
        else {
            [self.dataArray addObjectsFromArray:outPlanStoreArray.storesArray];
        }
        
        if ( self.canVisitNewStore )
        {
            //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
            // Display new sucess store which comes table wch_addstore and wch_addstoreqst
            /*
            NSArray* array=[[WSAddStoreTable sharedTable] queryWithNames:@[@"BIZ_DATE",@"UPLOAD_FLAG",@"EMP_ID"] ArgumentsValue:@[[WSCurrentTime getDateString],@"1",[WSAppData getObjectbyKey: APPDATA_EMPID]]];
            if (array != nil)
            {
                for (WSAddStoreObject* object in array)
                {
                    NSString* storeid = object.store_id;
                    NSString* stroename = object.store_name;
                    NSString* isplan = object.is_planed;
                    WSStoreBean* newstore = [[WSStoreBean alloc] initStoreWithObject:stroename IsPlan:[isplan boolValue]];
                    newstore.id = storeid;
                    newstore.name = stroename;
                    newstore.code = object.store_code;
                    newstore.plan = [isplan boolValue];
                    [self.dataArray addObject:newstore];
                }
            }
             */
        }
    }
    
    self.dataArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.dataArray]];
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
}


//三棵树中 客户开发的新增 要在次计划外中显示 (此处的添加区别于 addFinish(计划外的添加)).
- (void)loadNewAndOutPlanStore{
    [self initDataArray];
    NSArray *newStoreArray =[self gainImmediatelyVistStoreList];
    if (newStoreArray && [newStoreArray count] > 0) {
        [self.dataArray addObjectsFromArray:newStoreArray];
    }
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
}

- (NSArray *)gainImmediatelyVistStoreList {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
//    NSArray *newStoreArray = [[WSAddStoreTable sharedTable] queryImmediatelyVistStore];
//    
//    if (newStoreArray) {
//        BOOL isNewStorePage = [self isNewStorePage];
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
//                    for (WSStoreBean *storeBean in self.dataArray) {
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
//                    item.Id = storeid;
//                    NSString *stype = self.currentFuncs.styp;
//                    if (stype &&  object.store_type && [stype  rangeOfString:object.store_type].location != NSNotFound) {
//                        [array addObject:item];
//                    } else if (!stype) {
//                        [array addObject:item];
//                    }
//                }
//            }
//        }
//    }
    if (!array) {
        return nil;
    }
    return [NSArray arrayWithArray:array];
}

#pragma mark system mathod

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;

    self = [super init];
    if(self)
    {
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:funcs.fv];
        self.currentFuncs = funcs;
        self.title = funcs.name;
        self.dataArray = [[NSMutableArray alloc]init];
        self.filterArray = [[NSMutableArray alloc] init];
        
        
        return self;

    }
    return nil;
}


#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self initDataArray];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    NSString *className = [WSPlistHelper valueForKey:self.currentFuncs.fv withPlistName:kControllerMappingFileName];
    UITableView* tv;
    if (!([[UIDevice currentDevice] systemVersionByFloat] < 7.0) && [className isEqualToString:@"WSNewStoreListViewController"]) {
        tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    } else {
        tv= [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    }
    //tableview
    tv.backgroundColor = [UIColor whiteColor];
    tv.backgroundView = nil;
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tv setDelegate:self];
    [tv setDataSource:self];
    tv.tableHeaderView = [self getTableHeaderView];// headerView;
    
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    
    self.tableView = tv;
    [self.view addSubview:self.tableView];
}

- (void)addToolBar {
    self.ownParentViewController.navigationItem.rightBarButtonItems = nil;
}


- (UIView *)getTableHeaderView {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
    self.ownSearchBar = searchBar;
    self.ownSearchBar.searchBar.delegate = self;
    self.ownSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    if (INTERFACE_IS_PHONE) {
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView  addSubview:self.ownSearchBar];

    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 三棵树和宁德联通 新增立即拜访()
    NSLog(@"self.currentFuncs.fv---%@",self.currentFuncs.fv);
    //  为了区别信息中产品信息不调用此方（产品信息中得客户信息视图继承outPlan视图）
    // 高管拜访中也不调用此方法
    if (!([self.currentFuncs.fv isEqualToString:@"TAB_V7003"] || [self.currentFuncs.fv isEqualToString:@"TAB_V11001"])) {
        // 这里的newStore为客户开发 - 地产商开发中新增的
        [self loadNewAndOutPlanStore];
    }
    
    // 更新列表
    self.dataArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.dataArray]];
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    [self.tableView reloadData];
    
    [self addToolBar];
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

#pragma mark tableViewDelegate
//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//指定每个分区中有多少行，默认为1
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = [self.filterArray count];//[self.dataArray count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    @autoreleasepool {
        CGFloat contentWidth = INTERFACE_IS_PHONE ? k_TableViewContentWidth : (tableView.width - STORE_LIST_WIDTH_DIFFERENCE);//229;
        UIFont *font = [UIFont systemFontOfSize:UI_Font];
        WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
        NSString *content = nil;//store.name;
        if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
            content = store.name;
        } else {
            content = store.name;
            if (store.code != nil && [store.code length] > 0) {
                content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
            }
            if (store.bfnum && [store.bfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@-%@", content, [NSString stringWithFormat:@"拜访%@",store.bfnum]];
            }
            if (store.sfnum && [store.sfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@%@%@", content, [store.bfnum length] > 0 ? @"/" : @"-",[NSString stringWithFormat:@"随访%@",store.sfnum]];
            }
        }
        
        if (![content isKindOfClass:[NSString class]])
            return (INTERFACE_IS_PHONE ? 42.0f : 65.0f);
        CGSize size = [content ws_sizeWithFont:font constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByWordWrapping];
        
        return size.height + (INTERFACE_IS_PHONE ? 23.0f : 46.0f);
    }
}


//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    WSSelectListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[WSSelectListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier: SimpleTableIdentifier];
    }
    WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
    [self setAccessFlag:cell Store:store];
    CGFloat contentWidth = INTERFACE_IS_PHONE ? k_TableViewContentWidth : (tableView.width - STORE_LIST_WIDTH_DIFFERENCE);//229;
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    NSString *content = nil;//store.name;
    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
        content = store.name;
    } else {
        content = store.name;
        if (store.code != nil && [store.code length] > 0) {
            content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
        }
        if (store.bfnum && [store.bfnum length] > 0) {
            content = [NSString stringWithFormat:@"%@-%@", content, [NSString stringWithFormat:@"拜访%@",store.bfnum]];
        }
        if (store.sfnum && [store.sfnum length] > 0) {
            content = [NSString stringWithFormat:@"%@%@%@", content, [store.bfnum length] > 0 ? @"/" : @"-",[NSString stringWithFormat:@"随访%@",store.sfnum]];
        }
    }
    NSString *address = store.addr;
    
    if ([content isKindOfClass:[NSString class]])
    {
        CGSize size = [content ws_sizeWithFont:font constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect rect = [cell.textLabel textRectForBounds:cell.textLabel.frame limitedToNumberOfLines:0];
        rect.size = size;
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = font;
        
        cell.textLabel.frame = rect;
        
        cell.textLabel.text = content;
        if ([address isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = address;
        }
        else
        {
            cell.detailTextLabel.text = @"";
        }
    }
    else
    {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
    }
    cell.detailTextLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    
    // Add by WangXiaotang
    if (self.currentFuncs.isStoreInfo && [self.currentFuncs.isStoreInfo length] > 0) {
        if ([self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            {
                cell.accessoryType = UITableViewCellAccessoryDetailButton;
            }
#endif
        }
    }
    else
    {
        NSArray* arrays = self.currentFuncs.funcsArray;
        if (arrays && [arrays count] > 0 )
        {
            WSFuncsBean* fb = [arrays objectAtIndex:0];
            // Only isStoreInfo == "1", show the
            if ([fb.isStoreInfo isEqualToString:@"0"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
                {
                    cell.accessoryType = UITableViewCellAccessoryDetailButton;
                }
#endif
            }
        }
    }
    
    //设置访问节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    action.store_id = store.Id;
    action.func_code = self.currentFuncs.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.is_required = self.currentFuncs.required;
    action.title = self.currentFuncs.name;
    if (self.currentFuncs.iParentFuncsBean
        && self.currentFuncs.iParentFuncsBean.fc
        && [self.currentFuncs.iParentFuncsBean.fc length] > 0) {
        
        action.module_fc = self.currentFuncs.iParentFuncsBean.fc;
    }
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
    if ([self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {
        if ([status isEqualToString:ActionDone]) {
            cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
        } else if ([status isEqualToString:ActionWorking]) {
            cell.imageView.image = [UIImage imageNamed:@"visit_doing.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"visit_not_start.png"];
        }
        cell.imageView.frame = CGRectMake(0, 0, 24, 24);
    }
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    if (store.plan) {
        [cell setTagFrame:cellRect andStyle:ECELLTAGStyleInPlan];
    }else{
        [cell setTagFrame:cellRect andStyle:ECELLTAGStyleOutPlan];
    }
    return cell;    
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSStoreBean* store = [self.filterArray objectAtIndex:indexPath.row];
    self.currentStore = store;
    
    if (![self.currentFuncs.opt.isIntentToStore isEqualToString:@"Y"]) {
        if(![self anyStoreHasNotLeave:store andModuleFC:self.currentFuncs.fc])
            return;
        [self startUpdata:store];
    }
    else
    {
        WSFuncsBean* nextfb = [self.currentFuncs.funcsArray objectAtIndex:0];
        NSString *className = [WSPlistHelper valueForKey:nextfb.fv withPlistName:kControllerMappingFileName];
        UIViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:nextfb Store:self.currentStore];
        
        //设置访问节点
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = self.currentStore.Id;
        action.func_code = self.currentFuncs.fc;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = self.currentFuncs.name;
        if (self.currentFuncs.iParentFuncsBean
            && self.currentFuncs.iParentFuncsBean.fc
            && [self.currentFuncs.iParentFuncsBean.fc length] > 0) {
            
            action.module_fc = self.currentFuncs.iParentFuncsBean.fc;
        }
        action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
        vc.currentVisitAction = action;
        
        
        if (self.ownParentViewController) {
            self.ownParentViewController.hidesBottomBarWhenPushed = YES;
            [self.ownParentViewController.navigationController pushViewController:vc animated:YES];
        } else {
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    //StoreBean* l_store = [self.dataArray objectAtIndex:indexPath.row];
    WSStoreBean* l_store = [self.filterArray objectAtIndex:indexPath.row];
    UIViewController *storeInfo = nil;
    
    if (self.currentFuncs.isStoreInfo && [self.currentFuncs.isStoreInfo length] > 0) {
        if ([self.currentFuncs.isStoreInfo isEqualToString:@"1"]) {
            storeInfo = [[WSStoreInfoViewController alloc] initWithStoreInfo:l_store];
        }
        else if ([self.currentFuncs.isStoreInfo isEqualToString:@"3"])
        {
            storeInfo = [[WSPfizerEtripModifyStoreInfoViewController alloc] initWithFuncs:self.currentFuncs store:l_store storeInfoDic:nil];
        }
    }
    else
    {
        NSArray* arrays = self.currentFuncs.funcsArray;
        if (arrays && [arrays count] > 0 )
        {
            WSFuncsBean* fb = [arrays objectAtIndex:0];
            // Only isStoreInfo == "1", show the
            if ([fb.isStoreInfo isEqualToString:@"1"]) {
                storeInfo = [[WSStoreInfoViewController alloc]
                             initWithStoreInfo:l_store];
            }
            else
            {
                id class = [NSClassFromString(self.storeInfoClassName) alloc];
                if ([class respondsToSelector:@selector(initWithStoreInfo:filter:)]) {
                    storeInfo = [class performSelector:@selector(initWithStoreInfo:filter:) withObject:l_store withObject:nil];
                }
                //            storeInfo = [[NSClassFromString([PropertyManager getPropertybyKey:fb.fv]) alloc] initWithFuncs:fb];
                //            storeInfo = [[MyModifyStoreInfoViewController alloc] initWithStoreInfo:l_store filter:category];
            }
        }else {
            
            storeInfo = [[WSStoreInfoViewController alloc] initWithStoreInfo:l_store];
            
        }
    }
    
    LogInfo(@"Going to init class: %@", storeInfo);
    
    NSString *StoreInforString = NSLocalizedString(@"store_info",nil);
    storeInfo.title = StoreInforString;
    
    self.ownParentViewController.hidesBottomBarWhenPushed = YES;
    [self.ownParentViewController.navigationController pushViewController:storeInfo animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
            [btn setTitle:CancelString  forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.filterArray = [NSMutableArray arrayWithArray:self.dataArray];
    [self.tableView reloadData]; 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.filterArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    self.filterArray = [NSMutableArray arrayWithArray:[self searchUnitbyString:searchBar.text]];
    [self.tableView reloadData];
    
}
@end
