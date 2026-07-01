//
//  WSBaseDictsDBService.m
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDictsDBService.h"
#import "WSBaseDictsTable.h"
#import "WSDictBrand.h"
#import "WSDataSourceManager.h"
#import "WSBaseModel.h"


#define kBaseDictKey_id             (@"_id")
#define kBaseDictKey_server_node    (@"server_node")
#define kBaseDictKey_pid            (@"pid")

#define kServerSeq                  @"SEQ"
#define kServerSeqLowerCase         @"seq"

#define kDictQueryString @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts where "

#define kDictMomeQueryString @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts "


#define kDictQueryStringParent @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts where bdts.levelCode = 1 and "

#define kDictWithDistributeQueryString @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts join base_product on base_product.series = bdts._id join base_in_store_prod on base_in_store_prod.prod_id = base_product._id where "

#define kDictWithGeographyString    @"select bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts where bdts.levelCode=( select max(bdts.levelCode) from  base_dicts bdts where "

#define kDictWithName @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node from base_dicts bdts where "


//查询对店关系的字典项
#define kStoreDictQueryString @"select distinct bdts._id Id,bdts.pid p,bdts.name,bdts.typ,bdts.dtyp,bdts.btyp,bdts.col1,bdts.col2,bdts.cod,bdts.dicts_sequence,bdts.SEQ,bdts.fl,bdts.levelCode,bdts.regex,bdts.server_node ,bsd.memo as memo  from base_dicts bdts "



// 安卓的字典项查询语句
// select base_dicts.[_id] ,base_dicts.[pid],base_dicts.[name],base_dicts.[dicts_sequence] ,count(base_in_store_prod.prod_id) as col1 from base_dicts join base_product on base_product.series = base_dicts._id join base_in_store_prod on base_in_store_prod.prod_id = base_product._id where base_in_store_prod.dist = '1' and base_in_store_prod.store_id = '6006'  and base_dicts.pid ='47047' group by base_dicts._id order by base_dicts.dicts_sequence

@implementation WSBaseDictsDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    LogTrace();
    WSBaseDictsTable *dictTable = [WSBaseDictsTable sharedTable];
    
//    NSArray *idsArry = [dicts valueForKey:@"id"];
//    NSArray *server_nodes = @[nodeName];
//      [dictTable batchDeleteFromTableWithNames:@[kBaseDictKey_id,kBaseDictKey_server_node] ArgumentsValues:@[idsArry,server_nodes]];
    
    
    
    [dictTable deleteWithNames:@[kBaseDictKey_server_node] ArgumentsValue:@[nodeName]];
    
    
    // SFA-21402 SFA-立白-IOS-订单模板调用时按时间降序排
    dicts = [self resetDictsSeq:dicts];
    
    
    ret = [dictTable batchInsertToTableWithMap:@{kBaseDictKey_id:@{kMapKey_serverKey:@"id"},
                                           kBaseDictKey_server_node:@{kMapKey_placeHolder:nodeName},
                                           kBaseDictKey_pid : @{kMapKey_serverKey:@"p"},
                                           kBaseDictKey_seq:@{kMapKey_serverKey:kServerSeq},
                                           kBaseDictKey_seq:@{kMapKey_serverKey:kServerSeqLowerCase}
                                                 } Dicts:dicts];
    return ret;
}

- (NSArray *)queryDictsForAcvtGridWithFilter:(NSString *)filter {
    
    if (filter == nil || [filter length] == 0) {
        NSLog(@"filter is nil or [fliter length] == 0 ");
        return nil;
    }
    NSString *sql = nil;
    if ([filter rangeOfString:@"@"].location != NSNotFound) {
        NSArray *array = [filter componentsSeparatedByString:@","];
        if ([array count] == 2) {
            NSString *typ = [array firstObject];
            NSString *btyp = array[1];
            sql = [NSString stringWithFormat:@"%@ bdts.typ = '%@' and bdts.btyp = '%@'", kDictQueryString,typ,btyp];
        }
        
    }else {
        NSArray *pArray = [filter componentsSeparatedByString:@","];
        NSString *inString = @"in (";
        for (NSInteger i = 0; i < [pArray count]; i++) {
            if (i == 0) {
                inString = [inString stringByAppendingFormat:@"'%@'",pArray[i]];
            }else {
                inString = [inString stringByAppendingFormat:@",'%@'",pArray[i]];
            }
        }
        inString = [inString stringByAppendingFormat:@")"];
        
        sql = [NSString stringWithFormat:@"%@ bdts.typ %@", kDictQueryString,inString];
    }
    
    NSArray *oArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
    
    NSArray *resultArray = [[NSArray alloc] init];
    resultArray = [self useSEQSortArrayWithOriginArray:oArray];
    
    return resultArray;
    
}


// SFA-4523 依照SEQ字段对数组进行排序
- (NSArray *)useSEQSortArrayWithOriginArray:(NSArray *)originArray
{
    NSComparator cmptr = ^(WSDictBean *obj1, WSDictBean *obj2){
        if ([obj1.SEQ integerValue] > [obj2.SEQ integerValue]) {
            
            return (NSComparisonResult)NSOrderedDescending;
            
        }
        if ([obj1.SEQ integerValue] < [obj2.SEQ integerValue]) {
            
            return (NSComparisonResult)NSOrderedAscending;
            
        }
        
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *afterSortArray = [originArray sortedArrayUsingComparator:cmptr];
    
    return afterSortArray;
}

- (NSString *)queryAcvtDictsGridRedisWithStoreId:(NSString *)storeId qst:(WSAcvtBean_qst *)qst param:(WSFuncsBean_Param *)param dict:(WSDictBean *)dictBean andGenId:(NSString *)genId repeateIndex:(NSInteger)repeateIndex {
    
    NSString *sql;
    
    if (genId && genId.length > 0) {
        sql = [NSString stringWithFormat:@"select * from base_store_dict_dis bsds  where  bsds.store_id = '%@' and bsds.func_code = '%@' and bsds.dict_id = '%@' and bsds.assetId = '%@'",storeId,qst.mc ,dictBean.Id, genId];
    }else{
       
       // SFA-16488  改回来  史克医院那个是后台问题,让后台改  和门店挂钩的问卷  去掉gen_id 别下发
        sql = [NSString stringWithFormat:@"select * from base_store_dict_dis bsds  where  bsds.store_id = '%@' and bsds.func_code = '%@' and bsds.dict_id = '%@' and bsds.assetId is null",storeId,qst.mc ,dictBean.Id];
         /*Jira - SFA-14132 SFA史克医院--【iPad】--断货及库存情况上报没有回显数据 create by sunhongfu 2017-11-22*/
     //  sql = [NSString stringWithFormat:@"select * from base_store_dict_dis bsds  where  bsds.store_id = '%@' and bsds.func_code = '%@' and bsds.dict_id = '%@'",storeId,qst.mc ,dictBean.Id];

    }
    
    //    NSString *funcCode = [NSString stringWithFormat:@"%@@%@",dictBean.Id,qst.mc];
    
    
    
    
    NSArray *dicts = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreDictDisObject"];
    NSString *colName = ([param.redis length] > 0 && ![param.redis isEqualToString:@"1"] && ![param.redis isEqualToString:@"0"]) ? param.redis:param.col;
    if ([self hasVariableWithClass:[WSBaseStoreDictDisObject class] varName:colName]) {
        if (repeateIndex < [dicts count]) {
           return [dicts[repeateIndex] valueForKey:colName];
        }
        return [[ dicts firstObject] valueForKey:colName];
    }else {
        NSLog(@"WSBaseStoreDictDisObject no has %@  property",colName);
    }
    return nil;
    
}

- (NSString *)queryAcvtDictsGridRedisWithStoreId:(NSString *)storeId qst:(WSAcvtBean_qst *)qst param:(WSFuncsBean_Param *)param dict:(WSDictBean *)dictBean {
    
//    NSString *funcCode = [NSString stringWithFormat:@"%@@%@",dictBean.Id,qst.mc];

    NSString *sql = [NSString stringWithFormat:@"select * from base_store_dict_dis bsds  where  bsds.store_id = '%@' and bsds.func_code = '%@' and bsds.dict_id = '%@'",storeId,qst.mc ,dictBean.Id];
    
    NSArray *dicts = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreDictDisObject"];
    NSString *colName = ([param.redis length] > 0 && ![param.redis isEqualToString:@"1"] && ![param.redis isEqualToString:@"0"]) ? param.redis:param.col;
    if ([self hasVariableWithClass:[WSBaseStoreDictDisObject class] varName:colName]) {
        return [(WSBaseStoreDictDisObject*)[ dicts firstObject] valueForKey:colName];
    }else {
        NSLog(@"WSBaseStoreDictDisObject no has %@  property",colName);
    }
    return nil;
    
}

- (WSDictBean *)queryDictWithID:(NSString *)dictID {
    
    NSString *sql = [NSString stringWithFormat:@"%@ bdts._id = '%@'",kDictQueryString, dictID];
    
    return [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];

}

- (WSDictBean *)queryDictWithTyp:(NSString *)dictTyp
{
    return [self queryDictWithTyp:dictTyp andCod:nil];
}

- (WSDictBean *)queryDictWithTyp:(NSString *)dictTyp andCod:(NSString *)cod
{
    NSString *sqlStr = @"";
    if (cod.length)
    {
        sqlStr = [NSString stringWithFormat:@" and bdts.cod = '%@' ",cod];
    }
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.typ='%@') %@ ",kDictWithGeographyString,dictTyp,sqlStr];
    return [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];
}

- (WSDictBean *)queryDictWithName:(NSString *)dictName
{
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.name = '%@'",kDictWithName, dictName];
    
    return [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];
}

- (NSArray *)queryDictsWithIDs:(NSArray *)dictIDArray {
    
    if (!dictIDArray || dictIDArray.count == 0) {
        return nil;
    }
    
    NSString *inString = @"in (";
    for (NSInteger i = 0; i < [dictIDArray count]; i++) {
        if (i == 0) {
            inString = [inString stringByAppendingFormat:@"'%@'",dictIDArray[i]];
        }else {
            inString = [inString stringByAppendingFormat:@",'%@'",dictIDArray[i]];
        }
    }
    inString = [inString stringByAppendingFormat:@")"];
    
    //MN-2122 2018-04-24
    NSString *sql = [NSString stringWithFormat:@"%@ bdts._id %@ order by ifnull(dicts_sequence, %ld)", kDictQueryString,inString, NSIntegerMax];
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
}

- (NSArray *)queryDictsWithIDsString:(NSString *)dictIDsString {
    
    if (!dictIDsString || dictIDsString.length == 0) {
        return nil;
    }
    
    NSString *inString = @"in (";
    
    inString = [NSString stringWithFormat:@"%@%@", inString, dictIDsString];
    
    inString = [inString stringByAppendingFormat:@")"];
    
    //MN-2122 2018-04-24
    NSString *sql = [NSString stringWithFormat:@"%@ bdts._id %@ order by ifnull(dicts_sequence, %ld)", kDictQueryString,inString, NSIntegerMax];
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
}

- (WSDictBean *)queryDictWithCod:(NSString *)dictCod {
    
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.cod = '%@'", kDictQueryString,dictCod];
    
    return [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];
    
}


- (NSArray *)queryDictWithType:(NSString *)dictType {
    
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.typ = '%@'", kDictQueryString,dictType];
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
    
}

- (NSString *)queryBrandIdByFilter:(NSString *)aFilter searchQuestion:(NSString *)searchQuestion {
    
    if (!aFilter || !searchQuestion) {
        return nil;
    }
    
    NSString *sql = kDictQueryString;
    
    if ([searchQuestion isEqualToString:@"brand"]) {
        
        sql = [NSString stringWithFormat:@"%@ bdts._id = '%@'", sql,aFilter];
        
    }else if ([searchQuestion isEqualToString:@"brandcode"]) {
        
        sql = [NSString stringWithFormat:@"%@ bdts.cod = '%@'", sql,aFilter];
        
    }
    
    WSDictBean *dictBean = [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];
    
    if (dictBean) {
        return dictBean.Id;
    }
    
    return nil;
}


- (NSArray *)queryProdsBrandByFilter:(NSString*)filter {
    //根节点
    NSMutableArray* rootArray = [[NSMutableArray alloc]init];
    NSMutableArray* brandArray = [[NSMutableArray alloc]init ];
    NSArray* dictsArray = [NSArray arrayWithArray:[self queryDictsForAcvtGridWithFilter:filter]];
    
    
    for(WSDictBean* db in dictsArray) {
        if(nil == db.p || [db.p isKindOfClass:[NSNull class]]) {
            [rootArray addObject:db];
        }
    }
    
    for(WSDictBean* db in rootArray)  {
        WSDictBrand* dict_brand = [[WSDictBrand alloc] initWithDict:db DictArray:dictsArray];
        [brandArray addObject:dict_brand];
    } 
    return brandArray;
}


- (WSDictBean *)queryDictWithParentId:(NSString *)pId{
    
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.pid = '%@'", kDictQueryString, pId];
    
    return [[[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] firstObject];
    
}

- (NSArray *)queryDictsWithParentId:(NSString *)pId{
    
    NSString *sqlSub = [NSString stringWithFormat:@"%@ bdts.pid = '%@'", kDictQueryString, pId];
    NSArray *subArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sqlSub andClassName:@"WSDictBean"];
    
    if (subArray.count < 1) {
        // SFA-4742 levelCode 为 1 时 查询 id
        NSString *sql = [NSString stringWithFormat:@"%@ bdts._id = '%@'", kDictQueryString, pId];
        NSArray *array = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
        
        return array;
    }
    return subArray;
}

- (NSArray *)queryDictsWithParentId:(NSString *)pId andDrid:(NSString *)drid
{
    NSString *sqlSub = [NSString stringWithFormat:@"%@ bdts.pid = '%@' and base_in_store_prod.store_id = '%@' group by bdts._id order by bdts.dicts_sequence", kDictWithDistributeQueryString, pId, drid];
    NSArray *subArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sqlSub andClassName:@"WSDictBean"];
    
    if (subArray.count < 1) {
        // SFA-4742 levelCode 为 1 时 查询 id
        NSString *sql = [NSString stringWithFormat:@"%@ bdts._id = '%@' and base_in_store_prod.store_id = '%@' group by bdts._id order by bdts.dicts_sequence", kDictWithDistributeQueryString, pId, drid];
        NSArray *array = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
        
        return array;
    }
    return subArray;
}

- (NSArray *)queryDictsWithParentId:(NSString *)pId filter:(NSString *)filter
{
    return [self queryDictsWithParentId:pId filter:filter memo:@""];
}

- (NSArray *)queryDictsWithParentId:(NSString *)pId filter:(NSString *)filter memo:(NSString*)memo
{
    if (filter == nil || [filter length] == 0) {
        NSLog(@"filter is nil or [fliter length] == 0 ");
        return nil;
    }
    NSString *sqlJoin = @"";
    NSString *sqlStoreId = @"1=1";
    if([memo isEqualToString:@"1"])
    {
        WSBaseModel *model = [WSDataSourceManager sharedInstance].currentActiveModel;
        sqlJoin =@"join base_store_dicts on bdts._id = base_store_dicts.dictId";
        sqlStoreId = [NSString stringWithFormat:@"base_store_dicts.sid = %@",model.currentStore.Id];
    }
    
    NSString *sql = [NSString stringWithFormat:@"%@ %@ where %@",kDictMomeQueryString,sqlJoin,sqlStoreId];
    if ([filter rangeOfString:@"@"].location != NSNotFound) {
        NSArray *array = [filter componentsSeparatedByString:@"@"];
        if ([array count] == 2) {
            NSString *typ = [array firstObject];
            NSString *btyp = array[1];
            sql = [NSString stringWithFormat:@"%@ and bdts.typ = '%@' and bdts.btyp = '%@'", sql,typ,btyp];
        }
        
    }else {
        NSArray *pArray = [filter componentsSeparatedByString:@","];
        NSString *inString = @"in (";
        for (NSInteger i = 0; i < [pArray count]; i++) {
            if (i == 0) {
                inString = [inString stringByAppendingFormat:@"'%@'",pArray[i]];
            }else {
                inString = [inString stringByAppendingFormat:@",'%@'",pArray[i]];
            }
        }
        inString = [inString stringByAppendingFormat:@")"];
        
        sql = [NSString stringWithFormat:@"%@ and bdts.typ %@", sql,inString];
    }
    
    if ([pId length] > 0) {
        NSArray *pidArray = [pId componentsSeparatedByString:@","];
        if ([pidArray count] > 1) {
            NSString *inString = @"in (";
            for (NSInteger i = 0; i < [pidArray count]; i++) {
                if (i == 0) {
                    inString = [inString stringByAppendingFormat:@"'%@'",pidArray[i]];
                }else {
                    inString = [inString stringByAppendingFormat:@",'%@'",pidArray[i]];
                }
            }
            inString = [inString stringByAppendingFormat:@")"];
            
            sql = [NSString stringWithFormat:@"%@ and pid %@", sql,inString];
        }else {
            sql = [NSString stringWithFormat:@"%@ and pid = '%@'", sql, pId];
        }
    }else {
        sql = [NSString stringWithFormat:@"%@ and pid is null", sql];
    }
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
}


// SFA 项目SFA-21402 SFA-立白-IOS-订单模板调用时按时间降序排
- (void)updateDictWithId:(NSString *)dictId andSequence:(NSString *)seStr{
    
    NSString *sql = [NSString stringWithFormat:@"update base_dicts set dicts_sequence =  '%@' where _id = '%@'" ,seStr,dictId];
    NSArray *sqlArray = [NSArray arrayWithObject:sql];
    
    [[WSBaseDictsTable sharedTable] executeUpdateWithSqls:sqlArray] ;
    
}

- (NSArray *)queryDictWithPid:(NSString *)dictPid{
    
    NSString *sql = [NSString stringWithFormat:@"%@ bdts.pid = '%@' order by bdts.dicts_sequence",kDictQueryString, dictPid];
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"] ;

}

-(NSArray *)queryRichMediaDict{
    
    NSString * sql  = @"select * from base_dicts where name = cod and levelCode = '1' and typ = 'fumeiti_label' ORDER BY SEQ";
    
    return [[WSBaseDictsTable  sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
}

-(NSArray *)queryCityListByFilter:(NSString *)filter  levelCode:(NSString *)levelCode{
    
    NSString * sql = [NSString stringWithFormat:@"%@ bdts.typ = '%@' and levelCode = '%@'", kDictQueryString,filter,levelCode];

    NSArray *oArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];

    NSArray *resultArray = [[NSArray alloc] init];
    resultArray = [self useSEQSortArrayWithOriginArray:oArray];

    return resultArray;

}
- (NSArray*)queryCityDownLoadList
{
    NSString * sql = [NSString stringWithFormat:@"select dicts.* from base_dicts dicts  inner  join base_store_other_data other on other.item1 = dicts._id and  other.type = '%@'",EMP_AREA];
    
    NSArray *oArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
    
    NSArray *resultArray = [[NSArray alloc] init];
    resultArray = [self useSEQSortArrayWithOriginArray:oArray];
    
    return resultArray;
}
//
- (NSArray*)queryBranchDownLoadList
{
    NSString * sql = [NSString stringWithFormat:@"select distinct dicts._id Id,dicts.pid pid,dicts.name name,dicts.typ typ,dicts.dtyp dtyp,dicts.btyp btyp,dicts.col1 col1,dicts.col2 col2,dicts.cod cod,dicts.dicts_sequence dicts_sequence,dicts.levelcode levelcode,dicts.regex regex,dicts.server_node server_node,dicts.SEQ SEQ,dicts.fl fl,dicts.iconUrl iconUrl from base_dicts dicts  inner  join base_store_other_data other on other.item1 = dicts._id and  other.type = '%@'",EMP_ORG];
    NSArray *oArray = [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
    
    NSArray *resultArray = [[NSArray alloc] init];
    resultArray = [self useSEQSortArrayWithOriginArray:oArray];
    
    return resultArray;
}

- (NSArray *)resetDictsSeq:(NSArray *)dicts {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:dicts.count];
    
    NSInteger i = 0;
    for (NSDictionary *dic in dicts) {
        NSMutableDictionary *newDic = [dic mutableCopy];
        if (![dic objectForKey:kServerSeq] && ![dic objectForKey:kServerSeqLowerCase]) {
            newDic[kServerSeq] = [NSString stringWithFormat:@"%ld", i];
            i++;
        }
        [newArray addObject:newDic];
    }
    
    return [newArray copy];
}
#pragma mark - # 查询对店关系字典项
- (NSArray *)queryStoreDictsWithStoreId:(NSString*)storeId filter:(NSString *)filter{
    
    if (filter == nil || [filter length] == 0) {
        LogError(@"filter is nil or [fliter length] == 0 ");
        return nil;
    }
    if (storeId == nil || [storeId length] == 0) {
        LogError(@"storeId is nil or [storeId length] == 0 ");
        return nil;
    }
    
    NSString * sqlJoin = @" join base_store_dicts bsd on bsd.dictId = bdts._id ";
    
    NSString * condition = [NSString stringWithFormat:@"1 = 1 and bsd.sid = '%@' ",storeId];

    NSString *sql = [NSString stringWithFormat:@"%@ %@ where %@",kStoreDictQueryString,sqlJoin,condition];
    
    if ([filter rangeOfString:@"@"].location != NSNotFound) {
        NSArray *array = [filter componentsSeparatedByString:@"@"];
        if ([array count] == 2) {
            NSString *typ = [array firstObject];
            NSString *btyp = array[1];
            sql = [NSString stringWithFormat:@"%@ and bdts.typ = '%@' and bdts.btyp = '%@'", sql,typ,btyp];
        }
        
    }else {
        NSArray *pArray = [filter componentsSeparatedByString:@","];
        NSString *inString = @"in (";
        for (NSInteger i = 0; i < [pArray count]; i++) {
            if (i == 0) {
                inString = [inString stringByAppendingFormat:@"'%@'",pArray[i]];
            }else {
                inString = [inString stringByAppendingFormat:@",'%@'",pArray[i]];
            }
        }
        inString = [inString stringByAppendingFormat:@")"];
        
        sql = [NSString stringWithFormat:@"%@ and bdts.typ %@", sql,inString];
    }
    
    
    return [[WSBaseDictsTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSDictBean"];
}

@end
