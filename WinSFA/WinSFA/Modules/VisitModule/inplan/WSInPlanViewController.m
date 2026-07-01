//
//  InPlanViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

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

#import "WSStoreDataProcessService.h"

#define INPLAN_UPDATA_NOTIFY @"INPLAN_UPDATA_NOTIFY"
#define CELLTAG 999

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

static NSString *category;
@implementation WSInPlanViewController
@synthesize tableView = _tableView;
@synthesize currentFuncs = _currentFuncs;
@synthesize ownParentViewController = _ownParentViewController;
@synthesize PlanStoreArray = _PlanStoreArray;
@synthesize shouldAddFilters = _shouldAddFilters;
@synthesize hasVisitType = _hasVisitType;
@synthesize noTypeItems = _noTypeItems;
@synthesize visitedStoreArray = _visitedStoreArray;
@synthesize notVisitStoreArray = _notVisitStoreArray;
@synthesize currentAddStoreName = _currentAddStoreName;

+(void)setCurrentCategory:(NSString *)aCategory
{
    category = aCategory;
}

+(NSString *) currentCategory
{
    return category;
}

//modify by wangdongyan 2012-02-16
-(void)initDataArray{
    
    // 默认为 inplanstore 节点
    // 如果 filter 有参数，则为 filter 中配置的节点名称
    // (辉瑞医院)
    NSString *noteName = INPLANSTORE;
    
    // 辉瑞医院 hos 节点单独处理
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    if (projectName != nil && [projectName isEqualToString:@"pfizer"] && [self.currentFuncs.ds isEqualToString:@"hos"]) {
        noteName = @"hos";
    } else if (self.currentFuncs.filter) {
        noteName = self.currentFuncs.filter;
    }
    WSInPlanStoreBean* inPanStores = [WSAppData getObjectbyKey:noteName];
    if (category == nil)
    {
        if ([self.currentFuncs.styp isKindOfClass:[NSString class]])
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ contains[cd] self.styp", self.currentFuncs.styp];
            NSArray *array = [inPanStores.storesArray filteredArrayUsingPredicate:predicate];
            [self.PlanStoreArray addObjectsFromArray:array];
        }
        else
        {
            [self.PlanStoreArray addObjectsFromArray:inPanStores.storesArray];
        }
    }
    else
    {
        for (WSStoreBean *storebean in inPanStores.storesArray)
        {
            if ([storebean.name isKindOfClass:[NSString class]] && [storebean.styp isEqualToString:category])
            {
                [self.PlanStoreArray addObject:storebean];
            }
        }
    }
    
//    self.PlanStoreArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.PlanStoreArray]];
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
    
    for (WSStoreBean *item in self.PlanStoreArray)
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
    [self.PlanStoreArray removeAllObjects];
    [self initDataArray];
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
-(id)initWithFuncs:(WSFuncsBean*)funcs Stores:(NSArray *)stores{
    if (funcs==nil||stores==nil) {
        return nil;
    }
    self = [super init];
    if(self)
    {
        self.currentFuncs=funcs;
        self.title=funcs.name;
        _PlanStoreArray=[[NSMutableArray alloc]init];
       [_PlanStoreArray addObjectsFromArray:stores];
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
        self.currentFuncs = funcs;
        self.title = funcs.name;
        
        _PlanStoreArray=[[NSMutableArray alloc]init];
        //add by wangdongyan
        [self initDataArray];
        
        [[WCOptionalSource sharedInstance] setViewControllerParam:self byKey:self.currentFuncs.fv];
        
        return self;
    }
    return nil;
}


#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addFinished) name:newStoreNotification object:nil];

    UITableView* tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tv.backgroundColor = [UIColor whiteColor];
    tv.backgroundView = nil;
    [tv setDelegate:self];
    [tv setDataSource:self];    
    self.tableView = tv;
    tv.scrollEnabled = YES;
    [self.view addSubview:self.tableView];
    
    self.ownParentViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad
{
    [self addAddedStores];
    if (self.hasVisitType)
    {
        [self generateVisitInfoArray];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.PlanStoreArray = [NSMutableArray arrayWithArray:[self sortStoreListArrayByVisitAction:self.PlanStoreArray]];
    [self.tableView reloadData];
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
        return [self.PlanStoreArray count];
    }
    else {
        if (0 == section) {
            return [self.notVisitStoreArray count];
        } else {
            return [self.visitedStoreArray count];
        }
    }
    
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    WSSelectListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SimpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[WSSelectListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier: SimpleTableIdentifier];
        

    }
    
    id item = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        item = [self.PlanStoreArray objectAtIndex:indexPath.row];
    }
    else
    {
        if (0 == indexPath.section)
        {
            item = [_notVisitStoreArray objectAtIndex:indexPath.row];
        }
        else
        {
            item = [_visitedStoreArray objectAtIndex:indexPath.row];
        }
    }

    CGFloat contentWidth = INTERFACE_IS_PHONE ? k_TableViewContentWidth : (tableView.width - STORE_LIST_WIDTH_DIFFERENCE); //229;
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    NSString *content = nil; //item.name;
    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"])
    {
        if ([item isKindOfClass:[WSStoreBean class]])
        {
            WSStoreBean *store = (WSStoreBean *)item;
            content = store.name;
        }
    }
    else
    {
        if ([item isKindOfClass:[WSStoreBean class]])
        {
            WSStoreBean *store = (WSStoreBean *)item;
            content = [NSString stringWithFormat:@"%@",store.name];
            if (store.code && [store.code length] > 0)
            {
                content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
            }
            if (store.bfnum && [store.bfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@-%@", content, [NSString stringWithFormat:@"拜访%@",store.bfnum]];
            }
            if (store.sfnum && [store.sfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@%@%@", content, [store.bfnum length] > 0 ? @"/" : @"-",[NSString stringWithFormat:@"随访%@",store.sfnum]];
            }
            

 
   
            
        }
    }
    NSString *address = nil;//item.addr;
    if ([item isKindOfClass:[WSStoreBean class]])
    {
        WSStoreBean *store = (WSStoreBean *)item;
        address = store.addr;
    }
    
    cell.detailTextLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    if ([content isKindOfClass:[NSString class]])
    {
        CGSize size = [content ws_sizeWithFont:font constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect rect = [cell.textLabel textRectForBounds:cell.textLabel.frame limitedToNumberOfLines:0];
        rect.size = size;
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = font;
        
        cell.textLabel.frame = rect;
        
        cell.textLabel.text = content;
        if ([address isKindOfClass:[NSString class]])
        {
            cell.detailTextLabel.text = address;
        }
    }
    else
    {
        cell.textLabel.text = @"";
    }

    if ([item isKindOfClass:[WSStoreBean class]])
    {
        [self setAccessFlag:cell Store:item];
    }
//    else if ([item isKindOfClass:[WSSubempstoreBean_in class]])
//    {
//        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
//        action.parent_action_id = self.currentVisitAction.ID;
//        
//        NSString *entryid = nil;
//        if ([item isKindOfClass:[WSStoreBean class]])
//        {
//            WSStoreBean *store = (WSStoreBean *)item;
//            entryid = store.Id;
//        }
//        else if ([item isKindOfClass:[WSSubempstoreBean_in class]])
//        {
//            WSSubempstoreBean_in *beanin = (WSSubempstoreBean_in *)item;
//            entryid = beanin.Id;
//        }
//        else
//        {
//            entryid = @"";
//        }
//        action.store_id = entryid/*self.currentStore.Id*/;
//        action.func_code = self.currentFuncs.fc;
//        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
//        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
//        action.is_required = self.currentFuncs.required;
//        action.title = self.currentFuncs.name;
//        if (self.currentFuncs.iParentFuncsBean
//            && self.currentFuncs.iParentFuncsBean.fc
//            && [self.currentFuncs.iParentFuncsBean.fc length] > 0) {
//            action.module_fc = self.currentFuncs.iParentFuncsBean.fc;
//        }
//        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
//        
//        if ([status isEqualToString:ActionDone]) {
//            cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
//        } else if ([status isEqualToString:ActionWorking]) {
//            cell.imageView.image = [UIImage imageNamed:@"visit_doing.png"];
//        } else {
//            cell.imageView.image = [UIImage imageNamed:@"visit_not_start.png"];
//        }
//        cell.imageView.frame = CGRectMake(0, 0, 24, 24);
//        self.currentVisitAction = action;
//    }
    
    if ([item isKindOfClass:[WSStoreBean class]]) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
#endif
    
   CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    if ([item isKindOfClass:[WSStoreBean class]]) {
        
        WSStoreBean *store = (WSStoreBean *)item;
        if (store.plan) {
            [cell setTagFrame:cellRect andStyle:ECELLTAGStyleInPlan];
        }else{
            [cell setTagFrame:cellRect andStyle:ECELLTAGStyleOutPlan];
        }
    }
    


    return cell;
    
}

//选中Cell响应事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//选中后的反显颜色即刻消失
    
    WSStoreBean* store = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        store = [self.PlanStoreArray objectAtIndex:indexPath.row];
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
    
    if(![self anyStoreHasNotLeave:store andModuleFC:self.currentFuncs.fc])
        return;
    /*! 中粮特有
     *  是否可以重复访店，默认和 R 为可以，N 为不可以
     */
    if (self.currentFuncs.repeatvisit != nil && [self.currentFuncs.repeatvisit isEqualToString:@"N"]) {
        if ([self isVisitedStore:store]) {
            NSString *cannotRepeatVisit = NSLocalizedString(@"该店已完成今日稽核数据提报，您不能再进店查看或修改。", nil);;
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:cannotRepeatVisit tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return;
        }
    }

    self.currentStore = store;

    WSWorkFlowViewController* wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:self.currentFuncs Store:store];
    self.currentViewController = wfvc;
    //Add title
    wfvc.title = store.name;

    //设置拜访节点
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    
    NSString *entryid = nil;
    if ([store isKindOfClass:[WSStoreBean class]]) {
        entryid = store.Id;
    }else{
        entryid = @"";
    }
    
    action.store_id = entryid/*self.currentStore.Id*/;
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
    wfvc.currentVisitAction = action;
    
    //计划内随访时需要实时请求数据
    if (store.storeAccessMode == WSStoreAccessModeSubEmp) {
        [self startUpdata:store];
        return;
    }
    
    LogInfo(@"Going to class WSWorkFlowViewController");
    
    if (self.ownParentViewController==nil) {
        [self.navigationController pushViewController:wfvc animated:YES];
    }else{
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    
}

//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat contentWidth = INTERFACE_IS_PHONE ? k_TableViewContentWidth : (tableView.width - STORE_LIST_WIDTH_DIFFERENCE);//229;
    UIFont *font = [UIFont boldSystemFontOfSize:UI_Font];
    id obj = [self.PlanStoreArray objectAtIndex:indexPath.row];

    NSString *content = nil; //store.name;
    if ([self.currentFuncs.opt.isCode isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isCode isEqualToString:@"0"]) {
        if ([obj isKindOfClass:[WSStoreBean class]]) {
            WSStoreBean *store = (WSStoreBean *)obj;
            content = store.name;
        }
    } else {
        //content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
        if ([obj isKindOfClass:[WSStoreBean class]]) {
            WSStoreBean *store = (WSStoreBean *)obj;
            content = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
            if (store.bfnum && [store.bfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@-%@", content, [NSString stringWithFormat:@"拜访%@",store.bfnum]];
            }
            if (store.sfnum && [store.sfnum length] > 0) {
                content = [NSString stringWithFormat:@"%@%@%@", content, [store.bfnum length] > 0 ? @"/" : @"-",[NSString stringWithFormat:@"随访%@",store.sfnum]];
            }
            
        }
    }
    
    if (![content isKindOfClass:[NSString class]])
        return (INTERFACE_IS_PHONE ? 42.0f : 65.0f);
    CGSize size = [content ws_sizeWithFont:font constrainedToWidth:contentWidth lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + (INTERFACE_IS_PHONE ? 23.0f : 46.0f);
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
    WSStoreBean* store = nil;
    if (!self.hasVisitType || [self categoryInNoTypeItems])
    {
        store = [self.PlanStoreArray objectAtIndex:indexPath.row];
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
            
            [self.PlanStoreArray addObjectsFromArray:[self generateAddedArray]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0f)];
    return headView;
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
            [self.ownParentViewController.navigationController pushViewController:l_newStoreVC animated:YES];
        }
        else
        {
            [self.navigationController pushViewController:l_newStoreVC animated:YES];
        }
    }
}


- (NSArray *)generateAddedArray
{
    //！！问卷数据库表重构，与Android保持一致逻辑，去除WSAddStoreTable表，统一使用visit_store_acvt_data，如需存储storeID等应该在base_store表中新增一条记录，用genid关联。
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
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
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1" forKey:@"compress"];
    [dic setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [dic setObject: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME forKey:@"objId"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    //空岗时候没有empId，传@""即可
    [dic setObject:[NSString stringNotNilWithValue:store.empId] forKey:@"empId"];
    
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
        if (self.currentStore.storeAccessMode == WSStoreAccessModeSubEmp) {
            [self.currentStore reSetStore:uploadState Key: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME];
        }

        // 处理回显节点数据内容
        [WSStoreDataProcessService processStoreDisDataWithDic:uploadState objID: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME storeID:self.currentStore.Id];
        // 处理巡访提醒节点
        [WSStoreDataProcessService processStoreInfoDataWithDic:uploadState objID: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME filter:self.currentFuncs.filter];
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        if (self.ownParentViewController==nil) {
            [self.navigationController pushViewController:self.currentViewController animated:YES];
        }else{
            [self.ownParentViewController.navigationController pushViewController:self.currentViewController animated:YES];
        }
    }
    
}


@end
