//
//  WSWorkbenchViewController.m
//  WinSFA
//
//  Created by yang on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSWorkbenchViewController.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSStoreListView.h"
#import "WSWorkbenchView.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSInoutStoreTable.h"
#import "WSStoreHttpService.h"
#import "WSReportFormController.h"
#import "WSFuncsBeanArray.h"
#import "WCTabBarController.h"
#import "WSStatisticsManager.h"
#import "WSMsgBeanArray.h"
#import "WSBaseMsgTypeTable.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "WSDetalViewController.h"
#import "WSFuncTipsViewModel.h"

#define UPDATA_NOTIFY @"UPDATA_NOTIFY"

@interface WSWorkbenchViewController () <WSWorkbenchViewDelegate,WSStoreListViewDelegate>

@property (nonatomic, strong) NSArray *storeArray;
@property (nonatomic, strong) WSStoreListView *storeListView;
@property (nonatomic, strong) WSWorkbenchView *workBenchView;
@property (nonatomic, strong) WSFuncsBean *currentSelectedFB;
@property (nonatomic, strong) WSStoreHttpService *storeHttpService;

@end

@implementation WSWorkbenchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([self.currentFuncs.isStoreInfo isEqualToString:@"1"]) {
        
        [self refreshStoreList];
        
        self.currentStore = [self.storeArray firstObject];
        
        if (self.storeArray.count > 1) {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage scaledImageForName:@"icon_refresh" ofType:@"png"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showStoreList) forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            
            if (self.ownParentViewController) {
                self.ownParentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            }
            else {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            }
        }
    }
    
    [self refreshTitle];
    
    WSWorkbenchView *view = [[WSWorkbenchView alloc] initWithFrame:self.view.bounds withColNumber:self.currentFuncs.colNum];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.workBenchView = view;
    self.workBenchView.delegate = self;
    [self.view addSubview:view];
    view.currentStore = self.currentStore;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load:) name:@"loadCountTip" object:nil];
    
    [self refreshFuncsData];
    [self handleTabBarItemBadgeValue];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self refreshTitle];
    [self refreshFuncsData];
    
    [self showApprovalReminder];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 显示审批提醒方法
- (void)showApprovalReminder {
    
    [WSFuncTipsViewModel showTipsViewWithRole:WSShowFuncTipsViewRoleTypeManager];
}




- (void)refreshTitle {
    
    if (![self.currentFuncs.isStoreInfo isEqualToString:@"0"]) {
        
        if (self.ownParentViewController) {
            self.ownParentViewController.title = self.currentStore.name;
        }
        else {
            self.title = self.currentStore.name;
        }
    }
    
    if (self.ownParentViewController) {
        self.ownParentViewController.tabBarItem.title = self.currentFuncs.name;
    }
    else {
        self.tabBarItem.title = self.currentFuncs.name;
    }
}

- (void)load:(NSNotification *)note {
    
    [self refreshFuncsData];
}

- (void)showStoreList {
    
    [self refreshStoreList];
    
    [self.storeListView setSelectedStore:self.currentStore];
    [self.storeListView setStoreList:self.storeArray];
    
    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *rootView = delegate.window.rootViewController.view;
    [self.storeListView showOnView:rootView];
}

- (void)initFuncsBeanData {
    
    [self refreshFuncsData];
}

- (WSStoreListView *)storeListView {
    
    if (!_storeListView) {
        
        _storeListView = [[WSStoreListView alloc] initWithStoreList:self.storeArray];
        _storeListView.delegate = self;
    }
    
    return _storeListView;
}

- (void)refreshFuncsData {
    
    NSArray *funcsArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.currentFuncs.funcsArray withStore:self.currentStore bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    self.funcBeanArray = funcsArray;
    
    [self initDictBeanAndDataSource];
    self.workBenchView.isGridHomeStyle = [self setIsGridHome];
    [self.workBenchView setDataSource:self.dataSource andDicts:self.dictBeanArray];
    [self handleTabBarItemBadgeValue];
}

- (BOOL)setIsGridHome {
    
    if (!self.currentFuncs.menuStyle || self.currentFuncs.menuStyle.length == 0) {
        return NO;
    }
    
    WSBaseDictsDBService *dbService = [[WSBaseDictsDBService alloc] init];
    WSDictBean *dictBean = [dbService queryDictWithID:self.currentFuncs.menuStyle];
    if (dictBean) {
        
        NSString *dictName = dictBean.name;
        if ([dictName isEqualToString:FUNCS_HOME_GRID_STYLE]) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshStoreList {
    
    NSString *subEmpId = self.subempStore.Id;
    NSString *funCode = self.currentFuncs.fc;
    
    NSString *currenteEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    currenteEmpId = [subEmpId length] > 0 ? subEmpId : currenteEmpId;
    
    NSString *search_objId = STORES;
    if ([self.currentFuncs.ds length] > 0) {
        search_objId = self.currentFuncs.ds;
    }
    
    BOOL isSearchable = [self.currentFuncs.opt.isSearchable isEqualToString:@"remote"];
    NSArray *allArray = [[WSBaseStoreDBService shareInstance]queryAllStoreWithFuncCode:funCode empId:currenteEmpId styp:self.currentFuncs.styp searchStr:nil search_objId:search_objId isSearchable:isSearchable
                                                                       storeAccessMode:[subEmpId length] > 0 ? WSStoreAccessModeSubEmp : WSStoreAccessModeNormal parentStoreFc:self.currentFuncs.opt.parentStoreFc];
    self.storeArray = allArray;
}

- (CGFloat)contentHeight {
    
    return [self.workBenchView contentHeight];
}

- (BOOL)isStoreWorkFlowFuncBean:(WSFuncsBean *)funcBean {
    
    WSFuncsBean *enterStoreFuncBean = nil;
    for (WSFuncsBean *funcBeanTemp in self.funcBeanArray) {
        
        if ([funcBean.fv isEqualToString:ENTERSTORE_FV]) {
            enterStoreFuncBean = funcBeanTemp;
            break;
        }
    }
    
    if (enterStoreFuncBean && [enterStoreFuncBean.fk isEqualToString:funcBean.fk]) {
        return YES;
    }
    
    return NO;
}

- (void)didSelectFuncBean:(WSFuncsBean *)funcBean {
    
    BOOL isInStore = [self isStoreWorkFlowFuncBean:funcBean];
    if (isInStore) {
        
        self.currentSelectedFB = funcBean;
        if (self.currentStore && !self.currentStore.plan) {
            
            WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSString *empId = ([self.subempStore.Id length] > 0 )?self.subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
            BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
            if (!isRequested) {
                isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
            }
            
            if (!isRequested) {
                
                self.storeHttpService = [[WSStoreHttpService alloc] init];
                self.storeHttpService.storeBean = self.currentStore;
                self.storeHttpService.objID = ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
                
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"加载中…", nil)  tips:nil tapTarget:self action:nil];
                
                __weak typeof(self) wself = self;
                [self.storeHttpService getOutplanStoreDataWithCompletionBlock:^(NSDictionary *dic, NSError *error) {
                    
                    if (!error) {
                        [wself showFuncBean:funcBean isInStore:isInStore];
                    }
                    wself.storeHttpService = nil;
                }];
                
                return;
            }
        }
    }
    
    [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs store:self.currentStore
                                                              eventValue:funcBean.name startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
    [self showFuncBean:funcBean isInStore:isInStore];
}

- (void)showFuncBean:(WSFuncsBean *)funcBean isInStore:(BOOL)isInStore {
    
    if (funcBean.funcsArray.count == 1) {
        
        WSFuncsBean *bean = [funcBean.funcsArray firstObject];
        if ([bean.isAcvtList isEqualToString:@"1"] && [bean.fv isEqualToString:@"TAB_V1002"]) {
            
            WSMsgBeanArray *messageArray = [[WSMsgBeanArray alloc] initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
            NSMutableArray *myMsgArray = [[NSMutableArray alloc] init];
            NSMutableArray *allMsgArray = [[NSMutableArray alloc] init];
            if (bean.styp && bean.styp.length > 0) {
                myMsgArray = [[messageArray getMsgsBeansWithStyp:bean.styp] mutableCopy];
            }
            else {
                myMsgArray = messageArray.msgArray;
            }
            
            for (int i = 0; i < myMsgArray.count; i++) {
                
                WSMsgsBean * msgBean = myMsgArray[i];
                for (WSMsgsBean_msg * tempMsg in msgBean.msg) {
                    
                    tempMsg.componentMsgs = [tempMsg generateComponentMsgsWith:tempMsg fileUrl:tempMsg.fileUrl];
                    [allMsgArray addObject:tempMsg];
                }
            }
            
            UIViewController *vc = nil;
            if (allMsgArray.count == 1) {
                
                WSMsgsBean_msg *msgBean = [allMsgArray firstObject];
                if ([msgBean.cont length] > 0 && [msgBean.cont hasPrefix:@"http"]) {
                    NSURL *url = [NSURL URLWithString:msgBean.cont];
                    vc = [[WSReportFormController alloc] initWithURL:url];
                }
                else {
                    vc = [[WSDetalViewController alloc]init];
                    ((WSDetalViewController *)vc).model = [allMsgArray firstObject] ;
                    ((WSDetalViewController *)vc).msgBean = myMsgArray;
                }
                
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
        }
    }
    
    WSFuncsBean *contentFuncsBean = funcBean;
    if ([contentFuncsBean.fv hasPrefix:FUNCS_FV_HAS_TB]) {
        
        contentFuncsBean = funcBean.funcsArray.firstObject;
    }
    else if ([contentFuncsBean.fv hasPrefix:FUNCS_FV_HAS_TAB]) {
        
        NSString *className = [WSPlistHelper valueForKey:contentFuncsBean.fv withPlistName:kControllerMappingFileName];
        if (className == nil) {
            contentFuncsBean = funcBean.funcsArray.firstObject;
        }
    }
    
    if ([contentFuncsBean.jumpUrl length] > 0) {
        
        WSAppDelegate *deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        [deleget callOrDownLoadOtherAPPWith:contentFuncsBean paramsDic:nil];
        return;
    }
    
    UIViewController *vc = [self checkNextPageWithFuncsBean:funcBean withShowToast:YES isInStore:isInStore];
    [self gotoNextPageWithViewController:vc withFuncsBean:funcBean withAutoJump:NO];
    
    if (![contentFuncsBean.opt.visitedFlag isEqualToString:@"Y"]) {
        vc.currentVisitAction = nil;
    }
}

- (void)workbenchView:(WSWorkbenchView *)workbenchView didSelectItem:(WSFuncsBean *)funcBean {
    
    if ([funcBean.fv isEqualToString:@"TAB_JUMP"]) {
        
        [self jumpToTabMenuWithFuncBean:funcBean];
        return;
    }

    [self didSelectFuncBean:funcBean];
}

- (void)jumpToTabMenuWithFuncBean:(WSFuncsBean *)funcBean {
    
    NSString *filter = funcBean.filter;
    NSArray *geoArray = [filter componentsSeparatedByString:@","];
    if (geoArray.count > 1) {
        
        NSString *fc0 = geoArray[0];
        NSString *fc1 = geoArray[1];
        
        if (geoArray.count > 2) {
            NSString *fc2 = geoArray[2];
            if (fc2.length > 0) {
                [[NSUserDefaults standardUserDefaults] setObject:fc2 forKey:TAB_JUMP_FC];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }

        int tabIndex = 0;
        int pageIndex = 0;
        NSArray *tabFuncsArray = nil;
        WSFuncsBeanArray *fba = [WSAppData getObjectbyKey:FUNCS];
        NSArray *fbArray = fba.funcsArray;
        for (int i = 0; i < fbArray.count; i++) {
            
            WSFuncsBean * fb =fbArray[i];
            if ([fb.fc isEqualToString:fc0]) {
                tabIndex = i ;
                tabFuncsArray = fb.funcsArray;
                break;
            }
        }
        
        for (int i = 0; i < tabFuncsArray.count; i ++) {
            
            WSFuncsBean * fb =tabFuncsArray[i];
            if ([fb.fc isEqualToString:fc1]) {
                pageIndex = i ;
                break;
            }
        }
        
        UIViewController *tabVc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ([tabVc isKindOfClass:[WCTabBarController class]]) {
            
            WCTabBarController * tabBarController = (WCTabBarController *)tabVc;
            [tabBarController setSelectedIndex:tabIndex];
            
            NSDictionary *dic = @{TAB_JUMP_NOTIFY: [NSString stringWithFormat:@"%d",pageIndex],@"tabFC":fc0};
            [[NSNotificationCenter defaultCenter] postNotificationName:TAB_JUMP_NOTIFY object:nil userInfo:dic];
        }
    }
}

- (void)handleTabBarItemBadgeValue {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *funCode = (self.currentFuncs.iParentFuncsBean) ? self.currentFuncs.iParentFuncsBean.fc : self.currentFuncs.fc;
    NSString *item2 = [WSBaseStoreOtherDataDBService queryStoreSearchObjCodeWithFlag:FUNC_TIP empId:empId funcode:funCode];
    UIViewController *vc = (self.ownParentViewController) ? self.ownParentViewController : self;
    
    NSInteger count = [item2 integerValue];
    if (count <= 0) {
        
        vc.tabBarItem.badgeValue = nil;
    }
    else {
        
        NSString *badgeValue = (count > 99) ? @"..." : [NSString stringWithFormat:@"%ld", count];
        if ([self.currentFuncs.menuStyle  isEqualToString:@"specialTip"]) {
            badgeValue = @"!";
        }
        vc.tabBarItem.badgeValue = badgeValue;
    }
}

- (void)didSelectStore:(WSStoreBean *)store {
    
    self.currentStore = store;
    self.workBenchView.currentStore = store;
    [self refreshTitle];
    [self refreshFuncsData];
}

@end
