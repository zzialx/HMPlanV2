//
//  WSStoreProddisDBService.m
//  WinSFA
//
//  Created by heju on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseStoreProddisDBService.h"

#import "WSBaseStoreProdDisTable.h"

#define K_PROD_ID (@"prod_id")
#define K_SERVER_NODE (@"server_node")


@implementation WSBaseStoreProddisDBService


- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId{
    
    NSArray *ps = [dicts valueForKey:@"p"];
    NSArray *genIds = [dicts valueForKey:@"gen_id"];
    
    NSArray* spec = [WSAppData getObjectbyKey:PRODSPECDIS];
    if (!spec || [spec count] < 1) {
        spec = [WSAppData getObjectbyKey:PRODSPEC];
    }
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:ps.count];
    //    NSArray *server_nodes = @[nodeName];
    
    NSMutableArray *allProddis = [NSMutableArray arrayWithCapacity:ps.count];
    for (NSInteger i = 0; i < [ps count]; i++) {
        NSMutableDictionary *proddis_dict = [NSMutableDictionary dictionary];
        NSString *pStr = ps[i];
        
        if (pStr && [pStr isKindOfClass:[NSString class]]) {
            
            if (i < [genIds count]) {
                genId = genIds[i];
            }
            
            NSArray *p_compoents = [pStr componentsSeparatedByString:@","];
            for (NSInteger j = 0; j < [p_compoents count]; j++){
                
                NSString *columnValue = [NSString stringNotNilWithValue:p_compoents[j]];
                NSString *columnName = @"";
                if ([spec count] > j) {
                    columnName = [NSString stringNotNilWithValue:spec[j]];
                    if (columnName && ([columnName isEqualToString:@"sid"] || [columnName isEqualToString:@"drid"] || [columnName isEqualToString:@"drId"])) {
                        columnName = @"store_id";
                        
                    }else if (columnName && [columnName isEqualToString:@"pid"]){
                        columnName = @"prod_id";
                        [idsArray addObject:columnValue];
                    }
                }
                [proddis_dict setObject:columnValue forKey:columnName];
            }
            if (![genId isEqual:[NSNull null]]) {
                [proddis_dict setObject:genId forKey:@"genid"];
            }
            [allProddis addObject:proddis_dict];
        }
        
    }
    
    WSBaseStoreProdDisTable *baseStoreProdDisTable = [WSBaseStoreProdDisTable sharedTable];
    
    
    NSArray *arrGenIds = [allProddis valueForKeyPath:@"@distinctUnionOfObjects.genid"];
    
    if (storeID && ![storeID isEqual:[NSNull null]] && [storeID length] > 0) {
        if (allProddis && [allProddis count] > 0) {
            //YIHAIKERRY-4228 与安卓和对逻辑修改 按照genid 删除数据 董宏    进一步优化 去除nodeName条件，与安卓对逻辑--张敏 2018-11-30
            if (arrGenIds.count > 0) {
                [baseStoreProdDisTable batchDeleteFromTableWithNames:@[@"genid",@"store_id"] ArgumentsValues:@[arrGenIds, @[storeID]]];
            }else {
                [baseStoreProdDisTable batchDeleteFromTableWithNames:@[@"store_id",K_SERVER_NODE] ArgumentsValues:@[@[storeID],@[nodeName]]];
            }
        }
    }else {
        
        //兼容：base_store_prod_dis表新增了server_node列，老数据的server_node为空，为了清空老数据，清除server_node为空的数据。
        NSString *sql = @"delete from base_store_prod_dis where server_node is null";
        [baseStoreProdDisTable executeUpdateWithSqls:@[sql]];

        [baseStoreProdDisTable batchDeleteFromTableWithNames:@[K_SERVER_NODE] ArgumentsValues:@[@[nodeName]]];
        
    }
    
    if (allProddis && [allProddis count] > 0) {
        return [baseStoreProdDisTable batchInsertToTableWithMap:@{K_PROD_ID:@{K_SERVER_NODE:@"prod_id"},K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:allProddis];
    }
    
    return YES;
    
}

/*
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId{
    
    WSBaseStoreDictDisTable *dictdisTable = [WSBaseStoreDictDisTable sharedTable];
    NSArray *ps = [dicts valueForKey:@"p"];
    NSArray *empIds = [dicts valueForKey:@"empId"];
    
    NSMutableArray *dictIds = [NSMutableArray arrayWithCapacity:ps.count];
    NSArray *server_nodes = @[nodeName];
    
    NSMutableArray *dictdiss = [NSMutableArray arrayWithCapacity:ps.count];
    for (NSInteger i = 0; i < [ps count]; i++) {
        
        NSMutableDictionary *dictdis = [NSMutableDictionary dictionary];
        NSString *p_str = ps[i];
        NSArray *p_compoents = [p_str componentsSeparatedByString:@","];
        if ([p_compoents count] >= K_P_DEFAULT_LENGTH) {
            
            NSString *empId = @"";
            if (i < [empIds count]) {
                empId = empIds[i];
            }
            NSString *store_id = [p_compoents firstObject];
            NSString *dictIdAndFunccode = p_compoents [1];
            NSArray *id_code_components = [dictIdAndFunccode componentsSeparatedByString:@"@"];
            NSString *dict_id = [id_code_components firstObject];
            [dictIds addObject:dict_id];
            
            NSString *func_code = [id_code_components lastObject];
            NSString *col1 = p_compoents[2];
            NSString *col2 = p_compoents[3];
            NSString *col3 = p_compoents[4];
            NSString *col4 = p_compoents[5];
            NSString *col5 = p_compoents[6];
            NSString *col6 = p_compoents[7];
            NSString *col7 = p_compoents[8];
            NSString *col8 = p_compoents[9];
            NSString *col9 = p_compoents[10];
            
            [dictdis setObject:empId forKey:@"emp_id"];
            [dictdis setObject:store_id forKey:@"store_id"];
            [dictdis setObject:func_code forKey:@"func_code"];
            [dictdis setObject:dict_id forKey:@"dict_id"];
            [dictdis setObject:col1 forKey:@"col1"];
            [dictdis setObject:col2 forKey:@"col2"];
            [dictdis setObject:col3 forKey:@"col3"];
            [dictdis setObject:col4 forKey:@"col4"];
            [dictdis setObject:col5 forKey:@"col5"];
            [dictdis setObject:col6 forKey:@"col6"];
            [dictdis setObject:col7 forKey:@"col7"];
            [dictdis setObject:col8 forKey:@"col8"];
            [dictdis setObject:col9 forKey:@"col9"];
            
            [dictdiss addObject:dictdis];
        }
    }
    
    //    [dictdisTable batchDeleteFromTableWithNames:@[K_DICT_ID,K_SERVER_NODE] ArgumentsValues:@[dictIds,server_nodes]];
    
    
    
    if ([storeID length] > 0) {
        if ([dictdiss count] > 0) {
            [dictdisTable batchDeleteFromTableWithNames:@[@"store_id"] ArgumentsValues:@[@[storeID]]];
        }
    }else {
        [dictdisTable deleteAll];
    }
    
    if ([dictdiss count] > 0) {
        return [dictdisTable batchInsertToTableWithMap:@{K_DICT_ID:@{K_SERVER_NODE:@"dict_id"},
                                                         K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}}  Dicts:dictdiss];
    }
    
    
    return YES;
    
}
*/

- (NSString *)queryRedisValueWith:(Class)cls storeId:(NSString *)sId acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId prodId:(NSString *)prodId colForParam:(NSString *)colName {
    
    if (sId == nil || acvtQstId == nil || acvtId == nil || acvtQstId == nil || prodId == nil || colName == nil) {
        LogInfo(@"sId:%@ acvtId:%@ acvtQstId:%@ prodId:%@ colName:%@ has nil",sId,acvtId,acvtQstId,prodId,colName);
        return nil;
    }
    
    NSArray *keyArrays = @[@"$storeId$",@"$acvtId$",@"$acvtQstId$",@"$prodId$"];
    
    NSString *storeIdStr = [NSString stringWithFormat:@"'%@'",sId];
    NSString *acvtIdStr = [NSString stringWithFormat:@"'%@'",acvtId];
    NSString *acvtQstIdStr = [NSString stringWithFormat:@"'%@'",acvtQstId];
    NSString *prodIdStr = [NSString stringWithFormat:@"'%@'",prodId];
    NSArray *valuesArray = @[storeIdStr,acvtIdStr,acvtQstIdStr,prodIdStr];
    
    NSArray *objects = [self queryObjectsWith:[WSBaseStoreProdDisObject class] plistKey:@"queryAcvtProdDisSql" keyArray:keyArrays valueArray:valuesArray];
    return [(WSBaseStoreProdDisObject*)[objects firstObject] valueForKey:colName];
}

- (NSString *)queryRedisValueWith:(Class)cls funcCode:(NSString *)funcCode storeId:(NSString *)sId  prodId:(NSString *)prodId colForParam:(NSString *)colName {

    if (sId == nil || prodId == nil || colName == nil) {
        LogInfo(@"sId:%@ prodId:%@ colName:%@",sId,prodId,colName);
        return nil;
    }
    NSArray *keyArrays= @[@"$storeId$",@"$prodId$",@"$ConditionWithfuncCode$"];
    NSString *funcodeStr = @"";
    if ([funcCode length] > 0) {
        funcodeStr = [NSString stringWithFormat:@"and bspd.funccode = '%@'",funcCode];
    }
    NSString *storeIdStr = [NSString stringWithFormat:@"'%@'",sId];
    NSString *prodIdStr = [NSString stringWithFormat:@"'%@'",prodId];
    NSArray *valuesArray = @[storeIdStr,prodIdStr,funcodeStr];
    
    NSArray *objects = [self queryObjectsWith:[WSBaseStoreProdDisObject class] plistKey:@"queryProdDisSql" keyArray:keyArrays valueArray:valuesArray];
    return [(WSBaseStoreProdDisObject*)[objects firstObject] valueForKey:colName];
}


/*查找数据调查问卷表格问题回显的所有storeProdDis数据*/
- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId qstId:(NSString *)acvtQstId genId:(NSString *)genId{
    
    return [self queryStoreProdDissWithStoreId:storeId acvtId:acvtId qstId:acvtQstId genId:genId needValidateRedisValueParamCols:nil];
    
}

// SFA-15823 回显更多产品，需过滤指定不为空列值的列(指定列不为空则查询并显示到表格中，其他的则继续放在更多产品)
- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId qstId:(NSString *)acvtQstId genId:(NSString *)genId needValidateRedisValueParamCols:(NSString *)paramColsString
{
    LogTrace();
    if ((storeId == nil || [storeId length] == 0)
        || (acvtId == nil || [acvtId length] == 0)
        || (acvtQstId == nil || [acvtQstId length] == 0 )) {
//        NSLog(@"storeId or acvtID or acvtQstId has nil value");
        return nil;
    }
    NSString *sql;
    
    NSString *validateRedisValueParamColsPartSql = @"";
    
    if (paramColsString && paramColsString.length > 0) {
        NSArray *paramColStrArray = [paramColsString componentsSeparatedByString:@","];
        for (NSString *paramColStr in paramColStrArray) {
            validateRedisValueParamColsPartSql = [NSString stringWithFormat:@"%@ and bspd.%@ is not null ", validateRedisValueParamColsPartSql, paramColStr];
        }
    }
    
    // SFA-20482 添加 base_store_prod_dis 上的 store_id 过滤条件
    if ([genId length] > 0) {
        sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bspd where genid = (select bsad.acvt_qst_answer as genid from base_store_acvt_dis bsad where  bsad.sid = '%@' and bsad.acvtid = '%@' and bsad.acvtqstid = '%@' and gen_id = '%@') %@ and store_id = '%@'",storeId,acvtId,acvtQstId,genId,validateRedisValueParamColsPartSql,storeId];
        
        // MSTD-4553  此处应给base_store_acvt_dis表对应显示数据的store=-1
        if (storeId.length > 0 && [storeId isEqualToString:@"-1"]) {
            sql = [NSString stringWithFormat:@"select * from base_store_prod_dis where genid = (select bsad.acvt_qst_answer as genid from base_store_acvt_dis bsad where bsad.acvtid = '%@' and bsad.acvtqstid = '%@' and gen_id = '%@') %@ and store_id = '%@'",acvtId,acvtQstId,genId,validateRedisValueParamColsPartSql,storeId];
        }
    }else {
        sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bspd where genid = (select bsad.acvt_qst_answer as genid from base_store_acvt_dis bsad where  bsad.sid = '%@' and bsad.acvtid = '%@' and bsad.acvtqstid = '%@' and gen_id is null) %@ and store_id = '%@'",storeId,acvtId,acvtQstId, validateRedisValueParamColsPartSql,storeId];
    }

    
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
}

- (NSString  *)queryStoreProdRedisValueWithGenId:(NSString *)genId storeId:(NSString *)storeId prodId:(NSString *)prodId paramCol:(NSString *)col  repeateIndex:(NSInteger)repeateIndex {
    if ([genId length] == 0
        ||[prodId length] == 0 ) {
//        NSLog(@"genId or storeId or prodId or col has nil value");
        return nil;
    }
    if ([storeId length] == 0) {
        storeId = @"-1";
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis  where  genid = '%@' and  store_id= '%@' and prod_id = '%@'",genId,storeId,prodId];
    NSArray *array = [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
    WSBaseStoreProdDisObject *baseStoreProdDisObject;
    if (repeateIndex < [array count]) {
         baseStoreProdDisObject = array[repeateIndex];
    } else {
        baseStoreProdDisObject = (WSBaseStoreProdDisObject*)[array firstObject];
    }
    
    if ([self hasVariableWithClass:[WSBaseStoreProdDisObject class] varName:col]) {
         return [baseStoreProdDisObject valueForKey:col];
    }
    return nil;
}

- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId {
    if (storeId == nil && [storeId length] == 0) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bsps  where bsps.store_id = '%@'",storeId];
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
}

- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId sortByColParam:(NSString *)colStr isOrderByDesc:(BOOL)isDesc
{
    if (storeId == nil && [storeId length] == 0) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bsps  where bsps.store_id = '%@'",storeId];
    
    if (colStr && colStr.length > 0) {
        if (!isDesc) {
            sql = [NSString stringWithFormat:@"%@ order by cast(bsps.%@ as double) asc", sql, colStr];
        }else
            sql = [NSString stringWithFormat:@"%@ order by cast(bsps.%@ as double) desc", sql, colStr];
    }
    
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
}

- (NSArray *)queryStoreProdDissWithFuncCode:(NSString *)funcCode storeId:(NSString *)storeId {
    if ( [storeId length] == 0 || [funcCode length] == 0) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bsps  where  bsps.funccode = '%@' and bsps.store_id = '%@' ",funcCode,storeId];
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
}

- (NSArray *)queryStoreProdDissWithFuncCode:(NSString *)funcCode storeId:(NSString *)storeId sortByColParam:(NSString *)colStr isOrderByDesc:(BOOL)isDesc
{
    if ( [storeId length] == 0 || [funcCode length] == 0) {
        return nil;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bsps  where  bsps.funccode = '%@' and bsps.store_id = '%@' ",funcCode,storeId];
    
    if (colStr && colStr.length > 0) {
        if (!isDesc) {
            sql = [NSString stringWithFormat:@"%@ order by cast(bsps.%@ as double) asc", sql, colStr];
        }else
            sql = [NSString stringWithFormat:@"%@ order by cast(bsps.%@ as double) desc", sql, colStr];
    }
    
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
}

- (NSArray *)queryStoreProdDissWithGenId:(NSString *)genID storeId:(NSString *)storeId prodIds:(NSString *)prodIds
{
    
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_prod_dis bsps  where"];
    
    if (genID.length > 0) {
        sql = [NSString stringWithFormat:@"%@ bsps.genid = '%@'", sql, genID];
    }else{
        genID = @"null";
        sql = [NSString stringWithFormat:@"%@ bsps.genid is '%@'", sql, genID];
    }
    
    if (storeId.length > 0) {
        if (genID.length <= 0) {
            sql = [NSString stringWithFormat:@"%@ bsps.store_id = '%@'", sql, storeId];
        }else
            sql = [NSString stringWithFormat:@"%@ and bsps.store_id = '%@'", sql, storeId];
    }
    
    if (prodIds.length > 0) {
        if (genID.length <= 0 && storeId.length <= 0) {
            sql = [NSString stringWithFormat:@"%@ bsps.prod_id in ( %@ )", sql, prodIds];
        }else
            sql = [NSString stringWithFormat:@"%@ and bsps.prod_id in ( %@ )", sql, prodIds];
    }
    
    return [[WSBaseStoreProdDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreProdDisObject"];
    
}


@end
