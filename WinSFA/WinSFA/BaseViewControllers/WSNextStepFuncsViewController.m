//
//  WSNextStepFuncsViewController.m
//  WinSFA
//
//  Created by Alicia on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNextStepFuncsViewController.h"
#import "WSNextStepFuncsView.h"

#import "WSInoutStoreTable.h"

#import "WSBaseAcvtDBService.h"
#import "WSReportFormController.h"
#import "WSGeographiclistViewController.h"
#import "WSGeographicInfo.h"
#import "WSInoutStoreTable.h"
#import "HYPageView.h"
#import "WSMV_LISTViewController.h"
#import "WSAcvtViewController.h"
#import "WSLeaveStoreAcvtViewController.h"

#define INDEX_NOT_SET        -1
#define REQUEST_NOTIFY       @"sendRequest_notify"

@interface WSNextStepFuncsViewController () <WSNextStepFuncsDelegate>


@property (nonatomic, strong) WSNextStepFuncsView *nextStepFuncsView;
@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) WSNextStepFuncsViewStyle viewStyle;
@property (nonatomic, assign) NSArray *subViewControllerArray;


@end

@implementation WSNextStepFuncsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.viewStyle = WSNextStepFuncsUnderLineScroll;
    
    [self setupViews];
    [self setupTitle];
   
    
    [self initializationBackItemAction];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // MN-1779 HYPageView 视图是layoutsubview中初始化 导致不能在 viewDidLoad 设置偏移，所以重新设置下
    if (self.viewStyle == WSNextStepFuncsUnderLineScroll) {
        [self.nextStepFuncsView moveToVisibleWithIndex:self.currentIndex];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Method


- (instancetype)initWithFuncs:(WSFuncsBean *)funcs store:(WSStoreBean *)store subempStore:(WSSubempstoreBean *)subempStore acvtNewStore:(WSStoreBean *)acvtNewStore moduleFC:(NSString *)moduleFC {
    self = [super init];
    if (self) {
        self.currentFuncs = funcs;
        
        self.currentStore = store;
        self.subempStore = subempStore;
        self.acvtNewStore = acvtNewStore;
        
        self.moduleFC = moduleFC;
        
        self.currentIndex = INDEX_NOT_SET;
        
        [self initFuncsBeanData];
    }
    return self;
}


- (void)setupViews {
    
    CGFloat nextStepHeight;
    CGFloat mainPosY;
    if (self.viewStyle == WSNextStepFuncsUnderLineScroll) {
        nextStepHeight = self.view.height;
        mainPosY = 0;
    } else {
        nextStepHeight = 58;
        mainPosY = nextStepHeight;
    }
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, mainPosY, self.view.width, self.view.height - mainPosY)];
    self.mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.mainView];
    
    self.nextStepFuncsView = [[WSNextStepFuncsView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, nextStepHeight)];
    [self.nextStepFuncsView setViewStyle:self.viewStyle vcArray:[self getViewControllers]];
    if (self.viewStyle == WSNextStepFuncsUnderLineScroll) {
        self.nextStepFuncsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        self.nextStepFuncsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    [self.view addSubview:self.nextStepFuncsView];
    
    [self.nextStepFuncsView setFuncsArray:self.funcBeanArray];
    self.nextStepFuncsView.delegate = self;
    
  
    // 设置需要进入的拜访项，拜访项”打勾“
    NSInteger lastIndex = INDEX_NOT_SET;
    for (NSInteger i = 0; i < self.self.funcBeanArray.count; i++) {
        WSFuncsBean *fb = self.funcBeanArray[i];
        // 原有的逻辑必须循环查询，查询逻辑中有插入逻辑
        WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
        VisitActionStatus visitStatus = [self getVisitActionStatusWithFuncsBean:fb action:action];
        
        
        if ([fb.fv isEqualToString:ENTERSTORE_FV]) {
            NSString *detect_code = self.moduleFC;
            if (self.input_reflect_code) {
                if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                    detect_code = self.input_reflect_code;
                }
            }
            //判断是否重拜访
            if ([self isVisitedStore:self.currentStore withParentFuncCode:detect_code])
            {
                lastIndex = i;
                __weak WSNextStepFuncsViewController *weakSelf = self;
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil)
                                                               message:NSLocalizedString(@"enterpos_dialog_message", nil)];
                
                [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label",nil) block:^{
                    
                    //MN-2616 2018-06-05
                    NSArray *vcArray = [weakSelf getViewControllers];
                    WCBaseViewController *vc = [vcArray firstObject];
                    if([vc.currentFuncs.fv isEqualToString:ENTERSTORE_FV] && [vc isKindOfClass:[WSAcvtViewController class]])
                    {
                        ((WSAcvtViewController *)vc).currentStore.inReadonlyMode = YES;
                        [((WSAcvtViewController *)vc) setAcvtReadOnly];
                        [weakSelf gotoFuncs:weakSelf.funcBeanArray[i] index:i];
                    }
                    else
                        [weakSelf goBack];
                }];
                
                [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                    [weakSelf gotoFuncs:weakSelf.funcBeanArray[i] index:i];
                }];
                
                [alert show];
            }
        }
        
        // 设置当前选中项
        if (lastIndex == INDEX_NOT_SET && ![visitStatus isEqualToString:ActionDone]) {
            lastIndex = i;
            [self gotoFuncs:self.funcBeanArray[i] index:i];
        }

        if ([visitStatus isEqualToString:ActionDone]) {
            [self.nextStepFuncsView setHasVisitedIndex:i];
        }
    }
}


- (void)setupTitle {
    NSString *title = nil;
    if (self.currentStore) {
        NSString *storeNameAndCode = [self.currentStore getDisplayNameAndCode];
        if ([storeNameAndCode length] > 0) {
            title = storeNameAndCode;
        }
    }
    if ([title length] > 0) {
        self.title = title;
    } else {
        self.title = self.currentFuncs.name;
    }
}

- (void)initializationBackItemAction {
    [self backItemAction:@selector(backAction) target:self];
}

- (void)backAction
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    //MN-1284 2018-03-15 增加未离店返回提示操作
    BOOL isEnterStore = NO;
    if (self.currentStore)
        isEnterStore = [[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
    
    if(isEnterStore)
    {
        BOOL isLeaveStore = [[WSInoutStoreTable sharedTable] isLeaveStore:self.currentStore andOtherParam:self.moduleFC andParamType:EParameterType_ParentFC];
        if (isLeaveStore || [self.currentFuncs.opt.leaveStoreTip isEqualToString:@"0"])
            [self goBack];
        else
        {
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"post_quit_message", nil)];
            [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label",nil) block:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"back_label", nil) block:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MAIN_VC_NEED_UPDATE_BADGE_NOTIFY object:nil];
                [self goBack];
            }];
            [alert show];
        }
        return;
    }
    
    [self goBack];
}


- (BOOL)backToParent {
    LogTrace();
    
    // MN-2527 如果当前 Controller 上追加过其他视图则不需要返回移除视图即可
    if ([self removeOtherController]) {
        return NO;
    }

    if (self.currentIndex < self.funcBeanArray.count - 1) {
        NSInteger index = self.currentIndex + 1;
        [self gotoFuncs:self.funcBeanArray[index] index:index];
        return NO;
    }
  
    [self goBack];
    
    return YES;
}

- (void)goBack {
    if (!self.backVC) {
        NSInteger l_count = self.ownParentViewController != nil ? [self.ownParentViewController.navigationController.viewControllers count] : [self.navigationController.viewControllers count];
        
        if (l_count <= 1) {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            // SFA-13432 donghong
            [self.navigationController popViewControllerAnimated:NO];
        }
    } else {
        [self.navigationController popToViewController:self.backVC animated:YES];
    }
}

#pragma mark - Private Method
- (NSArray *)getViewControllers {
    if (self.funcBeanArray.count == 0) {
        return nil;
    }
    
    NSMutableArray *vcArray = [NSMutableArray arrayWithCapacity:self.funcBeanArray.count];
    for (WSFuncsBean *funcs in self.funcBeanArray) {
        UIViewController *vc = [self checkNextPageWithFuncsBean:funcs withShowToast:NO isInStore:NO];
        if (!vc) {
            LogError(@"vc is nil, fc is %@, name is %@", funcs.fc, funcs.name);
            continue;
        }
        vc = [self getValidNextControllerWithVC:vc withFuncsBean:funcs withAutoJump:NO isInStore:NO];
        [self resetViewController:vc];
        [vcArray addObject:vc];
    }
    return [vcArray copy];
}

- (void)resetViewController:(UIViewController *)vc {

    if ([vc isKindOfClass:[WCBaseViewController class]]) {
        ((WCBaseViewController *)vc).ownParentViewController = self;
        ((WCBaseViewController *)vc).input_reflect_code = self.input_reflect_code;
        ((WCBaseViewController *)vc).isTabMode = YES;
    }
    
    //    if ([vc isKindOfClass:[SuperWorkSpaceViewController class]]) {
    //        ((SuperWorkSpaceViewController*)vc).delegate = self;
    //    }
    
    if ([vc isKindOfClass:[BaseViewController class]]) {
        ((BaseViewController *)vc).m_ParentViewController = self;
        ((BaseViewController *)vc).moduleFC = self.moduleFC;
    }
    
    if ([vc isKindOfClass:[WSGeographiclistViewController class]]) {
        WSGeographiclistViewController *geovc = (WSGeographiclistViewController *)vc;
        WSGeographicInfo *info = [WSAppData getObjectbyKey:GEOINFO];
        geovc.iGeographicInfos = info.iProvineceInfoArray;
    }

}



#pragma mark - WSNextStepFuncsDelegate
- (void)gotoFuncs:(WSFuncsBean *)funcs index:(NSInteger)index {
    if (index == self.currentIndex) {
        return;
    }
    
    CGRect frame = CGRectMake(0, 0, self.mainView.width, self.mainView.height);
    
    if (self.viewStyle != WSNextStepFuncsUnderLineScroll) {
        UIViewController *vc = [self checkNextPageWithFuncsBean:funcs withShowToast:YES isInStore:YES];
        if (!vc) {
            return;
        }
        
        vc = [self getValidNextControllerWithVC:vc withFuncsBean:funcs withAutoJump:NO];
        if (!vc) {
            return;
        }
        
        [self resetViewController:vc];
        
        vc.view.frame = frame;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIViewController *lastVC = [self.childViewControllers lastObject];
        [lastVC.view removeFromSuperview];
        [lastVC removeFromParentViewController];
        
        [self addChildViewController:vc];
        [self.mainView removeAllSubviews];
        [self.mainView addSubview:vc.view];
    } else {
        // MN-2395 地图 Panel 导致崩溃，移除视图
        if (self.currentIndex != INDEX_NOT_SET) {
            UIViewController *lastVC = [self.childViewControllers lastObject];
            [lastVC.view removeFromSuperview];
            [lastVC removeFromParentViewController];
        }
        
        [self.nextStepFuncsView resetVCFrameWithIndex:index frame:frame];
    }
    
    [self setVisitAction];
    
    [self.nextStepFuncsView setCurrentIndex:index];
    self.currentIndex = index;
}

- (void)setVisitAction {
    // 切换后判断上一次的拜访项是否已经拜访结束，如果已经拜访结束需要“打勾”
    NSInteger lastIndex = self.currentIndex;
    if (lastIndex >= 0) {
        WSFuncsBean *lastFb = self.funcBeanArray[lastIndex];
        WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:lastFb];
        VisitActionStatus visitStatus = [self getVisitActionStatusWithFuncsBean:lastFb action:action];
        if ([visitStatus isEqualToString:ActionDone]) {
            [self.nextStepFuncsView setHasVisitedIndex:lastIndex];
        }
    }
}

- (UIViewController *)addOtherControllerToView:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        BaseViewController *baseVC = (BaseViewController *)viewController;
        baseVC.m_ParentViewController = self;
    }
    
    UIViewController *currentVC = [self.nextStepFuncsView getViewControllerByIndex:self.currentIndex];
    
    return currentVC;
}

- (BOOL)removeOtherController {
    UIViewController *currentVC = [self.nextStepFuncsView getViewControllerByIndex:self.currentIndex];
    
    if ([currentVC isKindOfClass:[WSMV_LISTViewController class]]) {
        WSMV_LISTViewController *mvListVC = (WSMV_LISTViewController *)currentVC;
        return [mvListVC removeOtherController];
    }
    return NO;
}


- (BOOL)isValidController:(UIViewController *)vc index:(NSInteger)index
{
    //MN-2616 2018-06-05
    WSFuncsBean *funcs = self.funcBeanArray[index];
    
    vc = [self getValidNextControllerWithVC:vc withFuncsBean:funcs withAutoJump:NO];
    if (!vc) return NO;
    
    BOOL isIgnoreValidCheck = (self.currentStore.inReadonlyMode) ? YES : NO;
    if(isIgnoreValidCheck == NO)
    {
        BOOL isValid = [self checkEnterLeaveStore:funcs showToast:YES];
        if (!isValid) return NO;
    }
    else
    {
        if([vc isKindOfClass:[WSLeaveStoreAcvtViewController class]])
        {
            NSString *EnterStoreString = NSLocalizedString(@"not_enter_store",nil);
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:EnterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    
    [self setVisitAction];
    self.currentIndex = index;
    return YES;
}

@end
