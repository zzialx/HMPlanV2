//
//  WSBaseProductDBService.m
//  WinSFA
//
//  Created by weida on 15/12/25.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseProductDBService.h"
#import "WSBaseProductTable.h"
#import "NSArray+SQL.h"
#import "WSBaseStoreDistruleDBService.h"
#import "WSBaseStoreTable.h"

#define kKey_id              (@"_id")
#define kKey_serverCode      (@"serverCode")//本地表保存数据来源的字段
#define kKey_seq             (@"seq")


#define SELECT_PRODS_FROM_BASEPRODTABLE @"select distinct prod._id Id,prod.name,prod.cod,prod.searchcod,prod.pTyp,prod.brand,prod.barcode barcod,prod.url,prod.seq,prod.addproduct_json_data,prod.blockPrice,prod.regex,prod.pack,prod.size,prod.series,prod.serverCode,prod.memo1,prod.memo2,prod.memo3,prod.memo4,pinyin,expirydate,bigage,memo,prodtrees,barcode2 "


#define SELECT_PRODS_FROM_BASEPRODTABLE_NEW @"select distinct prod._id Id,prod.name,prod.cod,prod.searchcod,prod.pTyp,prod.brand,prod.barcode barcod,prod.price price,prod.url,prod.seq,prod.addproduct_json_data,prod.blockPrice,prod.regex,prod.pack,prod.size,prod.series,prod.serverCode,prod.memo1,prod.memo2,prod.memo3,prod.memo4,pinyin,expirydate,bigage,memo,prodtrees,barcode2 "

#define PRODS_REPLACE_NAME   @"ifnull(prod.name||char(13)||char(10)||prod.%@, prod.name) as name"

typedef enum {
    WSQueryProdByNormalType,
    WSQueryProdByBrandType /*brandId = product.seire*/
} WSProductQueryType;


@implementation WSBaseProductDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    
    WSBaseProductTable *table = [WSBaseProductTable sharedTable];//得到Base_Product表
    
    ret = [table batchDeleteFromTableWithNames:@[kKey_serverCode] ArgumentsValues:@[@[nodeName]]];//批量删除以前的数据
    
    if (ret)
    {
        // MSTD-7490
        dicts = [self addPinyinFromNameToDicts:dicts];
        
        ret = [table batchInsertToTableWithMap:@{kKey_id:@{kMapKey_serverKey:@"id"},
                                                 kKey_serverCode:@{kMapKey_placeHolder:nodeName},
                                                 kKey_seq:@{kMapKey_autoIncrement:@1}} Dicts:dicts];
    }
    return ret;
}
- (NSArray *)baseQueryProductsWithStoreId:(NSString *)storeId brand:(NSString *)brand pType:(NSString *)pType paramsCondition:(NSString *)paramsCondition  queryType:(WSProductQueryType)queryType appendprop:(NSString *)appendprop {
    return [self baseQueryProductsWithStoreId:storeId brand:brand pType:pType paramsCondition:paramsCondition queryType:queryType appendprop:appendprop filterProdIdArray:nil];
}

- (NSArray *)baseQueryProductsWithStoreId:(NSString *)storeId brand:(NSString *)brand pType:(NSString *)pType paramsCondition:(NSString *)paramsCondition queryType:(WSProductQueryType)queryType appendprop:(NSString *)appendprop filterProdIdArray:(NSArray *)filterProdIdArray {
    
    NSString *storeIdStr = @"";
    NSString *brandStr = @"";
    NSString *pTypCondition = @"";
    NSString *filterProdCondition = @"";
    
    if ([storeId length] > 0 ) {
        
        NSArray *storeIdArray = [storeId componentsSeparatedByString:@","];
        if ([storeIdArray count] > 1) {
            storeIdStr = [NSString stringWithFormat:@" and isp.store_id %@", [storeIdArray getInSqlString]];
        }else {
            storeIdStr = [NSString stringWithFormat:@" and isp.store_id = '%@'",storeId];
        }
    }
    
    if ([brand length] > 0) {
        if (queryType == WSQueryProdByNormalType) {
            brandStr = [NSString stringWithFormat:@"and prod.brand = '%@'",brand];
        }else if (queryType == WSQueryProdByBrandType) {
            brandStr = [NSString stringWithFormat:@"and prod.series in (select _id from base_dicts where _id = '%@')",brand];
        }
    }
    
    if ([pType length] > 0) {
        NSArray *pTypes = [pType componentsSeparatedByString:@","];
        pTypCondition = [pTypCondition stringByAppendingFormat:@"and prod.pTyp %@", [pTypes getInSqlString]];
    }
    
    if (filterProdIdArray) {
        filterProdCondition = [filterProdCondition stringByAppendingFormat:@"and prod._id not %@", [filterProdIdArray getInSqlString]];
    }
    
    NSArray *keyArrays = @[@"$storeId$",@"$prodBrand$",@"$pTypeCondition$",@"$paramsCondition$", @"$filterProdCondition$"];
    
    
    // storeId brand pType 都为空 且 paramCondition 有值，去掉 paramCondition 第一个 and，避免 sql 语法错误
//    if (paramsCondition.length > 4 &&
//        (!storeIdStr || [storeIdStr length] == 0) &&
//        (!brandStr || [brandStr length] == 0) &&
//        (!pTypCondition || [pTypCondition length] == 0)) {
//        paramsCondition = [paramsCondition substringFromIndex:4];
//    }
    
    NSArray *valuesArrays = @[storeIdStr,brandStr,pTypCondition,[NSString stringNotNilWithValue:paramsCondition],filterProdCondition];

    return [self queryProdBeanWithplistKey:@"queryStoreProdSql" keyArray:keyArrays valueArray:valuesArrays appendprop:appendprop];
}


- (NSArray *)queryProductsWithStoreId:(NSString *)storeId brand:(NSString *)brand pType:(NSString *)pType params:(NSArray *)params appendprop:(NSString *)appendprop {
    if ([params count] == 0) {
        LogInfo(@"[params count] == 0");
        return nil;
    }
   
    NSString *paramCondition = @"";
    for (NSInteger j = 0; j < [params count]; j++) {
        WSFuncsBean_Param *param = params[j];
        if (![param.col isEqualToString:@"otherdicts"]) {
            paramCondition = [paramCondition stringByAppendingFormat:@" and %@ = '1'",param.col];
        }
        
    }
    return [self baseQueryProductsWithStoreId:storeId brand:brand pType:pType paramsCondition:paramCondition queryType:WSQueryProdByNormalType appendprop:appendprop];
}
- (NSArray *)queryServerRedisProductsWithStoreId:(NSString *)storeId
                                brand:(NSString *)brand
                                pType:(NSString *)pType
                               params:(NSArray *)params
                                      appendprop:(NSString *)appendprop fc:(NSString*)fc md5:(NSString*)md5 store_id:(NSString*)store_id{
    
//    NSString *sql = [NSString stringWithFormat:@"%@ from base_product prod  join base_in_store_prod isp on prod._id= isp.prod_id join   base_store_prod_dis pd  on  prod._id = pd.prod_id where isp.dist=1  and isp.store_id in ('%@') and pd.store_id = '%@' and pd.prod_id in (select prod_id from base_in_store_prod where dist='%@' and  store_id in ('%@'))  and (pd.[funccode] is null or pd.[funccode]='%@')    and prod.pTyp in('%@')  and pd.genid ='%@'   order by  pd._id ", SELECT_PRODS_FROM_BASEPRODTABLE_NEW,storeId,store_id,@"1",storeId,fc,pType,md5];
    //不再关联分销规则表
    NSString *sql = [NSString stringWithFormat:@"%@ from base_product prod  join   base_store_prod_dis pd  on  prod._id = pd.prod_id where  pd.store_id = '%@' and  (pd.[funccode] is null or pd.[funccode]='%@')    and prod.pTyp in('%@')  and pd.genid ='%@'   order by  pd._id ", SELECT_PRODS_FROM_BASEPRODTABLE_NEW,store_id,fc,pType,md5];
    
    LogInfo(@"表格按照回显逻辑查询产品sql：%@",sql);
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];

}


- (NSArray *)queryBrandSortProductsWithStoreId:(NSString *)storeId brand:(NSString *)brandId params:(NSArray *)params appendprop:(NSString *)appendprop {
//    if ([params count] == 0) {
//        LogInfo(@"[params count] == 0");
//        return nil;
//    }
    NSString *paramCondition = @"";
    for (NSInteger j = 0; j < [params count]; j++) {
        WSFuncsBean_Param *param = params[j];
        if (![param.col isEqualToString:@"otherdicts"]) {
            paramCondition = [paramCondition stringByAppendingFormat:@" and %@ = '1'",param.col];
        }
        
    }
    return [self baseQueryProductsWithStoreId:storeId brand:brandId pType:nil paramsCondition:paramCondition queryType:WSQueryProdByBrandType appendprop:appendprop];
}



- (NSArray *)queryRedisBrandSortProductWithFuncCode:(NSString *)funcCode
                                            StoreId:(NSString *)storeId
                                               drId:(NSString *)drId
                                              genId:(NSString *)genId
                                              brand:(NSString *)brand
                                             params:(NSArray *)params
                             isUseDistributionRules:(BOOL)isUseDistributionRules
                                         appendprop:(NSString *)appendprop
{
    if ([params count] == 0) {
        LogInfo(@"[params count] == 0");
    }
    NSString *baseInstoreProdCondition = @"";
    
    if (isUseDistributionRules) {
        for (NSInteger j = 0; j < [params count]; j++) {
            WSFuncsBean_Param *param = params[j];
            if (![param.col isEqualToString:@"otherdicts"]) {
                if (param.redis.length > 0 && [param.redis isEqualToString:@"1"]) {
                    baseInstoreProdCondition = [baseInstoreProdCondition stringByAppendingFormat:@" and bisd.%@ = '1'",param.col];
                }
            }
            
        }
        
        if ([drId length] > 0) {
            
            NSArray *drIdArray = [drId componentsSeparatedByString:@","];
            if ([drIdArray count] > 1) {
                baseInstoreProdCondition = [baseInstoreProdCondition stringByAppendingFormat:@" and bisd.store_id %@", [drIdArray getInSqlString]];
            }else {
                /*base_in_store_prod表中存入的是drId*/
                baseInstoreProdCondition = [baseInstoreProdCondition stringByAppendingFormat:@" and bisd.store_id = '%@'",drId];
            }
        }
    }
    
    
    NSString *funcCodeStr = @"";
    NSString *storeIdStr = @"";
    NSString *genIdStr = @"";
    NSString *brandStr = @"";
    
    if ([funcCode length] > 0) {
        funcCodeStr = [NSString stringWithFormat:@"bspd.funccode = '%@'",funcCode];
    }
    
    if ([storeId length] > 0) { 
        if ([funcCodeStr length] > 0) {
            storeIdStr = [NSString stringWithFormat:@" and bspd.store_id = '%@'",storeId];
        }else {
            storeIdStr = [NSString stringWithFormat:@" bspd.store_id = '%@'",storeId];
        }
    }
    
    if ([genId length] > 0) {
        genIdStr = [NSString stringWithFormat:@" and bspd.genid = '%@'",genId];
    }
    
    if ([brand length] > 0) {
        NSArray *allBrands = [brand componentsSeparatedByString:@","];
        if ([allBrands count] > 0) {
            brandStr = [NSString stringWithFormat:@"and prod.series in (select _id from base_dicts where _id %@)", [allBrands getInSqlString]];
        }
    }
    
    NSString *paramCondition = @"";
    if ([params count] > 0) {
        for (NSInteger j = 0; j < [params count]; j++) {
            WSFuncsBean_Param *param = params[j];
            // MN-712 过滤掉隐藏的列
            if (![param.gone isEqualToString:@"0"] && param.gone.length > 0) {
                continue;
            }
            if ([paramCondition length] == 0) {
                paramCondition = [paramCondition stringByAppendingFormat:@" and (bspd.%@ != ''",param.col];
            }else {
                paramCondition = [paramCondition stringByAppendingFormat:@" or bspd.%@ != ''",param.col];
            }
            
        }
        if ([paramCondition length] > 0) {
             paramCondition= [paramCondition stringByAppendingString:@" )"];
        }
    }
    NSArray *keyArrays = @[@"$baseInstoreProdCondition$",@"$funcCode$",@"$storeId$",@"$genId$",@"$prodBrand$",@"$paramsCondition$"];
    
    NSArray *valuesArrays = @[baseInstoreProdCondition,funcCodeStr,storeIdStr,[NSString stringNotNilWithValue:genIdStr],brandStr,[NSString stringNotNilWithValue:paramCondition]];

    return [self queryProdBeanWithplistKey:@"queryStoreRedisBrandSortProductSql" keyArray:keyArrays valueArray:valuesArrays appendprop:appendprop];
}
- (NSArray *)queryProdBeanWithplistKey:(NSString *)key keyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray  appendprop:(NSString *)appendprop {
    // SFA-13944
    NSString *replaceTarget;
    NSString *replacement;
    if ([appendprop length] > 0) {
        replaceTarget = @"prod.name";
        replacement = [NSString stringWithFormat:PRODS_REPLACE_NAME, appendprop];
    }
    
    return [self queryObjectsWith:[WSProdBean class] plistKey:key keyArray:keyArray valueArray:valueArray replacingOccurrencesOfString:replaceTarget withString:replacement];
}

//查询表格的更多产品

- (NSArray *)queryMoreProductsWithStoreId:(NSString *)storeId brand:(NSString *)brand pType:(NSString *)pType params:(NSArray *)params appendprop:(NSString *)appendprop {
   
    NSString *paramCondition = @"";

    return [self baseQueryProductsWithStoreId:storeId brand:brand pType:pType paramsCondition:paramCondition queryType:WSQueryProdByNormalType appendprop:appendprop];
}

- (NSArray *)queryMoreProductsWithStoreId:(NSString *)storeId brand:(NSString *)brand pType:(NSString *)pType params:(NSArray *)params appendprop:(NSString *)appendprop filterProdIdArray:(NSArray *)filterProdIdArray {
    
    return [self baseQueryProductsWithStoreId:storeId brand:brand pType:pType paramsCondition:@"" queryType:WSQueryProdByNormalType appendprop:appendprop filterProdIdArray:filterProdIdArray];
}


/*待验证（对人的调查问卷 嵌表格产品查询）*/
- (NSArray *)queryProductsForPeopleWithStoreId:(NSString *)storeId filter:(NSString *)filter {
    if (filter == nil) {
        NSLog(@"error filter is nil");
        return nil;
    }
    NSString *sql;
    if (filter && ![filter isEqualToString:@""]) {
        sql = [NSString stringWithFormat:@"select distinct prod._id Id,prod.name,prod.cod,prod.searchcod,prod.pTyp,prod.brand,prod.barcode barcod,prod.url,prod.seq,prod.addproduct_json_data,prod.blockPrice,prod.regex,prod.pack,prod.size,prod.series,prod.serverCode,prod.barcode2  from base_product  prod join base_in_store_prod bisp on (prod._id = bisp.prod_id and prod.pTyp = '%@') where bisp.store_id = '%@'" ,filter,storeId];
    } else {
        sql = [NSString stringWithFormat:@"select distinct prod._id Id,prod.name,prod.cod,prod.searchcod,prod.pTyp,prod.brand,prod.barcode barcod,prod.url,prod.seq,prod.addproduct_json_data,prod.blockPrice,prod.regex,prod.pack,prod.size,prod.series,prod.serverCode,prod.barcode2  from base_product  prod join base_in_store_prod bisp on (prod._id = bisp.prod_id) where bisp.store_id = '%@'" ,storeId];
    }
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
}

- (NSArray *)queryProductsWithFilter:(NSString *)filter
{
    if (filter == nil) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select distinct prod._id Id,prod.name,prod.cod,prod.searchcod,prod.pTyp,prod.brand,prod.barcode barcod,prod.price,prod.url,prod.seq,prod.addproduct_json_data,prod.blockPrice,prod.regex,prod.pack,prod.size,prod.series,prod.serverCode,prod.barcode2  from base_product  prod where prod.pTyp = '%@'",filter];
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
}

- (NSArray *)queryProductsWithCondition:(NSString *)condition
{
    if (condition == nil) {
        return nil;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ from base_product prod where ", SELECT_PRODS_FROM_BASEPRODTABLE];
    
    NSArray *filterArray = [condition componentsSeparatedByString:@"@"];
    
    if ([filterArray count] == 1) {
        [sql appendFormat:@"prod.pTyp = '%@' ",[filterArray firstObject]];
    }else if ([filterArray count] > 1) {
        NSString *pTyp = filterArray[0];
        NSString *brand = filterArray[1];
        
        if ([pTyp length] > 0) {
            [sql appendFormat:@"prod.pTyp = '%@' ",pTyp];
        }
        
        if ([brand length] > 0) {
            if ([pTyp length] > 0) {
                [sql appendString:@" and "];
            }
            [sql appendFormat:@"prod.brand = '%@' ",brand];
        }
    }
    
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
}

- (NSArray *)queryAllProducts
{
    NSString *sql = [NSString stringWithFormat:@"%@ from base_product prod ", SELECT_PRODS_FROM_BASEPRODTABLE];
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
}

- (WSProdBean *)queryProductByID:(NSString *)prodID
{
    if (prodID == nil) {
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"%@ from base_product prod where prod._id = '%@'",SELECT_PRODS_FROM_BASEPRODTABLE, prodID];
    return [[[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"] firstObject];
}



- (NSArray *)queryProductByIds:(NSArray *)prodIds appendprop:(NSString *)appendprop //SFA-14624 2017-11-28
{
    if ([prodIds count] == 0)
        return nil;
    
    NSString *sql;
    
    NSArray *distinctProdIds = [prodIds valueForKeyPath:@"@distinctUnionOfObjects.self"];
    // YIHAIKERRY-3512 有重复产品需要拼重复产品
    if ([distinctProdIds count] == [prodIds count]) {
        sql = [NSString stringWithFormat:@"%@ from base_product prod where prod._id %@ ", SELECT_PRODS_FROM_BASEPRODTABLE, [prodIds getInSqlString]];
        sql = [self getNewSql:sql byAppendprop:appendprop];
    } else {
        sql = [NSString stringWithFormat:@"%@ from base_product prod where prod._id %@ ", SELECT_PRODS_FROM_BASEPRODTABLE, [distinctProdIds getInSqlString]];
        sql = [self getNewSql:sql byAppendprop:appendprop];
        NSMutableDictionary *prodIdDictionary = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < [prodIds count]; i++) {
            NSString *prodId = prodIds[i];
            NSString *count = [prodIdDictionary objectForKey:prodId];
            if (!count) {
                // 没有出现过重复产品则设置 count 为 1
                [prodIdDictionary setObject:@1 forKey:prodId];
            } else {
                NSString *prodSql = [NSString stringWithFormat:@"%@ from base_product prod where prod._id = '%@'", SELECT_PRODS_FROM_BASEPRODTABLE, prodId];
                prodSql = [self getNewSql:prodSql byAppendprop:appendprop];
    
                sql = [sql stringByAppendingFormat:@"union all %@", prodSql];
            }
        }
    }
    
    if ([sql length] > 0) {
        sql = [sql stringByAppendingString:@" order by prod._id"];
    }
    
    NSArray *prodArray = [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
    /* 添加 order by prod._id 替换内存排序
    prodArray = [prodArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        WSProdBean *prod1 = (WSProdBean *)obj1;
        WSProdBean *prod2 = (WSProdBean *)obj2;
        NSNumber *number1 = [NSNumber numberWithUnsignedInteger:[prodIds indexOfObject:prod1.Id]];
        NSNumber *number2 = [NSNumber numberWithUnsignedInteger:[prodIds indexOfObject:prod2.Id]];
        
        return [number1 compare:number2];
    }];
    */
        
    return prodArray;
}

- (NSArray *)queryProductByIds:(NSArray *)prodIds andIsOrderByImgtype:(BOOL)isOrderByImgtype {
    if ([prodIds count] == 0) {
        return nil;
    }
    
    NSString *sql = @"";
    
    if (isOrderByImgtype){
        sql = [NSString stringWithFormat:@"%@ from base_product prod join base_in_store_prod on base_in_store_prod.prod_id = prod._id where prod._id %@ order by base_in_store_prod.imgtype, prod._id, prod.seq", SELECT_PRODS_FROM_BASEPRODTABLE, [prodIds getInSqlString]];
    }else{
        sql = [NSString stringWithFormat:@"%@ from base_product prod where prod._id %@ order by prod._id, prod.seq", SELECT_PRODS_FROM_BASEPRODTABLE, [prodIds getInSqlString]];
    }
    
    NSArray *prodArray = [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
    
    return prodArray;
    
}

//产品中是否包含barcode ，用于判断扫描按钮的显示
- (BOOL)queryHasBarcodeProductList{
    
    NSString *sql = [NSString stringWithFormat:@"%@ from base_product prod where barcode is not null limit 1 ", SELECT_PRODS_FROM_BASEPRODTABLE];
    
    NSArray *productsList =  [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
    if (productsList && productsList.count > 0) {
        return YES;
    }
    return NO;
}

- (NSArray *)queryHasBarcodeProductListByIsLimitOne:(BOOL)isLimitOne pType:(NSString *)pType sid:(NSString *)sid disRuleId:(NSString *)disRuleId appendprop:(NSString *)appendprop {
    //SFA-26213
    NSString *querySid = @"";
    if(sid.length > 0)
    {
        if([sid isEqualToString:@"-1"])
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in('%@')", sid];
        else
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in('%@')", disRuleId];
    }
    
    NSString *pTypCondition = @"";
    if ([pType length] > 0) {
        NSArray *pTypes = [pType componentsSeparatedByString:@","];
        pTypCondition = [NSString stringWithFormat:@" and prod.pTyp %@", [pTypes getInSqlString]];
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ from base_product prod join base_in_store_prod on base_in_store_prod.prod_id = prod._id where barcode is not null ", SELECT_PRODS_FROM_BASEPRODTABLE];
    
    [sql appendFormat:@"and (prod.expirydate is null or prod.expirydate != '0') %@ %@order by base_in_store_prod.imgtype, prod._id, prod.seq",
     querySid, pTypCondition];
    
    if (isLimitOne) {
         [sql appendString:@" limit 1"];
    }
    
    NSString *newSql = [self getNewSql:sql byAppendprop:appendprop];
    
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:newSql andClassName:@"WSProdBean"];
}
- (NSArray *)queryProductsWithBarcode:(NSString *)barcode pType:(NSString *)pType{
    if (barcode == nil) {
        return nil;
    }
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ from base_product prod where ", SELECT_PRODS_FROM_BASEPRODTABLE];
    
   [sql appendFormat:@"prod.barcode in ('%@') ",barcode];
    
    if ([pType length] > 0) {
        NSArray *pTypes = [pType componentsSeparatedByString:@","];
        NSString *pTypCondition = [NSString stringWithFormat:@" and prod.pTyp %@", [pTypes getInSqlString]];
        [sql appendString:pTypCondition];
    }
    
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSProdBean"];
}

//SFA-20430 2018-05-28 (增加参数 sid与moreProdType) 根据Prodtree查询产品方法
- (NSArray *)queryProductsWithProdtreeId:(NSString *)prodtreeId appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType
{
    if (prodtreeId == nil) return nil;
    
    //SFA-20430 2018-05-28 (修改逻辑 增加分销规则)
    NSString *querySid = @"";
    if(sid.length > 0)
    {
        if([sid isEqualToString:@"-1"])
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in('%@')", sid];
        else
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in(select drId from base_store_distrule where sid = '%@')", sid];
    }
    
    NSString *queryMoreProdType = @"";
    if(moreProdType.length > 0)
        queryMoreProdType = [NSString stringWithFormat:@"and base_in_store_prod.%@ = 1", moreProdType];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ from base_product prod join base_in_store_prod on base_in_store_prod.prod_id = prod._id where ", SELECT_PRODS_FROM_BASEPRODTABLE];
    [sql appendFormat:@"prod.prodtrees like '%%%@%%' and (prod.expirydate is null or prod.expirydate != '0') %@ %@ order by base_in_store_prod.imgtype, prod._id, prod.seq",
     prodtreeId, querySid, queryMoreProdType];

    NSString *newSql = [self getNewSql:sql byAppendprop:appendprop];
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:newSql andClassName:@"WSProdBean"];
}

//SFA-21064 2018-06-21 根据genid查询产品方法
- (NSArray *)queryProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType
{
    return  [self queryProductsWithGenid:genid appendprop:appendprop sid:sid moreProdType:moreProdType needStoreID:NO];
}


//SFA-21067 针对以上方法的扩充方法
- (NSArray *)queryProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType needStoreID:(BOOL)needStoreID
{
    if(genid.length <= 0) return nil;
    
    NSString *queryHead = [NSString stringWithFormat:@"%@, imgtype, bspd.item1, bspd.item2, bspd.item3, bspd.item4, bspd.item5, bspd.item6, bspd.item7, bspd.item8, bspd.item9, bspd.item10, bspd.item11, bspd.item12, bspd.item13, bspd.item14, bspd.item15, bspd.item16, bspd.item17, bspd.item18, bspd.item19, bspd.item20, bspd.item21, bspd.item22, bspd.item23, bspd.item24, bspd.item25, bspd.item26, bspd.item27, bspd.item28, bspd.item29, bspd.item30, bspd.item31, bspd.item32, bspd.item33, bspd.item34, bspd.item35, bspd.item36, bspd.item37, bspd.item38, bspd.item39, bspd.item40, bspd.item41, bspd.item42, bspd.item43, bspd.item44, bspd.item45, bspd.item46, bspd.item47, bspd.item48, bspd.item49, bspd.item50, bspd.dist, bspd.pri, bspd.inv, bspd.disp, bspd.sdisp, bspd.cmpt, bspd.oos, bspd.mtd, bspd.ord, bspd.gofa, bspd.aging, bspd.otherdicts, bspd.dt, bspd.dn from base_product prod ", SELECT_PRODS_FROM_BASEPRODTABLE];
    NSString *storeID = (needStoreID == YES) ? [NSString stringWithFormat:@"and bspd.store_id = '%@'", sid] : @"";
    NSString *queryProdGenid = [NSString stringWithFormat:@"join base_store_prod_dis bspd on bspd.prod_id = prod._id and bspd.genid in ('%@') %@", genid , storeID];
    NSString *queryProdId = @"join base_in_store_prod on base_in_store_prod.prod_id = prod._id";
    NSString *queryWhere = @"where (prod.expirydate is null or prod.expirydate != '0')";
    NSString *querySid = @"";
    
    
    NSString *ruleId = [NSString stringWithFormat:@"'%@'",sid];
    
    NSString *mySql = [NSString stringWithFormat:@"select dist_rule_id  from ws_base_store_table where  store_id = '%@'", sid];
    
    NSArray *data = [[WSBaseStoreTable sharedTable] queryDicDatasBySql:mySql argumentsValues:nil];
    
    NSArray *resultArray = nil;
    
    if ([data count] > 0) {
        resultArray = [data valueForKey:@"dist_rule_id"];
    }
    
    if (resultArray) {
        ruleId = [NSString stringWithFormat:@"'%@'",[resultArray firstObject]];
    }
    
    //    分销规则的查询 董宏  YIHAIKERRY-4602
    WSBaseStoreDistruleDBService *disruleService = [[WSBaseStoreDistruleDBService alloc] init];
    NSArray *drIdArray = [disruleService queryDrIdByStoreId:sid];
    if (drIdArray) {
        ruleId = [NSString stringWithFormat:@"select drId from base_store_distrule where sid = '%@'",sid];
    }
    if(sid.length > 0)
    {
        if([sid isEqualToString:@"-1"])
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in('%@')", sid];
        else
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in(%@)", ruleId];
    }
    NSString *queryMoreProdType = @"";
    if(moreProdType.length > 0)
        queryMoreProdType = [NSString stringWithFormat:@"and base_in_store_prod.%@ = 1", moreProdType];
    //    donghong YIHAIKERRY-4634
    NSString *queryEnd = @"order by bspd._id, base_in_store_prod.imgtype, prod._id, prod.seq";

    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                            queryHead, queryProdGenid, queryProdId, queryWhere, querySid, queryMoreProdType, queryEnd];
    NSString *newSql = [self getNewSql:sql byAppendprop:appendprop];
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:newSql andClassName:@"WSProdBean"];
}

//SFA-21315 2018-06-22 根据产品id数组查询产品方法
- (NSArray *)queryProductByIds:(NSArray *)prodIds appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType
{
    if(prodIds.count <= 0) return nil;
    
    NSString *queryHead = [NSString stringWithFormat:@"%@, imgtype from base_product prod ", SELECT_PRODS_FROM_BASEPRODTABLE];
    NSString *queryProdId = @"join base_in_store_prod on base_in_store_prod.prod_id = prod._id";
    NSString *queryWhere = @"where (prod.expirydate is null or prod.expirydate != '0')";
    NSString *queryIds = [NSString stringWithFormat:@"and prod._id %@ ", [prodIds getInSqlString]];
    NSString *querySid = @"";
    if(sid.length > 0)
    {
        if([sid isEqualToString:@"-1"])
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in('%@')", sid];
        else
            querySid = [NSString stringWithFormat:@"and base_in_store_prod.store_id in(select drId from base_store_distrule where sid = '%@')", sid];
    }
    NSString *queryMoreProdType = @"";
    if(moreProdType.length > 0)
        queryMoreProdType = [NSString stringWithFormat:@"and base_in_store_prod.%@ = 1", moreProdType];
    NSString *queryEnd = @"order by base_in_store_prod.imgtype, prod._id, prod.seq";
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                            queryHead, queryProdId, queryWhere, queryIds, querySid, queryMoreProdType, queryEnd];

    NSString *newSql = [self getNewSql:sql byAppendprop:appendprop];
    return [[WSBaseProductTable sharedTable] queryAndReturnInfosBySql:newSql andClassName:@"WSProdBean"];
}

// SFA-13944
- (NSString *)getNewSql:sql byAppendprop:(NSString *)appendprop {
    NSString *replaceTarget;
    NSString *replacement;
    if ([appendprop length] > 0) {
        replaceTarget = @"prod.name";
        replacement = [NSString stringWithFormat:PRODS_REPLACE_NAME, appendprop];
        NSString *newSql = [sql stringByReplacingOccurrencesOfString:replaceTarget withString:replacement];
        return newSql;
    } else {
        return sql;
    }
}
- (NSString *)queryStoreValueWithParamCol:(NSString *)col prodBean:(WSProdBean *)prodBean{

    if ([self hasVariableWithClass:[WSProdBean class] varName:col]) {
        return [NSString stringWithValue:[prodBean valueForKey:col]];
    } else if ([col isEqualToString:@"barcode"]) {
        //        SFA-20537
        //        SFA--立白-ios---经销商门店拜访-任意一家门店-预售订单--添加产品--打印订单后，69码没有显示
        return [NSString stringWithValue:[prodBean valueForKey:@"barcod"]];
    }

    return nil;
    
}
@end
