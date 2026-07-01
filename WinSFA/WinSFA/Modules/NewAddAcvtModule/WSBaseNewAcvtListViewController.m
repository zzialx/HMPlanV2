
//
//  WSBaseNewAcvtListViewController.m
//  WinSFA
//
//  Created by yang on 15/12/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseNewAcvtListViewController.h"
#import "WSStoreInfoTableViewCell.h"
#import "WSRequestHelper.h"
#import "WSLocationArray.h"
#import "WSLocationSelectViewController.h"
#import "WSBaseDictsTable.h"
#import "WSBaseStoreTable.h"
#import "WSTestTools.h"
#import "WSBaseDictsDBService.h"
#import "WSAcvtListDataItem.h"
#import "WSAcvtQstDisItem.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseNewAcvtListHeadView.h"
#import "WSHttpURLHelper.h"
#import "WSBaseAcvtDBService.h"
#import "WSCalendarLogicService.h"
#import "WCPopListView.h"
#import "WSEmptyViewCell.h"
#import "WSStoreDataProcessService.h"
#import "WSNewAddAcvtModel.h"
#import "LEOAssistiveTouch.h"
#import "WSNewAddProdsWithSeriesViewController.h"
#import "MoreProductViewController.h"
#import "WSAcvtDataGridViewPanel.h"
#import "WSAcvtVCManager.h"
#import "WSInterAction.h"
#import "WSAcvtViewController.h"
#import "WSStatisticsManager.h"
#import "WSSellFloatWindowManager.h"

#define SELECT_MORE_PRODUCT_CONTROLLER   @"MoreProductViewController"
#define TREE_NODE_SELECT_MORE_PRODUCT_CONTROLLER   @"WSNewAddProdsWithSeriesViewController"

#define TABLE_HEAD_VIEW_HEIGHT 320

#define FV_TAB_V6001        @"TAB_V6001"

@interface WSBaseNewAcvtListViewController ()<WSBaseNewAcvtListHeadViewDelegate,WCPopListViewDelegate,WCBaseViewControllerDelegate>{
    
    UISearchBar *nbar;
    UIView *leftView;
    UIImageView *markImageView;
    NSInteger _currentDisplayMonth;
    //BOOL _calender;
}

@property (nonatomic,strong) WSBaseNewAcvtListHeadView *baseNewAcvtListHeadView;

@property (nonatomic,assign) CGFloat tableHeaderHeight;
@property (nonatomic,assign) CGFloat y_point;

@end

@implementation WSBaseNewAcvtListViewController


- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean {
    self = [super initWithFuncs:aFuncsBean];
    if (self) {
        if (self.currentFuncs.submenu) {
            
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MN-2254 2018-04-28 本次修改牵扯几处修改搜索MN-2254查看
    self.isCalenderPattern = [self.currentFuncs.opt.addType isEqualToString:FUNCS_OPT_ADD_TYPE_CALENDER] ? YES : NO;
    
    //YIHAIKERRY-872 董宏 日历刷新添加 防止2次刷新加入判断
    //_calender = YES;
    //[self upLoadCalender];
    
    _isGroupStyle = [self.currentFuncs.menuStyle isEqualToString:@"groupStyle"];
    WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
    //查询出筛选条件model
     WSDictBean *dictBean = [service queryDictWithID:self.currentFuncs.menuStyle];
    _isGroupStyle = [dictBean.name isEqualToString:@"groupStyle"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = nil;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (self.isCalenderPattern) {
        [self.tableView beginUpdates];
        self.tableView.tableHeaderView = [self tableViewHeadView];// 关键是这句话
        [self.tableView endUpdates];
    }
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    if ([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
#endif

}

- (void)upLoadCalender
{
    //MN-2254 2018-04-28 本次修改牵扯几处修改搜索MN-2254查看
    if(self.isCalenderPattern)
    {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
        if(!_currentDisplayMonth)
            _currentDisplayMonth = comps.month;
        
        [self requestDutyPlanWithDisplayMonth:_currentDisplayMonth];
    }
    
//    if (_calender) {
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        NSDateComponents *comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
//        if(!_currentDisplayMonth)
//        {
//        _currentDisplayMonth = comps.month;
//        }
//        NSString *addType = self.currentFuncs.opt.addType;
//        if ([addType length] > 0 && [addType isEqualToString:FUNCS_OPT_ADD_TYPE_CALENDER]) {
//            self.isCalenderPattern = YES;
//            [self requestDutyPlanWithDisplayMonth:_currentDisplayMonth];
//            _calender = !_calender;
//        }
//    }
}

//右侧按钮 取消方法 SFA-13855 董宏
- (void)rightBarButtonItem
{
    if (self.ownParentViewController)
    {
        self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


#pragma mark - 重写viewWillAppear方法
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark - 重写viewDidAppear方法
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //MN-2254 2018-04-28 本次修改牵扯几处修改搜索MN-2254查看
    //备注：这段代码不要放到Willappear中，可能会导致pushviewController失败，SFA-28153SFA-立白-IOS-苹果X，计划内门店，车销/预售订单，点击后，出现空白页 
    if (self.isCalenderPattern)
    {
        [self upLoadCalender];
        [self rightBarButtonItem];
    }
    else
    {
        [self refreshData];
        [self addNewButton];
    }
    
//    [self upLoadCalender];
//
//    if (self.isCalenderPattern) /*日历模式*/
//        [self rightBarButtonItem];
//    else
//        [self addNewButton];
//
//    [self refreshData];
}

#pragma mark - 重写viewWillDisappear方法
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //_calender = YES;
    
    [self hideAddMoreButton];
}

#pragma mark - 重写viewDidDisappear方法
- (void)viewDidDisappear:(BOOL)animated
{
    [self rightBarButtonItem];
}

#pragma mark - 增加新按键方法
- (void)addNewButton
{
    //buttonName存在则显示按钮名字为其值，若不存在则不显示右上角的按钮
    UIBarButtonItem *buttonItem = nil;
    NSString *buttonName =  self.currentFuncs.buttonName;
    buttonName = [buttonName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *isAddString = self.currentFuncs.opt.isAdd;
    
    BOOL isAdd = YES;
    if (isAddString && [isAddString isEqualToString:@"N"])
        isAdd = NO;

    if (isAdd)
    {
        if ([self.currentFuncs.opt.uploadInTheFollowing isEqualToString:@"underTitle"] && !self.tempChildController)
        {
            [self showAddMorePlusButton]; //MN-1880 此处与安卓确认过逻辑，用新的悬浮加号按钮替换之前的新增按钮，以后如需兼容之前新增按钮的展示方式则要增加样式参数
        }
        else
            buttonItem = [self getRightBarButtonItemWithButtonName:buttonName];
    }
    
    if (self.ownParentViewController)
        self.ownParentViewController.navigationItem.rightBarButtonItem = buttonItem;
    else
        self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)refreshedAllSubviewsWithRealtimeDatas
{
    [self checkAndGotoNextViewController];
}

- (void)refreshData {
    // MN-925 新增  配置为 remote  remoteList 列表页请求  配置为 remoteAdd 列表页不请求新增页请求
    if ([self.currentFuncs.opt.isSearchable isEqualToString:@"remote"] ||
        [self.currentFuncs.opt.sendRequest isEqualToString:@"remote"] ||
        [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteList"]) {
        if (([self.needRefresh isEqualToString:@"1"] || self.isFirstLoad) && !self.isCalenderPattern) {
            [self headerSearchView:self.headerSearchView remoteSearch:nil isFromSearchLables:NO];
        } else if (self.isBackShowRefresh) { //YIHAIKERRY-4564
            self.isBackShowRefresh = NO;
            [self subclassReloadData];
        }
    } else {
        [self subclassReloadData];
    }
}
-(void)subclassReloadData{
    
}

/*日历模式才有*/
- (UIView*)tableViewHeadView {
    
    self.baseNewAcvtListHeadView = [[WSBaseNewAcvtListHeadView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, TABLE_HEAD_VIEW_HEIGHT) currentFuncs:self.currentFuncs addAcvtArray:self.addAcvtArray];
    self.baseNewAcvtListHeadView.delegate = self;
    
    
    return self.baseNewAcvtListHeadView;
}
- (void)reloadDataFromDb {
    /*
     显示当天的数据
     */
    NSString *empId = _subempid.length > 0? _subempid :[WSAppData getObjectbyKey:APPDATA_EMPID];
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    
    NSString *currentDate = [WSCurrentTime getDateString];
   
    NSArray *serviceDataArray = [service queryAcvtDatasWithStoreID:self.currentStore.Id acvtType:self.currentFuncs.filter searchText:currentDate genIDs:nil isRead:YES isRemoteSearch:(self.currentSaveDataType == WSSaveSeachedData) acvtSort:self.currentFuncs.opt.acvtSort withEmpId:empId];
    [self refreshWithServiceDataArray:serviceDataArray];

}
- (void)reloadData
{
    [[WSTestTools getInstance] keepTimeWithKey:@"newStoreList生成数据总耗时"];
    
    if (self.isCalenderPattern) {
        
        //SFA-23423
//        if (self.isFirstLoad) {
        
            [self reloadDataFromDb];
//        }
        [self resetCalenderViewsIcon];
    }else {
        
        NSString *empId = _subempid.length > 0? _subempid :[WSAppData getObjectbyKey:APPDATA_EMPID];
        
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *serviceDataArray = nil;
            // 如果isSearchable配置为remote 并且是页面第一次加载 则显示实时请求的数据。
        if ([self.currentFuncs.opt.isSearchable isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteList"])
        {
            
//            if (self.isFirstLoad) {
//            }else{
                // 只收索后台下发的，不去查本地修改的  SFA 箭牌 WRIGLEY-1585
            
          
            if ([self.currentFuncs.fv isEqualToString:FV_TAB_V6001]) {
                // SFA-17888 TAB_V6001 的特殊处理逻辑
                serviceDataArray = [service queryStoresWithAcvtType:self.currentFuncs.filter isRemoteSearch:YES acvtSort:self.currentFuncs.opt.acvtSort withEmpId:empId isCode:self.currentFuncs.opt.isCode];
            } else {
                serviceDataArray = [service queryAcvtDatasWithStoreID:self.currentStore.Id acvtType:self.currentFuncs.filter searchText:self.currentSearchText genIDs:nil isRead:YES isRemoteSearch:YES acvtSort:self.currentFuncs.opt.acvtSort  withEmpId:empId];
                
            }
//            }
            
        }else{
             if ([self.currentFuncs.fv isEqualToString:FV_TAB_V6001]) {
                 // SFA-17888 TAB_V6001 的特殊处理逻辑
                 serviceDataArray = [service queryStoresWithAcvtType:self.currentFuncs.filter isRemoteSearch:(self.currentSaveDataType == WSSaveSeachedData) acvtSort:self.currentFuncs.opt.acvtSort withEmpId:empId isCode:self.currentFuncs.opt.isCode];
             } else {
                 serviceDataArray = [service queryAcvtDatasWithStoreID:self.currentStore.Id acvtType:self.currentFuncs.filter searchText:self.currentSearchText genIDs:nil isRead:YES isRemoteSearch:(self.currentSaveDataType == WSSaveSeachedData) acvtSort:self.currentFuncs.opt.acvtSort withEmpId:empId];
//                 if (serviceDataArray.count == 0) {
//                     [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中请稍后...", nil) tips:nil tapTarget:self action:nil type:MBProgressHUDMessageTypeDone autoHideTime:0.1];
//
//                 }
             }
        }
        
        
        [self refreshWithServiceDataArray:serviceDataArray];
    }
    
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"newStoreList生成数据总耗时"];
    
}
- (void)refreshWithServiceDataArray:(NSArray *)serviceDataArray
{
    if ( self.isCalenderPattern && [self.selectedDates count] >  0) {
        [self reloadDataWithDates:self.selectedDates];
        
         /*不进行跟新*/
    } else {
        self.dataArray = [NSMutableArray arrayWithArray:serviceDataArray];
        
        //YIHAIKERRY-1142益海嘉里深圳分组需求
        if (_isGroupStyle) {
            [self.groupStyleDataArray removeAllObjects];
            [self.cacheDataArray removeAllObjects];
            
            BOOL isResetRightStr = NO;
            //去重 一共分多少个组
            NSMutableArray *groupNameArray = [NSMutableArray array];
            for (WSAcvtListDataItem *listItem in serviceDataArray) {
                if (![groupNameArray containsObject:listItem.groupName ? listItem.groupName : @"未分组"])
                {
                    if(!listItem.groupName)
                    {
                        listItem.groupName = @"未分组";
                    }
                    [groupNameArray addObject:listItem.groupName];

                    WSNewAddAcvtModel *model = [[WSNewAddAcvtModel alloc] init];
                    WSNewAddAcvtModel *cacheModel = [[WSNewAddAcvtModel alloc] init];
                    model.titleStr = listItem.groupName;
                    cacheModel.titleStr = listItem.groupName;
                    model.rightStr = listItem.groupSummary;
                    cacheModel.rightStr = listItem.groupSummary;
                    [self.groupStyleDataArray addObject:model];
                    [self.cacheDataArray addObject:cacheModel];
                }
                if (listItem.groupExpression.length >0) {
                    isResetRightStr = YES;
                }
            }
            
            //反循环 将组名相同的model放到各自对应的组里
            for (int i = 0; i < groupNameArray.count; i++) {
                NSString *groupName= groupNameArray[i];
                WSNewAddAcvtModel *model = self.groupStyleDataArray[i];
                WSNewAddAcvtModel *cacheModel = self.cacheDataArray[i];
                for (WSAcvtListDataItem *listItem in serviceDataArray) {
                    
                    //将重复的 归类到各自的组下
                    if ([groupName isEqualToString:listItem.groupName ? listItem.groupName : @"未分组"])
                    {
                        [model.subModelArray addObject:listItem];
                        [cacheModel.subModelArray addObject:listItem];
                    }
                }
            }
            if (isResetRightStr) {
                for (int i = 0 ; i < groupNameArray.count; i++) {
                    WSNewAddAcvtModel *model = self.groupStyleDataArray[i];
                    WSNewAddAcvtModel *cacheModel = self.cacheDataArray[i];
                    float numValue = 0.0;
                    float sumValue = 0.0;
                    for (WSAcvtListDataItem *listItem in model.subModelArray) {
                        //YIHAIKERRY-3877 SFA 益海嘉里-【订单管理】 【IOS】 提单总金额计算错误  不用逗号分割，改为用¥¥分割，因为价格为12,500 中的逗号冲突了
                        NSArray *tempArray = [listItem.groupExpression componentsSeparatedByString:APPENDING_STRING_TAG];
                        numValue += [(NSString *)[tempArray firstObject] floatValue];
                        
                        NSString * moneyStr = [tempArray lastObject];
                        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@"," withString:@""]; //把价格中的逗号去掉
                        sumValue += [moneyStr floatValue];
                    }
                    NSString *rightStr = [NSString stringWithFormat:@"%0.2lf/%0.2lf",numValue,sumValue];
                    model.rightStr = rightStr;
                    cacheModel.rightStr = rightStr;
                }
            }
        }
        
        [self.tableView reloadData];
       
        if ([self respondsToSelector:@selector(updateSMSButtonTitle)]) {
            [self updateSMSButtonTitle];
        }
        
        if ([self.dataArray count] > 0) {
            if (self.empty && ![self.empty isHidden]) {
                [self.empty setHidden:YES];
            }
        }
        
        //YIHAIKERRY-4240 2018-10-07
        if (_isGroupStyle) {
            [self.empty removeFromSuperview];
            self.empty = nil;
            if (self.groupStyleDataArray.count <= 0) {
                [self addEmptyView];
            }
        }
    }
}

- (BOOL)getIsLocalForward
{
    if ([self.currentFuncs.opt.acvtSort isEqualToString:@"1"]) {
        return NO;
    }
    
    return YES;
}

- (void)reloadDataWithDates:(NSArray *)dateStrs {
    
    NSString *empId = _subempid.length > 0? _subempid :[WSAppData getObjectbyKey:APPDATA_EMPID];
    if (self.isCalenderPattern && [dateStrs count] > 0) {
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        NSArray *queryDatasArry = [service queryAcvtDatasWithStoreID:self.currentStore.Id acvtType:self.currentFuncs.filter searchText:[dateStrs firstObject] genIDs:nil isRead:YES isRemoteSearch:(self.currentSaveDataType == WSSaveSeachedData) acvtSort:self.currentFuncs.opt.acvtSort  withEmpId:empId];
        self.dataArray = [NSMutableArray arrayWithArray:queryDatasArry];
        [self.tableView reloadData];
    }
    
}


 /*
  获取上月最后6天下月前6天之间的时间
  */
- (NSArray *)getCalenderShowLimitDateStrs {
   
    NSMutableArray *dateStrs = [NSMutableArray array];
    for (NSInteger i = - CALENDER_LIMIT_DAY; i < 0; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:0 day:i+1]];
    }
  
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    
    for (NSInteger i = 0; i < numberOfDaysInMonth; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:0 day:i+1]];
    }
    
    for (NSInteger i = 0; i < CALENDER_LIMIT_DAY ; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:1 day:i+1]];
    }
    return dateStrs;
}

/*
 获取当前日历显示月份的上月最后6天下月前6天之间的时间
 */
- (NSArray *)getDisplayCalenderShowLimitDateStrs {
    
    NSMutableArray *dateStrs = [NSMutableArray array];
    for (NSInteger i = - CALENDER_LIMIT_DAY; i < 0; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth] day:i+1]];
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    NSUInteger numberOfDaysInMonth = range.length;
    
    for (NSInteger i = 0; i < numberOfDaysInMonth; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth] day:i+1]];
    }
    
    for (NSInteger i = 0; i < CALENDER_LIMIT_DAY ; i++) {
        [dateStrs addObject:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth+1] day:i+1]];
    }
    return dateStrs;
}

- (void)resetCalenderViewsIcon {
//    NSArray *dateStrs = [self getCalenderShowLimitDateStrs];
    NSArray *dateStrs = [self getDisplayCalenderShowLimitDateStrs];
    
    WSAcvtModel *acvtModel = [[WSAcvtModel alloc] init];
    acvtModel.currentFuncs = self.currentFuncs;
    acvtModel.currentStore = self.currentStore;
    NSMutableDictionary *calendarIconsDic = [WSCalendarLogicService getCalendaDutyPlanIcon:dateStrs usingGenId:NO acvtModel:acvtModel withoutEmptyDic:NO];
    if ([calendarIconsDic allKeys].count > 0) {
        WSBaseNewAcvtListHeadView *baseAcvtListViewHeadView = (WSBaseNewAcvtListHeadView *)self.tableView.tableHeaderView;
        if ([baseAcvtListViewHeadView isKindOfClass:[WSBaseNewAcvtListHeadView class]]) {
            [baseAcvtListViewHeadView reloadCalendarSubViewIcons:calendarIconsDic];
        }
    }
}

-(void)setSubempid:(NSString*)empid
{
    _subempid = empid;
}

- (void)addDutyPlanNewAcvt:(WSAcvtBean *)acvtBean {
}

- (NSArray *)addAcvtArray {
    if (!_addAcvtArray || [_addAcvtArray count] == 0) {
        NSString *isAdd = self.currentFuncs.opt.isAdd;
        if (!(isAdd && [isAdd isEqualToString:@"N"])) {
            
            WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
            
            if (!self.currentStore) {
                _addAcvtArray = [baseAcvtDBService queryAcvtsByFilter:self.currentFuncs.filter acvtCode:self.currentFuncs.opt.isAdd];
            } else {
                _addAcvtArray = [baseAcvtDBService queryAcvtsWithStoreId:self.currentStore.Id filter:self.currentFuncs.filter];
            }
            
        }
    }
    
    return _addAcvtArray;
}


- (NSArray *)getAcvtBeansWithFilter:(NSString *)filter {
    if (!filter) {
        NSLog(@"filter  is empty !");
        return nil;
    }

    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    return [baseAcvtDBService queryAcvtsByFilter:filter acvtCode:nil];
}

- (BOOL)isAcvtBeanHasAcvtName:(WSAcvtBean *)acvtBean {
    
    BOOL hasAcvtName = NO;
    
    for (WSAcvtBean_qst *qst in acvtBean.qsts) {
        if (qst.isAcvtName && [qst.isAcvtName length] > 0 && ![qst.isAcvtName isEqualToString:@"0"]) {
            hasAcvtName = YES;
            break;
        }
    }
    
    return hasAcvtName;
}


- (WSAcvtBean *)filterAcvtBeanWithId:(NSString *)acvtId {
    NSPredicate* pre=[NSPredicate predicateWithFormat:@"self.acvtId==%@",acvtId];
    NSArray* tmpFilterAcvts= [self.filterAcvts filteredArrayUsingPredicate:pre];
    return [tmpFilterAcvts firstObject];
    
}




/*删除没有配置主副右标题的数据*/
//- (void)removeAddedStoreOfNoTitle {
//    
//    NSMutableArray *removeStores = [NSMutableArray array];
//    [self.addNewAcvtList enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL * stop) {
//        WSAddStoreObject *addStore = (WSAddStoreObject *)obj;
//        NSString *mainTitle = [self.storesMainTitle objectForKey:addStore.update_md5id];
//        NSString *subHeadString = [self.storesSubhead objectForKey:addStore.update_md5id];
//        NSString *rightTitleString = [self.storesRightTitle objectForKey:addStore.update_md5id];
//        if ( !([mainTitle length] > 0 || [subHeadString length] > 0 || [rightTitleString length] > 0)) {
//            [removeStores addObject:addStore];
//            
//        }
//    }];
//    [self.addNewAcvtList removeObjectsInArray:removeStores];
//}

- (void)createHeaderSearchView{
    
    CGFloat height = 0;
    if (!self.headerSearchView) {
        
        NSString *searchTag = self.currentFuncs.opt.searchTag;
        if ((!searchTag || [searchTag length]== 0) && self.currentFuncs.opt.searchQuestion) {
            searchTag = self.currentFuncs.opt.searchQuestion;
            
        }
        CGFloat searchViewHeight = k_SearchHeaderViewDefaultHeight;
        if ([self isUploadGeoLocationInfo]) {
            if ([[UIDevice currentDevice] systemVersionNotLowerThan:@"7.0"]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                CGFloat leftView_origin_x = INTERFACE_IS_PHONE ? 0 :175;
                leftView = [[UIView alloc] initWithFrame:CGRectMake(leftView_origin_x, 0, LeftBarWidth, 44)];
                self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                _locationBtn.showsTouchWhenHighlighted = YES;
                _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                NSString *title = NSLocalizedString(@"beijing", nil);
                //            [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
                [_locationBtn setTitle:title forState:UIControlStateNormal];
                [_locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [_locationBtn setTitleColor:[UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:206.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
                _locationBtn.enabled = NO;
                [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [leftView addSubview:_locationBtn];
                
                markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
                markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                markImageView.contentMode = UIViewContentModeRight;
                [leftView addSubview:markImageView];
                [self.view addSubview:leftView];
                
#else
                nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
                for (UIView *view in nbar.subviews) {
                    if ([view isKindOfClass:[UITextField class]]) {
                        [view removeFromSuperview];
                    }
                }
                self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                _locationBtn.showsTouchWhenHighlighted = YES;
                _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                NSString *title = NSLocalizedString(@"beijing", nil);
                [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
                [_locationBtn setTitle:title forState:UIControlStateNormal];
                [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [nbar addSubview:_locationBtn];
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
                imageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                imageView.contentMode = UIViewContentModeRight;
                [nbar addSubview:imageView];
                [headerView addSubview:nbar];

#endif
            }else{
                nbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, LeftBarWidth, 44)];
                nbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                
                for (UIView *view in nbar.subviews) {
                    if ([view isKindOfClass:[UITextField class]]) {
                        [view removeFromSuperview];
                    }
                }
                self.locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _locationBtn.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                _locationBtn.showsTouchWhenHighlighted = YES;
                _locationBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                NSString *title = NSLocalizedString(@"beijing", nil);
                [_locationBtn.titleLabel adjustsFontSizeToFitWidth];
                [_locationBtn setTitle:title forState:UIControlStateNormal];
                [_locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [nbar addSubview:_locationBtn];
                
                markImageView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"carat-open.png"]];
                markImageView.frame = CGRectMake(0, 0, LeftBarWidth, 44);
                markImageView.contentMode = UIViewContentModeRight;
                [nbar addSubview:markImageView];
                [self.view addSubview:nbar];

            }
            _currentLocationString = NSLocalizedString(@"beijing", nil);
        }
        float xoffset = [self isUploadGeoLocationInfo] ? LeftBarWidth : 0.0;
        float width = self.view.bounds.size.width - xoffset;
        
        self.headerSearchView = [[WSHeaderSearchView alloc] initWithFrame:CGRectMake(xoffset, 0, width, searchViewHeight) funcs:self.currentFuncs isSearchable:self.currentFuncs.opt.isSearchable searchTag:searchTag nativeStoreList:self.dataArray];
        self.headerSearchView.autoresizingMask =UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        if (self.headerSearchView) {
            self.headerSearchView.delegate = self;
//            self.headerSearchView.storeList = self.addNewAcvtList;
            height = CGRectGetHeight(self.headerSearchView.frame);
            [self.view addSubview:self.headerSearchView];
        }
        
        
//        if (IOS7_OR_LATER) {
//            _locationBtn.backgroundColor = k_SearchBarBgColor;
//        }
        
        if ([self isUploadGeoLocationInfo]) {
            _locationSelectIndex = -1;
            [self locationMe];
        }
        if (height > 0 && self.tableView) {
            CGRect newFrame = self.tableView.frame;
            newFrame.origin.y += height;
            newFrame.size.height -= height;
            self.tableView.frame = newFrame;
        }

        
    }
}
- (BOOL)isUploadGeoLocationInfo {
    
    if ([self.currentFuncs.opt.isOpenGeo isEqualToString:@"Y"]){
        return YES;
    }
    return NO;
}

// SFA-29104 （改变定位的通知方式，去掉在本类中的逆地理编码解析，直接返回解析后的结果）
- (void)locationMe {
    
    DDLogInfo(@"（wsbasenewacvtlistviewcontroller）: 使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
    
}

- (void)locationFinished:(NSNotification *)sender{
    
    DDLogInfo(@"（locationFinished）:通知回来了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    self.location = tmpLocationDescribe.location.coordinate;
    
    if (error) {
        LogError(@"获取位置失败,class:%@,error:%@",[self class], error);
    }else{
        [self resetLocation:tmpLocationDescribe.provinceName locality:tmpLocationDescribe.cityName subLocality:tmpLocationDescribe.subLocality];
    }
}

- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality {
    
    /*  _locationSelectIndex = -1 代表选择定位信息
     *  >= 0 代表选择的 locationArray 的 index
     */
    if (_locationSelectIndex >= 0) {
        return;
    }
    if (locality) {
        _currentLocationString = locality;
    } else if (administrativeArea) {
        _currentLocationString = administrativeArea;
    }
    [[NSUserDefaults standardUserDefaults] setObject:_currentLocationString forKey:kGlobalCityName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (_locationSelectIndex == -1) {
        [_locationBtn setTitle:_currentLocationString forState:UIControlStateNormal];
    }
}

- (void)calenderSelectedDate:(NSString *)selectedDate {
    
    
}

- (void) updateSMSButtonTitle{

}
- (NSString *)getNextMonthSixthDay {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth
                               fromDate:now];
    comps.month = comps.month + 1;
    comps.day = 6;
    NSDate *resultDate = [cal dateFromComponents:comps];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:resultDate];
}


- (NSString *)getDistanceBeforeMonthSixthDay {
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:now];
    comps.day = -6;
    NSDate *resultDate = [cal dateFromComponents:comps];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:resultDate];
}

- (void)requestDutyPlanWithDisplayMonth:(NSInteger)month {
    
    [self querying_messageTips];

    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] ;
    NSString *compress = @"1";
    
    NSString *startDate = [NSString stringNotNilWithValue:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth] day:-6]];

    NSString *ds = self.currentFuncs.ds;
    if (ds == nil) {
        ds = ACVTDIS;
    }
    NSString *objId = [NSString stringNotNilWithValue:ds];
    NSString *endDate = [NSString stringNotNilWithValue:[WSCurrentTime dateFromNowMonth:[WSCurrentTime distanceFromNowToMonth:_currentDisplayMonth+1] day:6]];

    NSString *cellId = @"no cellid";
    
    NSMutableDictionary *searchDic = [NSMutableDictionary dictionary];
    [searchDic setObject:empId forKey:APPDATA_EMPIDBIGI];
    [searchDic setObject:compress forKey:@"compress"];
    [searchDic setObject:startDate forKey:@"startDate"];
    [searchDic setObject:objId forKey:@"objId"];
    [searchDic setObject:endDate forKey:@"endDate"];
    [searchDic setObject:cellId forKey:@"cellid"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteSearchFinish:) name:k_Remote_Notify object:nil];
    [[WSRequestHelper shareInstance] postRequestData:searchDic notifyName:k_Remote_Notify];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isGroupStyle)
    {
        return self.groupStyleDataArray.count;
    }
    else
    {
         return 1;
    }
}

#pragma mark WSHeaderSearchViewDelegate Methods

- (void)headerSearchViewCancelButtonClicked:(WSHeaderSearchView *)view {
    
    self.currentSearchText = nil;
    self.currentSaveDataType = WSSaveLocalData;
    // 如果点击取消并且配置remote 的情况，默认请求全部数据
    if ([self.currentFuncs.opt.isSearchable isEqualToString:@"remote"])
    {
        [self headerSearchView:self.headerSearchView remoteSearch:nil isFromSearchLables:NO];
        
    }else{
        [self reloadData];

    }
}

- (NSArray *)headerSearchView:(WSHeaderSearchView *)view nativeSearch:(NSString *)text{
    
    self.currentSearchText = text;
    self.currentSaveDataType = WSSaveLocalData;
    [self reloadData];

    return self.dataArray;
}
- (void)headerSearchView:(WSHeaderSearchView *)view remoteSearch:(NSString *)text isFromSearchLables:(BOOL)isFromLables{
    self.currentSearchText = text;

    // 服务器搜索
    [self querying_messageTips];

    NSMutableDictionary *searchDic = [NSMutableDictionary dictionary];
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] ;
    NSString *bizeDate = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *objId = ACVTDIS;
    NSString *value = [NSString stringNotNilWithValue:text];  //NSString *objId = @"acvtdis";
    // 上传的搜索标签以空格隔开
    // 三棵树（线上的是以逗号隔开）的需和安卓后台及惠氏保持一致（下次升级后台需要修改）
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [searchDic setObject:empId forKey:APPDATA_EMPIDBIGI];
    [searchDic setObject:bizeDate forKey:APPDATA_BIZDATE];
    
    //MSTD-7479 2017-01-05
    if ([self.currentFuncs.ds length] > 0 && ![self.currentFuncs.ds isEqualToString:@"acvt"])
        objId = self.currentFuncs.ds;
    
    [searchDic setObject:objId forKey:@"objId"];
    if (isFromLables) {
        [searchDic setObject:value forKey:@"lables"];
    }else {
        [searchDic setObject:value forKey:@"value"];
    }
    if ([self isUploadGeoLocationInfo]) {
        [searchDic setObject:[[NSNumber numberWithDouble:self.location.latitude] stringValue] forKey:GPS_LAT];
        [searchDic setObject:[[NSNumber numberWithDouble:self.location.longitude] stringValue] forKey:GPS_LON];
        [searchDic setObject:_locationBtn.titleLabel.text forKey:GEONAME];
    }
    
    if (self.currentStore.Id > 0 ) {
        [searchDic setObject:self.currentStore.Id forKey:@"storeId"];

    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteSearchFinish:) name:k_Remote_Notify object:nil];
    [[WSRequestHelper shareInstance] postRequestData:searchDic notifyName:k_Remote_Notify];
    
}

- (void)remoteSearchFinish:(id)sender {
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:k_Remote_Notify object:nil];
    // 解析数据
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *dic = [info objectFromJSONString];
    
    NSString *ds = self.currentFuncs.ds;
    if (ds == nil) {
        ds = ACVTDIS;
    }
    
    for (NSString *key in dic.allKeys)
    {
        if ([key rangeOfString:ACVTDIS].location != NSNotFound)
            ds = key;
    }
    
    NSArray *remoteAcvtdis = [dic objectForKey:ds];
    NSString *flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    
    if ([flag isEqualToString:@"0"])
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"refresh_failure", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        return;
    }
    
    if (remoteAcvtdis && [remoteAcvtdis count] > 0)
    {
        self.currentSaveDataType = WSSaveSeachedData;
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        if ([self.currentFuncs.opt.isSearchable isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteList"])
        {
            NSDictionary *storeDicInfo = nil;
            if ([remoteAcvtdis isKindOfClass:[NSDictionary class]])
                storeDicInfo = (NSDictionary *)remoteAcvtdis;
            else if ([remoteAcvtdis isKindOfClass:[NSArray class]])
            {
                //MN-472 2018-02-05 单个节点数据处理逻辑变化
                storeDicInfo = [(NSArray *)remoteAcvtdis firstObject];
                if (![storeDicInfo[@"jsonType"] isEqualToString:@"array"])
                    storeDicInfo = dic;
            }
            //MENGNIU-1021 董宏 获取服务器数据
            [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo genId:nil isRemoteSearch:YES];
        }
        else
            [service replaceToTableWithDicts:remoteAcvtdis FromNode:ACVTDIS hasNewData:YES storeID:nil isRemoteSearch:YES];
        
        //将回显acvt_qst_answer 转为opt_value 的方法 processServerAcvtDisValue 统一处理
//        WSBaseAcvtdisDBService *processServer = [[WSBaseAcvtdisDBService alloc] init];
//        if (![processServer processServerAcvtDisValue]) {
//            LogError(@"processServerAcvtDisValue 失败");
//        }

    }
    //MN-2254 2018-04-28 同安卓一致不做提示
//    else
//    {
//        NSString *alterString = NSLocalizedString(@"no_result", nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:alterString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//    }
    
    [self subclassReloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isGroupStyle)
    {
        WSNewAddAcvtModel *model;
        if ( self.groupStyleDataArray.count > section)
        {
            model = self.groupStyleDataArray[section];
        }
        
        return model.subModelArray.count;
    }
    else
    {
        return ((self.dataArray.count > 0) ? self.dataArray.count : 1);
        //return [self.dataArray count];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataArray.count <= 0)
        return CGRectGetHeight(tableView.bounds) - tableView.tableHeaderView.frame.size.height;
    WSAcvtListDataItem *acvtItem;
//    YIHAIKERRY-1819 donghong
    if (self.isGroupStyle)
    {
        WSNewAddAcvtModel *addAcvtModel = self.groupStyleDataArray[indexPath.section];
        acvtItem = [addAcvtModel.subModelArray objectAtIndex:indexPath.row];

    }
    else
    {
    acvtItem = [self.dataArray objectAtIndex:indexPath.row];
    }
    BOOL isShowleftIcon = NO;
    if ([acvtItem.leftIconUrl length] > 0)
        isShowleftIcon = YES;
    return [WSStoreInfoTableViewCell cellHeightWithMainTitle:acvtItem.mainTitle rightTitle:acvtItem.rightTitle subTitle:acvtItem.subTitle.string
                                                   leftTitle:acvtItem.leftTitle tableWidth:tableView.width isShowActionTip:self.showActionTip
                                                   isNotRead:acvtItem.unRead isShowLeftIcon:isShowleftIcon];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    static NSString *CellIdentifier = @"WSStoreInfoTableViewCell";
    
    WSStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WSStoreInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
   // YIHAIKERRY-1505 
    WSAcvtListDataItem *acvtItem;
    
    if (self.isGroupStyle)
    {
        WSNewAddAcvtModel *addAcvtModel = self.groupStyleDataArray[indexPath.section];
        acvtItem = [addAcvtModel.subModelArray objectAtIndex:indexPath.row];
    }
    else
    {
        acvtItem = [self.dataArray objectAtIndex:indexPath.row];
    }
    [cell setData:acvtItem];
    
    if (tableView.isEditing) {
        
        if (acvtItem.isChecked) {
            
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }else{
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    
    cell.imageView.image = nil;
    if (self.showActionTip) {
        
        cell.isShowActionTip = self.showActionTip;
        
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        action.store_id = _subempid;
        
        action.func_code = self.currentFuncs.fc;
        action.dict_id = acvtItem.acvtID;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = acvtItem.genID;
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
        }else{
            
            action.module_fc = action.func_code;
        }
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action isQueryTitle:YES];
        if ([status isEqualToString:ActionDone])
        {
            cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
        }
        else if ([status isEqualToString:ActionWorking])
        {
            cell.imageView.image = [UIImage imageNamed:@"visit_doing.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"visit_not_start.png"];
        }
        
        //辉瑞ECALL会议审批流程需要同时兼容旧方案和新方案
        if ([self.currentFuncs.opt.isShowActionTip isEqualToString:@"Y"] || [self.currentFuncs.opt.isUseNewId isEqualToString:@"Y"]) { //新方案
            //辉瑞ECALL，已上传过的数据会套用另一个acvt模板返回，该模板isUploaded = 1标记已上传过
            NSPredicate *pre2 = [NSPredicate predicateWithFormat:@"isUploaded=%@ AND acvtId=%@",@"1",acvtItem.acvtID];
            NSArray *filterArray2 =[self.filterAcvts filteredArrayUsingPredicate:pre2];
            if([filterArray2 count] > 0){
                cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
            }
        }else { //旧方案
            //pim会按月回显
            
            
//            WSAcvtBeanArray* array=[WSAppData getObjectbyKey:ACVTS];
//            NSPredicate* pre=[NSPredicate predicateWithFormat:@"isUploaded=%@ AND gen_id=%@ AND acvtId=%@",@"1",acvtItem.genID,acvtItem.acvtID];
//            NSArray* filterArray=[array.acvtArray filteredArrayUsingPredicate:pre];
//            if(filterArray.count>0){
//                cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
//            }
        }
        
    }
    
    
//    [cell setStyleWithIndexPath:indexPath totalCount:[self.dataArray count]];
    
    return cell;
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


#pragma mark WSBaseNewAcvtListHeadViewDelegate Method
- (void)headView:(WSBaseNewAcvtListHeadView *)headView selectedAcvtBean:(WSAcvtBean *)selectedAcvtBean {
    [self addDutyPlanNewAcvt:selectedAcvtBean];
}

- (void)headView:(WSBaseNewAcvtListHeadView *)headView selectedDates:(NSArray *)selectedDates {
    self.selectedDates = selectedDates;
    [self reloadDataWithDates:selectedDates];
}


- (void)headView:(WSBaseNewAcvtListHeadView *)headView changeToHeight:(CGFloat)height {
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = self.baseNewAcvtListHeadView;
    [self.tableView endUpdates];
}

- (void)headView:(WSBaseNewAcvtListHeadView *)headView changeToMonth:(NSInteger)month
{
    _currentDisplayMonth = month;
    [self requestDutyPlanWithDisplayMonth:month];
}

#pragma mark - WCPopListViewDelegate
- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex{
    
    [self addDutyPlanNewAcvt:[self.addAcvtArray objectAtIndex:anIndex]];
}


#pragma mark - Getter
- (NSMutableArray *)groupStyleDataArray
{
    if (!_groupStyleDataArray) {
        _groupStyleDataArray = [NSMutableArray array];
    }
    return _groupStyleDataArray;
}

- (NSMutableArray *)cacheDataArray
{
    if (!_cacheDataArray) {
        _cacheDataArray = [NSMutableArray array];
    }
    return _cacheDataArray;
}






//========================================================================================================================================================================

#pragma mark - 自动添加更多产品跳转逻辑方法
- (void)autoAddMoreJumpLogic {
    
    WSAcvtViewController *currentNewAcvtVC = [[WSAcvtViewController alloc] initWithAcvt:[self.addAcvtArray firstObject]
                                                                                  Funcs:self.currentFuncs Store:self.currentStore md5:nil];
    currentNewAcvtVC.moduleFC = self.moduleFC;
    currentNewAcvtVC.currentVisitAction = self.currentVisitAction;
    currentNewAcvtVC.wcBaseViewdelegate = self;
    [currentNewAcvtVC viewWillAppear:NO];
    [currentNewAcvtVC viewDidAppear:NO];
    //[[WSAcvtVCManager sharedInstance] setCurrentActiveNotShownNewAddAcvtVC:_currentNewAcvtVC];
    [[WSAcvtVCManager sharedInstance] saveAcvtViewController:currentNewAcvtVC];
    
    BOOL isNext = ([self.currentFuncs.opt.sendRequest isEqualToString:@"remote"] || [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteAdd"]);
    if (!isNext) {
        [self checkAndGotoNextViewController];
    }
}

#pragma mark - 标准跳转逻辑方法
- (void)standardJumpLogic {
    
    WSFuncsBean *bean = [self.currentFuncs.funcsArray firstObject];
    if (bean && [bean.fv isEqualToString:REPOPRT_FV]) {
        NSString *className = [WSPlistHelper valueForKey:bean.fv withPlistName:kControllerMappingFileName];
        UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:bean];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        self.isBackShowRefresh = YES;
        return;
    }
    
    NSString *isAdd = self.currentFuncs.opt.isAdd;
    if (!(isAdd && [isAdd isEqualToString:@"N"])) {
        
        if ([self.addAcvtArray count] == 1) {
            [self addDutyPlanNewAcvt:[self.addAcvtArray firstObject]];
        }
        else if ([self.addAcvtArray count] > 1) {
            WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
            UIView *rootView = delegate.window.rootViewController.view;
            NSArray *acvtNameArray = [self.addAcvtArray valueForKeyPath:@"@unionOfObjects.acvtName"];
            WCPopListView *view = [[WCPopListView alloc] initWithTotalArry:acvtNameArray selectedArray:nil withSelectedMode:WCPopListSigleSelected
                                                             animationType:WCPopListAnimationTypeFromPoint maxHeight:rootView.height - 64];
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
    
    [[WSStatisticsManager sharedInstance] insertStoreInfoSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean
                                                          currentFuncBean:self.currentFuncs store:self.currentStore senceId:SCENE_ADD_ACVT
                                                               eventValue:self.currentFuncs.buttonName startTime:[WSCurrentTime getTimeMillisStringForDevice]
                                                                  endTime:nil genId:[WSStatisticsManager getGenId]];
}

#pragma mark - 全部跳转逻辑方法
- (void)allJumpLogic {
    
    if([self.currentFuncs.opt.autoAddMore isEqualToString:@"1"]) {
        [self autoAddMoreJumpLogic];
        return;
    }
    [self standardJumpLogic];
}

#pragma mark - 自动跳转下一个视图管理器方法 MN-1863_2018-04-19
- (void)autoJumpToNextViewController {
    
    if ([self.currentFuncs.opt.isSearchable isEqualToString:@"remote"] ||
        [self.currentFuncs.opt.sendRequest isEqualToString:@"remoteList"] ||
        self.currentStore.inReadonlyMode) {//MN-3847--zhangmin 2018-10-19  没有进店的时候，inReadonlyMode 为yes ，不自动跳转到添加产品页面
        return;
    }
    
    if([self.currentFuncs.opt.autoAddMore isEqualToString:@"1"] && [self.dataArray count] < 1) {
        //SFA-28021
        [self addAcvtAutoJumpTime];
        [self performSelector:@selector(autoAddMoreJumpLogic) withObject:nil afterDelay:0.1];
        return;
    }
    
    if([self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"]) {
        if([self.dataArray count] < 1) {
            [self performSelector:@selector(standardJumpLogic) withObject:nil afterDelay:0.1];
        }
    }
    else if(![self.currentFuncs.opt.autoJumpNext isEqualToString:@"0"]) {
        if([self.dataArray count] < 1 && [self.currentFuncs.buttonName length] > 0 && !self.isPageSegmentView && !self.isTabMode) {
            [self performSelector:@selector(standardJumpLogic) withObject:nil afterDelay:0.1];
        }
    }
}

#pragma mark - 设置自动跳转时间
- (void)addAcvtAutoJumpTime {
    NSString *value = [WSCurrentTime getDateTime];
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kPropertyUserDefaultsKey];
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    [newDictionary setObject:value forKey:kAddAcvtAutoJumpTime];
    [[NSUserDefaults standardUserDefaults] setObject:newDictionary forKey:kPropertyUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 新增按键响应方法
- (void)addNewAcvt:(id)sender {
    [self allJumpLogic];
}

#pragma mark - 检查并跳转下一个视图管理器
- (void)checkAndGotoNextViewController {
    [self gotoAddMoreProdsViewController];
}

#pragma mark - 跳转更多产品视图管理器
- (void)gotoAddMoreProdsViewController {
    
    WSAcvtViewController *acvtViewController =  [[WSAcvtVCManager sharedInstance] getAcvtViewController];
    WSAcvtDataGridViewPanel *firstAcvtDataGridViewPanel = nil;
    //for (UIView *view in _currentNewAcvtVC.acvtview.subviews) {
    for (UIView *view in acvtViewController.acvtview.widgetArray) {
        if ([view isKindOfClass:[WSAcvtDataGridViewPanel class]]) {
            WSAcvtDataGridViewPanel *acvtDataGridViewPanel = (WSAcvtDataGridViewPanel *)view;
            if (!acvtDataGridViewPanel.isHidden && ![acvtDataGridViewPanel.getReadonly isEqualToString:@"1"]) {
                firstAcvtDataGridViewPanel = acvtDataGridViewPanel;
                break;
            }
        }
    }
    
    [[WSAcvtVCManager sharedInstance] saveAcvtDataGridViewPanel:firstAcvtDataGridViewPanel];
    //[[WSAcvtVCManager sharedInstance] setCurrentActiveAcvtDataGridViewPanel:firstAcvtDataGridViewPanel];
    
    UIViewController *moreProductVC = nil;
    if ([firstAcvtDataGridViewPanel getAcvtDataSource].currentTableItem.opt.prodtrees &&
        [firstAcvtDataGridViewPanel getAcvtDataSource].currentTableItem.opt.prodtrees.length > 0) {
        moreProductVC = [[WSNewAddProdsWithSeriesViewController alloc] initWithDataGridComponentDataSource:[firstAcvtDataGridViewPanel getAcvtDataSource]
                                                                                                     title:NSLocalizedString(@"more_product_label", nil)];
        moreProductVC.currentStore = self.currentStore;
        ((WSNewAddProdsWithSeriesViewController *)moreProductVC).currentAcvtBean = self.currentAcvt;
        ((WSNewAddProdsWithSeriesViewController *)moreProductVC).addProdsJumpStyle = @"2";
    } else {
        moreProductVC = [[MoreProductViewController  alloc] initWithProductArray:[firstAcvtDataGridViewPanel getAcvtDataSource].moreProductArray
                                                                           title:NSLocalizedString(@"more_product_label", nil)];
    }
    [self.navigationController pushViewController:moreProductVC animated:YES];
}

#pragma mark - 显示更多以上按键
- (void)showAddMorePlusButton {
    
    typeof(self) __weak weakSelf = self;
    [[LEOAssistiveTouch sharedInstance] setMainBtnClickedCallbackBlock:^{
        [weakSelf allJumpLogic];
    }];
    [[LEOAssistiveTouch sharedInstance] setMainBtnImage:nil];
    [[LEOAssistiveTouch sharedInstance] setMainBtnImage:[UIImage imageNamed:@"icon_plus"]];
    [LEOAssistiveTouch show];
}

#pragma mark - 隐藏更多按键
- (void)hideAddMoreButton {
    
    [[LEOAssistiveTouch sharedInstance] setMainBtnImage:[UIImage imageNamed:@"icon_online_chat"]];
    [[LEOAssistiveTouch sharedInstance] setMainBtnClickedCallbackBlock:nil];
    [LEOAssistiveTouch hide];
    [WSSellFloatWindowManager hideSellFloatWindow];

}

#pragma mark - 获取具有按钮名称的右栏按钮项方法
- (UIBarButtonItem *)getRightBarButtonItemWithButtonName:(NSString *)buttonName {
    
    UIBarButtonItem *buttonItem = nil;
    if ([buttonName length] > 0) {
        if ([buttonName isEqualToString:@"Y"]) {
            buttonItem = [self barButtonItemImage:@"title-bar_create_icon" target:self action:@selector(addNewAcvt:)];
        } else {
            buttonItem = [self barButtonItemTitle:buttonName target:self action:@selector(addNewAcvt:)];
        }
    }
    return buttonItem;
}

@end
