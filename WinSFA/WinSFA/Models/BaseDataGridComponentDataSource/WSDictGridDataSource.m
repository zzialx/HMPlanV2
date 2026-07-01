//
//  WSDictGridDataSource.m
//  WinSFA
//
//  Created by Alicia on 2018/7/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSDictGridDataSource.h"
#import "WSFdtTable.h"
#import "WSBaseDictsDBService.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"
#import "WSBaseStoreDictdisDBService.h"

@implementation WSDictGridDataSource


- (NSArray *)getDataBaseDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    NSArray *l_array = [[NSArray alloc] init];
    
    NSString *storeIdStr = nil;
    if (store.Id) {
        if (qstId) {
            storeIdStr = [NSString stringWithFormat:@"%@_%@", store.Id, qstId];
        } else {
            storeIdStr = store.Id;
        }
    } else if (qstId) {
        storeIdStr = qstId;
    }
    l_array = [[WSFdtTable sharedTable] queryDictWithStoreId:storeIdStr fc:funcs.fc srid:store.srid withMd5:md5];
    
    return l_array;
}



- (NSArray *)getLocalDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    NSArray *dataSource = nil;
    NSArray *dataBaseDatas = [self getDataBaseDatasByMd5:md5 funcs:funcs store:store qstId:qstId];
    if ([dataBaseDatas count] > 0) {
        NSArray *fdtObjects = [[WSFdtTable sharedTable] queryWithNames:@[@"IMG_IDX"] ArgumentsValue:@[[NSString stringNotNilWithValue:md5]]];
        if ([fdtObjects count] > 0) {
            NSArray *dictsIds = [dataBaseDatas valueForKeyPath:@"self.dict_id"];
            WSBaseDictsDBService *baseDictsDBService = [[WSBaseDictsDBService alloc] init];
            dataSource = [baseDictsDBService queryDictsWithIDs:dictsIds];
        }
    }
    return dataSource;
}


- (NSArray *)getServerDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean{
    
    //MN-1332 2018-03-21(可编辑模式 或者 不隐藏空数据 情况是执行)
    if ((![qstBean.readonly isEqualToString:@"1"]) || ([funcs.hiddenEmpty isEqualToString:@"0"])){
        WSBaseDictsDBService *baseDictDBService = [[WSBaseDictsDBService alloc] init];
        return [baseDictDBService queryDictsForAcvtGridWithFilter:funcs.filter];
    }
    
    WSBaseDictsDBService *baseDictDBService = [[WSBaseDictsDBService alloc] init];
    NSArray *dictsDataSources = [baseDictDBService queryDictsForAcvtGridWithFilter:funcs.filter];
    
    NSMutableArray *dictIdsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < dictsDataSources.count; i++) {
        WSDictBean *dictBean = [dictsDataSources objectAtIndex:i];
        [dictIdsArray addObject:dictBean.Id];
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSString *dictIdsStr = [dictIdsArray componentsJoinedByString:@","];
    if (dictIdsStr.length > 0) {
        WSBaseStoreDictdisDBService *dictDisDBService = [[WSBaseStoreDictdisDBService  alloc] init];
        NSArray *dictDisObjectsArray = [dictDisDBService queryStoreDictdisWithGenId:md5 storeId:store.Id dictIds:dictIdsStr];
        
        for (WSBaseStoreDictDisObject *dictDis in dictDisObjectsArray) {
            for (WSFuncsBean_Param *aParam in funcs.paramArray) {
                NSString *colValue = [dictDis valueForKey:aParam.col];
                if ([NSString stringNotNilWithValue:colValue].length > 0) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Id CONTAINS %@", dictDis.dict_id];
                    NSArray *predicateArray = [dictsDataSources filteredArrayUsingPredicate:predicate];
                    if(predicateArray.count > 0) {
                        [resultArray addObject:[predicateArray firstObject]];
                        break;
                    }
                }
            }
        }
    }
    return resultArray;
}
/*
- (NSArray *)getDictServerData {
    //    WSAddStoreQstObject *storeQstObject = nil;
    //    NSArray * storeQstDataArray = [[WSAddStoreQstTable sharedTable] queryStoreQstByMd5:self.ownAcvtViewController.md5 andAcvtQstId:self.currentQst.acvtQstId andQstType:self.currentQst.qstType];
    //    if ([storeQstDataArray count] > 0) {
    //        storeQstObject =  (WSAddStoreQstObject *)[storeQstDataArray firstObject];
    //    }
    
    WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
    //    NSString *genid = [service queryQstServerValueWithStoreId:nil acvtId:nil acvtQstId:self.currentQst.acvtQstId genId:self.ownAcvtViewController.md5];
    NSString *genid = [service queryQstServerValueWithStoreId:nil acvtId:nil acvtQstId:self.currentQst.acvtQstId genId:self.model.md5];
    
    NSMutableArray *dicDataArray = [NSMutableArray arrayWithCapacity:1];
    if ([genid length] > 0) {
        WSStoredDictDisArray *storedDictDisArray = [WSAppData getObjectbyKey:STOREDICTDIS];
        __weak NSMutableArray *tempArray = dicDataArray;
        [storedDictDisArray.storedDictDisArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            WSStoredDictDisBean *storedDictDisBean =(WSStoredDictDisBean *) obj;
            if (storedDictDisBean.gen_id
                && [storedDictDisBean.gen_id isEqualToString:genid]) {
                [tempArray addObject:storedDictDisBean];
            }
        }];
    }
    return dicDataArray;
}
*/

@end
