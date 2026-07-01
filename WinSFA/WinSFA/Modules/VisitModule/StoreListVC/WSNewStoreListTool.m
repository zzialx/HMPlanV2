//
//  WSNewStoreListTool.m
//  WinSFA
//
//  Created by sunhf on 2018/1/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSNewStoreListTool.h"
#import "WSConfigParamHelper.h"

@implementation WSNewStoreListTool
#pragma mark - 获得门店准备状态
+ (WSNewStorePrepareState)getStorePrepareStateByStore:(WSStoreBean *)store withWSAcvtBean:(WSAcvtBean *)prepareStateAcvtBean
{
    return [[self class] getStorePrepareStateByStore:store bizDate:[WSAppData getObjectbyKey:APPDATA_BIZDATE] withWSAcvtBean:prepareStateAcvtBean];
}

+ (WSNewStorePrepareState)getStorePrepareStateByStore:(WSStoreBean *)store bizDate:(NSString *)bizDate  withWSAcvtBean:(WSAcvtBean *)prepareStateAcvtBean
{
    WSNewStorePrepareState prepareState = WSNewStorePrepareStateNotPrepare;
    
    if ([store.prepareState length] > 0 && ![store.prepareState isEqualToString:PREPARE_STATE_READY] && ![store.prepareState isEqualToString:PREPARE_STATE_NOT_PREPARE] ) {
        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
        WSDictBean *dict = [service queryDictWithID:store.prepareState];
        store.prepareState = dict.cod;
    }
    
    if ([store.prepareState isEqualToString:PREPARE_STATE_READY]) {
        prepareState = WSNewStorePrepareStateReady;
    }
    
    if (!store.hasGetStateData && prepareState == WSNewStorePrepareStateNotPrepare) {
        
        if (prepareStateAcvtBean) {
            
            if ([prepareStateAcvtBean.acvtCode isEqualToString:STORE_PREPARE_ACVT_CODE]) { //联合利华，使用固定问卷编码stores_zbzt
                //有stores_zbzt这个问卷才去过滤
                WSAcvtBean_qst *qst = [prepareStateAcvtBean getQstBeanByQstCod:STORE_PREPARE_ACVT_CODE];
                if (qst) {
                    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                    NSString *value = [service queryQstValueWithStoreId:store.Id acvtId:prepareStateAcvtBean.acvtId acvtQstId:qst.acvtQstId genId:nil isMatchGenId:NO bizDate:bizDate];
                    
                    if ([value length] > 0) {
                        WSBaseDictsDBService *service = [[WSBaseDictsDBService alloc] init];
                        WSDictBean *db = [service queryDictWithID:value];
                        store.prepareState = db.cod;
                        if ([store.prepareState isEqualToString:PREPARE_STATE_READY]) {
                            prepareState = WSNewStorePrepareStateReady;
                        }
                    }
                }
            }else {//标准产品，可以随意配置问卷，只要问卷有回显值，就认为是已准备
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                if ([service hasValueForStoreId:store.Id acvtId:prepareStateAcvtBean.acvtId]){
                    store.prepareState = PREPARE_STATE_READY;
                    prepareState = WSNewStorePrepareStateReady;
                }
                
            }
            
        }
    }
    return prepareState;
}

#pragma mark - 判断是否有正在拜访中没离店的
+ (BOOL)anyStoreHasNotLeave:(WSStoreBean*)aStore andModuleFC:(NSString *)store_moduleFC withCurrentFuncs:(WSFuncsBean *)currentFuncs
{
    if (![WSConfigParamHelper getIsCheckLeaveStore])
    {
        return YES;
    }
    
    WSInoutStoreObject *inoutStoreObject = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    
    //required校验其他模块是否有未离的店
    BOOL isHaveStoreNotLeave = YES;
    if (inoutStoreObject )
    {
        
        if (![inoutStoreObject.needtip isEqualToString:@"null"]) {
            // 根据渠道过滤不校验的门店， needtip 记录了渠道条件的判断
            isHaveStoreNotLeave = YES;
        }
        //同一个模块，不同门店
        else if ([inoutStoreObject.modulefc isEqualToString:store_moduleFC])
        {
            if (![inoutStoreObject.store_id isEqualToString:aStore.Id])
            {
                isHaveStoreNotLeave = NO;
            }
        }
        else
        {
            //不同模块
//            if (![currentFuncs.required isEqualToString:@"E"])
//            {
//                isHaveStoreNotLeave = NO;
//            }
            if ([currentFuncs.opt.parentStoreFc isEqualToString:@""]||currentFuncs.opt.parentStoreFc == nil) {
                if (![inoutStoreObject.store_id isEqualToString:aStore.Id]) {
                    isHaveStoreNotLeave = NO;
                }
            }else{
                isHaveStoreNotLeave = NO;
            }
        }
    }
    
    if (!isHaveStoreNotLeave) {
        NSString *tip = [NSString stringWithFormat:@"%@%@", inoutStoreObject.memo1, NSLocalizedString(@"not_leave_store", nil)];
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"js_alert_title", nil)
                                 tips:tip tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
    }
    
    return isHaveStoreNotLeave;
}

#pragma mark - 判断当天是否已经拜访过该门店
+ (BOOL)isVisitedStore:(WSStoreBean *)aStore withCurrentFuncs:(WSFuncsBean *)currentFuncs
{
    return [[WSInoutStoreTable sharedTable] isLeaveStore:aStore andOtherParam:currentFuncs.iParentFuncsBean.fc andParamType:EParameterType_ParentFC];
}

#pragma mark - 获得计划外门店的fb
+ (WSFuncsBean*)getSelectedOutPlanFuncsBeanWithStore:(WSStoreBean *)store
{
    WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean *fb = [funcsBeanArray getFuncsBeanWithFC:store.mappingStoreFc];
    return fb;
}

#pragma mark - 判断计划外是否请求过数据
+ (BOOL)isOutPlanRequestWithSubempstoreBean:(WSSubempstoreBean *)subempStore withCurrentStore:(WSStoreBean *)currentStore
{
    WSBaseStoreOtherDataDBService *baseStoreOtherDataDBService = [[WSBaseStoreOtherDataDBService alloc] init];
    NSString *empId = ([subempStore.Id length] > 0 )?subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
    BOOL isRequested = [baseStoreOtherDataDBService isStoreRequested:STORE_NOT_REQUEST empId:empId storeId:currentStore.Id];
    if (!isRequested) {
        isRequested = [baseStoreOtherDataDBService isStoreRequested:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:currentStore.Id];
    }
    return isRequested;
    
}

#pragma mark - 处理更新计划内门店数据库中的相关数据
+ (void)saveInPlanStoreRequestFlagWithSubempStore:(WSSubempstoreBean *)subempStore withCurrentStore:(WSStoreBean *)currentStore withStoreDicInfo:(NSDictionary *)storeDicInfo
{
    [WSStoreDataProcessService processStoreInfoDataToDbWith:currentStore info:storeDicInfo];
    NSString *empId = ([subempStore.Id length] > 0 )?subempStore.Id:[WSAppData getObjectbyKey:APPDATA_EMPID];
    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:WSASVC_OUTPLANSTORE_REQUESTED_FLAG empId:empId storeId:currentStore.Id];
}

#pragma mark - 获得已经离店完成拜访的个数
+ (NSInteger)getCount:(NSArray *)storeListArray withVisitActionStatus:(VisitActionStatus)visitActionStatus
{
    NSPredicate* pre = [NSPredicate predicateWithFormat:@"self.actionState==%@",visitActionStatus];
    NSArray* filterArray = [storeListArray filteredArrayUsingPredicate:pre];
    return [filterArray count];
}
@end
