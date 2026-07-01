//
//  WSLeaveStoreAcvtViewController.m
//  WinSFA
//
//  Created by heju on 15/12/22.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSLeaveStoreAcvtViewController.h"
#import "WSJSONBuilder.h"
#import "WSRequestHelper.h"
#import "WSEnvrionment.h"
#import "WSBeaconManager.h"
#import "WSStoreBeans.h"
#import "WSInoutStoreTable.h"
#import "WSAlertpolicy.h"
#import "WSBaseModel.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WinJSBridgeViewController.h"
#import "WSBaseFunsDBService.h"
#import "WSAttanceViewModel.h"

#define UPDATA_NOTIFY_FB @"fb_notify"



//======================================================================================================================================================

@interface WSLeaveStoreAcvtViewController ()

@property (nonatomic, copy) NSString *leaveStoreTimeStamp;
@property (nonatomic, strong) WSStoreBean *temp_storebean;
@property (nonatomic, assign) BOOL isShowOrangeAlert;

@end
//======================================================================================================================================================

@implementation WSLeaveStoreAcvtViewController

- (void)loadView {
    
    [super loadView];
    
    WSInoutStoreObject *notleaveStore = [[WSInoutStoreTable sharedTable] getNotLeaveStoreByStoreId:self.currentStore.Id moduleFc:self.currentVisitAction.module_fc];
    if (notleaveStore.visit_id) {
        
        self.model.md5 = notleaveStore.visit_id;
        LogInfo(@"离店:%@,md5:%@ 进店：%@", [self class], self.md5 ,self.model.md5);
    }
    else {
        
        LogError(@"错误，离店时查询不到对应的进店记录，storeId:%@, module_fc:%@", self.currentStore.Id, self.currentVisitAction.module_fc);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.temp_storebean = [self matchStoreBeanForStores];
    [self getVisit_id];
}

- (WSStoreBean *)matchStoreBeanForStores {
    
    WSStoreBeans *storeBeansArray = [WSAppData getObjectbyKey:STORES];
    __block WSStoreBean *storebean = nil;
    [storeBeansArray.storesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        WSStoreBean *storeBean = (WSStoreBean *)obj;
        if ([storeBean.Id isEqualToString:self.currentStore.Id]) {
            storebean = storeBean;
        }
    }];
    
    return storebean;
}

-(void)getVisit_id {
    
    WSInoutStoreObject * notleaveStore = [[WSInoutStoreTable sharedTable] getNotLeaveStoreByStoreId:self.currentStore.Id moduleFc:self.currentVisitAction.module_fc];
    if (notleaveStore.visit_id) {
        
        self.model.md5 = notleaveStore.visit_id;
        LogInfo(@"离店:%@,md5:%@ 进店：%@", [self class], self.md5 ,self.model.md5);
    }
    else {
        
        LogError(@"错误，离店时查询不到对应的进店记录，storeId:%@, module_fc:%@", self.currentStore.Id, self.currentVisitAction.module_fc);
    }
}

- (void)showWaitHudAndDoUpload {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil) tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    
    if ([self respondsToSelector:@selector(setVisitAction)]) {
        [self performSelector:@selector(setVisitAction)];
    }
    
    if ([self.temp_storebean miniumalDuration] == nil) {
        [self performSelector:@selector(executeRealUpload) withObject:nil afterDelay:0.01];
    }
    else {
        [self executeOutStoreImformationPolicy];
    }
}

- (void)executeRealUpload {
    
    if (![self uploadPhotosForTable]) {
        
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    if (![self uploadPhotosForAcvtView:YES]) {
        
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    if (![self uploadDatas]) {
        
        [self showDBErrorTipAndHidAllHud];
        return;
    }
    
    [self updateStoreVisitStaus:VisitStoreDone];
    [self manageActionStatus:self.currentVisitAction];
    [[WSInoutStoreTable sharedTable] updateLeaveStoreTime:self.currentStore andOtherParam:self.model.md5 andParamType:EParameterType_VisitId outTime:@"1"];
    
    if (self.currentStore.beaconUUId) {
        [[WSBeaconManager getInstance] removeBeaconWithStoreId:self.currentStore.Id];
    }
    
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    NSString *tip = NSLocalizedString(@"add_upload_queue", nil);
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tip tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
    
    self.isBackAccrossParent = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ENTER_OR_LEAVESTORE_RELOAD_STORE_LIST object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:END_STORE object:nil userInfo:nil];
    
    [self popToParentOrHome];
}

- (BOOL)uploadDatas {
    
    __block NSMutableDictionary *jsonDataDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    [jsonDataDic setObject:@"1" forKey:@"is"];
    
    NSString *enable_gps = [CLLocationManager locationServicesEnabled] ? @"1" : @"0";
    [jsonDataDic setObject:enable_gps forKey:GPS_ENABLE_GPS];
    
    NSMutableDictionary *newWorkDic = [self getNetWorkStatus];
    [newWorkDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [jsonDataDic setObject:obj forKey:key];
    }];
    
    
    NSMutableDictionary *qstMemoValuesDict = (NSMutableDictionary *)[self.acvtview getAcvtQstMemoValues];
    [qstMemoValuesDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [jsonDataDic setObject:obj forKey:key];
    }];
    
    WSBaseFunsDBService *bsDB = [[WSBaseFunsDBService alloc]init];
    NSString *parentFC = [bsDB getParentFuncsCode:self.currentFuncs.fc];
    if (parentFC && parentFC.length > 0) {
        [jsonDataDic setObject:parentFC forKey:@"parentFc"];
    }
    
    BOOL hasPhoto = [self newAcvtHasPhoto];

    NSString *postData = [WSJSONBuilder buildEnterLeaveStorebyFuncs:self.currentFuncs isPhoto:hasPhoto Store:self.currentStore jsonData:jsonDataDic
                                                                md5:self.model.md5 isUsingDataEntry:YES enterLeaveTime:self.leaveStoreTimeStamp];
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    NSString *newMd5 = [[NSString alloc] initWithFormat:@"%@_LeaveStore_%@", self.currentFuncs.fc, self.model.md5];
    
    BOOL insertDataSucceed = [self insertUploadData:postData URL:URL_UPLOAD MD5:newMd5 IsPhoto:NO NotifyName:notifyID];
    if (!insertDataSucceed) {
        return insertDataSucceed;
    }
    
    [[WSCustomTimeTable sharedTable] updateCustomTimeFinishedWithStoreId:self.currentStore.Id withVisitId:self.model.md5];
    [[WSRequestHelper shareInstance] postRequestOnEnterLeaveStorebyData:postData md5:self.model.md5 notifyName:notifyID];
    
    [self updateExitUpLoadAction];
    
    return YES;
}

- (void)alertpolicyforUpload {
    
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"uploading_prompt", nil)  tips:NSLocalizedString(@"please_wait", nil) tapTarget:self action:nil];
    [self executeRealUpload];
}

- (BOOL)manageActionStatus:(WSVisitStoreActionObject *)visitAction {
    
    WSVisitStoreActionObject *nextRemindAction = visitAction;
    NSArray *arr = [[WSVisitStoreActionTable sharedTable] queryActionsWithObject:nextRemindAction];
    if ([arr count] == 0) {
        
        arr = [[WSVisitStoreActionTable sharedTable] queryActionsWithObjectExceptParentId:nextRemindAction];
        if ([arr count] > 0) {
            
            WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
            WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
            action.parent_action_id = taction .parent_action_id;
            action.store_id = self.currentVisitAction.store_id;
            action.func_code = taction.func_code;
            action.biz_date = taction.biz_date;
            action.emp_id = taction.emp_id;
            action.is_required = taction.is_required;
            action.title = taction.title;
            
            if (self.currentVisitAction && self.currentVisitAction.module_fc && [self.currentVisitAction.module_fc length] > 0) {
                action.module_fc = self.currentVisitAction.module_fc;
            }
            else {
                action.module_fc = action.func_code;
            }
            
            if (self.input_reflect_code && self.input_reflect_code.length >0) {
                action.module_fc = self.input_reflect_code ;
            }
            return [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone];
        }
        
        
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = self.currentVisitAction.parent_action_id;
        action.store_id = self.currentVisitAction.store_id;
        action.func_code = nextRemindAction.func_code;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.is_required = nextRemindAction.is_required;
        action.title = nextRemindAction.title;
        
        if (self.currentVisitAction && self.currentVisitAction.module_fc && [self.currentVisitAction.module_fc length] > 0) {
            action.module_fc = self.currentVisitAction.module_fc;
        }
        else {
            action.module_fc = action.func_code;
        }
        
        if (self.input_reflect_code && self.input_reflect_code.length >0) {
            action.module_fc = self.input_reflect_code ;
        }
        return [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone];
    }
    else {
        
        WSVisitStoreActionObject *taction = [arr objectAtIndex:0];
        WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
        action.parent_action_id = taction .parent_action_id;
        action.store_id = self.currentVisitAction.store_id;
        action.func_code = nextRemindAction.func_code;
        action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
        action.is_required = nextRemindAction.is_required;
        action.title = nextRemindAction.title;
        
        if (self.currentVisitAction && self.currentVisitAction.module_fc && [self.currentVisitAction.module_fc length] > 0) {
            action.module_fc = self.currentVisitAction.module_fc;
        }
        else {
            action.module_fc = action.func_code;
        }
        
        if (self.input_reflect_code && self.input_reflect_code.length >0) {
            action.module_fc = self.input_reflect_code ;
        }
        
        return [[WSVisitStoreActionTable sharedTable] updateAction:action toStatus:ActionDone];
    }
    
    return YES;
}

- (void)executeOutStoreImformationPolicy {
    
    WSAlertpolicy *policy = [[WSAlertpolicy alloc]init];
    NSMutableDictionary *policyDict = [[NSMutableDictionary alloc] init];
    
    NSString *begin_time_str = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.model.md5 andParamType:EParameterType_VisitId]];
    NSString *enterStoreTime = [WSCurrentTime getTimeStringbyMills:[begin_time_str doubleValue]];
    [policyDict setObject:enterStoreTime forKey:@"begin_time_str"];
    
    NSString *end_time_str = [WSCurrentTime getTimeStringbyMills:[self.leaveStoreTimeStamp doubleValue]];
    [policyDict setObject:end_time_str forKey:@"end_time_str"];
    
    NSString *dateStr =[WSCurrentTime getDateString];
    NSArray *nameArray = [self.currentStore.name componentsSeparatedByString:@"-"];
    NSString *storeName =[nameArray objectAtIndex:0];
    
    NSString *title =[NSString stringWithFormat:@"%@-%@\n%@-%@\n在店时间不足%@分钟", self.currentStore.code, storeName, dateStr, end_time_str, self.temp_storebean.miniumalDuration];
    [policyDict setObject:title forKey:@"title"];
    
    [policyDict setObject:IS_CONFIRM_LEAVE_STORE forKey:@"message"];
    [policyDict setObject:self.temp_storebean.miniumalDuration  forKey:@"duration"];
    
    policy.delegate = self ;
    [policy executePolicy:policyDict];
}

- (double)getEnterStoreTime {
    
    NSString *enterTime = [NSString stringWithValue:[[WSInoutStoreTable sharedTable] getEnterStoreTime:self.currentStore andOtherParam:self.model.md5 andParamType:EParameterType_VisitId]];
    if (enterTime != nil && ![enterTime isEqualToString:@""]) {
        return [enterTime doubleValue];
    }
    return [[WSCurrentTime getServerTime] doubleValue];
}

- (double)getLeaveStoreTime {
    
    return [[WSCurrentTime getServerTime] doubleValue];
}

- (void)gotToController:(WCBaseViewController *)wfvc {
    
    wfvc.hidesBottomBarWhenPushed = YES;
    if (self.ownParentViewController) {
        [self.ownParentViewController.navigationController pushViewController:wfvc animated:YES];
    }
    else {
        [self.navigationController pushViewController:wfvc animated:YES];
    }
}
//离店时间规则更新：更新为点击离开门店按钮的时间(助销离店或者其他离店还采用原来的逻辑)
- (void)setStoreExitTime:(NSString*)exitTime{
    
    self.leaveStoreTimeStamp = exitTime;
}


#pragma mark - 重写viewDidLoad方法
- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.isShowOrangeAlert = YES;
    self.leaveStoreTimeStamp = [WSCurrentTime getServerTime];
    ((WSAcvtModel *)self.model).luaExecuteParams = [WSCurrentTime getDateTime];
   
    [self checkVisitTimeAlert];
}
- (void)checkVisitTimeAlert{
    
    BOOL isAdd = [self p_addTimeAlert];
    if (!isAdd&&[self.currentFuncs.opt.sendRequest isEqualToString:@"remote"]) {
        [self startUpdata:self.currentStore];
    }
}
#pragma mark - 检查活动是否采集完成
- (void)checkActivityCollectionState{
    
    if ([self.currentFuncs.opt.sendRequest isEqualToString:FUNCS_OPT_Remote]) {
        
        [self startUpdata:self.currentStore];
    }
    
}
#pragma mark - 离店提醒弹框方法
- (BOOL)p_addTimeAlert {
    
    NSString *role = [WSAttanceViewModel getLoginUserRole];
    if ([role isEqualToString:@"主管"] || [role isEqualToString:@"OM"]) {
        LogInfo(@"主管不再显示小于5分钟的弹框");
        return NO;
    }
    if ([role isEqualToString:@"销售代表"] && ![self.currentVisitAction.fromModuleName isEqualToString:kHelpSales_Name]) {
        LogInfo(@"不是助销模块的离店，离店不再显示小于5分钟的弹框");
        return NO;

    }
    
    double enterTime = [self getEnterStoreTime];
    double leaveTime = [self getLeaveStoreTime];
    double minDiff = leaveTime - enterTime;
    if (minDiff < 5 * 60) {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"当前在店时长少于5分钟，是否继续？", nil) message:nil];
        @weakify_self;
        [alert setCancelButtonWithTitle:@"否" block:^{
            @strongify_self;
            [self backToParent];
        }];
        [alert addButtonWithTitle:@"是" block:^{
            @strongify_self;
            if ([self.currentFuncs.opt.sendRequest isEqualToString:@"remote"]) {
                [self startUpdata:self.currentStore];
            }else{
                LogError(@"不需要校验完美活动是否采集，直接离开门店");
            }
        }];
        [alert show];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - 请求数据方法
- (void)startUpdata:(WSStoreBean*)store{
    
    [self querying_messageTips];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishRequest:) name:UPDATA_NOTIFY_FB object:nil];
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    if (self.currentFuncs.styp && [self.currentFuncs.styp length] > 0) {
        [uploadMgr appUpdataManagerInfo:store StoreIds:nil subempId:nil withObjId:self.currentFuncs.ds notifyName:UPDATA_NOTIFY_FB styp:self.currentFuncs.styp timeout:0];
    }
    else {
        [uploadMgr appUpdataManagerInfo:store StoreIds:nil subempId:nil withObjId:self.currentFuncs.ds notifyName:UPDATA_NOTIFY_FB styp:nil timeout:0];
    }
}

#pragma mark - 请求回调方法
- (void)finishRequest:(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATA_NOTIFY_FB object:nil];
    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0) {
        
        NSString *tmpString = [error ws_localizedDescription];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSDictionary *uploadState = [info objectFromJSONString];
    NSString *objId = self.currentFuncs.ds;
    
    if (self.currentStore != nil) {
        [self.currentStore reSetStore:uploadState Key:objId];
    }
    
    NSObject *tmpObject = uploadState[objId];
    NSDictionary *storeDicInfo = nil;
    if ([tmpObject isKindOfClass:[NSDictionary class]]) {
        
        storeDicInfo = (NSDictionary *)tmpObject;
    }
    else if ([tmpObject isKindOfClass:[NSArray class]]) {
        
        NSArray *array = (NSArray *)tmpObject;
        for (int i = 0; i < array.count; ++i) {
            
            id arrayObj = [array objectAtIndex:i];
            if ([arrayObj isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *arrayObjDic = (NSDictionary *)arrayObj;
                NSString *msg = [arrayObjDic objectForKey:@"msg"];
                if (msg.length == 0) {
                    continue;
                }
                
                storeDicInfo = arrayObjDic;
                break;
            }
        }
    }

    [self addAlertWithResultDic:storeDicInfo];
}

#pragma mark - 弹框提醒方法
- (void)addAlertWithResultDic:(NSDictionary *)resultDic {
    
    if (resultDic.allKeys.count == 0) {
        return;
    }
    
    NSString *msg = [resultDic objectForKey:@"msg"];
    if (msg.length == 0) {
        return;
    }
    
    NSString *url = [resultDic objectForKey:@"url"];
    NSString *orangeState = [NSString stringWithFormat:@"%@", [resultDic objectForKey:@"state"]];
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"提示" message:msg];
    @weakify_self;

    if ([orangeState isEqualToString:@"2"]) {
        
        [alert setCancelButtonWithTitle:@"确认" block:^{}];
    }
    else {
        
        [alert setCancelButtonWithTitle:@"否" block:^{
            
            @strongify_self;
            if ([orangeState isEqualToString:@"0"]) {
                [self backToParent];
            }
        }];
        
        [alert addButtonWithTitle:@"是" block:^{
            
            @strongify_self;
            if (url.length > 0) {
                
                WinJSBridgeViewController *vc = [[WinJSBridgeViewController alloc] init];
                vc.currentStore = self.currentStore;
                vc.externalOpenUrl = url;
                vc.isNotAllowSideslipBack = YES;
                
                [vc setBackFreshOrangeState:^{
                    [self startUpdata:self.currentStore];
                }];
                
                [self gotToController:vc];
            }
        }];
    }
          
    [alert show];
}

@end
//======================================================================================================================================================
