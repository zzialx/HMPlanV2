//
//  WSAcvtDBService.m
//  WinSFA
//
//  Created by yang on 15/4/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtDBService.h"
#import "WSFacTable.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSVisitStoreAcvtTable.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSTestTools.h"
#import "WSDataSourceManager.h"
#import "WSAcvtModel.h"

@implementation WSAcvtDBService

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                             funcCod:(NSString *)fc
                                 md5:(NSString *)md5
{
    return [WSAcvtDBService insertAcvtDatasToDBWithStore:storeBean newStoreBean:nil acvtBean:acvtBean qstValueDic:qstValueDic qstValueDicKeyType:keyType funcCod:fc md5:md5];
}

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                        newStoreBean:(WSStoreBean *)newStoreBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                            funcCod:(NSString *)fc
                                 md5:(NSString *)md5
{
    return [WSAcvtDBService insertAcvtDatasToDBWithStore:storeBean newStoreBean:newStoreBean acvtBean:acvtBean qstValueDic:qstValueDic qstValueDicKeyType:keyType funcCod:fc md5:md5 bizDate:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
}

+ (BOOL)insertAcvtDatasToDBWithStore:(WSStoreBean *)storeBean
                        newStoreBean:(WSStoreBean *)newStoreBean
                            acvtBean:(WSAcvtBean *)acvtBean
                         qstValueDic:(NSDictionary *)qstValueDic
                  qstValueDicKeyType:(WSAcvtQstValueDicKeyType)keyType
                             funcCod:(NSString *)fc
                                 md5:(NSString *)md5
                             bizDate:(NSString *)bizDate
{
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    
    NSString *parentGenId = nil;
    
    NSString *storeId;
    if ([storeBean isKindOfClass:[WSStoreBean class]]) {
        storeId = storeBean.Id;
        if (storeBean.iStoreIdentify != nil)
        {
            NSString *storeid = [NSString stringWithFormat:@"%@_%@", storeBean.Id, storeBean.iStoreIdentify];
            storeId=storeid;
            
        }
    }else if ([storeBean isKindOfClass:[WSHosBean class]]) {
        storeId = [(WSHosBean *)storeBean Id];
    }else if ([storeBean isKindOfClass:[WSSubempstoreBean class]]) {
        storeId = [(WSSubempstoreBean *)storeBean Id];
    }else {
        storeId = @"-1";
    }
    NSString *newStoreId;
    if (newStoreBean) {
        newStoreId = newStoreBean.Id;
    }

    
    for(WSAcvtBean_qst* qst in acvtBean.qsts)
    {
        NSString *key  = nil;
        
        if (keyType == WSAcvtQstValueDicKeyTypeQstTypeAndAcvtqstID) {
            key = [NSString stringWithFormat:@"%@%@",qst.qstType, qst.acvtQstId];
        }else {
            key = qst.acvtQstId;
        }
        
        NSString *value;
        
        if ([qst.qstType isEqualToString:QST_TYPE_GE] ||
            [qst.qstType isEqualToString:QST_TYPE_GF] ){
            NSDictionary *resultDic = [qstValueDic objectForKey:key];
            
            // GE 插入数据库的是address  上传的是 areaID
            if (resultDic) {
                value = [resultDic JSONString];
            }
        }
        else if ([qst.qstType isEqualToString:QST_TYPE_AN] ||
                 [qst.qstType isEqualToString:QST_TYPE_AM] ||
                 [qst.qstType isEqualToString:QST_TYPE_ANX]){
            
            id resultObj = [qstValueDic objectForKey:key];
            
            if (resultObj) {
                if ([resultObj isKindOfClass:[NSString class]]) {
                    value = resultObj;
                }else if ([resultObj isKindOfClass:[NSArray class]]) {
                    value = [resultObj JSONString];
                }
            }
        }
        else
        {
            value = [qstValueDic objectForKey:key];
        }
        
        //(sid,acvtid,acvtqstid,acvt_qst_answer,gen_id,assetid,opt_value,emp_id,biz_date,newStoreId,mClickTime,server_node)
        if (value) {
            
            NSMutableArray *qstDatas = [[NSMutableArray alloc] init];
            
            [qstDatas addObject:[NSString stringNotNilWithValue:storeId]];
            [qstDatas addObject:acvtBean.acvtId];
            [qstDatas addObject:qst.acvtQstId];
            [qstDatas addObject:value];
            [qstDatas addObject:md5];
            
            NSString *parentId = acvtBean.parentgenId;
            parentGenId = parentId;
            [qstDatas addObject:parentId?:[NSNull null]];
            [qstDatas addObject:[NSNull null]];
        
            WSStoreBean *currentStore = nil;
            WSAcvtModel *acvtModel = nil;
            WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
            if ([model isKindOfClass:[WSAcvtModel class]]) {
                acvtModel = (WSAcvtModel *)model;
                currentStore = acvtModel.currentStore;
            }

            NSString *tempEmpId = currentStore.srid.length > 0 ? currentStore.srid : acvtModel.subEmpId;
            NSString *empId = tempEmpId ? tempEmpId :[WSAppData getObjectbyKey:APPDATA_EMPID];
            [qstDatas addObject:[NSString stringNotNilWithValue: empId]];
            [qstDatas addObject:bizDate];
            [qstDatas addObject:[NSString stringNotNilWithValue:newStoreId]];
            [qstDatas addObject:[NSNull null]];
            [qstDatas addObject:[NSString stringNotNilWithValue:acvtModel.currentFuncs.ds]];
            
            [datas addObject:qstDatas];
        }
        
    }
    
    //    LogInfo(@"insert: %@", datas);
    
//    [[WSTestTools getInstance] keepTimeWithKey:@"WSVisitStoreAcvtDataTable:insertOrUpdateDatas"];
    BOOL result = [[WSVisitStoreAcvtDataTable sharedTable] insertOrUpdateDatas:datas genId:md5 andParentGenId:parentGenId];
    
    if (result) {
        NSMutableArray *datas = [[NSMutableArray alloc] init];
        [datas addObject:[NSString stringNotNilWithValue:storeId]];
        [datas addObject:acvtBean.acvtId];
        [datas addObject:bizDate];
        [datas addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        
        if ([storeBean isKindOfClass:[WSStoreBean class]]) {
            [datas addObject:[storeBean.srid length] > 0 ? storeBean.srid : [NSNull null]];
        }else {
            [datas addObject:[NSNull null]];
        }
        
        [datas addObject:fc];
        [datas addObject:md5];
        
        NSArray *acvtDatas = [NSArray arrayWithObject:datas];
        result = [[WSVisitStoreAcvtTable sharedTable] insertOrUpdateDatas:acvtDatas genId:md5];
    }
//    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"WSVisitStoreAcvtDataTable:insertOrUpdateDatas"];
    
    if (result) {
//        [[WSTestTools getInstance] keepTimeWithKey:@"processLocalAcvtDisValue"];
        WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
        [service processLocalAcvtDisValue];
//        [[WSTestTools getInstance] printAndEndTimeIntervalforKey:@"processLocalAcvtDisValue"];
    }
    
    return result;
}

+(BOOL)deleteVisitStoreAcvtDataWithGenId:(NSString *)genId {
    return  [[WSVisitStoreAcvtDataTable sharedTable] deleteWithNames:@[@"gen_id"] ArgumentsValue:@[[NSString stringNotNilWithValue:genId]]];
}


@end
