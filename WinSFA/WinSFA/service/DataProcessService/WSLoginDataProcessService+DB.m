//
//  WSLoginDataProcessService+DB.m
//  WinSFA
//
//  Created by weida on 16/1/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSLoginDataProcessService+DB.h"
#import "WSBaseStoreOtherDataTable.h"
#import "WSReportFormController.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreAcvtDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseProductDBService.h"
#import "WSBaseFunsDBService.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseEmployeDBService.h"
#import "WSBaseMsgStoreDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreDictsDBService.h"
#import "WSBaseProductTable.h"
#import "WSEditableAcvtQstDBService.h"
#import "WSBaseStoreDictdisDBService.h"
#import "WSBaseStoreProddisDBService.h"
#import "WSVisitPlanDBService.h"
#import "WSBaseInstoreProdDBService.h"
#import "WSRichMediaDBService.h"
#import "WSVisitStoreActionTable.h"
#import "WSVisitStoreStatusTable.h"
#import "WSRequestDataCacheTable.h"
#import "WSBaseStoreDataTable.h"
#import "WSBaseStoreOtherDataTable.h"
#import "WSInoutStoreTable.h"
#import "WSFacTable.h"
#import "WSFdtTable.h"
#import "WSFptTable.h"
#import "WSAddProductTable.h"
#import "WSImagePathTable.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSBaseDictsTable.h"
#import "WSBaseStoreTable.h"
#import "WSBaseStoreAcvtTable.h"
#import "WSBaseAcvtTable.h"
#import "WSBaseAcvtQstTable.h"
#import "WSBaseAcvtQstOptTable.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSBaseStoreDictDisTable.h"
#import "WSBaseStoreProdDisTable.h"
#import "WSBaseInStoreProdTable.h"
#import "WSBaseFunsTable.h"
#import "WSTestTools.h"
#import "WSRichMediaOtherInfoTable.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgTypeTable.h"
#import "WSStatisticsManager.h"
#import "WSBaseStoreDistruleDBService.h"
#import "WSBaseEmployeTable.h"
#import "WSBaseStoreVisitPlanTable.h"
#import "WSFuncTipDBService.h"
#import "WSCalendarAlarmDBService.h"
#import "WSStoreChannelTypeDBService.h"
#import "WSBaseStoreInfoDBService.h"
#import "WSAcvtModel.h"
//=================================================================================================================================================================

@implementation WSLoginDataProcessService (DB)

- (void)saveToDataBase:(NSDictionary*)dic {
    
    NSArray *allKeys = dic.allKeys;
    if (!allKeys.count) {
        
        LogError(@"There is no data for saving");
        return;
    }
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_LOGIN_DATA_INSERT_DATABASE forcePrint:YES];

    NSDictionary *nodeToClassMap = @{STORES:[WSBaseStoreDBService class],
                                     STORE_ACVT_RELATION:[WSBaseStoreAcvtDBService class],
                                     STORE_DICTS_RELATION:[WSBaseStoreDictsDBService class],
                                     STORE_DICTS_RELATION_NEW:[WSBaseStoreDictsDBService class],
                                     Store_acvt:[WSBaseAcvtDBService class],
                                     STORE_MSG:[WSBaseMsgStoreDBService class],
                                     @"prods":[WSBaseProductDBService class],
                                     @"dicts":[WSBaseDictsDBService class],
                                     @"msgs":[WSBaseMsgTypeDBService class],
                                     INSTOREPROD:[WSBaseInstoreProdDBService class],
                                     @"funcs2":[WSBaseFunsDBService class],
                                     @"baseemployee":[WSBaseEmployeDBService class],
                                     ACVTDIS:[WSBaseAcvtdisDBService class],
                                     STOREACVTDIS:[WSBaseAcvtdisDBService class],
                                     STOREPRODDIS:[WSBaseStoreProddisDBService class],
                                     STOREDICTDIS:[WSBaseStoreDictdisDBService class],
                                     @"storeacvtdis:visitplan":[WSVisitPlanDBService class],
                                     EDITABLE_ACVTQST:[WSEditableAcvtQstDBService class],
                                     SPE_FUMEITI : [WSRichMediaDBService class],
                                     STORE_DISTRULE:[WSBaseStoreDistruleDBService class],
                                     FUNC_TIP:[WSFuncTipDBService class],
                                     FUNC_Count_TIP:[WSFuncTipDBService class],
                                     CALENDAR_ALARM:[WSCalendarAlarmDBService class],
                                     STORE_CHANNEL_TYPE:[WSStoreChannelTypeDBService class],
                                     PRODUNIT:[WSBaseStoreOtherDataDBService class],
                                     ELECTRONICMEMO:[WSBaseStoreOtherDataDBService class],
                                     PROMOTION:[WSBaseStoreOtherDataDBService class],
                                     SPE_ROUTE:[WSBaseStoreOtherDataDBService class],
                                     SUBMENUIMG:[WSBaseStoreOtherDataDBService class],
                                     SUBMENUIMGCOORDINATE:[WSBaseStoreOtherDataDBService class],
                                     EMPLOYEEINFORMATION:[WSBaseStoreOtherDataDBService class],
                                     STORE_INFO:[WSBaseStoreInfoDBService class],
                                     PROD_SPEC_IMG:[WSBaseStoreOtherDataDBService class],
                                     STORE_NOT_REQUEST:[WSBaseStoreOtherDataDBService class],
                                     STRPTYPDST:[WSBaseStoreOtherDataDBService class],
                                     PRODPRICE:[WSBaseStoreOtherDataDBService class],
                                     PRODUCT_COL:[WSBaseStoreOtherDataDBService class],
                                     PRODUCT_COL_STORE:[WSBaseStoreOtherDataDBService class],
                                     EMP_AREA:[WSBaseStoreOtherDataDBService class],
                                     EMP_ORG:[WSBaseStoreOtherDataDBService class],
                                     STORE_FILTER:[WSBaseStoreOtherDataDBService class],
                                     STORE_PROD_RELATION_SHIP:[WSBaseStoreOtherDataDBService class],
                                     STORE_UPDATE_FLAG:[WSBaseStoreOtherDataDBService class],
                                     STORE_ROUTE_VISIT_STATE:[WSBaseStoreOtherDataDBService class],
                                     FUNC_TIP_POSM:[WSFuncTipDBService class],
                                     };//服务器节点到处理该节点的本地类名映射
    
    /*对解析的节点顺序进行排序*/
    NSArray *nodeOrders = @[STORES,STORE_ACVT_RELATION,STORE_DICTS_RELATION,Store_acvt,FUNCS2,
                            EDITABLE_ACVTQST,SPE_FUMEITI,STORE_DICTS_RELATION_NEW];
    NSMutableArray *orderAllKeys = [NSMutableArray array];
    
    //不需要排序的结点，子线程并行处理插入
    NSArray *nonOrdersArray = @[PRODS,MSGS,DICTS,ACVTDIS,INSTOREPROD,STOREACVTDIS,STOREPRODDIS,STOREDICTDIS,PRODUNIT,PROMOTION,SUBMENUIMG,SUBMENUIMG,EMPLOYEEINFORMATION,PROD_SPEC_IMG,STORE_NOT_REQUEST,STRPTYPDST,PRODPRICE,PRODUCT_COL,PRODUCT_COL_STORE,EMP_AREA,EMP_ORG,STORE_FILTER];

    NSMutableArray *nonOrdersNodesArray = [NSMutableArray array];
    for (NSString *orderKey in nodeOrders) {
        for (NSString *realKey in allKeys) {
            NSArray *keyArray = [realKey componentsSeparatedByString:@":"];
            NSString *subKey = [keyArray firstObject];
            if ([orderKey isEqualToString:subKey]) {
                [orderAllKeys addObject:realKey];
            }
        }
    }
    
    for (NSString *key in allKeys) {
        
        NSArray *keyArray = [key componentsSeparatedByString:@":"];
        NSString *subKey = [keyArray firstObject];
        if ([nonOrdersArray containsObject:subKey]) {
            [nonOrdersNodesArray addObject:key];
        }
        else if (![orderAllKeys containsObject:key]) {
            [orderAllKeys addObject:key];
        }
    }
    
    NSMutableArray *otherDataArry = [[NSMutableArray alloc]initWithCapacity:allKeys.count];
    for (NSString*key in orderAllKeys) {//遍历所有key
        [self processNodeWithKey:key dataDic:dic nodeToClassMap:nodeToClassMap otherDataArray:otherDataArry];
    }

    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t dispatchGroup = dispatch_group_create();
    for (NSString*key in nonOrdersNodesArray) {
        dispatch_group_async(dispatchGroup, dispatchQueue, ^(){
            [self processNodeWithKey:key dataDic:dic nodeToClassMap:nodeToClassMap otherDataArray:otherDataArry];
        });
    }
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);
    
    WSDBService *DB = [WSBaseStoreOtherDataDBService alloc];
    [DB replaceToTableWithDicts:otherDataArry FromNode:nil hasNewData:YES];//保存到OtherDataTable
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_LOGIN_DATA_INSERT_DATABASE forcePrint:YES];
    [[WSTestTools getInstance] keepTimeWithKey:LOG_PROCESS_STOREACVT_DIS_VALUE forcePrint:YES];
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_PROCESS_STOREACVT_DIS_VALUE forcePrint:YES];
    
    [[WSTestTools getInstance] keepTimeWithKey:@"processAcvtQstLuaScript" forcePrint:YES];
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    [acvtService processAcvtQstLuaScript];
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"processAcvtQstLuaScript" forcePrint:YES];
}

- (void)processNodeWithKey:(NSString *)key dataDic:(NSDictionary *)dic nodeToClassMap:(NSDictionary *)nodeToClassMap otherDataArray:(NSMutableArray *)otherDataArry {
    
    WSDBService *DB = nil;
    id Object = dic[key];
    
    //判断是否有新数据（有些表只有真正有服务器的新数据时才应该按genid清除本地数据）
    BOOL hasNewData = NO;
    if (Object && [Object isKindOfClass:[NSArray class]]) {
        if ([Object count] > 0) {
            hasNewData = YES;
        }
    }
    else if (Object && ![Object isKindOfClass:[NSArray class]]) {
        hasNewData = YES;
    }
    
    NSString *nodeName = nil;
    if ([key isEqualToString:@"storeacvtdis:visitplan"]) {

        nodeName = key;
    }
    else {
        NSArray *nodeNames = [key componentsSeparatedByString:@":"];//用冒号分开
        nodeName = [nodeNames firstObject];
    }
    
    BOOL isNormalDataKey = [[nodeToClassMap allKeys] containsObject:nodeName];
    if (isNormalDataKey) {
        
        NSArray *dataArray = nil;
        if ([Object isKindOfClass:[NSArray class]]) {//数组
            dataArray = Object;
        }
        
        if (nodeName) {
            
            Class className = nodeToClassMap[nodeName];
            if (className) {
                
                DB = [className alloc];
                DB.isLoginSendNode = YES;
                [DB replaceToTableWithDicts:dataArray FromNode:key hasNewData:hasNewData];
                
                LogInfo(@"%@结点，数据条数：%ld", key, (unsigned long)[dataArray count]);
            }
        }
    }
    else {
        
        if ([Object isKindOfClass:[NSDictionary class]]) {//字典
            
            for (NSString*subKey in ((NSDictionary*)Object).allKeys) {
                [otherDataArry addObject:@{@"type" :key,
                                           @"item1":subKey,
                                           @"item2":((NSDictionary*)Object)[subKey]}];
            }
        }
        else if ([Object isKindOfClass:[NSArray class]]) {//数组
            
            NSArray *arry = (NSArray *)Object;
            if (1 == arry.count) {//数组只有一个字典，字典只有一对键值,且与key相同
                
                NSDictionary *oneDict = arry[0];
                if ([oneDict isKindOfClass:[NSDictionary class]] && (oneDict.allKeys.count == 1) && [oneDict.allKeys[0] isEqualToString:key]) {
                    [otherDataArry addObject:@{@"type" :WINSFA_SHARE_DATA_TYPE,
                                               @"item1":key,
                                               @"item2":oneDict.allValues[0]}];
                    return;
                }
            }
        }
        else {//就是一个值
            
            [otherDataArry addObject:@{@"type" :WINSFA_SHARE_DATA_TYPE,
                                       @"item1":key,
                                       @"item2":Object?:[NSNull null]}];
        }
    }
}

+ (void)clearBaseDatas {
    
    LogTrace();
    
    [[WSBaseDictsTable sharedTable] deleteAll];
    [[WSBaseStoreTable sharedTable] deleteAll];
    [[WSBaseStoreAcvtTable sharedTable] deleteAll];
    [[WSBaseStoreAcvtDisTable sharedTable] deleteAll];
    [[WSBaseAcvtTable sharedTable] deleteAll];
    [[WSBaseAcvtQstTable sharedTable] deleteAll];
    [[WSBaseAcvtQstOptTable sharedTable] deleteAll];
    [[WSBaseStoreAcvtDisTable sharedTable] deleteAll];
    [[WSBaseStoreDictDisTable sharedTable] deleteAll];
    [[WSBaseStoreProdDisTable sharedTable] deleteAll];
    [[WSBaseInStoreProdTable shareInstance] deleteAll];
    [[WSBaseFunsTable sharedTable] deleteAll];
    [[WSBaseEmployeTable sharedTable] deleteAll];
    [[WSBaseStoreVisitPlanTable sharedTable] deleteAll];
    [[WSBaseStoreOtherDataTable sharedTable] cleanOldDataAboutCityStoreListCount];
    [[WSBaseMsgTable sharedTable] cleanOldData];                                    //公告信息数据清理
    [[WSBaseMsgTypeTable sharedTable] cleanOldData];
    [[WSBaseProductTable sharedTable] deleteAll];                                   //清除产品表数据
}

+ (void)clearOldVisitDatas {
    
    LogTrace();
    
    [[WSInoutStoreTable sharedTable] cleanOldData];             //清除前一天进离店信息
    [[WSVisitStoreStatusTable shareInstance]cleanOldData];
    [[WSVisitStoreActionTable sharedTable] cleanOldData];       //清除前一天拜访步骤标志
    [[WSVisitStoreAcvtDataTable sharedTable] cleanOldData];     //调查问卷数据
    [[WSRequestDataCacheTable sharedTable] cleanOldData];
    [[WSFptTable sharedTable] cleanOldData];
    [[WSFdtTable sharedTable] cleanOldData];
    [[WSImagePathTable sharedTable] cleanOldData];
    [[WSOffLineUploadTable sharedTable] cleanOldData];
    [[WSAddProductTable sharedTable] cleanOldData];
    [[WSCustomTimeTable sharedTable] cleanOldData];
    [[WSBaseStoreOtherDataTable sharedTable] cleanOldData];
    [[WSBaseStoreDataTable sharedTable] cleanOldData];
    [[WSRichMediaOtherInfoTable sharedTable] cleanOldData];     //富媒体点击时间数据
    [WSAcvtModel claerDateEnterBackgroundMark];                 //清除日期后台标识
}

@end
//=================================================================================================================================================================
