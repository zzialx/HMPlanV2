//
//  MainViewController_iPad.m
//  WinSFA
//
//  Created by yang on 14-4-21.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//
#define GEONOTIFY  @"geo_notify"
#import "MainViewController_iPad.h"
#import "WSMainLeftView.h"
#import "WSPlistHelper.h"
#import <WCNavigationController.h>
#import "BaseViewController.h"
#import "WSMsgBeanArray.h"
#import "WSFuncsBeanArray.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSInoutStoreTable.h"
#import "MainViewController.h"
#import "WSAppSettingViewController.h"
#import "SuperBarViewController.h"
#import "WSSpecialAcvtViewController.h"
#import "WSAcvtViewController.h"
#import "WSRequestHelper.h"
#import "JFTakeCountButton.h"
#import "WSEmpinforefreshBeanArray.h"
#import "WSMyMsgViewController.h"
#import "WSBaseMsgTypeTable.h"

#import "WSOutsideLinkViewController.h"
#import "WSDownLoadRichMediaController.h"

#import "WSMyMsgAcvtListViewController.h"
#import "WSDetalViewController.h"
#import "WSRevertViewController.h"
#import "WSRichMediaMainController.h"
#import "WSSuggestedTableShowController.h"
#import "WSRichMediaDBService.h"
#import "WSRichMediaMainShowController.h"
#import "WSReportFormController.h"
#import "WSManuallyUploadViewController.h"
#import "WSRefreshLoginHttpService.h"
#import "WSLoginDataProcessService.h"
#import "WSMJProgressHeader.h"
#import "WSMainLeftViewManager.h"
#define kConfirmToChangeFuncsAlertViewTag 2001
#define kConfirmToLogOutAlertViewTag 2002
#define kMarginLeftToBtn 150

#define kURLretrievePassword      (@"/retrievePass/retrievePassword.jsp?")


@interface MainViewController_iPad ()<WSMainLeftViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong)  WSMainLeftView *leftView;

@property (nonatomic, strong)  UIViewController *centerViewController;

@property (nonatomic, strong)  UIViewController *permanentViewController;

@property (nonatomic, assign) BOOL showHomePage;

@property (nonatomic, strong) WSFuncsBean *selectedFuncsBean;

@property (nonatomic, strong) WSFuncsBean *toBeSelectedFuncsBean;

@property (nonatomic, strong) WSFuncsBean *homePageRealSubFuncsBean;

@property (nonatomic, strong) UIButton *logoutButton;
@property (nonatomic, strong) NSThread *noticeThread;

@property (nonatomic, strong) NSMutableArray *navArray;

@property (nonatomic,strong)  UIPopoverController *pop;

@end

@implementation MainViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _showHomePage = YES;
    
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

- (void)setUpViews
{
    self.leftView = [[WSMainLeftView alloc] initWithFrame:CGRectMake(0, 0, kLeftVieWidth, self.view.bounds.size.height-kLeftViewCellHeight)];
    self.leftView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.leftView.delegate = self;
    [self.view addSubview:self.leftView];
    self.leftView.layer.zPosition=100;
    [WSMainLeftViewManager getInstance].mainLeftView = self.leftView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markBadgeForMessage) name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    
    
    UIView* logoutbackView=[[UIView alloc] initWithFrame:CGRectMake(0, self.leftView.bottom , self.leftView.width , kLeftViewCellHeight)];
    
    UIColor *bgColor = [UIColor colorForKey:@"LeftBottomViewBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor lightGrayColor];
    }
    
    logoutbackView.backgroundColor = bgColor;
    
    logoutbackView.layer.zPosition=100;
    logoutbackView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:logoutbackView];
    
    UIButton* logoutButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, logoutbackView.width/2, logoutbackView.height)];
    [logoutButton setImage:[UIImage imageForName:@"logout_btn"] forState:UIControlStateNormal];
    [logoutButton setTitle:NSLocalizedString(@"exit_account", nil) forState:UIControlStateNormal];
    [logoutButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    logoutButton.titleLabel.font=[UIFont boldSystemFontOfSize:UI_LeftView_Font];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [logoutbackView addSubview:logoutButton];
    self.logoutButton = logoutButton;
    
    UIButton* aboutButton=[[UIButton alloc] initWithFrame:CGRectMake(logoutButton.width, 0, logoutbackView.width/2, logoutbackView.height)];
    [aboutButton setImage:[UIImage imageForName:@"about_btn"] forState:UIControlStateNormal];
    [aboutButton setTitle:NSLocalizedString(@"about", nil) forState:UIControlStateNormal];
    [aboutButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [aboutButton addTarget:self action:@selector(aboutsoftware:) forControlEvents:UIControlEventTouchUpInside];
    aboutButton.titleLabel.font=[UIFont boldSystemFontOfSize:UI_LeftView_Font];
    [logoutbackView addSubview:aboutButton];
    // 定时获取公告信息内容
    NSString *isPushInfomation = [[NSUserDefaults standardUserDefaults] objectForKey:INFORMATION_PUSH];
    if ([isPushInfomation isEqualToString:@"1"]) {
        [self updateNoticeInfoRequestStart];
        self.noticeThread = [[NSThread alloc]initWithTarget:self selector:@selector(updateNoticeInfo) object:nil];
        [self.noticeThread start];
    }
    
    self.navArray = [NSMutableArray array];
}

- (void)setUpRefreshService {
    self.refreshService = [[WSRefreshLoginHttpService alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.refreshService.endRefreshBlock = ^(WSRefreshLoginStatus status) {
        
        [weakSelf.leftView endRefreshData];
        
        if (status == WSRefreshLoginStatusSuccess) {
            [weakSelf.view removeAllSubviews];
            [weakSelf setUpViews];
        }
        
        if (status == WSRefreshLoginStatusDisable) {
            // TODO:
//            weakSelf.leftView.userInteractionEnabled = NO;
//            weakSelf.centerViewController.view.userInteractionEnabled = NO;
        }
        
        weakSelf.view.userInteractionEnabled = YES;
        weakSelf.navigationController.view.userInteractionEnabled = YES;
        
        [weakSelf performSelector:@selector(showfb) withObject:nil afterDelay:0.1];
        
    };
    self.refreshService.progressBlock = ^(NSInteger progress) {
        WSMJProgressHeader *header = (WSMJProgressHeader *)weakSelf.leftView.tableView.mj_header;
        [header setLoadingProgress:progress];
    };
}

- (void)modifyPasswd:(id)sender{
    
    
    NSString *findPwdURL = [NSString stringWithFormat:@"%@%@",[WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName],kURLretrievePassword];
    
    WSReportFormController *findPwd = [[WSReportFormController alloc]initWithURL:[NSURL URLWithString:findPwdURL]];
    findPwd.title = NSLocalizedString(@"重置密码", nil);
    [self.navigationController pushViewController:findPwd animated:YES];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)aboutsoftware:(id)aSender{
    
    WSAppSettingViewController *setting = [[WSAppSettingViewController alloc] initAppSetting];
    [self.navigationController pushViewController:setting animated:YES];
}

- (void)logout{
    
    NSInteger pending = [self checkNotUploadData];
    if (pending > 0) {
        WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *funcsBean ;
        for (WSFuncsBean *fb in fba.funcsArray) {
            if ([fb.fv isEqualToString:@"TB_V180"]) {
                funcsBean = fb;
                break;
            }
        }
        BOOL result = [self didSelectFuncsBean:funcsBean];
        if (result ) {
            [self.leftView selectFuncsBean:self.selectedFuncsBean];
            NSString *NODataString = NSLocalizedString(@"homepage_unupload_recommendation",nil);
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
        
    }else{
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"exit_app_prompt", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
        
        [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
            // 退出时停止timer和thread
            if (![self.noticeThread isCancelled] ) {
                [self.noticeThread cancel];
            }
            if ([self.noticeTimer isValid]) {
                [self.noticeTimer invalidate];
                self.noticeTimer = nil;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
            
        }];
        
        [alert show];
    }
}

- (NSInteger )checkNotUploadData{
    WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
    NSInteger pending = [l_leaveStore queryCountWithUploadFlagType:Failed];
    return pending;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];

    //[[NSNotificationCenter defaultCenter] removeObserver:self name:MYMSG_DETAIL_DIDSELECT_MESSAGE object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.navArray removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
     LogTrace();
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    LogTrace();
    [super viewDidAppear:animated];
    
    [self.leftView setArrowImageView];
    
    [self markBadgeForMessage];
    
    if (!_showHomePage)
    {
        return;
    }
    
    NSString *geoVersion = [WSAppData getObjectbyKey:GEOVERSION];
    if (!self.geoHasUpdated && geoVersion && [geoVersion length] > 0)
    {
        self.geoHasUpdated = TRUE;
        [self updateGeoVersion];
    }
    
    _showHomePage = NO;

    WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
    NSDictionary *showFuncsDict = [fba getShowFuncsBean];
    if ([[showFuncsDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
        self.homePageRealSubFuncsBean = [showFuncsDict objectForKey:SHOW_FUNCS_BEAN];
        
        if ([[showFuncsDict objectForKey:MOBILE_HOME_PAGE_READING_TIME] integerValue] > 0) {
            
            WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
            UIViewController *rootViewController = delegate.window.rootViewController;
            __block UIView *coverView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
            [coverView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.1]];
            [rootViewController.view addSubview:coverView];
            
            JFTakeCountButton *durationButton = [JFTakeCountButton initWithCount:[[showFuncsDict objectForKey:MobileHomePageReadingTimeKey] intValue]
                                                                       withTitle:nil
                                                                  withTitleColor:[UIColor clearColor]
                                                                   withTitleFont:[UIFont boldSystemFontOfSize:30.0f]
                                                                       withBlock:^{
                                                                           [coverView removeFromSuperview];
                                                                       }];
            [durationButton startTakeCount];
            [durationButton setFrame:CGRectMake(0, 20, 60, 60)];
            [coverView addSubview:durationButton];
        }
        
        [self.leftView showFuncsBean:[showFuncsDict objectForKey:FROM_FUNCS_BEAN]];
    }else {
        [self.leftView showFuncsBean:[fba.funcsArray firstObject]];
    }
    

    
}

#pragma mark - private methods

/*
- (void)callOtherAPP
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP];
    //    NSString *projectName = [WSPlistHelper valueForKey:@"ProjectName" withPlistName:kConfilgFileName];
    if (!userId) {   userId = @"";    }
    if (!password) {   password = @"";    }
    NSDictionary *dic = @{@"userID": userId, @"password" : password};
    NSMutableString *string = [NSMutableString stringWithString:@"wintrainning://"];
    NSString *json = [dic JSONString];
    [string appendString:[json mk_urlEncodedString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:string]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }
    else
    {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"js_alert_title" message:@"您暂未安装应用PCH eDetailing，请安装后重试"];
        [alert setCancelButtonWithTitle:@"confirm" block:nil];
        [alert show];
    }
}
 */

-(void)showWrongMessage
{
    NSString *NODataString = NSLocalizedString(@"acvt_type_empty_label",nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NODataString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];

}

- (void)setCenterViewController:(UIViewController *)centerViewController
{
    [self performSelector:@selector(_setCenterViewController:) withObject:centerViewController afterDelay:0.01];
}

- (void)_setCenterViewController:(UIViewController *)centerViewController
{
    if (_centerViewController != centerViewController) {
        if (_centerViewController) {
            [_centerViewController.view removeFromSuperview];
            [_centerViewController removeFromParentViewController];
            _centerViewController = nil;
        }
        
        _centerViewController = centerViewController;
        [self addChildViewController:self.centerViewController];
        _centerViewController.view.frame = CGRectMake(kLeftVieWidth, 0, self.view.bounds.size.width - kLeftVieWidth, self.view.bounds.size.height);
        
        //TB_V10现在是一个通用容器，不是只对应公告信息，公告信息对应的页面应该由下一层的TAB指定，现在是TAB_V1002
//        if ([self.selectedFuncsBean.fv isEqualToString:@"TB_V10"]) {
//            
//            _centerViewController.view.frame = CGRectMake(kLeftVieWidth, 0, (self.view.bounds.size.width - kLeftVieWidth)/2, self.view.bounds.size.height);
//            
//        }

        [self.view addSubview:_centerViewController.view];
        
    }
}
-(void)msgDetailDidSelect:(NSNotification *)noti{
    NSArray * detailMsgArray = noti.object;
    if (detailMsgArray.count>0) {
        [self lookForDetailMessage:detailMsgArray[0] with:detailMsgArray[1] isShowHomePage:detailMsgArray[2]];
    }else{
        [self lookForDetailMessage:nil with:nil isShowHomePage:@"0"];
    }

}
-(void)lookForDetailMessage:(WSMsgsBean_msg *)msg with:(NSArray *)msgBeanArray isShowHomePage:(NSString *)isShowHomePage{
    
    [self deleteDetailMsgOrRevertView:nil];
    WSDetalViewController * detalCtrl = [[WSDetalViewController alloc]init];
    detalCtrl.model = msg;
    detalCtrl.msgBean = msgBeanArray.mutableCopy;
    if ([isShowHomePage isEqualToString:@"1"]) {
        detalCtrl.isHomePageShow = YES;
    }
    WCNavigationController* controller = [[WCNavigationController alloc] initWithRootViewController:detalCtrl];
    [self addChildViewController:controller];
    controller.view.frame = CGRectMake((self.view.bounds.size.width - kLeftVieWidth)/2 + kLeftVieWidth, 0, (self.view.bounds.size.width - kLeftVieWidth)/2, self.view.bounds.size.height);
    [self.view addSubview:controller.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDetailMsgOrRevertView:) name:DELETE_DETAILMSG_OR_REVERT_VIEW object:nil];

}

-(void)deleteDetailMsgOrRevertView:(NSNotification *)noti{
    if (noti) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    }
    for (UIViewController * controller in self.childViewControllers)
    {
        if ([controller isKindOfClass:[WCNavigationController class]]) {
            
            for (UIViewController * ctrl in controller.childViewControllers)
            {
                if ([ctrl isKindOfClass:[WSDetalViewController class]] ||[ctrl isKindOfClass:[WSRevertViewController class]] )
                {
                    //                    if ([ctrl isKindOfClass:[WSRevertViewController class]])
                    //                    {
                    for (UIView * view in ctrl.navigationController.view.subviews)
                    {
                        [view removeFromSuperview];
                    }
                    //                    }
                    
                    [ctrl.view removeFromSuperview];
                    [ctrl removeFromParentViewController];
                    
                    if ([ctrl isKindOfClass:[WSDetalViewController class]]) {
                        [controller.view removeFromSuperview];
                        [controller removeFromParentViewController];
                    }
                    
                    break;
                }
            }
            
            
        }
    }


}
- (NSInteger)markBadgeForMessage
{
    LogTrace();
    NSInteger unReadMessageCount = 0;
    NSInteger unUploadCount = 0;
    NSMutableArray *arrayForMessage = nil;
    WSFuncsBeanArray * fba = [WSAppData getObjectbyKey:FUNCS];
    for (int i = 0; i < [fba.funcsArray count]; i++)
    {
        WSFuncsBean* fb = [fba.funcsArray objectAtIndex:i];
        if ([fb.fv isEqualToString:@"TB_V11"]
            || [fb.fv isEqualToString:@"TB_V10"]
            || [fb.fv isEqualToString:@"TB_V12"])
        {

            WSMsgBeanArray * messageArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
            for (int j=0; j<[messageArray.msgArray count]; j++) {
                WSMsgsBean *msgsB=[messageArray.msgArray objectAtIndex:j];
                if ([msgsB.name isEqualToString:@"总裁致词"]) {
                    [messageArray.msgArray  removeObjectAtIndex:j];
                }
            }
            NSArray *msgsArray = nil;
            if (fb.filter != nil && [fb.filter length] > 0) {
                msgsArray = [messageArray getMsgsBeansWithFilter:fb.filter];
            }
            if (msgsArray != nil) {
                arrayForMessage = [NSMutableArray arrayWithArray:msgsArray];
            }else{
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
                }else{
                    bNew = NO;
                }
                bFlag = YES;
            }else{
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
                for (WSMsgsBean_msg *msg in aMsg.msg)
                {
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
                        }else{
                            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                            id obj = [dic objectForKey:key];
                            if (obj == nil) {
                                ++m;
                            }
                            
                        }
                    }else{
                        if (msg.isread != nil && [msg.isread isEqualToString:@"1"]) {
                            NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                            NSMutableDictionary *infodic = [NSMutableDictionary dictionaryWithDictionary:dic];
                            [infodic setObject:[NSNumber numberWithBool:YES] forKey:key];
                            [user setObject:infodic forKey:kWSMessageDomainName];
                            [user synchronize];
                        }else{
                            ++m;
                        }
                    }
                    
                }
            }
            unReadMessageCount = m;
            NSString *identifer = nil;
            if (m > 0) {
                identifer = [NSString stringWithFormat:@"%d",m];
            }
            
            [self.leftView setEventIdentifer:identifer withFuncsBean:fb];
            fb.eventIdentifer = identifer;
        }
        // 手动上传
        else if ([fb.fv isEqualToString:@"TB_V180"]) {
            NSInteger pending = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
            unUploadCount = pending;
            [self updateBadgeForManualUploadWithFuncsBean:fb];
        }
        // 计划内外,TB_V61为Etrip新增，是“连锁分店拜访”，功能类似门店拜访
        else if ([fb.fv isEqualToString:@"TB_V20"] || [fb.fv isEqualToString:@"TB_V61"] || [fb.fv isEqualToString:@"TB_V50"] || [fb.fv isEqualToString:@"TB_V80"] || [fb.fv isEqualToString:@"TB_V60"]) {
            [self updateBadgeForStoreVisitWithFuncsBean:fb];
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
            
            NSString *identifer = nil;
            if (pending > 0)
            {
                identifer = [NSString stringWithFormat:@"%ld", (long)pending];
            }
            
            [self.leftView setEventIdentifer:identifer withFuncsBean:fb];
            fb.eventIdentifer = identifer;
        }else if([fb.fv isEqualToString:@"TB_mediaDownload"]){
            
            [self.leftView setEventIdentifer:nil withFuncsBean:fb];

            
        }
    }
    return unReadMessageCount + unUploadCount;
}


- (BOOL)anyStoreHasNotLeave:(WSFuncsBean *)fb notLeaveStoreFc:(NSString *)fc {
    
    if ([fb.fc isEqualToString:fc]) {
        return YES;
    }
    for (WSFuncsBean *subFb in fb.funcsArray) {
        if ([subFb.fc isEqualToString:fc]) {
            return YES;
        }
        
        BOOL result = [self anyStoreHasNotLeave:subFb notLeaveStoreFc:fc];
        if (result) {
            return YES;
        }
        
    }
    return NO;
}

#pragma mark Update LeftView Icon Methods

- (void)updateBadgeForManualUploadWithFuncsBean:(WSFuncsBean *)funcsBean
{
    LogTrace();
    
    NSInteger pending =  [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    
    NSString *identifer = nil;
    
    if (pending > 0)
    {
        identifer = [NSString stringWithFormat:@"%ld", (long)pending];
    }
    
    [self.leftView setEventIdentifer:identifer withFuncsBean:funcsBean];
    funcsBean.eventIdentifer = identifer;
}

- (void)updateBadgeForStoreVisitWithFuncsBean:(WSFuncsBean *)funcsBean
{
    
    LogTrace();
    BOOL pending = NO;
    WSInoutStoreObject *l_store = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    
    if (l_store) {
        pending = [self anyStoreHasNotLeave:funcsBean notLeaveStoreFc:l_store.modulefc];
    }
    
    NSString *identifer = nil;
    
    if (pending) {
        identifer = @"!";
    }
    
    [self.leftView setEventIdentifer:identifer withFuncsBean:funcsBean];
    funcsBean.eventIdentifer = identifer;
}


- (void)showfb
{
    [self.leftView showFuncsBean:self.selectedFuncsBean];
}

#pragma mark - WSMainLeftViewDelegate

- (void)needRefreshData
{
    [super beginRefreshData];
}

- (BOOL)didSelectFuncsBean:(WSFuncsBean *)funcsBean
{
    
    self.toBeSelectedFuncsBean = funcsBean;
    
    if ([self.toBeSelectedFuncsBean.fv isEqualToString:@"TB_unileveLink"]) {
        
        UIButton *btn =  (UIButton *)[self.leftView.leftBottombtnDict objectForKey:@"TB_unileveLink"];
        if (btn) {
            WSOutsideLinkViewController *outside  =  [[WSOutsideLinkViewController alloc] initWithFuncs:funcsBean];
            CGRect rect = CGRectMake(kMarginLeftToBtn,0,30,30);
            CGSize contentSize = CGSizeMake(440, 340);
            
            if ([[UIDevice currentDevice] systemVersionHigherThan:@"8.0"]) {
                outside.modalPresentationStyle=UIModalPresentationPopover;
                outside.preferredContentSize= contentSize ;
                
                outside.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionLeft;
                outside.popoverPresentationController.sourceRect = btn.bounds;
                outside.popoverPresentationController.permittedArrowDirections= UIPopoverArrowDirectionLeft;
                
                UIPopoverPresentationController*pop  = outside.popoverPresentationController;
                pop.permittedArrowDirections=  UIPopoverArrowDirectionLeft;
                pop.sourceRect= rect;
                pop.sourceView = btn ;
                [self presentViewController:outside animated:YES completion:nil];
                
            }else{
                
                _pop =[[UIPopoverController alloc]initWithContentViewController:outside];
                _pop.popoverContentSize = contentSize;
                [_pop presentPopoverFromRect:rect inView:btn permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            }
        }
        return NO;
    }
    
    if ([self.toBeSelectedFuncsBean.fv isEqualToString:@"TB_mediaDownload"]) {
        
        [self.leftView setEventIdentifer:nil withFuncsBean:self.toBeSelectedFuncsBean];
        
        UIButton *btn =  (UIButton *)[self.leftView.leftBottombtnDict objectForKey:@"TB_mediaDownload"];
        
        if (btn) {
            WSDownLoadRichMediaController *down  =  [[WSDownLoadRichMediaController alloc] initWithFuncs:funcsBean];
            CGRect rect = CGRectMake(kMarginLeftToBtn,0,30,30);
            CGSize contentSize = CGSizeMake(350, 300);
            
            if ([[UIDevice currentDevice] systemVersionHigherThan:@"8.0"]) {
                down.modalPresentationStyle=UIModalPresentationPopover;
                down.preferredContentSize= contentSize ;
                
                down.popoverPresentationController.permittedArrowDirections=  UIPopoverArrowDirectionLeft;
                down.popoverPresentationController.sourceRect = btn.bounds;
                down.popoverPresentationController.permittedArrowDirections= UIPopoverArrowDirectionLeft;
                
                UIPopoverPresentationController*pop  = down.popoverPresentationController;
                pop.permittedArrowDirections=  UIPopoverArrowDirectionLeft;
                pop.sourceRect= rect;
                pop.sourceView = btn ;
                [self presentViewController:down animated:YES completion:nil];
                
            }else{
                
                _pop =[[UIPopoverController alloc]initWithContentViewController:down];
                _pop.popoverContentSize = contentSize;
                [_pop presentPopoverFromRect:rect inView:btn permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            }
        }
        return NO;
    }
    
    
    if ([self.toBeSelectedFuncsBean.fv isEqualToString:@"TB_richMediaList"]) {
        
        WSRichMediaMainShowController *rich = [[WSRichMediaMainShowController alloc] init];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rich];
        
        [self presentViewController:nav animated:YES completion:nil];
        
        return NO;
    }
    
    
    if ([self.selectedFuncsBean.fv isEqualToString:@"TB_V20"] || [self.selectedFuncsBean.fv isEqualToString:@"TB_V61"])
    {
        [self updateBadgeForStoreVisitWithFuncsBean:self.selectedFuncsBean];
    }
    
    NSString *className = [WSPlistHelper valueForKey:self.toBeSelectedFuncsBean.fv withPlistName:kControllerMappingFileName];
    WSAppDelegate * deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;

    if (funcsBean && [funcsBean.fv isEqualToString:@"TB_V210"]&& [funcsBean.funcsArray count]>=1) {
        WSFuncsBean *jumpFuncsBean = [funcsBean.funcsArray objectAtIndex:0];
        [deleget callOrDownLoadOtherAPPWith:jumpFuncsBean];
        return NO;
    }
    
    if (self.toBeSelectedFuncsBean) {
        WSFuncsBean *jumpFuncsBean = [self.toBeSelectedFuncsBean.funcsArray firstObject];
        if (jumpFuncsBean.fv && [jumpFuncsBean.fv isEqualToString:@"TAB_V20001"]) {
            [deleget callOrDownLoadOtherAPPWith:jumpFuncsBean];
            return NO;
        }
    }
    
    if (className == nil) {
        [self showWrongMessage];
        return NO;
    }
    else
    {
        WCNavigationController *currentCenterController = (WCNavigationController *)self.centerViewController;
        if(currentCenterController){
            UIViewController *realContentTopViewController = [currentCenterController visibleViewController];
            
            if ([realContentTopViewController respondsToSelector:@selector(isValueChange)]) {
                BOOL changed=[(BaseViewController*)realContentTopViewController isValueChange];
                [self.leftView setValueChanged:changed withFuncsBean:currentCenterController.funcsBean];
            }else{
                [self.leftView setValueChanged:NO withFuncsBean:currentCenterController.funcsBean];
            }
        }
        
        
        WCNavigationController *controller = nil;
        
        for(WCNavigationController* nav in self.navArray){
            if(nav.funcsBean==self.toBeSelectedFuncsBean){
                controller=nav;
                break;
            }
        }
        
        if(!controller){
            LogInfo(@"Going to init class:%@", className);
            
            UIViewController * vc = [[NSClassFromString(className) alloc] initWithFuncs:self.toBeSelectedFuncsBean];
            vc.title = self.toBeSelectedFuncsBean.name;
//            if ([className isEqualToString:@"WSMyMsgAcvtListViewController"]) {
//
//                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(msgDetailDidSelect:) name:MYMSG_DETAIL_DIDSELECT_MESSAGE object:nil];
//            }
            
            
            controller = [[WCNavigationController alloc] initWithRootViewController:vc];
            
            if(self.toBeSelectedFuncsBean.funcsArray.count>1){
                controller.funcsBean=self.toBeSelectedFuncsBean;
                [self.navArray addObject:controller];
            }else if((self.toBeSelectedFuncsBean.funcsArray.count==1)){
                WSFuncsBean* fb=self.toBeSelectedFuncsBean.funcsArray.firstObject;
                if(![fb.dateTyp isEqualToString:@"E"]) {
                    // SFA-6800 修改内存泄漏时添加该逻辑，因 SFA-15906 暂时屏蔽
                   //&& ![fb.fv isEqualToString:REPOPRT_FV]){
                    controller.funcsBean=self.toBeSelectedFuncsBean;
                    [self.navArray addObject:controller];
                }
                
                
            }
        }
        
        if ([self.homePageRealSubFuncsBean.fv isEqualToString:DEFAULT_HOMEPAGE_FV]) {
            
            if ([[controller.viewControllers lastObject] isKindOfClass:[WSMyMsgViewController class]]) {
                WSMyMsgViewController *msgVC = (WSMyMsgViewController *)[controller.viewControllers lastObject];
                msgVC.subFuncsBeanNeedShow = self.homePageRealSubFuncsBean;
                self.homePageRealSubFuncsBean = nil;
            }
            else if([[controller.viewControllers lastObject] isKindOfClass:[WSMyMsgAcvtListViewController class]]){
                WSMyMsgAcvtListViewController *msgVC = (WSMyMsgAcvtListViewController *)[controller.viewControllers lastObject];
                msgVC.subFuncsBeanNeedShow = self.homePageRealSubFuncsBean;
                self.homePageRealSubFuncsBean = nil;
            }

        }
        
        self.selectedFuncsBean = self.toBeSelectedFuncsBean;
        
        [self setCenterViewController:controller];
        
        
        if( !IOS7_OR_LATER ){
        
            controller.navigationBar.clipsToBounds = YES;
            controller.toolbar.clipsToBounds=YES;
            
            [[UIBarButtonItem appearance] setTitleTextAttributes:
             @{ NSFontAttributeName: [UIFont systemFontOfSize:17],
                NSShadowAttributeName: [NSValue valueWithUIOffset:UIOffsetZero],
                NSForegroundColorAttributeName:[UIColor colorWithRed:0.0 green:147.0/255.0 blue:208.0/255.0 alpha:1.0]
                } forState:UIControlStateNormal];
            [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new]
                                                    forState:UIControlStateNormal
                                                  barMetrics:UIBarMetricsDefault];
            [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_back_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 0)]
                                                              forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsDefault];
            [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, 0)
                                                                 forBarMetrics:UIBarMetricsDefault];
        }
        
    }
    return YES;
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kConfirmToChangeFuncsAlertViewTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            NSString *className = [WSPlistHelper valueForKey:self.selectedFuncsBean.fv withPlistName:kControllerMappingFileName];
            
            LogInfo(@"Going to init class:%@", className);
            UIViewController * vc = [[NSClassFromString(className) alloc] initWithFuncs:self.toBeSelectedFuncsBean];
            vc.title = self.toBeSelectedFuncsBean.name;
            WCNavigationController* controller = [[WCNavigationController alloc] initWithRootViewController:vc];
            
            self.selectedFuncsBean = self.toBeSelectedFuncsBean;
            
            [self setCenterViewController:controller];
            
            if( !IOS7_OR_LATER ){
                controller.navigationBar.clipsToBounds = YES;
                controller.toolbar.clipsToBounds=YES;
                
                [[UIBarButtonItem appearance] setTitleTextAttributes:
                 @{ NSFontAttributeName: [UIFont systemFontOfSize:17],
                    NSShadowAttributeName: [NSValue valueWithUIOffset:UIOffsetZero],
                    NSForegroundColorAttributeName:[UIColor colorWithRed:0.0 green:147.0/255.0 blue:208.0/255.0 alpha:1.0]
                    } forState:UIControlStateNormal];
                [[UIBarButtonItem appearance] setBackgroundImage:[UIImage new]
                                                        forState:UIControlStateNormal
                                                      barMetrics:UIBarMetricsDefault];
                [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"nav_back_btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 0)]
                                                                  forState:UIControlStateNormal
                                                                barMetrics:UIBarMetricsDefault];
                [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5, 0)
                                                                     forBarMetrics:UIBarMetricsDefault];
            }
            
            [self.leftView selectFuncsBean:self.selectedFuncsBean];
            
        }
    }
    else if (alertView.tag == kConfirmToLogOutAlertViewTag)
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            // 退出时停止timer和thread
            if (![self.noticeThread isCancelled] ) {
                [self.noticeThread cancel];
            }
            if ([self.noticeTimer isValid]) {
                [self.noticeTimer invalidate];
                self.noticeTimer = nil;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT object:nil];
        }
    }
}

-(void)updateGeoVersion
{
    BOOL shouldUpdate = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentLibraryFolderPath = [documentsDirectory stringByAppendingPathComponent:@"CityData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentLibraryFolderPath])
    {
        shouldUpdate = YES;
    }
    
    NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"geoVersion"];
    NSString *serviceVersion = [WSAppData getObjectbyKey:GEOVERSION];
    if (nil == currentVersion) {
        shouldUpdate = YES;
    } else if ([currentVersion compare:serviceVersion options:NSNumericSearch] == NSOrderedAscending) {
        shouldUpdate = YES;
    }
    
    //    if (newVersion > oldVersion)
    //    {
    //        shouldUpdate = YES;
    //    }
    if (shouldUpdate)
        
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(geoUpdated:)
                                                     name:GEONOTIFY
                                                   object:nil];
        WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
        NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
        [uploadMgr appUpdateGeoDataWithEmpId:empId notifyName:GEONOTIFY];
    }
}

-(void)geoUpdated:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GEONOTIFY
                                                  object:nil];
    
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error != 0)
    {
        //[self performSelector:@selector(updateGeoVersion) withObject:nil afterDelay:5];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"update_data_tip", nil)  tips:nil tapTarget:self action:nil];
    
    NSDictionary *dic = [info objectFromJSONString];
    //[self processGeoData:dic];
    
    [NSThread detachNewThreadSelector:@selector(processGeoData:) toTarget:self withObject:dic];
}

-(void)processGeoData:(NSDictionary *)dic
{
    @autoreleasepool {
        NSArray *provinceArray = [dic objectForKey:@"geography"];
        if (provinceArray != nil)
        {
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

-(void)updateFinished
{
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
}

@end
