//
//  WSStoreDataProcessService.m
//  
//
//  Created by yang on 15/12/24.
//
//

#import "WSStoreDataProcessService.h"
#import "WSStoreInfoBeanArray.h"
#import "WSStoreBean.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSBaseStoreAcvtDBService.h"
#import "WSBaseStoreProdDisTable.h"
#import "WSBaseStoreAcvtDisTable.h"
#import "WSBaseStoreDictDisTable.h"
#import "WSBaseInstoreProdDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSBaseStoreAcvtDBService.h"
#import "WSBaseStoreDictdisDBService.h"
#import "WSBaseStoreProddisDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreDBService.h"
#import "WSBaseStoreDistruleDBService.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "NSArray+SQL.h"
#import "WSFuncTipDBService.h"

@implementation WSStoreDataProcessService


+ (void)processStoreDisDataWithDic:(NSDictionary *)uploadState objID:(NSString *)objID storeID:(NSString *)storeID
{
    NSArray *arr = [uploadState objectForKey:objID];
    NSDictionary *dic = [arr objectAtIndex:0];
    
    if([dic objectForKey:STOREDICTDIS]){
        WSStoredDictDisArray *storeDictDisArray = [WSAppData getObjectbyKey:STOREDICTDIS];
        if (storeDictDisArray == nil
            || storeDictDisArray.storedDictDisArray == nil
            || [storeDictDisArray.storedDictDisArray count] < 1 )
        {
            storeDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
            [WSAppData putObject:storeDictDisArray forKey:STOREDICTDIS];
            
        }
        else
        {
            NSArray *sdaArray= [storeDictDisArray.storedDictDisArray copy];
            
            for (WSStoredDictDisBean *item in sdaArray)
            {
                if ([[item.m_p firstObject] isEqualToString:storeID])
                {
                    [storeDictDisArray.storedDictDisArray removeObject:item];
                }
            }
            WSStoredDictDisArray *newStoreDictDisArray = [[WSStoredDictDisArray alloc] initWithObject:dic];
            [storeDictDisArray.storedDictDisArray addObjectsFromArray:newStoreDictDisArray.storedDictDisArray];
        }
        
    }
    
    
}

+ (void)processStoreInfoDataWithDic:(NSDictionary *)uploadState objID:(NSString *)objID filter:(NSString *)filterString
{
    NSArray *newDatasArray = [uploadState objectForKey:objID];
    NSDictionary *newDatas = [newDatasArray firstObject];
    
    //新本地数据集合
    NSMutableArray* newStoreInfoArray= [[NSMutableArray alloc] init];
    
    //本地数据集合
    WSStoreInfoBeanArray *loginStoreInfoBeans = [WSAppData getObjectbyKey:STOREINFOS];
    
    //获取服务器返回的更新信息。
    WSStoreInfoBeanArray *storeinfoBeans = [[WSStoreInfoBeanArray alloc] initWithObject:newDatas];
    
    
    while ([storeinfoBeans.storeinfoArray count] > 0) {
        @autoreleasepool {
            
            WSStoreInfoBean* storeInfo_temp = [storeinfoBeans.storeinfoArray firstObject];
            
            if ((storeInfo_temp.empId && [storeInfo_temp.empId length] > 0)
                && (!storeInfo_temp.storeId || [storeInfo_temp.storeId length] < 1 )) { //处理对账号业务
                
                NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:2];
                
                for (WSStoreInfoBean *temp in loginStoreInfoBeans.storeinfoArray) {
                    if (temp.empId
                        && [temp.empId length] > 0
                        && [temp.empId isEqualToString:storeInfo_temp.empId]) {
                        
                        //如果此业务不提供过滤器字段则，只能获取新信息的类型来处理，尽量缩小匹配范围。
                        NSString * stringFilter = filterString;
                        if (!stringFilter || [stringFilter length] < 1) {
                            
                            stringFilter = storeInfo_temp.typ;
                        }
                        
                        if (stringFilter
                            && [stringFilter length] > 0
                            && [stringFilter isEqualToString:temp.typ]) { //新信息的有类型的，并且能在客户端找到同样类型的旧信息
                            
                            [removeArray addObject:temp];
                        }else if (!stringFilter && !temp.typ){            //新信息是无类型，并且在客户端也存在无类型的旧信息
                            
                            [removeArray addObject:temp];
                        }
                    }
                }
                if ([removeArray count] > 0) {
                    [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                }
                [newStoreInfoArray addObject:storeInfo_temp];
                
            }else if ((storeInfo_temp.storeId && [storeInfo_temp.storeId length] > 0)
                      && (!storeInfo_temp.empId || [storeInfo_temp.empId length] < 1 )){ //处理对店业务 暂时不需要处理
                
                //                目前对店业务只有PI类型表格支持，PI表格的数据在登录时更新。不需要临时请求。
                //                NSMutableArray *removeArray = [NSMutableArray arrayWithCapacity:2];
                //
                //                for (WSStoreInfoBean *temp in loginStoreInfoBeans.storeinfoArray) {
                //                    if (temp.storeId
                //                        && [temp.storeId length] > 0
                //                        && [temp.storeId isEqualToString:storeInfo_temp.storeId]) {
                //
                //                        NSString * stringFilter = filterString;
                //                        if (!stringFilter || [stringFilter length] < 1) {
                //
                //                            stringFilter = storeInfo_temp.typ;
                //                        }
                //
                //                        if (stringFilter
                //                            && [stringFilter length] > 0
                //                            && [stringFilter isEqualToString:temp.typ]) { //新信息的有类型的，并且能在客户端找到同样类型的旧信息
                //
                //                            [removeArray addObject:temp];
                //                        }else if (!stringFilter && !temp.typ){            //新信息是无类型，并且在客户端也存在无类型的旧信息
                //
                //                            [removeArray addObject:temp];
                //                        }
                //                    }/Users/yang/Downloads/cyy/svn/svn_SFA/SFA-iOS-MainBranch-LEEMANPAPER/WinSFA/WinSFA/service/DataProcessService/WSStoreDataProcessService.m
                //                }
                //
                //                if ([removeArray count] > 0) {
                //                    [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                //                }
                //                [newStoreInfoArray addObject:storeInfo_temp];
            }else if ((storeInfo_temp.storeId && [storeInfo_temp.storeId length] > 0)
                      && (storeInfo_temp.empId && [storeInfo_temp.empId length] > 0 )) {
                NSMutableArray* removeArray=[NSMutableArray array];
                [loginStoreInfoBeans.storeinfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WSStoreInfoBean *loginStoreInfo = (WSStoreInfoBean *)obj;
                    if (loginStoreInfo.storeId
                        &&storeInfo_temp.storeId
                        && loginStoreInfo.typ
                        && storeInfo_temp.typ
                        && [loginStoreInfo.storeId isEqualToString:storeInfo_temp.storeId]
                        && [loginStoreInfo.typ isEqualToString:storeInfo_temp.typ]) {
                        [removeArray addObject:loginStoreInfo];
                    }
                    
                }];
                
                [loginStoreInfoBeans.storeinfoArray removeObjectsInArray:removeArray];
                [newStoreInfoArray addObject:storeInfo_temp];
                
            }else{
                
                LogError(@"返回店信息有错误！为了不丢失数据，只能追加=%@" ,storeInfo_temp);
                [newStoreInfoArray addObject:storeInfo_temp];
            }
            
            [storeinfoBeans.storeinfoArray removeObject:storeInfo_temp];
            
        }
        
    }
    
    //追加需要更新的数据。
    [loginStoreInfoBeans.storeinfoArray addObjectsFromArray:newStoreInfoArray];
    [WSAppData putObject:loginStoreInfoBeans forKey:STOREINFOS];
}

+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo {
    
    [WSStoreDataProcessService processStoreInfoDataToDbWith:store info:storeInfo genId:nil];
    
}

// 获取实时请求需要处理的节点名称
+ (NSDictionary *)getHandleStoreInfoKeysAndClass {
    return @{STOREACVTDIS:  @"WSBaseAcvtdisDBService",
             ACVTDIS:       @"WSBaseAcvtdisDBService",
             STOREPRODDIS:  @"WSBaseStoreProddisDBService",
             STOREDICTDIS:  @"WSBaseStoreDictdisDBService",
             ACVTINFO:      @"WSBaseAcvtDBService",
             ACVT:          @"WSBaseStoreAcvtDBService",
             PRODS:         @"WSBaseInstoreProdDBService",
             INSTOREPROD:   @"WSBaseInstoreProdDBService",
             STORES:        @"WSBaseStoreDBService",
             STORE_DISTRULE:@"WSBaseStoreDistruleDBService",
             PROMOTION:     @"WSBaseStoreOtherDataDBService",
             STORE_FILTER:  @"WSBaseStoreOtherDataDBService",
             STORE_MSG:     @"WSBaseMsgStoreDBService",
             ACVTDIS_SPESTORE_UPDATAEECHO : @"WSBaseAcvtdisDBService"
             };
}

// 将多个门店下的节点数据拼接成一个节点下多个门店的数据，用于批量操作数据库
+ (NSDictionary *)convertStoresInfoDictionaryFromStores:(NSArray *)stores {
    NSDictionary *handleDict = [WSStoreDataProcessService getHandleStoreInfoKeysAndClass];
    NSMutableDictionary *storesDicInfo = [[NSMutableDictionary alloc] init];
    
    [stores enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
        NSDictionary *storeDictionary = (NSDictionary *)obj;
        // SFA-7190 YIHAIKERRY-3214 处理实时请求节点数据
        for (NSString *key in [storeDictionary allKeys]) {
            
            NSArray *keyArray = [key componentsSeparatedByString:@":"];
            NSString *subKey = [keyArray firstObject];
            NSString *handleClass = handleDict[subKey];
            if (!handleClass) {
                continue;
            }
            NSMutableArray *arr = [storesDicInfo objectForKey:key];
            
            id dataDict = [storeDictionary objectForKey:key];
            if ([dataDict isKindOfClass:[NSArray class]]) {
                NSArray *dataArray = (NSArray *)dataDict;
                for (id tempDic in dataArray) {
                    if ([tempDic isKindOfClass:[NSDictionary class]]) {
                        
                        NSMutableDictionary *newMutableDic = [[NSMutableDictionary alloc]initWithDictionary:tempDic];
                        [newMutableDic setObject:key forKey:@"type"];
                        
                        if (arr) {
                            [arr addObject:newMutableDic];
                        } else {
                            arr = [NSMutableArray arrayWithObject:newMutableDic];
                        }
                    } else {
                        LogError(@"下发数据错误");
                        continue;
                    }
                }
            } else {
                if (arr) {
                    [arr addObject:dataDict];
                } else {
                    arr = [NSMutableArray arrayWithObject:dataDict];
                }
            }
            [storesDicInfo setObject:arr forKey:key];
            
        }
    }];
    return storesDicInfo;
}

+ (void)processStoreInfoDataToDbWithStoresInfo:(NSDictionary *)storesInfo storeID:(NSString *)storeId genId:(NSString *)genId
                                isRemoteSearch:(BOOL)isRemoteSearch {
    
    NSDictionary *handleDict = [WSStoreDataProcessService getHandleStoreInfoKeysAndClass];
    NSArray *allKeys = [storesInfo allKeys];
    
    if ([allKeys containsObject:@"delNote"]) {
        NSString *delNoteValue = [storesInfo objectForKey:@"delNote"];
        NSArray *delNoteArray = [delNoteValue componentsSeparatedByString:@","];
        NSString *server_node = [delNoteArray getInSqlString];
        NSString *delSql = [NSString stringWithFormat:@"delete from base_store_acvt_dis where sid = '%@' and server_node %@",
                            storeId, server_node];
        WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
        [sqliteUtil executeUpdateWithSqls:@[delSql]];
    }
    if ([allKeys containsObject:@"delLocalNote"]) {
        NSString *delLocalNoteValue = [storesInfo objectForKey:@"delLocalNote"];
        NSArray *delLocalNoteArray = [delLocalNoteValue componentsSeparatedByString:@","];
        NSString *server_node = [delLocalNoteArray getInSqlString];
        NSString *delSql = [NSString stringWithFormat:@"delete from visit_store_acvt_data where sid = '%@' and server_node %@",
                            storeId, server_node];
        WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
        [sqliteUtil executeUpdateWithSqls:@[delSql]];
    }
    
    for (NSString *key in allKeys) {
        
        if ([key isEqualToString:@"delNote"] || [key isEqualToString:@"delLocalNote"]) {
            continue;
        }

        if ([key hasPrefix:STOREACVTDIS] ||[key hasPrefix:ACVTDIS]|| [key hasPrefix:ACVTDIS_SPESTORE_UPDATAEECHO]) {
            NSArray *storeAcvtDisArray = [storesInfo objectForKey:key];
            WSBaseAcvtdisDBService *baseAcvtDisSerice = [[WSBaseAcvtdisDBService alloc] init];
            [baseAcvtDisSerice BatchReplaceToTableWithDicts:storeAcvtDisArray FromNode:key hasNewData:YES storeID:storeId
                                             isRemoteSearch:isRemoteSearch genId:genId];

            if ([storeAcvtDisArray count] > 0) {
                [baseAcvtDisSerice processServerAcvtDisValue];
            }
        } else if ([key hasPrefix:FUNC_TIP_DIS]){
            
            WSFuncTipDBService *dbService = [[WSFuncTipDBService alloc] init];
            [dbService replaceToTableWithDicts:[storesInfo objectForKey:key] FromNode:key hasNewData:YES storeID:storeId];
            
        } else {
            
            NSArray *keyArray = [key componentsSeparatedByString:@":"];
            NSString *subKey = [keyArray firstObject];
        
            NSString *handleClassName = handleDict[subKey];
            if (!handleClassName) {
                continue;
            }
            Class handleClass = NSClassFromString(handleClassName);
            if (!handleClass) {
                continue;
            }

            WSDBService *dbService = [[handleClass alloc] init];
            [dbService replaceToTableWithDicts:[storesInfo objectForKey:key] FromNode:key hasNewData:YES storeID:storeId];
        }
    }
}

+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo genId:(NSString *)genId isRemoteSearch:(BOOL)isRemoteSearch{
    [self processStoreInfoDataToDbWithStoresInfo:storeInfo storeID:store.Id genId:genId isRemoteSearch:isRemoteSearch];
}

+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo genId:(NSString *)genId{
    [self processStoreInfoDataToDbWith:store info:storeInfo genId:genId isRemoteSearch:NO];
}

+ (void)saveStoreAcvtUploadCountToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo {
    
    
    NSArray *acvt = storeInfo[@"acvt"];
    
    NSDictionary *acvtDic = [acvt firstObject];
    
    NSString *sid = acvtDic[@"sid"];
    if ([sid isKindOfClass:[NSNumber class]]) {
        sid = [(NSNumber *)sid stringValue];
    }
    /*若acvtDic 包含sid key 则说明是调查问卷上传次数关系的数据  不是调查问卷本身属性的数据*/
    /* 数据格式如下：
    [{"sid":245975,"acvtId":113},{"sid":245975,"acvtId":24427,"uploadCount":26},{"sid":245975,"acvtId":109,"SORT":1},{"sid":245975,"acvtId":8213,"SORT":2},{"sid":245975,"acvtId":110,"SORT":3},{"sid":245975,"acvtId":111,"SORT":4},{"sid":245975,"acvtId":112,"SORT":5},{"sid":245975,"acvtId":46019,"SORT":6}]
     */
    if (sid && [sid length] > 0) {
        if ([acvt isKindOfClass:[NSArray class]] && [acvt count] > 0) {
            WSBaseStoreAcvtDBService *baseStoreAcvtDBService = [[WSBaseStoreAcvtDBService alloc] init];
            [baseStoreAcvtDBService replaceToTableWithDicts:acvt FromNode:nil hasNewData:YES storeID:store.Id];
        }
    }
}





@end
