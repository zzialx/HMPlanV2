//
//  WinStoreInfoTools.m
//  WinSFA
//
//  Created by yuanji on 2022/11/12.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WinStoreInfoTools.h"
#import "WSRequestHelper.h"
#import "WSStoreBean.h"
#import "WSBaseStoreTable.h"
#import "WSBaseStoreDBService.h"
#import "WSNewStoreListTool.h"
#import "WSStoreDataProcessService.h"
#import "WSBaseStoreOtherDataDBService.h"

@implementation WinStoreInfoTools

#pragma mark - 请求门店信息方法
- (void)requestStoreInfoWithStoreId:(NSString *)storeId notifyName:(NSString *)notifyName {
    
    WSStoreBean *storeBean = [[WSStoreBean alloc] init];
    storeBean.Id = storeId;
    
    WSRequestHelper *uploadMgr = [WSRequestHelper shareInstance];
    [uploadMgr appUpdataManagerInfo:storeBean StoreIds:nil subempId:nil withObjId:ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME notifyName:notifyName styp:nil timeout:0];
}

#pragma mark - 解析全部门店数据到数据库方法
- (void)analysisAllStoresInfoToDBWithDictionary:(NSDictionary *)dictionary objId:(NSString *)objId {
    
    id storeBeanInfo = [dictionary objectForKey:@"storeDis"];
    if ([storeBeanInfo isKindOfClass:[NSArray class]]) {
        
        NSArray *array = (NSArray *)storeBeanInfo;
        [[WSBaseStoreTable sharedTable] insertAllStoresWith:array searchObjId:objId searchObjCode:nil isPlan:@"0"];
    }
}

#pragma mark - 查询门店对象方法
- (WSStoreBean *)queryStoreBeanWithStoreId:(NSString *)storeId {
    
    WSBaseStoreDBService *storeService = [[WSBaseStoreDBService alloc] init];
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *storesArray = [storeService queryStoreWithId:storeId andEmpId:empId];
    WSStoreBean *storeBean = [storesArray firstObject];
    return storeBean;
}

#pragma mark - 是否可以拜访门店方法
- (BOOL)isVisitStoreWithStoreId:(WSStoreBean *)storeBean funcsBean:(WSFuncsBean *)funcsBean {
    
    BOOL isForceLeaveStore = [[WSInoutStoreTable sharedTable] isForceLeaveStoreWithStore:storeBean];
    if (isForceLeaveStore) {
        
        NSString *text = NSLocalizedString(@"forceLeaveStore_tip", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:text tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return NO;
    }
    
    if (![WSNewStoreListTool anyStoreHasNotLeave:storeBean andModuleFC:funcsBean.fc withCurrentFuncs:funcsBean]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - 更新当前门店方法
- (void)updateCurrentStoreWithStoreBean:(WSStoreBean *)storeBean storeInfo:(NSDictionary *)dictionary objId:(NSString *)objId {
    
    [storeBean reSetStore:dictionary Key:objId];
}

#pragma mark - 更新当前门店其它数据方法
- (void)updateCurrentStoreOtherDataWithStoreBean:(WSStoreBean *)storeBean storeInfo:(NSDictionary *)dictionary flag:(NSString *)flag {
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    [WSStoreDataProcessService processStoreInfoDataToDbWith:storeBean info:dictionary];
    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:flag empId:empId storeId:storeBean.Id];
}

#pragma mark - 查找门店拜访项方法
- (WSVisitStoreActionObject *)findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean currentVisitAction:(WSVisitStoreActionObject * __nullable)currentAction
                                                      storeId:(NSString *)store_id subMenuFuncsCode:(NSString *)subMenuFuncsCode storeBean:(WSStoreBean *)storeBean {
    
    WSVisitStoreActionObject *action = [[WSVisitStoreActionObject alloc] init];
    action.parent_action_id = currentAction.ID;
    action.store_id = store_id;
    action.func_code = funcsBean.fc;
    action.biz_date = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    action.emp_id = [WSAppData getObjectbyKey:APPDATA_EMPID];
    action.title = funcsBean.name;
    NSString *moduleFC;
    if ([currentAction.module_fc length] > 0) {
        moduleFC = currentAction.module_fc;
    }
    else if([subMenuFuncsCode length] > 0){
        moduleFC = subMenuFuncsCode;
    }
    else {
        moduleFC = funcsBean.fc;
    }
    
    action.module_fc = moduleFC;
    
    if (storeBean.mappingStoreListFV && [storeBean.mappingStoreListFV isEqualToString:@"TAB_V8003"]) {
        action.module_fc = storeBean.mappingStoreListFC;
    }
    
    action.ID = [[WSVisitStoreActionTable sharedTable] queryActionId:action];
    
    return action;
}

@end
