//
//  WSBaseAcvtdisDBService.m
//  WinSFA
//
//  Created by heju on 16/3/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseAcvtdisDBService.h"

#import "WSBaseStoreAcvtDisTable.h"

#import "WSBaseAcvtDBService.h"

#import "WSFacQstTable.h"
#import "WSFacTable.h"
#import "WSAcvtDisLogicService.h"
#import "WSAcvtQstDisItem.h"
#import "WSAcvtListDataItem.h"
#import "WSTestTools.h"
#import "WSVisitStoreAcvtDataTable.h"
#import "WSAcvtQstDisItem.h"
#import "WSSqliteUtil.h"
#import "NSArray+SQL.h"
#import "WSShowQstViewForStoreListCell.h"
#import "WSBaseDictsDBService.h"
#import "NSArray+SQL.h"
#import "WSAcvtQuestionAnswerBean.h"
#import "YYModel.h"

#define K_ACVT_QST_ID          (@"acvtQstId")
#define K_SERVER_NODE  (@"server_node")

@interface WSBaseAcvtdisDBService ()

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation WSBaseAcvtdisDBService

#pragma mark - getter

- (NSNumberFormatter *)numberFormatter {
    
    if (!_numberFormatter) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        _numberFormatter = numberFormatter;
    }
    
    return _numberFormatter;
    
}

#pragma mark - public methods


-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:storeID isRemoteSearch:NO];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId  isRemoteSearch:(BOOL)isRemoteSearch {
    
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:storeID isRemoteSearch:isRemoteSearch genId:genId];
}
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId {
    
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:storeID genId:genId isRemoteSearch:NO];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID isRemoteSearch:(BOOL)isRemoteSearch
{
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:storeID isRemoteSearch:isRemoteSearch genId:nil];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID isRemoteSearch:(BOOL)isRemoteSearch genId:(NSString *)genId
{
    
    BOOL ret = YES;
    WSBaseStoreAcvtDisTable *acvtdisTable = [WSBaseStoreAcvtDisTable sharedTable];
    //清除数据
    NSMutableArray *namesArray = [NSMutableArray array];
    NSMutableArray *valuesArray = [NSMutableArray array];
//    SFA-34301
    if (self.isLoginSendNode) {
        [namesArray addObjectsFromArray:@[K_SERVER_NODE]];  //无storeId时根据结点名删除
        [valuesArray addObjectsFromArray:@[nodeName]];
        
        if ([namesArray count] > 0) {
            [acvtdisTable deleteWithNames:namesArray ArgumentsValue:valuesArray];
        }
        [namesArray removeAllObjects];
        [valuesArray removeAllObjects];
    }
    

    NSMutableArray *acvtdisDicts =[NSMutableArray array];
    BOOL isAcvtDis = NO;
    if ([nodeName hasPrefix:@"acvtdis"]) {
        isAcvtDis = YES;
    }
    
    for (NSDictionary *dic in dicts) {
        //回显字典
        NSDictionary *disDict = [self getDisDictWith:dic isAcvtDis:isAcvtDis isRemoteSearch:isRemoteSearch];
        
        if (disDict) {
            [acvtdisDicts addObject:disDict];
        }
        
    }
    
    

    
    NSArray *genIDs = [dicts valueForKeyPath:@"@distinctUnionOfObjects.gen_id"];
    

    
    //genid 优先级最高
    //其次 门店id 加问卷id 和安卓统一逻辑
    //SFA-26204 lishuli --TODO 需要优化
    if ([dicts count] > 0 && [genIDs count] > 0) {
        for (NSString *genid in genIDs) {
            [acvtdisTable deleteWithNames:@[@"gen_id"] ArgumentsValue:@[genid]];
        }
    } else {
        
        if ([storeID length] > 0 && ![storeID isEqualToString:@"-1"]) {
            NSMutableArray *acvtIds = [NSMutableArray arrayWithCapacity:acvtdisDicts.count];
            for (NSDictionary *dict in acvtdisDicts ) {
                NSString *acvtId = [dict objectForKey:@"acvtId"];
                if (![acvtIds containsObject:acvtId]) {
                    [acvtdisTable deleteWithNames:@[@"sid",@"acvtId"] ArgumentsValue:@[storeID,acvtId]];
                    [acvtIds addObject:acvtId];
                }
            }
        } else {
            if (isRemoteSearch) {
                [namesArray addObjectsFromArray:@[K_SERVER_NODE,@"is_search"]];
                [valuesArray addObjectsFromArray:@[nodeName,@"1"]];
            }else {
                [namesArray addObjectsFromArray:@[K_SERVER_NODE]];  //无storeId时根据结点名删除
                [valuesArray addObjectsFromArray:@[nodeName]];
            }
        }
        
        if ([dicts count] > 0 && [genId length] > 0) {  //有genId时根据genid删除（一般用于报表跳转请求）
            [namesArray addObject:@"gen_id"];
            [valuesArray addObject:genId];
        }
        
        if ([namesArray count] > 0) {
            [acvtdisTable deleteWithNames:namesArray ArgumentsValue:valuesArray];
        }
    }
    

    if (hasNewData && [genIDs count] > 0) {
        //有新数据时，本地数据才会根据genId删除
        [[WSVisitStoreAcvtDataTable sharedTable] batchDeleteFromTableWithNames:@[@"gen_id"] ArgumentsValues:@[genIDs ? genIDs :@""]];
    }

    if ([acvtdisDicts count] > 0) {
        ret = [acvtdisTable batchInsertToTableWithMap:@{K_ACVT_QST_ID:@{kMapKey_serverKey:@"acvtQstId"},
                                                        K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:acvtdisDicts];
    }
    
    [self processServerAcvtDisValueWithDicts:dicts];

    return ret;
}


#pragma mark ----批量处理门店列表数据的回显数据
- (BOOL)BatchReplaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
                      isRemoteSearch:(BOOL)isRemoteSearch genId:(NSString *)genId {
    
    BOOL ret = YES;
    WSBaseStoreAcvtDisTable *acvtdisTable = [WSBaseStoreAcvtDisTable sharedTable];
    
    NSMutableArray *acvtdisDicts = [NSMutableArray array];
    BOOL isAcvtDis = NO;
    if ([nodeName hasPrefix:@"acvtdis"]) {
        isAcvtDis = YES;
    }
    if ([nodeName isEqualToString:ACVTDIS_SPESTORE_UPDATAEECHO]) {
        if (storeID && storeID.length > 0 && ![storeID isEqualToString:@"-1"]) {
            isAcvtDis = NO;
        }else{
            isAcvtDis = YES;
        }
    }
    NSMutableArray *sidArray = [NSMutableArray array];
    NSMutableArray *genIdArray = [NSMutableArray array];
    NSMutableArray *acvtIdArray = [NSMutableArray array];
    for (NSDictionary *dic in dicts) {
        NSDictionary *disDict = [self getDisDictWith:dic isAcvtDis:isAcvtDis isRemoteSearch:isRemoteSearch];
        if (disDict) {
            [acvtdisDicts addObject:disDict];
            NSString *sid = disDict[@"sid"];
            NSString *genId = disDict[@"gen_id"];
            NSString *acvtId = disDict[@"acvtId"];
            
            if ([sid length] > 0 && ![sid isEqualToString:@"-1"]) {
                if (![sidArray containsObject:sid]) {
                    [sidArray addObject:sid];
                }
            }
            if (genId && genId.length > 0) {
                if (![genIdArray containsObject:genId]) {
                    [genIdArray addObject:genId];
                }
            }
            if ([acvtId length] > 0 ) {
                if (![acvtIdArray containsObject:acvtId]) {
                    [acvtIdArray addObject:acvtId];
                }
            }
        }
    }
    
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:@[K_SERVER_NODE]];
    NSMutableArray *valuesArray = [NSMutableArray arrayWithArray:@[nodeName]];
    if ([dicts count] > 0 && [genId length] > 0) {
        if (![genIdArray containsObject:genId]) {
            [genIdArray addObject:genId];
        }
    }
    NSString *deleteSql = [self baseDeleteSqlWithNames:namesArray valuesArray:valuesArray];
    
    if(genIdArray.count > 0) {
        if([deleteSql hasSuffix:@"where "]) {
            deleteSql = [NSString stringWithFormat:@"%@ gen_id %@ ", deleteSql, [genIdArray getInSqlString]];
        }
        else {
            deleteSql = [NSString stringWithFormat:@"%@ and gen_id %@ ", deleteSql, [genIdArray getInSqlString]];
        }
    }
    
    if (sidArray.count > 0) {
        if([deleteSql hasSuffix:@"where "]) {
            deleteSql = [NSString stringWithFormat:@"%@ sid %@ ", deleteSql, [sidArray getInSqlString]];
        }
        else {
            deleteSql = [NSString stringWithFormat:@"%@ and sid %@ ", deleteSql, [sidArray getInSqlString]];
        }
       
        if (acvtIdArray.count > 0) { //和安卓对逻辑，删除acvtdis时 ，再加一个条件：acvtid SFA-31685
            if([deleteSql hasSuffix:@"where "]) {
                deleteSql = [NSString stringWithFormat:@"%@ acvtId %@ ", deleteSql, [acvtIdArray getInSqlString]];
            }
            else {
                deleteSql = [NSString stringWithFormat:@"%@ and acvtId %@ ", deleteSql, [acvtIdArray getInSqlString]];
            }
        }
        
    } else {
        if (isRemoteSearch) {
            if([deleteSql hasSuffix:@"where "]) {
                deleteSql = [NSString stringWithFormat:@" %@ is_search = '1' ", deleteSql];
            }
            else {
                deleteSql = [NSString stringWithFormat:@" %@ and is_search = '1' ", deleteSql];
            }
        }
    }
    
    [acvtdisTable executeUpdateWithSqls:@[deleteSql]];
    
    NSArray *genIDs = [dicts valueForKeyPath:@"@distinctUnionOfObjects.gen_id"];
    if (hasNewData && [genIDs count] > 0) {
        [[WSVisitStoreAcvtDataTable sharedTable] batchDeleteFromTableWithNames:@[@"gen_id"] ArgumentsValues:@[genIDs ? genIDs :@""]];
    }
    
    if ([acvtdisDicts count] > 0) {
        ret = [acvtdisTable batchInsertToTableWithMap:@{K_ACVT_QST_ID:@{kMapKey_serverKey:@"acvtQstId"},
                                                        K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:acvtdisDicts];
    }
    
    if (isRemoteSearch) {
        [self processServerAcvtDisValueWithDicts:dicts];
    }
    
    return ret;
}

- (void)processServerAcvtDisValueWithDicts:(NSArray *)dicts {
    if ([dicts count] > 0) {
        [self processServerAcvtDisValue];
    }
}
#pragma mark ----抽取方法
//拼接删除baseSql
-(NSString *)baseDeleteSqlWithNames:(NSArray *)namesArray valuesArray:(NSArray *)valuesArray {
    NSString* dbTableName=[WSPlistHelper valueForKey:[[WSBaseStoreAcvtDisTable sharedTable] className] withPlistName:kDataBaseMappingFileName];
    NSString *deleteSql=[NSString  stringWithFormat:@"delete from %@ where ",dbTableName];
    for (int j = 0; j < namesArray.count; j++) {
        deleteSql=[deleteSql stringByAppendingFormat:@"%@ = '%@'",[namesArray objectAtIndex:j],valuesArray[j]];
        if(j < namesArray.count-1){
            deleteSql = [deleteSql stringByAppendingFormat:@" and "];
        }
    }
    return deleteSql;
}
//回显字典
- (NSDictionary *)getDisDictWith:(NSDictionary *)dic isAcvtDis:(BOOL)isAcvtDis isRemoteSearch:(BOOL)isRemoteSearch{
    
    NSString *p  = dic[@"p"];
    
    if (!p || [p isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    //MMSH-10415 增加srid的逻辑
    NSString *srid = [NSString stringNotNilWithValue:dic[@"srid"]];
    NSString *empId = ((srid.length > 0) ? srid : [NSString stringNotNilWithValue:dic[@"empId"]]);
    
    NSString *genId = [NSString stringNotNilWithValue:dic[@"gen_id"]];
    
    NSArray *pStrs = [p componentsSeparatedByString:@","];
    NSMutableDictionary * disDict = [NSMutableDictionary dictionary];
    NSString *sid = nil;
    NSString *acvtid = nil;
    NSString *acvtqstid = nil;
    NSString *acvtqstvalue = nil;
    
    if (isAcvtDis) {
        if ([pStrs count] == 2) {
            acvtid = [NSString stringNotNilWithValue:[pStrs firstObject]];
            acvtqstid = [NSString stringNotNilWithValue:pStrs[1]];
        }else if ([pStrs count] >= 3) {
            acvtid = [NSString stringNotNilWithValue:[pStrs firstObject]];
            acvtqstid = [NSString stringNotNilWithValue:pStrs[1]];
            if ([pStrs count] == 3) {
                acvtqstvalue = [NSString stringNotNilWithValue:pStrs[2]];
            }else {
                NSArray *valueArray = [pStrs subarrayWithRange:NSMakeRange(2, [pStrs count] - 2)];
                acvtqstvalue = [valueArray componentsJoinedByString:@","];
            }
            
        }
    }else {
        if ([pStrs count] == 3) {
            sid = [NSString stringNotNilWithValue:[pStrs firstObject]];
            acvtid = [NSString stringNotNilWithValue:pStrs[1]];
            acvtqstid = [NSString stringNotNilWithValue:pStrs[2]];
        }else if ([pStrs count] >= 4) {
            sid = [NSString stringNotNilWithValue:[pStrs firstObject]];
            acvtid = [NSString stringNotNilWithValue:pStrs[1]];
            acvtqstid = [NSString stringNotNilWithValue:pStrs[2]];
            if ([pStrs count] == 4) {
                acvtqstvalue = [NSString stringNotNilWithValue:pStrs[3]];
            }else {
                NSArray *valueArray = [pStrs subarrayWithRange:NSMakeRange(3, [pStrs count] - 3)];
                acvtqstvalue = [valueArray componentsJoinedByString:@","];
            }
            
        }
        // MN-655 按照安卓的逻辑修改，对人的不存 sid
        if ([sid isEqualToString:@"-1"]) {
            sid = nil;
        }
    }
    if(sid) {
        [disDict setObjectSafe:sid forKey:@"sid"];
    }
    [disDict setObjectSafe:acvtid forKey:@"acvtId"];
    [disDict setObjectSafe:acvtqstid forKey:@"acvtQstId"];
    [disDict setObjectSafe:acvtqstvalue forKey:@"acvt_qst_answer"];
    [disDict setObjectSafe:empId forKey:@"emp_id"];
    [disDict setObjectSafe:genId forKey:@"gen_id"];
    
    if (isRemoteSearch) {
        [disDict setObjectSafe:@"1" forKey:@"is_search"];
    }
    if (dic[STOREACVTDIS_NEWSTOREID]) {
        [disDict setObjectSafe:dic[STOREACVTDIS_NEWSTOREID] forKey:STOREACVTDIS_NEWSTOREID];
    }
    return disDict;
}

- (NSString *)queryPeopleQstValuePresentationByGenID:(NSString *)genID acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean
{
    NSString *valueID = [self queryQstValueWithStoreId:nil acvtId:acvtId acvtQstId:qstBean.acvtQstId genId:genID isMatchGenId:YES bizDate:nil];
    
    NSString *valuePresentation = nil;
    
    if ([valueID length] > 0) {
        valuePresentation = [WSAcvtDisLogicService getQstValuePresentationWithValueID:valueID qstBean:qstBean];
    }
    
    return valuePresentation;
}

- (NSArray *)queryAcvtMd5ArrayWithStoreID:(NSString *)storeID acvtID:(NSString *)acvtID
{
    NSString *sql = [NSString stringWithFormat:@"select distinct gen_id from visit_store_acvt_data where sid = '%@' and acvtid = '%@' and emp_id = '%@' and biz_date = '%@' union select distinct gen_id from base_store_acvt_dis where sid = '%@' and acvtid = '%@' and emp_id = '%@' and gen_id is not null and gen_id != ''", [NSString stringNotNilWithValue:storeID], [NSString stringNotNilWithValue:acvtID], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]],[NSString stringNotNilWithValue:storeID], [NSString stringNotNilWithValue:acvtID], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]];
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
    NSArray *md5Array = [dataArray valueForKey:@"gen_id"];
    
//    NSLog(@"sql:%@",sql);
    
    return md5Array;
}

- (NSArray *)queryStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID acvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName
{
    NSMutableArray *names = [@[@"acvtQstId",@"emp_id"] mutableCopy];
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:acvtQstID],[NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]] mutableCopy];
    
    if (storeID) {
        [names addObject:@"sid"];
        [values addObject:[NSString stringNotNilWithValue:storeID]];
    }
    
    if (noteName) {
        [names addObject:@"server_node"];
        [values addObject:[NSString stringNotNilWithValue:noteName]];
    }
    
    return [[WSBaseStoreAcvtDisTable sharedTable] queryWithNames:names ArgumentsValue:values];
}
- (NSArray *)queryStoreAcvtDisBeanArrayAcvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName{
    
     NSString * sqlString = [NSString stringWithFormat:@"select * from base_store_acvt_dis where acvtQstId = '%@' and emp_id = '%@' and  server_node like '%@%%'",acvtQstID,[WSAppData getObjectbyKey: APPDATA_EMPID],noteName];
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    
    return [object queryAndReturnInfosBySql:sqlString andClassName:@"WSBaseStoreAcvtDisObject"];


}

- (NSArray *)queryStoreAcvtDisBeanArrayAcvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName isRemoteSearch:(BOOL)isRemoteSearch
{
    NSString * sqlString = [NSString stringWithFormat:@"select * from base_store_acvt_dis where acvtQstId = '%@' and emp_id = '%@' and  server_node like '%@%%'",acvtQstID,[WSAppData getObjectbyKey: APPDATA_EMPID],noteName];

    if (isRemoteSearch) {
        sqlString = [NSString stringWithFormat:@"%@ and is_search = '1' ", sqlString];
    }else{
        sqlString = [NSString stringWithFormat:@"%@ and is_search is null ", sqlString];
    }
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    
    return [object queryAndReturnInfosBySql:sqlString andClassName:@"WSBaseStoreAcvtDisObject"];
    
    
}

- (NSArray *)queryLocalAcvtDisBeanArrayWithStoreID:(NSString *)storeID acvtQstID:(NSString *)acvtQstID
{
    NSMutableArray *names = [@[@"acvtQstId",@"emp_id"] mutableCopy];
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:acvtQstID],[NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]] mutableCopy];
    
    if (storeID) {
        [names addObject:@"sid"];
        [values addObject:[NSString stringNotNilWithValue:storeID]];
    }
    
    return [[WSVisitStoreAcvtDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
}

- (NSArray *)queryServerStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID genID:(NSString *)genID
{
    NSMutableArray *names = [@[@"gen_id",@"emp_id"] mutableCopy];
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:genID], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]] mutableCopy];
    
    if ([storeID length] > 0) {
        [names addObject:@"sid"];
        [values addObject:[NSString stringNotNilWithValue:storeID]];
    }
    
    return [[WSBaseStoreAcvtDisTable sharedTable] queryWithNames:names ArgumentsValue:values];
}

- (NSArray *)queryLocalStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID newStoreId:(NSString *)newStoreId genID:(NSString *)genID withEmpId:(NSString *)empId{
    
    NSMutableArray *names = [@[@"gen_id",@"emp_id"] mutableCopy];
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:genID], (empId.length > 0 ? empId : [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]])] mutableCopy];
    
    //YIHAIKERRY-4564
//    if ([storeID length] > 0) {
//        [names addObject:@"sid"];
//        [values addObject:[NSString stringNotNilWithValue:storeID]];
//    }
    
    if ([newStoreId length] > 0) {
        [names addObject:@"newStoreId"];
        [values addObject:[NSString stringNotNilWithValue:newStoreId]];
    }
    return [[WSVisitStoreAcvtDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    
}

- (WSBaseStoreAcvtDisObject *)queryServerAcvtDisObjectByGenID:(NSString *)genID acvtQstID:(NSString *)acvtQstID
{
    if (!genID || !acvtQstID) {
        return nil;
    }
    
    NSArray *names = @[@"gen_id",@"acvtqstid"];
    NSArray *values = @[[NSString stringNotNilWithValue:genID], [NSString stringNotNilWithValue:acvtQstID]];
    
    return [[[WSBaseStoreAcvtDisTable sharedTable] queryWithNames:names ArgumentsValue:values] firstObject];
}

- (WSVisitStoreAcvtDataObject *)queryLocalAcvtDisObjectByGenID:(NSString *)genID acvtQstID:(NSString *)acvtQstID
{
    if (!genID || !acvtQstID) {
        return nil;
    }
    
    NSArray *names = @[@"gen_id",@"acvtqstid"];
    NSArray *values = @[[NSString stringNotNilWithValue:genID], [NSString stringNotNilWithValue:acvtQstID]];
    
    return [[[WSVisitStoreAcvtDataTable sharedTable] queryWithNames:names ArgumentsValue:values] firstObject];
}

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort{
    
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
    return [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isRead:isRead isRemoteSearch:isRemoteSearch acvtSort:acvtSort withEmpId:empId];
    
}

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType qstAnswer:(NSString *)qstAnswer genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort{
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
    return [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:nil genIDs:genIDs isFromLocal:YES isRead:isRead isRemoteSearch:isRemoteSearch withEmpId:empId qstAnswer:qstAnswer isFromTABV6001:NO isCode:nil];
}

- (NSArray *)queryStoresWithAcvtType:(NSString *)acvtType  isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId isCode:(NSString *)isCode
{
    return [self queryAcvtDatasWithStoreID:@"-1" acvtType:acvtType searchText:nil genIDs:nil isFromLocal:YES isRead:NO isRemoteSearch:isRemoteSearch withEmpId:empId qstAnswer:nil isFromTABV6001:YES isCode:isCode];
}
    
- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId
{

    NSArray *localArray = [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isFromLocal:YES isRead:isRead isRemoteSearch:isRemoteSearch withEmpId:empId];
    NSArray *serverArray = [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isFromLocal:NO isRead:isRead isRemoteSearch:isRemoteSearch withEmpId:empId];
    
    NSArray *dataArray = [self getDatasWithAcvtSort:acvtSort localArray:localArray serverArray:serverArray];
    
    //过滤掉没有主副标题的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.mainTitle != nil or self.subTitle != nil or self.rightTitle != nil"];
    NSArray *filterArray = [dataArray filteredArrayUsingPredicate:predicate];
    
    
    return filterArray;
    
}
- (NSInteger)getAcvtDatasCountWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId
{
    NSArray *dataArray = [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isRead:isRead isRemoteSearch:isRemoteSearch acvtSort:acvtSort withEmpId:empId];
    //过滤掉没有主副标题的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.rightTitle == nil"];
    NSArray *filterArray = [dataArray filteredArrayUsingPredicate:predicate];
    return filterArray.count;
}
- (NSMutableArray *)getDatasWithAcvtSort:(NSString *)acvtSort localArray:(NSArray *)localArray serverArray:(NSArray *)serverArray {
    NSMutableArray *dataArray = [NSMutableArray array];
    
    if ([localArray count] > 0) {
        
        if ([acvtSort isEqualToString:@"0"] ||  acvtSort.length == 0) {
            [dataArray addObjectsFromArray:localArray];
            
            NSArray *localGenIdArray = [dataArray valueForKeyPath:@"self.genID"];
            
            for (WSAcvtListDataItem *item in serverArray) {
                if (![localGenIdArray containsObject:item.genID]) {
                    [dataArray addObject:item];
                }
            }
        }else {
            if ([serverArray count] > 0) {
                //先放入服务器数据，为了保证按下发顺序排序，再把有本地数据的条目进行替换
                
                [dataArray addObjectsFromArray:serverArray];
                
                NSArray *serverGenIdArray = [dataArray valueForKeyPath:@"self.genID"];
                
                for (WSAcvtListDataItem *item in localArray) {
                    if ([serverGenIdArray containsObject:item.genID]) {
                        [dataArray replaceObjectAtIndex:[serverGenIdArray indexOfObject:item.genID] withObject:item];
                    }else {
                        if (![acvtSort isEqualToString:@"3"]) {
                            [dataArray addObject:item];
                        }
                    }
                }
                
            }else {
                if (![acvtSort isEqualToString:@"3"]) {
                    [dataArray addObjectsFromArray:localArray];
                }
            }
        }
        
    }else {
        [dataArray addObjectsFromArray:serverArray];
    }
    return dataArray;
}

/*
 注意和 - (NSArray *)queryAcvtDatasWithStoreID:...的区别(方法名少了qst)
 */
- (NSArray *)queryAcvtQstDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch {
    NSArray *localArray = [self queryAcvtQstDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isFromLocal:YES isRead:isRead isRemoteSearch:isRemoteSearch];
    NSArray *serverArray = [self queryAcvtQstDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isFromLocal:NO isRead:isRead isRemoteSearch:isRemoteSearch];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    
    if ([localArray count] > 0) {
        [dataArray addObjectsFromArray:localArray];
        NSArray *localGenIdArray = [dataArray valueForKeyPath:@"self.genId"];
        for (WSAcvtQstDisItem *item in serverArray) {
            if (![localGenIdArray containsObject:item.genId]) {
                [dataArray addObject:item];
            }
        }
    }else {
        [dataArray addObjectsFromArray:serverArray];
    }
    
    return dataArray;
}

- (BOOL)processServerAcvtDisValue
{
    NSArray *plistKeys = @[@"updateAcvtDisOptValueDictsSql",@"updateAcvtDisOptValueStoreSql",@"updateAcvtDisOptValueEmpSql",@"updateAcvtDisOptValueProdSql",@"updateAcvtDisOptValueOptSql"];
    BOOL updateOptValueSuccess = NO;
    for (int i = 0; i <plistKeys.count;i++) {
        NSString *plistKey = plistKeys[i];
        NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:nil valueArray:nil];
        updateOptValueSuccess = [[WSBaseStoreAcvtDisTable sharedTable] executeUpdateWithSqls:@[sql]];
    }
    return updateOptValueSuccess;
}

- (BOOL)processLocalAcvtDisValue
{
    NSString *sql = [self getSQLWithPlistKey:@"localAcvtDataOptIsNull" keyArray:nil valueArray:nil];
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryDicDatasBySql:sql argumentsValues:nil];
    
    if (!dataArray || dataArray.count == 0) {
        return YES;
    }
    
    NSMutableArray *sqlArray = [NSMutableArray array];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSDictionary *dic in dataArray) {
        NSString *_id = [dic objectForKey:@"id"];
        NSString *valueID = [dic objectForKey:@"acvt_qst_answer"];
        NSString *ds = [dic objectForKey:@"ds"];
        NSString *filter = [dic objectForKey:@"filter"];
        NSString *acvtQstID = [NSString stringWithValue:[dic objectForKey:@"acvtQstId"]];
        
        if (!valueID || [valueID isKindOfClass:[NSNull class]] || [valueID length] == 0) {
            continue;
        }
        
        NSString *value;
        if ([ds isKindOfClass:[NSString class]] && [ds length] > 0) {
            value = [WSAcvtDisLogicService getDSValueByID:valueID ds:ds filter:filter];
        }else {
            value = [WSAcvtDisLogicService getOPTValueByID:valueID acvtQstID:acvtQstID];
        }
        
        if ([value length] > 0) {
            NSString *updateSql = [NSString stringWithFormat:@"update visit_store_acvt_data set opt_value = ? where _id='%@'", _id];
            [sqlArray addObject:updateSql];
            [valueArray addObject:@[value]];
        }
    }
    
    if ([sqlArray count] > 0) {
        return [[WSBaseStoreAcvtDisTable sharedTable] executeUpdateWithSqls:sqlArray withArgumentsInArray:valueArray];
    }
    
    return YES;
}

- (NSDictionary *)getFuncCodeAndAcvtDataReadCount
{
    // (" (fv like 'TB_%' or  levelCode= '2') ");
    NSString *sql11 = [self getSQLWithPlistKey:@"getAddAcvtCount" keyArray:@[@"$fcWhere$"] valueArray:@[@"(fv like 'TB_%' or  levelCode= '2')"]];
    NSArray *dicArray = [[WSBaseStoreAcvtDisTable sharedTable] queryDicDatasBySql:sql11 argumentsValues:nil];
    
    NSMutableDictionary *unReadDic = [NSMutableDictionary dictionary];

    for (NSDictionary *dic in dicArray) {
        NSString *genid = [dic objectForKey:@"genId"];
        NSString *fc = [dic objectForKey:@"fc"];
        NSString *compare = [NSString stringWithValue:[dic objectForKey:@"compare"]];
        
        BOOL unRead = NO;
        if ([compare isEqualToString:@"1"]) {
            unRead = YES;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fc = %@ and genId = %@", fc, genid];
            NSArray *filterArray = [dicArray filteredArrayUsingPredicate:predicate];
            if ([filterArray count] > 1) {
                for (NSDictionary *subDic in filterArray) {
                    NSString *compareSub = [NSString stringWithValue:[subDic objectForKey:@"compare"]];
                    if ([compareSub isEqualToString:@"0"]) {
                        unRead = NO;
                        break;
                    }
                }
            }
        }
        
        if (unRead) {
            NSNumber *number = [unReadDic objectForKey:fc];
            if (!number) {
                number = @1;
            }else {
                number = [NSNumber numberWithInteger:[number integerValue] + 1];
            }
            [unReadDic setObject:number forKey:fc];
        }
        
    }
    
    return unReadDic;
}

- (NSString *)queryQstValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId isMatchGenId:(BOOL)isMatchGenId bizDate:(NSString *)bizDate isGetLastValue:(BOOL)isGetLastValue {
    NSString *value = [self queryQstLocalValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:genId bizDate:bizDate isGetLastValue:isGetLastValue];
    if (!value) {
        value = [self queryQstServerValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:isMatchGenId ? genId : nil isGetLastValue:isGetLastValue];
    }
    
    return value;
}

- (NSString *)queryQstValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId isMatchGenId:(BOOL)isMatchGenId bizDate:(NSString *)bizDate
{
    
    NSString *value = [self queryQstLocalValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:genId bizDate:bizDate];
    if (!value) {
        value = [self queryQstServerValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:isMatchGenId ? genId : nil];
    }
    
    return value;
}

- (NSString *)queryQstServerValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId {
    
    return [self queryQstServerValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:genId isGetLastValue:NO];
}

- (NSString *)queryQstServerValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId
                                       genId:(NSString *)genId isGetLastValue:(BOOL)isGetLastValue
{
    if (!acvtQstId)
        return nil;
    
    //MN-2266 2018-05-07
    NSString *sidCondition = (storeID.length > 0) ? [NSString stringWithFormat:@"sid = '%@'", storeID] : @"sid is null";
    NSString *acvtIdCondition = (acvtId.length > 0) ? [NSString stringWithFormat:@"and acvtId = '%@'", acvtId] : @"";
    NSString *acvtQstIdCondition = (acvtQstId.length > 0) ? [NSString stringWithFormat:@"and acvtQstId = '%@'", acvtQstId] : @"";
    NSString *genIdCondition = [NSString stringWithFormat:@"and (gen_id = '%@' or gen_id is null)", genId];
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_acvt_dis where %@ %@ %@ %@", sidCondition, acvtIdCondition, acvtQstIdCondition, genIdCondition];
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
    
//    //    NSMutableArray *names = [@[@"acvtQstId",@"emp_id"] mutableCopy];
//    //    NSMutableArray *values = [@[[NSString stringNotNilWithValue:acvtQstId],[NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]] mutableCopy];
//    // MENGNIU-1837 安卓不加人员id
//    NSMutableArray *names = [@[@"acvtQstId"] mutableCopy];
//    NSMutableArray *values = [@[[NSString stringNotNilWithValue:acvtQstId]] mutableCopy];
//
//    if ([acvtId length] > 0) {
//        [names addObject:@"acvtId"];
//        [values addObject:acvtId];
//    }
//    if (([storeID length] > 0) && ![storeID isEqualToString:@"-1"]) {
//        [names addObject:@"sid"];
//        [values addObject:storeID];
//    }else{
//        [names addObject:@"sid"];
//        [values addObject:[NSNull null]];
//    }
//
//    if ([genId length] > 0) {
//        [names addObject:@"gen_id"];
//        [values addObject:genId];
//    }
//    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryWithNames:names ArgumentsValue:values];

    WSBaseStoreAcvtDisObject *obj;
    if (!isGetLastValue) {
        obj = [dataArray firstObject];
    } else {
        obj = [dataArray lastObject];
    }
    return obj.acvt_qst_answer;
}


- (NSString *)queryQstLocalValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId bizDate:(NSString *)bizDate {
    return [self queryQstLocalValueWithStoreId:storeID acvtId:acvtId acvtQstId:acvtQstId genId:genId bizDate:bizDate isGetLastValue:NO];
}

- (NSString *)queryQstLocalValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId bizDate:(NSString *)bizDate isGetLastValue:(BOOL)isGetLastValue
{
    if (!acvtQstId) {
        return nil;
    }
    
    NSMutableArray *names = [@[@"acvtQstId",@"emp_id"] mutableCopy];
    NSMutableArray *values = [@[[NSString stringNotNilWithValue:acvtQstId],[NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]]] mutableCopy];
    
    if ([acvtId length] > 0) {
        [names addObject:@"acvtId"];
        [values addObject:acvtId];
    }
    if ([storeID length] > 0) {
        [names addObject:@"sid"];
        [values addObject:storeID];
    }
    if ([genId length] > 0) {
        [names addObject:@"gen_id"];
        [values addObject:genId];
    }
    
    if ([bizDate length] > 0) {
        [names addObject:@"biz_date"];
        [values addObject:bizDate];
    }
    
    NSArray *dataArray = [[WSVisitStoreAcvtDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    
    WSVisitStoreAcvtDataObject *obj;
    if (!isGetLastValue) {
        obj = [dataArray firstObject];
    } else {
        obj = [dataArray lastObject];
    }
    
    return obj.acvt_qst_answer;
}

- (BOOL)deleteLocalDataWithGenId:(NSString *)genId
{
    if (!genId) {
        return YES;
    }
    return [[WSVisitStoreAcvtDataTable sharedTable] deleteWithNames:@[@"gen_id"] ArgumentsValue:@[genId]];
}

- (BOOL)deleteLocalDataWithGenIds:(NSArray *)genIds
{
    if (!genIds) {
        return YES;
    }
    return  [[WSVisitStoreAcvtDataTable sharedTable] batchDeleteFromTableWithNames:@[@"gen_id"] ArgumentsValues:@[genIds ? genIds : @""]];

}

- (BOOL)deleteServerDataWithGenId:(NSString *)genId
{
    if (!genId) {
        return YES;
    }
    return [[WSBaseStoreAcvtDisTable sharedTable] deleteWithNames:@[@"gen_id"] ArgumentsValue:@[genId]];
}

- (BOOL)deleteLocalDataWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId
{
    if (!storeId || !acvtId) {
        return YES;
    }
    
    return [[WSVisitStoreAcvtDataTable sharedTable] deleteWithNames:@[@"sid",@"acvtid"] ArgumentsValue:@[storeId,acvtId]];
}


- (NSArray *)queryAcvtQstDatasByGenId:(NSString *)genId
{
    NSArray *datas = [self queryAcvtQstDatasByGenId:genId plistKey:@"getLocalAcvtData"];
    
    if (!datas || [datas count] == 0) {
        datas = [self queryServerAcvtQstDatasByGenId:genId];
    }
    return datas;
}

- (NSArray *)queryServerAcvtQstDatasByGenId:(NSString *)genId {
    return [self queryAcvtQstDatasByGenId:genId plistKey:@"getServerAcvtData"];
}

- (NSArray *)queryLocalAcvtQstDatasByGenId:(NSString *)genId {
    return [self queryAcvtQstDatasByGenId:genId plistKey:@"getLocalAcvtData"];
}

- (NSArray *)queryAcvtQstDatasByGenId:(NSString *)genId plistKey:(NSString *)plistKey
{
    if (!genId || [genId length] == 0) {
        return nil;
    }
    
    NSString *storeIDValue = @"";
    NSString *acvtIDValue = @"";
    NSString *genIDValue = [NSString stringWithFormat:@" and genId = '%@'", genId];
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSArray *keyArray = @[@"$storeIdWhere$",@"$acvtIdWhere$",@"$genIdWhere$",@"$empIdWhere$"];
    NSArray *valueArray = @[storeIDValue,acvtIDValue,genIDValue,empIDValue];
    
   
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    NSArray *datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:@[genId] className:@"WSAcvtQstDisItem"];
    
    return datas;
}


- (NSArray *)queryAcvtQstDatasByGenIds:(NSArray *)genIds
{
    if ([genIds count] == 0) {
        return nil;
    }
    
    
    NSString *storeIDValue = @"";
    NSString *acvtIDValue = @"";
    
    NSString *genIdStr = @"(";
    
    for (NSInteger i = 0; i < [genIds count]; i++) {
        NSString *rowMd5 = genIds[i];
        
        if (i == 0) {
            genIdStr = [genIdStr stringByAppendingFormat:@"'%@'",rowMd5];
        }else {
            genIdStr = [genIdStr stringByAppendingFormat:@" ,'%@'",rowMd5];
        }
    }
    genIdStr = [genIdStr stringByAppendingString:@" )"];
    
    NSString *genIDValue = [NSString stringWithFormat:@" and genId in %@", genIdStr];
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSArray *keyArray = @[@"$storeIdWhere$",@"$acvtIdWhere$",@"$genIdWhere$",@"$empIdWhere$"];
    NSArray *valueArray = @[storeIDValue,acvtIDValue,genIDValue,empIDValue];
    
    NSString *plistKey = @"getLocalAcvtData";
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    NSArray *datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:genIds className:@"WSAcvtQstDisItem"];
    
    if (!datas || [datas count] == 0) {
        plistKey = @"getServerAcvtData";
        sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
        datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:genIds className:@"WSAcvtQstDisItem"];
    }
    
    return datas;
}


- (NSArray *)queryAcvtDatasWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId genIds:(NSArray *)genIds
{
    
    NSString *storeIDValue = @"";
    NSString *acvtIDValue = @"";
    NSString *genIDValue = @"";
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    if ([storeId length] > 0) {
        storeIDValue = [NSString stringWithFormat:@" and acvt_dis.sid = '%@'", storeId];
    }
    if ([acvtId length] > 0) {
        acvtIDValue = [NSString stringWithFormat:@" and acvt_dis.acvtId = '%@'", acvtId];
    }
    
    if ([genIds count] > 0) {
        NSMutableString *genIdWhere = [NSMutableString stringWithString:@" and genId in("];
        for (NSString *genId in genIds) {
            [genIdWhere appendFormat:@"'%@'", genId];
            
            if ([genIds indexOfObject:genId] != [genIds count] - 1) {
                [genIdWhere appendString:@","];
            }
        }
        [genIdWhere appendString:@")"];
        genIDValue = genIdWhere;
    }
    
    NSArray *keyArray = @[@"$storeIdWhere$",@"$acvtIdWhere$",@"$genIdWhere$",@"$empIdWhere$"];
    NSArray *valueArray = @[storeIDValue,acvtIDValue,genIDValue,empIDValue];
    
    //local
    NSString *plistKey = @"getLocalAcvtData";
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    NSArray *localDatas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:nil className:@"WSAcvtQstDisItem"];
    
    NSMutableArray *localItemArray = [NSMutableArray array];
    NSMutableDictionary *localItemDic = [NSMutableDictionary dictionary];
    
    for (WSAcvtQstDisItem *qstItem in localDatas) {
        [self processDataWithQstItem:qstItem allDataArray:localItemArray allDataDic:localItemDic isNeedMainSubTitle:NO isNeedQstDisArray:YES];
    }
    
    //server
    plistKey = @"getServerAcvtData";
    sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    NSArray *serverDatas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:nil className:@"WSAcvtQstDisItem"];
    
    NSMutableArray *serverItemArray = [NSMutableArray array];
    NSMutableDictionary *serverItemDic = [NSMutableDictionary dictionary];
    
    for (WSAcvtQstDisItem *qstItem in serverDatas) {
        [self processDataWithQstItem:qstItem allDataArray:serverItemArray allDataDic:serverItemDic isNeedMainSubTitle:NO isNeedQstDisArray:YES];
    }
    
    //去重
    NSMutableArray *allArray = [NSMutableArray array];
    
    if ([localItemArray count] > 0) {
        [allArray addObjectsFromArray:localItemArray];
        NSArray *localGenIdArray = [allArray valueForKeyPath:@"self.genID"];
        for (WSAcvtListDataItem *item in serverItemArray) {
            if (![localGenIdArray containsObject:item.genID]) {
                [allArray addObject:item];
            }
        }
    }else {
        [allArray addObjectsFromArray:serverItemArray];
    }
    
    return allArray;
}

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch withEmpId:(NSString *)empId
{
    return [self queryAcvtDatasWithStoreID:storeID acvtType:acvtType searchText:searchText genIDs:genIDs isFromLocal:isFromLocal isRead:isRead isRemoteSearch:isRemoteSearch withEmpId:empId qstAnswer:nil isFromTABV6001:NO isCode:nil];
}

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType  withEmpId:(NSString *)empId qstAnswer:(NSString *)qstAnswer isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead
{
    
    NSString *storeIDValue;
    NSString *tempEmpId = empId;
    if ([tempEmpId length ] == 0) {
        tempEmpId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey: APPDATA_EMPID]];
    }
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", tempEmpId];
    NSString *searchValue = @"";
    
    //storeID
    if (!storeID || [storeID length] == 0 || [storeID isEqualToString:@"-1"]) {
        storeIDValue = @"and (acvt_dis.sid is null or acvt_dis.sid = '-1')";
    }else {
        storeIDValue = [NSString stringWithFormat:@" and acvt_dis.sid = '%@'", storeID];
    }
    if (qstAnswer && qstAnswer.length > 0) {
        if ([qstAnswer rangeOfString:@"in"].location == NSNotFound) {
            NSMutableString *searchWhere = [NSMutableString stringWithString:@" and ("];
            
            [searchWhere appendFormat:@" answer = '%@'", qstAnswer];
            
            [searchWhere appendString:@" )"];
            
            searchValue = searchWhere;
        } else {
            searchValue = [NSString stringWithFormat:@" and answer %@", qstAnswer];
        }
    }
    
    NSString *plistKey = @"checkSameAcvtDisSql";
    NSArray *keyArray = @[@"$storeIdWhere$",@"$empIdWhere$", @"$optNamelike$"];
    NSArray *valueArray = @[storeIDValue, empIDValue,searchValue];
    
    
    
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    
    NSString *filter = [NSString stringNotNilWithValue:acvtType];
    
    NSArray *datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:@[filter] className:@"WSAcvtQstDisItem"];
//    SFA-25175 donghong
    if(datas.count<1)
    {
        sql = [sql stringByReplacingOccurrencesOfString:@"visit_store_acvt_data" withString:@"base_store_acvt_dis"];
        
    
        datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:@[filter] className:@"WSAcvtQstDisItem"];

    }
    
    NSMutableArray *acvtItemArray = [NSMutableArray array];
    NSMutableDictionary *acvtItemDic = [NSMutableDictionary dictionary];
    
    for (WSAcvtQstDisItem *qstItem in datas) {
        
        if (isRead && [qstItem.countrule length] > 0 && [qstItem.countrule isEqualToString:qstItem.acvtanswer]) {
            qstItem.unRead = true;
        }
        
        [self processDataWithQstItem:qstItem allDataArray:acvtItemArray allDataDic:acvtItemDic isNeedMainSubTitle:YES isNeedQstDisArray:NO];
    }
    
    return acvtItemArray;
}


- (NSArray *)queryStoreIdWithAnswer:(NSString *)answer acvtQstID:(NSString *)acvtQstID {
    NSString *sql = [NSString stringWithFormat:@"select sid from base_store_acvt_dis dis left join base_acvt_qst qst on qst.acvtQstId = dis.acvtQstId  where acvt_qst_answer = '%@' and dis.acvtQstID = '%@'", answer, acvtQstID];
    NSArray *datas = [[WSBaseStoreAcvtDisTable sharedTable] queryDatasBySql:sql columnArr:@[@"sid"]];
    return datas;
}

#pragma mark - private methods

/**
 获取acvt列表数据
 
 @param storeID     storeID
 @param acvtType    filter
 @param searchText  searchText
 @param genIDs      genIDs
 @param isFromLocal YES取本地数据，NO取服务器数据
 @param isRead      YES查询已读未读状体，NO不查询
 @return WSAcvtListDataItem数组
 */
- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch withEmpId:(NSString *)empId qstAnswer:(NSString *)qstAnswer isFromTABV6001:(BOOL)isFromTABV6001 isCode:(NSString *)isCode
{
    NSString *storeIDValue = @"";
    NSString *isSearchValue = @"";
    NSString *genIDsValue = @"";
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", empId];
    NSString *searchValue = @"";
    
    //storeID YIHAIKERRY-4564 修改的逻辑变动较大(和安卓已经对比过逻辑)
    if (storeID && storeID.length > 0 && ![storeID isEqualToString:@"-1"]) {
        storeIDValue = [NSString stringWithFormat:@" and acvt_dis.sid = '%@'", storeID];
    }
//    //isSearch
//    if (isRemoteSearch) {
//        isSearchValue = @"and acvt_dis.is_search ='1'";
//    }else {
//        isSearchValue = @"and acvt_dis.is_search is null";
//    }
    
    //genid
    if ([genIDs count] > 0) {
        NSMutableString *genIdWhere = [NSMutableString stringWithString:@" and genId in("];
        for (NSString *genId in genIDs) {
            [genIdWhere appendFormat:@"'%@'", genId];
            
            if ([genIDs indexOfObject:genId] != [genIDs count] - 1) {
                [genIdWhere appendString:@","];
            }
        }
        [genIdWhere appendString:@")"];
        genIDsValue = genIdWhere;
    }
    
    if (qstAnswer && qstAnswer.length > 0) {
        if ([qstAnswer rangeOfString:@"in"].location == NSNotFound) {
            NSMutableString *searchWhere = [NSMutableString stringWithString:@" and ("];
            
            [searchWhere appendFormat:@" answer = '%@'", qstAnswer];
            
            [searchWhere appendString:@" )"];
            
            searchValue = searchWhere;
        } else {
            searchValue = [NSString stringWithFormat:@" and answer %@", qstAnswer];
        }
        //        searchText = qstAnswer;
    }else{
        //searchText
        if ([searchText length] > 0) {
            NSMutableString *searchWhere = [NSMutableString stringWithString:@" and ("];
            
            NSArray *searchTextArray = [searchText componentsSeparatedByString:@" "];
            
            NSInteger realSeachTextIndex = 0;
            
            for (NSInteger i = 0; i < [searchTextArray count]; i++) {
                NSString *searchText = searchTextArray[i];
                NSString *searchTagWithoutSpace = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([searchTagWithoutSpace length] > 0) {
                    if ([searchTextArray containsObject:searchTagWithoutSpace]) {
                        
                        if (realSeachTextIndex > 0) {
                            [searchWhere appendString:@" and "];
                        }
                        [searchWhere appendFormat:@" answer like '%%%@%%'", searchTagWithoutSpace];
                        realSeachTextIndex +=1;
                    }
                }
            }
            [searchWhere appendString:@" )"];
            searchValue = searchWhere;
        }
    }
    
    
    NSString *plistKey = @"searchLocalAcvtData";
    if (!isFromLocal) {
        plistKey = @"searchServerAcvtData";
        
        if ([searchText length] > 0) {
            empIDValue = [NSString stringWithFormat:@"%@ and acvt_dis.gen_id not in (select distinct gen_id from visit_store_acvt_data)", empIDValue];
        }
    }
    
    NSArray *keyArray = @[@"$storeIdWhere$",@"$isSearchWhere$",@"$genIdWhere$",@"$empIdWhere$", @"$optNamelike$"];
    NSArray *valueArray = @[storeIDValue, isSearchValue, genIDsValue, empIDValue,searchValue];
    
    
    
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    
    NSString *filter = [NSString stringNotNilWithValue:acvtType];
    
    NSArray *datas = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:@[filter] className:@"WSAcvtQstDisItem"];
    
    NSMutableArray *acvtItemArray;
  
    if (!isFromTABV6001) {
        acvtItemArray = [NSMutableArray array];
        NSMutableDictionary *acvtItemDic = [NSMutableDictionary dictionary];
        for (WSAcvtQstDisItem *qstItem in datas) {
            if (isRead && [qstItem.countrule length] > 0 && [qstItem.countrule isEqualToString:qstItem.acvtanswer]) {
                qstItem.unRead = true;
            }
                
            [self processDataWithQstItem:qstItem allDataArray:acvtItemArray allDataDic:acvtItemDic isNeedMainSubTitle:YES isNeedQstDisArray:NO];

        }
    } else {
        acvtItemArray = [self processDataToNewStoreList:datas isCode:isCode];
    }
    
    return acvtItemArray;
    
}


/**
 获取 acvt 中 所有问题数据
 
 @param storeID     storeID
 @param acvtType    filter
 @param searchText  searchText
 @param genIDs      genIDs
 @param isFromLocal YES取本地数据，NO取服务器数据
 @param isRead      YES查询已读未读状体，NO不查询
 @return WSAcvtQstDisItem数组
 */
- (NSArray *)queryAcvtQstDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch
{
    
    NSString *storeIDValue;
    NSString *isSearchValue = @"";
    NSString *genIDsValue = @"";
    NSString *empIDValue = [NSString stringWithFormat:@" and acvt_dis.emp_id = '%@'", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *searchValue = @"";
    
    //storeID
    if (!storeID || [storeID length] == 0 || [storeID isEqualToString:@"-1"]) {
        if (isFromLocal) {
            storeIDValue = @"and acvt_dis.sid = '-1'";
        }else{
            storeIDValue = @"and acvt_dis.sid is null";
        }
    }else {
        storeIDValue = [NSString stringWithFormat:@" and acvt_dis.sid = '%@'", storeID];
    }
    
    //isSearch
    if (isRemoteSearch) {
        isSearchValue = @"and acvt_dis.is_search ='1'";
    }else {
        isSearchValue = @"and acvt_dis.is_search is null";
    }
    
    //genid
    if ([genIDs count] > 0) {
        NSMutableString *genIdWhere = [NSMutableString stringWithString:@" and genId in("];
        for (NSString *genId in genIDs) {
            [genIdWhere appendFormat:@"'%@'", genId];
            
            if ([genIDs indexOfObject:genId] != [genIDs count] - 1) {
                [genIdWhere appendString:@","];
            }
        }
        [genIdWhere appendString:@")"];
        genIDsValue = genIdWhere;
    }
    
    //searchText
    if ([searchText length] > 0) {
        NSMutableString *searchWhere = [NSMutableString stringWithString:@" and ("];
        NSArray *searchTextArray = [searchText componentsSeparatedByString:@" "];
        for (NSString *searchTag in searchTextArray) {
            NSString *searchTagWithoutSpace = [searchTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([searchTextArray indexOfObject:searchTag] > 0) {
                [searchWhere appendString:@" or "];
            }
            [searchWhere appendFormat:@" answer like '%%%@%%'", searchTagWithoutSpace];
        }
        [searchWhere appendString:@" )"];
        searchValue = searchWhere;
    }
    
    NSArray *keyArray = @[@"$storeIdWhere$",@"$isSearchWhere$",@"$genIdWhere$",@"$empIdWhere$", @"$optNamelike$"];
    NSArray *valueArray = @[storeIDValue, isSearchValue, genIDsValue, empIDValue,searchValue];
    
    NSString *plistKey = @"searchLocalAcvtData";
    if (!isFromLocal) {
        plistKey = @"searchServerAcvtData";
    }
    
    NSString *sql = [self getSQLWithPlistKey:plistKey keyArray:keyArray valueArray:valueArray];
    
    NSString *filter = [NSString stringNotNilWithValue:acvtType];
    
    return  [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:@[filter] className:@"WSAcvtQstDisItem"];
}

- (void)processDataWithQstItem:(WSAcvtQstDisItem *)qstItem allDataArray:(NSMutableArray *)dataArray allDataDic:(NSMutableDictionary *)allDataDic isNeedMainSubTitle:(BOOL)isNeedMainSubTitle isNeedQstDisArray:(BOOL)isNeedQstDisArray
{
    
    if (!([qstItem.answer length] > 0)) {
        return;
    }
    
    WSAcvtListDataItem *acvtItem = [allDataDic objectForKey:qstItem.genId];
    if (!acvtItem) {
        acvtItem = [WSAcvtListDataItem new];
        acvtItem.genID = qstItem.genId;
        acvtItem.acvtID = qstItem.acvtId;
        [dataArray addObject:acvtItem];
        [allDataDic setObject:acvtItem forKey:qstItem.genId];
    }
    
    if (qstItem.unRead) {
        acvtItem.unRead = qstItem.unRead;
    }
    
    if ([qstItem.newstoreid length] > 0) {
        acvtItem.newstoreid = qstItem.newstoreid;
    }
    
    
    WSBaseAcvtDBService *acvtDBService = [[WSBaseAcvtDBService alloc] init];
    if (isNeedMainSubTitle) {
        // SFA-14940 
        if ([qstItem.isacvtname isEqualToString:kAcvtNameMainTitle] ||[qstItem.isacvtname isEqualToString:@"14"]) {
            
            if ([acvtItem.mainTitle length] > 0) {
                acvtItem.mainTitle = [NSString stringWithFormat:@"%@ %@", acvtItem.mainTitle, qstItem.answer];
            }else {
                acvtItem.mainTitle = [self getTitleStringWithQstItem:qstItem];
            }
            
        }else if ([qstItem.isacvtname isEqualToString:kAcvtNameSubTitle]) {
            
            NSString *answer = [self getTitleStringWithQstItem:qstItem];
//            if ([qstItem.qsttype isEqualToString:QST_TYPE_N]) {
                //     SFA-19412
                //      SFA-广福来-ios：考察门店、感兴趣的产品，价格保留后2位

//                answer = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:answer.doubleValue]];
//            }
            NSString * isContainColons = @":";
            if ([qstItem.qstName containsString:isContainColons]) {
                isContainColons = @"";
            }
            NSString *name = [NSString stringWithFormat:@"%@%@ ", qstItem.qstName,isContainColons];
            NSString *value = answer;
            NSDictionary *attrDicName = @{NSForegroundColorAttributeName:MAIN_TEXT_COLOR};
            NSDictionary *attrDicValue = @{NSForegroundColorAttributeName:DETAIL_TEXT_COLOR};
            
            NSAttributedString *nameAtt = [[NSAttributedString alloc] initWithString:name attributes:attrDicName];
            NSAttributedString *valueAtt = [[NSAttributedString alloc] initWithString:value attributes:attrDicValue];
            
            if ([acvtItem.subTitle length] > 0) {
                [acvtItem.subTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
            }else {
                NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
                acvtItem.subTitle = attrStr;
            }
            
            [acvtItem.subTitle appendAttributedString:nameAtt];
            [acvtItem.subTitle appendAttributedString:valueAtt];
            
        } else if ([qstItem.isacvtname isEqualToString:kAcvtNameLeftTitle]) {
            NSString * isContainColons = @":";
            if ([qstItem.qstName containsString:isContainColons]) {
                isContainColons = @"";
            }
            NSString *leftTitle = [NSString stringWithFormat:@"%@%@ %@", qstItem.qstName,isContainColons,qstItem.answer];
            if ([acvtItem.leftTitle length] > 0) {
                acvtItem.leftTitle = [NSString stringWithFormat:@"%@ %@", acvtItem.leftTitle, leftTitle];
            } else {
                acvtItem.leftTitle = leftTitle;
            }
        }else if ([qstItem.isacvtname isEqualToString:kAcvtNameRightTitle]) {
            
            NSString *answer = qstItem.answer;
            if ([qstItem.qsttype isEqualToString:@"T"]) {
                answer = qstItem.acvtanswer;
            }
//            if ([qstItem.qsttype isEqualToString:QST_TYPE_N]) {
//                answer = [self.numberFormatter stringFromNumber:[NSNumber numberWithDouble:answer.doubleValue]];
//            }
            
            if ([acvtItem.rightTitle length] > 0) {
                acvtItem.rightTitle = [NSString stringWithFormat:@"%@ %@", acvtItem.rightTitle, answer];
            }else {
                acvtItem.rightTitle = answer;
            }
        }else if ([qstItem.isacvtname isEqualToString:kAcvtNameLeftImg]) {
            /*
             左图标
             */
            NSString *acvtAnser =  qstItem.answer;
            NSString *optPic = [acvtDBService queryOptPicByID:qstItem.acvtanswer acvtQstID:qstItem.acvtQstId];
            if ([optPic length] > 0) {
                acvtAnser =  optPic;;
            }
//            NSString *compeletUrl = [WSHttpURLHelper getImageCompleteURL:acvtAnser];
//            acvtItem.leftIconUrl = compeletUrl;
            acvtItem.leftIconUrl = acvtAnser;
        } else if ([qstItem.isacvtname isEqualToString:kAcvtNameRightTitleColor]) {
            acvtItem.rightTitleColor = qstItem.answer;
        }
        else if ([qstItem.isacvtname isEqualToString:kAcvtNameGroupName])
        {
            //YIHAIKERRY-1142益海嘉里深圳分组需求
            acvtItem.groupName = qstItem.answer;
        }
        else if ([qstItem.isacvtname isEqualToString:kAcvtNameGroupSummary])
        {
            //YIHAIKERRY-1142益海嘉里深圳分组需求
            acvtItem.groupSummary = qstItem.acvtanswer;
        }else if ([qstItem.isacvtname isEqualToString:KAcvtNameGroupExPression]){
            if (acvtItem.groupExpression.length > 0) {
                //YIHAIKERRY-3877 SFA 益海嘉里-【订单管理】 【IOS】 提单总金额计算错误  不用逗号分割，改为用¥¥分割，因为价格为12,500 中的逗号冲突了
                acvtItem.groupExpression = [NSString stringWithFormat:@"%@%@%@",acvtItem.groupExpression,APPENDING_STRING_TAG,qstItem.acvtanswer];
            }else{
                acvtItem.groupExpression = qstItem.acvtanswer;
            }
        } else if ([qstItem.isacvtname isEqualToString:KAcvtNameRequiredLogo])
        {
            //SFASK-75 史克医院拍拍赚调试
            acvtItem.requiredLogo = qstItem.acvtanswer;
        }
    }
    
    if (isNeedQstDisArray) {
        if (!acvtItem.qstDisArray) {
            acvtItem.qstDisArray = @[qstItem];
        }else {
            NSMutableArray *array = [NSMutableArray arrayWithArray:acvtItem.qstDisArray];
            [array addObject:qstItem];
            acvtItem.qstDisArray = array;
        }
    }
}

// SFA-18859 DV类型需根据answer查询对应dict的name作为显示标题
- (NSString *)getTitleStringWithQstItem:(WSAcvtQstDisItem *)qstItem
{
    NSString *title = qstItem.answer;
    
    if ([qstItem.acvtanswer isEqualToString:qstItem.answer]) {
        if ([qstItem.qsttype isEqualToString:QST_TYPE_DV]) {
            WSBaseDictsDBService *baseDictDBService = [[WSBaseDictsDBService alloc] init];
            WSDictBean *dictBean = [baseDictDBService queryDictWithID:qstItem.answer];
            if (dictBean.name.length > 0) {
                title = dictBean.name;
            }else{
                title = @"null";
            }
        }
    }
    
    return title;
}

- (NSMutableArray *)processDataToNewStoreList:(NSArray *)array isCode:(NSString *)isCode {
    NSArray *genIdArray = [array valueForKeyPath:@"@distinctUnionOfObjects.genId"];
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:genIdArray.count];
    for (NSString *genId in genIdArray) {
        for (WSAcvtQstDisItem *qstItem in array) {
            if ([qstItem.genId isEqualToString:genId]) {
                
                WSAcvtListDataItem *acvtItem = [[WSAcvtListDataItem alloc] init];
                acvtItem.genID = qstItem.genId;
                acvtItem.acvtID = qstItem.acvtId;
                acvtItem.newstoreid = qstItem.storeId;
                
        
                NSString *mainTitle = qstItem.storeName;
                if (![isCode isEqualToString:@"0"] && [qstItem.storeCode length] > 0) {
                    mainTitle = [NSString stringWithFormat:@"%@-%@", qstItem.storeCode, qstItem.storeName];
                }
        
                acvtItem.mainTitle = mainTitle;
                
                [dataArray addObject:acvtItem];
                break;
            }
        }
    }
    return dataArray;
}


- (WSBaseStoreAcvtDisObject *)queryQstServerValueAcvtQstId:(NSString *)acvtQstId genId:(NSString *)genId server_node:(NSString * )server_node{
    NSString * sqlString = [NSString stringWithFormat:@"select * from base_store_acvt_dis where acvtQstId = '%@' and gen_id = '%@' and  server_node like '%@%%'",acvtQstId,genId,server_node];
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    WSBaseStoreAcvtDisObject * obj = (WSBaseStoreAcvtDisObject *)[object queryAndReturnSingleInfoBySql:sqlString andClassName:@"WSBaseStoreAcvtDisObject"];
    return obj;
}

/*查询这个调查问卷的回显数据*/
- (NSArray *)queryAcvtQstDatasByAcvtId:(NSString *)acvtId {
    NSString * sqlString = [NSString stringWithFormat:@"select * from base_store_acvt_dis where acvtId = '%@'",acvtId];
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    return  [object queryAndReturnInfosBySql:sqlString andClassName:@"WSBaseStoreAcvtDisObject"];
}



- (NSArray *)queryAcvtQstDictsCountByAcvtId:(NSString *)acvtId filter:(NSString *)filter objId:(NSString *)objId {
    NSString *styp = @"";
    if ([filter rangeOfString:@"@"].location != NSNotFound) {
        NSArray *array = [filter componentsSeparatedByString:@"@"];
        if ([array count] == 2) {
            NSString *typ = [array firstObject];
            NSString *btyp = array[1];
            styp = [NSString stringWithFormat:@" and bst.styp = '%@' and bst.styp = '%@'",typ,btyp];
        }
        
    }else {
        
        if (filter.length > 0) {
            NSArray *pArray = [filter componentsSeparatedByString:@","];
            NSString *inString  = [pArray getInSqlString];
            styp = [NSString stringWithFormat:@" and bst.styp %@",inString];
        }
        
    }
    NSString *inSerchObjString = @"";
    NSArray *searchObjIdArray = [objId componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < [searchObjIdArray count]; i++) {
        if (i == 0) {
            inSerchObjString = [inSerchObjString stringByAppendingFormat:@"'%@'",searchObjIdArray[i]];
        }else {
            inSerchObjString = [inSerchObjString stringByAppendingFormat:@",'%@'",searchObjIdArray[i]];
        }
    }
    
    NSArray  * objIdArray = [objId componentsSeparatedByString:@","];
    NSString *searchObjId = [NSString stringWithFormat:@"and bst.search_objId %@ ", [objIdArray getInSqlString]];
    
    NSString *sql = [NSString stringWithFormat:@"select bsad.[acvt_qst_answer],count(bsad.[sid]) as queryCount \
                     from base_acvt_qst baq \
                     join base_store_acvt_dis bsad on baq.[acvtQstId]=bsad.acvtQstId and baq.acvtId=bsad.acvtId \
                     join ws_base_store_table bst on bst.store_Id = bsad.sid  %@ %@ \
                     where bsad.[acvtId]= %@  group by bsad.[acvt_qst_answer]", styp, searchObjId, acvtId];
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc] init];
    return [object queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
}

- (BOOL)hasValueForStoreId:(NSString *)storeId acvtId:(NSString *)acvtId
{
    if (!storeId || !acvtId || [storeId length] == 0 || [acvtId length] == 0) {
        return NO;
    }
    NSInteger count = [[WSBaseStoreAcvtDisTable sharedTable] queryCountWithSql:[NSString stringWithFormat:@"select count(_id) from base_store_acvt_dis where sid = '%@' and acvtId = '%@'", storeId, acvtId]];
    
    if (count <= 0) {
        count = [[WSBaseStoreAcvtDisTable sharedTable] queryCountWithSql:[NSString stringWithFormat:@"select count(_id) from visit_store_acvt_data where sid = '%@' and acvtId = '%@'", storeId, acvtId]];
    }
    
    if (count > 0) {
        return YES;
    }
    
    return NO;
}

-(NSString *)queryStoreImageUrlWithStoreId:(NSString *)storeId imgType:(WSStoreImgType)imgType{
    
    if (storeId.length == 0) {
        return nil;
    }
    
    NSString *qstCod =@"smallImgUrl";
    if (imgType == WSStoreImgTypeBig ) {
        qstCod = @"bigImgUrl";
    }
    
    NSString * sqlString = [NSString stringWithFormat:@"select * from base_store_acvt_dis bsad join base_acvt_qst baq on baq.acvtId = bsad.acvtId and baq.acvtQstId = bsad.acvtQstId where baq.qstCod = '%@' and  bsad.sid = '%@'",qstCod,storeId];
    
    WSSqliteUtil *object = [[WSSqliteUtil alloc]init];
    WSBaseStoreAcvtDisObject * obj = (WSBaseStoreAcvtDisObject *)[object queryAndReturnSingleInfoBySql:sqlString andClassName:@"WSBaseStoreAcvtDisObject"];
    return obj.acvt_qst_answer;
}

//通过问题编码数组查询问题回显值方法 qstCode:问题编码
- (NSString *)queryQstValueWithQstCode:(NSString *)qstCode
{
    if(qstCode.length <= 0)
        return qstCode;
    
    NSString *sqlString = [NSString stringWithFormat:@"select acvt_qst_answer from base_acvt_qst left join base_store_acvt_dis on base_acvt_qst._id = base_store_acvt_dis.acvtQstId where base_acvt_qst.qstCod = '%@' and emp_id = '%@'", qstCode, [WSAppData getObjectbyKey: APPDATA_EMPID]];
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *resultArray = [sqliteUtil queryDicDatasBySql:sqlString argumentsValues:nil];
    if (resultArray.count > 0)
        resultArray = [resultArray valueForKey:@"acvt_qst_answer"];
    return [resultArray firstObject];
}


- (NSArray *)queryQstValueWithStoreId:(NSString *)storeID acvtQstIdArray:(NSArray *)acvtQstIdArray {
    NSString *qstQuery = [acvtQstIdArray getInSqlString];
    
    NSString *empId = [WSAppData getObjectbyKey: APPDATA_EMPID];
    NSString *sql = [NSString stringWithFormat:@"select acvt_qst_answer  from visit_store_acvt_data where sid = '%@' and acvtQstId %@ and emp_id = '%@' union select acvt_qst_answer from base_store_acvt_dis where sid = '%@' and acvtQstId %@ and emp_id = '%@'", storeID, qstQuery, empId, storeID, qstQuery, empId];
    
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreAcvtDisObject"];
    return  [dataArray valueForKey:@"acvt_qst_answer"];
}
-(NSArray *)queryAcvtDisWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode qstType:(NSString*)qstType{
    NSString * sql = [NSString stringWithFormat:@"select distinct baq.qstname  qstname,  bsad.acvt_qst_answer   qstanwser  , baq.displayMode   qstdisplaymodel , baq.hideQstName,groupName , baq.qstIconUrl qstIconUrl from base_store_acvt_dis bsad  join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='%@' join base_acvt_qst baq on baq.acvtId=ba._id and baq._id=bsad.acvtQstId  and bsad.sid = '%@' where bsad.emp_id = '%@' and baq.qsttype = '%@' ",acvtCode,storeId,[WSAppData getObjectbyKey:APPDATA_EMPID],qstType];
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable]  queryAndReturnInfosBySql:sql andClassName:@"WSShowQstViewSingleLineModel"];
    return dataArray;
}
-(NSArray *)queryAcvtDisWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode{
    if (storeId.length == 0 || acvtCode.length == 0) return nil;
    /*select distinct baq.qstname  qstName,  bsad.acvt_qst_answer   qstanwser  , baq.displayMode   qstdisplaymodel , baq.hideQstName from base_store_acvt_dis
     bsad  join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='store_emp_acvt' join base_acvt_qst baq on baq.acvtId=ba._id and baq._id=bsad.acvtQstId  and bsad.sid = '198202'*/
//    NSString * sql = [NSString stringWithFormat:@"select distinct qstname || acvt_qst_answer as acvt_qst_answer from base_store_acvt_dis bsad  join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='%@' join base_acvt_qst baq on baq.acvtId=ba._id and baq._id=bsad.acvtQstId  and bsad.sid = '%@'",acvtCode,storeId];
    NSString * sql = [NSString stringWithFormat:@"select distinct baq.qstname  qstname,  bsad.acvt_qst_answer   qstanwser  , baq.displayMode   qstdisplaymodel , baq.hideQstName,groupName , baq.qstIconUrl qstIconUrl from base_store_acvt_dis bsad  join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='%@' join base_acvt_qst baq on baq.acvtId=ba._id and baq._id=bsad.acvtQstId  and bsad.sid = '%@' where bsad.emp_id = '%@' and  (qstanwser is not null or baq.defaultValue is not null)",acvtCode,storeId,[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable]  queryAndReturnInfosBySql:sql andClassName:@"WSShowQstViewSingleLineModel"];
//    return  [dataArray valueForKey:@"acvt_qst_answer"];
    return dataArray;
}

- (NSArray *)queryAcvtUploadTimeWithStoreId:(NSString *)storeId withsubEmpId:(NSString *)subEmpId{
    
    NSString *tempStoreId = storeId;
    NSString *tempEmpId = subEmpId;
    if (tempStoreId == nil) {
        tempStoreId = @"-1";
    }
    if (tempEmpId == nil) {
        tempEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    NSArray *keyArray = @[@"$lstore$",@"$sstore$",@"$lempId$",@"$sempId$"];
    NSString *lStore = [NSString stringWithFormat:@"and ldis.sid = '%@'",tempStoreId];
    NSString *sStore = [NSString stringWithFormat:@"and dis.sid = '%@'",tempStoreId];
    NSString *lEmpId = [NSString stringWithFormat:@"and ldis.emp_id = '%@'",tempEmpId];
    NSString *sEmpId = [NSString stringWithFormat:@"and dis.emp_id = '%@'",tempEmpId];
    NSArray *valueArray = @[lStore,sStore,lEmpId,sEmpId];
    NSString *sql = [self getSQLWithPlistKey:@"getAcvtUploadTime" keyArray:keyArray valueArray:valueArray];
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryObjectsBySql:sql argumentsValues:nil className:@"WSAcvtBean_qst"];
    return dataArray;
}

#pragma mark - YIHAIKERRY-2139 董宏添加 查询问卷列表的时间回显 storeId:门店id
- (NSArray *)queryAcvtQuestionAnswerWithStoreId:(NSString *)storeId
{
    //YIHAIKERRY-3012 增加门店StoreId查询条件
    NSString *ldisStoreId = ((storeId.length > 0) ? ([NSString stringWithFormat:@"or ldis.[sid] = '%@'", storeId]) : @"");
    NSString *sqlStoreId = ((storeId.length > 0) ? ([NSString stringWithFormat:@"or dis.[sid] = '%@'", storeId]) : @"");
    NSString *sql = [NSString stringWithFormat:@"select qst.acvtId acvtId, qst.color color, qst.memo memo, ifnull(ldis.[acvt_qst_answer], dis.[acvt_qst_answer]) as acvt_qst_answer   from base_acvt_qst qst left join visit_store_acvt_data ldis on ldis.[acvtQstId] = qst.[acvtId] || qst.[qstId] and ldis.[emp_id] ='%@' and (ldis.[sid] is null or ldis.[sid]='-1' %@) left join base_store_acvt_dis dis on dis.[acvtQstId] = qst.[_id] and dis.[emp_id] = '%@' and (dis.[sid] is null or dis.[sid] = '-1' %@) where qst.qstCod ='lastUploadTime'", [WSAppData getObjectbyKey:APPDATA_EMPID], ldisStoreId, [WSAppData getObjectbyKey:APPDATA_EMPID], sqlStoreId];
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAcvtQuestionAnswerBean"];
    return dataArray;
}
- (NSInteger )queryAcvtReadNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode andNeedGenId:(BOOL)needGenId
{
    NSString * str = @"";
    if (needGenId) {
        str = @"and serverAcvtData.gen_id = localAcvtData.gen_id";
    }
    NSString *sql = [NSString stringWithFormat:@"select count(serverAcvtData.acvt_qst_answer) unReadNum from base_store_acvt_dis serverAcvtData join base_acvt_qst qst on serverAcvtData.acvtId = qst.acvtId and serverAcvtData.acvtQstId = qst._id and qst.qstCod = '%@' left join visit_store_acvt_data localAcvtData on localAcvtData.sid = serverAcvtData.sid and localAcvtData.acvtQstId = serverAcvtData.acvtQstId and serverAcvtData.acvtId = localAcvtData.acvtId %@ where serverAcvtData.acvt_qst_answer =='0' and serverAcvtData.sid = '%@' and (localAcvtData.acvt_qst_answer is null or localAcvtData.acvt_qst_answer='0')", qstCode, str , storeId];
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAcvtQuestionAnswerBean"];
    
    if(dataArray.count > 0)
    {
        WSAcvtQuestionAnswerBean *beanNum = [dataArray firstObject];
        return beanNum.unReadNum;
    }
    
    return 0;
}
- (NSInteger)queryOrangeCollectAndMainDisplayNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode{
    
    NSString *sql = [NSString stringWithFormat:@"select sum(ifnull(serverAcvtData.acvt_qst_answer,0) - ifnull(localAcvtData.acvt_qst_answer,0)) unReadNum from base_store_acvt_dis serverAcvtData join base_acvt_qst qst on serverAcvtData.acvtId = qst.acvtId and serverAcvtData.acvtQstId = qst._id and qst.qstCod = '%@' left join visit_store_acvt_data localAcvtData on localAcvtData.sid = serverAcvtData.sid and localAcvtData.acvtQstId = serverAcvtData.acvtQstId and serverAcvtData.acvtId = localAcvtData.acvtId where serverAcvtData.sid = '%@'",qstCode, storeId];
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAcvtQuestionAnswerBean"];
    
    NSInteger unreadnum = 0;
    if(dataArray.count > 0)
    {
        for (WSAcvtQuestionAnswerBean *beanNum in dataArray) {
            unreadnum +=  beanNum.unReadNum;
        }
    }
    
    return unreadnum;
}
/*
 *查询CNY活动提示语
 */
- (NSString*)queryCNYActivityAndMainDisplayNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode{
    
    NSString *sql = [NSString stringWithFormat:@"select serverAcvtData.acvt_qst_answer,localAcvtData.acvt_qst_answer as local_acvt_qst_answer from base_store_acvt_dis serverAcvtData join base_acvt_qst qst on serverAcvtData.acvtId = qst.acvtId and serverAcvtData.acvtQstId = qst._id and qst.qstCod = '%@' left join visit_store_acvt_data localAcvtData on localAcvtData.sid = serverAcvtData.sid and localAcvtData.acvtQstId = serverAcvtData.acvtQstId and serverAcvtData.acvtId = localAcvtData.acvtId where serverAcvtData.sid = '%@'",qstCode, storeId];
    
    NSArray *dataArray = [[WSBaseStoreAcvtDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAcvtQuestionAnswerBean"];
    
    NSString * cnyMsg = @"";
    if(dataArray.count > 0)
    {
        WSAcvtQuestionAnswerBean * answerBean = dataArray.firstObject;
        if (answerBean.acvt_qst_answer.length>0&&(ISNULL(answerBean.local_acvt_qst_answer).length==0)) {
            cnyMsg = answerBean.acvt_qst_answer;
        }
    }
    
    return cnyMsg;
}

- (NSInteger)queryMsgReadNumberStoreId:(NSString *)storeId{
    
    NSString *sql = [NSString stringWithFormat:@"select msg_type._id,msg_type.name,count(1),sum(case when msg_store.isread='1' then 1 else 0 end) as readed from base_msg_type msg_type join base_msg  msg on msg_type._id=msg.pid join base_msg_store msg_store on msg_store.msg_id=msg._id where msg_store.store_id='%@' group by msg_type._id,msg_type.name",storeId];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    while ([rs next]) {
        
//        NSObject *instance = [NSClassFromString(@"WSBaseMsgObject") yy_modelWithDictionary:[rs resultDictionary]];
//        [array addObject:instance];
        NSString * count = [rs objectForColumnName:@"count(1)"];
        NSString * readed = [rs objectForColumnName:@"readed"];
        NSInteger unreadCount = [count integerValue] - [readed integerValue];
        [array addObject:[NSString stringWithFormat:@"%ld",unreadCount]];
    }
    
    if (array.count > 0) {
        NSInteger unreadnunm = 0;
        for (NSString * unread in array) {
            unreadnunm += [unread integerValue];
        }
        return unreadnunm>0?unreadnunm:0;
    }
    return 0;
}

@end
