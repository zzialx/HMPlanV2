//
//  AcvtListViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtListViewController.h"
#import "WSAcvtBean.h"
#import "WSAcvtViewController.h"
#import "WSAppData.h"
#import "WSVisitStoreActionTable.h"
//#import "WSMarketActivityForAcvt.h"
#import "WSBusiAcvtBeanArray.h"
#import "UIDevice+Addtional.h"
#import "WSAcvtListFlagArray.h"
//#import "WSNavigationBar.h"
//#import "WSEnvrionment.h"
#import "WSBaseAcvtDBService.h"
#import "WCPopListView.h"
#import "WSVisitStoreAcvtTable.h"
#import "WSAcvtListTableViewCell.h"
#import "SuperBarViewController.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAcvtQstDisItem.h"
#import "WSAcvtQuestionAnswerBean.h"
#import "WSRequestTools.h"

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 210 : (210 * UI_XFactor))

@interface WSAcvtListViewController () <WCPopListViewDelegate>

@property (nonatomic, strong) NSArray *notInStoreAcvtArray;
@property (nonatomic, strong) NSArray *addedToStoreAcvtArray;
@property (nonatomic, strong) NSArray *allAcvtArray;
@property (nonatomic, strong) WSEmptyView *emptyView;
@property (nonatomic , assign) BOOL isFirstLoaded;
@property (nonatomic, strong) NSArray *acvtUploadTimeArray;

@end

@implementation WSAcvtListViewController
@synthesize m_currentStore = _m_currentStore;
@synthesize m_currentFuncs = _m_currentFuncs;
@synthesize m_currentAcvtArray = _m_currentAcvtArray;
@synthesize m_ParentViewController = _m_ParentViewController;
@synthesize m_SubempstoreBean = _m_SubempstoreBean;


-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    // SFA-22331 后台会下发调查问卷信息，没有菜单 所以去掉空判断
    if(!funcs) {
        LogError(@"菜单为空，可能是个错误");
//        return nil;
    }
    self = [super initWithFuncs:funcs];
    if(self != nil)
    {
        _m_currentFuncs = funcs;
        self.showActionTip = YES;
        return self;
    }
    return nil;
}

-(id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)aStore 
{
    if(funcs == nil || aStore == nil)
        return nil;
    
    self = [super initWithFuncs:funcs Store:aStore];
    if(self != nil)
    {
        _m_currentFuncs = funcs;
        _m_currentStore = aStore;
        self.showActionTip = YES;
        return self;
    }
    return nil;
}

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)aStore hosBean:(WSHosBean*)hosBean {
    if(funcs == nil || aStore == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        _m_currentFuncs = funcs;
        
        _m_currentStore = aStore;
        
        _hosBean = hosBean;
        
        self.showActionTip = YES;
        
        return self;
    }
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle


-(void)initAcvtList:(NSArray *)acvtIds
{
    
    
    if(self.m_currentAcvtArray == nil)
        _m_currentAcvtArray = [[NSMutableArray alloc]init];
    else [self.m_currentAcvtArray removeAllObjects];
    
    if (acvtIds && acvtIds.count) {
        
        WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
        
        for (NSString *acvtId in acvtIds) {
            WSAcvtBean *acvtBean = [baseAcvtDBService queryAcvtWithAcvtID:acvtId];
            if (acvtBean) {
                [self.m_currentAcvtArray addObject:acvtBean];
            }
            
        }
    }else{
        NSMutableArray * l_acvtFilters = [NSMutableArray arrayWithArray:[WSAcvtListViewController filterAcvtListWithCurrentFuncs:self.m_currentFuncs withCurrentStore:self.m_currentStore]];
        
        
        if (self.filterResult && self.filterResult.length > 0) {
            NSArray *array = [self.filterResult componentsSeparatedByString:@"@"];
            if(array.count > 1)
            {
                NSString *function = [array firstObject];
                NSString *code = array [1];
                for (WSAcvtBean *acvtBean in l_acvtFilters){
                    if ([acvtBean.acvtCode isEqualToString:code]) {
                        if ([function isEqualToString:@"remove"]) {
                            [l_acvtFilters removeObject:acvtBean];
                            break;
                        }else if([function isEqualToString:@"require"]){
                            acvtBean.isReq = @"1";
                        }
                        
                    }
                }
            }
        }
          self.m_currentAcvtArray = l_acvtFilters;
    }
    
    self.allAcvtArray = self.m_currentAcvtArray;
}

+ (NSArray *)filterAcvtListWithCurrentFuncs:(WSFuncsBean *)currentFuncs withCurrentStore:(WSStoreBean *)currentStore{
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *filtersArray = [baseAcvtDBService queryAcvtsWithStoreId:currentStore.Id filter:currentFuncs.filter];
    return filtersArray;

}

-(void)initializationBackItemAction
{
    if (self.m_ParentViewController) {
        self.m_ParentViewController.navigationItem.rightBarButtonItem = nil;
    } else  {
        self.navigationItem.rightBarButtonItem = nil;
        if (self.m_currentFuncs && self.m_currentFuncs.isHomePageWillShow) {
            NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
            if (mobileHomeDic) {
                NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
                [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
                self.m_currentFuncs.isHomePageWillShow = NO;
            }
        }else {
            [self backItemAction:nil target:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initAcvtList:nil];
    [self initializationBackItemAction];
    [self uploadVisitActionWithAcvtNoData];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    if (INTERFACE_IS_PHONE) {
        [self loadStoreNameLabel];
    }
    [self loadAcvtdis];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.y_point, self.view.bounds.size.width, self.view.bounds.size.height - self.y_point) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.tableView];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([self.allAcvtArray count] == 0) {
        if (!self.emptyView) {
            self.emptyView = [[WSEmptyView alloc] init];
            [self.view addSubview:self.emptyView];
        }
        [self.emptyView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.emptyView setHidden:NO];
    } else {
        [self.emptyView setHidden:YES];
    }
    
    // MSTD-7336 有 Tab 的时候不用进入下一层
    BOOL isTab = self.isTabMode;
    UIViewController *parentVC = self.parentViewController.parentViewController;
    if (!isTab && parentVC && [parentVC isKindOfClass:[SuperBarViewController class]]) {
        SuperBarViewController *superBarVC = (SuperBarViewController *)parentVC;
        if (superBarVC.currentFuncs.funcsArray.count > 0) {
            isTab = YES;
        }
    }
    
    // SFA-19520 根据配置添加自动跳转逻辑
    if (self.currentFuncs.opt && [self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"]) {
        if (!self.isFirstLoaded && self.allAcvtArray.count == 1 && !isTab) {
            WSAcvtBean* l_acvtBean = [self.allAcvtArray firstObject];
            [self showAcvtViewController:l_acvtBean];
        }
        
        if (self.isFirstLoaded && self.allAcvtArray.count == 1 && !isTab) {
            //        MENGNIU-579 蒙牛项目需要去除 动画 yes 变为 no 2017-10-31-又改回原逻辑(需要演示 等后续碰方案修改)
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.isFirstLoaded = YES;
    }

    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // SFA-8592
    if ([self isAddTypeEqualFilter]) {
        [self reloadAddedToStoreDatas];
        [self addToolBar];
    }
    [self loadAcvtdis];
    [self.tableView reloadData];
    
}

- (void)loadAcvtdis
{
    //YIHAIKERRY-2139 董宏 修改逻辑 按照安卓逻辑修改 查询回显显示时间而不是问题默认值
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    NSArray *arrQuestionAnswer = [service queryAcvtQuestionAnswerWithStoreId:self.currentStore.Id]; //YIHAIKERRY-3012 增加门店StoreId查询条件
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (WSAcvtBean *acvt in self.allAcvtArray)
    {
        for (NSInteger i = arrQuestionAnswer.count - 1; i > -1; i--)
        {
            WSAcvtQuestionAnswerBean *qst = arrQuestionAnswer [i];
            //            donghong   YIHAIKERRY-3228
            if ([acvt.acvtId isEqualToString:qst.acvtId] /*&&qst.acvt_qst_answer.length > 0*/)
            {
                [tempArray addObject:qst];
                self.showActionTip = NO;
                break;
            }
        }
    }
    self.acvtUploadTimeArray = tempArray;
}

#pragma mark - NewAcvt

- (BOOL)isAddTypeEqualFilter {
    NSString *addType = self.currentFuncs.opt.addType;
    if ([addType isEqualToString:self.currentFuncs.filter] ) {
        return YES;
    }
    return NO;
}

- (void)addToolBar {
    if ([self.notInStoreAcvtArray count] > 0) {
        NSString *buttonName = self.currentFuncs.buttonName;
        buttonName = [buttonName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        UIBarButtonItem *barItem = [self barButtonItemTitle:buttonName target:self action:@selector(addNewAcvt:)];
        self.parentViewController.navigationItem.rightBarButtonItem = barItem;
    } else {
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)reloadAddedToStoreDatas {
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    self.notInStoreAcvtArray = [baseAcvtDBService queryAcvtsWithfilter:self.currentFuncs.filter notInStoreId:self.currentStore.Id];
    
    self.addedToStoreAcvtArray = [baseAcvtDBService queryAcvtsWithfilter:self.currentFuncs.filter addedToStoreId:self.currentStore.Id];
   
    if ([self.addedToStoreAcvtArray count] > 0) {
        NSMutableArray *tempAllArray = [NSMutableArray arrayWithArray:self.m_currentAcvtArray];
        [tempAllArray addObjectsFromArray:self.addedToStoreAcvtArray];
        self.allAcvtArray = [tempAllArray copy];
    } else {
        self.allAcvtArray = self.m_currentAcvtArray;
    }
}

- (void)addNewAcvt:(id)sender {
    if ([self.notInStoreAcvtArray count] == 1) {
        [self showAcvtViewController:[self.notInStoreAcvtArray firstObject]];
    }else if ([self.notInStoreAcvtArray count] > 1) {
        WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        UIView *rootView = delegate.window.rootViewController.view;
        NSArray *acvtNameArray = [self.notInStoreAcvtArray valueForKeyPath:@"@unionOfObjects.acvtName"];
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
        
        CGFloat width = [view getMaxWidth];
        if (!IOS8_OR_LATER && INTERFACE_IS_PAD) {
            [view showViewFromRect:CGRectMake(rootView.height - width, 64, width, popListHeight) inView:rootView animated:YES];
        } else {
            [view showViewFromRect:CGRectMake(rootView.width - width, 64, width, popListHeight) inView:rootView animated:YES];
            
        }
    }
}



- (void)showAcvtViewController:(WSAcvtBean *)l_acvtBean {
    WSAcvtViewController* avc = nil;
    if ([self.m_currentFuncs.fv isEqualToString:@"TAB_V8001_01"]) {
        
    }else{
        if (self.hosBean) {
            avc = [[WSAcvtViewController alloc] initWithAcvt:l_acvtBean Funcs:self.m_currentFuncs Store:self.m_currentStore hosBean:self.hosBean];
        }else {
            if (self.m_currentStore != nil) {
                avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs: self.m_currentFuncs Store:self.m_currentStore SubEmpId:self.Subempid];
                avc.input_reflect_code = self.relate_sub_menu_code;
            }else if(self.m_SubempstoreBean != nil){
                WSStoreBean *bean = [[WSStoreBean alloc] initStoreWithId:self.m_SubempstoreBean.Id andName:self.m_SubempstoreBean.name andPlan:NO];
                bean.srid = self.m_SubempstoreBean.Id;
                avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs: self.m_currentFuncs Store:bean];
            }else{
                avc = [[WSAcvtViewController alloc]initWithAcvt:l_acvtBean Funcs: self.m_currentFuncs Store:self.m_currentStore SubEmpId:self.Subempid];
                avc.input_reflect_code = self.relate_sub_menu_code;
            }
        }
    }
    
    avc.title = l_acvtBean.acvtName;
    WSVisitStoreActionObject *action = [self getVisitStoreActionObjectWith:l_acvtBean];
    avc.currentVisitAction = action;
    avc.realParentFuncsCode = self.realParentFuncsCode;
    avc.wsSplitController = self.wsSplitController;
    
    [[WSVisitStoreActionTable sharedTable] insertCurrentAction:action];
    
    LogInfo(@"Go into class:%@", avc);
    
    //    [self.navigationController pushViewController:avc animated:YES];
    avc.hidesBottomBarWhenPushed = YES;
    if (self.navigationController != nil) {
        //        MENGNIU-579 蒙牛项目需要去除 动画 yes 变为 no  2017-10-31-又改回原逻辑(需要演示 等后续碰方案修改)
        [self.navigationController pushViewController:avc animated:YES];
    }else{
        [self.m_ParentViewController.navigationController pushViewController:avc animated:YES];
    }
    avc = nil;
}

-(WSVisitStoreActionObject *)getVisitStoreActionObjectWith:(WSAcvtBean *)acvt{

    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = self.currentVisitAction.ID;
    if (self.m_currentStore != nil) {
        action.store_id = self.m_currentStore.Id;
    }else if (self.m_SubempstoreBean){
        action.store_id = self.m_SubempstoreBean.Id;
    }else if (self.Subempid) {
        action.store_id = self.Subempid;
    }
    action.func_code = self.m_currentFuncs.fc;
    action.dict_id = acvt.acvtId;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = acvt.acvtName;
    if (self.currentVisitAction
        && self.currentVisitAction.module_fc
        && [self.currentVisitAction.module_fc length] > 0) {
        
        action.module_fc = self.currentVisitAction.module_fc;
    }else{
        
        action.module_fc = action.func_code;
    }
    if (self.relate_sub_menu_code) {
        action.module_fc = self.relate_sub_menu_code;
    }
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

#pragma mark - WCPopListViewDelegate
- (void)popListView:(WCPopListView *)popListView didSelectedIndex:(NSInteger)anIndex {
    [self showAcvtViewController:[self.notInStoreAcvtArray objectAtIndex:anIndex]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger l_acvtCount = [self.allAcvtArray count];
    return l_acvtCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WSAcvtBean* l_acvtBean = [self.allAcvtArray objectAtIndex:indexPath.row];
    NSString *title = l_acvtBean.acvtName;
    CGFloat cellTextLabelWidth = self.view.frame.size.width - 90;
    CGFloat contentWidth = cellTextLabelWidth > k_TableViewContentWidth ? cellTextLabelWidth : k_TableViewContentWidth;

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0], NSParagraphStyleAttributeName:style}];
    
    CGSize size =  [string boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    CGFloat height = MAX(size.height + 23, MAIN_CELL_HEIGHT);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    WSAcvtListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WSAcvtListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    
    // Configure the cell...
 
    WSAcvtBean* l_acvtBean = [self.allAcvtArray objectAtIndex:indexPath.row];
    cell.textLabel.text = l_acvtBean.acvtName;
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    cell.textLabel.font = font;
    cell.textLabel.textColor = MAIN_TEXT_COLOR;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row < self.acvtUploadTimeArray.count) {
        
        WSAcvtQuestionAnswerBean *qst = self.acvtUploadTimeArray [indexPath.row];
        if ([l_acvtBean.acvtId isEqualToString:qst.acvtId] && qst.acvt_qst_answer.length > 0) {
            NSString *uploadTime = [WSCurrentTime getTimeStringWithInterval:[qst.acvt_qst_answer doubleValue] withFormat:qst.memo];
            cell.detailTextLabel.text = uploadTime;
            cell.detailTextLabel.font = FONT_SIZE_PINGFANG_MEDIUM(11);
            cell.detailTextLabel.textColor = qst.color.length > 0 ? [UIColor colorWithHexString:qst.color] : MAIN_TEXT_COLOR;
        }
    }

    if (self.showActionTip) {
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.ID;
        if (self.m_currentStore != nil) {
            action.store_id = self.m_currentStore.Id;
        }else if (self.m_SubempstoreBean){
            action.store_id = self.m_SubempstoreBean.Id;
        }else if (self.Subempid) {
            action.store_id = self.Subempid;
        }
        
        action.func_code = self.m_currentFuncs.fc;
        action.dict_id = l_acvtBean.acvtId;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.title = l_acvtBean.acvtName;
 
    
        if ([l_acvtBean.isReq isKindOfClass:[NSString class]] && [l_acvtBean.isReq isEqualToString:@"1"]) {
            action.is_required = @"R";
        }        
 
        if (self.currentVisitAction
            && self.currentVisitAction.module_fc
            && [self.currentVisitAction.module_fc length] > 0) {
            
            action.module_fc = self.currentVisitAction.module_fc;
        }else{
            
            action.module_fc = action.func_code;
        }
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
        if ([status isEqualToString:ActionDone])
        {
            cell.imageView.image = [UIImage imageNamed:@"visit_action_done"];
        }
        else if ([status isEqualToString:ActionWorking])
        {
            cell.imageView.image = [UIImage imageNamed:@"icon_visitdoing"];
        }
        else
        {
            cell.imageView.image = nil;
        }
        
        //pim会按月回显
        WSAcvtListFlagArray* array=[WSAppData getObjectbyKey:MENUACVTLISTFLAG];

        NSPredicate* pre=[NSPredicate predicateWithFormat:@"self.empId==%@ and self.acvtId==%@",action.emp_id,l_acvtBean.acvtId];
        if (_m_currentStore.Id) {
            pre=[NSPredicate predicateWithFormat:@"self.empId==%@ and self.acvtId==%@ and self.storeId==%@",action.emp_id,l_acvtBean.acvtId,_m_currentStore.Id];
        }
        NSArray* filterArray=[array.acvtArray filteredArrayUsingPredicate:pre];
        if(filterArray.count>0){
            cell.imageView.image = [UIImage imageNamed:@"visit_done.png"];
        }
//       SFA-16921 董宏
        WSAcvtListFlagArray* arrayEcho=[WSAppData getObjectbyKey:MENUACVTLISTFLAGECHO];
        NSPredicate* preEcho=[NSPredicate predicateWithFormat:@"self.empId==%@ and self.acvtId==%@ and self.storeId==%@",action.emp_id,l_acvtBean.acvtId,_hosBean.Id];
        NSArray* filterArrayEcho=[arrayEcho.acvtArray filteredArrayUsingPredicate:preEcho];
        if(filterArrayEcho.count>0){
            cell.imageView.image = [UIImage imageNamed:@"visit_action_done"];
        }
        
        [cell setAction:action andAcvtBean:l_acvtBean];

    }

    if ([self isAddTypeEqualFilter]) {
        if (indexPath.row < self.m_currentAcvtArray.count) {
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_activity_in"]];
        } else {
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_activity_out"]];
        }
    }
    
    NSInteger totalCount = [self.allAcvtArray count];
    
    CGFloat xOffset = 15;
    if (indexPath.row == totalCount - 1) {
        xOffset = 0;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WSAcvtBean* l_acvtBean = [self.allAcvtArray objectAtIndex:indexPath.row];
    if (![self checkLastAcvtIsFinishedWithCurrentIndex:indexPath.row]) return;
    [self showAcvtViewController:l_acvtBean];
}

// 如果opt.isSeq为1的话，调查问卷的填写需要按顺序填写。SFA-14114 add by zhiqing
-(BOOL)checkLastAcvtIsFinishedWithCurrentIndex:(NSInteger)index{
    if (index == 0) return YES;
    if ([self.currentFuncs.opt.isSeq isEqualToString:@"1"]) {
        WSAcvtBean* l_acvtBean = [self.allAcvtArray objectAtIndex:index - 1];

       WSVisitStoreActionObject *action =  [self getVisitStoreActionObjectWith:l_acvtBean];
        VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action];
        if (![status isEqualToString:ActionDone]) {
            // 提示
            NSString * tips = [NSString stringWithFormat:@"%@: %@!\n%@",NSLocalizedString(@"not_input_label", nil),l_acvtBean.acvtName,NSLocalizedString(@"Please fill in the form according to the list order", nil)];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }

    }
    return YES;
}
//拜访项为必填，但没有数据，设为已读
- (void)uploadVisitActionWithAcvtNoData{
    
    if (self.m_currentFuncs.required && self.m_currentFuncs.required.length >0  && [self.allAcvtArray count] < 1) {
        [self uploadVisitAction:self.currentVisitAction];
    }
}

- (BOOL)uploadVisitAction:(WSVisitStoreActionObject *)visitAction{
    
    WSVisitStoreActionObject *nextRemindAction = visitAction;
    
    //处理重复进店
    
    NSArray *arr =[[WSVisitStoreActionTable sharedTable] queryActionsWithObject:nextRemindAction];
    if ([arr count]==0) {
        
        arr = [[WSVisitStoreActionTable sharedTable] queryActionsWithObjectExceptParentId:nextRemindAction];
        if([arr count]>0){
            
            WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
            
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            
            //NSLog(@"==>>>>> %@",self.input_reflect_code);
            
            action.parent_action_id = taction .parent_action_id;
            action.store_id = self.currentVisitAction.store_id;
            action.func_code = taction.func_code;
            action.biz_date = taction.biz_date;
            action.emp_id = taction.emp_id;
            action.is_required = taction.is_required;
            action.title = taction.title;
            if (self.currentVisitAction
                && self.currentVisitAction.module_fc
                && [self.currentVisitAction.module_fc length] > 0) {
                action.module_fc = self.currentVisitAction.module_fc;
            }else{
                action.module_fc = action.func_code;
            }
            
            
            BOOL result = [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone inOutFlag:nil];
            if (!result) {
                return NO;
            }
            
        }else{
            
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            
            action.parent_action_id = self.currentVisitAction.parent_action_id;
            action.store_id = self.currentVisitAction.store_id;
            action.func_code = nextRemindAction.func_code;
            action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
            action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
            action.is_required = nextRemindAction.is_required;
            action.title = nextRemindAction.title;
            if (self.currentVisitAction
                && self.currentVisitAction.module_fc
                && [self.currentVisitAction.module_fc length] > 0) {
                action.module_fc = self.currentVisitAction.module_fc;
            }else{
                action.module_fc = action.func_code;
            }
            
            NSLog(@"==>>> %@   , %@ ",self.relate_sub_menu_code,self.currentVisitAction.module_fc);
            BOOL result = [[WSVisitStoreActionTable sharedTable]updateAction:action toStatus:ActionDone inOutFlag:nil];
            
            if (!result) {
                return NO;
            }
            
        }
    }else{
        WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
        BOOL result = [[WSVisitStoreActionTable sharedTable]updateAction:taction toStatus:ActionDone inOutFlag:nil parentForceToDone:[self parentForceToDone]];
        if (!result) {
            return NO;
        }
        
    }
    return YES;
}
- (BOOL)parentForceToDone {
    
    if ([self.m_currentFuncs.opt.visitedFlag isEqualToString:@"Y"]) {
        return YES;
    }
    
    return NO;
}

@end
