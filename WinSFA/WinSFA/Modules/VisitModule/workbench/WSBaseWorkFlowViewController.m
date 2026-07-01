//
//  WSBaseWorkFlowViewController.m
//  WinSFA
//
//  Created by yang on 16/12/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseWorkFlowViewController.h"
#import "WSEnterStoreAcvtViewController.h"
#import "WSLeaveStoreAcvtViewController.h"
#import "WSNewAddListViewController.h"
#import "WSAcvtListViewController.h"
#import "WSAcvtGridViewController.h"
#import "WSMV_LISTViewController.h"
#import "WSEnterStoreViewController.h"
#import "WSLeaveStoreViewController.h"
#import "WSPopViewController.h"
#import "VisitDoctorViewController.h"
#import "WSNextStepViewController.h"
#import "WSInoutStoreTable.h"
#import "WSBaseAcvtDBService.h"
#import "WSVisitedMenuArray.h"
#import "WSBaseDictsDBService.h"
#import "WSFuncsBeanFilterLogicService.h"
#import "WSRequestHelper.h"
#import "WSStoreDataProcessService.h"
#import "WSProdGrideWithExpandableBrandsViewController.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSSubMenuViewController.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSInventoryModel.h"
#import "WinInventoryPopupConfig.h"
#import "WinJYOrderDetialPopupView.h"
#import "WinStockOutPopupView.h"
#import "WSInventoruHeader.h"
#import "WinStockOutPopupConfig.h"

#define REQUEST_NOTIFY @"sendRequest_notify"

@interface WSBaseWorkFlowViewController () <WSPopViewControllerDelegate>

@property (nonatomic, strong) UIViewController *updateMenuController;
@property (nonatomic, assign) BOOL updateMenuIsAutoJump;
@property (nonatomic, copy) NSString *requestObjID;

@end

@implementation WSBaseWorkFlowViewController

- (void)reloadView {
}

- (void)removeSelection {
}

- (void)reloadHeaderView {
}

- (void)initFuncsBeanData {
    
    self.funcBeanArray = [WSFuncsBeanFilterLogicService filterFuncsBean:self.currentFuncs.funcsArray withStore:self.currentStore bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    NSArray *specVCArray = [NSArray arrayWithObjects:@"TAB_V17001",@"TAB_V8001",@"V20A01", nil];
    NSMutableArray *mutableArray = [self.funcBeanArray  mutableCopy];
    for (WSFuncsBean *funcsBean in self.funcBeanArray) {
        
        if ([specVCArray containsObject:funcsBean.fv]) {
            
            BOOL isEmpty = [self isExistNewAcvtAndAcvtListWithFuncsBean:funcsBean withStoreBean:self.currentStore];
            if (isEmpty == NO) {
                
                if ([funcsBean.hiddenEmpty isEqualToString:@"1"]) {
                    [mutableArray removeObject:funcsBean];
                }
            }
        }
    }

    self.funcBeanArray = [mutableArray copy];
}

- (void)initDictBeanAndDataSource {
    
    if (!self.funcBeanArray || self.funcBeanArray.count == 0) {
        return;
    }
  
    NSArray *dictIDArray = [self.funcBeanArray valueForKeyPath:@"@distinctUnionOfObjects.menuType"];
    if (!dictIDArray || dictIDArray.count == 0) {
        
        [self setDataSourceWithFuncsBean];
        return;
    }
    
    WSBaseDictsDBService *dictsService = [[WSBaseDictsDBService alloc] init];
    NSArray *dictBeanArray = [dictsService queryDictsWithIDs:dictIDArray];
    if (!dictBeanArray || dictBeanArray.count == 0) {
        
        [self setDataSourceWithFuncsBean];
        return;
    }
    
    self.dictBeanArray = dictBeanArray;
    
    WSFuncsBeanFilterLogicService *funcsLogicService = [[WSFuncsBeanFilterLogicService alloc] init];
    self.dataSource = [funcsLogicService filterMenuTypeFuncsBean:self.funcBeanArray withDictsBeanArray:dictBeanArray];;
}

- (void)setDataSourceWithFuncsBean {
    
    NSArray *tempArray = [NSArray arrayWithObject:self.funcBeanArray];
    self.dataSource = tempArray;
}

- (BOOL)gpsIsReq:(WSFuncsBean *)fb {
    
    WSStoreBean *store;
    if (!self.acvtNewStore) {
        store = self.currentStore;
    }
    else {
        store = self.acvtNewStore;
    }
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *filterBean = [[service queryAcvtsWithStoreId:store.Id filter:fb.filter] firstObject];
    for (WSAcvtBean_qst *ab_qst in filterBean.qsts) {
        
        if ([ab_qst.qstType isEqualToString:QST_TYPE_GF]) {
            
          if([ab_qst.is_req isEqualToString:@"1"])
              return YES;
        }
    }
    
    return NO;
}

- (UIViewController *)checkNextPageWithFuncsBean:(WSFuncsBean *)fb withShowToast:(BOOL)showToast {
    
    return [self checkNextPageWithFuncsBean:fb withShowToast:showToast isInStore:YES];
}

#pragma mark - 查询下一级菜单方法
- (UIViewController *)checkNextPageWithFuncsBean:(WSFuncsBean *)fb withShowToast:(BOOL)showToast isInStore:(BOOL)isInStore {
    
    if (!fb) {
        return nil;
    }
    
    self.currentStore.inReadonlyMode = NO;
    
    NSString *enableLocation = [[NSUserDefaults standardUserDefaults] objectForKey:ENABLE_LOCATION];
    NSString *isGPS = fb.opt.isGps;
    if (enableLocation != nil && [enableLocation isEqualToString:@"1"]) {
        
        if (fb.opt != nil && isGPS != nil) {
            
            BOOL enterStore = [[WSLocationManager getInstance] checkConfigAndAuthorizationGps:isGPS showAlert:fb.name];
            if (!enterStore) {
                return nil;
            }
            
            WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
            NSString *empId = ([self.subempStore.Id length] > 0 ) ? self.subempStore.Id : [WSAppData getObjectbyKey:APPDATA_EMPID];
            BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:self.currentStore.Id];
            if (!isRequested) {
                isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:self.currentStore.Id];
            }
            
            if (!isRequested && [self gpsIsReq:fb]) {
                
                NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
                if (status == NotReachable) {
                    
                    NSString *openWifiOnGetGps = [[NSUserDefaults standardUserDefaults] objectForKey:OPEN_WIFI_ON_GET_GPS];
                    if([openWifiOnGetGps isEqualToString:@"0"]) {
                        
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"default_net_tip2", nil)
                                                 tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    }
                    else {
                        
                        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"default_net_tip", nil)
                                                 tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                    }
                    return nil;
                }
            }
        }
    }
    
    if (isInStore) {
        
        BOOL isValid = [self checkEnterLeaveStore:fb showToast:showToast];
        if (!isValid) {
            return nil;
        }
    }
    
    NSString *optIndependentShowSub = fb.opt.independentShowSub;
    WSFuncsBean *firstFuncsBean = [fb.funcsArray firstObject];
    if ([optIndependentShowSub isEqualToString:@"Y"] && [firstFuncsBean.fv isEqualToString:@"FV_Bridg_Webview"]) {
        
        NSString *className = [WSPlistHelper valueForKey:firstFuncsBean.fv withPlistName:kControllerMappingFileName];
        UIViewController *vc = [[NSClassFromString(className) alloc] initWithFuncs:firstFuncsBean];
        return vc;
    }
    
    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    if ([fb.fv rangeOfString:@"DT_001"].location != NSNotFound) {
        className = @"WSProdGrideWithExpandableBrandsViewController";
    }

    UIViewController* vc;
    NSString *isAdd = fb.opt.isAdd;
    if (!isAdd || ![isAdd isEqualToString:@"Y"]) {
        
        if ([fb.menuLayout isEqualToString:MENU_LAYOUT_NEXTSTEPS]) {
            
            vc = [[WSNextStepViewController alloc]initWithFuncs:fb Store:self.currentStore];
        }
        else {
            
            vc = [[NSClassFromString(className) alloc] initWithFuncs:fb];
            if ([vc respondsToSelector:@selector(initWithFuncs:Store:)] && self.currentStore) {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore];
            }
            
            if ([vc respondsToSelector:@selector(initWithFuncs:Store:subEmpStore:)] && self.subempStore) {
                
                if (self.currentStore || ![vc isKindOfClass:[BaseViewController class]]) {
                    vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore subEmpStore:self.subempStore];
                } else {
                    vc = [[NSClassFromString(className) alloc] initWithFuncs:fb subEmpStore:self.subempStore];
                }
            }
            
            if ([vc respondsToSelector:@selector(initWithFuncs:Store:acvtNewStore:)] && self.acvtNewStore) {
                vc = [[NSClassFromString(className) alloc] initWithFuncs:fb Store:self.currentStore acvtNewStore:self.acvtNewStore];
            }
        }
    }
    
    if ([fb.fv isEqualToString:@"V20S01"] || [fb.fv isEqualToString:@"V20S99"]) {
        
        if (!fb.filter || [fb.filter length] == 0) {
            
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:@"请使用调查问卷的方式配置进离店(在filter配置相关调查问卷的类型)" tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return nil;
        }
        
        UIViewController *controller = [self rebuildEnterSoreViewControllerIfExistFilter:fb];
        if (controller) {
            vc = controller;
        }
    }
    else {
        
        if ([self.currentFuncs.opt.isVisitCompleteModuleReadonlyTip isEqualToString:@"1"]) {
            
            NSInteger startIndex = 0;
            NSInteger endIndex = 0;
            NSInteger selectFB = 0;
            for (WSFuncsBean *funcBean in self.funcBeanArray) {
                
                if ([funcBean.fv isEqualToString:@"V20S01"]) {
                    startIndex = [self.funcBeanArray indexOfObject:funcBean] ;
                }
                
                if ([funcBean.fv isEqualToString:@"V20S99"]) {
                    endIndex = [self.funcBeanArray indexOfObject:funcBean] ;
                }
                
                if ([funcBean.fv isEqualToString:fb.fv]) {
                    selectFB = [self.funcBeanArray indexOfObject:funcBean] ;
                }
            }
            
            if ([[WSInoutStoreTable sharedTable] isLeaveStore:self.currentStore andOtherParam:self.currentVisitAction.module_fc andParamType:EParameterType_ParentFC] &&
                (startIndex < selectFB && selectFB < endIndex ) && ![fb.fv isEqualToString:REPOPRT_FV] && ![fb.required isEqualToString:REQUIRED_E]) {
                
                NSString *isShipKey = [NSString stringWithFormat:@"isShiped%@",self.currentStore.Id];
                NSString *isShip = [[NSUserDefaults standardUserDefaults] objectForKey:isShipKey];
                if (![isShip isEqualToString:@"1"]) {
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isShipKey];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:nil tips:NSLocalizedString(@"func_readonly", nil) tapTarget:nil action:nil
                                             type:MBProgressHUDMessageTypeFailed autoHideTime:1.5f];
                }
            }
        }
    }
    
    if ([fb.fv rangeOfString:@"DT_001"].location != NSNotFound) {
        vc = [[WSProdGrideWithExpandableBrandsViewController alloc] initWithFuncs:fb Store:self.currentStore];
    }
    
    if (vc == nil) {
        
        LogInfo(@"className no support :%@", fb.fv);
        
        if (fb.opt.isAdd!=nil && [fb.opt.isAdd isEqualToString:@"N"] == NO) {
            vc = [[WSNewAddListViewController alloc]  initWithFuncs:fb Store:self.currentStore withSubEmpId:self.subempStore.Id];
        }
        else {
            
            if ([fb.isAcvtList isEqualToString:@"1"]) {
               
                NSArray *filtersArray = [WSAcvtListViewController filterAcvtListWithCurrentFuncs:fb withCurrentStore:self.currentStore];
                if ([filtersArray count] > 1) {
                    vc = [[WSAcvtListViewController alloc] initWithFuncs:fb Store:self.currentStore];
                }
                else if ([filtersArray count] == 1) {
                    
                    if (self.acvtNewStore) {
                        vc = [[WSAcvtViewController alloc] initWithAcvt:[filtersArray objectAtIndex:0] Funcs:fb Store:self.currentStore acvtNewStore:self.acvtNewStore];
                    } else {
                        vc = [[WSAcvtViewController alloc] initWithAcvt:[filtersArray objectAtIndex:0] Funcs:fb Store:self.currentStore SubEmpId:self.subempStore.Id];
                    }
                }
                else {
                    vc = [[WSAcvtViewController alloc] initWithAcvt:nil Funcs:fb Store:self.currentStore];
                }
            }
            else if ([fb.isAcvtList isEqualToString:@"2"]) {
                vc = [[WSAcvtGridViewController alloc] initWithFuncs:fb Store:self.currentStore];
            }
            else {
                
                LogInfo(@"Go into class 2 fb.ds：%@ == %@\n", fb.ds, [WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]);
                if (self.currentStore) {
                    vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]) alloc] initWithFuncs:fb Store:self.currentStore subEmpStore:self.subempStore];
                } else {
                    vc = [[NSClassFromString([WSPlistHelper valueForKey:fb.ds withPlistName:kControllerMappingFileName]) alloc] initWithFuncs:fb];
                }
                [vc setShowActionTip:YES];
            }
        }
    }
    
    if ([vc isKindOfClass:[BaseViewController class]]) {
        BaseViewController *bsvc = (BaseViewController *)vc;
        bsvc.moduleFC = self.moduleFC;
    }
    else if ([vc isKindOfClass:[SuperWorkSpaceViewController class]]) {
        SuperWorkSpaceViewController *bsvc = (SuperWorkSpaceViewController *)vc;
        bsvc.moduleFC = self.moduleFC;
    }
    
    if ([vc isKindOfClass:[WSMV_LISTViewController class]]) {
        
        WSMV_LISTViewController *mvListCon = (WSMV_LISTViewController *)vc;
        if (self.currentVisitAction.fromModuleName.length>0&&self.currentVisitAction.fromModuleName ) {
            mvListCon.fromModuleName = self.currentVisitAction.fromModuleName;
        }
        [mvListCon initData];
        
        if ([mvListCon itemCount] == 1 && [mvListCon.currentFuncs.menuLayout isEqualToString:MENU_LAYOUT_TAB]) {
            UIViewController *nextViewController = [mvListCon generateNextPageWithRow:0];
            vc = nextViewController;
        }
    }
    
    if ([vc respondsToSelector:@selector(setSubempid:)]) {
        [vc performSelector:@selector(setSubempid:) withObject:self.subempStore.Id];
    }
    
    return vc;
}

- (BOOL)checkEnterLeaveStore:(WSFuncsBean *)fb showToast:(BOOL)showToast {
    
    if ([fb.required isEqualToString:kRequrid_Directaccess]) {
        return YES;
    }
    
    BOOL hasV20S99 = NO;
    for (WSFuncsBean *funcsbean in self.funcBeanArray) {
        
        if ([funcsbean.fv isEqualToString:LEAVESTORE_FV]) {
            hasV20S99 = YES;
            break;
        }
    }
    
    if (hasV20S99) {

        NSString *detectFc = self.moduleFC;
        if ([[WSInoutStoreTable sharedTable] queryFunCodeListWithCurrentFunCode:self.moduleFC].length>0) {
            detectFc = [[WSInoutStoreTable sharedTable] queryFunCodeListWithCurrentFunCode:self.moduleFC];
        }
        
        if (self.input_reflect_code && [self.input_reflect_code length] > 0) {
            
            if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                detectFc = self.input_reflect_code;
            }
        }
        
        BOOL isEnterStore = [[WSInoutStoreTable sharedTable] isEnterStore:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC];
        NSString *leaveTime = [[WSInoutStoreTable sharedTable] getLeaveStoreTime:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC];
        if (isEnterStore && self.isTabMode) {
            
            if (leaveTime && ![leaveTime isEqualToString:@"null"] && ![fb.fv isEqualToString:ENTERSTORE_FV]) {
                isEnterStore = NO;
            }
        }
        
        if ((!isEnterStore) && (![fb.fv isEqualToString:ENTERSTORE_FV]) && ([fb.opt.isCheckEnterStore isEqualToString:@"1"])) {
            
            if (showToast) {
                
                NSString *EnterStoreString = NSLocalizedString(@"not_enter_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:EnterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return NO;
        }
  
//        if (!isEnterStore && (![fb.fv isEqualToString:ENTERSTORE_FV]) && ![fb.required isEqualToString:@"E"]) {
//            
//            if (showToast) {
//                
//                NSString *EnterStoreString = NSLocalizedString(@"not_enter_store",nil);
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:EnterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            }
//            return NO;
//        }
  
        if ([leaveTime isEqualToString:@"null"] && [fb.fv isEqualToString:ENTERSTORE_FV]) {
            
            if (showToast) {
                
                NSString *leaveStoreString = NSLocalizedString(@"not_leave_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:leaveStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return NO;
        }
        
        NSString *enterTime = [[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:detectFc andParamType:EParameterType_ParentFC];
        if (([enterTime compare:leaveTime] == NSOrderedSame) &&([fb.fv isEqualToString:LEAVESTORE_FV])) {
            
            if (showToast) {
                NSString *enterStoreString = NSLocalizedString(@"not_enter_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:enterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return NO;
        }
        //添加未重新进入门店就能进入离开门店的问题
        if (![self.currentStore.actionState isEqualToString:ActionWorking]&&[fb.fv isEqualToString:LEAVESTORE_FV]) {
            if (showToast) {
                NSString *enterStoreString = NSLocalizedString(@"not_enter_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:enterStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return NO;
        }

        
        if (([enterTime compare:leaveTime] == NSOrderedDescending) &&([fb.fv isEqualToString:ENTERSTORE_FV])) {
            
            if (showToast) {
                NSString *leaveStoreString = NSLocalizedString(@"not_leave_store",nil);
                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:leaveStoreString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            }
            return NO;
        }

        if (leaveTime && ![leaveTime isEqualToString:@"null"] && ![fb.fv isEqualToString:ENTERSTORE_FV] && ![fb.required isEqualToString:@"E"]) {
            self.currentStore.inReadonlyMode = YES;
        }
    }
    
    return YES;
}

- (BOOL)gotoNextPageWithViewController:(UIViewController *)tmpVc withFuncsBean:(WSFuncsBean *)fb withAutoJump:(BOOL)isAuto {
    
    BaseViewController *controller = [self getValidNextControllerWithVC:tmpVc withFuncsBean:fb withAutoJump:isAuto];
    if (!controller) {
        return NO;
    }
    
    if ([fb.fv isEqualToString:ENTERSTORE_FV]) {

        NSString *maxCallNumString = [WSAppData getObjectbyKey:APPDATA_MAXCALLNUM];
        BOOL isNeedShowMaxCallNumAlert = NO;
        if (maxCallNumString && [maxCallNumString integerValue] > 0) {
            
            NSArray *storeIdArray = [[WSInoutStoreTable sharedTable] queryVisitedStoreIdArray];
            if ([storeIdArray count] >= [maxCallNumString integerValue] && ![storeIdArray containsObject:self.currentStore.Id]) {
                isNeedShowMaxCallNumAlert = YES;
            }
        }
        
        if (isNeedShowMaxCallNumAlert) {
            
            if (!isAuto) {
                
                BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:[NSString stringWithFormat:NSLocalizedString(@"visit_count_exceed_max", nil), [maxCallNumString integerValue]]];
                [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label",nil) block:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                    [self gotoUpdateMenuOrPushViewController:controller isAutoJump:isAuto fb:fb];
                }];
                [alert show];
            }
        }
        else {
            
            NSString *detect_code = self.moduleFC;
            if (self.input_reflect_code) {
                
                if (![self.moduleFC isEqualToString:self.input_reflect_code]) {
                    detect_code = self.input_reflect_code;
                }
            }
            
            NSArray *fcList = [[[WSSqliteUtil alloc] init] queryParentfcWithCurrentfc:detect_code];
            if (fcList.count > 0) {
                detect_code = [fcList componentsJoinedByString:@","];
            }
            
            if ([self isVisitedStore:self.currentStore withParentFuncCode:detect_code]) {
                
                if (!isAuto) {
                    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:NSLocalizedString(@"enterpos_dialog_message", nil)];
                    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel_label",nil) block:nil];
                    [alert addButtonWithTitle:NSLocalizedString(@"confirm", nil) block:^{
                        [self gotoUpdateMenuOrPushViewController:controller isAutoJump:isAuto fb:fb];
                    }];
                    [alert show];
                }
            }
            else {
                [self gotoUpdateMenuOrPushViewController:controller isAutoJump:isAuto fb:fb];
            }
        }
    }
    else {
        
        [self gotoUpdateMenuOrPushViewController:controller isAutoJump:isAuto fb:fb];
    }
    
    return YES;
}

- (BaseViewController *)getValidNextControllerWithVC:(UIViewController *)tmpVc withFuncsBean:(WSFuncsBean *)fb withAutoJump:(BOOL)isAuto {
    
    return [self getValidNextControllerWithVC:tmpVc withFuncsBean:fb withAutoJump:isAuto isInStore:YES];
}

- (BaseViewController *)getValidNextControllerWithVC:(UIViewController*)tmpVc withFuncsBean:(WSFuncsBean*)fb withAutoJump:(BOOL)isAuto isInStore:(BOOL)isInStore {

    if (tmpVc == nil) {
        return nil;
    }
    
    BaseViewController *controller = (BaseViewController *)tmpVc;
    controller.currentStore = self.currentStore;
    if ([controller isKindOfClass:[BaseViewController class]]) {
        controller.relate_sub_menu_code = self.input_reflect_code;
    }

    LogInfo(@"Go into class %@\n", [tmpVc className]);
    if (![fb.name isEqualToString:@"离开门店"]) {
        controller.title = fb.name;
    }
    
    WSVisitStoreActionObject *action = [self queryVisitActionObjectWithFuncsBean:fb];
    action.ID = (int)[[WSVisitStoreActionTable sharedTable] queryActionId:action];
    LogInfo(@"actionId：%d",action.ID);
//    if (isInStore && [self.currentFuncs.opt.isSeq isKindOfClass:[NSString class]] && [self.currentFuncs.opt.isSeq isEqualToString:@"1"] && [fb.required isEqualToString:@"R"]) {
//        
//        NSArray *arr = [[WSVisitStoreActionTable sharedTable] getPreRequiredUndoneAction:action];
//        if ([arr count] > 0) {
//            
//            if (!isAuto) {
//                NSString *TakePhotoString = NSLocalizedString(@"pls_fill_According_list", nil);
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:TakePhotoString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//            }
//            return nil;
//        }
//    }
    
    if (isInStore && [fb.fv isEqualToString:LEAVESTORE_FV] && [fb.required isEqualToString:@"R"]) {
        
        NSArray *notcompleteArray = [[WSVisitStoreActionTable sharedTable] queryNotCompleteButRequiredAction:action];
        if (notcompleteArray && [notcompleteArray count] > 0) {
            
            WSFuncsBean *enterStoreFuncsBean;
            for (WSFuncsBean *funcsBean in self.funcBeanArray) {
                
                if ([funcsBean.fv isEqualToString:ENTERSTORE_FV]) {
                    enterStoreFuncsBean = funcsBean;
                    break;
                }
            }
            
            NSInteger count = 0;
            NSString *promt = @"";
            for (WSVisitStoreActionObject *subAction in notcompleteArray) {
                
                if (![subAction.func_code isEqualToString:fb.fc] && ![subAction.func_code isEqualToString:enterStoreFuncsBean.fc]) {
                    
                    if (!subAction.dict_id) {
                        
                        if (count > 0) {
                            promt = [promt stringByAppendingFormat:@","];
                        }
                        promt = [promt stringByAppendingFormat:@"%@", subAction.title];
                    }

                    count++;
                }
            }
            
            if (![promt isEqualToString:@""]) {
                
                if (!isAuto) {
                    promt = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"not_reported_info", nil) ,promt];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:promt tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
                return nil;
            }
        }
        
        NSString *notFillFuncs = [self checkNotFillFromMustFillFuncs];
        if ([notFillFuncs length] > 0) {
            
            if (!isAuto) {
                
                if ([notFillFuncs isEqualToString:@"(null)"]||[notFillFuncs isKindOfClass:[NSNull class]]||[notFillFuncs containsString:@"null"]) {
                    
                    NSString *text = [NSString stringWithFormat:@"请按顺序填写，如果还是无法离店，就填写未拜访原因离店"];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
                else {
                    
                    NSString *text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"not_reported_info", nil) ,notFillFuncs];
                    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                }
            }
            
            return nil;
        }

        NSString *notFillNames =[self checkNotFillFromMustFillAcvt];
        if ([notFillNames length] > 0) {
            
            NSString *text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"not_reported_info", nil) ,notFillNames];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return nil;
        }
    }
    
    if ([controller isKindOfClass:[BaseViewController class]]) {
        
        BaseViewController *bsvc = (BaseViewController *)controller;
        bsvc.moduleFC = self.moduleFC;
    }
    else if ([controller isKindOfClass:[SuperWorkSpaceViewController class]]) {
        
        SuperWorkSpaceViewController *bsvc = (SuperWorkSpaceViewController *)controller;
        bsvc.moduleFC = self.moduleFC;
    }
    controller.currentVisitAction = action;
    controller.realParentFuncsCode = self.realParentFuncsCode;
    
    return controller;
}

- (void)gotoUpdateMenuOrPushViewController:(UIViewController *)controller isAutoJump:(BOOL)isAutoJump fb:(WSFuncsBean *)fb {
    
    if (!fb.opt.updateMenu || [fb.opt.updateMenu length] == 0) {
        
        [self pushViewController:controller isAutoJump:isAutoJump];
    }
    else {
        
        self.updateMenuIsAutoJump = isAutoJump;
        self.updateMenuController = controller;
        [self startUpdateStoreWithFb:fb];
    }
}

- (void)pushViewController:(UIViewController *)controller isAutoJump:(BOOL)isAutoJump {
    
    if (self.wsSplitController) {
        
        if ([self isKindOfClass:[WSSubMenuViewController class]]) {
            
            WCNavigationController* navController = [[WCNavigationController alloc] initWithRootViewController:controller];
            UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_BUTTON_WH, 0, MAIN_BUTTON_WH, 44)];
            [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
            controller.navigationItem.leftBarButtonItem = homeButtonItem;
            
            [self.wsSplitController presentViewController:navController animated:YES completion:nil];
            
        }
        else if ([controller isKindOfClass:[WSEnterStoreViewController class]] || [controller isKindOfClass:[WSEnterStoreAcvtViewController class]] ||
                 [controller isKindOfClass:[WSLeaveStoreViewController class]] || [controller isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
            
            WSPopViewController *popCon = [[WSPopViewController alloc] initWithContentViewController:(WCBaseViewController *)controller];
            if ([controller isKindOfClass:[WSAcvtViewController class]]) {
                popCon.confirmSelector = @selector(executeUpload);
            }
            else {
                popCon.confirmSelector = @selector(upload);
            }
            popCon.delegate = self;
            popCon.popViewSize = CGSizeMake(600, 520);
            
            if (IOS8_OR_LATER) {
                popCon.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            else {
                self.wsSplitController.modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            
            [self.wsSplitController presentViewController:popCon animated:YES completion:nil];
        }
        else {
            
            if ([controller isKindOfClass:[WCBaseViewController class]]) {
                ((WCBaseViewController *)controller).wsSplitController = self.wsSplitController;
            }
            else if ([controller isKindOfClass:[VisitDoctorViewController class]]) {
                ((VisitDoctorViewController *)controller).wsSplitController  = self.wsSplitController;
            }
            WCNavigationController *nav = [[WCNavigationController alloc] initWithRootViewController:controller];
            [self.wsSplitController showRightController:nav];
        }
    }
    else {
        
        controller.hidesBottomBarWhenPushed = YES;
        if (self.currentFuncs.opt.suggestOrderNode.length>0&&[controller isKindOfClass:[WinJSBridgeViewController class]]) {
            WinJSBridgeViewController * jsVC = (WinJSBridgeViewController*)controller;
            jsVC.isNotAllowSideslipBack = YES;
            @weakify_self;
            [jsVC setBackBlcok:^{
                @strongify_self;
                [self loadSuggestOrderInfo];
            }];
        }

        if (isAutoJump) {
            
            if (self.navigationController.viewControllers.count > 1) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:controller animated:YES];
                });
            }
        }
        else {
    
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (UIViewController *)rebuildEnterSoreViewControllerIfExistFilter:(WSFuncsBean *)fb {
    
    WSStoreBean *store;
    if (!self.acvtNewStore) {
        store = self.currentStore;
    }
    else {
        store = self.acvtNewStore;
    }
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *filterBean = [[service queryAcvtsWithStoreId:store.Id filter:fb.filter] firstObject];
    UIViewController *viewController = nil;
    if (filterBean && filterBean.acvtId) {
        
        if ([fb.fv isEqualToString:@"V20S01"]) {
            viewController = [[WSEnterStoreAcvtViewController alloc] initWithAcvt:filterBean Funcs:fb Store:store];
        }
        else if ([fb.fv isEqualToString:@"V20S99"]) {
            viewController = [[WSLeaveStoreAcvtViewController alloc] initWithAcvt:filterBean Funcs:fb Store:store];
        }
        [(BaseViewController *)viewController setCurrentSubEmpStore: self.subempStore];
    }
    
    return viewController;
}

- (NSString *)getFuncsId {
    
    NSString *sql = [NSString stringWithFormat:@"select *from base_funcs where fc = '%@'",self.currentFuncs.fc];
    FMResultSet *rs = [[WSFMDatebase getInstance]executeQueryWithSql:sql];
    NSMutableArray *names = [NSMutableArray array];
    while ([rs next]) {
        
        NSString *acvtName = [rs stringForColumn:@"_id"];
        [names addObject:acvtName];
    }
    
    NSString *parentId = [names firstObject];
    return parentId;
}

- (NSString *)getQueryStypByStyp:(NSString *)styp {
    
    if (!styp || [styp length] == 0) {
        return @"";
    }
    
    NSString *stypReplaceStr = @"";
    NSArray *stypReplaces = [styp componentsSeparatedByString:@"-"];
    if ([stypReplaces count] > 0) {
        stypReplaceStr = [NSString stringWithFormat:@" or styp ='%@'", stypReplaces[0]];
    }
    
    NSString *like_StypStr = [NSString stringWithFormat:@" and (styp = '%@' or styp is null or styp like '%%%@,%%' %@)", styp, styp, stypReplaceStr];
    return like_StypStr;
}

- (NSString *)checkNotFillFromMustFillAcvt {
        
    NSString *parentId = [self getFuncsId];
    WSBaseAcvtDBService *acvt_service = [[WSBaseAcvtDBService alloc]init];
    NSString *styp = [self getQueryStypByStyp:self.currentStore.styp];
    NSString *notFillNames = [acvt_service queryNotFillFromMustFillAcvtStoreId:self.currentStore.Id withParentId:parentId withStoreType:styp];
    return notFillNames;
}

- (NSString *)checkNotFillFromMustFillFuncs {
    
    NSString *funcsId = [self getFuncsId];
    NSString *styp = [self getQueryStypByStyp:self.currentStore.styp];
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSArray *keyArray = @[@"$storeId$", @"$funcsId$", @"$func_styp$", @"$emp_id$"];
    NSArray *valueArray = @[[NSString stringNotNilWithValue:self.currentStore.Id], [NSString stringNotNilWithValue:funcsId], [NSString stringNotNilWithValue:styp],[NSString stringNotNilWithValue:empId]];
    if ([keyArray count] != [valueArray count]) {
        return nil;
    }
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"QuerySql.plist" ofType:nil];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *sql = [plistDict objectForKey:@"notFillFuncsQuerySql"];
    for (int i = 0; i < keyArray.count ; i++) {
        sql = [sql stringByReplacingOccurrencesOfString:keyArray[i] withString:valueArray[i]];
    }
    LogInfo(@"checkNotFillFromMustFillFuncs sql：%@",sql);
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    NSString *names = @"";
    NSInteger count = 0;
    while ([rs next]) {
        
        NSString *funcsName = [rs stringForColumn:@"a.name"];
        if (count > 0) {
            names = [names stringByAppendingString:@","];
        }
        names = [names stringByAppendingFormat:@"%@", funcsName];
        count++;
    }
    return names;
}

- (WSVisitStoreActionObject *)queryVisitActionObjectWithFuncsBean:(WSFuncsBean *)funcsBean {
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
        
        if (self.currentStore.Id && !self.input_reflect_code) {
            action.parent_action_id = 0;
        }
        else {
            action.parent_action_id = self.currentVisitAction.ID;
        }
        
        if (self.currentVisitAction && [self.currentVisitAction.module_fc length] > 0 && !(self.currentStore.mappingStoreListFV && [self.currentStore.mappingStoreListFV isEqualToString:@"TAB_V8003"])) {
            action.parent_action_id = self.currentVisitAction.ID;
        }
    }
    else {
        
        action.parent_action_id = self.currentVisitAction.ID;
    }
    
    NSString *entryid = nil;
    if ([self.currentStore isKindOfClass:[WSStoreBean class]]) {
        entryid = self.currentStore.Id;
    }
    else {
        entryid = @"";
    }
    
    if (self.acvtNewStore) {
        action.newstore_id = self.acvtNewStore.Id;
    }
    
    action.store_id = entryid;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    if (funcsBean.required && [funcsBean.required isEqualToString:@"R"]) {
        
        NSArray *specVCArray = [NSArray arrayWithObjects:@"TAB_V17001",@"TAB_V8001",@"V20A01", nil];
        if ([specVCArray containsObject:funcsBean.fv]) {
            
            BOOL isExist = [self isExistNewAcvtAndAcvtListWithFuncsBean:funcsBean withStoreBean:self.currentStore];
            if (!isExist && ![funcsBean.hiddenEmpty isEqualToString:@"1"]) {
                action.is_required = nil;
            }
            else {
                action.is_required = funcsBean.required;
            }
        }
        else {
            action.is_required = funcsBean.required;
        }
    }
    else {
        action.is_required = funcsBean.required;
    }
    
    action.title = funcsBean.name;

    if (self.currentVisitAction && self.currentVisitAction.module_fc && [self.currentVisitAction.module_fc length] > 0) {
        action.module_fc = self.currentVisitAction.module_fc;
    }
    else {
        action.module_fc = action.func_code;
    }
    
    if (self.input_reflect_code && [self.input_reflect_code length]>0) {
        action.module_fc = self.input_reflect_code;
    }
    if (self.currentVisitAction&&self.currentVisitAction.fromModuleName && [self.currentVisitAction.fromModuleName length] > 0) {
        action.fromModuleName = self.currentVisitAction.fromModuleName;
    }

    return action;
}

- (VisitActionStatus)getVisitActionStatusWithFuncsBean:(WSFuncsBean *)funcsBean action:(WSVisitStoreActionObject*)action {
    
    VisitActionStatus status = [[WSVisitStoreActionTable sharedTable] queryActionStatus:action intOutFlag:self.input_reflect_code];
    if ([status isEqualToString:ActionNotStart]) {
        
        WSVisitedMenuArray *visitedMenuArray = [WSAppData getObjectbyKey:VISITED_MENU];
        if ([visitedMenuArray.beanArray count] > 0) {
            
            BOOL isVisited = [visitedMenuArray isFuncsCodeVisited:funcsBean.fc storeId:self.currentStore.Id parentFuncsCode:self.currentFuncs.fc];
            if (isVisited) {
                status = ActionDone;
                [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone inOutFlag:self.input_reflect_code];
            }
        }
    }
    
    return status;
}

- (BOOL)isExistNewAcvtAndAcvtListWithFuncsBean:(WSFuncsBean *)aFuncsBean withStoreBean:(WSStoreBean *)aStoreBean {
    
    WSBaseAcvtDBService *baseAcvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *l_acvtFilters = [baseAcvtDBService queryAcvtsWithStoreId:aStoreBean.Id filter:aFuncsBean.filter];
    WSAcvtBean *newAddAcvtBean = nil;
    NSString *isAdd = [NSString stringWithValue:self.currentFuncs.opt.isAdd];
    if ([isAdd length] > 0 && !([isAdd isEqualToString:@"N"])) {
        
        if ([isAdd isEqualToString:@"Y"]) {
            
            newAddAcvtBean = [l_acvtFilters firstObject];
        }
        else {
            
            WSBaseAcvtDBService *dbService = [[WSBaseAcvtDBService alloc] init];
            newAddAcvtBean = [dbService  queryAcvtWithAcvtCode:self.currentFuncs.opt.isAdd];
            if (newAddAcvtBean == nil) {
                newAddAcvtBean = [dbService queryAcvtByFilter:self.currentFuncs.opt.isAdd acvtCode:nil];
                
            }
        }
    }
    
    if (newAddAcvtBean || ([l_acvtFilters count] == 1 && (aFuncsBean.isAcvtList != nil && [aFuncsBean.isAcvtList isEqualToString:@"1"]))) {
        return YES;
    }
    else if ([l_acvtFilters count] >= 1) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isVisitedStore:(WSStoreBean *)aStore withParentFuncCode:(NSString *)parentFC {
    
    return [[WSInoutStoreTable sharedTable] isLeaveStore:aStore andOtherParam:parentFC andParamType:EParameterType_ParentFC];
}

- (BOOL)hasTipsWithStore:(WSStoreBean *)aStore funcCode:(WSFuncsBean *)fb {
    
    NSString *info = [[NSUserDefaults standardUserDefaults] objectForKey:STORE_TIPS_INFO];
    if (!info) {
        return NO;
    }
    
    NSArray *multiArray = [info componentsSeparatedByString:@"@"];
    if ([multiArray count] == 0) {
        return NO;
    }
    
    for (NSString *infoString in multiArray) {
        
        BOOL hasTips = [self hasTipsWithInfo:infoString fb:fb];
        if (hasTips) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)hasTipsWithInfo:(NSString *)infoString fb:(WSFuncsBean *)fb {
    
    NSArray *infoArray = [infoString componentsSeparatedByString:@","];
    if ([infoArray count] != 3) {
        return NO;
    }
    
    NSString *fc = infoArray[0];
    if (![fc isEqualToString:fb.fc]) {
        return NO;
    }
    
    NSString *acvtCode = infoArray[1];
    NSString *qstCode = infoArray[2];
    WSBaseAcvtDBService *acvtDBService = [[WSBaseAcvtDBService alloc] init];
    NSArray *qstArray = [acvtDBService queryQstWithStoreId:self.currentStore.Id acvtCode:acvtCode qstCode:qstCode];
    if (!qstArray || [qstArray count] == 0) {
        return NO;
    }
    
    WSBaseAcvtdisDBService *acvtDisDBService = [[WSBaseAcvtdisDBService alloc] init];
    NSMutableArray *acvtQstArray = [NSMutableArray arrayWithCapacity:qstArray.count];
    for (WSAcvtBean_qst *qst in qstArray) {
        [acvtQstArray addObject:qst.acvtQstId];
    }
    
    NSArray *dataArray = [acvtDisDBService queryQstValueWithStoreId:self.currentStore.Id acvtQstIdArray:acvtQstArray];
    if ([dataArray count] == 0) {
        return NO;
    }
    
    for (NSString *qstAnwser in dataArray) {
        
        if ([qstAnwser isEqualToString:@"1"]) {
            return NO;
        }
    }
    return YES;
}

- (void)dismissController {
    
    if (INTERFACE_IS_PAD && self.presentingViewController.presentingViewController) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)getRequestObjIDWithFb:(WSFuncsBean *)funcBean {
    
    NSString *objId;
    if ([funcBean.opt.sendRequest isEqualToString:@"1"]) {
        
        if (funcBean != nil && funcBean.filter != nil && [funcBean.filter length] > 0) {
            objId = funcBean.filter;
        }
        else {
            objId =  ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME;
        }
    }
    else if ([funcBean.opt.updateMenu length] > 0) {
        objId = funcBean.opt.updateMenu;
    }
    
    self.requestObjID = objId;
    return objId;
}

- (void)startUpdateStoreWithFb:(WSFuncsBean *)fb {
    
    if (!self.currentStore) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRequest:) name:REQUEST_NOTIFY object:nil];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataManagerInfo:self.currentStore.Id withObjId:[self getRequestObjIDWithFb:fb] notifyName:REQUEST_NOTIFY];
    [self querying_messageTips];
}

- (void)finishRequest:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REQUEST_NOTIFY object:nil];
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        
        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    else {
        
        NSDictionary *uploadState = [info objectFromJSONString];
        NSObject *tmpObject = uploadState[self.requestObjID];
        NSDictionary *storeDicInfo = nil;
        if ([tmpObject isKindOfClass:[NSDictionary class]]) {
            storeDicInfo = (NSDictionary *)tmpObject;
        }
        else if ([tmpObject isKindOfClass:[NSArray class]]) {
            storeDicInfo = [(NSArray *)tmpObject firstObject];
        }
        
        [self.currentStore reSetStore:uploadState Key:self.requestObjID];
        [WSStoreDataProcessService processStoreInfoDataToDbWith:self.currentStore info:storeDicInfo];
        
        if (!self.updateMenuController) {
        }
        else {
            [self pushViewController:self.updateMenuController isAutoJump:self.updateMenuIsAutoJump];
            self.updateMenuController = nil;
        }
    }
}

- (void)popViewControllerDidDismiss:(WSPopViewController *)controller isConfirm:(BOOL)isConfirm {
    
    if (isConfirm && self.wsSplitController) {
        
        if ([controller.contentViewController isKindOfClass:[WSLeaveStoreViewController class]] || [controller.contentViewController isKindOfClass:[WSLeaveStoreAcvtViewController class]]) {
            
            [self dismissController];
            return;
        }
    }
    
    if (isConfirm) {
        
        [self reloadView];
        [self reloadHeaderView];
    }
}
#pragma mark - # 建议订单弹框提醒
- (void)loadSuggestOrderInfo{
    LogInfo(@"显示建议订单弹框，门店ID：%@", self.currentStore.Id);
    if (!self.currentStore || !self.currentFuncs) {
        LogError(@"currentStore或currentFuncs为空");
        return;
    }
    @weakify_self;
    [WSRequestTools reqestSuggestOrderListWithObjId:self.currentFuncs.opt.suggestOrderNode storeInfo:self.currentStore success:^(NSObject *model) {
        if (model&&[model isKindOfClass:[WSInventoryResultModel class]]) {
            WSInventoryResultModel * suggestOrderModel = (WSInventoryResultModel*)model;
            if (suggestOrderModel.data.count > 0 || suggestOrderModel.otoData.count > 0) {
                @strongify_self;
                [self p_showAlertViewWithResultModel:suggestOrderModel];
            }else{
                LogError(@"返回数据为空");
            }
        }else{
            LogError(@"返回异常");
        }
        } failure:^(NSString *errorTips) {
            LogError(@"建议订单接口返回error：%@",errorTips);
        }];
}
- (void)p_showAlertViewWithResultModel:(WSInventoryResultModel*)resultModel{
    
    WinWorkPopupType popupType =  WinWorkPopupTypeDefault;
    if (resultModel.otoData.count>0 && resultModel.data.count >0) {
        if (![self isHasShowSuggestOrderPopuView] && ![self isHasShowStockOutPopuView]) {
            //建议订单弹框和缺货提醒弹框都没有显示过
            popupType = WinWorkPopupTypeDouble;
        }else if (![self isHasShowSuggestOrderPopuView] && [self isHasShowStockOutPopuView]){
            //建议订单弹框没有显示过，缺货提醒弹框已经显示过了
            popupType = WinWorkPopupTypeOrder;
        }else if ([self isHasShowSuggestOrderPopuView] && ![self isHasShowStockOutPopuView]){
            //缺货提醒弹框没有显示过，建议订单弹框已经显示过了
            popupType = WinWorkPopupTypeStock;
        }else{
            LogInfo(@"建议订单弹框和缺货提醒弹框都已经显示过了,无需再显示了");
        }
    }
    if (resultModel.data.count>0 && resultModel.otoData.count ==0) {
        if (![self isHasShowSuggestOrderPopuView]) {
            popupType = WinWorkPopupTypeOrder;
        }
    }
    if (resultModel.otoData.count>0 && resultModel.data.count ==0) {
        if (![self isHasShowStockOutPopuView]) {
            popupType = WinWorkPopupTypeStock;
        }
    }
    LogInfo(@"弹框提醒样式--->%u",popupType);
    if (popupType == WinWorkPopupTypeDouble) {
        [self p_showStockOutPopupViewWithPopupType:popupType withResultModel:resultModel];
    }else if (popupType == WinWorkPopupTypeOrder){
        [self p_showSuggestOrderPopupViewWithPopupType:popupType withResultModel:resultModel];
    }else if (popupType == WinWorkPopupTypeStock){
        [self p_showStockOutPopupViewWithPopupType:popupType withResultModel:resultModel];
    }else{
        LogError(@"此类型不需要显示弹框");
    }
}
#pragma mark - # 显示缺货提醒弹框
- (void)p_showStockOutPopupViewWithPopupType:(WinWorkPopupType)popupType withResultModel:(WSInventoryResultModel*)resultModel{
    
    NSString * confirmBtnStr = @"我知道了";
    if (popupType == WinWorkPopupTypeDouble) {
        confirmBtnStr = @"下一步";
    }
    NSString * title = @"O2O策略门店供给提醒";
    @weakify_self;
    WinStockOutPopupConfig *config = [[WinStockOutPopupConfig alloc] init];
    config.setTitle(title)
        .setOtoTableData(resultModel.otoData)
        .setConfirmButtonTitle(confirmBtnStr)
        .setConfirmAction(^{
            LogInfo(@"缺货提醒弹框：用户点击了我知道了");
            NSString * key = [self getPopupViewStateKeyWithFixedString:STOCK_OUT_KEY];
            SET_USER_DEFAULT_OBJECT(@"1",key);
            @strongify_self;
            if (popupType == WinWorkPopupTypeDouble) {
                LogInfo(@"缺货提醒弹框：点击下一步");
                [self p_showSuggestOrderPopupViewWithPopupType:popupType withResultModel:resultModel];
            }
        });
    [WinStockOutPopupView showStockOutPopupViewWithConfig:config];
}
#pragma mark - # 显示建议订单弹框
- (void)p_showSuggestOrderPopupViewWithPopupType:(WinWorkPopupType)popupType withResultModel:(WSInventoryResultModel*)resultModel{
    
    NSString * confirmBtnStr = @"我知道了";
    WinInventoryPopupConfig *config = [[WinInventoryPopupConfig alloc] init];
    config.setTitle(@"")
            .setSubtitle(@"上月建议订单购进详情")
            .setPopupType(WinInventoryPopupTypeOne)
            .setTableData(resultModel.data)
            .setBuyTotalText(resultModel.gjSum)
            .setJYTotalText(resultModel.jySum)
            .setCancelButtonTitle(confirmBtnStr)
            .setCancelAction(^{
                LogInfo(@"建议订单弹框：用户点击了我知道了");
                NSString * key = [self getPopupViewStateKeyWithFixedString:SUGGEST_ORDER_KEY];
                SET_USER_DEFAULT_OBJECT(@"1",key);
            });

    [WinJYOrderDetialPopupView showWithConfig:config];
}
#pragma mark - # 判断今日是否显示过建议订单弹框，YES代表今日显示过了
- (BOOL)isHasShowSuggestOrderPopuView{

    NSString * key = [self getPopupViewStateKeyWithFixedString:SUGGEST_ORDER_KEY];
    NSString * suggestOrderValue = USER_DEFAULT_SAFE_STRING(key);
    if (suggestOrderValue.boolValue) {
        LogInfo(@"门店：%@已经显示建议订单，今日不再显示",self.currentStore.Id);
        return YES;
    }
    return NO;
}
#pragma mark - # 判断今日是否显示过缺货提醒弹框，YES代表今日显示过了
- (BOOL)isHasShowStockOutPopuView{
    
    NSString * key = [self getPopupViewStateKeyWithFixedString:STOCK_OUT_KEY];
    NSString * suggestOrderValue = USER_DEFAULT_SAFE_STRING(key);
    if (suggestOrderValue.boolValue) {
        LogInfo(@"门店：%@已经缺货提醒弹框，今日不再显示",self.currentStore.Id);
        return YES;
    }
    return NO;
}

- (NSString*)getPopupViewStateKeyWithFixedString:(NSString*)fixexString{
    
    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString * biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSString * storeId = self.currentStore.Id.length?self.currentStore.Id:@"";
    NSString * key = [NSString stringWithFormat:@"%@_%@_%@_%@",fixexString,ISNULL(empId),ISNULL(biz_date),storeId];
    return key;
}


@end
