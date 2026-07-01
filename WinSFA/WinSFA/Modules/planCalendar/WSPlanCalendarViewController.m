//
//  WSPlanCalendarViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/26.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarViewController.h"
#import "YYModel.h"
#import "WSPlanCalendarTableViewHeaderView.h"
#import "WSPlanCalendarTableViewCell.h"
#import "WSCalendaView.h"
#import "NSDate+Formatter.h"
#import "WSRequestHelper.h"
#import "WSPlanCalendarDataModel.h"
#import "WSPlanRouteListViewController.h"
#import "WSPlanRouteListDataModel.h"
#import "WSAttanceViewModel.h"
#import "WSScheduleStoreView.h"

static CGFloat const kPlanCalendarCellHeight    = 40.0f;
static CGFloat const kPlanCalendarHeaderHeight  = 30.0f;
static CGFloat const kPlanScheduleHeight        = 320.0f;
static NSString * const kPlanCalendarCellId     = @"StoreRouteCellId";
static NSString * const kPlanCalendarHeaderId   = @"StoreRouteHeaderId";
static NSString * const KTABLEKQVIEWCELLID      = @"WSAttanceInfoTableViewCellID";
static NSString * const KTABLEKQVIEHEADID       = @"WSAttanceInfoTableViewHEADID";
static NSString * const ROLE                    = @"销售代表";
//==============================================================================================================================================================

#pragma mark - 计划日历视图管理器 延展(内部)
@interface WSPlanCalendarViewController () <UITableViewDelegate, UITableViewDataSource, WSCalendaViewDelegate, WSPlanCalendarTableViewCell,
WSPlanRouteListViewControllerDelegate>

@property (nonatomic, strong) WSCalendaView *infoCalendarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WSPlanCalendarDataModel *planCalendarModel;
@property (nonatomic, strong) NSMutableArray *arrPlan;
@property (nonatomic, strong) NSMutableArray *arrSchedule;
@property (nonatomic, strong) WSPlanCalendarRouteDataInfoModel *selectDataInfoModel;//选择的计划
@property (nonatomic, strong) WSAttenanceModel *attanceModel;                       //考勤状态，考勤备注，考勤审批状态
@property (nonatomic, strong) NSString *approveState;                               //旧的UI显示考勤审批状态数组
@property (nonatomic, strong) NSMutableArray *callPlanStoreList;                    //日程安排门店数组
@property (nonatomic, strong) WSAttanceViewModel *viewModel;                        //VM对象，处理数据逻辑
@property (nonatomic, assign) CGFloat calendaHight;
@property (nonatomic, assign) BOOL scrollMoth;                                      //是否选择的是月份标识
@property (nonatomic, assign) NSInteger timeCompare;                                //日期对比标识(0今天前 1今天后 2今天)
@property (nonatomic, copy) NSString *date;                                         //选择当前月标识
@property (nonatomic, copy) NSString *selectToday;                                  //选择当前天标识
@property (nonatomic, copy) NSString *role;                                         //判断角色

@end
//==============================================================================================================================================================

#pragma mark - 计划日历视图管理器
@implementation WSPlanCalendarViewController

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _date = [NSDate date].yyyyMMByLineWithDate;
    _arrPlan = [NSMutableArray arrayWithCapacity:5];
    _arrSchedule = [NSMutableArray arrayWithCapacity:5];
    _role = [WSAttanceViewModel getLoginUserRole];
    
    [self addControls];
}

#pragma mark - 重写viewDidLayoutSubviews方法
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self layoutControls];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self getNavigationItem].rightBarButtonItems = nil;
    self.uploadButton = nil;
}

#pragma mark - 获取viewModel方法
- (WSAttanceViewModel *)viewModel {
    
    if (!_viewModel) {
        _viewModel = [[WSAttanceViewModel alloc] init];
    }
    return _viewModel;
}

#pragma mark - 加载控制视图方法
- (void)addControls {
    
    _infoCalendarView = [[WSCalendaView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 7 * 4 + 70)
                                                 MultipleSel:NO NewPlan:YES];
    _infoCalendarView.delegate = self;
    [self.view addSubview:_infoCalendarView];

    UITableView *tableView = [[UITableView alloc] init];
    tableView.rowHeight = kPlanCalendarCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSPlanCalendarTableViewCell class] forCellReuseIdentifier:kPlanCalendarCellId];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KTABLEKQVIEWCELLID];
    [tableView registerClass:[WSPlanCalendarTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kPlanCalendarHeaderId];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
}

#pragma mark - 布局控制视图方法
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat calendaHight = self.calendaHight ? : [_infoCalendarView getHight];
    self.infoCalendarView.frame = CGRectMake(0, 0, viewWidth, calendaHight);
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.infoCalendarView.frame), viewWidth, viewHeight - CGRectGetMaxY(self.infoCalendarView.frame));
}

#pragma mark - 加载数据模型方法
- (void)loadModelDateStr:(NSString*)dateStr {
    
    self.timeCompare = [NSDate timeCompare:dateStr];
    self.selectToday = dateStr;

    [self.arrPlan removeAllObjects];
    [self.arrSchedule removeAllObjects];
    self.approveState = @"";
    self.attanceModel = nil;
    [self.callPlanStoreList removeAllObjects];
    
    if (self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        self.arrPlan = [self.viewModel getPlanRouteListWithTableData:self.planCalendarModel.tableData withDateStr:dateStr];
        self.arrSchedule = [self.viewModel getScheduleListWithTableData:self.planCalendarModel.tableData withDateStr:dateStr];
        self.approveState = [self.viewModel getOldRoleApproveStateWithTableData:self.planCalendarModel.tableData withDateStr:dateStr];
    }
    else {
        self.attanceModel = [self.viewModel getAttendanceStateListWithKqList:self.planCalendarModel.kqInfo withDateStr:dateStr];
        self.callPlanStoreList = [self.viewModel getDayWorkPlanListWithPlanStoreList:self.planCalendarModel.callPlanStoreList withDateStr:dateStr];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 实现numberOfSectionsInTableView:协议(返回分组数)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        
        if (self.scrollMoth) {
            return 0;
        }
        return 2;
    }
    return 1;
}

#pragma mark - 实现tableView:heightForHeaderInSection:协议(设置分组的高度)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        
        if (self.scrollMoth) {
            return 0.0f;
        }
        return kPlanCalendarHeaderHeight;
    }
   
    if (self.scrollMoth) {
        return 0.0f;
    }
    if (self.attanceModel != nil && self.callPlanStoreList.count > 0) {
        return kPlanScheduleHeight;
    }
    if (self.attanceModel != nil && self.callPlanStoreList.count == 0) {
        return 160.0f;
    }
    if (self.attanceModel == nil && self.callPlanStoreList.count > 0) {
        return kPlanScheduleHeight;
    }
    if (self.attanceModel == nil && self.callPlanStoreList.count == 0) {
        return 90.0f;
    }
    return kPlanCalendarHeaderHeight;
}

#pragma mark - 实现tableView:viewForHeaderInSection:协议(自定义分组头)
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headView;
    if (self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        
        WSPlanCalendarTableViewHeaderView *headerView = (WSPlanCalendarTableViewHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanCalendarHeaderId];
        if (section == 0) {
            
            [headerView setWithTitle:@"拜访计划/实际拜访："];
            [headerView.setAttendanceBtn setHidden:YES];
        }
        else {
            
            [headerView setWithTitle:@"考勤："];
            if ([NSDate validateWithSelectDateStr:self.selectToday]) {
                [headerView setAttendanceWithIsValidState:YES];
            }
            else {
                [headerView setAttendanceWithIsValidState:NO];
            }
            
            WSPlanCalendarDataInfoModel *kqDataModel;
            for (WSPlanCalendarDataInfoModel *dataModel in self.planCalendarModel.tableData) {
                
                if ([dataModel.day isEqualToString:self.selectToday]) {
                    
                    kqDataModel = dataModel;
                    if (dataModel.forenoon) {
                        [self.arrSchedule addObject:[NSString stringWithFormat:@"上午   %@",dataModel.forenoon]];
                    }
                    if (dataModel.afternoon) {
                        [self.arrSchedule addObject:[NSString stringWithFormat:@"下午   %@",dataModel.afternoon]];
                    }
                    if (dataModel.allday) {
                        [self.arrSchedule addObject:[NSString stringWithFormat:@"全天   %@",dataModel.allday]];
                    }
                    break;
                }
            }
            
            @weakify_self;
            [headerView setJumpAttendanceVC:^{
                @strongify_self;
                [self p_jumpKqSetingVC:kqDataModel];
            }];
        }
        headView = headerView;
    }
    else {
        
        WSScheduleStoreView *headerView = [[WSScheduleStoreView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPlanScheduleHeight)];
        headerView.selectDate = self.selectToday;
        [headerView setAttenanceModel:self.attanceModel];
        [headerView setSchedduleTaskList:self.callPlanStoreList];
        
        @weakify_self
        [headerView setAttenanceRuleBlock:^{
            @strongify_self;
            [self p_jumpKqSetingVC:self.attanceModel];
        }];
        headView = headerView;
    }

    return headView;
}

#pragma mark - 实现tableView:numberOfRowsInSection:协议(返回每组行数)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.planCalendarModel.tableData.count > 0|| [self.role isEqualToString:ROLE]) {
        
        if (self.scrollMoth) {
            return 0;
        }
        if (section == 0) {
            return self.arrPlan.count;
        }
        return self.arrSchedule.count;
    }
    return 1;
}

#pragma mark - 实现tableView:heightForRowAtIndexPath:协议(设置cell高度)
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        
        if (self.scrollMoth) {
            return 0.0f;
        }
        return kPlanCalendarCellHeight;
    }
    return 60.0f;
}

#pragma mark - 实现tableView:cellForRowAtIndexPath:协议(设置cell视图)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (self.planCalendarModel.tableData.count > 0 || [self.role isEqualToString:ROLE]) {
        
        WSPlanCalendarTableViewCell *planCalendarTable_cell = [tableView dequeueReusableCellWithIdentifier:kPlanCalendarCellId forIndexPath:indexPath];
        if(indexPath.section == 0) {
            planCalendarTable_cell.model = self.arrPlan[indexPath.row];
            planCalendarTable_cell.isBtn = self.timeCompare == 1 ? YES : NO;
        }
        else {
            planCalendarTable_cell.title = self.arrSchedule[indexPath.row];
            [planCalendarTable_cell setAttanceStateWithApproveState:self.approveState];
        }
        planCalendarTable_cell.planCalendarViewCellDelegate = self;
        cell = planCalendarTable_cell;
    }
    else {
        
        UITableViewCell *attanceInfocell = [tableView dequeueReusableCellWithIdentifier:KTABLEKQVIEWCELLID forIndexPath:indexPath];
        if (attanceInfocell == nil) {
            attanceInfocell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KTABLEKQVIEWCELLID];
        }
        cell = attanceInfocell;
    }
    
    return cell;
}

#pragma mark - 实现wsCalendaView:selDateAarray:协议(选择日期)
- (void)wsCalendaView:(WSCalendaView *)calendarView selDateAarray:(NSArray *)dateArray {
    
    if (dateArray.count > 0) {
        self.scrollMoth = NO;
        [self loadModelDateStr:[dateArray firstObject]];
    }
}

#pragma mark - 实现wsCalendaView:changeToMonth:协议(选择月份)
- (void)wsCalendaView:(WSCalendaView *)calendarView changeToMonth:(NSInteger)month {
    
    self.date = calendarView.tempDate.yyyyMMByLineWithDate;
    self.scrollMoth = YES;
    [self loadPlanCalendar];
}

#pragma mark - 实现wsCalendaView:changToSize:协议(高度变化)
- (void)wsCalendaView:(WSCalendaView *)calendarView changToSize:(CGSize)size {
    
    self.date = nil;
    [self.arrPlan removeAllObjects];
    [self.arrSchedule removeAllObjects];
    self.calendaHight = size.height;
    [self layoutControls];
}

#pragma mark - 实现btnDownViewCell:协议(拜访计划点击)
- (void)btnDownViewCell:(WSPlanCalendarRouteDataInfoModel *)model {
    
    self.selectDataInfoModel = [model yy_modelCopy];
    [self loadCalendaPlanRouteList];
}

#pragma mark - 跳转开亲页面方法
- (void)p_jumpKqSetingVC:(NSObject *)model {
    
    LogInfo(@"跳转考勤页面");
    WSFuncsBean *fb = self.currentFuncs.funcsArray.firstObject;
    if (model != nil) {
        
        if([model isKindOfClass:[WSAttenanceModel class]]){
            WSAttenanceModel * attanceModel = (WSAttenanceModel*)model;
            fb.kqArrange = [NSString stringWithFormat:@"%@,%@@#%@@#%@,%@", attanceModel.forenoon, attanceModel.afternoon, self.selectToday, ISNULL(attanceModel.forenoonMemo), ISNULL(attanceModel.afternoonMemo)];
        }
        else if([model isKindOfClass:[WSPlanCalendarDataInfoModel class]]){
            WSPlanCalendarDataInfoModel * kqDataModel = (WSPlanCalendarDataInfoModel*)model;
            fb.kqArrange = [NSString stringWithFormat:@"%@,%@@#%@@#%@,%@", kqDataModel.forenoon, kqDataModel.afternoon, self.selectToday, ISNULL(kqDataModel.forenoonMemo), ISNULL(kqDataModel.afternoonMemo)];
        }
    }
    else {
        fb.kqArrange = [NSString stringWithFormat:@"%@,%@@#%@", @"", @"", self.selectToday];
    }
    [self pushViewWithFuncsBean:fb realSubFuncsBean:nil];
}

#pragma mark - 请求加载日历计划路线列表方法
- (void)loadCalendaPlanRouteList {
    
    [self querying_messageTips];
    
    NSMutableDictionary*paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:self.selectToday forKey:@"selectDate"];
    
    NSString *notifyID = @"loadCalendaPlanRouteList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadRouteListFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 请求加载日历计划路线列表通知回调方法
- (void)uploadRouteListFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if ([dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.opt.searchTag]]) {
            
            WSPlanRouteListDataModel *routeListData = [WSPlanRouteListDataModel yy_modelWithDictionary:dic];
            routeListData.selectToday = self.selectToday;
            WSPlanRouteListViewController *routeList = [[WSPlanRouteListViewController alloc] init];
            routeList.routeListData = routeListData;
            routeList.selectDataInfoModel = self.selectDataInfoModel;
            routeList.planRouteListViewCellDelegate = self;
            routeList.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:routeList animated:YES];
        }
        else{
            [MBProgressHUD showHUDAddedTo:self.view withText:@"当前无线路！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
        
        return;
    }
        
    NSString *title = NSLocalizedString(@"refresh_failure", nil);
    [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

#pragma mark - 实现upLoadRouteCalendar协议(重载日历数据)
- (void)upLoadRouteCalendar {
    
    [self loadPlanCalendar];
}










#pragma mark - 是否个性化重定向
- (BOOL)isPersonalizationRedirect {

    return YES;
}

#pragma mark - 展示个性化重定向
- (void)executePersonalizationRedirect {
    
    [self loadPlanCalendar];
}

#pragma mark - 加载计划日历数据方法
- (void)loadPlanCalendar {
    
    [self querying_messageTips];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.ds] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:self.date forKey:@"date"];
    
    NSString *notifyID = @"CalendaPlan";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 请求加载计划日历数据通知回调方法
- (void)uploadFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        self.planCalendarModel = nil;
        self.planCalendarModel = [WSPlanCalendarDataModel yy_modelWithDictionary:[dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.ds]]];
        self.infoCalendarView.planCalendarDataModel = self.planCalendarModel;
    
        if (self.selectToday.length == 0) {
            NSString *selectToday = [NSDate date].yyyyMMddByLineWithDate;
            [self loadModelDateStr:selectToday];
        }
        else {
            [self loadModelDateStr:self.selectToday];
        }
        
        if (self.planCalendarModel.rcTx.length > 0) {
            
            [self addMainTipsWithTips:self.planCalendarModel.rcTx];
            return;
        }
        
        [self homePersonalizationFinish];
        
        return;
    }
        
    NSString *title = NSLocalizedString(@"refresh_failure", nil);
    [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    
    [self homePersonalizationFinish];
}

#pragma mark - 弹框提醒方法
- (void)addMainTipsWithTips:(NSString *)tips {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString *mainTipsKey = [NSString stringWithFormat:@"%@_%@_%@", empId, bizdate, MAIN_TIPS];
    NSString *mainTips = [[NSUserDefaults standardUserDefaults] objectForKey:mainTipsKey];
    if ([mainTips isEqualToString:@"1"]) {
        
        LogInfo(@"今天已经显示过考勤提醒弹框");
        [self homePersonalizationFinish];
        return;
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:tips];
    [alert addButtonWithTitle:@"确定" block:^{
        
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        NSString *bizdate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSString *mainTipsKey = [NSString stringWithFormat:@"%@_%@_%@", empId, bizdate, MAIN_TIPS];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:mainTipsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self homePersonalizationFinish];
    }];
    [alert show];
}

@end
//==============================================================================================================================================================
