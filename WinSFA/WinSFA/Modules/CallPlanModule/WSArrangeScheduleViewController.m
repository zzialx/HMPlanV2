//
//  WCArrangeScheduleViewController.m
//  WinChannelFrameWork
//
//  Created by Lei Cai on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSArrangeScheduleViewController.h"
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


#define kCalendarPadding    MAIN_CELL_PADDING
#define kCalendarViewWidth (INTERFACE_IS_PHONE ? SCREEN_WIDTH - 2 * kCalendarPadding : 330.0f)
#define kCalendarViewWeekHeight  110.0f
#define KNoteLabelFont [UIFont systemFontOfSize:12.0]



@implementation WCSchedule
@synthesize date = date_;
@synthesize tasks = tasks_;
@end


@interface WSArrangeScheduleViewController () <UISearchBarDelegate,UIAlertViewDelegate,WSPopViewControllerDelegate,WSMutiserieListViewControllerDelegate,ZYCalendarDelegate>{
    
    enCalendarViewType calendarViewType;
}

@property (nonatomic, strong) ZYCalendarView *zyCalendarView;
@property (nonatomic, strong) WSSearchBar *ownSearchBar;
@property (nonatomic, strong) NSMutableArray * filterArray;
@property (nonatomic, strong) NSDate * currentDate;

@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray *visitedStores;

@property (nonatomic,strong) MBProgressHUD* m_HUD;
@property (nonatomic, strong) NSMutableArray* pointArray;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSString* monthFetchMethod;
@property (nonatomic,strong) NSString* calendarMethod;
@property (nonatomic,strong) NSString* visitCountMethod;

@property (nonatomic,strong) UIBarButtonItem *rightBtn;

@property (nonatomic, strong)NSMutableArray *stateArray;

@property (nonatomic, strong)NSMutableArray *inplanStoreArray;

@property (nonatomic, strong) WSAcvtBean *visitPuposeAcvtBean;
@property (nonatomic, strong)WSAcvtBean_qst *visitCountQst;



@end


@implementation WSArrangeScheduleViewController
@synthesize tableView = tableView_;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stateArray =[[NSMutableArray alloc]init];
    self.dataArray = [[NSMutableArray alloc] init];
    self.inplanStoreArray = [[NSMutableArray alloc]init];
    self.calendarMethod=@"calendar";
    
    if ([self.currentFuncs.filter isEqualToString:@"storeacvtdis:visitCount"]) {
        self.visitCountMethod = @"storeacvtdis:visitCount";
        self.funcStyle = WSCallPlanTableViewCellStyleVisitCount;
        WSBaseAcvtDBService *base_acvt_db = [[WSBaseAcvtDBService alloc]init];
        self.visitPuposeAcvtBean = [base_acvt_db queryAcvtWithAcvtCode:@"mapDataToMobile"];
        self.visitCountQst = [base_acvt_db queryQstWithAcvtQstCode:@"visitcount"];
        [self requestVisitPuposeOfThisMonth];
        
    }
    
    self.visitedStoreDict = [[NSMutableDictionary alloc]init];
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){
        
        WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
        self.dataArray = [baseStoreDBService queryStoreWithSearchObjId:@"stores" styp:self.currentFuncs.styp];
        
        
    }else{
        
        WSSubempstoreBeanArray* array= [WSAppData getObjectbyKey:SUBEMPSTORES];
        [self.dataArray addObjectsFromArray:array.subempstoreArray];
        
    }

    
    if(INTERFACE_IS_PAD)
    {
        calendarViewType = en_calendar_type_month;
        
        [self.view removeAllSubviews];
        
        CGFloat calendarViewHeight = [self getCalendarMonthHeight];
        ZYCalendarView *calendarView = [[ZYCalendarView alloc]initWithFrame:CGRectMake(kCalendarPadding, 23, kCalendarViewWidth, calendarViewHeight) CalendarType:en_calendar_type_month withPageNumber:11 withWeekStartDay:self.currentFuncs.value];
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
        [self.view addSubview:self.tableView];
        self.tableView.tableHeaderView = [self generateSearchView];

         NSString *noteStr = [NSString stringWithFormat:NSLocalizedString(@"callplanhint", nil)];
        CGSize labelsize = [noteStr ws_sizeWithFont:KNoteLabelFont constrainedToWidth:300 lineBreakMode:NSLineBreakByCharWrapping];
        
        UILabel* noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(kCalendarPadding, CGRectGetMaxY(calendarView.frame) + MAIN_PADDING , kCalendarViewWidth, labelsize.height)];
        noteLabel.text = noteStr;
        noteLabel.font= KNoteLabelFont;
        noteLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [noteLabel setNumberOfLines:0];
        noteLabel.autoresizingMask= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:noteLabel];
        
        
        self.navigationItem.hidesBackButton = YES;
        
        self.m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.m_HUD];
        
        
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
        
        UIView *searchView = [self generateSearchView];
        UIView *headerTView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, calendarViewHeight + CGRectGetHeight(searchView.frame) + 40)];
        [headerTView setBackgroundColor:[UIColor clearColor]];
        
        ZYCalendarView *calendarView = [[ZYCalendarView alloc]initWithFrame:CGRectMake(kCalendarPadding, 0, kCalendarViewWidth, calendarViewHeight) CalendarType:calendarViewType withPageNumber:11 withWeekStartDay:self.currentFuncs.value];
        self.zyCalendarView = calendarView;
        self.zyCalendarView.delegate = self;
        [self.zyCalendarView setBackgroundColor:[UIColor whiteColor]];
        [headerTView addSubview:self.zyCalendarView];
        
        
        UIView* lineView=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(calendarView.frame) + 5, self.view.width, 1)];
        lineView.backgroundColor= [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
        [headerTView addSubview:lineView];
        
        NSString *noteStr = [NSString stringWithFormat:NSLocalizedString(@"callplanhint", nil)];
        
        CGSize labelsize = [noteStr ws_sizeWithFont:KNoteLabelFont constrainedToWidth:300 lineBreakMode:NSLineBreakByCharWrapping];

        UILabel* noteLabel=[[UILabel alloc] initWithFrame:CGRectMake(kCalendarPadding, CGRectGetMaxY(calendarView.frame) + 10, kCalendarViewWidth, labelsize.height)];
        noteLabel.text = noteStr;
        noteLabel.font= KNoteLabelFont;
        [noteLabel setNumberOfLines:0];
        noteLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [headerTView addSubview:noteLabel];
        
        if (searchView) {
            [searchView setFrame:CGRectMake(0, CGRectGetMaxY(noteLabel.frame), self.view.width, 44)];
            [headerTView addSubview:searchView];
        }

        self.tableView = [[FMMoveTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:self.tableView];
        self.tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self.tableView setTableHeaderView:headerTView];
        
        self.m_HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.m_HUD];
        
    }
    
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"] ){
        
        self.method=@"callPlan";
        self.monthFetchMethod=@"callpladaynnum";
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
    
    NSDateFormatter* datefor = [NSDateFormatter standardDateFormatter];
    [datefor setDateFormat:@"yyyy-MM-dd"];
    NSString* dateString=[datefor stringFromDate:[NSDate date]];
    self.currentDate=[datefor dateFromString:dateString];
    
    [self calendarView:self.zyCalendarView didMoveToMonth:nil];
    [self registerForKeyboardNotifications];
}

- (void)addToolBar {
    if(INTERFACE_IS_PAD) {
        self.rightBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save_label", nil)  style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
        self.ownParentViewController.navigationItem.rightBarButtonItem = self.rightBtn;
        [self.ownParentViewController.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:UI_Font],NSFontAttributeName, nil] forState:UIControlStateNormal];
        if (!self.currentFuncs.opt.isTodayVisit) {
            self.rightBtn.enabled = NO;
        }
    } else {
        self.rightBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save_label", nil) style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
        self.ownParentViewController.navigationItem.rightBarButtonItem = self.rightBtn;
        [self.ownParentViewController.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:UI_Font],NSFontAttributeName, nil] forState:UIControlStateNormal];
        
        if (!self.currentFuncs.opt.isTodayVisit) {
            self.rightBtn.enabled = NO;
        }
    }
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
    
     //更新列表
    
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){
        
        [self loadNewAndOutPlanStore];

    }

    [self addToolBar];
   
}

- (BOOL)shouldPauseBackAction {
    return YES;
}

- (void)backAction {
    
    if(self.currentSch.changed){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"please_save", nil)];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
            [self backToParent];
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            [self save:nil];
            [self backToParent];
        }];
        [alert show];
        
    }else {
        [self backToParent];
    }
}

//友宝新增，新增客户要在拜访计划设置里面显示
- (void)loadNewAndOutPlanStore{
    NSArray *newStoreArray =[self gainImmediatelyVisitStoreList];
    
    if (newStoreArray && [newStoreArray count]> 0) {

            [self.dataArray addObjectsFromArray:newStoreArray];
    }
}

- (NSArray *)gainImmediatelyVisitStoreList{
    NSMutableArray *array =[[NSMutableArray alloc]init];
    
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
//    NSArray *newStoreArray =[[WSAddStoreTable sharedTable]queryImmediatelyVistStore];
//    
//    if (newStoreArray) {
//    for (WSAddStoreObject *object in newStoreArray) {
//            NSString *storeid = object.store_id;
//            if (storeid && storeid.length >0 ) {
//                BOOL isExist = NO;
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
//                    WSStoreBean *item = [[WSStoreBean alloc]init];
//                    item.styp = object.store_type;
//                    item.sv = @"";
//                    item.name = object.store_name;
//                    item.Id = storeid;
//                    item.code = object.store_code;
//                    [array addObject:item];
//                }
//            }
//            
//        }
  
    if (!array) {
        return nil;
    }
    
    return [NSArray arrayWithArray:array];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filterArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return INTERFACE_IS_PAD ? 60:50;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WSCallPlanTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[WSCallPlanTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withFuncStyle:self.funcStyle];
        cell.delegate = self;
    }

    NSObject<I_W_Cell> *storeBean = [self.filterArray objectAtIndex:indexPath.row];
    [cell setSb:storeBean];
    NSString *seialNumberStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    
    if ([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]) {
        WSStoreBean *sb = (WSStoreBean *)storeBean;
        [cell.selectedNoteButton setSelected:sb.bPlanned];
        if (sb.bPlanned == YES) {
            cell.serialNumberlabel.text = seialNumberStr;
        }
    }else{
        WSSubempstoreBean *sb = (WSSubempstoreBean *)storeBean;
        [cell.selectedNoteButton setSelected:sb.bPlanned];
        if (sb.bPlanned == YES) {
            cell.serialNumberlabel.text = seialNumberStr;
        }
    }
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
        NSArray *visitSubStoreS = [self getVisitedSubStoreWithPid:[storeBean getId]];
        if (visitSubStoreS.count > 0) {
            cell.visitSubStoresLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)visitSubStoreS.count];
            cell.serialNumberlabel.text = seialNumberStr;
        }
    }else if (self.funcStyle == WSCallPlanTableViewCellStyleVisitCount){
        WSBaseAcvtdisDBService *acvtdisService = [[WSBaseAcvtdisDBService alloc]init];
        WSBaseStoreAcvtDisObject *object = [[acvtdisService queryStoreAcvtDisBeanArrayWithStoreID:[storeBean getId] acvtQstID:self.visitCountQst.acvtQstId noteName:self.visitCountMethod] firstObject];
        if (object.acvt_qst_answer.length >0) {
            cell.storeVisitCountLabel.text =  [NSString stringWithFormat:@"已拜访%@次",object.acvt_qst_answer];
        }else{
            cell.storeVisitCountLabel.text =  [NSString stringWithFormat:@"已拜访0次"];
        }
    }
    return cell;
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

- (void)didSelectedWithStoreCode:(NSString *)storeCode{
    
    BOOL beforeToday=NO;
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if([[dateFormat stringFromDate:self.currentSch.date] isEqualToString:[dateFormat stringFromDate:[NSDate date]]] ){
        if (self.currentFuncs.opt.isTodayVisit) {
            beforeToday = NO;
        }else{
            beforeToday=YES;
        }
        
    }else if ([self.currentSch.date compare:[NSDate date]] == NSOrderedAscending){
        beforeToday = YES;
    }
    
    if(beforeToday){
        NSString *title = NSLocalizedString(@"call_plan_setting_date_error_lable", nil);
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
    if ([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]) {
        WSStoreBean *sb = (WSStoreBean *)storeBean;
        if (self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore) {
            sb.bPlanned = !sb.bPlanned;
        }
        self.currentStore = sb;
        
    }else{
        
        WSSubempstoreBean *sb =(WSSubempstoreBean *)storeBean;
        sb.bPlanned = !sb.bPlanned;
    }
    [self sortFilterArray];
    [self.tableView reloadData];
}

- (void)pushViewControllerWithSlectStore:(NSObject<I_W_Cell> *)aStore{
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    WSMutiserieListViewController *vc = [[WSMutiserieListViewController alloc]initWithStore:(WSStoreBean *)aStore withCurrentDate:[dateFormat stringFromDate:self.currentDate] withFilter:self.currentFuncs.filter];
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
    
    WSCallPlanTableViewCell *fromCell = [tableView cellForRowAtIndexPath:fromIndexPath];
    WSCallPlanTableViewCell *toCell = [tableView cellForRowAtIndexPath:toIndexPath];
    
    NSString *tempValue = toCell.serialNumberlabel.text;
    toCell.serialNumberlabel.text = fromCell.serialNumberlabel.text;
    fromCell.serialNumberlabel.text = tempValue;
    
    
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){

        WSStoreBean *sb_fromIndexPath = [self.filterArray objectAtIndex:fromIndexPath.row];
        WSStoreBean *sb_toIndexPath = [self.filterArray objectAtIndex:toIndexPath.row];
        NSUInteger fromIndex=[self.currentSch.tasks indexOfObject:sb_fromIndexPath];
        NSUInteger toIndex=[self.currentSch.tasks indexOfObject:sb_toIndexPath];
        [self.currentSch.tasks exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];

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
    NSPredicate* preSelected = [NSPredicate predicateWithFormat:@"bPlanned == 1"];
    NSArray* arraySelected = [self.filterArray filteredArrayUsingPredicate:preSelected];
    NSPredicate* preUnSelected = [NSPredicate predicateWithFormat:@"bPlanned == 0"];
    NSArray* arrayUnSelected = [self.filterArray filteredArrayUsingPredicate:preUnSelected];
    [self.filterArray removeAllObjects];
    [self.filterArray addObjectsFromArray:arraySelected];
    [self.filterArray addObjectsFromArray:arrayUnSelected];
    
    arraySelected = [self.currentSch.tasks filteredArrayUsingPredicate:preSelected];
    arrayUnSelected = [self.currentSch.tasks filteredArrayUsingPredicate:preUnSelected];
    [self.currentSch.tasks removeAllObjects];
    [self.currentSch.tasks addObjectsFromArray:arraySelected];
    [self.currentSch.tasks addObjectsFromArray:arrayUnSelected];
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
- (void)calendarView:(ZYCalendarView *)aCalendarView didSelecteDate:(NSDate *)aDate{
    
        BOOL ascend=NO;
        NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
        if([[dateFormat stringFromDate:aDate] isEqualToString:[dateFormat stringFromDate:[NSDate date]]] ){
            if (self.currentFuncs.opt.isTodayVisit) {
                ascend = NO;
            }else{
                ascend= YES;
    
            }
    
        }else if([aDate compare:[NSDate date]] == NSOrderedAscending){
          ascend = YES;
        }
    
        if(ascend){
            self.rightBtn.enabled=NO;
            [self.tableView removeGestureRecognizer];
        }else{
            self.rightBtn.enabled=YES;
            [self.tableView setup];
        }
    
        self.currentDate=aDate;
        //选中的状态
        if (self.stateArray.count >0) {
    
            self.currentDateState = [[self.zyCalendarView calendarViewEventArrayForDate:self.currentDate] firstObject];
        }
    if(self.currentSch.changed && self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore){
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"please_save", nil)];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
                [self downloadSelectDateData];
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                [self save:nil];
            }];
            [alert show];
            
        }else{
            [self downloadSelectDateData];
        }
}

- (void)calendarView:(ZYCalendarView *)aCanlendarView didMoveToMonth:(NSDate *)aDate{
    
    self.m_HUD.labelText = NSLocalizedString(@"please_wait",nil);
    [self.m_HUD show:YES];
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM"];
    
    
    if (aDate != nil) {
        self.currentDate = aDate;
    }
    DateUtil  *dateutil = [[DateUtil alloc] init];
    
    NSMutableDictionary*willPostDic=[[NSMutableDictionary alloc] init];
    if (calendarViewType == en_calendar_type_week) {
         [willPostDic setObject:[dateutil formatDate:aCanlendarView.fromDate ] forKey:@"from"];
         [willPostDic setObject:[dateutil formatDate:aCanlendarView.toDate ] forKey:@"to"];
    }else{
        [willPostDic setObject:[dateFormat stringFromDate:aCanlendarView.currentDate] forKey:@"month"];
    }

    [willPostDic setObject:self.monthFetchMethod forKey:@"objId"];
    
    //点击搜索按钮开始发送请求
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monthDateDone:) name:@"monthDateDone" object:nil];
    [[WSRequestHelper shareInstance] fetchStoreSchedule:willPostDic notifyName:@"monthDateDone"];
}


-(void)monthDateDone:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"monthDateDone" object:nil];
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if(![notification.object isKindOfClass:[NSError class]]){
        
        NSArray* requestData=[[[notification object] objectFromJSONString] objectForKey:self.monthFetchMethod];
        
        self.pointArray=[NSMutableArray array];
        self.stateArray =[NSMutableArray array];
        self.inplanStoreArray = [NSMutableArray array];
        
        for(NSDictionary* dic in requestData){
            NSDate* date=[dateFormat dateFromString:[dic objectForKey:@"doc_date"]];
            NSString *state = [NSString stringWithValue:[dic objectForKey:@"state"]];
            NSString *count = [NSString stringWithValue:[dic objectForKey:@"count"]];
            [self.pointArray addObject:date];
            if (state && state.length >0) {
                [self.stateArray addObject:[NSString stringWithFormat:@"state_%@",state]];

            }
            if (count && count.length >0) {
                [self.inplanStoreArray addObject:[NSString stringWithFormat:@"count_%@",count]];
               
            }
            
        }
        
        self.zyCalendarView.pointArray = self.pointArray;
        self.zyCalendarView.stateArray = self.stateArray;
        self.zyCalendarView.inplanStoreArray = self.inplanStoreArray;

    }
    [self.zyCalendarView SetDateViewDot];
    
    DateUtil  *dateutil = [[DateUtil alloc] init];
    
    NSMutableDictionary* calendarPostDic=[[NSMutableDictionary alloc] init];
    
    [dateFormat setDateFormat:@"yyyy"];
    [calendarPostDic setObject:[dateFormat stringFromDate:self.zyCalendarView.currentDate] forKey:@"year"];
    if (calendarViewType == en_calendar_type_week) {
        [calendarPostDic setObject:[dateutil formatDate:self.zyCalendarView.fromDate ] forKey:@"from"];
        [calendarPostDic setObject:[dateutil formatDate:self.zyCalendarView.toDate ] forKey:@"to"];
    }else{
        [dateFormat setDateFormat:@"MM"];
        [calendarPostDic setObject:[dateFormat stringFromDate:self.zyCalendarView.currentDate] forKey:@"month"];
    }
    [calendarPostDic setObject:self.calendarMethod forKey:@"objId"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calendarDateDone:) name:@"calendarDateDone" object:nil];
    [[WSRequestHelper shareInstance] fetchCalendarDateDone:calendarPostDic notifyName:@"calendarDateDone"];
}

-(void)calendarDateDone:(NSNotification*)notification
{
    [self.m_HUD hide:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"calendarDateDone" object:nil];
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if(![notification.object isKindOfClass:[NSError class]]){
        
        NSArray* requestData=[[[notification object] objectFromJSONString] objectForKey:self.calendarMethod];
        
        NSMutableArray* array=[NSMutableArray array];
        for(NSDictionary* dic in requestData){
            NSString* dateString=[dic objectForKey:@"doc_date"];
            NSDate* date=[dateFormat dateFromString:dateString];
            [array addObject:date];
        }
        if(array.count>0){
            [self.zyCalendarView reloadViewWithArray:array];
        }
    }
    

    NSString* dateString=[dateFormat stringFromDate:[NSDate date]];
    if (self.stateArray.count) {
        //选中的状态
        self.currentDateState = [[self.zyCalendarView calendarViewEventArrayForDate:self.currentDate] firstObject];
    }
    if([[dateFormat stringFromDate:self.currentDate] isEqualToString:dateString]){
        [self downloadSelectDateData];
    }

}

- (void)downloadSelectDateData
{
    self.m_HUD.labelText = NSLocalizedString(@"please_wait",nil);
    [self.m_HUD show:YES];
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSMutableDictionary*willPostDic=[[NSMutableDictionary alloc]init];
    
    [willPostDic setObject:[dateFormat stringFromDate:self.currentDate] forKey:@"docDate"];
    [willPostDic setObject:self.method forKey:@"objId"];
    
    //点击搜索按钮开始发送请求
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(requestHaveBeenDone:) name:@"roadManagerRequest" object:nil];
    [[WSRequestHelper shareInstance] postRequestOnRoadsManager:willPostDic notifyName:@"roadManagerRequest"];
}

//请求完数据后 该方法将被调用
-(void)requestHaveBeenDone:(NSNotification*)notification{
    
    [self.m_HUD hide:YES];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"roadManagerRequest" object:nil];
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary* requestData=[[notification object] objectFromJSONString];
        NSArray* array=[requestData objectForKey:self.method];
        //array为nil，没考虑
        
        if(array && array.count>0){
            
            if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"] ){

                NSString* storeids=[NSString string];
                for(NSDictionary* dic in array){
                    storeids=[storeids stringByAppendingFormat:@"%@,",[NSString stringWithValue:[dic valueForKey:@"id"]]];
                }
                storeids =[storeids substringToIndex:storeids.length-1];
                
                NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
                [dic setObject:storeids forKey:@"storeids"];
                [dic setObject:[dateFormat stringFromDate:self.currentDate] forKey:@"date"];
                
                //塞进数据库，都从数据库查询。
                [[WSVisitStorePlanTable sharedTable] insertVisitStorePlanWithDic:dic];
                
            }else{
                
                //塞进数据库，都从数据库查询。
                [[WSVisitPeoplePlanTable sharedTable] insertVisitPlanWithArray:array withDate:[dateFormat stringFromDate:self.currentDate]];
            }
        }else{
            if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){
                
                NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
                [dic setObject:@"" forKey:@"storeids"];
                [dic setObject:[dateFormat stringFromDate:self.currentDate] forKey:@"date"];
                //塞进数据库，都从数据库查询。
                [[WSVisitStorePlanTable sharedTable] insertVisitStorePlanWithDic:dic];
                
            }else{
                //塞进数据库，都从数据库查询。
                [[WSVisitPeoplePlanTable sharedTable] insertVisitPlanWithArray:[NSArray array] withDate:[dateFormat stringFromDate:self.currentDate]];
            }
        }
    }
    
    NSArray* array = nil;
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){

        array= [[WSVisitStorePlanTable sharedTable] queryVisitStorePlanByDate:[dateFormat stringFromDate:self.currentDate]];
        NSArray* storeidsArray=[NSArray array];
        if(array && array.count>0){
            storeidsArray=[[[array objectAtIndex:0] storeids] componentsSeparatedByString:@","];
            array = storeidsArray;
        }
    }else {
        array= [[WSVisitPeoplePlanTable sharedTable] queryVisitPlanByDate:[dateFormat stringFromDate:self.currentDate]];
    }
    [self updateTableWithSource:array];
}

/**
 *  更新内容，通过特定日期选中的数据内容
 *
 *  @param array 某天选中的商铺id
 */
- (void)updateTableWithSource:(NSArray*)array
{
    
    NSDateFormatter* dateFor = [NSDateFormatter standardDateFormatter];
    [dateFor setDateFormat:@"yyyy-MM-dd"];
    
    WCSchedule *newSchedule = [[WCSchedule alloc] init];
    newSchedule.date = self.currentDate;
    newSchedule.tasks = [[NSMutableArray alloc] init];
    self.currentSch=newSchedule;
    
    self.visitedStores = [[NSMutableArray alloc]init];
    
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){

        NSArray* storeidsArray=array;
        for(NSString* storeid in storeidsArray){
            for (WSStoreBean *store in self.dataArray) {
                if([store.Id isEqualToString:storeid]){
                    WSStoreBean* store_copy=[store copy];
                    store_copy.bPlanned=YES;

                    [newSchedule.tasks addObject:store_copy];
                    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore) {
                         [self.visitedStores addObject:store_copy];
                    }
                   
                }
            }
        }
        
        for (WSStoreBean *store in self.dataArray) {
            if(![storeidsArray containsObject:store.Id]){
                WSStoreBean* store_copy=[store copy];
                [newSchedule.tasks addObject:store_copy];
            }
        }
        
    }else{
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"docdate==%@",[dateFor stringFromDate:newSchedule.date]];
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
            [self.visitedStoreDict setObject:storePidDic forKey:[dateFor stringFromDate:newSchedule.date]];
        }
    }

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.pid ==nil"];
    self.currentSch.tasks = [[self.currentSch.tasks filteredArrayUsingPredicate:predicate] mutableCopy];
    self.filterArray = [NSMutableArray arrayWithArray:self.currentSch.tasks];
    
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

    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
    NSPredicate* pre=[NSPredicate predicateWithFormat:@"name contains [cd] %@",searchBar.text];
    [self.filterArray filterUsingPredicate:pre];
    [self sortFilterArray];

    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchBar.text.length>0){
        self.filterArray=[NSMutableArray arrayWithArray:self.currentSch.tasks];
        NSPredicate* pre=[NSPredicate predicateWithFormat:@"name contains [cd] %@",searchBar.text];
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
    
   NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
   [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    if (stores.count>0) {
        NSObject<I_W_Cell> *object = [stores firstObject];
        
        NSMutableArray *array =[NSMutableArray array];
        
        if ([parentStore isKindOfClass:[WSStoreBean class]]) {
            
            WSStoreBean *pStore =[(WSStoreBean *)parentStore copy];
            pStore.bPlanned = YES;
            
            [array addObjectsFromArray:stores];
            [array addObject:pStore];
        }

        if ([self.visitedStoreDict objectForKey:[dateFormat stringFromDate:self.currentSch.date]]) {
            
            NSMutableDictionary *dict = [self.visitedStoreDict objectForKey:[dateFormat stringFromDate:self.currentSch.date]];
            [dict setObject:array forKey:[object getPid]];
            
        }else{
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            [dict setObject:array forKey:[object getPid]];
            
            [self.visitedStoreDict setObject:dict forKey:[dateFormat stringFromDate:self.currentSch.date]];
            
        }
        self.currentStore.bPlanned = YES;

    }else if (stores.count ==0){
        
        NSMutableDictionary *dict = [self.visitedStoreDict objectForKey:[dateFormat stringFromDate:self.currentSch.date]];
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
    
//    NSString *title = NSLocalizedString(@"数据进入上传队列", nil);
//    
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    
    NSDateFormatter *dateFormat = [NSDateFormatter standardDateFormatter];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    
    NSDictionary *visitedSubStoreDict =[self.visitedStoreDict objectForKey:[dateFormat stringFromDate:self.currentSch.date]];
    
    if([self.currentFuncs.ds isEqualToString:STORE] || [self.currentFuncs.ds isEqualToString:@"stores"]){

        
        
        NSMutableDictionary* dic=[NSMutableDictionary dictionary];
        NSString* storeids=[NSString string];
        NSMutableArray *callplanstores = [[NSMutableArray alloc] init];
        
        for(WSStoreBean* bean in self.currentSch.tasks){
            if(bean.bPlanned && self.funcStyle != WSCallPlanTableViewCellStyleVisitSubempStore){
                storeids=[storeids stringByAppendingFormat:@"%@,",bean.Id];
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:bean.Id, @"store_id", nil];
                [callplanstores addObject:dic];
            }
            if (visitedSubStoreDict && visitedSubStoreDict.count >0) {
                
                NSArray *visitedSubStores =[visitedSubStoreDict objectForKey:bean.Id];
                
                for (WSStoreBean *subStore in visitedSubStores) {
                    if (subStore.bPlanned) {
                        storeids=[storeids stringByAppendingFormat:@"%@,",subStore.Id];
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:subStore.Id, @"store_id", nil];
                        [callplanstores addObject:dic];
                    }
                }
            }
        }
        
        [dic setObject:(storeids != nil) ? storeids : [NSNull null] forKey:@"storeids"];
        [dic setObject:[dateFormat stringFromDate:self.currentSch.date] forKey:@"date"];
        [dic setObject:callplanstores forKey:@"callplanstores"];
        
        if(storeids.length==0){
            [self.pointArray removeObject:self.currentSch.date];
        }else{
            if(![self.pointArray containsObject:self.currentSch.date]){
                [self.pointArray addObject:self.currentSch.date];
            }
        }
        
        [[WSVisitStorePlanTable sharedTable] insertVisitStorePlanWithDic:dic];
        
    }else{
        NSMutableArray* array=[NSMutableArray array];
        for(WSSubempstoreBean* bean in self.currentSch.tasks){
            if(bean.bPlanned){
                NSMutableDictionary* dic=[NSMutableDictionary dictionary];
                [dic setObject:[dateFormat stringFromDate:self.currentSch.date] forKey:@"docDate"];
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
        
        [[WSVisitPeoplePlanTable sharedTable] insertVisitPlanWithArray:array withDate:[dateFormat stringFromDate:self.currentSch.date]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatafinishRequest:)
                                                 name:UPDATAFINISH_NOTIFY
                                               object:nil];
    [[WSRequestHelper shareInstance] uploadStoreSchedule:self];
    
}


-(void)updatafinishRequest:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATAFINISH_NOTIFY object:nil];
    
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitCount) {
         [self requestVisitPuposeOfThisMonth];
    }
    //更新日历状态
    if (self.funcStyle == WSCallPlanTableViewCellStyleVisitSubempStore
        || self.funcStyle == WSCallPlanTableViewCellStyleVisitCount) {
        [self calendarView:self.zyCalendarView didMoveToMonth:nil];
    }
    [self downloadSelectDateData];

    NSString *title=nil;
    
    NSDictionary *dic = [notification.object objectFromJSONString];
    NSString *result = [dic objectForKey:@"result"];
    
    if([result isEqualToString:@"0"]){
        title = NSLocalizedString(@"upload_failure", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }else{
        title = NSLocalizedString( @"upload_success", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    }
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

@end
