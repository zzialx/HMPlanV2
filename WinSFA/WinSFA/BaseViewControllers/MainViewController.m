//
//  MainViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#define GEONOTIFY  @"geo_notify"

#import "MainViewController.h"
#import "WSAppData.h"
#import "WSFuncsBeanArray.h"
#import "WSFuncsBean.h"
#import "WSMsgViewController.h"
#import "WSCustomerVistViewController.h"
#import "WSInfoSearchViewController.h"
#import "WSManagersVisitViewController.h"
#import "WSSpecialAcvtListViewController.h"
#import "WSAppDelegate.h"
#import "WSGPSUpload.h"
#import "WSRequestHelper.h"
#import "WSNeighborStoreController.h"
#import "JSBadgeView.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSCurrentTime.h"
#import "WSAppSettingViewController.h"
#import "WSPlistHelper.h"
#import "WSOffLineUploadTable.h"
#import "WSInoutStoreTable.h"
#import "WSEmpinforefreshBeanArray.h"
#import "MJRefresh.h"
#import "WSMyMsgViewController.h"
#import "WSLoginDataProcessService.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSDetalViewController.h"
#import "SDCycleScrollView.h"
#import "WSReportFormController.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSTestTools.h"
#import "WSManuallyUploadViewController.h"
#import "WSTopBannerCycleScrollView.h"
#import "WSLampText.h"
#import "WSMainNoticeView.h"
#import "WSMyMsgAcvtListViewController.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSMJProgressHeader.h"
#import "WSOnlineConsultationService.h"
#import "WSFuncTipDBService.h"

#define kCellHeight                 106
#define systemVersion               [[UIDevice currentDevice]systemVersionByFloat]
#define k_BaseViewTag               100
#define k_ButtonOfCellViewBaseTag   1000
#define kURLretrievePassword        (@"/retrievePass/retrievePassword.jsp?")

@interface MainViewController () {}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger noticeIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) WSFuncsBean *feedbackFuncsBean;
@property (nonatomic, strong) NSThread *noticeThread;
@property (nonatomic, strong) NSArray *topMsgBeanArray;
@property (nonatomic, strong) NSDictionary *fcAcvtUnReadCountDic;
@property (nonatomic, strong) UIView *mainCellView;
@property (nonatomic, strong) WSMainNoticeView *noticeView;
@property (nonatomic, strong) NSMutableArray *mainCellViewMArray;

@end

@implementation MainViewController
@synthesize iGPSUpload = _iGPSUpload;
@synthesize remindHasShown = _remindHasShown;
@synthesize geoHasUpdated = _geoHasUpdated;
@synthesize currentCellView = _currentCellView;
@synthesize scrollView = _scrollView;

#pragma mark - 重写initWithNibName:bundle:方法
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - 重写didReceiveMemoryWarning方法
- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mainCellViewMArray = [[NSMutableArray alloc] init];
    
    [self setUpRefreshService];
    [self setUpViews];
    [self offlineLoginRefresh];
}

- (void)offlineLoginRefresh {
    
    WSLoginDataProcessService *loginService = [[WSLoginDataProcessService alloc] init];
    if ([loginService isOfflineLoginWhenLaunchNeedRefresh]) {
        [self beginRefreshData];
    }
}

- (void)setUpViews {
    
    self.view.multipleTouchEnabled = NO;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    UIImage *bg_image;
    bg_image = [UIImage imageNamed:@"main_bg.png"];
    self.view.layer.contents = (id)bg_image.CGImage;
    
    NSMutableArray *funcArray = [self getCurrentFuncsArray];
    NSInteger count = [funcArray count];

    _cellCount = count;
 
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.bounces = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markBadgeForMessage) name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
    
    WSMJProgressHeader *header = [WSMJProgressHeader headerWithRefreshingTarget:self refreshingAction:@selector(beginRefreshData)];
    header.automaticallyChangeAlpha = YES;
    self.scrollView.mj_header = header;
    
    self.noticeView = [[WSMainNoticeView alloc] init];
    [self.scrollView addSubview:self.noticeView];
    [self.noticeView setHidden:YES];
    
    CGFloat originY = 0;
    if (!self.currentFuncs) {
        
        CGFloat topMsgViewHeight = self.view.width * k_TopMsgViewWHRatio;
        WSTopBannerCycleScrollView *topBannerCycleScrollView = [[WSTopBannerCycleScrollView alloc] initWithFrame:CGRectMake(0, originY, self.view.width, topMsgViewHeight) withUseTitle:YES];
        if (topBannerCycleScrollView) {
            
            [self.scrollView addSubview:topBannerCycleScrollView];
            originY += topMsgViewHeight;
        }
    }
    
    NSString *columnString = [[NSUserDefaults standardUserDefaults] objectForKey:HOMEPAGE_COLUMNS];
    if (columnString && columnString.length > 0) {
        _cellColumns = [columnString integerValue];
    }
    else {
        if (count > 6 || (originY > 0 && count > 4)) {
            _cellColumns = 3;
            
        } else {
            _cellColumns = 2;
        }
    }
    
    _cellRows = count / _cellColumns + (count % _cellColumns > 0 ? 1 : 0);
    CGFloat width = SCREEN_WIDTH / _cellColumns;
    CGFloat height = kCellHeight;
    CGFloat paddingY = 0;
    self.mainCellView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.view.width, _cellRows * height)];
    [self.scrollView addSubview:self.mainCellView];
    
    [self.mainCellViewMArray removeAllObjects];
    
    CGFloat borderWidth = 1;
    for (int i = 0 ; i < count ; i++) {
        
        CGFloat offsetX = width * (i % _cellColumns);
        CGFloat offsetY = paddingY * (i / _cellColumns + 1) + height * (i / _cellColumns);
        CGRect tempRect = CGRectMake(offsetX, offsetY, width, height);
        WSMainCellView *cellView = [[WSMainCellView  alloc] initWithFrame:tempRect tag:i+k_BaseViewTag superColumns:_cellColumns];
        cellView.delegate = self;
        NSString *nameString = [NSString stringWithFormat:@"%@.png",[[funcArray objectAtIndex:i] fv]];
        UIImage *img = [UIImage imageNamed:nameString];
        WSFuncsBean* fb = [funcArray objectAtIndex:i];
        UIImage *UnselectedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_tabBar_unselected_server.png",fb.icon]];
        
        if (UnselectedImage) {
            [cellView.iconImageView setImage:UnselectedImage];
        }
        else {
            if (fb.icon.length>0) {
                NSString * imageUrl = [WSHttpURLHelper getImageCompleteURL:fb.icon];
                [[WSRequestHelper shareInstance] downloadImageWithUrl:imageUrl imageView:cellView.iconImageView placeholderImage:img];
            }else{
                [cellView.iconImageView setImage:img];
            }
        }
        
        cellView.label.text = fb.name;
        
        if (fb.opt.menuBgColor.length > 0) {
            cellView.backgroundColor = [UIColor colorWithHexString:fb.opt.menuBgColor];
            borderWidth = 5;
        }
        
        [self.mainCellView addSubview:cellView];
        [self.mainCellViewMArray addObject:cellView];
    }
    
    [self setupBorderBySize:CGSizeMake(width, height) lineWidth:borderWidth];
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, originY + paddingY + _cellRows * height)];
    
    NSString *isPushInfomation = [[NSUserDefaults standardUserDefaults] objectForKey:INFORMATION_PUSH];
    if ([isPushInfomation isEqualToString:@"1"]) {
        
        [self updateNoticeInfoRequestStart];
        self.noticeThread = [[NSThread alloc]initWithTarget:self selector:@selector(updateNoticeInfo) object:nil];
        [self.noticeThread start];
    }

    [self startFeedBackService];
    [self checkStoreHaveNotLeave];
}

- (void)refreshMainCellViewImageWithFuncsBean:(WSFuncsBean *)fb {
    
    NSMutableArray *funcArray = [self getCurrentFuncsArray];
    NSInteger fbIndex = -1;
    for (NSInteger i = 0; i < funcArray.count; i++) {
        
        WSFuncsBean *funcsB=[funcArray objectAtIndex:i];
        if ([fb isEqual:funcsB]) {
            fbIndex = i;
            break;
        }
    }
    
    WSMainCellView *cellView = [self.mainCellViewMArray objectAtIndex:fbIndex];
    UIImage *UnselectedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"%@_tabBar_unselected_server.png",fb.icon]];
    [cellView.iconImageView setImage:UnselectedImage];
    if (fb.opt.menuBgColor.length > 0) {
        cellView.backgroundColor = [UIColor colorWithHexString:fb.opt.menuBgColor];
    }
}

- (void)setupBorderBySize:(CGSize)size lineWidth:(CGFloat)lineWidth {
    
    for(int i = 0 ; i < _cellRows ; i++){
        for (int j = 0 ; j < _cellColumns; j++) {
            
            CGRect rect = CGRectMake(j * size.width, i * size.height , size.width, size.height);
            CALayer *topLayer = [[CALayer alloc] init];
            topLayer.frame = CGRectMake(rect.origin.x, CGRectGetMinY(rect), rect.size.width, lineWidth);
            topLayer.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
            [self.mainCellView.layer addSublayer:topLayer];
            
            if (j != 0) {
                CALayer *leftLayer = [[CALayer alloc] init];
                leftLayer.frame = CGRectMake(rect.origin.x, rect.origin.y, lineWidth, rect.size.height);
                leftLayer.backgroundColor = DETAIL_SEPERATE_LINE_COLOR.CGColor;
                [self.mainCellView.layer addSublayer:leftLayer];
            }
        }
    }
}

- (void)checkStoreHaveNotLeave {
    
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (!inOutStoreObj) {
        
        if (!self.noticeView || self.noticeView.hidden) {
            return;
        }
        [self resetNoticeViewsByIsHidden:YES];
        return;
    }
    
    if (self.noticeView.hidden) {
        
        [self.noticeView setFrame:CGRectMake(0, CGRectGetMinY(self.mainCellView.frame), self.view.width, MAIN_NOTICE_HEIGHT)];
        [self resetNoticeViewsByIsHidden:NO];
    }
    [self.noticeView setNotLeaveStore:inOutStoreObj];
}

- (void)resetNoticeViewsByIsHidden:(BOOL)isHidden {
    
    CGRect mainFrame = self.mainCellView.frame;
    CGSize scrollSize = self.scrollView.contentSize;
    CGFloat scrollHeight;
    if (isHidden) {
        mainFrame.origin.y -= MAIN_NOTICE_HEIGHT;
        scrollHeight = scrollSize.height - MAIN_NOTICE_HEIGHT;
    }
    else {
        mainFrame.origin.y += MAIN_NOTICE_HEIGHT;
        scrollHeight = scrollSize.height + MAIN_NOTICE_HEIGHT;
    }
    self.mainCellView.frame = mainFrame;
    [self.scrollView setContentSize:CGSizeMake(scrollSize.width, scrollHeight)];
    [self.noticeView setHidden:isHidden];
}

- (void)setUpRefreshService {
    
    self.refreshService = [[WSRefreshLoginHttpService alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    self.refreshService.endRefreshBlock = ^(WSRefreshLoginStatus status) {
        
        [weakSelf.scrollView.mj_header endRefreshing];
        
        if (status == WSRefreshLoginStatusSuccess) {
            [weakSelf.view removeAllSubviews];
            [weakSelf setUpViews];
            [weakSelf markBadgeForMessage];
        }

        weakSelf.view.userInteractionEnabled = YES;
        weakSelf.navigationController.view.userInteractionEnabled = YES;
    };
    
    self.refreshService.progressBlock = ^(NSInteger progress) {
        
        WSMJProgressHeader *header = (WSMJProgressHeader *)weakSelf.scrollView.mj_header;
        [header setLoadingProgress:progress];
    };
}

- (void)beginRefreshDataFromNewMessage {
    
    [self.scrollView.mj_header beginRefreshing];
}

- (void)modifyPasswd:(id)sender{
    
}

- (void)viewWillAppear:(BOOL)animated {
    
  [super viewWillAppear:animated];
    
   UIWindow *w = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    for (UIView *view in w.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView=(UIImageView *)view;
            imageView.image=nil;
        }
    }
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;

    //添加关于
    UIButton* aboutButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [aboutButton addTarget:self action:@selector(aboutsoftware:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *aboutItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    self.navigationItem.rightBarButtonItems = @[aboutItem];
    
    //注销
     UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"exit_account", nil) style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItems = @[logoutItem];
    if (INTERFACE_IS_PHONE) {
        
        CGFloat w = [self.title ws_sizeWithFont:[UIFont fontWithName:@"Arial" size:18] constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping].width;
        if(w > 200){
           [self showNavTitle:self title:self.title width:self.view.bounds.size.width];
        }
    }
    
    [self checkStoreHaveNotLeave];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)aboutsoftware:(id)aSender {
    
    WSAppSettingViewController *setting = [[WSAppSettingViewController alloc] initAppSetting];
    [self.navigationController pushViewController:setting animated:YES];
}

- (NSInteger)markBadgeForMessage {
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    self.fcAcvtUnReadCountDic = [service getFuncCodeAndAcvtDataReadCount];
    
    NSInteger unReadMessageCount = 0;
    NSInteger unUploadCount = 0;
    NSMutableArray *arrayForMessage = nil;
    NSMutableArray * funcArray = [self getCurrentFuncsArray];

    for (int i = 0; i < [funcArray count]; i++) {
        
        WSFuncsBean* fb = [funcArray objectAtIndex:i];
        if ([fb.fv isEqualToString:@"TB_V10"] || [fb.fv isEqualToString:@"TB_V12"]) {
            
            if ([fb.fv isEqualToString:@"TB_V10"]) {
                self.noticeIndex = i;
            }
            
            if ([fb.fv isEqualToString:@"TB_V12"]) {
                 self.noticeIndex = i;
            }
            
            WSMsgBeanArray *messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
            for (int j = 0; j < [messageArray.msgArray count]; j++) {
                
                WSMsgsBean *msgsB=[messageArray.msgArray objectAtIndex:j];
                if ([msgsB.name isEqualToString:@"总裁致词"]) {
                    [messageArray.msgArray  removeObjectAtIndex:j];
                }
            }

            NSMutableString *str = [NSMutableString stringWithCapacity:0];
            for (NSInteger j = 0 ; fb.funcsArray.count > j ; j++) {
                
                WSFuncsBean* fbNew = fb.funcsArray[j] ;
                if (fbNew.filter.length > 0) {
                    
                    NSString *strDecollator = @"";
                    if (str.length > 0) {
                       strDecollator = @",";
                    }
                    [str appendString:[NSString stringWithFormat:@"%@%@",strDecollator,fbNew.filter]];
                }
            }
            
            NSArray *msgsArray = nil;
            if (str != nil && [str length] > 0) {
                msgsArray = [messageArray getMsgsBeansWithFilter:str];
            }
            
            if (msgsArray != nil) {
                arrayForMessage = [NSMutableArray arrayWithArray:msgsArray];
            }
            else{
                arrayForMessage = [NSMutableArray arrayWithArray:messageArray.msgArray];
            }

            int m = 0;
            BOOL bFlag = NO;
            BOOL bNew = NO;
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
            NSDictionary *msgInfoDic = [user dictionaryForKey:kWSMessageDomainName];
            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            NSString *empid = [msgInfoDic objectForKey:kWSMessageEmpId];
            
            if (msgInfoDic != nil && (empid != nil && [empid isEqualToString:empId])) {
                
                NSString *date = [msgInfoDic objectForKey:kWSMessageBizDate];
                if (date != nil && ![date isEqualToString:bizDate]) {
                    
                    [user removeObjectForKey:kWSMessageDomainName];
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
                    if (bizDate) {
                        [dic setObject:bizDate forKey:kWSMessageBizDate];
                    }
                    
                    if (empId) {
                        [dic setObject:empId forKey:kWSMessageEmpId];
                    }
                    [user setObject:dic forKey:kWSMessageDomainName];
                    [user synchronize];
                    bNew = YES;
                }
                else {
                    bNew = NO;
                }
                bFlag = YES;
            }
            else {
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
                if (bizDate) {
                    [dic setObject:bizDate forKey:kWSMessageBizDate];
                }
                
                if (empId) {
                    [dic setObject:empId forKey:kWSMessageEmpId];
                }
                [user setObject:dic forKey:kWSMessageDomainName];
                [user synchronize];
                bNew = YES;
            }
            
            for (WSMsgsBean *aMsg in arrayForMessage) {
                
                for (WSMsgsBean_msg *msg in aMsg.msg) {
                    
                    NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
                    if (bFlag) {
                        if (bNew) {
                            
                            if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                                
                                NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                                NSMutableDictionary *infodic = [NSMutableDictionary dictionaryWithDictionary:dic];
                                [infodic setObject:[NSNumber numberWithBool:YES] forKey:key];
                                [user setObject:infodic forKey:kWSMessageDomainName];
                                [user synchronize];
                            }
                        }
                        else {
                            
                            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                            id obj = [dic objectForKey:key];
                            if (obj == nil && [msg.isread isEqualToString:@"0"]) {
                                ++m;
                            }
                        }
                    }
                    else {
                        
                        if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                            NSMutableDictionary *infodic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [infodic setObject:[NSNumber numberWithBool:YES] forKey:key];
                            [user setObject:infodic forKey:kWSMessageDomainName];
                            [user synchronize];
                        }
                        else {
                            ++m;
                        }
                    }
                }
            }
            
            unReadMessageCount = m;
            if (m > 0) {
                [self addBadgeToMainCellAtIndex:i badge:m];
            }
            else {
                [self removeMainCellBadgeAtIndex:i];
            }
        }
        else if ([fb.fv isEqualToString:@"TB_V180"]) {
            
            NSInteger pending = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
            unUploadCount = pending;
            if (pending > 0) {
                [self addBadgeToMainCellAtIndex:i badge:pending];
            }
            else {
                [self removeMainCellBadgeAtIndex:i];
            }
        }
        else if ([fb.fv isEqualToString:@"TB_V20"] || [fb.fv isEqualToString:@"TB_V110"]) {
            
            BOOL pending = NO;
            WSInoutStoreObject *l_store = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
            pending = [self anyStoreHasNotLeave:fb notLeaveStoreFc:l_store.func_code];
            if (pending) {
                [self addBadgeToMainCellAtIndex:i text:@"!"];
            }
            else {
                [self removeMainCellBadgeAtIndex:i];
            }
        }
        else if ([fb.fv isEqualToString:@"TB_ATT_REMIND"]) {
            
            NSArray *filtedData;
            for (WSFuncsBean *subFuncsBean in fb.funcsArray) {
                
                if ([subFuncsBean.fv isEqualToString:@"TAB_V7001"]) {
                    WSEmpinforefreshBeanArray *emprefreshBeans = [WSAppData getObjectbyKey:subFuncsBean.ds];
                    filtedData = [emprefreshBeans getEmpinforefreshsWithFilter:subFuncsBean.filter];
                    break;
                }
            }
            
            NSInteger pending = [filtedData count];
            if (pending > 0) {
                [self addBadgeToMainCellAtIndex:i badge:pending];
            }
            else {
                [self removeMainCellBadgeAtIndex:i];
            }
        }
        else {
            
            NSNumber *unReadCount = [self.fcAcvtUnReadCountDic objectForKey:fb.fc];
            if ([unReadCount integerValue] > 0) {
                [self addBadgeToMainCellAtIndex:i badge:[unReadCount integerValue]];
            }
            else{
                [self removeMainCellBadgeAtIndex:i];
            }
        }
      
        NSString *badgeStr =  [WSFuncTipDBService queryTipWithFuncCode:fb.fc andEmpId:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        NSInteger pending = [badgeStr integerValue];
        if (pending > 0) {
            [self addBadgeToMainCellAtIndex:i badge:pending];
        }
    }
    return unReadMessageCount + unUploadCount;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
}

- (BOOL)anyStoreHasNotLeave:(WSFuncsBean *)fb notLeaveStoreFc:(NSString *)fc {
    
    if ([fb.fc isEqualToString:fc]) {
        return YES;
    }
    
    for (WSFuncsBean *subFb in fb.funcsArray) {
        
        if ([subFb.fc isEqualToString:fc]) {
            return YES;
        }
        
        return [self anyStoreHasNotLeave:subFb notLeaveStoreFc:fc];
    }
    return NO;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil)  tips:nil tapTarget:self action:nil];
    [self performSelector:@selector(refreshBadgeMessage) withObject:nil afterDelay:0.1];
    
    NSString *geoVersion = [WSAppData getObjectbyKey:GEOVERSION];
    if (!self.geoHasUpdated && geoVersion && [geoVersion length] > 0) {
        self.geoHasUpdated = YES;
        [self updateGeoVersion];
    }
    
    NSArray *remindArray = [WSAppData getObjectbyKey:TASKREMIND];
    if (!self.remindHasShown && remindArray) {
        self.remindHasShown = YES;
        [self performSelector:@selector(showTaskRemind) withObject:nil afterDelay:1.0f];
    }
    
//    if ([WSAppData sharedManager].showHomePage) {
//        return;
//    }
//    
//    [WSAppData sharedManager].showHomePage = YES;
//    WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
//    NSDictionary *showFuncsDict = [fba getShowFuncsBean];
//    if ([[showFuncsDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
//        
//        [self pushViewWithFuncsBean:[showFuncsDict objectForKey:FROM_FUNCS_BEAN] realSubFuncsBean:[showFuncsDict objectForKey:SHOW_FUNCS_BEAN]];
//    }
    
}

- (void)refreshBadgeMessage {
    
    [self markBadgeForMessage];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
}

- (void)updateGeoVersion {
    
    BOOL shouldUpdate = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentLibraryFolderPath = [documentsDirectory stringByAppendingPathComponent:@"CityData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentLibraryFolderPath]) {
        shouldUpdate = YES;
    }
    
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"geoVersion"];
    NSString *serviceVersion = [WSAppData getObjectbyKey:GEOVERSION];
    if (nil == currentVersion) {
        shouldUpdate = YES;
    }
    else if ([currentVersion compare:serviceVersion options:NSNumericSearch] == NSOrderedAscending) {
        shouldUpdate = YES;
    }
    
    if (shouldUpdate) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geoUpdated:) name:GEONOTIFY object:nil];
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        [uploadMgr appUpdateGeoDataWithEmpId:empId notifyName:GEONOTIFY];
    }
}

- (void)geoUpdated:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GEONOTIFY object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error != 0) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip", nil)  tips:nil tapTarget:self action:nil];
    NSDictionary *dic = [info objectFromJSONString];
    [NSThread detachNewThreadSelector:@selector(processGeoData:) toTarget:self withObject:dic];
}

- (void)updateFinished {
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:YES];
}

- (void)processGeoData:(NSDictionary *)dic {
    
    @autoreleasepool {
        
        NSArray *provinceArray = [dic objectForKey:@"geography"];
        if (provinceArray != nil) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *documentLibraryFolderPath = [documentsDirectory stringByAppendingPathComponent:@"CityData"];
            [provinceArray writeToFile:documentLibraryFolderPath atomically:YES];
        }
        
        [self performSelectorOnMainThread:@selector(updateFinished) withObject:nil waitUntilDone:NO];
        [[NSUserDefaults standardUserDefaults] setObject:[WSAppData getObjectbyKey:GEOVERSION] forKey:@"geoVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)showTaskRemind {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb {
    
    [self pushViewWithFuncsBean:fb realSubFuncsBean:nil];
}

#pragma mark - 跳转视图管理器方法
- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean {
    
    if ([fb.name isEqualToString:@"在线客服"] || [fb.name isEqualToString:@"在线咨询"]) {
        
        WSFuncsBean *onlineConsultationFB = [self getOnlineConsultationFuncsBeanWithParentFuncsBean:fb];
        WSOnlineConsultationService *onlineConsultationService = [WSOnlineConsultationService shareInstance];
        [onlineConsultationService gotoNextOnlineConsultationReportFormViewControllerWithOnlineConsultationString:onlineConsultationFB.filter];
    }
    else {
        
        WCBaseViewController *vc = [WCBaseViewController getControllerWithFuncsBean:fb realSubFuncsBean:realSubFuncsBean];
        vc.hidesBottomBarWhenPushed = YES;
        if (vc) {
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            [self showWrongMessage:vc];
        }
    }
}

- (WSFuncsBean *)getOnlineConsultationFuncsBeanWithParentFuncsBean:(WSFuncsBean *)parentFuncsBean {
    
    WSFuncsBean *resultFuncsBean = nil;
    if (parentFuncsBean.funcsArray && parentFuncsBean.funcsArray.count > 0) {
        
        for (WSFuncsBean *fb in parentFuncsBean.funcsArray) {
            if ([fb.fv isEqualToString:@"FV_mobile_report"] && ([fb.name isEqualToString:@"在线客服"] || [fb.name isEqualToString:@"在线咨询"])) {
                resultFuncsBean = fb;
                break;
            }
        }
        
        if (!resultFuncsBean) {
            
            for (WSFuncsBean *fb in parentFuncsBean.funcsArray) {
                resultFuncsBean = [self getOnlineConsultationFuncsBeanWithParentFuncsBean:fb];
                if (resultFuncsBean)
                    break;
            }
            
            if (!resultFuncsBean) {
                resultFuncsBean = parentFuncsBean;
            }
        }
    }
    
    return resultFuncsBean;
}

- (void)showWrongMessage:(UIViewController*)vc {

    if (vc == nil) {
        
        NSString *NODataString = NSLocalizedString(@"acvt_type_empty_label",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
 
- (void)logout {
    
    UIViewController *viewController = [self checkNotUploadData];
    if (viewController && [viewController isKindOfClass:[WSManuallyUploadViewController class]]) {
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        NSString *NODataString = NSLocalizedString(@"homepage_unupload_recommendation",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"exit_app_prompt", nil)];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
            
            if ([self.noticeTimer isValid]) {
                [self.noticeTimer invalidate];
                self.noticeTimer = nil;
            }

            if (![self.noticeThread isCancelled] ) {
                [self.noticeThread cancel];
            }
        }];
        [alert show];
    }
}

- (UIViewController *)checkNotUploadData {
    
    WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
    NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
    NSMutableArray * funcArray = [self getCurrentFuncsArray];

    if (pending > 0) {
        
        WSFuncsBean *funcsBean;
        for (WSFuncsBean *fb in funcArray) {
            if ([fb.fv isEqualToString:@"TB_V180"]) {
                funcsBean = fb;
                break;
            }
        }
        
        WSManuallyUploadViewController *manullyUploadController;
        if (funcsBean) {
            manullyUploadController = [[WSManuallyUploadViewController alloc] initWithFuncs:funcsBean];
        }
        else{
            manullyUploadController = [[WSManuallyUploadViewController alloc] init];
        }
        manullyUploadController.isInCheckUploadedDataFlow = YES;
        
        return manullyUploadController;
    }
    return nil;
}

#pragma mark -ActionSheet Delegate Methods
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
        if (![self.noticeThread isCancelled]) {
            [self.noticeThread cancel];
        }
        if ([self.noticeTimer isValid]) {
            [self.noticeTimer invalidate];
            self.noticeTimer = nil;
        }
    }
}

#pragma mark - WSMainCellViewDelegate Methods
- (void)cellView:(WSMainCellView *)cellView touchBegin:(NSInteger)viewTag {
    
    [self addNotificationWhenAppEnterBackgroud];
    self.currentCellView = cellView;
}

- (void)cellView:(WSMainCellView *)cellView touchEnd:(NSInteger)viewTag {

    NSMutableArray *funcArray = [self getCurrentFuncsArray];
    WSFuncsBean* fb = [funcArray objectAtIndex:viewTag - k_BaseViewTag];
    [self pushViewWithFuncsBean:fb];
}

- (void)addNotificationWhenAppEnterBackgroud {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGGE_MAINCELL_STATENORMAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentCellState) name:CHANGGE_MAINCELL_STATENORMAL object:nil];
}

- (void)changeCurrentCellState {
    
    [self.currentCellView changeBackgroundNormal];
}

- (void)resetNoticeInfoBadge:(NSArray *)msgArray {
    
    int m = 0;
    BOOL bFlag = NO;
    BOOL bNew = NO;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSDictionary *msgInfoDic = [user dictionaryForKey:kWSMessageDomainName];
    if (msgInfoDic != nil) {
        
        NSString *date = [msgInfoDic objectForKey:kWSMessageBizDate];
        if (date != nil && ![date isEqualToString:bizDate]) {
            
            [user removeObjectForKey:kWSMessageDomainName];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
            [dic setObject:[NSString stringNotNilWithValue:bizDate] forKey:kWSMessageBizDate];
            [user setObject:dic forKey:kWSMessageDomainName];
            [user synchronize];
            bNew = YES;
        }
        else {
            bNew = NO;
        }
        bFlag = YES;
    }
    else {
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
        if (bizDate) {
            [dic setObject:bizDate forKey:kWSMessageBizDate];
        }
        [user setObject:dic forKey:kWSMessageDomainName];
        [user synchronize];
    }
    
    for (WSMsgsBean *aMsg in msgArray) {
        for (WSMsgsBean_msg *msg in aMsg.msg) {
            
            NSString *key = [NSString stringWithFormat:@"%@#%@#%@", msg.s, msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
            if (bFlag) {
                
                if (bNew) {
                    if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                        NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                        NSMutableDictionary *infodic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [infodic setObject:[NSNumber numberWithBool:YES] forKey:key];
                        [user setObject:infodic forKey:kWSMessageDomainName];
                        [user synchronize];
                    }
                }
                else {
                    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                    id obj = [dic objectForKey:key];
                    if (obj == nil && [msg.isread isEqualToString:@"0"]) {
                        ++m;
                    }
                }
            }
            else {
                
                if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                    NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                    NSMutableDictionary *infodic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [infodic setObject:[NSNumber numberWithBool:YES] forKey:key];
                    [user setObject:infodic forKey:kWSMessageDomainName];
                    [user synchronize];
                }
                else {
                    ++m;
                }
            }
        }
    }
    
    if (m > 0) {
        [self addBadgeToMainCellAtIndex:self.noticeIndex badge:m];
    }
    else {
        [self removeMainCellBadgeAtIndex:self.noticeIndex];
    }
}

- (void)addBadgeToMainCellAtIndex:(NSInteger)index text:(NSString *)text {
    
    id view = [self.view viewWithTag:index+k_BaseViewTag+k_ButtonOfCellViewBaseTag];
    if ([view isKindOfClass:[UIImageView class]]) {
        
        NSArray *views = [view subviews];
        for (UIView *subView in views) {
            if ([subView isKindOfClass:[JSBadgeView class]]) {
                [subView removeFromSuperview];
            }
        }
        
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:view alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = text;
    }
}

- (void)addBadgeToMainCellAtIndex:(NSInteger)index badge:(NSInteger)bCount {
    
    id view = [self.view viewWithTag:index+k_BaseViewTag+k_ButtonOfCellViewBaseTag];
    if ([view isKindOfClass:[UIImageView class]]) {
        
        NSArray *views = [view subviews];
        for (UIView *subView in views) {
            if ([subView isKindOfClass:[JSBadgeView class]]) {
                [subView removeFromSuperview];
            }
        }
        
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:view alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = [NSString stringWithFormat:@"%ld",(long)bCount];
    }
}

- (void)removeMainCellBadgeAtIndex:(NSInteger)index {
    
    id view = [self.view viewWithTag:index+k_BaseViewTag+k_ButtonOfCellViewBaseTag];
    if ([view isKindOfClass:[UIImageView class]]) {
        
        NSArray *views = [view subviews];
        for (UIView *subView in views) {
            if ([subView isKindOfClass:[JSBadgeView class]]) {
                [subView removeFromSuperview];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self changeCurrentCellState];
}

- (void)startFeedBackService {
    
    BOOL startService = NO;
    NSMutableArray * funcArray = [self getCurrentFuncsArray];

    for (WSFuncsBean *funcsBean in  funcArray) {
        if (funcsBean.fv && [funcsBean.fv isEqualToString:@"TB_POA_RETASK"]) {
            startService = YES;
        }
    }
    
    if (startService) {
        WSInfoService *feedbackService = [[WSInfoService alloc] initWith:@"dihonPoaTaskRes" notify:@"MVC_FEEDBACK_REQUEST_NOTIFY"];
        feedbackService.delegate = self;
        [feedbackService  startRequest];
    }
}

- (void)infoService:(WSInfoService *)service feedback:(NSInteger)count {

    NSMutableArray * funcArray = [self getCurrentFuncsArray];
    for (int i = 0; i < [funcArray count]; i++) {
        
        WSFuncsBean *funcsBean = [funcArray objectAtIndex:i];
        if ([funcsBean.fv isEqualToString:@"TB_POA_RETASK"]) {
            if (count > 0) {
                [self addBadgeToMainCellAtIndex:i badge:count];
            }
            else {
                [self removeMainCellBadgeAtIndex:i];
            }
            break;
        }
    }
}

- (NSMutableArray *)getCurrentFuncsArray {

    if (self.currentFuncs) {
        return self.currentFuncs.funcsArray;
    }
    else {
        WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
        return fba.funcsArray;
    }
}

-(void)showNavTitle:(UIViewController *)controller title:(NSString *)title width:(CGFloat) width {
    
    CGFloat w = [title ws_sizeWithFont:[UIFont fontWithName:@"Arial" size:18] constrainedToWidth:CGFLOAT_MAX].width;
    CGFloat x = 0;
    if (w <= width) {
        x = (width - w) / 2;
    }
    
    WSLampText *titleLabel = [[WSLampText alloc]initWithFrame:CGRectMake(x, 0, w, 40)];
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Arial" size:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    [scroll addSubview:titleLabel];
    controller.navigationItem.titleView = scroll;
}

@end

