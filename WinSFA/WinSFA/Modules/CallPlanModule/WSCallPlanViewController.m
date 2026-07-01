//
//  WSCallPlanViewController.m
//  WinSFA
//
//  Created by winchannel on 2017/5/4.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSCallPlanViewController.h"
#import "WSAppData.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "ZYCalendarView.h"
#import "WSSubempstoreBeanArray.h"
#import "WSVisitStorePlanTable.h"
#import "WSVisitPeoplePlanTable.h"
#import "WSPopViewController.h"
#import "WSMutiserieListViewController.h"
#import "I_W_Cell.h"
#import "DateUtil.h"
#import "WSSearchBar.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtViewController.h"
#import "WSBaseAcvtdisDBService.h"

#import "WSBaseStoreDBService.h"
#import "WSStoreBean+Plan.h"
#import "WSMapView.h"
#import "WSBaseFunsDBService.h"
#import "WSBaseStoreInfoDBService.h"
#import "WSStorePlanManager.h"


//#define kCalendarPadding    MAIN_CELL_PADDING
#define kCalendarPadding    0

#define kCalendarViewWidth (INTERFACE_IS_PHONE ? SCREEN_WIDTH - 2 * kCalendarPadding : 330.0f)
#define kCalendarViewWeekHeight  125.0f
#define KNoteLabelFont [UIFont systemFontOfSize:12.0]
#define kRedisOtherSubtitleHeight 20.0f

@implementation WSCallPlanSchedule
@synthesize date = date_;
@synthesize tasks = tasks_;
@end

@interface WSCallPlanViewController ()<UISearchBarDelegate,UIAlertViewDelegate,WSPopViewControllerDelegate,WSMutiserieListViewControllerDelegate,ZYCalendarDelegate>{
    
    enCalendarViewType calendarViewType;
}
@property (nonatomic, strong) ZYCalendarView *zyCalendarView;
//@property (nonatomic, strong) WSMapView *mapView;
@property (nonatomic, strong) WSSearchBar *ownSearchBar;
@property (nonatomic, strong) NSMutableArray * filterArray;
@property (nonatomic, strong) NSMutableArray * transitArray;

@property (nonatomic, strong) NSDate * currentDate;

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray *visitedStores;

@property (nonatomic,strong) MBProgressHUD* m_HUD;
@property (nonatomic, strong) NSMutableArray* pointArray;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSString* monthFetchMethod;
@property (nonatomic,strong) NSString* calendarMethod;
@property (nonatomic,strong) NSString* visitCountMethod;

@property (nonatomic,strong) NSString *redisOtherMethod;

@property (nonatomic,strong) NSString *timeFrom;


@property (nonatomic,strong) UIBarButtonItem *rightBtn;

@property (nonatomic, strong)NSMutableArray *stateArray;

@property (nonatomic, strong)NSMutableArray *inplanStoreArray;

@property (nonatomic, strong) WSAcvtBean *visitPuposeAcvtBean;

@property (nonatomic, strong)WSAcvtBean_qst *visitCountQst;//门店拜访次数

@property (nonatomic, strong)WSAcvtBean_qst *plan_limitQst;//拜访次数限制

@property (nonatomic, strong)WSAcvtBean_qst *plan_countQst;//已做拜访计划次数


@property (nonatomic, strong) WSCallPlanTableViewCell *planCell;

@property (nonatomic, strong) UIView *headerView;


@property (nonatomic, strong) DateUtil *currentDateUtil;

@property (nonatomic, strong) NSDateFormatter *dateFor;

@property (nonatomic, strong)NSDate *maxDate;

@property (nonatomic, strong)NSDate *minDate;

@property (nonatomic, assign) BOOL isUploaded;

@property (nonatomic, assign) BOOL isFirstLoadMap;
@property (nonatomic, assign) BOOL isStoreBean;//是否是门店
@property (nonatomic, assign) BOOL isFirstLoad;         //  标识拜访计划是否是第一次进入

@end

@implementation WSCallPlanViewController
@synthesize tableView = tableView_;
- (MBProgressHUD *)m_HUD {
    if (!_m_HUD) {
        _m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view insertSubview:_m_HUD atIndex:3];
    }
    return _m_HUD;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isFirstLoad = YES;

    self.stateArray =[[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc] init];
    self.calendarMethod=@"calendar";
    self.currentDateUtil = [[DateUtil alloc]init];
    self.isFirstLoadMap = YES;
    self.dateFor = [NSDateFormatter standardDateFormatter];
    [self.dateFor setDateFormat:@"yyyy-MM-dd"];
    self.currentDate=[NSDate date];
    
//   SFA-17013 【ios】汉高移动手机端，我的计划点击在右上角地图按钮，闪退
    //判断是否是门店
    // SFA-17006 加入ds为空默认为Stores的逻辑
    // SFA-17006 加入ds为空默认为Stores的逻辑 SFA-21004 添加 : 判断
    NSString *ds = self.currentFuncs.ds;
    if ([ds length] > 0) {
        NSArray *keyArray = [ds componentsSeparatedByString:@":"];
        ds = [keyArray firstObject];
        if ([ds isEqualToString:STORE] || [ds isEqualToString:@"stores"]) {
            // SFA-22711 兼容平台无 STORE 的设置
            if ([ds isEqualToString:STORE]) {
                ds = @"stores";
            }
            self.isStoreBean = YES;
        } else {
            self.isStoreBean = NO;
        }
    } else {
        self.isStoreBean = YES;
    }
    [[WSVisitStorePlanTable sharedTable] deleteAll];
    
    if (self.currentFuncs.filter && [self.currentFuncs.filter rangeOfString:@":visitCount"].location != NSNotFound) {
        self.visitCountMethod = self.currentFuncs.filter;
        self.funcStyle = WSCallPlanTableViewCellStyleVisitCount;
        WSBaseAcvtDBService *base_acvt_db = [[WSBaseAcvtDBService alloc]init];
        self.visitPuposeAcvtBean = [base_acvt_db queryAcvtWithAcvtCode:@"mapDataToMobile"];
        self.visitCountQst = [base_acvt_db queryQstWithAcvtQstCode:@"visitcount"];
        self.plan_limitQst = [base_acvt_db queryQstWithAcvtQstCode:@"plan_limit"];
        self.plan_countQst = [base_acvt_db queryQstWithAcvtQstCode:@"plan_count"];
        [self requestVisitPuposeOfThisMonth];
        
    }
//    SFA-17873
//    【ios】手机端汉高移动，我的计划不显示小图标和拜访次数
    if (self.currentFuncs.redis && self.currentFuncs.redis.length > 0 && (![self.currentFuncs.redis isEqualToString:@"0"])) {
        self.redisOtherMethod = self.currentFuncs.redis;
        self.funcStyle = WSCallPlanTableViewCellStyleRedisOther;
    }
    
    self.visitedStoreDict = [[NSMutableDictionary alloc]init];
    if(self.isStoreBean){
        
        WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
//        donghong SFA-17926 查询带回显的 门店表（支庆帮忙添加）
//        NSArray *storesArray = [baseStoreDBService queryStoreWithSearchObjId:@"stores" styp:self.currentFuncs.styp];
        NSArray *storesArray = [baseStoreDBService queryAllStoreWithFuncCode:self.currentFuncs.fc empId:[WSAppData getObjectbyKey:APPDATA_EMPID] styp:self.currentFuncs.styp searchStr:nil search_objId:ds isSearchable:NO storeAccessMode:0 acvtId:nil selectedQstValues:nil rangeConditions:nil distance:0 pageNumber:-1 distanceSort:nil otherDataDic:nil storeFiletrTyp:self.currentFuncs.opt.storeFiletr notPlan:YES parentStoreFc:self.currentFuncs.opt.parentStoreFc];
        self.dataArray = [self DuplicateRemoval:storesArray];
//        SFA-18403
//        SFA汤臣倍健，点击拜访计划，闪退！
        //在这遍历的目的是再点击每一天的时候不会再去遍历了
        NSMutableArray *storeBeanIds = [NSMutableArray array];
        for (WSStoreBean *storeBean in self.dataArray) {
            [storeBeanIds addObject:storeBean.Id];
        }
        NSString *str = [NSString stringWithFormat:@"callPlanstoreBeanIds%@",self.currentFuncs.opt.storeFiletr];
        NSUserDefaults *defaultsManager = [NSUserDefaults standardUserDefaults];
        [defaultsManager setObject:[storeBeanIds componentsJoinedByString:@","] forKey:str];
        [defaultsManager synchronize];
        

        
    }else{
        
        WSSubempstoreBeanArray* array= [WSAppData getObjectbyKey:SUBEMPSTORES];
        [self.dataArray addObjectsFromArray:array.subempstoreArray];
        
    }
    
    
    
    if(INTERFACE_IS_PAD)
    {
        calendarViewType = en_calendar_type_month;
        
        [self.view removeAllSubviews];
        
        CGFloat calendarViewHeight = [self getCalendarMonthHeight];
        //SFA 项目SFA-20467 我的计划中，日期往前翻只能翻到4月16日，再也无法往前翻,经与报告人沟通暂改为左右各能烦三个月，由11周改为24周。
        ZYCalendarView *calendarView = [[ZYCalendarView alloc]initWithFrame:CGRectMake(kCalendarPadding, 23, kCalendarViewWidth, calendarViewHeight) CalendarType:en_calendar_type_month withPageNumber:24 withWeekStartDay:self.currentFuncs.value];
        self.zyCalendarView = calendarView;
        self.zyCalendarView.delegate = self;
        [self.zyCalendarView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:self.zyCalendarView];
        
        UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(kCalendarPadding*2+calendarView.width, 0, 1, self.view.height)];
        lineView.backgroundColor= [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
        lineView.autoresizingMask=UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:lineView];
        
        CGRect rect=CGRectMake(kCalendarViewWidth+20*3, 20 , 410, self.view.height-20);
        self.tableView = [[FMMoveTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        self.tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableHeaderView = [self getTableHeaderView];
        [self.view addSubview:self.tableView];
        
        NSString *noteStr = [NSString stringWithFormat:NSLocalizedString(@"callplanhint", nil)];
        CGSize labelsize = [noteStr ws_sizeWithFont:KNoteLabelFont constrainedToWidth:300 lineBreakMode:NSLineBreakByCharWrapping];
        
        UILabel* noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(calendarView.frame) + MAIN_PADDING , (kCalendarViewWidth) - 30, labelsize.height)];
        noteLabel.text = noteStr;
        noteLabel.font= KNoteLabelFont;
        noteLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [noteLabel setNumberOfLines:0];
        noteLabel.autoresizingMask= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:noteLabel];
        
        
        self.navigationItem.hidesBackButton = YES;
        
        
        
        NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        
    }else {
        if ([self.currentFuncs.typ isEqualToString:@"2"]) {
            calendarViewType = en_calendar_type_month;
            
        }else{
            calendarViewType = en_calendar_type_week;
        }
        
        [self.view removeAllSubviews];
        
        CGFloat calendarViewHeight = [self getCalendarMonthHeight];
        //SFA 项目SFA-20467 我的计划中，日期往前翻只能翻到4月16日，再也无法往前翻,经与报告人沟通暂改为左右各能烦三个月，由11周改为24周。
        ZYCalendarView *calendarView = [[ZYCalendarView alloc]initWithFrame:CGRectMake(kCalendarPadding, 0, kCalendarViewWidth, calendarViewHeight) CalendarType:calendarViewType withPageNumber:24 withWeekStartDay:self.currentFuncs.value];
        self.zyCalendarView = calendarView;
        self.zyCalendarView.delegate = self;
        [self.zyCalendarView setBackgroundColor:[UIColor whiteColor]];
     
        
        CGFloat tableViewHeight = (calendarViewType == en_calendar_type_week ) ? self.view.bounds.size.height - calendarViewHeight : self.view.bounds.size.height ;
        CGFloat tableViewOffsetY = (calendarViewType == en_calendar_type_week ) ? self.zyCalendarView.bottom : 0 ;
        
        UIView *headerView = [self getTableHeaderView];
        
        headerView.frame = CGRectMake(0, tableViewOffsetY, headerView.width, headerView.height);
        
        self.headerView = headerView;
        
        [self.view addSubview:headerView];
        
        tableViewOffsetY = headerView.bottom;
        
        tableViewHeight = tableViewHeight - headerView.height;
        
        if (calendarViewType == en_calendar_type_week) {
            [self.view addSubview:calendarView];
//            self.mapView =[[WSMapView alloc]initWithFrame:CGRectMake(0,self.zyCalendarView.bottom , self.view.bounds.size.width, self.view.bounds.size.height - calendarViewHeight ) funcs:self.currentFuncs stores:nil];
//            self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleBottomMargin;
//            [self.view addSubview:self.mapView];
        }

        self.tableView = [[FMMoveTableView alloc] initWithFrame:CGRectMake(0,tableViewOffsetY , self.view.bounds.size.width, tableViewHeight) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.tableView];
        self.tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//        self.tableView.tableHeaderView = [self getTableHeaderView];
        
    }
    
    if(self.isStoreBean){
        
        self.method=@"callPlan";
        self.monthFetchMethod=@"callweekplandata";
    }else{
        self.method=@"followcallplan";
        self.monthFetchMethod=@"sfdaynnum";
    }
    //门店有下级门店用数字标记，否则用图片标记识别
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"self.pid !=nil"];
    //医生
    NSArray *subStoreVisited = [[self.dataArray filteredArrayUsingPredicate:predicate1]mutableCopy];
    if (subStoreVisited.count >0) {
        self.funcStyle = WSCallPlanTableViewCellStyleVisitSubempStore;
        self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
        
    }
    
    
    if (self.currentFuncs.opt.minWeek && self.currentFuncs.opt.minWeek.length > 0) {
        int minWeek = [self.currentFuncs.opt.minWeek intValue];
        self.minDate =  [self.zyCalendarView.fromDate dateByAddingTimeInterval:minWeek * 7*3600*24];
    }
    if (self.currentFuncs.opt.maxWeek && self.currentFuncs.opt.maxWeek.length > 0) {
        int maxWeek = [self.currentFuncs.opt.maxWeek intValue];
        self.maxDate =  [self.zyCalendarView.toDate dateByAddingTimeInterval:maxWeek * 7*3600*24];
    }

    [self registerForKeyboardNotifications];
    
//    [self.zyCalendarView.calendarCollectionView reloadData];
}
//- (void)addbtn
//{
//    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
//    [backBtn setBackgroundColor:[UIColor clearColor]];
//    //                [backBtn setImage:[UIImage imageForName:@"icon_back.png"] forState:UIControlStateNormal];
//    [backBtn setImage:[[UIImage scaledImageForName:@"icon_back" ofType:@"png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    //                [backBtn setImage:[UIImage imageForName:@"icon_back_press.png"] forState:UIControlStateHighlighted];
//    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//
//    //创建home按钮
//    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem=homeButtonItem;
//}
- (void)addToolBar {
    
    
    [self getNavigationItem].rightBarButtonItems= nil;
    NSMutableArray *rightBarArray = [NSMutableArray array];
    
    
    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [uploadBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [uploadBtn addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn setImage:[UIImage scaledImageForName:@"icon_upload" ofType:@"png"] forState:UIControlStateNormal];
    self.rightBtn = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    [rightBarArray addObject:self.rightBtn];
    
    if (!self.currentFuncs.opt.isTodayVisit && [self.currentDate compare:[NSDate date]] != NSOrderedDescending) {
        self.rightBtn.enabled = NO;
    }
    if (self.currentFuncs.opt.isMap) {
        
        UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mapBtn setFrame:CGRectMake(0, 0, 25, 25)];
        [mapBtn addTarget:self action:@selector(switchViews) forControlEvents:UIControlEventTouchUpInside];
        [mapBtn setImage:[UIImage scaledImageForName:@"storeMapMode" ofType:@"png"] forState:UIControlStateNormal];
        UIBarButtonItem *mapBarBtn = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
        [rightBarArray addObject:mapBarBtn];
    }
    [self getNavigationItem].rightBarButtonItems = rightBarArray;
}

- (void)requestVisitPuposeOfThisMonth{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visitPuposeFinish:) name:@"visitPuposeFinish" object:nil];
    [[WSRequestHelper shareInstance] postRequestOnRoadsManager:@{@"objId" : self.visitCountMethod} notifyName:@"visitPuposeFinish"];
}

- (void)visitPuposeFinish:(NSNotification *)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"visitPuposeFinish" object:nil];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error) {
        return ;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary  *dataDic = [info objectFromJSONString];
    if ([dataDic objectForKey:self.visitCountMethod]){
        if ([self.visitCountMethod hasPrefix:STOREACVTDIS]) {
            WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
            [baseAcvtDisSerice replaceToTableWithDicts:[dataDic objectForKey:self.visitCountMethod] FromNode:self.visitCountMethod hasNewData:YES storeID:nil];
        }
    }
}

- (CGFloat)getCalendarMonthHeight {
    CGFloat calendarViewHeight = 0;
    if ( calendarViewType == en_calendar_type_week ) {
        calendarViewHeight = kCalendarViewWeekHeight;
    }  else {
        CGFloat calendarMonthColums = 7;
        CGFloat calendarMonthRows = 6;
        CGFloat calendarMonthCellHeight = (kCalendarViewWidth / calendarMonthColums ) * calendarMonthRows;
        calendarViewHeight = kTimeHeadViewHeight + kDateHeadViewHeight + calendarMonthCellHeight;
    }
    return calendarViewHeight;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    // SFA-23892
    if ((!IOS11_OR_LATER && !_isFirstLoad) || IOS11_OR_LATER) {
        [self addToolBar];
    }
//    [self addbtn];
//  SFA-27291  donghong
    if ((self.isLoaded && [self.currentFuncs.opt.isSearchable isEqualToString:@"auto"])) {
        [self calendarView:self.zyCalendarView didMoveToMonth:self.currentDate];
    }
    if (!self.isLoaded) {
        [self calendarView:self.zyCalendarView didMoveToMonth:[NSDate date]];
        self.isLoaded = YES;
    }
    if (self.currentDate) {
        [self downloadSelectDateData];
    }
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.zyCalendarView SetDateViewDot];    //执行事件
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // SFA-23892
    if (!IOS11_OR_LATER) {
        if (self.isFirstLoad) {
            [self addToolBar];
        }
        self.isFirstLoad = NO;
    }
    
}

- (BOOL)shouldPauseBackAction {
    return YES;
}

- (void)backAction {
  
    if( [[WSStorePlanManager sharedInstance].isChangeDic objectForKey:self.currentFuncs.fc] || [WSStorePlanManager sharedInstance].isChange){
        
        NSString *message = NSLocalizedString(@"back_confirm2", nil);

        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];

        [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
            [self save:nil];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
            [[WSStorePlanManager sharedInstance] deleteData];
            [self backToParent];
        }];
        [alert show];
        
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"please_save", nil)];
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
//            [[WSStorePlanManager sharedInstance] deleteData];
//            [self backToParent];
//        }];
//        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
//            [self save:nil];
////            [self backToParent];
//        }];
//        [alert show];
        
    }else {
        [[WSStorePlanManager sharedInstance] deleteData];
        [self backToParent];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filterArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject<I_W_Cell> *storeBean = [self.filterArray objectAtIndex:indexPath.row];
    
    CGFloat cellHeight = [self.planCell heightForRowWithStore:storeBean WithCellWidth:self.tableView.width withFuncStyle:self.funcStyle];
    
    NSString *subTitleStr = [self getRedisOtherSubtitleWithStoreId:[storeBean getId]];
    
    // SFA-14567 此处暂时只需要显示固定高度的一行
    if (subTitleStr && subTitleStr.length > 0) {
        cellHeight += kRedisOtherSubtitleHeight;
    }
    
    return cellHeight;

}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WSCallPlanTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSString *seialNumberStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    
    NSObject<I_W_Cell> *storeBean = [self.filterArray objectAtIndex:indexPath.row];

    NSString *visitSubStoresCount = nil;
    NSString *visitCount = nil;
    NSString *subTitleStr = nil;
    
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        NSArray *visitSubStoreS = [self getVisitedSubStoreWithPid:[storeBean getId]];
        if (visitSubStoreS.count > 0) {
            visitSubStoresCount = [NSString stringWithFormat:@"%ld",(unsigned long)visitSubStoreS.count];
        }
    }else if (self.funcStyle == WSCallPlanTableViewCellStyleVisitCount){
        WSBaseAcvtdisDBService *acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
        WSBaseStoreAcvtDisObject *object = [[acvtdisService queryStoreAcvtDisBeanArrayWithStoreID:[storeBean getId] acvtQstID:self.visitCountQst.acvtQstId noteName:self.visitCountMethod] firstObject];
//         SFA-20283 - SFA 汉高移动【ios】：我的计划中未显示拜访次数。(当时和安卓对的时候好像逻辑上的差别有点大)
        //        如果其他项目需要可以加参数做判断
        BOOL isShowVisitCount = NO ;
//        if ([DateUtil checkSameWeekWithWeek1:self.currentDate withWeek2:[NSDate date]]) {
//            isShowVisitCount = YES;
//        }
        if ([DateUtil checkSameMonthWithMonth1:self.currentDate withMonth2:[NSDate date]]) {
                isShowVisitCount = YES;
            }
        if (object.acvt_qst_answer.length >0 && isShowVisitCount) {
            visitCount =  [NSString stringWithFormat:@"已拜访%@次",object.acvt_qst_answer];
        }else{
            visitCount =  [NSString stringWithFormat:@"已拜访0次"];
        }
    }
    else if (self.funcStyle == WSCallPlanTableViewCellStyleRedisOther){

        subTitleStr = [self getRedisOtherSubtitleWithStoreId:[storeBean getId]];
    }
    
    
    if (cell == nil) {
        cell = [[WSCallPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withFuncStyle:self.funcStyle withvisitedSubStores:visitSubStoresCount];
        cell.delegate = self;
    }
    cell.contentView.autoresizesSubviews = YES;
    [cell setRedisOtherSubtitle:subTitleStr];
    [cell setStore:storeBean withOpt:self.currentFuncs.opt];
//    [cell setSb:storeBean];
    [cell setSeialNumberStr:seialNumberStr];
    [cell setVisitCount:visitCount];
    
    self.planCell = cell;
    return cell;
}

- (NSString *)getRedisOtherSubtitleWithStoreId:(NSString *)storeId
{
    NSString *subTitleStr = @"";
    
//    WSBaseFunsDBService *funcsDBService = [[WSBaseFunsDBService alloc] init];
//    NSString *subTitleStr = [funcsDBService getFuncsNameWithFilter:self.redisOtherMethod];
    
    // SFA-14351 目前只支持从storeInfo表中取subtitle的数据，后期可扩展
    WSBaseStoreInfoDBService *storeInfoDBService = [WSBaseStoreInfoDBService shareInstance];
    
    WSStoreInfoBean *storeInfo = [storeInfoDBService queryStoreInfoByStoreId:storeId andType:self.redisOtherMethod];
    
    if (storeInfo.col_value && storeInfo.col_value.length > 0) {
        subTitleStr = [NSString stringWithFormat:@"%@", storeInfo.col_value];
    }else{
        subTitleStr = @"";
    }
    
    return subTitleStr;
}

- (void)resetTableHeaderView{
    
    if (INTERFACE_IS_PHONE) {
        if (self.filterArray.count>0) {
            self.headerView.hidden = NO;
        }
        else
        {
            self.headerView.hidden = YES;
        }
    }
}
- (UIView *)getTableHeaderView{
    
    
    CGFloat calendarViewHeight = [self getCalendarMonthHeight];
    
    UIView *searchView = nil;
    if((self.filterArray && self.filterArray.count > 0 ) || self.ownSearchBar.searchBar.text.length > 0 || self.currentDate){
        searchView = [self generateSearchView];
    }
    CGFloat headerViewHeight = (calendarViewType != en_calendar_type_week) ? calendarViewHeight +  CGRectGetHeight(searchView.frame) + 40 :CGRectGetHeight(searchView.frame) + 40 ;
    UIView *headerTView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,headerViewHeight)];
    [headerTView setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat lineViewHeight =  (calendarViewType != en_calendar_type_week) ? calendarViewHeight + 5 :5;
    UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(0, lineViewHeight, self.view.width, 1)];
    lineView.backgroundColor= [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
    [headerTView addSubview:lineView];
    
    if (self.zyCalendarView && calendarViewType != en_calendar_type_week) {
        [self.zyCalendarView setFrame:CGRectMake(kCalendarPadding, 0, kCalendarViewWidth, calendarViewHeight)];
        [headerTView addSubview:self.zyCalendarView];
    }
    
    NSString *noteStr = [NSString stringWithFormat:NSLocalizedString(@"callplanhint", nil)];
    
    if (self.currentFuncs.opt.label) {
        noteStr = self.currentFuncs.opt.label;
    }
    
    CGFloat labelWidth = kCalendarViewWidth - 30;
    CGSize labelsize = [noteStr ws_sizeWithFont:KNoteLabelFont constrainedToWidth:labelWidth lineBreakMode:NSLineBreakByCharWrapping];
    
    UILabel* noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, lineViewHeight + 5, labelWidth, labelsize.height)];
    noteLabel.text = noteStr;
    noteLabel.font= KNoteLabelFont;
    [noteLabel setNumberOfLines:0];
    noteLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [headerTView addSubview:noteLabel];
    
    if (searchView) {
        [searchView setFrame:CGRectMake(0, CGRectGetMaxY(noteLabel.frame), self.view.width, 44)];
        [headerTView addSubview:searchView];
        //    SFA-17011
        //    【ios】汉高移动手机端我的计划模块，要设置的门店无法上下滑动
        headerTView.height = searchView.bottom;
    }
    return headerTView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSObject<I_W_Cell> *storeBean = [self.filterArray objectAtIndex:indexPath.row];
    
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        NSArray *subemp = [self getSubStoreWithPid:[storeBean getId]];
        if (subemp && subemp.count >0) {
            //弹出医生列表框
            [self pushViewControllerWithSlectStore:storeBean];
        }else{
            NSString *title = @"该门店无下属门店";
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }
}
-(void)didSelectedWithStoreCode:(NSString *)storeCode otherParams:(NSDictionary *)otherParams {
    
    BOOL beforeToday=NO;
    if([[self.dateFor stringFromDate:self.currentSch.date] isEqualToString:[self.dateFor stringFromDate:[NSDate date]]] ){
        if (self.currentFuncs.opt.isTodayVisit) {
            beforeToday = NO;
        }else{
            beforeToday=YES;
        }
        
    }else if ([self.currentSch.date compare:[NSDate date]] == NSOrderedAscending){
        beforeToday = YES;
    }

    if ((self.minDate && [self.currentSch.date compare:self.minDate] == NSOrderedAscending) ||
       (self.maxDate && [self.currentSch.date compare:self.maxDate] == NSOrderedDescending)) {
        if ([[self.dateFor stringFromDate:self.currentSch.date] isEqualToString:[self.dateFor stringFromDate:self.maxDate]]) {
            beforeToday = NO;
        }else{
            beforeToday = YES;
        }
        
    }
    if (otherParams) {
        NSString *storeId = [otherParams objectForKey:@"storeId"];
        WSBaseAcvtdisDBService *acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
        WSBaseStoreAcvtDisObject *plan_limitObject = [[acvtdisService queryStoreAcvtDisBeanArrayWithStoreID:storeId acvtQstID:self.plan_limitQst.acvtQstId noteName:self.visitCountMethod] firstObject];
        NSString *plan_limit = plan_limitObject.acvt_qst_answer ? : @"0";
        if (plan_limit && [plan_limit floatValue] > 0) {
            WSBaseStoreAcvtDisObject *plan_countObject = [[acvtdisService queryStoreAcvtDisBeanArrayWithStoreID:storeId acvtQstID:self.plan_countQst.acvtQstId noteName:self.visitCountMethod] firstObject];
            NSString *plan_count = plan_countObject.acvt_qst_answer ? : @"0";
            //filter 有值不为空   plan_count > plan_limt 并且 plan_limt不为空
            if (self.visitCountMethod  && self.visitCountMethod.length > 0 && [plan_count  floatValue] >= [plan_limit floatValue]) {
                beforeToday = YES;
            }
        }
    }

    if(beforeToday){
        NSString *title = NSLocalizedString(@"callplan_upload_notify", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    self.currentSch.changed = YES;
    
    NSPredicate *predicate;
    NSObject<I_W_Cell> *storeObject = [self.filterArray  firstObject];
    if ([storeObject getCode] && [storeObject getCode].length >0) {
        predicate =  [NSPredicate predicateWithFormat:@"self.code = %@", storeCode];
    }else{
        predicate =  [NSPredicate predicateWithFormat:@"self.name = %@", storeCode];
    }
    NSObject<I_W_Cell> *storeBean = [[self.filterArray filteredArrayUsingPredicate:predicate] firstObject];
    if (self.isStoreBean) {
        WSStoreBean *sb = (WSStoreBean *)storeBean;
        if (self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore) {
            sb.bPlanned = !sb.bPlanned;
        }
        self.currentStore = sb;
        
    }else{
        
        WSSubempstoreBean *sb =(WSSubempstoreBean *)storeBean;
        sb.bPlanned = !sb.bPlanned;
    }
    
    [WSStorePlanManager sharedInstance].isChange = YES;
    BOOL setFCTime = YES;
    for (NSString*str in [[WSStorePlanManager sharedInstance].fcTime allKeys]) {
        if ([[self.dateFor stringFromDate:self.currentDate] isEqualToString:[[WSStorePlanManager sharedInstance].fcTime objectForKey:str]]) {
            setFCTime = NO;
            break;
        }
        
    }
    if (setFCTime) {
        [[WSStorePlanManager sharedInstance].fcTime setObject:[self.dateFor stringFromDate:self.currentDate] forKey:self.currentFuncs.fc];
    }
    [[WSStorePlanManager sharedInstance].isChangeDic setObject:@"1" forKey:self.currentFuncs.fc];

    if (self.currentStore.bPlanned) {
        [[WSStorePlanManager sharedInstance].storePlanArr addObject:@{@"doc_date":[self.dateFor stringFromDate:self.currentDate],@"store_id":self.currentStore.Id}];
    }
    else
    {
        for (NSInteger i = 0; i < [WSStorePlanManager sharedInstance].storePlanArr.count ; i++) {
            NSDictionary *dic = [WSStorePlanManager sharedInstance].storePlanArr[i];
            if ([[dic objectForKey:@"doc_date"] isEqualToString:[self.dateFor stringFromDate:self.currentDate]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]] isEqualToString:self.currentStore.Id]) {
                [[WSStorePlanManager sharedInstance].storePlanArr removeObjectAtIndex:i];
                break;
            }
            
        }

    }
    [self sortFilterArray];
    [self resetTableHeaderView];
   
    [self.tableView reloadData];
}
- (void)didSelectedWithStoreCode:(NSString *)storeCode{
    
    [self didSelectedWithStoreCode:storeCode otherParams:nil];
}

- (void)pushViewControllerWithSlectStore:(NSObject<I_W_Cell> *)aStore{
    
    
    WSMutiserieListViewController *vc = [[WSMutiserieListViewController alloc]initWithStore:(WSStoreBean *)aStore withCurrentDate:[self.dateFor stringFromDate:self.currentDate] withFilter:self.currentFuncs.filter];
    vc.delegate = self;
    vc.title = [aStore getName];
    WSPopViewController *popCon = [[WSPopViewController alloc]initWithContentViewController:(WCBaseViewController *)vc];
    popCon.confirmSelector = @selector(upload);
    popCon.delegate = self;
    popCon.popViewSize = CGSizeMake(600, 520);
    
    if (IOS8_OR_LATER) {
        popCon.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:popCon animated:YES completion:nil];
    
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.filterArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    
    WSStoreBean *fromStore =  (WSStoreBean*)self.filterArray[fromIndexPath.row];
    WSStoreBean *toStore =  (WSStoreBean*)self.filterArray[toIndexPath.row];
    NSInteger form = 0;
    NSInteger to = 0;
    NSInteger select = 0;
    for (NSInteger i = 0; i < [WSStorePlanManager sharedInstance].storePlanArr.count ; i++) {
        NSDictionary *dic = [WSStorePlanManager sharedInstance].storePlanArr[i];
        if ([[dic objectForKey:@"doc_date"] isEqualToString:[self.dateFor stringFromDate:self.currentDate]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]] isEqualToString:fromStore.Id]) {
            form = i;
            select++;
            continue;
        }
        if ([[dic objectForKey:@"doc_date"] isEqualToString:[self.dateFor stringFromDate:self.currentDate]] && [[NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]] isEqualToString:toStore.Id]) {
            to = i;
            select++;
            continue;
        }
        if (select>1) {
            break;
        }
    }

    if (select>1 && fromStore && toStore) {
        [[WSStorePlanManager sharedInstance].storePlanArr exchangeObjectAtIndex:form withObjectAtIndex:to];
        [WSStorePlanManager sharedInstance].isChange = YES;
        BOOL setFCTime = YES;
        for (NSString*str in [[WSStorePlanManager sharedInstance].fcTime allKeys]) {
            if ([[self.dateFor stringFromDate:self.currentDate] isEqualToString:[[WSStorePlanManager sharedInstance].fcTime objectForKey:str]]) {
                setFCTime = NO;
                break;
            }
            
        }
        if (setFCTime) {
            [[WSStorePlanManager sharedInstance].fcTime setObject:[self.dateFor stringFromDate:self.currentDate] forKey:self.currentFuncs.fc];
        }

    }
    
    WSCallPlanTableViewCell *fromCell = [tableView cellForRowAtIndexPath:fromIndexPath];
    WSCallPlanTableViewCell *toCell = [tableView cellForRowAtIndexPath:toIndexPath];
    
    NSString *tempValue = toCell.seialNumberStr;
    toCell.seialNumberStr = fromCell.seialNumberStr;
    fromCell.seialNumberStr = tempValue;
    
    
    if(self.isStoreBean){
        
//        WSStoreBean *sb_fromIndexPath = [self.filterArray objectAtIndex:fromIndexPath.row];
//        WSStoreBean *sb_toIndexPath = [self.filterArray objectAtIndex:toIndexPath.row];
//        NSUInteger fromIndex=[self.currentSch.tasks indexOfObject:sb_fromIndexPath];
//        NSUInteger toIndex=[self.currentSch.tasks indexOfObject:sb_toIndexPath];
        [self.currentSch.tasks exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        
    }else{
        WSSubempstoreBean *sb_fromIndexPath = [self.filterArray objectAtIndex:fromIndexPath.row];
        WSSubempstoreBean *sb_toIndexPath = [self.filterArray objectAtIndex:toIndexPath.row];
        NSUInteger fromIndex=[self.currentSch.tasks indexOfObject:sb_fromIndexPath];
        NSUInteger toIndex=[self.currentSch.tasks indexOfObject:sb_toIndexPath];
        [self.currentSch.tasks exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
    }
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
        proposedDestinationIndexPath = sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (BOOL)moveTableView:(FMMoveTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSPredicate* preSelected = [NSPredicate predicateWithFormat:@"bPlanned == 1"];
    NSArray* arraySelected = [self.filterArray filteredArrayUsingPredicate:preSelected];
    if (indexPath.row>arraySelected.count-1 || arraySelected.count==0) {
        return NO;
    }
    [[WSStorePlanManager sharedInstance].isChangeDic setObject:@"1" forKey:self.currentFuncs.fc];

    self.currentSch.changed=YES;
    return YES;
}

- (void)didMoveUpdateSource{
    
    //    [self save:nil];  // 需求看此jira    SFA 项目 SFA-3202
    
}

- (NSArray *)getSubStoreWithPid:(NSString *)pid{
    
    NSMutableArray *subArray = [[NSMutableArray alloc]init];
    for (WSStoreBean *bean in self.dataArray) {
        if ([bean.pid isEqualToString:pid]) {
            if (self.currentFuncs.filter) {
                if ([self.currentFuncs.filter isEqualToString:bean.styp]) {
                    [subArray addObject:bean];
                }
                
            }else{
                [subArray addObject:bean];
            }
        }
    }
    return [NSArray arrayWithArray:subArray];
    
}

- (NSArray *)getVisitedSubStoreWithPid:(NSString *)pid{
    
    NSPredicate *subPredicate = nil;
    if (self.currentFuncs.filter && self.currentFuncs.filter.length >0) {
        subPredicate = [NSPredicate predicateWithFormat:@"self.pid == %@ and self.styp == %@",pid,self.currentFuncs.filter];
    }else{
        subPredicate = [NSPredicate predicateWithFormat:@"self.pid == %@",pid];
    }
    //拜访过的医生
    NSArray *subVisitedStores = [self.visitedStores filteredArrayUsingPredicate:subPredicate];
    
    return [NSArray arrayWithArray:subVisitedStores];
    
}

-(void)sortFilterArray
{
//    SFA-28156 董宏
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:self.filterArray.count];
    for (WSStoreBean *storeBean in self.transitArray) {
        for (WSStoreBean *storeBeanFilter in self.filterArray) {
            if ([storeBean.Id isEqualToString:storeBeanFilter.Id]) {
                [arr addObject:storeBeanFilter];
                break;
            }
        }
    }
    NSPredicate* preSelected = [NSPredicate predicateWithFormat:@"bPlanned == 1"];
    NSArray* arraySelected = [arr filteredArrayUsingPredicate:preSelected];
    arraySelected = [self sortDataSourceArrayUploadList:arraySelected];
//    arraySelected = [self sortDataSourceArrayCheckSubtitleWithOriginArray:arraySelected];
    NSPredicate* preUnSelected = [NSPredicate predicateWithFormat:@"bPlanned == 0"];
    NSArray* arrayUnSelected = [arr filteredArrayUsingPredicate:preUnSelected];
//    arrayUnSelected = [self sortDataSourceArrayCheckSubtitleWithOriginArray:arrayUnSelected];

    [self.filterArray removeAllObjects];
    [self.filterArray addObjectsFromArray:arraySelected];
    [self.filterArray addObjectsFromArray:arrayUnSelected];
    
    arraySelected = [self.currentSch.tasks filteredArrayUsingPredicate:preSelected];
    arrayUnSelected = [self.currentSch.tasks filteredArrayUsingPredicate:preUnSelected];
    [self.currentSch.tasks removeAllObjects];
    [self.currentSch.tasks addObjectsFromArray:arraySelected];
    [self.currentSch.tasks addObjectsFromArray:arrayUnSelected];
    self.zyCalendarView.number = arraySelected.count;
    
}

- (NSArray *)sortDataSourceArrayCheckSubtitleWithOriginArray:(NSArray *)originArray
{
    NSMutableArray *doHaveSubtitleMArray = [[NSMutableArray alloc] init];
    NSMutableArray *donotHaveSubtitleMArray = [[NSMutableArray alloc] init];
    NSMutableArray *sortedMArray = [[NSMutableArray alloc] init];
    
    for (WSStoreBean *storeBean in originArray) {
        NSString *subTitleStr = [self getRedisOtherSubtitleWithStoreId:[storeBean getId]];
        if (subTitleStr && subTitleStr.length > 0) {
            [doHaveSubtitleMArray addObject:storeBean];
        }else{
            [donotHaveSubtitleMArray addObject:storeBean];
        }
    }
    
    [sortedMArray addObjectsFromArray:doHaveSubtitleMArray];
    [sortedMArray addObjectsFromArray:donotHaveSubtitleMArray];

    return [NSArray arrayWithArray:sortedMArray];
}
//SFA-28636 donghong
- (NSArray *)sortDataSourceArrayUploadList:(NSArray *)uploadList
{
    NSMutableArray *sortedMArray = [[NSMutableArray alloc] init];
    
   
    if([WSStorePlanManager sharedInstance].storePlanArr)
    {
        for (NSDictionary *dic in [WSStorePlanManager sharedInstance].storePlanArr) {
            if ([[dic objectForKey:@"doc_date"] isEqualToString:[self.dateFor stringFromDate:self.currentDate]]) {
                for (WSStoreBean *storeBean in uploadList) {
                    if ([[NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]] isEqualToString:storeBean.Id]) {
                        [sortedMArray addObject:storeBean];
                        break;
                    }
                }
            }
        }
        return [NSArray arrayWithArray:sortedMArray];
    }
    return uploadList;
}

- (UIView*) generateSearchView
{
    float headerWidth = INTERFACE_IS_PAD ? CGRectGetWidth(self.tableView.frame) : self.view.bounds.size.width;
    float headerHeight = INTERFACE_IS_PAD ? 64.0f : 44.0f;
    if(self.ownSearchBar==nil){
        WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0, 0, headerWidth, headerHeight) isResetTextField:NO isResetBackgroundColor:NO isTop:NO isNotAutoresizingFlexible:YES];
        self.ownSearchBar = searchBar;
        self.ownSearchBar.searchBar.delegate = self;
    }
    
    UIView* headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, headerHeight)];
    if (INTERFACE_IS_PHONE) {
        [headerView setBackgroundColor:MAIN_SEARCH_BG_COLOR];
    }
    [headerView addSubview:self.ownSearchBar];
    
    self.ownSearchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    //判断是否下你是搜索框
    if(self.currentFuncs.opt.isSearchable && [self.currentFuncs.opt.isSearchable isEqualToString:@"N"]){
        headerView.hidden=YES;
        headerView.frame=CGRectZero;
    }
    return headerView;
}

#pragma mark- CalendarDelegate
- (BOOL)calendarViewScrollViewTodayAndICurrentSchIsChanged{
    return  [[WSStorePlanManager sharedInstance].isChangeDic objectForKey:self.currentFuncs.fc] ? YES : NO;
//    return self.currentSch.changed;
}

- (void)calendarView:(ZYCalendarView *)aCalendarView didSelecteDate:(NSDate *)aDate{
    BOOL ascend=NO;
    
    if([[self.dateFor stringFromDate:aDate] isEqualToString:[self.dateFor stringFromDate:[NSDate date]]] ){
        if (self.currentFuncs.opt.isTodayVisit) {
            ascend = NO;
        }else{
            ascend= YES;
            
        }
        
    }else if([aDate compare:[NSDate date]] == NSOrderedAscending){
        ascend = YES;
    }
    
    if ((self.minDate && [aDate compare:self.minDate] == NSOrderedAscending) ||
        (self.maxDate && [aDate compare:self.maxDate] == NSOrderedDescending )) {
        if ([[self.dateFor stringFromDate:aDate] isEqualToString:[self.dateFor stringFromDate:self.maxDate]]) {
            ascend = NO;
        }else{
            ascend = YES;
        }
    }
    if (self.zyCalendarView.isExChangeMap) {
        ascend = YES;
    }
    if(ascend){
        self.rightBtn.enabled=NO;
        [self.tableView removeGestureRecognizer];
    }else{
        self.rightBtn.enabled=YES;
        [self.tableView setup];
    }
    
    
    self.zyCalendarView.number  = -1;
    if( [[WSStorePlanManager sharedInstance].isChangeDic objectForKey:self.currentFuncs.fc] && self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"please_save", nil)];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            [[WSStorePlanManager sharedInstance].storePlanArr removeAllObjects];
            [[WSStorePlanManager sharedInstance].storePlanArr addObjectsFromArray:[WSStorePlanManager sharedInstance].storePlanOldArr];
            self.currentDate=aDate;
            [self downloadSelectDateData];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [self save:nil];
            self.currentDate=aDate;
        }];
        [alert show];
        
    }else{
        self.currentDate=aDate;
        [self downloadSelectDateData];
    }
    //选中的状态
    if (self.stateArray.count >0) {
        
        self.currentDateState = [[self.zyCalendarView calendarViewEventArrayForDate:self.currentDate] firstObject];
    }
}

- (void)calendarView:(ZYCalendarView *)aCanlendarView didMoveToMonth:(NSDate *)aDate{
    
  
    self.currentDate = aDate;

    
    NSMutableDictionary*willPostDic=[[NSMutableDictionary alloc] init];
    [willPostDic setObject:[self.currentDateUtil formatDate:aCanlendarView.fromDate ] forKey:@"from"];
    [willPostDic setObject:[self.currentDateUtil formatDate:aCanlendarView.toDate ] forKey:@"to"];
    [willPostDic setObject:self.monthFetchMethod forKey:@"objId"];
    
    self.timeFrom = [NSString stringWithFormat:@"%@%@",[self.currentDateUtil formatDate:aCanlendarView.fromDate],[self.currentDateUtil formatDate:aCanlendarView.toDate]];
    
    for (NSString *str in [WSStorePlanManager sharedInstance].storePlanTime) {
        if ([str isEqualToString: self.timeFrom]) {
            return;
        }
    }
    self.m_HUD.labelText = NSLocalizedString(@"refresh_prompt",nil);
    [self.m_HUD show:YES];
    
    //点击搜索按钮开始发送请求
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monthDateDone:) name:@"monthDateDone" object:nil];
    [[WSRequestHelper shareInstance] fetchStoreSchedule:willPostDic notifyName:@"monthDateDone"];
}


-(void)monthDateDone:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"monthDateDone" object:nil];
    
    
    [self.m_HUD hide:YES];
    if(![notification.object isKindOfClass:[NSError class]]){
        
        NSArray* requestData = [[[notification object] objectFromJSONString] objectForKey:self.monthFetchMethod];
        
        self.pointArray=[NSMutableArray array];
        self.stateArray =[NSMutableArray array];
        
        NSMutableArray *planDataArray = [NSMutableArray array];
        
        for(NSDictionary* dic in requestData){
            NSDate* date=[self.dateFor dateFromString:[dic objectForKey:@"doc_date"]];
            NSString *state = [NSString stringNotNilWithValue:[dic objectForKey:@"stateUrl"]];
            NSArray *planData = [dic objectForKey:@"plandata"];
            
            [planDataArray addObjectsFromArray:planData];
            
            [self.pointArray addObject:date];
            
            [self.stateArray addObject:[NSString stringWithFormat:@"stateUrl_%@",state]];
            
        }

        //塞进数据库，都从数据库查询。
        [[WSVisitStorePlanTable sharedTable] batchInsertVisitStorePlanWithStoreInfoArray:planDataArray];
        if(![WSStorePlanManager sharedInstance].storePlanTime)
        {
            [WSStorePlanManager sharedInstance].storePlanArr = [NSMutableArray arrayWithCapacity:0];
            [WSStorePlanManager sharedInstance].storePlanTime = [NSMutableArray arrayWithCapacity:0];
            [WSStorePlanManager sharedInstance].fcTime = [NSMutableDictionary dictionaryWithCapacity:0];
            [WSStorePlanManager sharedInstance].storePlanOldArr = [NSMutableArray arrayWithCapacity:0];
            [WSStorePlanManager sharedInstance].isChangeDic = [NSMutableDictionary dictionaryWithCapacity:0];

        }

        [[WSStorePlanManager sharedInstance].storePlanArr addObjectsFromArray:planDataArray];
        
        [[WSStorePlanManager sharedInstance].storePlanOldArr addObjectsFromArray:planDataArray];

        [[WSStorePlanManager sharedInstance].storePlanTime addObject:self.timeFrom];


        self.zyCalendarView.pointArray = self.pointArray;
        self.zyCalendarView.stateArray = self.stateArray;
    }
    
    [self.zyCalendarView SetDateViewDot];

    if (self.zyCalendarView.isExChangeMap) {
        [self reloadMapViewStoreAnnotationsAndPolyLine];
    }
    NSString* dateString=[self.dateFor stringFromDate:[NSDate date]];
    if (self.stateArray.count) {
        //选中的状态
        self.currentDateState = [[self.zyCalendarView calendarViewEventArrayForDate:self.currentDate] firstObject];
    }
    if(([[self.dateFor stringFromDate:self.currentDate] isEqualToString:dateString]) || self.isUploaded == YES){
        [self downloadSelectDateData];
    }else{
        [self.ownSearchBar.searchBar setShowsCancelButton:NO animated:YES];
        [self.ownSearchBar resignFirstResponder];
        if(self.ownSearchBar.searchBar.text.length>0){
            self.ownSearchBar.searchBar.text=@"";
        }
        self.filterArray = nil;
        [self sortFilterArray];
        [self resetTableHeaderView];
      
        [self.tableView reloadData];
    }
    self.isUploaded = NO;
    
}

- (void)downloadSelectDateData
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    if([WSStorePlanManager sharedInstance].storePlanArr)
    {
        for (NSDictionary *dic in [WSStorePlanManager sharedInstance].storePlanArr) {
            if ([[dic objectForKey:@"doc_date"] isEqualToString:[self.dateFor stringFromDate:self.currentDate]]) {
                WSVisitStorePlanObject *storePlan = [WSVisitStorePlanObject alloc];
                storePlan.date =    [dic objectForKey:@"doc_date"];
                storePlan.storeid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"store_id"]];
                [array addObject:storePlan];
            }
        }
    }
    else
    {
        if(self.isStoreBean){
        
            array = (NSMutableArray*)[[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[self.dateFor stringFromDate:self.currentDate]];
        }else {
            array = (NSMutableArray*)[[WSVisitPeoplePlanTable sharedTable] queryVisitPlanByDate:[self.dateFor stringFromDate:self.currentDate]];
        }
    }
    //[self.mapView reloadPolyIineWithDateofWeekStr:[self.currentDateUtil getWeekDayEnglishFromDate:self.currentDate]];
    [self updateTableWithSource:array];
}

/**
 *  更新内容，通过特定日期选中的数据内容
 *
 *  @param array 某天选中的商铺id
 */
- (void)updateTableWithSource:(NSArray*)array
{
    
    WSCallPlanSchedule *newSchedule = [[WSCallPlanSchedule alloc] init];
//    董宏 SFA-26359
    if(self.currentDate)
    {
        newSchedule.date = self.currentDate;
    }
    else if(self.currentSch)
    {
        newSchedule.date = self.currentSch.date;
    }
    newSchedule.tasks = [[NSMutableArray alloc] init];
    self.currentSch=newSchedule;
    
    self.visitedStores = [[NSMutableArray alloc]init];
    
    if(self.isStoreBean){
        
        for (WSVisitStorePlanObject *object in array) {
            for (WSStoreBean *store in self.dataArray) {
                if ([store.Id isEqualToString:object.storeid]) {
                    WSStoreBean* store_copy=[store copy];
                    store_copy.bPlanned=YES;
                    store_copy.stateUrl = object.storestateurl;
                    [newSchedule.tasks addObject:store_copy];
                    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
                        [self.visitedStores addObject:store_copy];
                    }
                }
            }
            
        }
        NSArray* storeidsArray = [array valueForKeyPath:@"@distinctUnionOfObjects.storeid"];
        for (WSStoreBean *store in self.dataArray) {
            if(![storeidsArray containsObject:store.Id]){
                WSStoreBean* store_copy=[store copy];
                store_copy.bPlanned = NO;
                [newSchedule.tasks addObject:store_copy];
            }
        }
    }else{
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"docdate==%@",[self.dateFor stringFromDate:newSchedule.date]];
        NSArray* filterArray=[array filteredArrayUsingPredicate:pre];
        
        for(WSVisitPeoplePlanObject* visitPlan in filterArray){
            
            for (WSSubempstoreBean *mics in self.dataArray) {
                WSSubempstoreBean* mics_copy=[mics copy];
                
                if([visitPlan.subempid rangeOfString:@"null"].location!=NSNotFound){
                    if([mics_copy.orgId isEqualToString:visitPlan.suborgid]){
                        mics_copy.bPlanned=YES;
                        [newSchedule.tasks addObject:mics_copy];
                        break;
                    }
                }else if([visitPlan.suborgid rangeOfString:@"null"].location!=NSNotFound){
                    if([mics_copy.Id isEqualToString:visitPlan.subempid]){
                        mics_copy.bPlanned=YES;
                        [newSchedule.tasks addObject:mics_copy];
                        break;
                    }
                }else{
                    if([mics_copy.Id isEqualToString:visitPlan.subempid] && [mics_copy.orgId isEqualToString:visitPlan.suborgid]){
                        mics_copy.bPlanned=YES;
                        [newSchedule.tasks addObject:mics_copy];
                        break;
                    }
                }
            }
        }
        
        
        for (WSSubempstoreBean *mics in self.dataArray) {
            WSSubempstoreBean* mics_copy=[mics copy];
            
            BOOL shouldAdd=YES;
            for(WSVisitPeoplePlanObject* visitPlan in filterArray){
                if([mics_copy.Id isEqualToString:visitPlan.subempid] || [mics_copy.orgId isEqualToString:visitPlan.suborgid]){
                    shouldAdd=NO;
                    break;
                }
            }
            if(shouldAdd){
                [newSchedule.tasks addObject:mics_copy];
            }
        }
    }
    
    if (array && array.count >0 && self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        
        NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"self.pid !=nil"];
        //拜访过的医生
        NSArray *subVisitedStores = [[self.visitedStores filteredArrayUsingPredicate:subPredicate ]mutableCopy];
        
        NSPredicate *parentPredicate = [NSPredicate predicateWithFormat:@"self.pid ==nil"];
        //拜访过的医院
        NSArray *parentVisitedStores = [[self.visitedStores filteredArrayUsingPredicate:parentPredicate ]mutableCopy];
        
        NSMutableDictionary *storePidDic =[[NSMutableDictionary alloc]init];
        
        for (NSObject<I_W_Cell> *parentStore in parentVisitedStores ) {
            //对应医院下的拜访过的医生
            NSMutableArray  *subStores = [[NSMutableArray alloc]init];
            for (NSObject<I_W_Cell> *subStore in subVisitedStores) {
                
                if ([[subStore getPid] isEqualToString:[parentStore getId]]) {
                    
                    
                    [subStores addObject:subStore];
                }
            }
            [subStores addObject:parentStore];
            [storePidDic setObject:subStores forKey:[parentStore getId]];
        }
        if (storePidDic.count) {
            [self.visitedStoreDict setObject:storePidDic forKey:[self.dateFor stringFromDate:newSchedule.date]];
        }
    }
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pid ==nil"];
    self.currentSch.tasks = [[self.currentSch.tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    self.filterArray = [NSMutableArray arrayWithArray:self.currentSch.tasks];
    if(!self.transitArray)
    {
        self.transitArray =  [NSMutableArray arrayWithArray:self.currentSch.tasks];
    }
    [self sortFilterArray];
    [self resetTableHeaderView];
   
    [self.tableView reloadData];
    
    if(self.ownSearchBar.searchBar.text.length>0){
        [self searchBarCancelButtonClicked:self.ownSearchBar.searchBar];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    for(UIView *cc in [searchBar subviews])
    {
        for (UIView *views in [cc subviews]) {
            if([views isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)views;
                NSString *CancelString = NSLocalizedString(@"cancel_label",nil);
                [btn setTitle:CancelString  forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
                [btn.titleLabel setFont:[UIFont systemFontOfSize:UI_Font - 2]];
                break;
            }
        }
        
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
    [self sortFilterArray];
//    [self resetTableHeaderView];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
    NSPredicate* pre=[NSPredicate predicateWithFormat:@"name contains [cd] %@ or code contains[cd] %@ or addr contains[cd] %@",searchBar.text,searchBar.text,searchBar.text];
    [self.filterArray filterUsingPredicate:pre];
    [self sortFilterArray];
//    [self resetTableHeaderView];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text.length>0){
        // SFA-25313 SFA-立白-IOS-拜访计划设置-不能按地址搜索
        self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"name contains [cd] %@ or code contains[cd] %@ or addr contains[cd] %@" ,searchBar.text,searchBar.text,searchBar.text];
        [self.filterArray filterUsingPredicate:pre];
    }else{
        self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
    }
    [self sortFilterArray];
    
    [self.tableView reloadData];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        [self downloadSelectDateData];
    }else{
        [self save:nil];
    }
}

- (void)resetStoreState:(NSArray *)stores withParentStore:(NSObject<I_W_Cell> *)parentStore{
    
    if (stores.count>0) {
        NSObject<I_W_Cell> *object = [stores firstObject];
        
        NSMutableArray *array =[NSMutableArray array];
        
        if ([parentStore isKindOfClass:[WSStoreBean class]]) {
            
            WSStoreBean *pStore =[(WSStoreBean *)parentStore copy];
            pStore.bPlanned = YES;
            
            [array addObjectsFromArray:stores];
            [array addObject:pStore];
        }
        
        if ([self.visitedStoreDict objectForKey:[self.dateFor stringFromDate:self.currentSch.date]]) {
            
            NSMutableDictionary *dict = [self.visitedStoreDict objectForKey:[self.dateFor stringFromDate:self.currentSch.date]];
            [dict setObject:array forKey:[object getPid]];
            
        }else{
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            [dict setObject:array forKey:[object getPid]];
            
            [self.visitedStoreDict setObject:dict forKey:[self.dateFor stringFromDate:self.currentSch.date]];
            
        }
        self.currentStore.bPlanned = YES;
        
    }else if (stores.count ==0){
        
        NSMutableDictionary *dict = [self.visitedStoreDict objectForKey:[self.dateFor stringFromDate:self.currentSch.date]];
        if (dict.count >0) {
            NSArray *visitedStore =[dict objectForKey:[parentStore getId]];
            if (visitedStore.count >0) {
                [dict removeObjectForKey:[parentStore getId]];
            }
        }
    }
    [self sortFilterArray];
    [self save:nil];
    
}

- (void)save:(id)sender {
    
    
    self.isUploaded = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatafinishRequest:)
                                                 name:UPDATAFINISH_NOTIFY
                                               object:nil];
    //SFA-26749 设置了拜访计划后，点上传没反应，再点一次上传，计划上传成功后多了一倍数据 （添加上传中加载框）
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"数据上传中...", nil)  tips:nil tapTarget:self action:nil];
    [[WSRequestHelper shareInstance] uploadStoreSchedule:self];
    
}


-(void)updatafinishRequest:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATAFINISH_NOTIFY object:nil];
    
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitCount) {
        [self requestVisitPuposeOfThisMonth];
    }
    //更新日历状态

    self.isUploaded = YES;
    
    //2017-12-15 SFA-15218
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:ERROR];
    if(error || [notification.object isKindOfClass:[NSError class]])
    {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"upload_failure", nil) tips:nil
                            tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        [self performSelector:@selector(refreshCalendar) withObject:nil afterDelay:0.5];
        return;
    }
    
    NSDictionary *dic = [notification.object objectFromJSONString];
    NSString *result = [dic objectForKey:@"result"];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    NSString *title=nil;
    if([result isEqualToString:@"0"]){
        NSString *message = [dic objectForKey:@"message"];
        title = message.length > 0 ? message : NSLocalizedString(@"upload_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        
      
    }else{
        title = NSLocalizedString( @"upload_success", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        [self insertVisitPlanDataByUploadSuccess];
        
        if ([WSStorePlanManager sharedInstance].storePlanArr) {
            
            [[WSStorePlanManager sharedInstance] deleteData];
            
            [self calendarView:self.zyCalendarView didMoveToMonth:self.currentDate];
        }
        //        SFA-21090 donghong 请求 接到回执报错 不需要更新 成功更新
        [self performSelector:@selector(refreshCalendar) withObject:nil afterDelay:0.5];
    }
}

- (void)insertVisitPlanDataByUploadSuccess{
    
    NSDictionary *visitedSubStoreDict =[self.visitedStoreDict objectForKey:[self.dateFor stringFromDate:self.currentSch.date]];
    
    
    if(self.isStoreBean){
        
        [[WSVisitStorePlanTable sharedTable] deletVisitStorePlanWithByDate:[self.dateFor stringFromDate:self.currentSch.date]];
        
        for(WSStoreBean* bean in self.currentSch.tasks){
            
            if(bean.bPlanned && self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore){
                NSMutableDictionary* storeInfoDic=[NSMutableDictionary dictionary];
                [storeInfoDic setObject:(bean != nil) ? bean.Id : [NSNull null] forKey:@"store_id"];
                [storeInfoDic setObject:[self.dateFor stringFromDate:self.currentSch.date] forKey:@"doc_date"];
                [[WSVisitStorePlanTable sharedTable] insertVisitStorePlanWithStoreInfoDic:storeInfoDic];
                
            }else{
                NSArray * array  =[[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[self.dateFor stringFromDate:self.currentDate] withStoreId:bean.Id];
                if (array.count >0) {
                    [[WSVisitStorePlanTable sharedTable] deletVisitStorePlanWithByDate:[self.dateFor stringFromDate:self.currentDate] withStoreId:bean.Id];
                }
                
            }
            if (visitedSubStoreDict && visitedSubStoreDict.count >0) {
                
                NSArray *visitedSubStores =[visitedSubStoreDict objectForKey:bean.Id];
                
                for (WSStoreBean *subStore in visitedSubStores) {
                    if (subStore.bPlanned) {
                        NSMutableDictionary* subStoreInfoDic=[NSMutableDictionary dictionary];
                        [subStoreInfoDic setObject:(subStore != nil) ? subStore.Id : [NSNull null] forKey:@"store_id"];
                        [subStoreInfoDic setObject:[self.dateFor stringFromDate:self.currentSch.date] forKey:@"doc_date"];
                        [[WSVisitStorePlanTable sharedTable] insertVisitStorePlanWithStoreInfoDic:subStoreInfoDic];
                    }else{
                        NSArray * array  =[[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[self.dateFor stringFromDate:self.currentDate] withStoreId:subStore.Id];
                        if (array.count >0) {
                            [[WSVisitStorePlanTable sharedTable] deletVisitStorePlanWithByDate:[self.dateFor stringFromDate:self.currentDate] withStoreId:subStore.Id];
                        }
                    }
                }
            }
        }
        if(self.currentSch.tasks.count==0){
            [self.pointArray removeObject:self.currentSch.date];
        }else{
            if(![self.pointArray containsObject:self.currentSch.date]){
                [self.pointArray addObject:self.currentSch.date];
            }
        }
    }else{
        NSMutableArray* array=[NSMutableArray array];
        for(WSSubempstoreBean* bean in self.currentSch.tasks){
            if(bean.bPlanned){
                NSMutableDictionary* dic=[NSMutableDictionary dictionary];
                [dic setObject:[self.dateFor stringFromDate:self.currentSch.date] forKey:@"docDate"];
                [dic setObject:(bean.empId != nil) ? bean.empId : [NSNull null] forKey:@"empId"];
                [dic setObject:(bean.Id != nil) ? bean.Id : [NSNull null] forKey:@"subEmpId"];
                [dic setObject:(bean.name != nil) ? bean.name : [NSNull null] forKey:@"subEmpName"];
                [dic setObject:(bean.orgId != nil) ? bean.orgId : [NSNull null] forKey:@"subOrgId"];
                [dic setObject:(bean.orgName != nil) ? bean.orgName : [NSNull null] forKey:@"subOrgName"];
                [array addObject:dic];
            }
        }
        if(array.count==0){
            [self.pointArray removeObject:self.currentSch.date];
        }else{
            if(![self.pointArray containsObject:self.currentSch.date]){
                [self.pointArray addObject:self.currentSch.date];
            }
        }
        
        [[WSVisitPeoplePlanTable sharedTable] insertVisitPlanWithArray:array withDate:[self.dateFor stringFromDate:self.currentSch.date]];
    }
    
}
- (void)refreshCalendar {
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
    [self calendarView:self.zyCalendarView didMoveToMonth:self.currentDate];
    [self downloadSelectDateData];
}

//门店列表与拜访轨迹地图相互切换
- (void)switchViews{

    [self.ownSearchBar.searchBar setShowsCancelButton:NO animated:YES];
    [self.ownSearchBar resignFirstResponder];
    if(self.ownSearchBar.searchBar.text.length>0){
        self.ownSearchBar.searchBar.text=@"";
        
    }
    
    UIView *mapView = [self.view.subviews objectAtIndex:1];
    if ([mapView isKindOfClass:[WSMapView class]]) {
        
        self.zyCalendarView.isExChangeMap = YES;
        self.rightBtn.enabled = NO;
        
        [self reloadMapViewStoreAnnotationsAndPolyLine];
        
    }else{
    
        self.zyCalendarView.isExChangeMap = NO;
        if ([self.currentDate compare:[NSDate date]] != NSOrderedDescending) {
            self.rightBtn.enabled = NO;
        }else{
            self.rightBtn.enabled = YES;
        }
    }
    
    [self.zyCalendarView SetDateViewDot];
    [UIView beginAnimations:@"animationID" context:nil];
    [UIView setAnimationDuration:1.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView  setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
    [UIView  commitAnimations];//提交动画
}

- (void)reloadMapViewStoreAnnotationsAndPolyLine{
    
    NSMutableDictionary *callPlanDict = [NSMutableDictionary dictionary];
    
    NSArray *dates= [self.currentDateUtil getDateArrayFromDate:self.zyCalendarView.fromDate to:self.zyCalendarView.toDate];
    
    BOOL isSlectedDate = NO;
    for (NSDate *aDate in dates) {
        isSlectedDate = [[self.currentDateUtil formatDate:self.currentDate] isEqualToString:[self.currentDateUtil formatDate:aDate]];
        if (isSlectedDate) {
            break;
        }
    }
    
    NSMutableDictionary * inPlanDict = [NSMutableDictionary dictionary];
    for (NSDate *aDate in dates) {
        NSArray *array= [[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[self.dateFor stringFromDate:aDate]];
        NSMutableArray *stores = [NSMutableArray arrayWithCapacity:array.count];

        NSString *key = [NSString stringWithFormat:@"%@",[self.currentDateUtil getWeekDayEnglishFromDate:aDate]];
        int i = 1;
        for (WSVisitStorePlanObject *object in array)
        {
            for (WSStoreBean *store in self.dataArray)
            {
                WSStoreBean* store_copy=[store copy];
                if ([store.Id isEqualToString:object.storeid])
                {
                    store_copy.row_number = [NSString stringWithFormat:@"%d",i];
                    store_copy.bPlanned = YES;
                    [stores addObject:store_copy];
                    [inPlanDict setObject:store_copy forKey:store_copy.Id];
                    i++ ;
                }
            }
        }
        [callPlanDict setObject:stores forKey:key];
    }

    NSArray * inPladStoreIds = [inPlanDict allKeys];

    for (WSStoreBean * store in self.dataArray) {
        if ([inPladStoreIds containsObject:store.Id]) {
            store.bPlanned = YES;
        }
    }
    
    if (self.dataArray) {
        [callPlanDict setObject:self.dataArray forKey:@"allStoreArray"];
    }
//    if(self.isStoreBean){
//        [self.mapView loadStoreAnnotationsWithCallPlanDict:(NSDictionary *)callPlanDict withDateWeekStr: (isSlectedDate ? [self.currentDateUtil getWeekDayEnglishFromDate:self.currentDate] : nil)
//                                              withIsFitMap:YES];
//    }
    
}

#pragma mark - KeyboardNotifications method
- (void)registerForKeyboardNotifications
{
    [self removeForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)removeForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}


- (void)keyboardWillShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGFloat moveHight = kbSize.height;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        moveHight = kbSize.width;
    }
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         if (INTERFACE_IS_PHONE) {
                             UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, moveHight, 0.0);
                             self.tableView.contentInset = contentInsets;
                             self.tableView.scrollIndicatorInsets = contentInsets;
                         }
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
}

#pragma mark - WSPopViewControllerDelegate
- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm
{
    
}
-(NSMutableArray *)DuplicateRemoval:(NSArray *)array{ // 数组去重
    
    NSMutableArray * storeArray =  [[NSMutableArray alloc]init];
    NSMutableArray * storeIdArray = [[NSMutableArray alloc]init];
    for (WSStoreBean * store in array) {
        if (![storeIdArray containsObject:store.Id]) {
            [storeArray addObject:store];
            [storeIdArray addObject:store.Id];
        }
    }
    return storeArray;
}

@end
