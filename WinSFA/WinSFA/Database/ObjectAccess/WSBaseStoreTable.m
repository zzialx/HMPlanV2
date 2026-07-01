//
//  WSBaseStoreTable.m
//  WinSFA
//
//  Created by heju on 15/9/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreTable.h"
#import "WSBaseAcvtdisDBService.h"
#import "WSAppData.h"
#import "ChineseToPinyin.h"
#import "WSStoreDataProcessService.h"
#import "NSArray+SQL.h"

@implementation WSBaseStoreTable


static WSBaseStoreTable *baseStoreTable = nil;

+ (WSBaseStoreTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseStoreTable alloc] init];
        });
    }
    return baseStoreTable;
}

/*新增的门店退出时候不删除*/
- (void)clearBaseStore {
    
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM ws_base_store_table where acvt_genId is null"];
    [self executeUpdateWithSqls:@[clearSql]];
}

- (void)cleanOldData
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"emp_id", @"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}



- (void)insertAllStoresWith:(NSArray *)stores searchObjId:(NSString *)objId searchObjCode:(NSString *)objCode isPlan:(NSString *)plan {
    if (!stores) {
        LogError(@"stores  is  nil !!!");
        return;
    }
    
//    [stores enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
//        [self insertStoreWith:obj searchObjId:objId searchObjCode:objCode isPlan:plan];
//    }];

    if ([objId isEqualToString:@"autostoreinfofororg"] ) {
        objId = @"autostoreinfo";
    }
    
    NSMutableArray *deleteValuesArray = [NSMutableArray array];
    NSMutableArray *insertValuesArray = [NSMutableArray array];
    [stores enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
        
        NSDictionary *storeDictionary = (NSDictionary *)obj;
        NSString *store_Id = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_id]];
        
        NSArray *insertValues =   [self insertStoreWith:obj searchObjId:objId searchObjCode:objCode isPlan:plan];
        
        [deleteValuesArray addObject:store_Id];
        [insertValuesArray addObject:insertValues];
        
      
       
    }];
    //YIHAIKERRY-3535  数据存入优化
    //改为批量删除，再批量插入，
    //批量删除,改为一句sql 删除多条
    if (deleteValuesArray.count >0) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM ws_base_store_table WHERE search_objId = '%@' and store_Id %@ ", objId, [deleteValuesArray getInSqlString]];
        [self executeUpdateWithSqls:@[sql]];
    }
    
    //    [self batchDeleteDataWithNamesArray:deleteNamesArray ArgumentsValuesArray:deleteValuesArray];
    

    //批量插入
    [self  batchInsertWithArgumentsValuesArray:insertValuesArray];
    
    NSDictionary *storesDicInfo = [WSStoreDataProcessService convertStoresInfoDictionaryFromStores:stores];
    [WSStoreDataProcessService processStoreInfoDataToDbWithStoresInfo:storesDicInfo storeID:nil genId:nil isRemoteSearch:NO];
}



/**
 objId:实时搜索的节点
 objCode:实时搜索的内容
 注意 ws_base_store_table 添加字段要修改这里，这个需要重构下容易出 Bug
 */
- (NSArray *)insertStoreWith:(NSObject *)store searchObjId:(NSString *)objId searchObjCode:(NSString *)objCode isPlan:(NSString *)plan {
    
    NSDictionary *storeDictionary = (NSDictionary *)store;
    
    NSString *isPlanString = [storeDictionary objectForKey:Store_isPlaned];
    if (!isPlanString) {
        isPlanString = plan;
    }
    //备注：srid 的优先级比empId高
//    SFA-21116
//    【iOS】主管-协同拜访：点击人员列表需要实时请求到代表的门店
    NSString *srid = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_srid]];
    NSString *storeEmpId = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_empId]];
    NSString *storeName = [storeDictionary objectForKey:Store_name];
    NSString *store_Id = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_id]];
    NSString *empId = srid.length > 0 ? srid : storeEmpId;
    NSString *name = [NSString stringNotNilWithValue:storeName];
    NSString *code = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_cod]];
    NSString *stype = [NSString stringNotNilWithValue:[storeDictionary objectForKey:STORE_TYPE]];
    if ([[storeDictionary  allKeys] containsObject:@"styp"]) {
        stype = [NSString stringNotNilWithValue:[storeDictionary objectForKey:@"styp"]];
    }
    NSString *addr = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_addr]];
    NSString *lon = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_lon]];
    NSString *lat = [NSString stringNotNilWithValue: [storeDictionary objectForKey:Store_lat]];
    NSString *seq = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_seq]];
    NSString *search_objId = [NSString stringNotNilWithValue:objId];
    NSString *search_code = [NSString stringNotNilWithValue:objCode];
    NSString *lvlcode = @"";
    NSString *dist_rule_id = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_drId]];
    NSString *is_plan = [NSString stringNotNilWithValue:isPlanString];
    NSString *sv = [NSString stringNotNilWithValue:[storeDictionary objectForKey:Store_sv]];
    NSString *visit_status = @"0";
    NSString *biz_date = [NSString stringNotNilWithValue: [WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    NSString *addstore_json_data = @"";
    NSString *store_other_col = @"";
    NSString *pid = @"";
    NSString *acvt_genId = @"";
    NSString *detail_info = @"";
    NSString *beancon_mac = @"";
    NSString *beancon_uuid = @"";
    NSString *linkman = @"";
    NSString *phone = [NSString stringNotNilWithValue:storeDictionary[Store_phone]];
    NSString *storeFilter = @"";
    NSString *cityId = [NSString stringNotNilWithValue:[storeDictionary objectForKey:@"cityCode"]];;
    NSString *state = @"";
    NSString *last_man = [NSString stringNotNilWithValue:storeDictionary[Store_last_man]];
    NSString *last_date = [NSString stringNotNilWithValue:storeDictionary[Store_last_date]];
    NSString *distances = [NSString stringNotNilWithValue:storeDictionary[Store_distance]];
    NSString *row_number = [NSString stringNotNilWithValue:storeDictionary[Store_row_number]];
    NSString *item_name = [NSString stringNotNilWithValue:storeDictionary[Store_item_name]];
    NSString *department_id = [NSString stringNotNilWithValue:storeDictionary[Store_departmentId]];
    NSString *follow = [NSString stringNotNilWithValue:storeDictionary[Store_follow]];
    NSString *qrcode = [NSString stringNotNilWithValue:storeDictionary[Store_qrcode]];
    NSString *ctyp = [NSString stringNotNilWithValue:storeDictionary[Store_ctyp]];
    NSString *orgId = [NSString stringNotNilWithValue:storeDictionary[Store_orgId]];
    NSString *pinyin;
    if ([storeName length] > 0) {
        pinyin = [ChineseToPinyin getPinyinFromName:storeName];
    } else {
        pinyin = @"";
    }
    NSString *custCode = [NSString stringNotNilWithValue:storeDictionary[Store_custCode]];
    
    
//    /**
//     若已有store_id相同的数据 删除旧，插入新的
//     */
//    NSArray *baseStores = [[WSBaseStoreTable sharedTable] queryWithNames:[NSArray arrayWithObjects:@"store_Id",@"search_objId", nil] ArgumentsValue:[NSArray arrayWithObjects:store_Id,[NSString stringNotNilWithValue:objId], nil]];
//    WSBaseStoreObject *storeObject = [baseStores firstObject];
//    if (storeObject && storeObject.store_id) {
//        [[WSBaseStoreTable sharedTable] deleteWithNames:[NSArray arrayWithObjects:@"store_Id",@"search_objId", nil] ArgumentsValue:[NSArray arrayWithObjects:store_Id, [NSString stringNotNilWithValue:objId],nil]];
//    }
    /**
     插入新值
     */
    NSArray *values = @[store_Id,empId,name,code,stype,addr,lon,lat,seq,search_objId,search_code,lvlcode,dist_rule_id,is_plan,sv,visit_status,biz_date,addstore_json_data,store_other_col,pid,acvt_genId,detail_info,beancon_mac,beancon_uuid,linkman,phone,storeFilter,state,last_man,last_date,distances,row_number,item_name,department_id,pinyin,follow,cityId,qrcode,ctyp,custCode,orgId];
    
  
//    [self insertWithArgumentsValue:values];
    

    return values;
}



- (NSArray *)queryStoresWithFilter:(NSString *)qstFilter value:(NSString *)qstRedisValue {
    NSArray *filters = nil;
    if ([qstFilter rangeOfString:@"@"].location != NSNotFound) {
        filters= [qstFilter componentsSeparatedByString:@"@"];
    }else{
        filters = [qstFilter componentsSeparatedByString:@","];
    }
    NSString *filterStr = @" (";
    for (NSInteger i = 0; i < [filters count]; i++) {
        if (i == 0) {
            filterStr = [filterStr stringByAppendingFormat:@"'%@'",filters[i]];
        }else {
            filterStr = [filterStr stringByAppendingFormat:@",'%@'",filters[i]];
        }
    }
    filterStr = [filterStr stringByAppendingString:@")"];
    NSString *sql = [NSString stringWithFormat:@"select * from ws_base_store_table where styp in %@ and store_id = '%@'",filterStr,qstRedisValue];
    return [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreObject"];

}

- (BOOL)queryStoresWithSearchCode:(NSString *)searchCode
{
    NSString *sql = [NSString stringWithFormat:@"select * from ws_base_store_table where empId='%@' and search_code like '%@%%'  limit 1",[WSAppData getObjectbyKey:APPDATA_EMPID],searchCode];
    NSArray *arr =  [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreObject"];

    return  arr.count > 0 ? YES : NO;
    
}
- (NSArray *)queryStoresCitys{
  
    NSString *sql = @"select distinct search_code from ws_base_store_table";
    return [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreObject"];
    
}
@end
