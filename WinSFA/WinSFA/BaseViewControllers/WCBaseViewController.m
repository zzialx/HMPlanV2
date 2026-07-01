//
//  WCBaseViewController.m
// Core
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCBaseViewController.h"
#import "UINavigationBar+Image.h"
#import "WSAppSettingViewController.h"
#import "WSNewAddListViewController.h"
#import "WSAcvtListViewController.h"
#import "WSMV_LISTViewController.h"
#import "WSAcvtViewController.h"
#import "WSSplitViewController.h"
#import "WSMyMsgAcvtListViewController.h"
#import "WSMyMsgViewController.h"
#import "WSFuncsBeanArray.h"
#import "WSBaseAcvtDBService.h"
#import "LEOAssistiveTouch.h"
#import "LEOMemoTouch.h"
#import "WSLoginViewController.h"
#import "MainViewController.h"
#import "WSReportFormController.h"
#import "MainViewController_iPad.h"
#import "WSNextStepFuncsViewController.h"
#import "WSDataSourceManager.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSRequestHelper.h"
#import "WSFuncTipDBService.h"
#import "WSSellFloatWindowManager.h"
#import "WSTimerManager.h"
#import "WSAttanceViewModel.h"
#import "WSFuncTipsViewModel.h"

static NSString *timerKey = @"showSignKey";
static NSString *msg = @"当前门店类型建议拜访时间为40分钟，如未离店，请回到系统中进行离店操作!";

@interface WCBaseViewController () <I_Lua_Executor_Delegate>

@property (nonatomic, weak) id <UIGestureRecognizerDelegate> originDelegate;
@property (nonatomic, assign) BOOL isSetOffset;

@end

@implementation WCBaseViewController

#ifdef DEBUG
-(void)dealloc
{
    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
    
    [self backItemAction:@selector(backAction) target:self];
    
    //定时器
    NSString * role  = [WSAttanceViewModel getLoginUserRole];
    if([role isEqualToString:@"主管"]||[role isEqualToString:@"OM"]){
        LogInfo(@"不需要超时提醒");
        return;
    }else{
        [self p_addTimerAlert];
    }
    

}
- (void)p_addTimerAlert{
    @weakify_self;
    if(![self isKindOfClass:[WSLoginViewController class]]){
        [[WSTimerManager sharedManager] scheduleTimerKey:timerKey interval:40 repeats:YES eventHandle:^{
            @strongify_self;
            [self showSignOutStoreAlert];
        }];
    }
}
- (BOOL)backToParent
{
    LogTrace();
    
    NSInteger l_count = self.ownParentViewController != nil ? [self.ownParentViewController.navigationController.viewControllers count]:[self.navigationController.viewControllers count];
    
    if (l_count <= 1) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

- (void)backAction
{
    if ([self.ownParentViewController isKindOfClass:[WSNextStepFuncsViewController class]])
        [((WSNextStepFuncsViewController *)self.ownParentViewController) backAction];
    else
        [self backToParent];
}

- (BOOL)shouldCustomInteractivePopGestureRecognizerDelegate
{
    return NO;
}

- (BOOL)shouldPauseBackAction
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (INTERFACE_IS_PHONE) {
        if ([self shouldCustomInteractivePopGestureRecognizerDelegate] && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {

            self.navigationController.interactivePopGestureRecognizer.delegate = self;
            
        }
    }

    if (self.currentFuncs.opt && self.currentFuncs.opt.isHideTitle) {
        [self.navigationController setNavigationBarHidden:YES];
        // MSTD-7279 逻辑应该是为了报表写的，但是现在报表已经没有问题了，先屏蔽 如果有问题再打开，没有问题以后可以删除
//        [self offsetView];
    } else if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [self.navigationController setNavigationBarHidden:NO];
    }
    if (self.currentFuncs.pageTag && self.currentFuncs.pageTag .length > 0) {
        [self loadTip];
    }
    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
}

#pragma mark - 显示在线沟通悬浮按钮方法
- (void)showOnlineConsultationBtn {
    
    BOOL isBool1_1 = self.navigationController.viewControllers.count == 1;
    BOOL isBool1_2 = self.parentViewController.presentingViewController == nil;
    BOOL isBool1_3 = ![self isKindOfClass:[WSLoginViewController class]];

    BOOL isBool2_1 = self.navigationController.viewControllers.count == 2;
    BOOL isBool2_2 = [self.navigationController.viewControllers.firstObject isKindOfClass:[MainViewController class]];
    BOOL isBool2_3 = [self.navigationController.viewControllers.firstObject isKindOfClass:[MainViewController_iPad class]];
    BOOL isBool2_4 = [self isKindOfClass:[WSAppSettingViewController class]];
    
    NSString *memoURL = [LEOMemoTouch isShowMemoURL];
    if (memoURL && memoURL.length > 0) {

        if (((isBool1_1 && isBool1_2 && isBool1_3) || (isBool2_1 && (isBool2_2 || isBool2_3) && isBool2_4)) && !self.tempChildController) {
            
            __weak __typeof__(self) weakSelf = self;
            [[LEOMemoTouch rootSharedInstance] setMainBtnClickedCallbackBlock:^{
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
                vc.externalOpenUrl = memoURL;
                vc.hidesBottomBarWhenPushed = YES;
                [strongSelf.navigationController pushViewController:vc animated:YES];
            }];
            [[LEOMemoTouch rootSharedInstance] show];
        }
        else {
            
            [[LEOMemoTouch rootSharedInstance] setMainBtnClickedCallbackBlock:^{}];
            [[LEOMemoTouch rootSharedInstance] hide];
        }
    }
    
    NSString *online_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
    if (online_Consultation && online_Consultation.length > 0) {
        
        NSNumber *onlineConsultationSwitchStateNumber = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION_SWITCH_STATE];
        BOOL onlineConsultationSwitchIsOn = [onlineConsultationSwitchStateNumber boolValue];
            
        if (((isBool1_1 && isBool1_2 && isBool1_3) || (isBool2_1 && (isBool2_2 || isBool2_3) && isBool2_4)) && onlineConsultationSwitchIsOn && !self.tempChildController) {
                
            [LEOAssistiveTouch show];
                
            BOOL isSR = [WSSellFloatWindowManager isShowSellFloatWindowWithRole];
            if (isSR) {
                [WSSellFloatWindowManager showSellFloatWindow];
            }
            else {
                [WSSellFloatWindowManager hideSellFloatWindow];
            }
        }
        else {
    
            [LEOAssistiveTouch hide];
            [WSSellFloatWindowManager hideSellFloatWindow];
        }
    }
}

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    
    self = [super init];
    if(self != nil)
    {
        self.currentFuncs = funcs;
        
        return self;
    }
    return nil;
}


- (void)logout{
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"exit_app_prompt", nil)];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:nil];
    
    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:LOGOUT object:nil];
    }];
    
    [alert show];
}

- (void)aboutsoftware:(id)aSender{
    WSAppSettingViewController *setting = [[WSAppSettingViewController alloc] initAppSetting];
    [self.navigationController pushViewController:setting animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (INTERFACE_IS_PHONE) {
        if ([self shouldCustomInteractivePopGestureRecognizerDelegate] && [self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    
    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
    
    if (INTERFACE_IS_PHONE) {
        [self showOnlineConsultationBtn];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
}

-(void)addEmptyView
{
    _empty = [[WSEmptyView alloc] initWithFrame:self.view.bounds andFuncsBean:self.currentFuncs];
    _empty.backgroundColor = [UIColor whiteColor];
    _empty.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_empty];
}


- (UINavigationController *)getNavigationController
{
    if (self.ownParentViewController) {
        return self.ownParentViewController.navigationController;
    }else if(self.navigationController) {
        return self.navigationController;
    }else{
        return  self.view.viewController.navigationController;
    }
}

- (UINavigationItem *)getNavigationItem
{
    if (self.ownParentViewController) {
        if([self.ownParentViewController isKindOfClass:[WCBaseViewController class]])
        {
            WCBaseViewController *wcBase = (WCBaseViewController*)self.ownParentViewController;
            if (wcBase.ownParentViewController) {
                return wcBase.ownParentViewController.navigationItem;
            }
        }
        return self.ownParentViewController.navigationItem;
    }else {
        return self.navigationItem;
    }
}
#pragma mark - Refresh

- (void)beginRefreshData {
    self.view.userInteractionEnabled = NO;
    self.navigationController.view.userInteractionEnabled = NO;
    
    [self.refreshService beginRefreshData];
}


#pragma mark - memory warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
    LogInfo(@"(class:%@)%@", [self class], self.currentFuncs.name);
}

#pragma mark - About rotate

// iOS6以前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (INTERFACE_IS_PAD) {
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
    else
    {
        return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    }
    
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    if (INTERFACE_IS_PHONE) {
        return NO;
    } else {
        return YES;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    if (INTERFACE_IS_PAD) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (INTERFACE_IS_PHONE) {
        if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
            if (self.navigationItem.leftBarButtonItem != nil && [self shouldPauseBackAction] && [self respondsToSelector:@selector(backAction)]) {
                [self performSelector:@selector(backAction)];
                return NO;
            }
        }
    }
    
    return YES;
}

- (NSInteger)markBadgeForMessage {
    return 0;
}


-(void)doDynamicCalling:(id)instance method:(SEL)selector andParam:(NSObject *)param{
    
    
    NSMethodSignature   *singlenature = [instance methodSignatureForSelector:selector];
    
    NSInvocation   *invocation = [NSInvocation invocationWithMethodSignature:singlenature];
    
    [invocation setTarget:instance];
    
    [invocation setSelector:selector];
    
    [invocation setArgument:&param atIndex:2];
    
    [invocation invoke];
    
    
    
}

+(WCBaseViewController *)getControllerWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean{
    
    if (fb && [fb.funcsArray count]>=1) {
        WSAppDelegate * deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        
        WSFuncsBean *jumpFuncsBean = [fb.funcsArray objectAtIndex:0];
        if (jumpFuncsBean.fv && [jumpFuncsBean.fv isEqualToString:@"TAB_V20001"]) {
            [deleget callOrDownLoadOtherAPPWith:jumpFuncsBean];
            return nil;
        }
    }
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    LogInfo(@"Going to init class: %@",className);
    WCBaseViewController* vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    vc.title = fb.name;
    
    if ([realSubFuncsBean.fv isEqualToString:@"TAB_V1001"]) {
        if ([vc isKindOfClass:[WSMyMsgViewController class]]) {
            WSMyMsgViewController *msgVC = (WSMyMsgViewController *)vc;
            msgVC.subFuncsBeanNeedShow = realSubFuncsBean;
        }else if([vc isKindOfClass:[WSMyMsgAcvtListViewController class]]){
            WSMyMsgAcvtListViewController *msgVC = (WSMyMsgAcvtListViewController *)vc;
            msgVC.subFuncsBeanNeedShow = realSubFuncsBean;
        }
    } else if (realSubFuncsBean) {
        className = [WSPlistHelper valueForKey:realSubFuncsBean.fv withPlistName:kControllerMappingFileName];
        vc = [[NSClassFromString(className) alloc] initWithFuncs:realSubFuncsBean];
        vc.title = realSubFuncsBean.name;
    }

    return vc;

}

- (CGFloat)contentHeight
{
    return 0;
}

#pragma mark - # 发送视频跳转的通知
- (void)postJumpChatNotificer{
    LogInfo(@"执行次数埋点----->");
    //push 页面成功之后，发送接通视频的通知
    WSAppDelegate * appDelegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    if(appDelegate.chatVC){
        [[NSNotificationCenter defaultCenter] postNotificationName:JUMP_CHAT_NOTIFI object:self userInfo:appDelegate.chatNotifiInfo];
    }
}

#pragma mark - about visit action
- (BOOL)parentForceToDone {
    
    if ([self.currentFuncs.opt.visitedFlag isEqualToString:@"Y"]) {
        return YES;
    }
    
    return NO;
}


- (BOOL)isNeedUpdateParentStatus:(WSVisitStoreActionObject *)aAction{
    //未进店不需要更新父亲级别的状态
    WSVisitStoreActionObject *tempAction = [[WSVisitStoreActionObject alloc] init];
    tempAction.parent_action_id = aAction.parent_action_id;
    tempAction.module_fc = aAction.module_fc;
    tempAction.fromModuleName = aAction.fromModuleName;
    NSArray *brotherActionArr = [[WSVisitStoreActionTable sharedTable]queryActionsWithObject:tempAction];
    
    
    BOOL isEnterOrLeaveFunc = NO;
    for (WSVisitStoreActionObject *brotherAction in brotherActionArr) {
        NSString *sql = [NSString stringWithFormat:@"select *from base_funcs where fc = '%@'",brotherAction.func_code];
        FMResultSet *rs = [[WSFMDatebase getInstance]executeQueryWithSql:sql];
        NSMutableArray *fvs = [NSMutableArray array];
        while ([rs next]) {
            NSString *acvtName = [rs stringForColumn:@"fv"];
            if(acvtName&&acvtName.length>0){
                [fvs addObject:acvtName];
            }
        }
        NSString *fv = [fvs firstObject];
        if ([fv isEqualToString:@"V20S01"] || [fv isEqualToString:@"V20S99"]) {
            isEnterOrLeaveFunc = YES;
            break;
        }
        
    }
    
    if (![self parentForceToDone]) {
        if ((![self.currentFuncs.fv isEqualToString:@"V20S01"] && ![self.currentFuncs.fv isEqualToString:@"V20S99"]) && isEnterOrLeaveFunc) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)manageActionStatus:(WSVisitStoreActionObject *)visitAction{
    
    WSVisitStoreActionObject *nextRemindAction = visitAction;
    
    //处理重复进店
    
    NSArray *arr =[[WSVisitStoreActionTable sharedTable] queryActionsWithObject:nextRemindAction];
    if ([arr count]==0) {
        
        arr = [[WSVisitStoreActionTable sharedTable] queryActionsWithObjectExceptParentId:nextRemindAction];
        if([arr count]>0){
            
            WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
            
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            
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
            
            if (self.input_reflect_code && self.input_reflect_code.length >0) {
                action.module_fc = self.input_reflect_code ;
            }
            
            if (self.currentVisitAction.newstore_id) {
                action.newstore_id = self.currentVisitAction.newstore_id;
            }
            
            BOOL result = [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone inOutFlag:self.input_reflect_code];
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
            
            if (self.input_reflect_code && self.input_reflect_code.length >0) {
                action.module_fc = self.input_reflect_code ;
            }
            
            if (self.currentVisitAction.newstore_id) {
                action.newstore_id = self.currentVisitAction.newstore_id;
            }
            
            BOOL result = [[WSVisitStoreActionTable sharedTable]updateAction:action toStatus:ActionDone inOutFlag:self.input_reflect_code];
            
            if (!result) {
                return NO;
            }
            
            
        }
        
    }else{
        
        WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
        
        BOOL result = [[WSVisitStoreActionTable sharedTable]updateAction:taction
                                                                toStatus:ActionDone
                                                               inOutFlag:self.input_reflect_code
                                                       parentForceToDone:[self parentForceToDone]
                                                      updateParentStatus:[self isNeedUpdateParentStatus:taction]];
        if (!result) {
            return NO;
        }
        
    }
    
    return YES;
    
}

- (void)querying_messageTips{
    // MSTD-7216 先隐藏旧的再显示新的
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    NSString *tipsString = NSLocalizedString(@"querying_message",nil);
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tipsString  tips:nil tapTarget:self action:nil];
}

- (NSString *)getBadgeValue {
    return nil;
}

- (BOOL)isHiddenCurrentTab {
    return NO;
}

#pragma -mark   HYPageView 右侧按钮点击后，对应页面需要执行的事件
-(void)HYPageViewButtonClickEvent{
    // 具体逻辑子类实现
}

#pragma mark - 执行校验lua脚本
- (BOOL)executeValidateLuaScripWithFb:(WSFuncsBean *)fb {
    
   return  [self executeValidateLuaScripWithFb:fb functionName:nil params:nil];
}

- (BOOL)executeValidateLuaScripWithFb:(WSFuncsBean *)fb functionName:(NSString *)functionName params:(NSString *)params
{
    NSString *scriptString = fb.script;
    if (scriptString.length > 0 && [scriptString rangeOfString:@"function"].location != NSNotFound) {
        LogInfo(@"菜单脚本开始执行，fb:%@,scriptString:%@", fb, scriptString);
        wsLuaExecutor = [WSLuaExecutorManager shareInstance];
        wsLuaExecutor.isErrorFromScript = NO;
        wsLuaExecutor.delegate = self;
        wsLuaExecutor.currentoperator = nil;
        [wsLuaExecutor executeLuaScript:scriptString functionName:functionName params:params];
        if (wsLuaExecutor.isErrorFromScript) {
            LogInfo(@"菜单脚本执行报错，fb:%@,scriptString:%@", fb, scriptString);
            return NO;
        }
        LogInfo(@"菜单脚本结束执行，fb:%@,scriptString:%@", fb, scriptString);
    }
    return YES;
}
-(void)executeInterAction:(WSInterAction *)interaction
{
}

- (void)loadTip
{
//    [self querying_messageTips];
    NSMutableDictionary*paramDic=[[NSMutableDictionary alloc] init];
    [paramDic setObject:[NSString stringNotNilWithValue:self.currentFuncs.pageTag] forKey:@"objId"];
    [paramDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    NSString *notifyID = @"loadTip";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinish:) name:notifyID object:nil];
    [[WSRequestHelper shareInstance] uploadDatasDictionary:paramDic urlString:URL_UPDATE notifyName:notifyID md5:nil isUpload:NO];
}
-(void)uploadFinish:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:notification.name object:nil];
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    if(![notification.object isKindOfClass:[NSError class]]){
        NSDictionary *dic = [[notification object] objectFromJSONString];
        if([dic objectForKey:@"fcCountTipOnTime"] && [[dic objectForKey:@"fcCountTipOnTime"] isKindOfClass:[NSArray class]])
        {
            WSFuncTipDBService *DB = [WSFuncTipDBService alloc];
            [DB replaceToTableWithDicts:[dic objectForKey:@"fcCountTipOnTime"] FromNode:nil hasNewData:YES];
            [self handleTabBarItemBadgeValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_COMMUNITY_NEW_MESSAGE_NOTIFICATION object:nil];
        }
    }else{
        NSString * title = NSLocalizedString(@"refresh_failure", nil);
        [MBProgressHUD showHUDAddedTo:self.view withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
}
- (void)handleTabBarItemBadgeValue{
    
}
- (void)addChencShowAlertTipsWithMsg:(NSString*)msg{
    if (msg.length>0) {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:msg];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
            
        }];
        [alert show];
    }
}
- (void)addNotAllowSlidBack{
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
}

#pragma mark - # 在店时长超过40分钟提醒框
-(void)showSignOutStoreAlert{
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (inOutStoreObj.intime) {
        double enterStoreTime =  inOutStoreObj.intime.doubleValue;
        double currentTime = [[WSCurrentTime getServerTime] doubleValue];
        double alertTime =  enterStoreTime + 40 * 60;
        NSString *alertTime_str = [WSCurrentTime getTimeFromTimestamp:alertTime];
        NSString *currentTime_str = [WSCurrentTime getTimeFromTimestamp:currentTime];
        if([alertTime_str isEqualToString:currentTime_str]){
            LogInfo(@"在店时间超过40分钟====>%@",inOutStoreObj.name);
            NSString * alert_msg = [NSString stringWithFormat:@"%@:%@",inOutStoreObj.name,msg];
            BlockAlertView *alert = [BlockAlertView alertWithTitle:alert_msg message:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{

            }];
            [alert show];
        }
    }
}
#pragma mark - # 收集地理位置信息弹框
- (void)addCollectUserLocationPlaclyAlert:(completeSuccess)successBlock{
    NSString * visitPrivacyPolicyMsg = [[WSAppData sharedManager].datas objectForKey:VISITPRIVACYMESSAGE];
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"通知" message:visitPrivacyPolicyMsg];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label", nil) block:^{
        
    }];
    [alert addButtonWithTitle:NSLocalizedString(@"approval", nil) block:^{
        LogInfo(@"同意手机用户定位信息");
        [WSRequestTools requestAgreeAppCollectingPrivacySuccess:^(BOOL success) {
            NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithValue:@"1"] forKey:[NSString stringWithFormat:@"%@_%@",VISITPRIVACYFLAG,ISNULL(empId)]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (successBlock) {
                successBlock(YES);
            }
        }];
        

    }];
    [alert show];
}

#pragma mark - 弹出视图方法
- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean {
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = fb.name;
    vc.kqArrange = (fb.kqArrange ? fb.kqArrange : nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}












#pragma mark - 是否个性化重定向(子类重写可修改逻辑)
- (BOOL)isPersonalizationRedirect {

    return NO;
}

#pragma mark - 展示个性化重定向(子类重写可修改逻辑)
- (void)executePersonalizationRedirect {
    
}

#pragma mark - 首页个性化完成方法
- (void)homePersonalizationFinish {
    
    if (self.homePersonalizationFinishBlock) {
        self.homePersonalizationFinishBlock();
    }
}

#pragma mark - 重写viewDidAppear:方法
- (void)viewDidAppear:(BOOL)animated {
        
    [super viewDidAppear:animated];
    
    [LEOAssistiveTouch hide];
    [WSSellFloatWindowManager hideSellFloatWindow];
    [self showOnlineConsultationBtn];
    
    //只针对app根页面进行处理业务逻辑
    BOOL systemRedirectIsGo = [self isPushRegistrationAgreementViewController];
    if (!systemRedirectIsGo) {
        return;
    }
    
    LogInfo(@"WCBaseViewController viewDidAppear 1 进入搜查重定向逻辑");

    //重定向跳转
    systemRedirectIsGo = [self pushloginRedirectFC];
    if (systemRedirectIsGo) {

        LogInfo(@"WCBaseViewController viewDidAppear 2 有重定向页面跳转");
        return;
    }
    
    //公告提醒
    [[WSComponyInfomationViewModel alloc] showComponyInfomationAlertViewWithVC:self];
    if ([WSComponyInfomationManager sharedInstance].isShowComponyInfo) {
        
        LogInfo(@"WCBaseViewController viewDidAppear 3 有信息公告弹出");
        return;
    }
    
    //根页面viewDidAppear逻辑(涉及请求余弹框)
    BOOL personalizationIsGo = [self isPersonalizationRedirect];
    if (personalizationIsGo) {
        
        LogInfo(@"WCBaseViewController viewDidAppear 4 有首页个性化操作(请求/弹框。。。。)");
        
        __weak __typeof__(self) weakSelf = self;
        self.homePersonalizationFinishBlock = ^{
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.homePersonalizationFinishBlock = nil;
            [strongSelf approvalReminderRedirect];
        };
        
        [self executePersonalizationRedirect];
        
        return;
    }
    
    //审批提醒提示
    LogInfo(@"WCBaseViewController viewDidAppear 5 审批提醒");
    [self approvalReminderRedirect];
}

#pragma mark - 是否可以注册协议视图管理器方法(默认调查问卷)
- (BOOL)isPushRegistrationAgreementViewController {

    if ([self isKindOfClass:[WSReportFormController class]] || [self isKindOfClass:[WSAcvtViewController class]] ||
        [self isKindOfClass:[WSLoginViewController class]]) {
        return NO;
    }
    
    UIViewController *topViewController = nil;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        id navigationControllerObj = tabBarController.viewControllers.firstObject;
        if ([navigationControllerObj isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *navigationController = (UINavigationController *)navigationControllerObj;
            topViewController = navigationController.viewControllers.firstObject;
        }
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        topViewController = navigationController.viewControllers.firstObject;
    }
    
    if (!topViewController) {
        return NO;
    }
    
    UIViewController *childViewController = topViewController.childViewControllers.firstObject;
    if (childViewController) {
        return ((childViewController == self) ? YES : NO);
    }
    
    return ((topViewController == self) ? YES : NO);
}

#pragma mark - 弹出登录重定向视图方法(逻辑判定)
- (BOOL)pushloginRedirectFC {
        
    NSArray *loginRedirectFcS = [WSAppData getObjectbyKey:APPDATA_LOGIN_REDIRECT_FC];
    if (loginRedirectFcS.count == 0) {
        return NO;
    }
    
    BOOL isPush = NO;
    WSFuncsBeanArray *fbArray = [WSAppData getObjectbyKey:FUNCS];
    for (NSString *fc in loginRedirectFcS) {
            
        WSFuncsBean *funcsBean = [fbArray getAllFuncsBeanWithFC:fc];
        if (funcsBean.fc.length == 0) {
            continue;
        }
        
        NSMutableArray *loginRedicrectMarry = [[NSMutableArray alloc] initWithArray:loginRedirectFcS];
        [loginRedicrectMarry removeObject:fc];
                
        if (loginRedicrectMarry.count > 0) {
            [[WSAppData sharedManager].datas setValue:loginRedicrectMarry forKey:APPDATA_LOGIN_REDIRECT_FC];
        }
        else {
            [[WSAppData sharedManager].datas setValue:nil forKey:APPDATA_LOGIN_REDIRECT_FC];
        }

        funcsBean.isloginRedirectFcWillShow = YES;
        [self pushRedirectViewWithFuncsBean:funcsBean realSubFuncsBean:nil];
        
        isPush = YES;
        break;
    }
    
    return isPush;
}

#pragma mark - 弹出重定向视图方法
- (void)pushRedirectViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean {
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    WCBaseViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
    vc.hidesBottomBarWhenPushed = YES;
    vc.title = fb.name;
    vc.kqArrange = (fb.kqArrange ? fb.kqArrange : nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - 审批提醒重定向方法
- (void)approvalReminderRedirect {
        
    [WSFuncTipsViewModel showTipsViewWithRole:WSShowFuncTipsViewRoleTypeSale];
}

@end
