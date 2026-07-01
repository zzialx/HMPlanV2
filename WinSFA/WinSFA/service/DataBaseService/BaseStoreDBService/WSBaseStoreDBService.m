//
//  WSBaseStoreDBService.m
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDBService.h"
#import "WSBaseStoreTable.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSMainLeftViewManager.h"
#import "WSSubempstoreBeanArray.h"
#import "WSBaseAcvtDBService.h"
#import "NSArray+SQL.h"
#import "WSBaseStoreOtherDataDBService.h"
#import "NSArray+SQL.h"

static WSBaseStoreDBService *baseStoreDBService;

#define kTableKeyStore_Id       @"store_Id"
#define kTableKeySearch_objId   @"search_objId"
#define K_SEQ                   (@"seq")
//======================================================================================================================================================

@implementation WSBaseStoreDBService

#pragma mark - 获取共享实例方法
+ (instancetype)shareInstance {
   
    static dispatch_once_t onceToken;
    if (baseStoreDBService == nil) {
        dispatch_once(&onceToken, ^{
            baseStoreDBService = [[self alloc] init];
        });
    }
    return baseStoreDBService;
}

#pragma mark - 替换数据方法1
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData {
    
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:nil];
}

#pragma mark - 替换数据方法2
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LAST_UPDATE_LOCATION_MESSAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];

    BOOL ret = NO;
    WSBaseStoreTable *table = [WSBaseStoreTable sharedTable];
    
    if ([storeID length] > 0) {
        
        if ([dicts count] > 0) {
            ret = [table deleteWithNames:@[@"pid"] ArgumentsValue:@[storeID]];
        }
    }
    else {
     
        NSString *sql = [NSString stringWithFormat:@"delete from ws_base_store_table where search_objId = '%@' and (acvt_genId is null or acvt_genId = '')", nodeName];
        ret = [table executeUpdateWithSqls:@[sql]];
    
        NSArray *storeIdArry = [dicts valueForKey:@"id"];
        if (storeIdArry.count > 0) {
            [table batchDeleteFromTableWithNames:@[@"store_Id", kTableKeySearch_objId] ArgumentsValues:@[storeIdArry, @[nodeName]]];
        }
    }
    
    dicts = [self addPinyinFromNameToDicts:dicts];
    if (ret) {
        
        ret = [table batchInsertToTableWithMap:@{@"store_Id" : @{kMapKey_serverKey:Store_id},
                                                 @"code" : @{kMapKey_serverKey:Store_cod},
                                                 K_SEQ : @{kMapKey_serverKey:DICTS_SEQ},
                                                 @"search_objId" : @{kMapKey_placeHolder:nodeName},
                                                 @"dist_rule_id" : @{kMapKey_serverKey:Store_drId},
                                                 @"pid" : @{kMapKey_serverKey:Store_parentsid}}
                                         Dicts:dicts];
    }
    return ret;
}

#pragma mark - 查询全部门店数据方法1
- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr
                          search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode
                         parentStoreFc:(NSString *)parentStoreFc {
    
    return [self queryAllStoreWithFuncCode:funcCode empId:empId styp:styp searchStr:searchStr search_objId:objId isSearchable:isSearchable
                           storeAccessMode:storeAccessMode acvtId:nil  selectedQstValues:nil rangeConditions:nil distance:0 pageNumber:-1 distanceSort:nil
                              otherDataDic:nil parentStoreFc:parentStoreFc];
}

#pragma mark - 查询全部门店数据方法2
- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr
                          search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode
                                acvtId:(NSString *)acvtId selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions
                              distance:(CGFloat)distance pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort
                          otherDataDic:(NSDictionary *)otherDataDic parentStoreFc:(NSString*)parentStoreFc {
    
    return  [self queryAllStoreWithFuncCode:funcCode empId:empId styp:styp searchStr:searchStr search_objId:objId isSearchable:isSearchable
                            storeAccessMode:storeAccessMode acvtId:acvtId selectedQstValues:qstValues rangeConditions:rangeConditions distance:distance
                                 pageNumber:pageNumber distanceSort:distanceSort otherDataDic:otherDataDic storeFiletrTyp:nil parentStoreFc:parentStoreFc];
}

#pragma mark - 查询全部门店数据方法3
- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr
                          search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode
                                acvtId:(NSString *)acvtId selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions
                              distance:(CGFloat)distance pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort
                          otherDataDic:(NSDictionary *)otherDataDic storeFiletrTyp:(NSString *)storeFiletrTyp parentStoreFc:(NSString*)parentStoreFc {
    
   return  [self queryAllStoreWithFuncCode:funcCode empId:empId styp:styp searchStr:searchStr search_objId:objId isSearchable:isSearchable
                           storeAccessMode:storeAccessMode acvtId:acvtId selectedQstValues:qstValues rangeConditions:rangeConditions distance:distance
                                pageNumber:pageNumber distanceSort:distanceSort otherDataDic:otherDataDic storeFiletrTyp:storeFiletrTyp notPlan:NO
                             parentStoreFc:parentStoreFc];
}

#pragma mark - 查询全部门店数据方法4
- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr
                          search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode acvtId:(NSString *)acvtId
                     selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance
                            pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort otherDataDic:(NSDictionary *)otherDataDic
                        storeFiletrTyp:(NSString *)storeFiletrTyp notPlan:(BOOL)notPlan parentStoreFc:(NSString*)parentStoreFc {
    
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *biz_dateStr = [NSString stringWithFormat:@"%@", biz_date];
    NSString *empIdStr = [NSString stringWithFormat:@"%@", empId];
    NSString *func_codeStr  = @"";
    
    if ([parentStoreFc length] > 0) {
        
        func_codeStr = [self appendingSubConditionSql:funcCode];
        func_codeStr = [NSString stringWithFormat:@"and status.func_code in %@", func_codeStr];
    }
    
    NSString *vis_parentfcStr = @"";
    if ([funcCode length] > 0) {
        
        vis_parentfcStr = [self appendingSubConditionSql:funcCode];
        vis_parentfcStr = [NSString stringWithFormat:@"and vis.func_code in %@", vis_parentfcStr];
    }
    
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    
    NSString *inStypStr = @"";
    if ([styp length] > 0) {
        
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@", inStypStr];
    }
    
    NSString *acvtSearchStr = @"";
    NSString *isRouteId = [otherDataDic objectForKey:kStoreDBOtherData_RouteID];

    if ([isRouteId isEqualToString:@"1"]) {
        
        NSString *routeId = @"999999";
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"]) {
            routeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"];
        }
        acvtSearchStr = [NSString stringWithFormat:@"join base_store_other_data bsod on bsod.type = '%@' and bsod.item1 = '%@' and bsod.store_id = store.store_Id",
                         VISIT_PLAN_ROUTE, routeId];
    }
    else if ([isRouteId isEqualToString:@"2"]) {
        
        NSString *routeId = @"999999";
        routeId = [otherDataDic objectForKey:kStoreDBOtherData_RouteID_Value];
        acvtSearchStr =  [NSString stringWithFormat:@"join base_store_other_data bsod on bsod.type = '%@' and bsod.item1 = '%@' and bsod.store_id = store.store_Id",
                          VISIT_PLAN_ROUTE, routeId];
    }
    acvtSearchStr = [NSString stringWithFormat:@"%@  %@", acvtSearchStr, [self getAcvtSearchConditionWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions]];
    
    NSString *nameOrCodeSearchStr = @"";
    NSString *phoneSearchStr = @"";
    if (searchStr.length >= 6) {
        phoneSearchStr = [NSString stringWithFormat:@" or (store.[phone] like '%%%@%%')", searchStr];
    }
    
    searchStr = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchStr length] > 0) {
        
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" and ((store.[name] like '%%%@%%')", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[code]) like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[search_code]) like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[lvlcode] like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[addr]) like '%%%@%%' )", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingString:phoneSearchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[pinyin] like '%%%@%%'))", [searchStr lowercaseString]];
        if (isSearchable) {
            nameOrCodeSearchStr = [NSString stringWithFormat:@"and (store.[search_code]) = '%@'", searchStr];
        }
    }
    
    NSString *isVisitedStr = @"";
    NSString *limitStr = @"";
    if (pageNumber > -1) {
        limitStr =  [NSString stringWithFormat:@"limit %ld,%d",(long)(pageNumber * kStoreListPageCount), kStoreListPageCount];
    }
    
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@", inSearchObjStr];
    }
    
    NSString *storeFiletr = @"";
    if (storeFiletrTyp && [storeFiletrTyp length] > 0) {
        storeFiletr = [NSString stringWithFormat:@"and store.ctyp = '%@' ", storeFiletrTyp];
    }
    
    NSString * distanceSql = @"";
    NSString *planSeq = @"plan desc,";
    NSString *visitPlanMapOrder = @"cast(visitPlanMapOrder as int),";
    
    if (distanceSort && [distanceSort isEqualToString:@"1"]) {
        distanceSql = [NSString stringWithFormat:@"bsv.[biz_date] desc, case when (distance = '' or distance is null) then %ld else cast(distance as int) end,",
                       NSIntegerMax];
    }
    else if (distanceSort && [distanceSort isEqualToString:@"3"]) {
        distanceSql = [NSString stringWithFormat:@" case when (distance = '' or distance is null) then %ld else cast(distance as int) end,",
                       NSIntegerMax];
        planSeq = @"";
        visitPlanMapOrder = @"";
    }
    else if (distanceSort == nil) {
        distanceSql = [NSString stringWithFormat:@"bsv.[biz_date] desc,"];
    }
    
    if (notPlan) {
        
        planSeq = @"";
        visitPlanMapOrder = @"";
        distanceSql = @"";
    }
    
    NSArray *storeIds = [self queryRouteStoreIds];
    NSString *routeStoreIds = @"";
    NSString *routeStoreSeq = @"";
    if (storeIds.count > 0) {
   
        NSString *ids = [self appendingSubConditionSql:[storeIds componentsJoinedByString:@","]];
        routeStoreIds = [NSString stringWithFormat:@", (case when store.[store_Id] in %@ then 1 end)  as isRouteStore", ids];
        routeStoreSeq = @"cast(isRouteStore as int) desc,";
    }
    
    NSString *customizedEmpId = [NSString stringWithFormat:@"(store.[empId]) = '%@'", empIdStr];
    NSString *customizedGroup = [NSString stringWithFormat:@"group by store.[store_Id]"];
    NSString *sql_isFollowStore = @"";
    NSString *isFollowStore = [otherDataDic objectForKey:kStoreDBOtherData_isFollowStore];
    if (isFollowStore && [isFollowStore isEqualToString:@"1"]) {
        
        sql_isFollowStore = [NSString stringWithFormat:@"and store.follow = '%@'", @"1"];
        
        WSSubempstoreBeanArray *subempstoreBeanArray = [WSAppData getObjectbyKey:SUBEMPSTORES];
        NSArray *idStrArray = [subempstoreBeanArray.subempstoreArray valueForKeyPath:@"Id"];
        NSString *idStr = [idStrArray componentsJoinedByString:@","];
        NSString *objStr = [self appendingSubConditionSql:idStr];
        customizedEmpId = [NSString stringWithFormat:@"(store.[empId]) in %@", objStr];
        
        customizedGroup = @"";
    }
    
    NSString *storeClass = @"";
    NSString *storeClassCondition = [otherDataDic objectForKey:kStoreDBOtherData_storeClassCondition];
    if ([storeClassCondition length] > 0) {
        storeClass = storeClassCondition;
    }
    
    NSString *visitTimeSort = @"";
    NSString *visitTimeSortStr = [otherDataDic objectForKey:kStoreDBOtherData_visitTimeSort];
    if ([visitTimeSortStr isEqualToString:@"1"]) {
        visitTimeSort = @"last_date ,";
    }
    
    if ([isRouteId isEqualToString:@"1"]) {
        planSeq = [NSString stringWithFormat:@" bsod.item3, %@", planSeq];
    }
    else if ([isRouteId isEqualToString:@"2"]) {
        planSeq = [NSString stringWithFormat:@" bsod.item3, "];
    }
    
    NSString *routeNameSql = [NSString stringWithFormat:@"left join  base_store_other_data bsod1 on  bsod1.store_id = store.store_Id and bsod1.type = '%@'",
                              kWinStoreRouteResponseObjId];
    
    NSArray *keyArray = @[@"$acvtSearchCondition$", @"$customizedEmpId$", @"$biz_date$", @"$isFollowStore$", @"$func_code$",
                          @"$vis_parentfc$", @"$empId$", @"$likeStypStr$", @"$customizedGroup$", @"$storeClass$",
                          @"$nameOrCodeSearch$", @"$isVisited$", @"$limit$", @"$inSearchObjStr$", @"$planSeq$",
                          @"$visitPlanMapOrder$", @"$distanceSeq$", @"$isRouteStore$", @"$isRouteStoreSeq$", @"$isLastDtae$",
                          @"$routeNameCondition$", @"$storeFiletr$"];
    NSArray *valueArray = @[acvtSearchStr, customizedEmpId, biz_dateStr, sql_isFollowStore, func_codeStr,
                            vis_parentfcStr, empIdStr, inStypStr, customizedGroup, storeClass,
                            nameOrCodeSearchStr, isVisitedStr, limitStr, inSearchObjStr, planSeq,
                            visitPlanMapOrder, distanceSql, routeStoreIds, routeStoreSeq, visitTimeSort,
                            routeNameSql, storeFiletr];
    NSArray *objects = [self queryObjectsWith:[WSStoreBean class] plistKey:@"allStoresQuerySql" keyArray:keyArray valueArray:valueArray];
    for (WSStoreBean *storeBean in objects) {
        
        storeBean.storeAccessMode = storeAccessMode;
        if ([storeIds containsObject:storeBean.Id]) {
            
            NSInteger index = [storeIds indexOfObject:storeBean.Id];
            storeBean.isRouteStore = [NSString stringWithFormat:@"%ld", index + 1];
        }
    }
    
    return objects;
}

#pragma mark - 查询查总门店数量方法
- (NSInteger )queryAllStoreCountEmpId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId
                         isSearchable:(BOOL)isSearchable acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues
                      rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance otherDataDic:(NSDictionary *)otherDataDic {
    
    NSString *empIdStr = [NSString stringWithFormat:@"%@",empId];
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    NSString *inStypStr = @"";
    if ([styp length] > 0) {
        
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@", inStypStr];
    }
    
    NSString *nameOrCodeSearchStr = @"";
    NSString *phoneSearchStr = @"";
    if (searchStr.length >= 6) {
        
        phoneSearchStr = [NSString stringWithFormat:@" or (store.[phone] like '%%%@%%')", searchStr];
    }
    searchStr = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([searchStr length] > 0) {
        
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" and ((store.[name] like '%%%@%%')", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[code]) like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[search_code]) like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[lvlcode] like '%%%@%%'", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[addr]) like '%%%@%%' )", searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingString:phoneSearchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[pinyin] like '%%%@%%'))", [searchStr lowercaseString]];
        if (isSearchable) {
            nameOrCodeSearchStr = [NSString stringWithFormat:@"and (store.[search_code]) = '%@'", searchStr];
        }
    }
    
    NSString *acvtSearchStr = @"";
    NSString *isRouteId = [otherDataDic objectForKey:kStoreDBOtherData_RouteID];
    if (isRouteId && [isRouteId isEqualToString:@"1"]) {
        
        NSString *routeId = @"999999";
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"]) {
            routeId = [[NSUserDefaults standardUserDefaults] objectForKey:@"routeId"];
        }
        acvtSearchStr = [NSString stringWithFormat:@"join base_store_other_data bsod on bsod.type = '%@' and bsod.item1 = '%@' and bsod.store_id = store.store_Id",
                         VISIT_PLAN_ROUTE, routeId];
    }
    
    acvtSearchStr = [NSString stringWithFormat:@"%@  %@", acvtSearchStr, [self getAcvtSearchConditionWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions]];

    if ([inSearchObjStr length] > 0) {
        
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@", inSearchObjStr];
    }
    
    NSString *distanceCondition = @"";
    if (distance > 0) {
        
        distanceCondition = [NSString stringWithFormat:@"and cast(store.distances as int) > 0 and cast(store.distances as int) <= %f", distance];
    }
    
    NSString *sql_isFollowStore = @"";
    NSString *isFollowStore = [otherDataDic objectForKey:kStoreDBOtherData_isFollowStore];
    if (isFollowStore && [isFollowStore isEqualToString:@"1"]) {
        sql_isFollowStore = [NSString stringWithFormat:@"and store.follow = '%@'", @"1"];
    }
    
    NSString *sql = [NSString stringWithFormat:@"select store.store_Id from ws_base_store_table store %@ where store.empId = '%@' %@ %@ %@ %@ %@ group by store.store_Id",
                     acvtSearchStr, empIdStr, inStypStr, inSearchObjStr, nameOrCodeSearchStr, distanceCondition, sql_isFollowStore];
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    NSInteger count = 0;
    while ([rs next]) {
        count++;
    }
    
    return count;
}










/*全部门店 to 客户管理*/
- (NSArray *)queryAllStoreForModifyWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort {
    
    return [self queryStoreForModifyWithFuncCode:funcCode empId:empId styp:styp searchStr:searchStr search_objId:objId acvtId:nil selctedQstValues:nil rangeConditions:nil pageNumber:pageNumber distanceSort:distanceSort storeId:nil];
}
- (NSArray *)queryStoreForModifyWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort storeId:(NSString *)storeId
{
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *biz_dateStr = [NSString stringWithFormat:@"%@",biz_date];
    NSString *empIdStr = [NSString stringWithFormat:@"%@",empId];
    NSString *func_codeStr = [NSString stringWithFormat:@"and status.func_code = '%@'",funcCode];
    NSString *vis_parentfcStr = [NSString stringWithFormat:@"and vis.func_code = '%@'",funcCode];
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    
    NSString *inStypStr = @"";
    if ([styp length] > 0) {
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    NSString *nameOrCodeSearchStr = @"";
    //SaaS蒙牛智网行动-经销商运营系统MN-2999 搜索栏添加电话号码搜索MN-3026
    NSString *phoneSearchStr = @"";
    if (searchStr.length >= 6) {
        phoneSearchStr = [NSString stringWithFormat:@" or (store.[phone] like '%%%@%%')",searchStr];
    }
    if ([searchStr length] > 0) {
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" and ((store.[name] like '%%%@%%')",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[code]) like '%%%@%%'",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[lvlcode] like '%%%@%%'",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[addr]) like '%%%@%%' ))",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingString:phoneSearchStr];
        
        // MSTD-7051 拼音搜索
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[pinyin] like '%%%@%%')", [searchStr lowercaseString]];
    }
    NSString *isVisitedStr = @"";/*空*/
    NSString *limitStr = @"";/*自己填写限制*/
    if (pageNumber > -1) {
        limitStr =  [NSString stringWithFormat:@"limit %ld,%d",(long)(pageNumber * kStoreListPageCount),kStoreListPageCount];
    }
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    }
    
    NSString * searchStoreId = @"";
    if (storeId && storeId.length > 0) {
        searchStoreId = [NSString stringWithFormat:@"and store.store_Id = '%@'",storeId];
    }
    
    NSString * distanceSql = @"";
    if (distanceSort && [distanceSort isEqualToString:@"1"]) {
       // distanceSql = [NSString stringWithFormat:@"cast(distance as int),"];
        //SFA-22944  【SFA泸州老窖】【iOS】客户管理排序逻辑不正确 --zhangmin 2018/8/21  没有距离的在最底下
        distanceSql = [NSString stringWithFormat:@"case when (distance = '' or distance is null) then %ld else cast(distance as int) end,",NSIntegerMax];
    }
    
    NSString * acvtSearchStr = [self getAcvtSearchConditionWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions];
    
    NSArray *keyArray = @[@"$biz_date$",@"$empId$",@"$func_code$",@"$vis_parentfc$",@"$empId$",@"$inSearchObjStr$",@"$likeStypStr$" ,@"$nameOrCodeSearch$" ,@"$isVisited$", @"$distanceSeq$", @"$limit$", @"$searchStoreId$",@"$acvtSearchCondition$"];
    NSArray *valueArray = @[biz_dateStr,empIdStr ,func_codeStr,vis_parentfcStr,empIdStr,inSearchObjStr,inStypStr,nameOrCodeSearchStr,isVisitedStr,distanceSql, limitStr,searchStoreId,acvtSearchStr];
    NSArray *objects =  [self queryObjectsWith:[WSStoreBean class] plistKey:@"allModifyStoreInfo" keyArray:keyArray valueArray:valueArray];
    //    NSLog(@"objects--%@",objects);
    return objects;

}

/*用调查问卷的答案过滤门店 acvtId + acvtQstId + acvtqstanswer  在basestoreacvtdis节点下查出关联的门店*/

- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues rangeConditions:rangeConditions pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort distance:(CGFloat)distance otherDataDic:(NSDictionary *)otherDataDic
{
    
    NSString *biz_date = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *biz_dateStr = [NSString stringWithFormat:@"%@",biz_date];
    NSString *empIdStr = [NSString stringWithFormat:@"%@",empId];
    NSString *func_codeStr = [NSString stringWithFormat:@"and status.func_code = '%@'",funcCode];
    NSString *vis_parentfcStr = [NSString stringWithFormat:@"and vis.func_code = '%@'",funcCode];
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
   
    NSString *seq = @"actionStateSeq, bsv.[biz_date] desc, cast(store.row_number as int), cast(store.[seq] as int) ,";
    
    
    NSString *inStypStr = @"";
    if ([styp length] > 0) {
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    // SFA-24006 zhaodanyang
    searchStr = [searchStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nameOrCodeSearchStr = @"";
    if ([searchStr length] > 0) {
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" and ((store.[name] like '%%%@%%')",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[code]) like '%%%@%%'",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[lvlcode] like '%%%@%%'",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[addr]) like '%%%@%%' )",searchStr];
        nameOrCodeSearchStr = [nameOrCodeSearchStr stringByAppendingFormat:@" or (store.[pinyin] like '%%%@%%'))", [searchStr lowercaseString]];// MSTD-7051 拼音搜索
    }
    NSString *isVisitedStr = @"";/*空*/
    NSString *limitStr = @"";/*自己填写限制*/
    
    if (pageNumber > -1) {
        limitStr =  [NSString stringWithFormat:@"limit %ld,%d",(long)(pageNumber * kStoreListPageCount),kStoreListPageCount];
    }
    
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    }
    
    NSString *acvtSearchStr = [self getAcvtSearchConditionWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions];
   
    NSString * distanceSql = @"";
    if (distanceSort && [distanceSort isEqualToString:@"1"]) {
//        distanceSql = [NSString stringWithFormat:@"cast(distance as int),"];
        distanceSql = [NSString stringWithFormat:@"case when (distance = '' or distance is null) then %ld else cast(distance as int) end,",NSIntegerMax];

    }
    
    NSString * distanceCondition = @"";
    if (distance > 0) {
        distanceCondition = [NSString stringWithFormat:@"and cast(store.distances as int) > 0 and cast(store.distances as int) <= %f",distance];
    }
    
    NSString *customizedEmpId = [NSString stringWithFormat:@"(store.[empId]) = '%@'", empIdStr];
    NSString *customizedGroup = [NSString stringWithFormat:@"group by store.[store_Id]"];
    NSString *sql_isFollowStore = @"";
    NSString *isFollowStore = [otherDataDic objectForKey:kStoreDBOtherData_isFollowStore];
    if(isFollowStore && [isFollowStore isEqualToString:@"1"])
    {
        sql_isFollowStore = [NSString stringWithFormat:@"and store.follow = '%@'", @"1"];
        
        WSSubempstoreBeanArray *subempstoreBeanArray = [WSAppData getObjectbyKey:SUBEMPSTORES];
        NSArray *idStrArray = [subempstoreBeanArray.subempstoreArray valueForKeyPath:@"Id"];
        NSString *idStr = [idStrArray componentsJoinedByString:@","];
        NSString *objStr = [self appendingSubConditionSql:idStr];
        customizedEmpId = [NSString stringWithFormat:@"(store.[empId]) in %@", objStr];
        
        customizedGroup = @"";
    }
    
    NSString *sortAcvtSearchStr = @"";
    if ([[otherDataDic objectForKey:kStoreDBOtherData_isMengNiu] isEqualToString:@"1"])
    {
        //蒙牛加
        sortAcvtSearchStr = [self sortAcvtSearchCondionWith:(NSString *)acvtId qstValues:qstValues];
        seq = @"";
    }
    
    
    NSString *storeClass = @"";
    NSString *storeClassCondition = [otherDataDic objectForKey:kStoreDBOtherData_storeClassCondition];
    if ([storeClassCondition length] > 0) {
        storeClass = storeClassCondition;
    }
    
    NSString *routeNameSql = [NSString stringWithFormat:@"left join  base_store_other_data bsod1 on  bsod1.store_id = store.store_Id and bsod1.type = '%@'",
                              kWinStoreRouteResponseObjId];
    
    NSMutableArray *keyArray = [NSMutableArray arrayWithObjects:@"$customizedEmpId$", @"$biz_date$", @"$isFollowStore$",
                                @"$func_code$", @"$vis_parentfc$", @"$empId$", @"$customizedGroup$",
                                @"$storeClass$", @"$likeStypStr$", @"$nameOrCodeSearch$", @"$isVisited$", @"$limit$",
                                @"$inSearchObjStr$", @"$sortAcvtSearchCondition$", @"$acvtSearchCondition$",
                                @"$distanceSeq$", @"$distanceCondition$", @"$routeNameCondition$", @"$seq$", nil];
    NSMutableArray *valueArray = [NSMutableArray arrayWithObjects:customizedEmpId, biz_dateStr, sql_isFollowStore,
                                  func_codeStr, vis_parentfcStr, empIdStr, customizedGroup,
                                  storeClass, inStypStr, nameOrCodeSearchStr, isVisitedStr, limitStr,
                                  inSearchObjStr, sortAcvtSearchStr, acvtSearchStr,
                                  distanceSql, distanceCondition, routeNameSql, seq, nil];
    
    NSArray *objects = [self queryObjectsWith:[WSStoreBean class] plistKey:@"acvtSearchStoreQuerySql" keyArray:keyArray valueArray:valueArray];
    return objects;
}

/*计划内门店*/
- (NSArray *)queryInPlanStoresWithFuncCode:(NSString *)funcCode  empId:(NSString *)empId search_objId:(NSString *)objId styp:(NSString *)styp biz_date:(NSString *)biz_date
                           storeAccessMode:(WSStoreAccessMode)storeAccessMode otherDataDic:(NSDictionary *)otherDataDic
{
    NSString * funCodeStr= @"";
    if ([funcCode hasPrefix:@"'"]) {
        funCodeStr = funcCode;
    }else{
        funCodeStr = [NSString stringWithFormat:@"'%@'",funcCode];
    }
    
    NSString *empIdStr = [NSString stringWithFormat:@"'%@'",empId];
    NSString *bizDateStr = [NSString stringWithFormat:@"'%@'",biz_date];
    NSString *inStypStr = @"";
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    if ([styp length] > 0)
    {
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    
    if ([inSearchObjStr length] > 0)
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    
    NSString *sql_isFollowStore = @"";
    NSString *isFollowStore = [otherDataDic objectForKey:kStoreDBOtherData_isFollowStore];
    if(isFollowStore && [isFollowStore isEqualToString:@"1"])
        sql_isFollowStore = [NSString stringWithFormat:@"and store.follow = '%@'", @"1"];

    NSArray *keyArray = @[@"$funcCode$", @"$empId$", @"$bizDate$", @"$isFollowStore$", @"$inSearchObjStr$", @"$inStypStr$"];
    NSArray *valueArray = @[funCodeStr, empIdStr,bizDateStr, sql_isFollowStore, inStypStr, inSearchObjStr];
    NSArray *objects =  [self queryObjectsWith:[WSStoreBean class] plistKey:@"todayVisitStoresQuerySql" keyArray:keyArray valueArray:valueArray];
   
    for (WSStoreBean *storeBean in objects)
        storeBean.storeAccessMode = storeAccessMode;
    
    return objects;
}

/*计划内门店数量*/
- (NSInteger)queryInPlanStoresCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId  biz_date:(NSString *)biz_date{
    
   
    NSString *inStypStr = [self appendingSubConditionSql:funcBean.styp];
    NSString *objId = STORES;
    if ([funcBean.ds length] > 0) {
        objId = funcBean.ds;
    }
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    
    if ([inStypStr length] > 0) {
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    }
    
    
    NSString *sql = [NSString stringWithFormat:@"select count(id) from ws_base_store_table store join ws_base_store_visitplan bsv on bsv.store_id=store.store_Id  and store.empId = bsv.emp_id where bsv.emp_id =  '%@' and bsv.biz_date = '%@'  %@  %@ ",empId,biz_date,inStypStr,inSearchObjStr];
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryCountWithSql:sql];
    
}


- (NSInteger)queryAllStoresCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId   {
    
    NSString *objId = STORES;
    if ([funcBean.ds length] > 0) {
        objId = funcBean.ds;
    }
    NSString *inSearchObjStr = [self appendingSubConditionSql:objId];
    NSString *inStypStr = @"";
    NSString *styp = funcBean.styp;
    if ([styp length] > 0) {
        inStypStr = [self appendingSubConditionSql:styp];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    }
    NSString *sql = [NSString stringWithFormat:@"select count(id) from ws_base_store_table store where store.empId = '%@'  %@  %@ ",empId ,inStypStr,inSearchObjStr ];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryCountWithSql:sql];
}



- (NSMutableArray *)querySubempInPlanStoresWithSearch_objId:(NSString *)objId styp:(NSString *)styp empId:(NSString *)srId {
    
    NSString *subObjStr = [self appendingSubConditionSql:objId];
    NSString *subStypStr = [self appendingSubConditionSql:styp];
    NSString *subempStoresSql = [NSString stringWithFormat:@"select * from ws_base_store_table as bstore join ws_base_store_visitplan as bplan on (bstore.store_Id = bplan.store_id and bplan.biz_date = '%@' ",[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    if ([subObjStr length] > 0) {
        subempStoresSql = [subempStoresSql stringByAppendingFormat:@"and bstore.search_objId in %@",subObjStr];
    }
    if ([subStypStr length] > 0) {
        subempStoresSql = [subempStoresSql stringByAppendingFormat:@"and bstore.styp in %@",subStypStr];
    }
    if ([srId length] > 0) {
        subempStoresSql = [subempStoresSql stringByAppendingFormat:@"and bstore.empId = '%@'",srId];
    }
    subempStoresSql = [subempStoresSql stringByAppendingFormat:@")"];
    
    NSMutableArray *subempInplanStores = [NSMutableArray array];
    NSMutableArray *subempInplanBaseStores = [[WSBaseStoreTable sharedTable] queryAndReturnInfosBySql:subempStoresSql andClassName:@"WSBaseStoreObject"];
    for (NSInteger i = 0 ; i < [subempInplanBaseStores count]; i++) {
        WSBaseStoreObject *baseStoreObject = subempInplanBaseStores[i];
        [self setBaseStoreObjImage:baseStoreObject];
        WSStoreBean *storeBean = [[WSStoreBean alloc] initstoreWithBaseStoreObject:baseStoreObject isPlan:YES];
        [subempInplanStores addObject:storeBean];
    }
    return subempInplanStores;
}

- (NSArray *)queryOutPlanVisitingAndVisvitedStoresWithFuncCode:(NSString *)funcCode  empId:(NSString *)empId {
    
    return  [self queryOutPlanVisitingAndVisvitedStoresWithFuncCode:funcCode empId:empId ds:@""];
}
- (NSArray *)queryOutPlanVisitingAndVisvitedStoresWithFuncCode:(NSString *)funcCode  empId:(NSString *)empId ds:(NSString*)ds
{
    
    NSString *inFuncodeStr = @"";
    NSString *storeEmpIdStr = @"";
    NSString *statusEmpIdStr = @"";
    NSString *bsvBizDateStr = @"";
    NSString *bsvEmpIdStr = @"";
    NSString *objId = @"";

    if ([funcCode length] > 0) {
        inFuncodeStr = [inFuncodeStr stringByAppendingFormat:@"and status.[func_code] in(%@)",funcCode];
    }
    
    if ([empId length] > 0) {
        storeEmpIdStr = [storeEmpIdStr stringByAppendingFormat:@"store.[empId]= '%@'",empId];
        statusEmpIdStr = [statusEmpIdStr stringByAppendingFormat:@"and status.[emp_id]= '%@'",empId];
        bsvEmpIdStr = [bsvEmpIdStr stringByAppendingFormat:@"and bsv.emp_id = '%@'",empId];
    }
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if ([bizDate length] > 0) {
        bsvBizDateStr = [bsvBizDateStr stringByAppendingFormat:@"bsv.biz_date = '%@'",bizDate];
    }
    
    if (ds.length > 0) {
        NSArray *pArray = [ds componentsSeparatedByString:@","];
        NSString *inString  = [pArray getInSqlString];
        objId = [NSString stringWithFormat:@"and store.search_objId %@",inString];
    }
    
    NSArray *keyArray = @[@"$funcCode$",@"$storeEmpId$",@"$statusEmpId$",@"$bsvBiz_date$",@"$bsvEmpId$",@"$search_objId$"];
    NSArray *valueArray = @[inFuncodeStr,storeEmpIdStr,statusEmpIdStr,bsvBizDateStr,bsvEmpIdStr,objId];
    
    NSArray *baseStores = [self queryObjectsWith:[WSStoreBean class] plistKey:@"queryOutPlanVisitingAndVisitedStoresSql" keyArray:keyArray valueArray:valueArray];
    return baseStores;
}

- (NSString *)appendingSubConditionSql:(NSString *)string {
    
    NSString *subCondition = @"";
    /*SFA-14583 数据查有误,string是@""时候不能走下面的 create by sunhongfu 2017-11-28*/
    if (string.length > 0) {
        NSArray *conditions = [string componentsSeparatedByString:@","];
        if ([conditions count] > 0) {
            subCondition = [subCondition stringByAppendingFormat:@"("];
            for (NSInteger i = 0; i < [conditions count]; i++) {
                if (i == 0) {
                    subCondition = [subCondition stringByAppendingFormat:@"'%@'",conditions[i]];
                }else {
                    subCondition = [subCondition stringByAppendingFormat:@",'%@'",conditions[i]];
                }
            }
            subCondition = [subCondition stringByAppendingString:@")"];
        }
    }
   
    return subCondition;
}



- (NSString *)generateAcvtSearchCondionWith:(NSString *)acvtId qstValues:(NSDictionary *)qstValues {
    
    __block NSString *sql =  @"";
    [qstValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *keyStr = (NSString *)key;
            NSString *valueStr = @"";
            
            NSArray *valueArray = [(NSString *)obj componentsSeparatedByString:@","];
            
            if (valueArray.count > 1) {
                valueStr = @"(";
            }
            for (NSInteger  i = 0;  i < valueArray.count; i++) {
                if (i == 0) {
                    //SFA-16390  sql里多了两个 "," 逗号导致
                    valueStr = [valueStr stringByAppendingFormat:@"','||bsad%@.acvt_qst_answer||',' like '%%%@%%'", keyStr, valueArray[i]];
                } else {
                    //SFA-16390
                    valueStr = [valueStr stringByAppendingFormat:@" or ','||bsad%@.acvt_qst_answer||',' like '%%%@%%'", keyStr, valueArray[i]];
                }
            }
            if (valueArray.count > 1) {
                valueStr = [valueStr stringByAppendingString:@")"];
            }
            
            sql = [sql stringByAppendingFormat:@" join base_store_acvt_dis bsad%@ on bsad%@.sid=store.store_Id and bsad%@.acvtId='%@' and  bsad%@.acvtQstId='%@' and %@",keyStr,keyStr,keyStr,acvtId,keyStr,keyStr,valueStr];
        }
    }];
    return sql;
}

- (NSDictionary *)getQstMemoDicWithAcvtId:(NSString *)acvtId {
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    NSArray *qstArray = [acvtService queryQstsWithAcvtId:acvtId];
    NSMutableDictionary *qstDic = [NSMutableDictionary dictionaryWithCapacity:[qstArray count]];
    for (WSAcvtBean_qst *qst in qstArray) {
        [qstDic setObject:qst.memo forKey:qst.acvtQstId];
    }
    return [qstDic copy];
}

- (NSString *)generateAcvtSearchCondionByStoreFilterWith:(NSString *)acvtId qstValues:(NSDictionary *)qstValues {
    NSDictionary *qstDic = [self getQstMemoDicWithAcvtId:acvtId];
    
    __block NSString *sql =  @"";
    [qstValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *keyStr = (NSString *)key;
            // 将 acvtId 转为 memo,并替换 memo 中的 t 为 item，用于 base_store_other_data 表的对应列
            NSString *memo = [qstDic objectForKey:keyStr];
            memo = [memo stringByReplacingOccurrencesOfString:@"t" withString:@"item"];
            
            NSString *valueStr;
            
            NSArray *valueArray = [(NSString *)obj componentsSeparatedByString:@","];
            if ([valueArray count] == 1) {
                valueStr = [NSString stringWithFormat:@"and store_filter%@.%@ = '%@'", key, memo, obj];
            } else {
                valueStr = [NSString stringWithFormat:@"and store_filter%@.%@ %@",  key, memo, [valueArray getInSqlString]];
            }
            sql = [sql stringByAppendingFormat:@" join base_store_other_data store_filter%@ on store_filter%@.store_id=store.store_Id and store_filter%@.type='%@' %@", keyStr, keyStr, keyStr, STORE_FILTER, valueStr];
        }
    }];
    return sql;
}





- (NSString *)generateAcvtSearchCondionRangeWith:(NSString *)acvtId qstValues:(NSDictionary *)qstValues {
    
    __block NSString *sql =  @"";
    [qstValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *keyStr = (NSString *)key;
            NSString *valueStr = @"";
            
            NSArray *valueArray = [(NSString *)obj componentsSeparatedByString:QST_SEARCH_RANGE_SEPARATOR];
            if ([valueArray count] == 2) {
                NSString *lowerValue = valueArray[0];
                NSString *upperValue = valueArray[1];
                if ([lowerValue length] > 0 && [upperValue length] > 0) {
                    valueStr = [NSString stringWithFormat:@"answer_dis%@.acvt_qst_answer >= %@ and answer_dis%@.acvt_qst_answer <= %@", keyStr, lowerValue, keyStr, upperValue];
                } else if ([lowerValue length] > 0) {
                    valueStr = [NSString stringWithFormat:@"answer_dis%@.acvt_qst_answer >= %@", keyStr, lowerValue];
                } else {
                    valueStr = [NSString stringWithFormat:@"answer_dis%@.acvt_qst_answer <= %@", keyStr, upperValue];
                }
                
                sql = [sql stringByAppendingFormat:@" join (SELECT CAST(acvt_qst_answer AS double) AS acvt_qst_answer,sid FROM base_store_acvt_dis where acvtQstId='%@' and acvtId='%@') answer_dis%@ on answer_dis%@.sid=store.store_Id and %@", keyStr, acvtId, keyStr, keyStr, valueStr];
            }
        }
    }];
    return sql;
}


- (NSString *)generateAcvtSearchCondionRangeByStoreFilterWith:(NSString *)acvtId qstValues:(NSDictionary *)qstValues {
    
    NSDictionary *qstDic = [self getQstMemoDicWithAcvtId:acvtId];
    
    __block NSString *sql =  @"";
    [qstValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *keyStr = (NSString *)key;
            // 将 acvtId 转为 memo,并替换 memo 中的 t 为 item，用于 base_store_other_data 表的对应列
            NSString *memo = [qstDic objectForKey:keyStr];
            memo = [memo stringByReplacingOccurrencesOfString:@"t" withString:@"item"];
            
            NSString *valueStr = @"";
            
            NSArray *valueArray = [(NSString *)obj componentsSeparatedByString:QST_SEARCH_RANGE_SEPARATOR];
            if ([valueArray count] == 2) {
                NSString *lowerValue = valueArray[0];
                NSString *upperValue = valueArray[1];
                
              
                if ([lowerValue length] > 0 && [upperValue length] > 0) {
                    valueStr = [NSString stringWithFormat:@" store_filter%@.%@ >='%@' and store_filter%@.%@ <= '%@'", keyStr, memo, lowerValue, keyStr, memo, upperValue];
                } else if ([lowerValue length] > 0) {
                    valueStr = [NSString stringWithFormat:@" store_filter%@.%@ >='%@'", keyStr, memo, lowerValue];
                } else {
                    valueStr = [NSString stringWithFormat:@" store_filter%@.%@ <= '%@'", keyStr, memo, upperValue];
                }
                
                // 没有环境未测试
                sql = [sql stringByAppendingFormat:@"  join (SELECT CAST(%@ AS double) AS store_filter%@, sid FROM base_store_other_data store_filter%@ on store_filter%@.store_id=store.store_Id and store_filter%@.type='%@' and %@ ", memo, keyStr, keyStr, keyStr, keyStr, STORE_FILTER, valueStr];
            }
        }
    }];
    return sql;
}


- (WSBaseStoreObject *)queryStoreWithId:(NSString *)storeId {
    NSArray *names = @[@"store_Id"];
    NSArray *values = @[[NSString stringNotNilWithValue:storeId]];
    NSArray *stores = [[WSBaseStoreTable sharedTable] queryWithNames:names ArgumentsValue:values];
    WSBaseStoreObject *baseStoreObject = [stores firstObject];
    [self setBaseStoreObjImage:baseStoreObject];
    return baseStoreObject;
}

/*排序*/
- (NSString *)sortAcvtSearchCondionWith:(NSString *)acvtId qstValues:(NSDictionary *)qstValues
{
    //    __block NSString *sql =  @"";
    //    [qstValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    //        NSString *keyStr = (NSString *)key;
    //
    //        sql =[sql stringByAppendingFormat:@" left join base_store_acvt_dis call on call.sid=store.store_Id and call.acvtId=%@ and  call.acvtQstId=%@ left join base_store_acvt_dis number on number.sid=store.store_Id and number.acvtId=%@ and  number.acvtQstId=%@ left join base_store_acvt_dis sales on sales.sid=store.store_Id and sales.acvtId=%@ and  sales.acvtQstId=%@",acvtId,keyStr,acvtId,keyStr,acvtId,keyStr];
    //        /*和安卓一样,写死,有时间可以做成配置的*/
    //    }];
    NSString *sql =  @"";
    sql =[sql stringByAppendingFormat:@" left join base_store_acvt_dis call on call.sid=store.store_Id and call.acvtId=75075 and  call.acvtQstId=119195 left join base_store_acvt_dis number on number.sid=store.store_Id and number.acvtId=75075 and  number.acvtQstId=119197 left join base_store_acvt_dis sales on sales.sid=store.store_Id and sales.acvtId=75075 and  sales.acvtQstId=119196 "];
    return sql;
}


- (NSString *)queryDrIdWithStoreId:(NSString *)storeId {
    WSBaseStoreObject *storeObj = [self queryStoreWithId:storeId];
    return [storeObj dist_rule_id];
}

- (NSString *)queryStoreNameWithId:(NSString *)storeId
{
    WSBaseStoreObject *storeObj = [self queryStoreWithId:storeId];
    return [storeObj name];
}

- (NSArray *)queryStoreWithId:(NSString *)storeId andEmpId:(NSString *)empId
{
    NSArray *names = @[@"store_Id",@"empId"];
    NSArray *values = @[[NSString stringNotNilWithValue:storeId], [NSString stringNotNilWithValue:empId]];
    NSArray *stores = [[WSBaseStoreTable sharedTable] queryWithNames:names ArgumentsValue:values];
    
    NSMutableArray *subempStores = [NSMutableArray array];
    for (NSInteger i = 0 ; i < [stores count]; i++) {
        WSBaseStoreObject *baseStoreObject = stores[i];
        [self setBaseStoreObjImage:baseStoreObject];
        WSStoreBean *storeBean = [[WSStoreBean alloc] initstoreWithBaseStoreObject:baseStoreObject isPlan:YES];
        [subempStores addObject:storeBean];
    }
    return subempStores;
    
}

- (void)setBaseStoreObjImage:(WSBaseStoreObject *)baseStoreObject {
    if (baseStoreObject) {
        baseStoreObject.storeImg = [self queryStoreImgWithStoreId:baseStoreObject.store_id];
        baseStoreObject.attri = [self queryStoreAttiWithStoreId:baseStoreObject.store_id];
    }
}

- (NSString *)queryStoreAttiWithStoreId:(NSString *)storeId {
    NSString *sql = [NSString stringWithFormat:@"select acvt_qst_answer from base_store_acvt_dis bsad  join base_acvt ba on ba._id = bsad.acvtId and ba.acvtCode = 'store_attribute_icon' join base_acvt_qst baq on baq.acvtId = ba._id and baq._id=bsad.acvtQstId where bsad.sid = '%@'", storeId];
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *dataArray = [sqliteUtil queryDatasBySql:sql columnArr:@[@"acvt_qst_answer"]];
    if ([dataArray count] > 0) {
        return dataArray[0];
    }
    return nil;
}


- (NSString *)queryStoreImgWithStoreId:(NSString *)storeId {
    NSString *sql = [NSString stringWithFormat:@"select acvt_qst_answer from base_store_acvt_dis bsad join base_acvt_qst baq on baq.acvtId = bsad.acvtId and baq.acvtQstId = bsad.acvtQstId  where baq.qstCod='smallImgUrl' and bsad.sid = '%@'", storeId];
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSArray *dataArray = [sqliteUtil queryDatasBySql:sql columnArr:@[@"acvt_qst_answer"]];
    if ([dataArray count] > 0) {
        return dataArray[0];
    }
    return nil;
}

- (NSArray *)queryStoreWithFilter:(NSString *)filter andNodeName:(NSString *)nodeName andEmpId:(NSString *)empId  andPid:(NSString *)pid{
    
    NSString *inStypStr = @"";
    if ([filter length] > 0) {
        inStypStr = [self appendingSubConditionSql:filter];
        inStypStr = [NSString stringWithFormat:@"and store.styp in %@",inStypStr];
    }
    
    NSString *empIdStr = @"";
    
    if ([empId length] >0) {
        empIdStr = [NSString stringWithFormat:@"and empId = '%@'",empId];
    }
    
    NSString *nodeNameString = @"";
    if ([nodeName length] > 0) {
        nodeNameString = [NSString stringWithFormat:@"and search_objId = '%@'",nodeName];
    }
    
    NSString *pidStr = @"";
    if ([pid length] > 0) {
        pidStr = [NSString stringWithFormat:@"and pid = '%@'", pid];
    }
    
    return [self queryObjectsWith:[WSStoreBean class] plistKey:@"queryDVDataSourceStoresSql" keyArray:@[@"$empIdWhere$",@"$filterWhere$",@"$search_objIdWhere$", @"$pidWhere$"] valueArray:@[empIdStr, inStypStr,nodeNameString, pidStr]];
}

- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic acvtGenId:(NSString *)acvtGenId
{
    return [self insertOrUpdateStoreWithDataDic:dic acvtGenId:acvtGenId search_objId:@"stores"];
}

- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic acvtGenId:(NSString *)acvtGenId search_objId:(NSString *)search_objId
{
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSString *storeId = [NSString stringNotNilWithValue:dic[@"storeId"]];
    NSString *storeName = [NSString stringNotNilWithValue:dic[@"name"]];
    NSString *storeCode = [NSString stringNotNilWithValue:dic[@"code"]];
    NSString *storeType = [NSString stringNotNilWithValue:dic[@"type"]];
    NSString *storeAddr = [NSString stringNotNilWithValue:dic[@"addr"]];
    NSString *storeLon = [NSString stringNotNilWithValue:dic[@"lon"]];
    NSString *storeLat = [NSString stringNotNilWithValue:dic[@"lat"]];
    NSString *storeDrId = [NSString stringNotNilWithValue:dic[@"drId"]];
    
    if (!storeId || !acvtGenId) {
        return NO;
    }
    
    BOOL result = NO;
    NSArray *stores = [[WSBaseStoreTable sharedTable] queryWithNames:@[@"store_Id"] ArgumentsValue:@[storeId]];
    if ([stores count] > 0) {
    
        NSArray *names = @[@"empId", @"name", @"code", @"styp", @"addr", @"lon", @"lat", @"acvt_genId", @"dist_rule_id"];
        NSArray *values = @[empId, storeName, storeCode, storeType, storeAddr, storeLon, storeLat, acvtGenId, storeDrId];
        result = [[WSBaseStoreTable sharedTable] updateWithNames:names values:values whereName:@[@"store_Id"] whereValue:@[storeId]];
    } else {
        //MN-4159
        NSString *searchObjId = [NSString stringNotNilWithValue:dic[@"searchObjId"]];
        if (searchObjId && searchObjId.length > 0) {
            
            NSArray *searchObjIdArray = [searchObjId componentsSeparatedByString:@","];
            NSMutableArray *sqlArray = [[NSMutableArray alloc] initWithCapacity:searchObjIdArray.count];
            NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:searchObjIdArray.count];
            NSString *sql = @"insert into ws_base_store_table (store_Id,empId,name,code,styp,search_objId,addr,lon,lat,acvt_genId,dist_rule_id) values(?,?,?,?,?,?,?,?,?,?,?)";
            
            for (int i = 0; i < searchObjIdArray.count; ++i) {
                NSString *element = [searchObjIdArray objectAtIndex:i];
                [sqlArray addObject:sql];
                NSArray *values = @[storeId, empId, storeName, storeCode, storeType, element, storeAddr, storeLon, storeLat, acvtGenId, storeDrId];
                [valueArray addObject:values];
            }
            result = [[WSBaseStoreTable sharedTable] executeUpdateWithSqls:sqlArray withArgumentsInArray:valueArray];
        } else {
            
            NSString *sql = @"insert into ws_base_store_table (store_Id,empId,name,code,styp,search_objId,addr,lon,lat,acvt_genId,dist_rule_id) values(?,?,?,?,?,?,?,?,?,?,?)";
            NSArray *values = @[storeId, empId, storeName, storeCode, storeType, @"stores", storeAddr, storeLon, storeLat, acvtGenId, storeDrId];
            result = [[WSBaseStoreTable sharedTable] executeUpdateWithSqls:@[sql] withArgumentsInArray:@[values]];
        }
    }

    NSArray *allKeys = [dic allKeys];
    for (NSString *key in allKeys) {
        if ([key hasPrefix:STOREACVTDIS]) {
            NSArray *array = dic[key];
            if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                [service replaceToTableWithDicts:array FromNode:key hasNewData:YES storeID:storeId];
            }
        }
    }
    
    return result;
}


- (NSMutableArray *)queryStoreWithSearchObjId:(NSString *)search_objId styp:(NSString *)styp {

    return [self queryStoreWithSearchObjId:search_objId styp:styp empId:nil];
}

-(BOOL)updateStoreWithDataDic:(NSDictionary *)dic{
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    NSString *storeId = [NSString stringNotNilWithValue:dic[@"storeId"]];
//    NSString *storeName = [NSString stringNotNilWithValue:dic[@"name"]];
//    NSString *storeCode = [NSString stringNotNilWithValue:dic[@"code"]];
//    NSString *storeType = [NSString stringNotNilWithValue:dic[@"type"]];
//    NSString *storeAddr = [NSString stringNotNilWithValue:dic[@"addr"]];
//    NSString *storeLon = [NSString stringNotNilWithValue:dic[@"lon"]];
//    NSString *storeLat = [NSString stringNotNilWithValue:dic[@"lat"]];
//    NSString *storeDrId = [NSString stringNotNilWithValue:dic[@"drId"]];
//    NSString *storeDistance = [NSString stringNotNilWithValue:dic[@"distance"]];
    NSString *namesStr = @",name,code,styp,addr,lon,lat,dist_rule_id,distances,";
    if (!storeId) {
        return NO;
    }
    BOOL result = NO;

//    NSArray *names = @[@"empId", @"name", @"code", @"styp", @"addr", @"lon", @"lat", @"dist_rule_id", @"distances"];
//    NSArray *values = @[empId, storeName, storeCode, storeType, storeAddr, storeLon, storeLat,storeDrId, storeDistance];
    
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];

    for (NSString *name in dic.allKeys) {
        if ([namesStr rangeOfString:[NSString stringWithFormat:@",%@,", name]].location != NSNotFound) {
            NSString *valueStr = [NSString stringNotNilWithValue:[dic objectForKey:name]];
            if (valueStr.length > 0) {
                [names addObject:name];
                [values addObject:valueStr];
            }
        }
    }
    
    if (empId.length > 0) {
        [names addObject:@"empId"];
        [values addObject:empId];
    }
    
    result = [[WSBaseStoreTable sharedTable] updateWithNames:names values:values whereName:@[@"store_Id"] whereValue:@[storeId]];
    
    //  SFA 项目 SFA-5682
    NSArray *allKeys = [dic allKeys];
    for (NSString *key in allKeys) {
        if ([key hasPrefix:STOREACVTDIS]) {
            NSArray *array = dic[key];
            if ([array isKindOfClass:[NSArray class]] && [array count] > 0) {
                WSBaseAcvtdisDBService *service = [[WSBaseAcvtdisDBService alloc] init];
                result =  [service replaceToTableWithDicts:array FromNode:key hasNewData:YES storeID:storeId];
            }
        }
    }

    return result;
}

- (NSString *)queryStoreValueWithParamCol:(NSString *)col storeBean:(WSStoreBean *)storeBean {
    if (!storeBean || !col || [col length] == 0) {
        return nil;
    }
    if ([col isEqualToString:Store_lat]) {
        col = @"latitude";
    } else if ([col isEqualToString:Store_lon]) {
        col = @"longitude";
    } else if ([col isEqualToString:@"cod"]) {
        col = @"code";
    }

    if ([self hasVariableWithClass:[WSStoreBean class] varName:col]) {
        return [NSString stringWithValue:[storeBean valueForKey:col]];
    }
    
    return nil;
}

-(NSArray *)queryStoreByStoreId:(NSString *)storeId{
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * sql =[NSString stringWithFormat:@"select store.[store_Id]  Id, store.[empId], store.[name], store.[code], store.[styp], store.[sv], (case when bsv.store_id is not null then 1 else 0 end) as  plan,store.[addr],store.[lon],store.[lat],store.[store_other_col],store.[detail_info] from ws_base_store_table store left join ws_base_store_visitplan bsv on  bsv.store_id = '%@' where store.store_Id = '%@'",storeId,storeId];

    return  [sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreBean"];
}

- (WSStoreBean *)queryStoreByAcvtGenId:(NSString *)acvtGenId{
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * sql =[NSString stringWithFormat:@"select store.[store_Id]  Id, store.[empId], store.[name], store.[code], store.[styp], store.[sv],store.[addr],store.[lon],store.[lat],store.[store_other_col],store.[detail_info] from ws_base_store_table store where store.acvt_genId = '%@'",acvtGenId];
    
    return  [[sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreBean"] firstObject];
}

-(NSArray *)queryAllStoreToUpdataDistanceWith:(NSString *)empId objId:(NSString *)objId styp:(NSString *)styp{
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * stypSql = @"";
    if (styp.length > 0) {
        NSString * stypInString = [self appendingSubConditionSql:styp];
        stypSql = [NSString stringWithFormat:@"and store.[styp] in %@",stypInString];
    }
    if (objId.length > 0) {
        objId = [self appendingSubConditionSql:objId];
    }
     NSString * sql =[NSString stringWithFormat:@"select store.[store_Id] Id,store.[lon] longitude,store.[lat] latitude from ws_base_store_table store where store.[lon] > 0 and store.[lat] >0  and store.[empId] = '%@' and search_objId in %@ %@  ",empId,objId,stypSql];
    
    return  [sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreBean"];

}

-(NSArray *)queryRoutePlanStoresByFuncCode:(NSString *)funcCode SearchObjId:(NSString *)search_objId empId:(NSString *)empId route_id:(NSString *)route_id{
    
    NSString *funCodeStr = [NSString stringWithFormat:@"'%@'",funcCode];
    
    NSString *empIdStr = [NSString stringWithFormat:@"'%@'",empId];
    NSString *inStypStr = @"";
    NSString *inSearchObjStr = [self appendingSubConditionSql:search_objId];
    
    if ([inSearchObjStr length] > 0) {
        inSearchObjStr = [NSString stringWithFormat:@"and store.search_objId in %@",inSearchObjStr];
    }
    NSArray *keyArray = @[@"$funcCode$",@"$empId$",@"$inSearchObjStr$",@"$inStypStr$",@"$routeId$"];
    
    NSArray *valueArray = @[funCodeStr,empIdStr,inStypStr,inSearchObjStr,(route_id?route_id:@"")];
    
    NSArray *objects =  [self queryObjectsWith:[WSStoreBean class] plistKey:@"queryRoutePlanStore" keyArray:keyArray valueArray:valueArray];
    
    return objects;
}
    
    
/**
 查找某条路线的门店id集合

 @return id集合
 */
-(NSArray *)queryRouteStoreIds{
    NSArray * routeArray = [[[NSUserDefaults standardUserDefaults]objectForKey:ROUTE_PLAN_ID] componentsSeparatedByString:@"@"];
     NSString * bizeDate = [routeArray lastObject];
    NSString * routePlanId;
    if ([bizeDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]) {
        routePlanId = [routeArray firstObject];
    }
    if(!routePlanId) return nil;
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * sql = [NSString stringWithFormat:@"select item2 from base_store_other_data where base_store_other_data.type = 'spe_route' and item1 = '%@'",routePlanId];
   return [sqliteUtil queryDatasBySql:sql columnArr:@[@"item2"]];

}

-(NSInteger)queryRoutePlanStoreCountByBiz_date:(NSString *)biz_date search_objId:(NSString *)objId{
    NSArray * routeArray = [[[NSUserDefaults standardUserDefaults]objectForKey:ROUTE_PLAN_ID] componentsSeparatedByString:@"@"];
    NSString * bizeDate = [routeArray lastObject];
    NSString * routePlanId;
    if ([bizeDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]) {
        routePlanId = [routeArray firstObject];
    }

    if(!routePlanId) return 0;
    NSString * sql = [NSString stringWithFormat:@"select count(id) from ws_base_store_table store join base_store_other_data bsod on bsod.item2 = store.store_Id and bsod.item1 = '%@' where store.store_Id not in(select store_Id from  ws_base_store_visitplan where biz_date = '%@')  and store.search_objId in ('%@') ",routePlanId,biz_date,objId];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryCountWithSql:sql];
}


- (NSInteger)queryAllStoresCount {
    NSString * sql = [NSString stringWithFormat:@"select count(distinct store_id) from ws_base_store_table store where empId = '%@'", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryCountWithSql:sql];
}

// MSTD-7295 查询出一个门店
- (WSStoreBean *)queryOnlyOneStore {
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * sql =[NSString stringWithFormat:@"select store.[store_Id]  Id, store.[empId], store.[name], store.[code], store.[styp], store.[sv], (case when bsv.store_id is not null then 1 else 0 end) as  plan,store.[addr],store.[lon],store.[lat],store.[store_other_col],store.[detail_info] from ws_base_store_table store  left join ws_base_store_visitplan bsv on  bsv.store_id = store.store_id where empId = '%@'  limit 1", [WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    return (WSStoreBean *)[sqliteUtil queryAndReturnSingleInfoBySql:sql andClassName:@"WSStoreBean"];
}

-(NSMutableArray *)queryStoreWithSearchObjId:(NSString *)search_objId styp:(NSString *)styp empId:(NSString *)empId{
    if (search_objId.length > 0) {
        search_objId = [self appendingSubConditionSql:search_objId];
    }
    NSString *sql = [NSString stringWithFormat:@"select store.[store_Id] Id, store.[empId],store.[is_plan],store.[name], store.[code], store.[seq],store.[styp], store.[sv], store.dist_rule_id drId, store.[addr],store.[lon] longitude,store.[lat] latitude,store.[store_other_col],store.search_objId as noteName,store.[phone],store.[detail_info],store.[storesFilter],store.[state],store.[last_man],store.[last_date],store.[distances] distance,store.[row_number],attribute.acvt_qst_answer attri from ws_base_store_table store left join(select distinct acvt_qst_answer,baq.qstName ,bsad.sid from base_store_acvt_dis bsad   join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='store_attribute_icon' join base_acvt_qst baq on baq.acvtId=ba._id and baq._id=bsad.acvtQstId) attribute on attribute.sid=store.store_Id where store.search_objId in %@",search_objId];
  
    if (styp.length > 0) {
        NSString * stypSql = [self appendingSubConditionSql:styp];
        sql = [NSString stringWithFormat:@"%@ and store.[styp] in %@",sql,stypSql];
    }
    if (empId.length > 0) {
        NSString * stypSql = [self appendingSubConditionSql:empId];
        sql = [NSString stringWithFormat:@"%@ and store.[empId] in %@",sql,stypSql];
    }
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreBean"];
}

- (WSStoreBean *)getStoreWithResponseDic:(NSDictionary *)dic
{
    
    NSString *storeId = [NSString stringNotNilWithValue:dic[@"storeId"]];
    NSString *storeName = [NSString stringNotNilWithValue:dic[@"name"]];
    NSString *storeCode = [NSString stringNotNilWithValue:dic[@"code"]];
    NSString *storeType = [NSString stringNotNilWithValue:dic[@"type"]];
    NSString *storeAddr = [NSString stringNotNilWithValue:dic[@"addr"]];
    NSString *storeLon = [NSString stringNotNilWithValue:dic[@"lon"]];
    NSString *storeLat = [NSString stringNotNilWithValue:dic[@"lat"]];
    NSString *storeDrId = [NSString stringNotNilWithValue:dic[@"drId"]];
    
    WSStoreBean *storeBean = [[WSStoreBean alloc] init];
    storeBean.Id = storeId;
    storeBean.name = storeName;
    storeBean.code = storeCode;
    storeBean.typ = storeType;
    storeBean.addr = storeAddr;
    storeBean.longitude = [storeLon doubleValue];
    storeBean.latitude = [storeLat doubleValue];
    storeBean.drId = storeDrId;
    
    return storeBean;
}

// 门店搜索条件使用 store_filter 节点数据
+ (BOOL)isUseStoreFilterQueryStoreWithAcvtId:(NSString *)acvtId {
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    NSArray *qstArray = [acvtService queryQstsWithAcvtId:acvtId];
    if ([qstArray count] > 0) {
        WSAcvtBean_qst *qst = qstArray[0];
        if ([qst.memo length] > 0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getAcvtSearchConditionWithAcvtId:(NSString *)acvtId qstValues:(NSDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions {
    NSString *acvtSearchStr = @"";
    
    BOOL isUseStoreFilter = [WSBaseStoreDBService isUseStoreFilterQueryStoreWithAcvtId:acvtId];
    if (!isUseStoreFilter) {
        acvtSearchStr = [self getAcvtSearchConditionByAcvtDisWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions];
    } else {
        acvtSearchStr = [self getAcvtSearchConditionByStoreFilterWithAcvtId:acvtId qstValues:qstValues rangeConditions:rangeConditions];
    }

    return acvtSearchStr;
}

- (NSString *)getAcvtSearchConditionByAcvtDisWithAcvtId:(NSString *)acvtId qstValues:(NSDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions {
    NSString *acvtSearchStr = @"";
    
    if ([acvtId length] > 0 && [[qstValues allValues] count] > 0) {
        acvtSearchStr = [self generateAcvtSearchCondionWith:acvtId qstValues:qstValues];
    }
    if ([acvtId length] > 0 && [[rangeConditions allValues] count] > 0) {
        NSString *searchStr = [self generateAcvtSearchCondionRangeWith:acvtId qstValues:rangeConditions];
        if ([searchStr length] > 0) {
            acvtSearchStr = [acvtSearchStr stringByAppendingString:searchStr];
        }
    }
    return acvtSearchStr;
}

- (NSString *)getAcvtSearchConditionByStoreFilterWithAcvtId:(NSString *)acvtId qstValues:(NSDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions {
    NSString *acvtSearchStr = @"";
    
    if ([acvtId length] > 0 && [[qstValues allValues] count] > 0) {
        acvtSearchStr = [self generateAcvtSearchCondionByStoreFilterWith:acvtId qstValues:qstValues];
    }
    if ([acvtId length] > 0 && [[rangeConditions allValues] count] > 0) {
        NSString *searchStr = [self generateAcvtSearchCondionRangeByStoreFilterWith:acvtId qstValues:rangeConditions];
        if ([searchStr length] > 0) {
            acvtSearchStr = [acvtSearchStr stringByAppendingString:searchStr];
        }
    }
    return acvtSearchStr;
}

- (BOOL)deleteBaseStoreTable
{
    WSBaseStoreTable *table = [WSBaseStoreTable sharedTable];
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];

    //根据节点名删除旧数据, 当天本地新增的门店再次登录 不删除
    NSString *sql = [NSString stringWithFormat:@"delete from ws_base_store_table where store_Id not in(select bsod.store_id from base_store_other_data bsod where bsod.type = '%@' and bsod.emp_id = '%@')",WSASVC_OUTPLANSTORE_REQUESTED_FLAG,empId];
        
    return  [table executeUpdateWithSqls:@[sql]];
}
- (BOOL)deleteBaseStoreTableCity:(NSString*)cityCode
{
    //YIHAIKERRY-3767 2018/8/16 删除城市门店时，同时清除otherdatatable中的数据
    [self deleteBaseStoreOtherDataWithCityCode:cityCode type:nil];

    WSBaseStoreTable *table = [WSBaseStoreTable sharedTable];
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    
    //根据节点名删除旧数据, 当天本地新增的门店再次登录 不删除
    NSString *sql = [NSString stringWithFormat:@"delete from ws_base_store_table where cityId = '%@' and empId = '%@'",cityCode,empId];
    
    return  [table executeUpdateWithSqls:@[sql]];
}

- (BOOL)deleteBaseStoreTableCity:(NSString*)cityCode type:(NSString *)type search_obj:(NSString *)search_obj {
    [self deleteBaseStoreOtherDataWithCityCode:cityCode type:type];
    WSBaseStoreTable *table = [WSBaseStoreTable sharedTable];
    NSString *sql = nil;
    BOOL storeUpdateSuccess = NO;
    if ([type isEqualToString:WSCQVC_QUERY_STORE_ORG_LIST]) {
        sql = [NSString stringWithFormat:@"delete from ws_base_store_table where search_objId in ('%@') and orgId = '%@'",search_obj,cityCode];
    } else {
        sql = [NSString stringWithFormat:@"delete from ws_base_store_table where search_objId = '%@' and cityId = '%@'",search_obj,cityCode];
    }
    storeUpdateSuccess = [table executeUpdateWithSqls:@[sql]];
    return  storeUpdateSuccess;
}

- (void)deleteBaseStoreOtherDataWithCityCode:(NSString*)cityCode type:(NSString *)type  {
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *sql = nil;
    if (type && [type isEqualToString:WSCQVC_QUERY_STORE_ORG_LIST]) {
        sql = [NSString stringWithFormat:@"select store.store_Id from ws_base_store_table store  where orgId = '%@' and empId = '%@' group by store.store_Id",cityCode,empId];
    } else {
        sql = [NSString stringWithFormat:@"select store.store_Id from ws_base_store_table store  where cityId = '%@' and empId = '%@' group by store.store_Id",cityCode,empId];
    }
    
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    __block  NSMutableArray *sidArr = [NSMutableArray array];
    while ([rs next]) {
        NSString *storeId = [rs stringForColumn:@"store_Id"];
        [sidArr addObject:storeId];
    }
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    [service deleteBySidWithNodeName:STORE_FILTER dicts:nil storeArray:sidArr];
    
}

@end

