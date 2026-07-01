//
//  WSPlanCalendarManageViewController.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarManageViewController.h"
#import "YYModel.h"
#import "WSPlanCalendarTableViewHeaderView.h"
#import "WSPlanCalendarTableViewCell.h"
#import "WSCalendaView.h"
#import "NSDate+Formatter.h"
#import "WSRequestHelper.h"
#import "WSPlanCalendarDataModel.h"
#import "WSPlanCalendarManageDataModel.h"
#import "WSPlanCalendarManageTableViewCell.h"
#import "WSPlanCalendarManageTableViewFooterView.h"
#import "WSCalendarFollowUpDataModel.h"
#import "WSPlanFollowUpListViewController.h"

static CGFloat const kPlanCalendarManageCellHeight = 85;
static CGFloat const kPlanCalendarManageHeaderHeight = 30;
static CGFloat const kPlanCalendarManageFooterHeight = 40;
static NSString * const kPlanCalendarManageCellId = @"PlanCalendarManageCellId";
static NSString * const kPlanCalendarManageHeaderId = @"PlanCalendarManageHeaderId";
static NSString * const kPlanCalendarManageFooterId = @"PlanCalendarManageFooterId";
static NSString * const kPlanCalendarCellId = @"PlanCalendarCellId";

@interface WSPlanCalendarManageViewController () <UITableViewDelegate, UITableViewDataSource,
WSCalendaViewDelegate, WSPlanCalendarTableViewCell, WSPlanCalendarManageTableViewFooterViewDelegate>

@property (nonatomic,strong) WSCalendaView *infoCalendarView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) WSPlanCalendarManageDataModel *planCalendarManageModel;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *selectToday;
@property (nonatomic,assign) CGFloat calendaHight;
@property (nonatomic,strong) NSMutableArray *arrLeader;
@property (nonatomic,strong) NSMutableArray *arrSales;
@property (nonatomic,strong) NSMutableArray *arrSchedule;
@property (nonatomic,assign) BOOL first;
@property (nonatomic,assign) BOOL isRefresh;
@property (nonatomic,assign) NSInteger timeCompare;
@property (nonatomic,strong) NSString *selectDS;
@property (nonatomic,strong) NSIndexPath *deleteCellIndexPath;
@property (nonatomic,strong) WSCalendarFollowUpDataModel *followUpDataListModel;
@property (nonatomic,strong) WSPlanCalendarManageDataInfoModel *currentDayModel;

@end

@implementation WSPlanCalendarManageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDate *date = [NSDate date];
    self.date = date.yyyyMMByLineWithDate;
    self.arrLeader = [NSMutableArray arrayWithCapacity:0];
    self.arrSales = [NSMutableArray arrayWithCapacity:0];
    self.arrSchedule = [NSMutableArray arrayWithCapacity:5];

    [self addControls];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self layoutControls];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.isRefresh = YES;
    [self getNavigationItem].rightBarButtonItems = nil;
    self.uploadButton = nil;
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
    
    LogInfo(@"考勤请求内容：%@",paramDic);
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

#pragma mark - 请求加载计划日历数据通知回调方法
- (void)uploadFinish:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    if (![notification.object isKindOfClass:[NSError class]]) {
 
        [self.arrLeader removeAllObjects];
        [self.arrSales removeAllObjects];
        [self.arrSchedule removeAllObjects];
        
        NSDictionary *dic = [[notification object] objectFromJSONString];
        self.planCalendarManageModel = [WSPlanCalendarManageDataModel yy_modelWithDictionary:[dic objectForKey:[NSString stringNotNilWithValue:self.currentFuncs.ds]]];
        self.infoCalendarView.planCalendarMenageDataModel = self.planCalendarManageModel;
        NSDate *date = [NSDate date];
        
        //SFASK-209  （主管）首页-弹窗提示--登录弹窗提示
        BOOL isBlock = YES;
        if (!self.first) {
            
            if (self.planCalendarManageModel.approveFlag != nil && self.planCalendarManageModel.approveFlag.length > 0) {
                
                isBlock = NO;
                
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:self.planCalendarManageModel.approveFlag];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                    [self homePersonalizationFinish];
                }];
                [alert show];
            }
        }
        
        if ([self.date isEqualToString:date.yyyyMMByLineWithDate] && !self.first) {
            
            [self loadModelDateStr:date.yyyyMMddByLineWithDate];
            self.first = YES;
            
            if (isBlock) {
                [self homePersonalizationFinish];
            }
            
            return;
        }

        if (self.isRefresh && self.selectToday) {
            
            [self.infoCalendarView resetSelectDate:self.selectToday];
            self.isRefresh = NO;
            [self loadModelDateStr:self.selectToday];
            
            if (isBlock) {
                [self homePersonalizationFinish];
            }
        
            return;
        }
        
        [self.tableView reloadData];
        
        if (isBlock) {
            [self homePersonalizationFinish];
        }
        
        return;
    }
        
    NSString *title = NSLocalizedString(@"refresh_failure", nil);
    [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    
    [self homePersonalizationFinish];
}














- (void)addControls {
    
    _infoCalendarView=[[WSCalendaView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/7*6 + 70) MultipleSel:NO NewPlan:YES];
    
    _infoCalendarView.delegate=self;
    
    [self.view addSubview:_infoCalendarView];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.rowHeight = kPlanCalendarManageCellHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[WSPlanCalendarManageTableViewCell class] forCellReuseIdentifier:kPlanCalendarManageCellId];
    [tableView registerClass:[WSPlanCalendarTableViewCell class] forCellReuseIdentifier:kPlanCalendarCellId];
    [tableView registerClass:[WSPlanCalendarTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:kPlanCalendarManageHeaderId];
    [tableView registerClass:[WSPlanCalendarManageTableViewFooterView class] forHeaderFooterViewReuseIdentifier:kPlanCalendarManageFooterId];

    [tableView  setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    self.tableView = tableView;
}
- (void)layoutControls {
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat calendaHight =  self.calendaHight ? : [_infoCalendarView getHight];//viewWidth/7.f*4.5f/5.f*6 +10;
    
    _infoCalendarView.frame = CGRectMake(0, 0,viewWidth,calendaHight);
    
    self.tableView.frame = CGRectMake(0, _infoCalendarView.frame.size.height, viewWidth, viewHeight - _infoCalendarView.frame.size.height);
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
    {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
    {
        if (section == 0) {
            return self.arrLeader.count;
        }else if (section == 1) {
            return self.arrSales.count;
        }else{
            return self.arrSchedule.count;
        }
    }else
    {
        if (section == 0) {
            return self.arrSales.count;
        }else{
            return self.arrSchedule.count;
        }
    }

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if(([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"] && indexPath.section == 2 ) ||  ([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_2"] && indexPath.section == 1 ))
    {
        WSPlanCalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlanCalendarCellId forIndexPath:indexPath];
        
        cell.title = self.arrSchedule[indexPath.row];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else
    {

        WSPlanCalendarManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPlanCalendarManageCellId forIndexPath:indexPath];
        WSPlanCalendarRouteManageDataInfoModel *manageDataInfoModel = nil;
        if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
        {
            if (indexPath.section == 0) {
                manageDataInfoModel = self.arrLeader[indexPath.row];
            }else{
                manageDataInfoModel = self.arrSales[indexPath.row];
            }
        }else
        {
            manageDataInfoModel = self.arrSales[indexPath.row];
        }
        cell.model = manageDataInfoModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    WSPlanCalendarTableViewHeaderView *headerView = (WSPlanCalendarTableViewHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanCalendarManageHeaderId];
    if (section==0) {
        [headerView setWithTitle:@"计划/实际随访代表:"];
        if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
        {
            [headerView setWithTitle:@"计划/实际随访主管:"];
        }
        headerView.setAttendanceBtn.hidden = YES;
    }else if(section == 1 ) {
        [headerView setWithTitle:@"考勤:"];
        [self updateKqStateByHeaderView:headerView];
        if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
        {   
            [headerView setWithTitle:@"计划/实际随访代表:"];
            headerView.setAttendanceBtn.hidden = YES;
        }
    }else{
        [headerView setWithTitle:@"考勤:"];
        [self updateKqStateByHeaderView:headerView];
    }
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"] && section == 2 ) ||  ([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_2"] && section == 1 )|| self.timeCompare != 1)
    {
        return nil;
    }
    WSPlanCalendarManageTableViewFooterView *footerView = (WSPlanCalendarManageTableViewFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanCalendarManageFooterId];
    footerView.strDS = @"getSrList";
    if (section==0 && [self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"]) {
        footerView.strDS = @"getLeaderList";
    }
    
    footerView.planCalendarTableViewFooterViewDelegate = self;
    return footerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
    return kPlanCalendarManageHeaderHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"] && section == 2 ) ||  ([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_2"] && section == 1 ) || self.timeCompare != 1)
    {
        return 0.0f;
    }
    return kPlanCalendarManageFooterHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"] && indexPath.section == 2 ) ||  ([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_2"] && indexPath.section == 1 ))
    {
        return 40;
    }
    NSInteger x = 0;
    if (indexPath.section == 1 )
    {
        x = 25;
    }
    if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_2"])
    {
        x = 25;
    }

    return kPlanCalendarManageCellHeight - x;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.timeCompare != 1)
    {
        return NO;
    }
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    //删除数据，和删除动画
    self.deleteCellIndexPath = indexPath;
    
    __weak typeof(self)weakSelf = self;
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"确定删除该条随访计划？", nil) message:nil];
    [alert addButtonWithTitle:@"确定" block:^{
        [weakSelf deleteCell];
    }];
    
    [alert setCancelButtonWithTitle:@"取消" block:^{
        
    }];
    [alert show];
    
//    if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
//    {
//        if (indexPath.section == 0) {
//            [self.arrLeader removeObjectAtIndex:indexPath.row];
//        }else{
//            [self.arrSales removeObjectAtIndex:indexPath.row];
//        }
//    }else
//    {
//        [self.arrSales removeObjectAtIndex:indexPath.row];
//    }
//
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationTop];
}
#pragma mark WSCalendarViewDelegate
-(void)wsCalendaView:(WSCalendaView *)calendarView selDateAarray:(NSArray *)dateArray {
    if(dateArray.count > 0)
    {
        [self loadModelDateStr:[dateArray firstObject]];
    }
}

-(void)wsCalendaView:(WSCalendaView *)calendarView changeToMonth:(NSInteger)month
{
    self.date = calendarView.tempDate.yyyyMMByLineWithDate;
    
    [self loadPlanCalendar];
}

- (void)wsCalendaView:(WSCalendaView *)calendarView changToSize:(CGSize)size {
    self.date = nil;
    self.calendaHight = size.height;
    [self layoutControls];
//    [self.arrLeader removeAllObjects];
//    [self.arrSales removeAllObjects];
//    [self.arrSchedule removeAllObjects];

}
#pragma mark WSPlanCalendarManageTableViewFooterViewDelegate
- (void)btnDownDelegate:(NSString *)strDS{
    
    if(self.timeCompare != 1)
    {
        [MBProgressHUD showHUDAddedTo:self.view withText:@"只有未来时间可以添加随访！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

        return;
    }
    self.selectDS = strDS;
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:strDS] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"pId"];
    NSString *notifyID = @"loadCalendaFollowUpList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadRouteListFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
#pragma mark WSPlanRouteListViewControllerDelegate
- (void)upLoadRouteCalendar
{
    [self loadPlanCalendar];
}

- (void)loadModelDateStr:(NSString*)dateStr
{
    self.timeCompare = [NSDate timeCompare:dateStr];
    [self.arrLeader removeAllObjects];
    [self.arrSales removeAllObjects];
    self.selectToday = dateStr;
    [self.arrSchedule removeAllObjects];
    self.currentDayModel = nil;
    for (WSPlanCalendarManageDataInfoModel *dataModel in self.planCalendarManageModel.tableData) {
        if([dataModel.day isEqualToString:dateStr]){
            self.arrLeader = [NSMutableArray arrayWithArray:dataModel.leaderList];
            self.arrSales = [NSMutableArray arrayWithArray:dataModel.salesList];
            
            if (dataModel.forenoon) {
                [self.arrSchedule addObject:[NSString stringWithFormat:@"上午   %@",dataModel.forenoon]];
            }
            if (dataModel.afternoon) {
                [self.arrSchedule addObject:[NSString stringWithFormat:@"下午   %@",dataModel.afternoon]];
            }
            if (dataModel.allday) {
                [self.arrSchedule addObject:[NSString stringWithFormat:@"全天   %@",dataModel.allday]];
            }
            self.currentDayModel = dataModel;
            
            break;
        }
    }
    [self.tableView reloadData];
}


- (void)deleteCell
{
    WSPlanCalendarRouteManageDataInfoModel *manageDataInfoModel = nil;

    if([self.currentFuncs.fv isEqualToString:@"TAB_PLAN_CALENDAR_3"])
    {
        if (self.deleteCellIndexPath.section == 0) {
           manageDataInfoModel = self.arrLeader [self.deleteCellIndexPath.row];
        }else{
           manageDataInfoModel = self.arrSales[self.deleteCellIndexPath.row];
        }
    }else
    {
           manageDataInfoModel = self.arrSales[self.deleteCellIndexPath.row];
    }
    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:@"delPlanList"] forKey:@"objId"];
    if(manageDataInfoModel.leaderId && manageDataInfoModel.leaderId.length > 0)
    {
        [paramDic setObject:[NSString stringNotNilWithValue:manageDataInfoModel.leaderId] forKey:@"leaderId"];
    }
    [paramDic setObject:[NSString stringNotNilWithValue:manageDataInfoModel.salesId] forKey:@"salesId"];
    [paramDic setObject:[NSString stringNotNilWithValue:self.selectToday] forKey:@"selectDate"];
    [paramDic setObject:[NSString stringNotNilWithValue:manageDataInfoModel.storeId] forKey:@"storeId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"delPlanList";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delPlanListFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}

-(void)uploadRouteListFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if([dic objectForKey:[NSString stringNotNilWithValue:self.selectDS]]){
          
            self.followUpDataListModel = [WSCalendarFollowUpDataModel yy_modelWithDictionary:dic];
            WSPlanFollowUpListViewController *follow = [[WSPlanFollowUpListViewController alloc] init];
            follow.followUpDataListModel = self.followUpDataListModel;
            follow.selecDate = self.selectToday;
            if ([self.selectDS  isEqualToString:@"getLeaderList"]) {
                follow.followList = [self.arrLeader mutableCopy];
            }else{
                follow.followList = [self.arrSales mutableCopy];
            }
            follow.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:follow animated:YES];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view withText:@"暂无可随访人员！" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
-(void)delPlanListFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if(dic && [dic objectForKey:@"delPlanList"] && [[dic objectForKey:@"delPlanList"] isEqualToString:@"1"]){
            self.isRefresh = YES;
            [self loadPlanCalendar];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view withText:@"删除失败 请重试" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
- (void)updateKqStateByHeaderView:(WSPlanCalendarTableViewHeaderView*)headerView{
    if ([NSDate validateWithSelectDateStr:self.selectToday]) {
        //[headerView.setAttendanceBtn setHidden:NO];
        [headerView setAttendanceWithIsValidState:YES];
    }else{
        //[headerView.setAttendanceBtn setHidden:YES];
        [headerView setAttendanceWithIsValidState:NO];
    }
    __weak __typeof(self)weakSelf = self;
    [headerView setJumpAttendanceVC:^{
        WSFuncsBean * fb = weakSelf.currentFuncs.funcsArray.firstObject;
        if (self.arrSchedule.count>0) {
            NSString * morningAttendance = @"";
            NSString * afternoonAttendance = @"";
            for (NSString * scheduleTask in self.arrSchedule) {
                if ([scheduleTask containsString:@"上午"]) {
                    morningAttendance = [[scheduleTask  componentsSeparatedByString:@" "] lastObject];
                }if ([scheduleTask containsString:@"下午"]) {
                    afternoonAttendance = [[scheduleTask  componentsSeparatedByString:@" "] lastObject];
                }
            }
            fb.kqArrange = [NSString stringWithFormat:@"%@,%@@#%@@#%@,%@", morningAttendance,afternoonAttendance,self.selectToday,self.currentDayModel.forenoonMemo,self.currentDayModel.afternoonMemo];
        }else{
            fb.kqArrange = [NSString stringWithFormat:@"%@,%@@#%@@#%@,%@",@"",@"",self.selectToday,@"",@""];
        }
        
        [weakSelf pushViewWithFuncsBean:fb realSubFuncsBean:nil];
    }];
}
@end


