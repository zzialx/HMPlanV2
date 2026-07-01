//
//  WSBaseStoreOtherDataDBService.m
//  WinSFA
//
//  Created by weida on 15/12/28.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreOtherDataDBService.h"
#import "WSBaseStoreOtherDataTable.h"
#import "WSStoreOtherBean.h"
#import "NSArray+SQL.h"

@implementation WSBaseStoreOtherDataDBService

#pragma mark - 重写父类方法，保存到自己的表中
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData {
    
    BOOL ret = NO;
    if (![nodeName isEqualToString:PROMOTION_STORE] && ![nodeName isEqualToString:STORE_FILTER]) {
        
        if ([nodeName isEqualToString:kWinStoreRouteResponseObjId]) {
            
            NSArray *deleteTypes = [dicts valueForKey:@"type"];
            if (deleteTypes.count > 0) {
                ret = [[WSBaseStoreOtherDataTable sharedTable] batchDeleteFromTableWithNames:@[@"type"] ArgumentsValues:@[deleteTypes]];
            }
        }
        else {
            
            NSArray *deleteTypes = [dicts valueForKey:@"type"];
            NSArray *deleteItem1 = [dicts valueForKey:@"item1"];
            if (deleteTypes.count > 0 && deleteItem1.count > 0) {
                ret = [[WSBaseStoreOtherDataTable sharedTable] batchDeleteFromTableWithNames:@[@"type", @"item1"] ArgumentsValues:@[deleteTypes,deleteItem1]];
            }
        }
    }
    else {
        ret = YES;
    }
    
    if (ret) {
        
        NSDictionary * dict;
        if ([nodeName isEqualToString:PRODUNIT]) {
            dict = [self processProdUnitByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:PROMOTION_PINFO]) {
            dict = [self processPromotionPInfoByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:PROMOTION_STORE]) {
            dict = [self processPromotionStoreByNodeName:nodeName dicts:dicts];
        }
        else if([nodeName isEqualToString:SPE_ROUTE]){
            dict = [self processSpeRouteByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:SUBMENUIMGCOORDINATE]){
            dict = [self processSubMenuImgCoordinateByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:SUBMENUIMG]){
            dict = [self processSubMenuImgByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:EMPLOYEEINFORMATION]){
            NSString *item2JsonString = [[dicts firstObject]JSONString];
            dict = [self processEmployeeInfoByNodeName:nodeName jsonString:item2JsonString];
        }
        else if ([nodeName isEqualToString:PROD_SPEC_IMG]){
            dict = [self processProdSpecImgByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:STORE_NOT_REQUEST]){
            dict = [self processStoreNotRequestByNodeName:nodeName];
        }
        else if ([nodeName hasPrefix:STRPTYPDST]){
            dict = [self processStrptypdstKdsByNodeName:nodeName];
        }
        else if ([nodeName hasPrefix:PRODPRICE]){
            dict = [self processProdPriceKdsByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:PRODUCT_COL]) {
            dict = [self processProdColByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:STORE_FILTER]) {
            dict = [self processStoreFilterByNodeName:nodeName dicts:dicts];
        }
        else if ([nodeName isEqualToString:EMP_AREA]) {
            dict = [self processEmpAreaByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:STORE_PROD_RELATION_SHIP]){
            dict = [self processProdRelationByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:PRODUCT_COL_STORE]){
            dict = [self processProdColStoreIdByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:EMP_ORG]) {
            dict = [self processEmpOrgByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:STORE_UPDATE_FLAG]) {
            dict = [self processStoreUpdateFlagByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:STORE_ROUTE_VISIT_STATE]) {
            dict = [self processStoreRouteVisitStatrByNodeName:nodeName];
        }
        else if ([nodeName isEqualToString:ELECTRONICMEMO]) {
            dict = [self electronicMemoByNodeName:nodeName];
        }
        ret = [[WSBaseStoreOtherDataTable sharedTable] batchInsertToTableWithMap:dict Dicts:dicts];
    }
    
    return ret;
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID {
    
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData];
}

- (NSDictionary *)processProdUnitByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:PRODUNIT]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"prodId"},
                           @"item2":@{kMapKey_serverKey:@"convUnitId"},
                           @"item3":@{kMapKey_serverKey:@"cunvQty"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processPromotionPInfoByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:PROMOTION_PINFO]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"ruleId"},
                           @"item2":@{kMapKey_serverKey:@"ruleCode"},
                           @"item3":@{kMapKey_serverKey:@"buyNum"},
                           @"item4":@{kMapKey_serverKey:@"buyNumUnit"},
                           @"item5":@{kMapKey_serverKey:@"percentage"},
                           @"item6":@{kMapKey_serverKey:@"freeSku"},
                           @"item7":@{kMapKey_serverKey:@"freeAmount"},
                           @"item8":@{kMapKey_serverKey:@"freeAmountUnit"},
                           @"item9":@{kMapKey_serverKey:@"priority"},
                           @"item10":@{kMapKey_serverKey:@"groupId"},
                           @"item11":@{kMapKey_serverKey:@"freeSkuName"},
                           @"item12":@{kMapKey_serverKey:@"totalValue"},
                           @"item13":@{kMapKey_serverKey:@"value_dist"},
                           @"item14":@{kMapKey_serverKey:@"prod_group"},
                           @"item15":@{kMapKey_serverKey:@"rflag"},
                           @"item16":@{kMapKey_serverKey:@"prodId"},
                           @"item17":@{kMapKey_serverKey:@"ruleName"},
                           @"item18":@{kMapKey_serverKey:@"giftUnit"},
                           @"item19":@{kMapKey_serverKey:@"giftUnitCol"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processPromotionStoreByNodeName:(NSString *)nodeName dicts:(NSArray *)dicts {
    
    if (![nodeName isEqualToString:PROMOTION_STORE]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"store_id":@{kMapKey_serverKey:@"storeId"},
                           @"item1":@{kMapKey_serverKey:@"ruleId"}};
    NSArray *deleteStoreArray = [dicts valueForKey:@"storeId"];
    [self deleteBySidWithNodeName:nodeName dicts:dicts storeArray:deleteStoreArray];
    
    return dict;
}

- (void)deleteBySidWithNodeName:(NSString *)nodeName dicts:(NSArray *)dicts storeArray:(NSArray *)storeArray {
    
    if ([storeArray count] > 0) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM base_store_other_data WHERE type = '%@' and store_id %@ ", nodeName, [storeArray getInSqlString]];
        [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
    }
}

- (NSDictionary *)processSpeRouteByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:SPE_ROUTE]) {
        return nil;
    }
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"routeId"},
                           @"item2":@{kMapKey_serverKey:@"sid"},
                           @"item3":@{kMapKey_serverKey:@"seq"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processSubMenuImgCoordinateByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:SUBMENUIMGCOORDINATE]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"itemId"},
                           @"item2":@{kMapKey_serverKey:@"imgId"},
                           @"item3":@{kMapKey_serverKey:@"itemCode"},
                           @"item4":@{kMapKey_serverKey:@"startX"},
                           @"item5":@{kMapKey_serverKey:@"startY"},
                           @"item6":@{kMapKey_serverKey:@"endX"},
                           @"item7":@{kMapKey_serverKey:@"endY"},
                           @"item8":@{kMapKey_serverKey:@"fc"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processSubMenuImgByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:SUBMENUIMG]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"imgId"},
                           @"item2":@{kMapKey_serverKey:@"funcCode"},
                           @"item3":@{kMapKey_serverKey:@"name"},
                           @"item4":@{kMapKey_serverKey:@"width"},
                           @"item5":@{kMapKey_serverKey:@"height"},
                           @"item6":@{kMapKey_serverKey:@"url"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processEmployeeInfoByNodeName:(NSString *)nodeName jsonString:(NSString *)jsonString {
    
    if (![nodeName isEqualToString:EMPLOYEEINFORMATION]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:WINSFA_SHARE_DATA_TYPE},
                           @"item1":@{kMapKey_placeHolder:nodeName},
                           @"item2":@{kMapKey_placeHolder:jsonString}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"item1"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processProdSpecImgByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:PROD_SPEC_IMG]) {
        return nil;
    }
 
    NSDictionary *dict = @{@"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"imgorder"},
                           @"item2":@{kMapKey_serverKey:@"imgurl"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processStoreNotRequestByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:STORE_NOT_REQUEST]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"store_id":@{kMapKey_serverKey:@"storeId"},
                           @"type":@{kMapKey_placeHolder:nodeName}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processStrptypdstKdsByNodeName:(NSString *)nodeName {
    
    if (![nodeName hasPrefix:STRPTYPDST]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"store_id":@{kMapKey_serverKey:@"sid"},
                           @"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"pd"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processProdPriceKdsByNodeName:(NSString *)nodeName {
    
    if (![nodeName hasPrefix:PRODPRICE]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"store_id":@{kMapKey_serverKey:@"sid"},
                           @"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"pd"},
                           @"item2":@{kMapKey_serverKey:@"prodid"},
                           @"item3":@{kMapKey_serverKey:@"baseprc"},
                           @"item4":@{kMapKey_serverKey:@"baseunt"},
                           @"item5":@{kMapKey_serverKey:@"minprc"},
                           @"item6":@{kMapKey_serverKey:@"minunt"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processProdColByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:PRODUCT_COL]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"funcode"},
                           @"item2":@{kMapKey_serverKey:@"prod"},
                           @"item3":@{kMapKey_serverKey:@"col"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processProdColStoreIdByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:PRODUCT_COL_STORE]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"store_id":@{kMapKey_serverKey:@"storeId"},
                           @"item1":@{kMapKey_serverKey:@"funcode"},
                           @"item2":@{kMapKey_serverKey:@"prod"},
                           @"item3":@{kMapKey_serverKey:@"col"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processProdRelationByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:STORE_PROD_RELATION_SHIP]) {
        return nil;
    }

    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:nodeName},
                           @"item1":@{kMapKey_serverKey:@"pid"},
                           @"item2":@{kMapKey_serverKey:@"prodId"},
                           @"item3":@{kMapKey_serverKey:@"num"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[nodeName]];
    
    return dict;
}

- (NSDictionary *)processEmpAreaByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:EMP_AREA]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:EMP_AREA},
                           @"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"item1":@{kMapKey_serverKey:@"cityId"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[EMP_AREA]];
    
    return dict;
}

- (NSDictionary *)processEmpOrgByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:EMP_ORG] ) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type":@{kMapKey_placeHolder:EMP_ORG},
                           @"emp_id":@{kMapKey_serverKey:@"empId"},
                           @"item1":@{kMapKey_serverKey:@"orgId"}};
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[EMP_ORG]];
    
    return dict;
}

#pragma mark- 处理storeUpdateFlag信息方法
- (NSDictionary *)processStoreUpdateFlagByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:STORE_UPDATE_FLAG]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type" : @{kMapKey_placeHolder : STORE_UPDATE_FLAG},
                           @"item1" : @{kMapKey_serverKey : @"flag"},
                           @"item2" : @{kMapKey_serverKey : @"message"},    //新增
                           @"item3" : @{kMapKey_serverKey : @"message2"}};  //修改
    [[WSBaseStoreOtherDataTable sharedTable]deleteWithNames:@[@"type"] ArgumentsValue:@[STORE_UPDATE_FLAG]];
    
    return dict;
}

#pragma mark - 处理电子备忘录信息方法
- (NSDictionary *)electronicMemoByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:ELECTRONICMEMO]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type" : @{kMapKey_placeHolder : ELECTRONICMEMO},
                           @"emp_id" : @{kMapKey_serverKey : @"empId"},
                           @"item1" : @{kMapKey_serverKey : @"isShow"},
                           @"item2" : @{kMapKey_serverKey : @"isUrl"}};
    
    [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type"] ArgumentsValue:@[ELECTRONICMEMO]];
    
    return dict;
}

#pragma mark - 处理路线拜访状态方法
- (NSDictionary *)processStoreRouteVisitStatrByNodeName:(NSString *)nodeName {
    
    if (![nodeName isEqualToString:STORE_ROUTE_VISIT_STATE]) {
        return nil;
    }
    
    NSDictionary *dict = @{@"type" : @{kMapKey_placeHolder : STORE_ROUTE_VISIT_STATE},
                           @"biz_date" : @{kMapKey_placeHolder : [WSAppData getObjectbyKey:APPDATA_BIZDATE]},
                           @"emp_id" : @{kMapKey_serverKey : @"empId"},
                           @"item1" : @{kMapKey_serverKey : @"routeId"},
                           @"item2" : @{kMapKey_serverKey : @"storeId"},
                           @"item3" : @{kMapKey_serverKey : @"isVisit"}};
    [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type"] ArgumentsValue:@[STORE_ROUTE_VISIT_STATE]];
    
    return dict;
}

- (NSDictionary *)processStoreFilterByNodeName:(NSString *)nodeName dicts:(NSArray *)dicts {
    
    if (![nodeName isEqualToString:STORE_FILTER]) {
        return nil;
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSInteger i = 1; i <= 20 ; i++) {
        
        NSString *serverKey = [NSString stringWithFormat:@"t%ld", i];
        NSString *key = [NSString stringWithFormat:@"item%ld", i];
        [dict setObject:@{kMapKey_serverKey:serverKey} forKey:key];
    }
    [dict setObject:@{kMapKey_placeHolder:nodeName} forKey:@"type"];
    [dict setObject:@{kMapKey_serverKey:@"id"} forKey:@"store_id"];
    [dict setObject:@{kMapKey_serverKey:@"empId"} forKey:@"emp_id"];

    NSArray *deleteStoreArray = [dicts valueForKey:@"id"];
    [self deleteBySidWithNodeName:nodeName dicts:dicts storeArray:deleteStoreArray];
    
    return dict;
}

+ (void)saveStoreRequestFlagWith:(NSString *)flagType empId:(NSString *)empId storeIdArray:(NSArray *)storeIdArray {
    
    if ([empId length] == 0 || [flagType length] == 0 || [storeIdArray count] == 0) {
        LogInfo(@"flagType or empId or storeId is nil");
        return;
    }
    
    NSString * bizeDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:[storeIdArray count]];
    for (NSString *storeId in storeIdArray) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO base_store_other_data   (emp_id,store_id,type,biz_date) VALUES ('%@','%@','%@','%@')",empId,storeId,flagType,bizeDate];
        [sqlArray addObject:sql];
    }
    [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:[sqlArray copy]];
}

+ (void)saveStoreRequestFlagWith:(NSString *)flagType empId:(NSString *)empId storeId:(NSString *)storeId {
    
    [WSBaseStoreOtherDataDBService saveStoreRequestFlagWith:flagType empId:empId storeIdArray:@[storeId]];
}

- (BOOL)isStoreRequested:(NSString *)flagType empId:(NSString *)empId storeId:(NSString *)storeId {
    
    BOOL isRequested = NO;
    if ([empId length] == 0 || [flagType length] == 0 || [storeId length] == 0) {
        LogInfo(@"flagType or empId or storeId is nil");
        return NO;
    }
    
    NSArray *names = @[@"emp_id",@"store_id",@"type"];
    NSArray *values = @[empId,storeId,flagType];
    NSArray *results = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    if ([results count] > 0) {
        isRequested = YES;
    }
    return isRequested;
}

+ (void)saveStoreSearchObjCode:(NSString *)searchObjCode flagWith:(NSString *)flagType  empId:(NSString  *)empId funcCode:(NSString *)funcCode {
    
    [self saveStoreSearchObjCode:searchObjCode flagWith:flagType empId:empId funcCode:funcCode bizDate:nil];
}

+ (void)saveStoreSearchObjCode:(NSString *)searchObjCode flagWith:(NSString *)flagType  empId:(NSString  *)empId funcCode:(NSString *)funcCode bizDate:(NSString *)bizDate {
    
    if ([empId length] == 0 || [flagType length] == 0 || [funcCode length] == 0 || [searchObjCode length] == 0) {
        LogInfo(@"flagType or empId or funcCode or searchObjStr is nil");
        return;
    }
    
    NSArray *names, *values;
    NSString *sql;
    if (!bizDate) {
        
        names =  @[@"emp_id", @"type", @"item1"];
        values = @[empId, flagType, funcCode];
        sql = [NSString stringWithFormat:@"INSERT INTO base_store_other_data  (emp_id,type,item1,item2) VALUES ('%@','%@','%@','%@')",empId,flagType,funcCode,searchObjCode];
    }
    else {
        
        names = @[@"emp_id", @"type", @"item1", @"biz_date"];
        values = @[empId, flagType, funcCode, bizDate];
        sql = [NSString stringWithFormat:@"INSERT INTO base_store_other_data  (emp_id,type,item1,item2, biz_date) VALUES ('%@','%@','%@','%@', '%@')",empId,flagType,funcCode,searchObjCode, bizDate];
    }
    
    NSArray *results = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    if ([results count] == 1) {
        [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:names ArgumentsValue:values];
    }
    
    [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
}

+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate {
    
    [WSBaseStoreOtherDataDBService saveStoreCityCode:cityCode cityName:cityName empId:empId bizDate:bizDate storeCount:@""];
}

+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate storeCount:(NSString*)storeCount {
    
    return [self saveStoreCityCode:cityCode cityName:cityName empId:empId bizDate:bizDate storeCount:storeCount type:WSCQVC_QUERY_STORE_CITY_LIST];
}

+ (void)saveStoreCityCode:(NSString *)cityCode cityName:(NSString *)cityName  empId:(NSString  *)empId bizDate:(NSString *)bizDate storeCount:(NSString*)storeCount type:(NSString *)type {
    
    if ([empId length] == 0 || [cityCode length] == 0 || [cityName length] == 0 || [bizDate length] == 0) {
        return;
    }
    
    NSArray *names, *values;
    NSString *sql;
    names = @[@"emp_id", @"type", @"item1",@"item2", @"biz_date",@"item3"];
    values = @[empId, @"", cityName,cityCode,bizDate,storeCount];
    sql = [NSString stringWithFormat:@"INSERT INTO base_store_other_data  (emp_id,type,item1,item2, biz_date,item3) VALUES ('%@','%@','%@','%@', '%@','%@')",empId,type,cityName,cityCode, bizDate,storeCount];
    NSString *sqlD = [NSString stringWithFormat:@"delete from base_store_other_data where item2 = '%@' and type = '%@' and emp_id = '%@'",cityCode,type,empId];
    NSArray *results = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    if ([results count] == 1) {
        [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:names ArgumentsValue:values];
    }
    [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sqlD,sql]];
}

- (void)deleteStoreCityCode:(NSString *)cityCode empId:(NSString  *)empId {
    
    [self deleteStoreCityCode:cityCode empId:empId type:WSCQVC_QUERY_STORE_CITY_LIST];
}

- (void)deleteStoreCityCode:(NSString *)cityCode empId:(NSString  *)empId type:(NSString *)type {
    
    NSString *sql = [NSString stringWithFormat:@"delete from base_store_other_data where item2 = '%@' and type = '%@' and emp_id = '%@'",cityCode,type,empId];
    [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
}

+ (BOOL)saveStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withBizDate:(NSString *)bizDate withEmpId:(NSString *)empId genId:(NSString *)genId {
    
    if ( [fc length] == 0 || [acvtId length] == 0 ) {
        LogInfo(@" fc or acvtId is nil");
        return NO;
    }
    
    NSString *tempEmpId = empId;
    if (tempEmpId == nil) {
        tempEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    NSArray *names, *values;
    NSString *sql;
    names = @[@"emp_id",@"item1",@"item2",@"item3",@"item4"];
    values = @[tempEmpId,fc,acvtId,bizDate,genId];
    sql = [NSString stringWithFormat:@"INSERT INTO base_store_other_data  (emp_id,store_id,item1,item2, item3,biz_date) VALUES ('%@','%@','%@','%@', '%@', '%@')",tempEmpId,storeId,fc,acvtId, genId,bizDate];
    NSArray *results = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    if ([results count] == 1) {
        [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:names ArgumentsValue:values];
    }
    
    return [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
}

+ (NSString *)queryStoreSearchObjCodeWithFlag:(NSString *)flagType  empId:(NSString *)empId  funcode:(NSString *)funcCode {
    
    if ([empId length] == 0 || [flagType length] == 0 || [funcCode length] == 0 ) {
        LogInfo(@"flagType or empId or funcCode or searchObjStr is nil");
        return nil;
    }
    
    NSArray *names = @[@"emp_id",@"type",@"item1" ];
    NSArray *values = @[empId,flagType,funcCode];
    NSArray *results = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:names ArgumentsValue:values];
    if ([results count] > 0) {
        WSBaseStoreOtherDataObject *bsotObj = [results firstObject];
        return bsotObj.item2;
    }
    
    return nil;
}

+ (void)clearStoresSearchCodeFlag {
    
    NSArray *names = @[@"type"];
    NSArray *values = @[WSCQVC_QUERY_STORE_SEARCH_OBJ_STR_FLAG];
    [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:names ArgumentsValue:values];
}

- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic {
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSString *dataType = [NSString stringNotNilWithValue:dic[@"type"]];
    NSString *dataItem1 = [NSString stringNotNilWithValue:dic[@"item1"]];
    NSString *dataItem2 = [NSString stringNotNilWithValue:dic[@"item2"]];
    NSString *dataItem3 = [NSString stringNotNilWithValue:dic[@"item3"]];
    NSString *dataItem4 = [NSString stringNotNilWithValue:dic[@"item4"]];
    NSString *dataItem5 = [NSString stringNotNilWithValue:dic[@"item5"]];
    NSString *dataItem6 = [NSString stringNotNilWithValue:dic[@"item6"]];
    NSString *biz_date = [NSString stringNotNilWithValue:dic[@"biz_date"]];
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"item1"] ArgumentsValue:@[dataItem1]];
    
    BOOL result = NO;
    if ([datas count] > 0) {
        
        NSArray *names = @[@"emp_id", @"type", @"item2", @"item3", @"item4", @"item5", @"item6"];
        NSArray *values = @[empId, dataType, dataItem2, dataItem3, dataItem4, dataItem5, dataItem6];
        result = [[WSBaseStoreOtherDataTable sharedTable] updateWithNames:names values:values whereName:@[@"item1"] whereValue:@[dataItem1]];
    }
    else {
        
        NSString *sql = @"insert into base_store_other_data (emp_id,type,item1,item2,item3,item4,item5,item6,biz_date) values(?,?,?,?,?,?,?,?,?)";
        NSArray *values = @[empId, dataType, dataItem1, dataItem2, dataItem3, dataItem4, dataItem5, dataItem6, biz_date];
        result = [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql] withArgumentsInArray:@[values]];
    }
    
    return result;
}

- (BOOL)deleteWithType:(NSString *)type {
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    return [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type", @"emp_id"] ArgumentsValue:@[type, empId]];
}

- (BOOL)deleteWithStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withEmpId:(NSString *)empId{
    
    if ([fc length] == 0 || [acvtId length] == 0 ) {
        LogInfo(@" fc or acvtId is nil");
        return NO;
    }
    
    NSString *tempEmpId = empId;
    if (tempEmpId == nil) {
        tempEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    return [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"emp_id",@"item1",@"item2"] ArgumentsValue:@[tempEmpId,fc,acvtId]];
}
- (BOOL)deleteWithType:(NSString *)type storeId:(NSString *)storeId{
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    return [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type", @"emp_id",@"store_id"] ArgumentsValue:@[type, empId,storeId]];
}

- (BOOL)deleteWithType:(NSString *)type storeId:(NSString *)storeId item3:(NSString *)item3 {
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    return [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type", @"emp_id", @"store_id", @"item3"] ArgumentsValue:@[type, empId,storeId, item3]];
}

- (NSArray *)queryWithType:(NSString *)type {
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"emp_id"] ArgumentsValue:@[type, empId]];
    return datas;
}

- (NSArray *)queryWithType:(NSString *)type withItem16:(NSString *)item16 {
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return [sqliteUtil queryAndReturnInfosBySql:[NSString stringWithFormat:@"select *from base_store_other_data where type = '%@' and item16 = '%@'",type,item16]
                                   andClassName:@"WSStoreOtherBean"];
}

- (NSArray *)querywithType:(NSString *)type withColName:(NSString *)colName withColValue:(NSString *)colValue {
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return  [sqliteUtil queryAndReturnInfosBySql:[NSString stringWithFormat:@"select *from base_store_other_data where type = '%@' and ','||%@||',' like '%%,%@,%%'",type,colName,colValue]
                                    andClassName:@"WSStoreOtherBean"];
}

- (NSArray *)queryWithItem1:(NSString *)item1 {
    
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"item1"] ArgumentsValue:@[item1]];
    return datas;
}

+ (BOOL)saveFuncTipData:(NSArray *)funcTipArray {
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:funcTipArray.count];
    for (NSDictionary *dic in funcTipArray) {

        NSString *item1 = dic[@"fc"];
        NSString *item2 = dic[@"tip"];
        NSString *empId;
        if ([dic[@"empId"] isKindOfClass:[NSArray class]] && [dic[@"empId"] length] > 0) {
            empId = dic[@"empId"];
        }
        else {
            empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        }
        id storeId;
        if ([dic[@"storeId"] isKindOfClass:[NSArray class]] && [dic[@"storeId"] length] > 0) {
            storeId = dic[@"storeId"];
        }
        else {
            storeId = [NSNull null];
        }
        
        if ([item1 length] > 0) {
            
            [dataArray addObject:@{@"type" : FUNC_TIP,
                                   @"item1" : item1,
                                   @"item2" : (item2 ?: @"0"),
                                   @"emp_id" : empId,
                                   @"store_id" : storeId}];
        }
    }
    
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    return [service replaceToTableWithDicts:dataArray FromNode:nil hasNewData:YES];
}

+ (WSBaseStoreOtherDataObject *)queryFuncTipWithFc:(NSString *)fc {
    
    if (!fc) {
        return nil;
    }
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"item1", @"emp_id"] ArgumentsValue:@[FUNC_TIP, fc, empId]];
    return [datas firstObject];
}

+ (WSBaseStoreOtherDataObject *)queryFuncTipWithFc:(NSString *)fc storeId:(NSString *)storeId {
    
    if (!fc) {
        return nil;
    }
    
    id sid = storeId;
    if ([storeId length] == 0) {
        sid = [NSNull null];
    }
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"item1", @"emp_id", @"store_id"] ArgumentsValue:@[FUNC_TIP, fc, empId, sid]];
    return [datas firstObject];
}
+ (WSBaseStoreOtherDataObject *)queryFuncTipWithFc:(NSString *)fc storeId:(NSString *)storeId type:(NSString*)type{
    
    if (!fc) {
        return nil;
    }
    
    id sid = storeId;
    if ([storeId length] == 0) {
        sid = [NSNull null];
    }
    
    NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *datas = [[WSBaseStoreOtherDataTable sharedTable] queryWithNames:@[@"type", @"item1", @"emp_id", @"store_id"] ArgumentsValue:@[type, fc, empId, sid]];
    return [datas firstObject];
}

- (NSInteger)getFuncTipCountWithFC:(NSString *)fc storeId:(NSString *)storeId {

    WSBaseStoreOtherDataObject *obj = [WSBaseStoreOtherDataDBService queryFuncTipWithFc:fc storeId:storeId];
    return [obj.item2 integerValue];
}
- (NSInteger)getWorkCCellFuncTipCountWithFC:(NSString *)fc storeId:(NSString *)storeId type:(NSString*)type{
    WSBaseStoreOtherDataObject *obj = [WSBaseStoreOtherDataDBService queryFuncTipWithFc:fc storeId:storeId type:type];
    return [obj.item2 integerValue];
}

+ (BOOL)saveProdSpecImgData:(NSArray *)dictsArray FromNode:(NSString *)nodeName {
    
    if (![dictsArray isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dictsArray.count];
    for (NSDictionary *dic in dictsArray) {
        
        NSString *item1 = dic[@"imgorder"];
        NSString *item2 = dic[@"imgurl"];
        NSString *empId = [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]];
        if ([item1 length] > 0) {
            
            [dataArray addObject:@{@"type" : nodeName,
                                   @"item1" : item1,
                                   @"item2" : [NSString stringNotNilWithValue:item2],
                                   @"emp_id" : empId}];
        }
    }
    
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    return [service replaceToTableWithDicts:dataArray FromNode:nil hasNewData:YES];
}

+ (BOOL)saveStoreRequestFlagWithData:(NSArray *)dictsArray FromNode:(NSString *)nodeName{
    
    if (![dictsArray isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:dictsArray.count];
    for (NSDictionary *dic in dictsArray) {
        
        NSString *empId = [NSString stringNotNilWithValue:[dic objectForKey:@"empId"]];
        NSString *storeId = [NSString stringNotNilWithValue:[dic objectForKey:@"storeId"]];
        
        if (empId.length > 0 && storeId.length > 0) {
            [dataArray addObject:@{@"type" : nodeName,
                                   @"emp_id" : empId,
                                   @"store_id" : storeId
                                   }];
        }
    }
    
    WSBaseStoreOtherDataDBService *service = [[WSBaseStoreOtherDataDBService alloc] init];
    return [service replaceToTableWithDicts:dataArray FromNode:nil hasNewData:YES];
}

+ (NSArray *)queryProdSpecImg {
    
    NSString *sql = [NSString stringWithFormat:@"select item1, item2 from base_store_other_data where  type ='%@'", PROD_SPEC_IMG];
    NSArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return array;
}

+ (WSBaseStoreOtherDataObject *)queryAcvtGenIdWithStoreId:(NSString *)storeId withFc:(NSString *)fc withAcvtId:(NSString *)acvtId withBizDate:(NSString *)bizDate withEmpId:(NSString *)empId{
    
    NSString *tempEmpId = empId;
    if (tempEmpId == nil) {
        tempEmpId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    }
    
    NSString *sql = [NSString stringWithFormat:@"select *from base_store_other_data where emp_id = '%@' and item1 = '%@' and item2 = '%@' and biz_date = '%@'",tempEmpId,fc,acvtId,bizDate];
    WSBaseStoreOtherDataObject *bsodo = (WSBaseStoreOtherDataObject *)[[WSBaseStoreOtherDataTable sharedTable] queryAndReturnSingleInfoBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return bsodo;
}

- (NSArray *)queryProductColWithFC:(NSString *)fc {
    
    NSString *sql = [NSString stringWithFormat:@"select item2, item3 from base_store_other_data where item1 ='%@' and type ='%@'", fc, PRODUCT_COL];
    NSArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return array;
}

- (NSArray *)queryProductColWithFC:(NSString *)fc storeId:(NSString*)storeId {
    
    NSString *sql = [NSString stringWithFormat:@"select item2, item3 from base_store_other_data where (item1 ='%@' and type ='%@') or (item1 ='%@'  and  type = '%@' and store_id = '%@') ", fc,
                     PRODUCT_COL,fc,PRODUCT_COL_STORE,storeId];
    NSArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return array;
}

- (NSArray *)queryProductUnit {
    
    NSString *sql = @"select item1,item2 from base_store_other_data where type='prodUnit' order by item1, cast (item3 as float) desc";
    NSArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return array;
}

- (NSArray *)queryStoreFilterWithQstArray:(NSArray *)qstArray {
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *sql = @"";
    for (NSInteger i = 0; i < [qstArray count]; i++) {
        
        WSAcvtBean_qst *qst = qstArray[i];
        NSString *memo = qst.memo;
        if (i != 0) {
            sql = [sql stringByAppendingString:@" union "];
        }
        
        NSString *col = [memo stringByReplacingOccurrencesOfString:@"t" withString:@"item"];
        sql = [sql stringByAppendingFormat:@"select %@, count(distinct(store_id)) as queryCount from base_store_other_data where type = '%@' and emp_id = '%@' group by %@ \n", col, STORE_FILTER, empId, col];
    }
    
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    return  [sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreOtherBean"];
}

#pragma mark - 查询高频搜索数据方法
- (NSArray *)queryHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId maxCount:(NSInteger)maxCount {
    
    NSString *sqlType = (type.length > 0) ? type : @"SEARCH_PROD_HISTORY_FLAG";
    NSString *sqlEmpid = (empId.length > 0) ? empId : [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSInteger aqlCount = (maxCount > 0) ? maxCount : 10;
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_other_data where type = '%@' and emp_id = '%@' order by item2 desc limit %ld",
                     sqlType, sqlEmpid, aqlCount];
    NSArray *array = [[[WSSqliteUtil alloc] init] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    return array;
}

#pragma mark - 保存高频搜索数据方法
- (void)saveHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId text:(NSString *)text {
    
    if (!text || text.length <= 0) {
        return;
    }
    
    NSString *sqlType = (type.length > 0) ? type : @"SEARCH_PROD_HISTORY_FLAG";
    NSString *sqlEmpid = (empId.length > 0) ? empId : [WSAppData getObjectbyKey:APPDATA_EMPID];
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_other_data where type = '%@' and emp_id = '%@' and item1 = '%@'",
                     sqlType, sqlEmpid, text];
    WSBaseStoreOtherDataObject *dataObject = (WSBaseStoreOtherDataObject *)[sqliteUtil queryAndReturnSingleInfoBySql:sql andClassName:@"WSBaseStoreOtherDataObject"];
    
    if (!dataObject) {
        
        sql = [NSString stringWithFormat:@"insert into base_store_other_data (emp_id, type, item1, item2) VALUES ('%@','%@','%@','%@')",
               sqlEmpid, sqlType, text, @"1"];
        [[WSBaseStoreOtherDataTable sharedTable] insertWithSqls:@[sql]];
    }
    else {
        
        NSInteger count = [dataObject.item2 integerValue];
        NSString *newCount = [NSString stringWithFormat:@"%ld", (count + 1)];
        sql = [NSString stringWithFormat:@"update base_store_other_data set item2 = '%@' where type = '%@' and emp_id = '%@' and item1 = '%@'",
               newCount, sqlType, sqlEmpid, text];
        [[WSBaseStoreOtherDataTable sharedTable] executeUpdateWithSqls:@[sql]];
    }
}

#pragma mark - 删除高频搜索数据方法
- (void)deleteHighFrequencySearchDataWithType:(NSString *)type empId:(NSString *)empId text:(NSString *)text {
    
    if (!text || text.length <= 0) {
        return;
    }
    NSString *sqlType = (type.length > 0) ? type : @"SEARCH_PROD_HISTORY_FLAG";
    NSString *sqlEmpid = (empId.length > 0) ? empId : [WSAppData getObjectbyKey:APPDATA_EMPID];
    [[WSBaseStoreOtherDataTable sharedTable] deleteWithNames:@[@"type", @"emp_id", @"item1"] ArgumentsValue:@[sqlType, sqlEmpid, text]];
}

@end
