//
//  WSFuncsBeanContainerViewController.m
//  WinSFA
//
//  Created by yang on 17/1/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSFuncsBeanContainerViewController.h"
#import "WSReportFormController.h"
#import "WSRefreshLoginHttpService.h"
#import "MJRefresh.h"
#import "WSMainNoticeView.h"
#import "WSInoutStoreTable.h"
#import "WSFuncsBeanArray.h"
#import "WSLoginDataProcessService.h"
#import "WSMJProgressHeader.h"
#import "WSWorkBenchViewController.h"
#import "SuperBarViewController.h"
#import "WSCollectionMVListViewController.h"
#import "WSHorizontalPageViewController.h"
#import "WSRequestHelper.h"
#import "WSMsgsBean.h"
#import "WSMsgBeanArray.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSBaseStoreOtherDataDBService.h"

#define kViewGap            15
#define kBaseTagShadow      100
#define kShadowCornerRadius 5
#define kTopMsgFV           @"TAB_MSG_TOP"
#define kMainMvListFV       @"TAB_MV_LIST"
#define kkWorkBenchFV       @"FV_WORK"
#define kSalesInfoFV        @"FV_sales_info"
#define kCircleInfoFV       @"FV_circle_info"

@interface WSFuncsBeanContainerViewController () <WSReportFormControllerDelegate> {
    
    BOOL isFirstLoad;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *topMsgBeanArray;
@property (nonatomic, strong) WSMainNoticeView *noticeView;
@property (nonatomic, strong) NSMutableArray *controllerArray;
@property (nonatomic, assign) BOOL isSetOffset;
@property (nonatomic, strong) NSThread *noticeThread;
@property (nonatomic, strong) NSTimer *noticeTimer;
@property (nonatomic, copy) NSString *remindStr;                //提醒文字

@end

@implementation WSFuncsBeanContainerViewController

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    
    isFirstLoad = YES;
    
    [self setUpRefreshService];
    [self setUpViews];
    [self resetViewsFrame];
    [self handleTabBarItemBadgeValue];
    [self offlineLoginRefresh];
    
    //定时获取公告信息内容
    NSString *isPushInfomation = [[NSUserDefaults standardUserDefaults] objectForKey:INFORMATION_PUSH];
    if ([isPushInfomation isEqualToString:@"1"]) {
        [self updateNoticeInfoRequestStart];
        self.noticeThread = [[NSThread alloc]initWithTarget:self selector:@selector(updateNoticeInfo) object:nil];
        [self.noticeThread start];
    }
    
    //YIHAIKERRY-4345
    __weak __typeof(self) weakSelf = self;
    [self queryAdditionalRemindWithEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID] storeId:nil completionBlock:^(BOOL isSuccess, NSString *result) {
        
        if (isSuccess && (result && result.length > 0)) {
            UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (appRootVC.presentedViewController) {
                weakSelf.remindStr = [NSString stringWithFormat:@"%@", result];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:result];
                    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
                    [alert show];
                });
            }
        }
    }];
}

#pragma mark - 重写viewWillAppear:方法
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //SFA-30490
    if (!isFirstLoad && ![self.scrollView.mj_header isRefreshing] && [self.currentFuncs.opt.isRefresh isEqualToString:@"1"]) {
        [self.scrollView.mj_header beginRefreshing];
    }
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self checkStoreHaveNotLeave];
    
    //YIHAIKERRY-4345
    if (self.remindStr && self.remindStr.length > 0) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:self.remindStr];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
        [alert show];
        self.remindStr = nil;
    }
    
    if (!isFirstLoad) {
        return;
    }
    isFirstLoad = NO;
    
    [self showMobileHomePage];
}

#pragma mark - 离线登陆刷新方法
- (void)offlineLoginRefresh {
    
    WSLoginDataProcessService *loginService = [[WSLoginDataProcessService alloc] init];
    if ([loginService isOfflineLoginWhenLaunchNeedRefresh]) {
        [self.scrollView.mj_header beginRefreshing]; //改为启动下拉刷新的形式进行刷新操作
    }
}

#pragma mark - 处理导航项目的徽章方法
- (void)handleTabBarItemBadgeValue {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *funCode = (self.currentFuncs.iParentFuncsBean) ? self.currentFuncs.iParentFuncsBean.fc : self.currentFuncs.fc;
    NSString *item2 = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:FUNC_TIP empId:empId funcode:funCode];
    
    UIViewController *vc = (self.ownParentViewController) ? self.ownParentViewController : self;
    NSInteger count = [item2 integerValue];
    if (count <= 0) {
        vc.tabBarItem.badgeValue = nil;
    } else {
        NSString *badgeValue = (count > 99) ? @"..." : [NSString stringWithFormat:@"%ld", count];
        vc.tabBarItem.badgeValue = badgeValue;
    }
}

#pragma mark - 设置刷新服务方法
- (void)setUpRefreshService {
    
    self.refreshService = [[WSRefreshLoginHttpService alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    self.refreshService.endRefreshBlock = ^(WSRefreshLoginStatus status) {
        
        [weakSelf.scrollView.mj_header endRefreshing];
        
        if (status == WSRefreshLoginStatusSuccess) {
            [weakSelf.view removeAllSubviews];
            [weakSelf setUpViews];
            [weakSelf resetViewsFrame];
            [weakSelf handleTabBarItemBadgeValue];
        }
        
        // SFA-9411 重置工作台模块菜单
        NSArray *controllerArray = weakSelf.tabBarController.viewControllers;
        if ([controllerArray count] > 0) {
            for (UIViewController *controller in controllerArray) {
                if ([controller isKindOfClass:[UINavigationController class]]) {
                    UIViewController *topController =  [(UINavigationController *)controller topViewController];
                    if ([topController isKindOfClass:[SuperBarViewController class]]) {
                        BOOL isFind = NO;
                        for (UIViewController *subController in topController.childViewControllers) {
                            if ([subController isKindOfClass:[WSWorkbenchViewController class]]) {
                                WSFuncsBeanArray *funcsArray = [WSAppData getObjectbyKey:FUNCS];
                                WSFuncsBean *oldFb = [((WSWorkbenchViewController *)subController) currentFuncs];
                                WSFuncsBean *fb = [funcsArray getFuncsBeanWithFC:oldFb.fc];
                                if ([fb.fv isEqualToString:kkWorkBenchFV]) {
                                    [((WSWorkbenchViewController *)subController) setCurrentFuncs:fb];
                                    isFind = YES;
                                    break;
                                } else {
                                    LogError(@"获取刷新模块失败 %@, %@", oldFb.fc, oldFb.fv);
                                }
                            }
                        }
                        
                        if (isFind) {
                            break;
                        }
                    }
                }
            }
        }
        
        if (status == WSRefreshLoginStatusDisable) {
            // TODO:
        }
        
        weakSelf.view.userInteractionEnabled = YES;
        weakSelf.navigationController.view.userInteractionEnabled = YES;
    };
    
    self.refreshService.progressBlock = ^(NSInteger progress) {
        WSMJProgressHeader *header = (WSMJProgressHeader *)weakSelf.scrollView.mj_header;
        [header setLoadingProgress:progress];
    };
}




-(void)showMobileHomePage{
    
    WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
    
    NSDictionary * showFuncsBeanDict = [fba getShowFuncsBean];
    if ([[showFuncsBeanDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
        WSFuncsBean * fb = [showFuncsBeanDict objectForKey:FROM_FUNCS_BEAN];
        
        WSFuncsBean * showHomePageFuncs = [showFuncsBeanDict objectForKey:SHOW_FUNCS_BEAN];
        
        NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
        LogInfo(@"Going to init class: %@",className);
        //            WCBaseViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:showHomePageFuncs];
        WCBaseViewController * control = [WCBaseViewController getControllerWithFuncsBean:fb realSubFuncsBean:showHomePageFuncs] ;
        control.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:control animated:YES];
    }
    
}

- (void)setUpViews {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    scrollView.autoresizesSubviews = NO;
    self.scrollView = scrollView;
    //    scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];
   
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(beginRefreshData)];
    header.automaticallyChangeAlpha = YES;
    self.scrollView.mj_header = header;
    

    self.noticeView = [[WSMainNoticeView alloc] init];
    [self.scrollView addSubview:self.noticeView];
    [self.noticeView setHidden:YES];
    
    if (!self.controllerArray) {
        self.controllerArray = [NSMutableArray arrayWithCapacity:self.currentFuncs.funcsArray.count];
    }else {
        [self.controllerArray removeAllObjects];
    }
    
    for (NSInteger i = 0; i < self.currentFuncs.funcsArray.count; i++) {
        WSFuncsBean *funcBean = self.currentFuncs.funcsArray[i];
        NSString *className = [WSPlistHelper valueForKey:funcBean.fv withPlistName:kControllerMappingFileName];
        LogInfo(@"Going to init class: %@",className);
        WCBaseViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:funcBean];
       
        
        if (vc) {
            vc.ownParentViewController = self;
            
            [self addChildViewController:vc];
            
            if ([vc isKindOfClass:[WSReportFormController class]]) {
                ((WSReportFormController *)vc).isInContainerView = YES;
                ((WSReportFormController *)vc).delegate = self;
            }
            [scrollView addSubview:vc.view];
            
            [self.controllerArray addObject:vc];
            
            if ([funcBean.fv isEqualToString:kTopMsgFV] || [funcBean.fv isEqualToString:kSalesInfoFV] ) {
                self.isSetOffset = YES;
            }
            
        }
    }
    [self checkStoreHaveNotLeave];
}


- (void)resetViewsFrame {
    CGFloat originY = 0;
    CGFloat height = originY;
    //    YIHAIKERRY-2089
    //    SFA 益海嘉里深圳【ios】首页banner图片没有置顶，状态栏有行白条（如图）
    WCBaseViewController* vc = [self.controllerArray firstObject];
    //   MMSH-3265 【SFA 玛氏中国MWC（iOS）】首页未离店门店通知与手机模块重叠
    if (!self.noticeView.hidden && (![vc.currentFuncs.fv isEqualToString:kTopMsgFV])) {
        height = MAIN_NOTICE_HEIGHT;
    }
    CGFloat originNoticeY = originY;

  
    for (NSInteger i = 0; i < self.controllerArray.count; i++) {

        WCBaseViewController* vc = self.controllerArray[i];
    
        CGFloat viewHeight = [vc contentHeight];
       
        // YIHAIKERRY-2070 安卓没有添加最后一个报表增加高度的逻辑所以屏蔽下面逻辑
        /*
        // MENGNIU-1825 SFA-15491 当报表等在最后一个位置的时候计算出当前页面剩余位置放报表
        if (i == self.controllerArray.count - 1 &&
            ([vc isKindOfClass:[WSReportFormController class]]  || [vc isKindOfClass:[WSHorizontalPageViewController class]])) {
            CGFloat blankHeight = self.scrollView.height - height - viewHeight;
            if (blankHeight > 0) {
                viewHeight += blankHeight;
            }
        }
        */
        
        
        CGFloat padding = MAIN_CELL_PADDING;
        if ([vc.currentFuncs.fv isEqualToString:kTopMsgFV] || [vc.currentFuncs.fv isEqualToString:kSalesInfoFV] || [vc.currentFuncs.fv isEqualToString:kCircleInfoFV] || [vc.currentFuncs.fv isEqualToString:kkWorkBenchFV]) {
            padding = 0;
        }
        
        vc.view.frame = CGRectMake(padding, height, self.view.width - 2 * padding, viewHeight);
        height += viewHeight;
        
        if (![vc.currentFuncs.fv isEqualToString:kTopMsgFV]) { //公告信息下面不需要gap
            if ((![vc.currentFuncs.fv isEqualToString:kMainMvListFV])) {
                [self setCornerRadiusAndShadowToView:vc.view withTag:(kBaseTagShadow + i)];
            }
        } else {
            // 公告信息
            if (!self.noticeView.hidden) {
                // noticeView 需要放到公告信息下面
                originNoticeY = height;
                originY += MAIN_NOTICE_HEIGHT;
                height += MAIN_NOTICE_HEIGHT;
            }
            
            originY += kViewGap;
        }
        
        height += kViewGap;
    }
    
    if (!self.noticeView.hidden) {
        self.noticeView.frame = CGRectMake(0, originNoticeY, self.view.width, MAIN_NOTICE_HEIGHT);
    }
    
    self.scrollView.contentSize = CGSizeMake(self.view.width, height);
}

// MSTD-7279 逻辑应该是为了报表写的，但是现在报表已经没有问题了，先屏蔽 如果有问题再打开，没有问题以后可以删除
//- (void)offsetView {
//    //MSTD-4865 MSTD-4899 仅当isHideTitle 且不存在 Banner 时需要偏移状态栏高度
//    if (!self.isSetOffset && isFirstLoad) {
//        [super offsetView];
//    }
//}

- (void)checkStoreHaveNotLeave {
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (!inOutStoreObj) {
        if (!self.noticeView || self.noticeView.hidden) {
            return;
        }
        [self.noticeView setHidden:YES];
        [self resetViewsFrame];
        return;
    }
    
    [self.noticeView setNotLeaveStore:inOutStoreObj];

    if (self.noticeView.hidden) {
        [self.noticeView setHidden:NO];
        [self resetViewsFrame];
    }
    
}


- (void)beginRefreshData {
    self.view.userInteractionEnabled = NO;
    self.navigationController.view.userInteractionEnabled = NO;
//    MMSH-3021 董宏添加获取实时公告信息
    [self updateNoticeInfoRequestStart];
    [self.refreshService beginRefreshData];
}

// 信息中心定时更新公告信息
- (void)updateNoticeInfo {
    // to do something
    @autoreleasepool {
        id  interval = [[NSUserDefaults standardUserDefaults] objectForKey:POA_NOTIFICATION_INTERVAL];
        NSTimeInterval timeInterval = 30;
        if (interval && ([interval isKindOfClass:[NSString class]] || [interval isKindOfClass:[NSNumber class]])) {
            timeInterval = [interval   intValue];
        }
        self.noticeTimer = [NSTimer  timerWithTimeInterval:timeInterval*60.0f  target:self selector:@selector(updateNoticeInfoRequestStart) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.noticeTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop]  run];
    }
}

- (void)updateNoticeInfoRequestStart {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNoticeInfoFinished:)
                                                 name:@"updataMassage"
                                               object:nil];
    [[WSRequestHelper shareInstance]  postRequestMSGWithType:@""];
}
- (void)updateNoticeInfoFinished:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updataMassage" object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        //        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        //        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        NSDictionary *uploadState = [info objectFromJSONString];
        NSArray *array = [uploadState objectForKey:MSGS];
        
        if (array.count && array.count > 0)
        {
            [[WSBaseMsgTypeTable sharedTable] deleteAll];
            [[WSBaseMsgTable sharedTable] deleteAll];
            WSBaseMsgTypeDBService * dbSeevice = [[WSBaseMsgTypeDBService alloc] init];
            [dbSeevice replaceToTableWithDicts:array FromNode:MSGS hasNewData:YES];
            [self reloadFunTipCount];
        }
    }
}

- (void)setCornerRadiusAndShadowToView:(UIView *)view withTag:(NSInteger)tag  {
    UIView *shadowView = [self.scrollView viewWithTag:tag];
    if (shadowView) {
        shadowView.frame = view.frame;
        shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:kShadowCornerRadius].CGPath;
        view.frame = view.bounds;
        return;
    }
    
    view.layer.cornerRadius = kShadowCornerRadius;
    view.layer.masksToBounds = YES;
    
    shadowView = [[UIView alloc]initWithFrame:view.frame];
    shadowView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 3);
    shadowView.layer.shadowOpacity = 0.5;
    shadowView.layer.shadowRadius = kShadowCornerRadius;
    shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds cornerRadius:kShadowCornerRadius].CGPath;

    
    shadowView.clipsToBounds = NO;
    shadowView.tag = tag;
    
    [self.scrollView insertSubview:shadowView belowSubview:view];
    
    view.frame = view.bounds;
    [shadowView addSubview:view];
}

- (void)reloadFunTipCount {
    
    for (UIViewController *con in self.controllerArray) {
        if ([con isKindOfClass:[WSCollectionMVListViewController class]]) {
            [(WSCollectionMVListViewController *)con reloadView];
            break;
        }
    }
}

#pragma mark - WSReportFormControllerDelegate
- (void)resetFrame {
    [self resetViewsFrame];
}

@end
