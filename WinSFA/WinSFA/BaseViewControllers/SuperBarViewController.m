 //
//  SuperBarViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuperBarViewController.h"
#import "WSFuncsBean.h"
#import "SuperWorkSpaceViewController.h"
#import "WSAcvtBean.h"
#import "WSAppData.h"
#import "WSAcvtViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSGeographiclistViewController.h"
#import "WSGeographicInfo.h"
#import "WSPlistHelper.h"
#import "WSTodayVisitViewController.h"
#import "WSAllStoresViewController.h"
#import "WSNavigationBar.h"
#import "WSAppSettingViewController.h"
#import "WSReportFormController.h"
#import "WSEnvrionment.h"
#import "WSOtherDutyViewController.h"
#import "WSTitleTabView.h"

#import "WSBaseStoreDBService.h"
#import "WSVisitStoreStatusTable.h"

#import "WSMyMsgViewController.h"

#import "HYPageView.h"
#import "WSArrangeScheduleViewController.h"
#import "WSSendSuggestionViewController.h"
#import "WSMainLeftViewManager.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSCallPlanViewController.h"


#define kSegmentWidthOffset 10

@interface SuperBarViewController ()<WSTitleTabViewDelegate, HYPageViewDelegate>

@property (nonatomic, strong) WSTitleTabView *titleTabView;

@property (nonatomic, assign) CGFloat yPoint;

@property (nonatomic, strong) HYPageView *pageView;

@property (nonatomic, strong) NSMutableDictionary *controllerCacheDic;
@property (nonatomic , strong) NSMutableArray * pageViewControllerCacheArray;

@property (nonatomic, assign) BOOL isTitleSet;
@property (nonatomic, assign) BOOL isHideTitle;
@property (nonatomic , copy) NSString * noteJumpIndex;  //通知传来跳转的下标

@end

@implementation SuperBarViewController
@synthesize mainView = _mainView;
@synthesize currentFuncs = _currentFuncs;
@synthesize selectViewController;

-(NSMutableArray *)pageViewControllerCacheArray{
    if (!_pageViewControllerCacheArray) {
        _pageViewControllerCacheArray = [[NSMutableArray alloc]init];
    }
    return _pageViewControllerCacheArray;
}
-(void)valueChange:(id)sender
{
    for(UIView* view in [self.mainView subviews])
    {
        [view removeFromSuperview];
    }

    if(self.selectViewController)
    {
        [self.selectViewController.view removeFromSuperview];
        [self.selectViewController removeFromParentViewController];
        self.selectViewController = nil;
    }
    int seleted = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *sc = (UISegmentedControl *)sender;
        seleted = (int)sc.selectedSegmentIndex;
        
    }else if ([sender isKindOfClass:[NSNumber class]]) {
        seleted = [sender intValue];
    }
    
    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:seleted];
    
    [self getFuncViewControllerWithFunsBean:fb andIsAddToMainView:YES];
    
    if ([WSMainLeftViewManager getInstance].funcFc && ![fb.fc isEqualToString:[WSMainLeftViewManager getInstance].funcFc]) {
        [WSMainLeftViewManager getInstance].funcFc = nil;
    }
    
}


#pragma mark system mathod

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        self.title = funcs.name;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToindex:) name:TAB_JUMP_NOTIFY object:nil];

        return self;
    }
    return nil;
}

-(void)initializationBackItemAction
{
    BOOL isValidateForBack = NO;
    for ( WSFuncsBean* fb in self.currentFuncs.funcsArray ) {
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        if ([className isEqualToString:@"WSOtherDutyViewController"]) {
            isValidateForBack = YES;
        }
    }
    
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *readTimeStr = [mobileHomeDic objectForKey:MobileHomePageReadingTimeKey];
            [self backItemAction:nil target:nil withDelay:[readTimeStr intValue]];
            self.currentFuncs.isHomePageWillShow = NO;
        }
    }else {
        [self backItemAction:@selector(backAction) target:self];
    }
}
//SFA-23120 【泸州老窖-ios】考勤打卡成功后跳转考勤历史->工作日历
//上传完成后跳到下一个菜单
- (BOOL)JumpToNext
{

    LogTrace();
    if (self.currentFuncs.opt &&[self.currentFuncs.opt.autoJumpNext isEqualToString:@"1"]) {
        NSInteger currentPage = _pageView.currentPage;
        if (currentPage < _pageViewSubViewControllersArray.count - 1) {
            NSInteger index = currentPage + 1;
            [_pageView scrollToIndex:index];
            return YES;
        }
    }
    
    return NO;
}

- (void)backAction{
   [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (INTERFACE_IS_PAD && [self.selectViewController isKindOfClass:[WSMyMsgViewController class]]) {
        self.navigationController.view.width = BROWSERVC_WIDTH - kLeftVieWidth;
        [[NSNotificationCenter defaultCenter] postNotificationName:DELETE_DETAILMSG_OR_REVERT_VIEW object:nil];
    }

    if ([self.selectViewController isKindOfClass:[WSOtherDutyViewController class]]) {
        
        WSOtherDutyViewController *vc = (WSOtherDutyViewController *)self.selectViewController;
        if ([vc respondsToSelector:@selector(isValueChange)]) {
            if (vc.isValueChange) {
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"back_confirm2", nil)];
                
                [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
                [alert addButtonWithTitle:NSLocalizedString(@"upload_label", nil) block:^{
                    [vc checkRecordAlert];
                }];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"give_up", nil) block:^{
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }];
                [alert show];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }

        }

    } else if(self.pageViewSubViewControllersArray && [[self.pageViewSubViewControllersArray firstObject] isKindOfClass:[WSCallPlanViewController class]])
    {
        WSCallPlanViewController *vc = (WSCallPlanViewController *)[self.pageViewSubViewControllersArray firstObject];
        [vc backAction];
    }
    
    else{
        
        BOOL customBackAction = NO;
        
        if ([self.selectViewController isKindOfClass:[WCBaseViewController class]]) {
            WCBaseViewController *con = (WCBaseViewController *)self.selectViewController;
            if ([con shouldPauseBackAction]) {
                [con backAction];
                customBackAction = YES;
            }
        }
        
        if (!customBackAction) {
            [self backToParent];
        }
    }
    
}
/*实时请求门店后不需要再次请求该门店的现有功能影响其他的功能. 临时修复其他功能办法,以后删除*/
- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isTitleSet != YES) {
        self.title=self.currentFuncs.name;
    }
    [self initializationBackItemAction];
    
    
    if (INTERFACE_IS_PAD) {
        self.view.backgroundColor = RGBCOLOR(246,246,246);
    }
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadge) name:FRIEND_COMMUNITY_NEW_MESSAGE_NOTIFICATION object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBadge) name:FRIEND_COMMUNITY_DELETE_MESSAGE_NOTIFICATION object:nil];

}
//保存通知过来的跳转下标
- (void)jumpToindex:(NSNotification *)notification  {
    
    NSDictionary *userInfo = [notification userInfo];
    NSString *noteFc = userInfo[@"tabFC"];
    if([noteFc isEqualToString:self.currentFuncs.fc]){
        self.noteJumpIndex = userInfo[TAB_JUMP_NOTIFY];
    }
}
// //执行跳转方法
- (void)executionJumpNotify {
    if(self.noteJumpIndex) {
        [self.pageView scrollToIndex:[self.noteJumpIndex intValue]];
        self.noteJumpIndex = nil;
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
    
   // SFA-25441 立白 SFA--IOS--首页更换两个按钮：原报表查询与在线客服更改为订单管理、门店拜访按钮 跳转到指定的列表
    [self executionJumpNotify];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
    
}

-(void)dealloc{
       [[NSNotificationCenter defaultCenter] removeObserver:self name:FRIEND_COMMUNITY_NEW_MESSAGE_NOTIFICATION object:nil];
       [[NSNotificationCenter defaultCenter] removeObserver:self name:FRIEND_COMMUNITY_DELETE_MESSAGE_NOTIFICATION object:nil];
}

//// Implement loadView to create a view hierarchy programmatically, without using a nib.

- (void) addSelfMainView
{
    UIView* view = [[UIView alloc]initWithFrame:CGRectZero];
    self.mainView = view;
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mainView];
}

- (void) setMainViewFrame {
    int l_funcsCount = (int)[self.currentFuncs.funcsArray count];
    if(l_funcsCount < 2)
    {
        self.mainView.frame = self.view.bounds;
    }else{
        
        CGFloat x = INTERFACE_IS_PHONE ? 0 : 15;
        
        self.mainView.frame = CGRectMake(x, self.yPoint, self.view.bounds.size.width - 2 * x, self.view.bounds.size.height - self.yPoint);
    }

}

- (NSArray *)getTitleArray
{
    int l_funcsCount = (int)[self.currentFuncs.funcsArray count];
    
    if(l_funcsCount == 0)
        return nil;
    
    if(l_funcsCount == 1)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:0];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            return nil;
        }
        return @[subfuncs.name];
    }
    
    NSMutableArray* segmentTitlesArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < l_funcsCount;i++)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            continue;
        }
        
        if ([subfuncs.filter isEqualToString:@"tradocument"] || [subfuncs.fv isEqualToString:@"FV_ROLE_SWITCH"]) {
            continue;
        }
        [segmentTitlesArray addObject:subfuncs.name];
    }
    
    return segmentTitlesArray;
}

- (void)addTitleTabView
{
    int l_funcsCount = (int)[self.currentFuncs.funcsArray count];
    if(l_funcsCount == 0)
        return;
    if(l_funcsCount < 2)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:0];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            return;
        }
        [self valueChange:nil];
        return;
    }
    
    
    NSMutableArray* segmentTitlesArray = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < l_funcsCount;i++)
    {
        WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
        if (subfuncs.display != nil && [subfuncs.display isKindOfClass:[NSString class]] && [subfuncs.display isEqualToString:@"0"])
        {
            continue;
        }
        [segmentTitlesArray addObject:subfuncs.name];
    }

    WSTitleTabView *tabView = [[WSTitleTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TITLE_TAB_VIEW_HEIGHT) titleArray:[self getRefreshedTitleArray] aligment:WSTitleTabViewAlignmentCenter];
    tabView.delegate = self;
    tabView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleTabView = tabView;
    
    [self.view addSubview:self.titleTabView];
    
    self.yPoint = TITLE_TAB_VIEW_HEIGHT;
}

/*
- (void) addFuncsSegmentView
{
    NSArray *segmentTitlesArray = [self getTitleArray];
    
    UISegmentedControl *segmentedcontrol = [[UISegmentedControl alloc] initWithItems:segmentTitlesArray];

    segmentedcontrol.backgroundColor = [UIColor whiteColor];
    
    segmentedcontrol.frame = CGRectMake(kSegmentWidthOffset/2, kSegmentedControlTopGap, self.view.width - kSegmentWidthOffset, kSegmentedControlHeight);
    
    [segmentedcontrol addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    if (INTERFACE_IS_PAD) {
        
        UIColor* selectedColor= MAIN_TINT_COLOT;
        if (!selectedColor) {
            selectedColor = [UIColor colorWithRed:0.0 green:147.0/255.0 blue:208.0/255.0 alpha:1.0];
        }
        segmentedcontrol.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        segmentedcontrol.layer.cornerRadius = kSegmentedControlHeight / 2.0f;
        segmentedcontrol.clipsToBounds = YES;
        segmentedcontrol.layer.borderWidth = 1.0;
        segmentedcontrol.layer.borderColor = [selectedColor CGColor];
        
    }
    
    [self setTitleArray:segmentTitlesArray];
    
    UIView *segControlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kSegmentedControlHeight + kSegmentedControlTopGap)];
    [segControlView setBackgroundColor:[UIColor whiteColor]];
    [segControlView addSubview:segmentedcontrol];
    [self.view addSubview:segControlView];
    
    self.segmentedControl = segmentedcontrol;
    
    self.yPoint = kSegmentedControlTopGap + kSegmentedControlHeight + kSegmentedControlBottomGap;
}


- (void)setTitleArray:(NSArray *)titleArray
{
    CGFloat length = 0;
    
    for (NSInteger i = 0; i < [titleArray count]; i++) {

        NSString *title = titleArray[i];
        
        if (INTERFACE_IS_PHONE) {
            CGSize size = [title sizeWithFont:UI_SEGMENTCONTROL_FONT forWidth:self.view.width-20 lineBreakMode:NSLineBreakByCharWrapping];
            
            CGFloat dynamic_width = size.width + (INTERFACE_IS_PHONE ? 20.0 : 60.0)- kSegmentWidthOffset;
            
            if (IOS9_OR_LATER && INTERFACE_IS_PAD) {
                dynamic_width +=20;
            }
            
            if (INTERFACE_IS_PHONE) {
                if ([titleArray count] < 3) {
                    dynamic_width = ((self.view.bounds.size.width-kSegmentWidthOffset)/[titleArray count]);
                }
            }
            
            [self.segmentedControl setWidth:dynamic_width forSegmentAtIndex:i];
            
            length+=dynamic_width;
            
        }
        
        [self setTitle:title forIndex:i];
    }
    
    if (INTERFACE_IS_PHONE) {
        CGFloat width = length;
        
        if (width >= self.view.bounds.size.width - kSegmentWidthOffset) {
            width = self.view.bounds.size.width - kSegmentWidthOffset;
            
            for (NSInteger i=0; i < [titleArray count]; i++) {
                
                CGFloat dynamic_width = ((self.view.bounds.size.width-kSegmentWidthOffset)/[titleArray count]);
                
                [self.segmentedControl setWidth:dynamic_width forSegmentAtIndex:i];
                
            }
        }
        self.segmentedControl.frame = CGRectMake((self.view.bounds.size.width - width)/2, kSegmentedControlTopGap, width, kSegmentedControlHeight);
    }
}

// 在不点击segementController的item情况下可显示其对应模块的门店数据
- (void)refreshSegementControllerTitle
{
    WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
    NSInteger funcsCount = [self.currentFuncs.funcsArray count];
    if(funcsCount == 0) {
        return;
    }
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:funcsCount];
    
    for(int i = 0 ; i < funcsCount;i++)
    {
        self.segmentedControl.selectedSegmentIndex = i;
        WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:i];
        NSString *title = fb.name;
        if ([fb.fv isEqualToString:@"TAB_V2001"]) {
            if ([WSEnvrionment getStoreDataFromDb]) {
                NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                
                WSVisitStoreStatusTable *visitTable = [[WSVisitStoreStatusTable alloc] init];
                NSInteger visitedCount = [visitTable queryInPlanStoresVisitedCountWithFuncBean:fb empId:empId biz_date:bizDate];
                NSInteger planStoreCount = [baseStoreDBService queryInPlanStoresCountWithFuncBean:fb empId:empId biz_date:bizDate];
                title = [NSString stringWithFormat:@"%@(%ld/%ld)",fb.name, visitedCount, planStoreCount] ;
            }
        }else if ([fb.fv isEqualToString:@"TAB_V2002"]) {
            
            if ([WSEnvrionment getStoreDataFromDb]) {
                NSInteger allStoreCount = [baseStoreDBService queryAllStoresCountWithFuncBean:fb empId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
                title = [NSString stringWithFormat:@"%@(%ld)",fb.name,allStoreCount] ;
            }
        }
        [titleArray addObject:title];
    }
    
    [self setTitleArray:titleArray];
}
*/

- (NSArray *)getRefreshedTitleArray
{
    WSBaseStoreDBService *baseStoreDBService = [[WSBaseStoreDBService alloc] init];
    NSInteger funcsCount = [self.currentFuncs.funcsArray count];
    if(funcsCount == 0) {
        return nil;
    }
    NSMutableArray *titleArray = [NSMutableArray arrayWithCapacity:funcsCount];
    
    for(int i = 0 ; i < funcsCount;i++)
    {
        self.segmentedControl.selectedSegmentIndex = i;
        WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:i];
        
        // 如果是关于里面加的funcs，不在外层添加VC
        if ([fb.filter isEqualToString:@"tradocument"] || [fb.fv isEqualToString:@"FV_ROLE_SWITCH"] || [fb.display isEqualToString:@"0"]) {
            continue;
            
        }
        
        NSString *title = fb.name;
        if ([fb.fv isEqualToString:@"TAB_V2001"]) {
            if ([WSEnvrionment getStoreDataFromDb]) {
                NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
                
                WSVisitStoreStatusTable *visitTable = [[WSVisitStoreStatusTable alloc] init];
                NSInteger visitedCount = [visitTable queryInPlanStoresVisitedCountWithFuncBean:fb empId:empId biz_date:bizDate];
                NSInteger planStoreCount = [baseStoreDBService queryInPlanStoresCountWithFuncBean:fb empId:empId biz_date:bizDate];
                NSInteger routeStoreCount = [baseStoreDBService queryRoutePlanStoreCountByBiz_date:bizDate search_objId:fb.ds?fb.ds:@"stores"];
                
                title = [NSString stringWithFormat:@"%@(%ld/%ld)",fb.name, (long)visitedCount, ((long)planStoreCount + routeStoreCount)] ;
            }
        }else if ([fb.fv isEqualToString:@"TAB_V2002"]) {

            if ([WSEnvrionment getStoreDataFromDb]) {

                BOOL isSearchable  = [fb.opt.isSearchable isEqualToString:@"remote"];
                NSString *search_objId = ([fb.ds length] > 0 ? fb.ds : STORES);
                NSString *routeID = [fb.fc isEqualToString:@"TAB_F2001_AT01"] ? @"1" : @"0";
                NSDictionary *otherDic = @{kStoreDBOtherData_RouteID : routeID};
                NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                NSInteger allStoreCount = [[WSBaseStoreDBService shareInstance] queryAllStoreCountEmpId:empId
                                                                                                   styp:fb.styp
                                                                                              searchStr:nil
                                                                                           search_objId:search_objId
                                                                                           isSearchable:isSearchable
                                                                                                 acvtId:nil
                                                                                       selctedQstValues:nil
                                                                                        rangeConditions:nil
                                                                                               distance:0
                                                                                           otherDataDic:otherDic];
                title = [NSString stringWithFormat:@"%@(%ld)", fb.name, (long)allStoreCount];
            }
        }
        
        [titleArray addObject:title];
    }
    
    return titleArray;
}

- (UIViewController *)resetViewController:(UIViewController *)vc   funcsBean:(WSFuncsBean *)fb  {
    
    if ([fb.fv isEqualToString:@"TAB_V2001"]) {
        if (fb.opt && [fb.opt.autoJumpNext isEqualToString:@"1"]) {
            if ([vc isKindOfClass:[WSTodayVisitViewController class]]) {
                
                WSTodayVisitViewController *todayVisitVC = (WSTodayVisitViewController *)vc;
                NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                NSString *search_objId =([fb.ds length] > 0)?fb.ds : STORES;
                NSString *styp = fb.styp;
                NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
                
                NSArray *stores = [[WSBaseStoreDBService  shareInstance] queryInPlanStoresWithFuncCode:fb.fc empId:empId  search_objId:search_objId styp:styp biz_date:biz_date storeAccessMode:WSStoreAccessModeNormal otherDataDic:nil];
                if ([stores count] == 1) {
                    return [todayVisitVC generateNextVCWithFuncsBean:fb store:[stores firstObject] isSelf:NO];
                }
            }
        }
    }
    
    return nil;
}

-(NSInteger) initializationSelectSegment
{
    if (self.currentFuncs && self.currentFuncs.isHomePageWillShow) {
        NSDictionary *mobileHomeDic = [WSAppData getObjectbyKey:MOBILEHOMEPAGE];
        if (mobileHomeDic) {
            NSString *fcValue = [mobileHomeDic objectForKey:MobileHomePageFcKey];
            for(NSInteger i = 0 ; i < [self.currentFuncs.funcsArray count];i++) {
                WSFuncsBean* subfuncs = [self.currentFuncs.funcsArray objectAtIndex:i];
                if ([subfuncs.fc isEqualToString:fcValue]) {
                    return i;
                }
            }
        }
    }
    
    return 0;
}

- (void)refreshBadge {
    [self setBadge];
}


- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    //初始化MainView
    [self addSelfMainView];

//    NSArray *titleArray = [self getTitleArray];
    NSArray *titleArray = [self getRefreshedTitleArray];
    
    if ([titleArray count] == 1) {
        //YIHAIKERRY-4771
        [self setMainViewFrame];
        [self valueChange:nil];

    }else if ([titleArray count] > 1){
        
        if (INTERFACE_IS_PHONE) {
//            [self addFuncsSegmentView];
            [self setMainViewFrame];
            _pageViewSubViewControllersArray = [NSArray arrayWithArray:[self getAllFuncsViewControllers]];
            [self addFuncsSegmentPageViewWithTitleArray:titleArray andViewControllersArray:_pageViewSubViewControllersArray];
        }else {
            [self addTitleTabView];
            [self setMainViewFrame];

        }
    }

//    [self refreshSegementControllerTitle];

    if ([titleArray count] > 1) {
        [self initializationSelection];
    }
    
    
    self.controllerCacheDic = [NSMutableDictionary dictionaryWithCapacity:titleArray.count];
    
}

- (void)addFuncsSegmentPageViewWithTitleArray:(NSArray *)titleArray andViewControllersArray:(NSArray *)vcArray
{
    
    NSDictionary *additionalInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"isRemoveChildVC", nil];
    _pageView = [[HYPageView alloc] initWithFrame:self.mainView.bounds withTitles:titleArray withViewControllers:vcArray
                                   withParameters:nil withAdditionalInfo:additionalInfo];
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pageView.pageDelegate = self;
    
    _pageView.isHideTitle = self.isHideTitle;
    
    WSBaseDictsDBService *dictService = [[WSBaseDictsDBService alloc] init];
    WSDictBean *menuStyleDict = [dictService queryDictWithID:self.currentFuncs.menuStyle];
    if ([menuStyleDict.name isEqualToString:FUNCS_MENUSTYLE_PAGE_TITLE]) {
        [_pageView setIsTranslucent:NO];
        
        UIColor *titleColor = [UIColor colorForKey:@"TabBarPageTitleColor"];
        if (!titleColor) {
            titleColor = [UIColor whiteColor];
        }
        UIColor *titleSelectedColor = [UIColor colorForKey:@"TabBarPageTitleSelectedColor"];
        if (!titleSelectedColor) {
            titleSelectedColor = [UIColor whiteColor];
        }
        _pageView.selectedColor = titleSelectedColor;
        _pageView.unselectedColor = titleColor;
        
        _pageView.bottomImage = [UIImage imageNamed:@"icon_top_nav_now"];
        _pageView.isShowRightButton = YES;
    } else {
        _pageView.selectedColor = MAIN_TINT_COLOT;
        _pageView.unselectedColor = [UIColor blackColor];
    }

    [self.mainView addSubview:_pageView];
}

- (NSArray *)getAllFuncsViewControllers
{
    
    NSMutableArray *vcMArray = [[NSMutableArray alloc] init];
    
    for (WSFuncsBean* fb in self.currentFuncs.funcsArray) {
        
        UIViewController *vc = [self getFuncViewControllerWithFunsBean:fb andIsAddToMainView:NO];
        
        // 如果是关于里面加的funcs，不在外层添加VC
        if ([fb.filter isEqualToString:@"tradocument"] || [fb.fv isEqualToString:@"FV_ROLE_SWITCH"] ) {
            
        }else{
            if (vc)
            {
                ((WCBaseViewController *)vc).isPageSegmentView = YES; //MN-1327 2018-03-19
                [vcMArray addObject:vc];
            }
        }
    }
    
    return [NSArray arrayWithArray:vcMArray];
}

- (UIViewController *)getFuncViewControllerWithFunsBean:(WSFuncsBean *)fb andIsAddToMainView:(BOOL)isAdd
{
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    
    // SFA-15028 泸州老窖兼容安卓查找TAB_MV_LIST下级菜单FV选择呈现方式
    // WSMV_LISTViewController为新式Cell呈现方式，WSCollectionMVListViewController为旧式Cell呈现方式与此需求冲突，以下特殊分发跳转逻辑还需加上
    if ([fb.fv isEqualToString:@"TAB_MV_LIST"]) {
        className = @"WSMV_LISTViewController";
    }

    
    if (INTERFACE_IS_PAD && isAdd) {
        UIViewController *vc = [self.controllerCacheDic objectForKey:fb.fc];
        if (vc) {
            [self addChildViewController:vc];
            [self.mainView addSubview:vc.view];
            self.selectViewController = vc;
            return nil;
        }
    }
    
    UIViewController *vc = nil;
    
    if ([className isEqualToString:@"WSSendSuggestionViewController"]) {
        NSString *receiverString = NSLocalizedString(@"receiver",nil);
        NSString *subjectString = NSLocalizedString(@"theme",nil);
        NSArray* array = [NSArray arrayWithObjects:receiverString,subjectString, nil];
        vc = [[WSSendSuggestionViewController alloc]initWithFuncs:fb Titles:array];
    }else {
        vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
        vc.currentStore = self.currentStore;
        vc.prepareVisitDate = self.prepareVisitDate;
    }
    
    LogInfo(@"Going to init class name: %@, fb.fv:%@", className, fb.fv);
    
    if(vc)
    {
        
        if ([vc isKindOfClass:[WCBaseViewController class]]) {
            ((WCBaseViewController*)vc).ownParentViewController = self;
        }
        
        if ([vc isKindOfClass:[SuperWorkSpaceViewController class]]) {
            ((SuperWorkSpaceViewController*)vc).delegate = self;
        }
        
        if ([vc isKindOfClass:[BaseViewController class]]) {
            ((BaseViewController *)vc).m_ParentViewController = self;
            vc.currentStore = self.currentStore;
        }
        
        if ([vc isKindOfClass:[WSGeographiclistViewController class]]) {
            WSGeographiclistViewController *geovc = (WSGeographiclistViewController *)vc;
            WSGeographicInfo *info = [WSAppData getObjectbyKey:GEOINFO];
            geovc.iGeographicInfos = info.iProvineceInfoArray;
        }
        

        vc.currentVisitAction = self.currentVisitAction;
        
        vc.view.frame = self.mainView.bounds;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([vc isKindOfClass:[WSSpecialAcvtViewController class]]) {
            WSSpecialAcvtViewController *spacvt = (WSSpecialAcvtViewController*)vc;
            if ([self.currentFuncs.funcsArray count]>=2) {
                [[spacvt m_AcvtViewController] setHasSegment:YES];
                [spacvt m_AcvtViewController].isTabMode = YES;
            }
            UITableView *tv = spacvt.m_AcvtViewController.tableView;
            if (tv.height > self.mainView.height) {
                spacvt.m_AcvtViewController.tableView.frame = CGRectMake(tv.left, tv.top, tv.width, self.mainView.height);
            }
        }
        
        if ([self.currentFuncs.funcsArray count] >= 2 && [vc isKindOfClass:[WCBaseViewController class]]) {
            WCBaseViewController *baseVc = (WCBaseViewController *)vc;
            baseVc.hasSegment = YES;
        }
        
        
        UIViewController *childNextVC = [self resetViewController:vc funcsBean:fb];
        if (childNextVC) {
            vc = childNextVC;
            self.isTitleSet = YES;
            self.title = vc.title;
        }
        
        [self.controllerCacheDic setObject:vc forKey:fb.fc];
        
        if (isAdd) {
            [self addChildViewController:vc];
            [self.mainView addSubview:vc.view];
            self.selectViewController = vc;
            return nil;
        }
        
        if (fb.opt && fb.opt.isHideTitle) {
            self.isHideTitle = YES;
        }
        
    }else{
        LogInfo(@"%@ is nil.", className);
        NSString *className = [WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName];
        UIViewController *vcds =[[NSClassFromString(className) alloc] initWithFuncs:fb];
        LogInfo(@"Going to init class: %@, fb.ds:%@", vcds, fb.ds);
        
        if (vcds != nil && [vcds isKindOfClass:[BaseViewController class]]) {
            
            BaseViewController *vcbase = (BaseViewController *)vcds;
            vcbase.m_ParentViewController = self;
            vcds.view.frame = self.mainView.bounds;
            vcds.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            vc = vcds;
            
            [self.controllerCacheDic setObject:vc forKey:fb.fc];
            
            if (isAdd) {
                [self addChildViewController:vcbase];
                [self.mainView addSubview:vcds.view];
                self.selectViewController = vcds;
                return nil;
            }
        }
        
        vcds = nil;
    }
    
    return vc;
}

- (void)currentPageChangedFromOldIndex:(NSInteger)oldIndex toNewIndex:(NSInteger)newIndex
{
    NSLog(@"currentPageChangedFromOldIndex = %ld toNewIndex = %ld", (long)oldIndex, (long)newIndex);
    WCBaseViewController *newVC = [_pageViewSubViewControllersArray objectAtIndex:newIndex];
    if (newVC.currentFuncs.opt.isAdd.length > 0) {
        _pageView.rightButton.hidden = NO;
    }else
        _pageView.rightButton.hidden = YES;
    
    [self setBadge];

    // isAppearing
    // true if the child view controller's view is about to be added to the view hierarchy, false if it is being removed.
    // viewWillAppear调⽤用设置为YES，viewWillDisappear调⽤用设置为NO
    
    // 如果newVC 没有点击过，不需要手动掉  delayAppearDidMethodWithOldViewController
//    NSString * newVcClassName = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([newVC class]),(long)newIndex];
//    BOOL isFirstLoadNewVC = ![self.pageViewControllerCacheArray containsObject:newVcClassName];
//    if (isFirstLoadNewVC) {
//        [self.pageViewControllerCacheArray addObject:newVcClassName];
//    }
//    MMSH-3234 董宏 修改逻辑
//    if (oldIndex == newIndex && [self.pageView isFirstLoad] == NO) {
//        
//    }else if (isFirstLoadNewVC  && oldIndex != newIndex)
//    {
//        [oldVC beginAppearanceTransition:NO animated:YES];
//        [self performSelector:@selector(delayAppearDidMethodWithOldViewController:) withObject:@[oldVC,newVC] afterDelay:0.01];
//    }
//    else
//    {
////        //2017-11-03-MSTD-6773
////        if(oldIndex == 0 && oldIndex == newIndex && [self.pageView isFirstLoad])
////            return;
//        
//        [oldVC beginAppearanceTransition:NO animated:YES];
//        [self performSelector:@selector(delayAppearDidMethodWithOldViewController:) withObject:@[oldVC,newVC] afterDelay:0.01];
//    }

}

-(void)currentPageClickButtonWithPageIndex:(NSInteger)pageIndex{
    WCBaseViewController *currentVc = [_pageViewSubViewControllersArray objectAtIndex:pageIndex];
    [currentVc HYPageViewButtonClickEvent];
}
- (void)delayAppearDidMethodWithOldViewController:(NSArray *)vcsArray
{
    [[vcsArray firstObject] endAppearanceTransition];
    [self delayRunMethodWithNewViewController:[vcsArray lastObject]];
}

- (void)delayRunMethodWithNewViewController:(UIViewController *)newVC
{
    [newVC beginAppearanceTransition:YES animated:YES];
    [self performSelector:@selector(delayAppearDidMethodWithNewViewController:) withObject:newVC afterDelay:0.01];
}

- (void)delayAppearDidMethodWithNewViewController:(UIViewController *)newVC
{
    [newVC endAppearanceTransition];
}

- (void)initializationSelection
{
    NSInteger normalSelect = [self initializationSelectSegment];
    
    normalSelect = MAX(0, normalSelect);
    
    if (INTERFACE_IS_PHONE) {
//        [self.segmentedControl setSelectedSegmentIndex:normalSelect];
//        [self valueChange: [NSNumber numberWithInteger: normalSelect]];
    }else {
        [self.titleTabView setSelectedIndex:normalSelect];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (INTERFACE_IS_PAD && self.titleTabView) {
        
        if ([WSMainLeftViewManager getInstance].funcFc) {
            for (int i = 0; i < self.currentFuncs.funcsArray.count; i++) {
                WSFuncsBean * fb = self.currentFuncs.funcsArray[i];
                if ([fb.fc isEqualToString:[WSMainLeftViewManager getInstance].funcFc]) {
                    self.titleTabView.selectedIndex = i;
                }
            }
        }
        
        [self.titleTabView refreshTitlesWithTitleArray:[self getRefreshedTitleArray]];
    }
}

- (void)setBadge {
    // MN-792
    NSInteger pageCount = [_pageViewSubViewControllersArray count];
    if (pageCount > 0) {
        for (NSInteger i = 0; i < pageCount; i++) {
            JSBadgeView *badgeView = self.pageView.titleBadgeView[i];
            WCBaseViewController *newVC = [_pageViewSubViewControllersArray objectAtIndex:i];
            [badgeView setBadgeText:[newVC getBadgeValue]];
        }
    }
}

- (void)setTitle:(NSString *)title forIndex:(NSInteger)index
{
    if (INTERFACE_IS_PHONE) {
        [self.segmentedControl setTitle:title forSegmentAtIndex:index];
    }else {
        [self.titleTabView setTitle:title forTabAtIndex:index];
    }
}

#pragma mark - SuperWorkSpaceViewControllerDelegate

- (void)superWorkSpaceVC:(SuperWorkSpaceViewController *)controller refreshControllerTitle:(NSString *)title
{
    if ([title length] > 0) {
        if (INTERFACE_IS_PHONE) {
            if (_pageViewSubViewControllersArray && _pageViewSubViewControllersArray.count > 0) {
                NSInteger index = [_pageViewSubViewControllersArray indexOfObject:controller];
                [_pageView refreshTitle:title atPageIndex:index];
            }
            
//            [self setTitle:title forIndex:self.segmentedControl.selectedSegmentIndex];
        }else {
            [self setTitle:title forIndex:self.titleTabView.selectedIndex];
        }
    }
    
}

#pragma mark - WSTitleTabViewDelegate

- (void)titleTabView:(WSTitleTabView *)acvtTabView didSelectTitleAtIndex:(NSInteger)index
{
    
    [self valueChange:[NSNumber numberWithInteger:index]];
}


@end
