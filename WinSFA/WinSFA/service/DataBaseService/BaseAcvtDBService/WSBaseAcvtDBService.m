//
//  WSBaseAcvtDBService.m
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseAcvtDBService.h"
#import "WSBaseAcvtTable.h"
#import "WSBaseAcvtQstTable.h"
#import "WSBaseAcvtQstOptTable.h"

#import "WSBaseQstOptTable.h"
#import "NSArray+SQL.h"
#import "WSBaseFunsDBService.h"

#define kTableKey_id   (@"_id")
#define K_SERVER_NODE  (@"server_node")


static NSString * const kAcvtQstQueryString = @"select  defaultValue,mlen,dlen,mnum,qstDesc,qstId,acvtQstId,qstCod,qstName,acvtId,qsttype qstType,snum,ds,align,isAcvtName,isSupperLocalPhoto,maxPhoto,acvtNestedId,is_req,mc,func,filter,readonly,checkType,groupName,parent,parentQstId,alertTitle,color,bgColor,ishidden isHidden,Js script,orientation,hint,is_not_water_mark,memo,memo1,memo2,memo3,memo4,qstIconUrl,charNum,countrule,buttonname,tab,hideQstName,hideQstOptName,REG as reg,displayMode,hiddenBottomline,widthPercent,isCoverNewId,locationType, verticalGroupName,layout_gravity,titleReadColor,valueReadColor,valueColor,titleSize,valueSize,dependon from base_acvt_qst";
//YIHAIKERRY-1280 董宏 修改
static NSString * const kAcvtQuerySqlString = @"select distinct  ba._id acvtId, acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript, ba.originalAcvtId iOriginalAcvtId,cast(s as int) seq";



@implementation WSBaseAcvtDBService

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    return [self replaceToTableWithDicts:dicts FromNode:nodeName hasNewData:hasNewData storeID:nil];
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    
    WSBaseAcvtTable *table = [WSBaseAcvtTable sharedTable];
    WSBaseAcvtQstTable *qstTable = [WSBaseAcvtQstTable sharedTable];
    WSBaseAcvtQstOptTable *optTable = [WSBaseAcvtQstOptTable sharedTable];
    
    //acvt表新增了server_node列，老数据的server_node为空，为了清空老数据，清除server_node为空的数据。
    NSString *sql = @"delete from base_acvt where server_node is null";
    [table executeUpdateWithSqls:@[sql]];
    sql = @"delete from base_acvt_qst where server_node is null";
    [table executeUpdateWithSqls:@[sql]];
    sql = @"delete from base_acvt_qst_opt where server_node is null";
    [table executeUpdateWithSqls:@[sql]];
    
    
    if (!storeID) {
        //根据节点名删除数据
        [table deleteWithNames:@[K_SERVER_NODE] ArgumentsValue:@[nodeName]];
        [qstTable deleteWithNames:@[K_SERVER_NODE] ArgumentsValue:@[nodeName]];
        [optTable deleteWithNames:@[K_SERVER_NODE] ArgumentsValue:@[nodeName]];
    }
    
    //再按acvtID清除数据，防止计划外下发的数据节点名与登录节点名不一致，导致数据无法清除
    NSArray *acvtIdArry = [dicts valueForKey:@"acvtId"];
    if (!acvtIdArry || acvtIdArry.count == 0) {
        return YES;
    }
    
    [table batchDeleteFromTableWithNames:@[@"_id"] ArgumentsValues:@[acvtIdArry]];
    
    
    [table batchInsertToTableWithMap:@{kTableKey_id:@{kMapKey_serverKey:kAcvtKey_acvtId},
                                       K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:dicts];
    @try
    {
        NSMutableArray *muQsts = @[].mutableCopy;
        NSMutableArray *muOpts = @[].mutableCopy;
        NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
        for (NSArray*subArry in [dicts valueForKey:kAcvtKey_qst])
        {
            if (![subArry isKindOfClass:[NSArray class]])
                continue;
            int i = 0 ;
            for (NSDictionary *dict in subArry)
            { // 问题表中的seq字段根据问卷中的问题顺序添加  同安卓逻辑  SFA 箭牌 WRIGLEY-1585
                NSMutableDictionary * temp =  dict.mutableCopy;
                [temp setObject:@(i) forKey:@"seq"];
                [muQsts addObject:temp];
                i++;
                NSArray *opts = dict[kAcvtKey_opt];
                if ([opts isKindOfClass:[NSArray class]] && opts.count)
                    for (NSDictionary *dict in opts) {
                        NSString *tempAcvtQstId = [dict objectForKey:@"acvtQstId"];
                        NSString *tempOptId = [dict objectForKey:@"optId"];
                        NSString *tempKey = [NSString stringWithFormat:@"%@_%@", tempAcvtQstId, tempOptId];
                        if ([mdict objectForKey:tempKey]) {
                            continue;
                        }
                        
                        [mdict setObject:tempKey forKey:tempKey];
                        [muOpts addObject:dict];
                        
                }
            }
        }
        
       
        
        [qstTable batchDeleteFromTableWithNames:@[@"acvtId"] ArgumentsValues:@[acvtIdArry]];
        if (muQsts.count) {
            [qstTable batchInsertToTableWithMap:@{@"_id":@{kMapKey_serverKey:@"acvtQstId"},
                                                  @"qsttype":@{kMapKey_serverKey:@"qstType"},
                                                  @"REG":@{kMapKey_serverKey:@"reg"},
                                                  @"hiddenBottomline":@{kMapKey_serverKey:@"hiddenbuttomline"},
                                                  K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:muQsts];
        }
        
        NSString *acvtQstSql = [NSString stringWithFormat:@"select acvtQstId from base_acvt_qst where acvtId %@", [acvtIdArry getInSqlString]];
        
        NSArray *acvtQstIdArray = [qstTable queryDatasBySql:acvtQstSql columnArr:@[@"acvtQstId"]];
        if (acvtQstIdArray.count > 0) {
            [optTable batchDeleteFromTableWithNames:@[@"acvtQstId"] ArgumentsValues:@[acvtQstIdArray]];
        }
        if (muOpts.count > 0) {
            
            NSDictionary *dict = @{@"_id":@{kMapKey_serverKey:@"optId"},
                                   @"optPic":@{kMapKey_serverKey:@"optimgurl"},
                                   K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}};
            [optTable  batchInsertToTableWithMap:dict Dicts:muOpts];
        }

    }
    @catch (NSException *exception) {
        LogError(@"save Error-->%@",exception.description);
    }
    
    return YES;
}




- (NSArray *)queryAcvtsWithStoreId:(NSString *)storeId filter:(NSString *)fitler {
    
    if (fitler == nil) {
        LogInfo(@"fitler is nil");
        return nil;
    }
    NSString *queryAcvtSql = nil;
    if (storeId != nil) {
        queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba join base_store_acvt  bsa on (bsa.sid = '%@' and ba._id = bsa.acvtId and ba.typ = '%@') order by seq",kAcvtQuerySqlString,storeId,fitler];
    }else {
        queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba where typ = '%@' order by seq",kAcvtQuerySqlString,fitler];
    }
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    acvts = [self addQstToAcvtBean:acvts];
    return acvts;
}


- (NSArray *)addQstToAcvtBean:(NSArray *)acvts {
    for (WSAcvtBean *acvtBean in acvts) {
        NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
        [acvtBean.qsts addObjectsFromArray:qsts];
        
        for (WSAcvtBean_qst * qst in qsts) {
            if ([qst.readonly isEqualToString:@"1"]) {
                [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
            }
        }
    }
    return acvts;
}

- (NSArray *)queryAcvtsWithfilter:(NSString *)fitler notInStoreId:(NSString *)storeId {
    if (fitler == nil || storeId == nil) {
        LogInfo(@"fitler or storeId is nil");
        return nil;
    }
    NSString *queryAcvtSql = [NSString stringWithFormat:@"%@  from base_acvt ba where  typ =  '%@'   and _id not in (select ba._id from base_store_acvt bsa join base_acvt ba on ba.[_id] = bsa.acvtId where bsa.[sid] = '%@' and ba.[typ] = '%@' union all select  ba._id from visit_store_acvt_data   visit_acvt_data   join base_acvt ba on ba._id = visit_acvt_data.acvtId where  visit_acvt_data.sid = '%@' and  ba.[typ] = '%@' and visit_acvt_data.biz_date = '%@')",
                              kAcvtQuerySqlString,fitler, storeId, fitler, storeId, fitler, [WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    acvts = [self addQstToAcvtBean:acvts];
    return acvts;
}

- (NSArray *)queryAcvtsWithfilter:(NSString *)fitler addedToStoreId:(NSString *)storeId {
    if (fitler == nil || storeId == nil) {
        LogInfo(@"fitler or storeId is nil");
        return nil;
    }
    NSString *queryAcvtSql = [NSString stringWithFormat:@"select * from ( %@ from visit_store_acvt_data visit_acvt_data join base_acvt ba on ba._id=visit_acvt_data.acvtId  and visit_acvt_data.acvtId not  in  (select ba._id from base_store_acvt bsa join base_acvt ba on ba.[_id] = bsa.acvtId where bsa.[sid] = '%@' and ba.[typ] = '%@') and  visit_acvt_data.sid= '%@' and  ba.[typ] = '%@' and visit_acvt_data.biz_date='%@'  order by visit_acvt_data._id)",
                              kAcvtQuerySqlString,storeId, fitler, storeId, fitler, [WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    acvts = [self addQstToAcvtBean:acvts];
    return acvts;
}


- (NSArray *)queryQstsWithAcvtId:(NSString *)acvtId {
    
    if ([acvtId length] == 0) {
        LogInfo(@"acvtId is nil");
        return nil;
    }
    
    NSString *queryQstSql = [NSString stringWithFormat:@"%@ where acvtId = '%@' ",kAcvtQstQueryString, acvtId];
    
    NSArray *qsts = [[WSBaseAcvtQstTable sharedTable] queryAndReturnInfosBySql:queryQstSql andClassName:@"WSAcvtBean_qst"];
    for (NSInteger i= 0; i < [qsts count]; i++) {
        WSAcvtBean_qst *beanQst = qsts[i];
        NSArray *opts = [self queryOptsWithQstId:beanQst.acvtQstId];
        
        if ([opts count] > 0) {
            beanQst.opt = [opts mutableCopy];
        }
    }
    return qsts;
    
}

- (WSAcvtBean_qst *)queryQstWithAcvtQstId:(NSString *)acvtQstId {
    
    if (!acvtQstId) {
        LogInfo(@"acvtId is nil");
        return nil;
    }
    
    NSString *queryQstSql = [NSString stringWithFormat:@"%@ where acvtQstId = '%@' ", kAcvtQstQueryString, acvtQstId];
    
    NSArray *qsts = [[WSBaseAcvtQstTable sharedTable] queryAndReturnInfosBySql:queryQstSql andClassName:@"WSAcvtBean_qst"];
    
    return [qsts firstObject];
}

- (WSAcvtBean_qst *)queryQstWithAcvtQstCode:(NSString *)acvtQstCode {
    
    if (!acvtQstCode) {
        LogInfo(@"acvtId is nil");
        return nil;
    }
    
    NSString *queryQstSql = [NSString stringWithFormat:@"%@ where qstCod = '%@' ", kAcvtQstQueryString, acvtQstCode];
    
    NSArray *qsts = [[WSBaseAcvtQstTable sharedTable] queryAndReturnInfosBySql:queryQstSql andClassName:@"WSAcvtBean_qst"];
    
    return [qsts firstObject];
}


- (NSArray *)queryOptsWithQstId:(NSString *)qstId {
    if ([qstId length] == 0) {
        LogError(@"qstId is nil ");
    }
    NSString *queryOptSql = [NSString stringWithFormat:@"select baqo._id optId,baqo.acvtQstId,baqo.optName,baqo.optPic,baqo.seq from base_acvt_qst_opt baqo where acvtQstId = '%@'",qstId];
    return  [[WSBaseQstOptTable shareInstance] queryAndReturnInfosBySql:queryOptSql andClassName:@"WSAcvtBean_qst_opt"];
}

//MMSH-7467
- (WSAcvtBean *)queryAcvtWithStoreId:(NSString *)storeId withAcvtTyp:(NSString *)acvtTyp {
    
//    NSString *queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba join base_store_acvt bsa on (bsa.sid = '%@' and ba._id = bsa.acvtId and ba.typ = '%@') order by seq", kAcvtQuerySqlString, storeId, acvtTyp];
//    去掉关联关系 SFA-31686
    
    NSString *queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba where ba.typ = '%@' order by seq ", kAcvtQuerySqlString, acvtTyp];
    
    NSArray *acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    WSAcvtBean *acvtBean = [acvts firstObject];
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    
    return acvtBean;
}

- (WSAcvtBean *)queryAcvtWithAcvtCode:(NSString *)acvtCode {
    
    if (acvtCode == nil) {
        LogInfo(@"acvtCode is nil");
        return nil;
    }
    NSString *queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId, acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript from base_acvt ba where acvtcode = '%@'",acvtCode];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    
    WSAcvtBean *acvtBean = [acvts firstObject];
    
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    
    return acvtBean;
    
}

- (WSAcvtBean *)queryAcvtWithAcvtID:(NSString *)acvtID {
    
    if (acvtID == nil) {
        LogInfo(@"acvtCode is nil");
        return nil;
    }
    NSString *queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba where _id = '%@'",kAcvtQuerySqlString,acvtID];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    
    WSAcvtBean *acvtBean = [acvts firstObject];
    
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    return acvtBean;
    
}

- (WSAcvtBean *)queryAcvtWithQstCod:(NSString *)qstCod {
    
    if (qstCod == nil) {
        LogInfo(@"qstCod is nil");
        return nil;
    }
    NSString *queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId, acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript from base_acvt ba join base_acvt_qst where ba._id = base_acvt_qst.acvtId and base_acvt_qst.qstCod = '%@'",qstCod];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    
    WSAcvtBean *acvtBean = [acvts firstObject];
    
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    return acvtBean;
}

- (WSAcvtBean *)queryAcvtWithStoreId:(NSString *)storeId withAcvtCode:(NSString *)acvtCode{

    NSString *queryAcvtSql = [NSString stringWithFormat:@"%@ from base_acvt ba join base_store_acvt  bsa on (bsa.sid = '%@' and ba._id = bsa.acvtId and ba.acvtCode = '%@' ) order by seq",kAcvtQuerySqlString,storeId,acvtCode];
    
    NSArray * acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    
    WSAcvtBean *acvtBean = [acvts firstObject];
    
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    
    return acvtBean;
}

- (NSString *)queryNotFillFromMustFillAcvtStoreId:(NSString *)storeId withCurrentFc:(NSString *)currentFc withStoreType:(NSString *)styp{

    // parentId
    WSBaseFunsDBService *db = [[WSBaseFunsDBService alloc]init];
    NSString *parentId = [db getFuncsIdWithCurrentFc:currentFc];
    
    // styp
    if (!styp || [styp length] == 0) {
        return @"";
    }
    NSString *stypReplaceStr = @"";
    NSArray *stypReplaces = [styp componentsSeparatedByString:@"-"];
    if ([stypReplaces count] > 0) {
        stypReplaceStr = [NSString stringWithFormat:@" or styp ='%@'", stypReplaces[0]];
    }
    
    NSString *currentStyp = [NSString stringWithFormat:@" and (styp = '%@' or styp is null or styp like '%%%@,%%' %@)", styp, styp, stypReplaceStr];
    NSString *bsaStoreID = [NSString stringWithFormat:@"bsa.[sid] = '%@'",storeId];
    NSString *parentID = [NSString stringWithFormat:@"parentid = '%@'",parentId];
    
    NSString *vaStoreID = [NSString stringWithFormat:@"and va.[store_id] = '%@'",storeId];
    
    NSString * empId = [NSString stringWithFormat:@"and va.[emp_id] = '%@'" , [WSAppData getObjectbyKey:APPDATA_EMPID]];
    // key && value
    NSArray *keyArray = @[@"$bsaStoreId$",@"$parentId$",@"$storeTypeWhere$",@"$vaStoreId$",@"$emp_id$"];
    NSArray *valueArray = @[bsaStoreID,parentID,currentStyp,vaStoreID,empId];
    
    if ([keyArray count] != [valueArray count]) {
        NSLog(@"keyArray count  != valueArray count !");
        return nil;
    }
    NSString * path = [[NSBundle mainBundle]pathForResource:@"QuerySql.plist" ofType:nil];
    NSDictionary  *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * sql = [plistDict objectForKey:@"notFillAcvtQuerySql"];
    

    for (int i = 0; i < keyArray.count ; i++) {
        sql =  [sql stringByReplacingOccurrencesOfString:keyArray[i] withString:valueArray[i]];
    }
    
    LogInfo(@"sql--%@",sql);
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    NSString *names = @"";
    NSInteger count = 0;
    while ([rs next]) {
        NSString *acvtName = [rs stringForColumn:@"acvtName"];
        NSString *funcsName = [rs stringForColumn:@"funcsName"];
        if (count > 0) {
            names = [NSString stringWithFormat:@"%@,", names];
        }
        names = [NSString stringWithFormat:@"%@%@-[%@]", names, funcsName, acvtName];
        count++;
    }
    LogInfo(@"names--%@",names);
    return names;
    
    
    
}
- (NSString *)queryNotFillFromMustFillAcvtStoreId:(NSString *)storeId withParentId:(NSString *)parentId withStoreType:(NSString *)styp {
    LogTrace();
    NSString *bsaStoreID = [NSString stringWithFormat:@"bsa.[sid] = '%@'",storeId];
    NSString *parentID = [NSString stringWithFormat:@"parentid = '%@'",parentId];
 
    NSString *vaStoreID = [NSString stringWithFormat:@"and va.[store_id] = '%@'",storeId];
    
    NSString * empId = [NSString stringWithFormat:@"and va.[emp_id] = '%@'" , [WSAppData getObjectbyKey:APPDATA_EMPID]];
    NSArray *keyArray = @[@"$bsaStoreId$",@"$parentId$",@"$storeTypeWhere$",@"$vaStoreId$",@"$emp_id$"];
    NSArray *valueArray = @[bsaStoreID,parentID,styp,vaStoreID,empId];

    
    if ([keyArray count] != [valueArray count]) {
        NSLog(@"keyArray count  != valueArray count !");
        return nil;
    }
    NSString * path = [[NSBundle mainBundle]pathForResource:@"QuerySql.plist" ofType:nil];
    NSDictionary  *plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString * sql = [plistDict objectForKey:@"notFillAcvtQuerySql"];
    
    
    
    for (int i = 0; i < keyArray.count ; i++) {
        sql =  [sql stringByReplacingOccurrencesOfString:keyArray[i] withString:valueArray[i]];
    }
    
    LogInfo(@"sql--%@",sql);
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    NSString *names = @"";
    NSInteger count = 0;
    while ([rs next]) {
        NSString *acvtName = [rs stringForColumn:@"acvtName"];
        NSString *funcsName = [rs stringForColumn:@"funcsName"];
        if (count > 0) {
             names = [NSString stringWithFormat:@"%@,", names];
        }
        names = [NSString stringWithFormat:@"%@%@-[%@]", names, funcsName, acvtName];
        count++;
    }
    LogInfo(@"names--%@",names);
    return names;
}

- (NSString *)queryOptNameByID:(NSString *)optID acvtQstID:(NSString *)acvtQstID
{
    NSString *queryOptSql = [NSString stringWithFormat:@"select baqo._id optId,baqo.acvtQstId,baqo.optName,baqo.optPic,baqo.seq from base_acvt_qst_opt baqo where _id = '%@' and acvtQstId = '%@'", optID, acvtQstID];
    NSArray *array = [[WSBaseQstOptTable shareInstance] queryAndReturnInfosBySql:queryOptSql andClassName:@"WSAcvtBean_qst_opt"];
    WSAcvtBean_qst_opt *opt = [array firstObject];
    return [opt optName];
}


- (NSString *)queryOptPicByID:(NSString *)optID acvtQstID:(NSString *)acvtQstID {
    if ([optID length] == 0 || [acvtQstID length] == 0) {
        LogInfo(@"optID is nil  or  acvtQstId is nil");
        return nil;
    }
    NSString *queryOptSql = [NSString stringWithFormat:@"select baqo._id optId,baqo.acvtQstId,baqo.optName,baqo.optPic,baqo.seq from base_acvt_qst_opt baqo where _id = '%@' and acvtQstId = '%@'", optID, acvtQstID];
    NSArray *array = [[WSBaseQstOptTable shareInstance] queryAndReturnInfosBySql:queryOptSql andClassName:@"WSAcvtBean_qst_opt"];
    WSAcvtBean_qst_opt *opt = [array firstObject];
    return [opt optPic];
}

- (NSString *)queryOptPicByOptName:(NSString *)optName{
    
    if ([optName length] == 0 ) {
        LogInfo(@"optName is nil");
        return nil;
    }
    NSString *queryOptSql = [NSString stringWithFormat:@"select baqo._id optId,baqo.acvtQstId,baqo.optName,baqo.optPic,baqo.seq from base_acvt_qst_opt baqo where optName = '%@'", optName];
    NSArray *array = [[WSBaseQstOptTable shareInstance] queryAndReturnInfosBySql:queryOptSql andClassName:@"WSAcvtBean_qst_opt"];
    WSAcvtBean_qst_opt *opt = [array firstObject];
    return [opt optPic];
}

- (WSAcvtBean *)queryAcvtByFilter:(NSString *)filter acvtCode:(NSString *)acvtCode
{
    
    NSString *queryAcvtSql = nil;
    NSArray * acvts = nil;
    
    if ([acvtCode length] > 0 && ![acvtCode isEqualToString:@"Y"] && ![acvtCode isEqualToString:@"N"]) {
        queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId, acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript from base_acvt ba where acvtCode = '%@'",acvtCode];
        acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    }
    
    if ((!acvts || [acvts count] == 0) && [filter length] > 0) {
        queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId, acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript ,ba.originalAcvtId iOriginalAcvtId from base_acvt ba where typ = '%@'",filter];
        acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    }
    
    WSAcvtBean *acvtBean = [acvts firstObject];
    
    NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
    [acvtBean.qsts addObjectsFromArray:qsts];
    
    for (WSAcvtBean_qst * qst in qsts) {
        if ([qst.readonly isEqualToString:@"1"]) {
            [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
        }
    }
    
    return acvtBean;
}

- (NSArray *)queryAcvtsByFilter:(NSString *)filter acvtCode:(NSString *)acvtCode
{
    
    NSString *queryAcvtSql = nil;
    NSArray * acvts = nil;
    
    // WRIGLEY-1447 主线 新增门店时多渠道
    if ([acvtCode length] > 0 && ![acvtCode isEqualToString:@"Y"] && ![acvtCode isEqualToString:@"N"]) {
        NSArray *pArray = [acvtCode componentsSeparatedByString:@","];
        NSString *inString = @"in (";
        for (NSInteger i = 0; i < [pArray count]; i++) {
            if (i == 0) {
                inString = [inString stringByAppendingFormat:@"'%@'",pArray[i]];
            }else {
                inString = [inString stringByAppendingFormat:@",'%@'",pArray[i]];
            }
        }
        inString = [inString stringByAppendingFormat:@")"];
        
        //MN-689 增加 ba.originalAcvtId iOriginalAcvtId
        queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId,publisher,acvtName,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ba.acvtIconUrl acvtIconUrl,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript, ba.originalAcvtId iOriginalAcvtId, cast(s as int) seq from base_acvt ba where acvtCode %@ order by seq",inString];
        acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    }
    
    if ((!acvts || [acvts count] == 0) && [filter length] > 0) {
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
        
        //MN-689 增加 ba.originalAcvtId iOriginalAcvtId
        queryAcvtSql = [NSString stringWithFormat:@"select distinct  ba._id acvtId, acvtName,publisher,acvtObj,typ,ifnull(isBlock,'') isBlock,ifnull(isReq,'') isReq,ba.acvtIconUrl acvtIconUrl,ifnull(acvtCode,'') acvtCode ,ba.ftext luaScript, ba.originalAcvtId iOriginalAcvtId, cast(s as int) seq from base_acvt ba where typ %@ order by seq",inString];
        acvts = [[WSBaseAcvtTable sharedTable] queryAndReturnInfosBySql:queryAcvtSql andClassName:@"WSAcvtBean"];
    }
    
    for (WSAcvtBean *acvtBean  in acvts) {
        NSArray *qsts = [self queryQstsWithAcvtId:acvtBean.acvtId];
        [acvtBean.qsts addObjectsFromArray:qsts];
        
        for (WSAcvtBean_qst * qst in qsts) {
            if ([qst.readonly isEqualToString:@"1"]) {
                [acvtBean.qstIdsForOriginReadonly addObject:qst.acvtQstId];
            }
        }
    }
    return acvts;
}

- (BOOL)processAcvtQstLuaScript {
    
    NSString *sql = [self getSQLWithPlistKey:@"processAcvtQstLuaScript" keyArray:nil valueArray:nil];
    
    return [[WSBaseAcvtTable sharedTable] executeUpdateWithSqls:@[sql]];
}

- (NSString *)queryAcvtValueWithParamCol:(NSString *)col acvtBean:(WSAcvtBean *)acvtBean{
    
    if (!acvtBean || !col || [col length] == 0) {
        return nil;
    }
    if ([self hasVariableWithClass:[WSAcvtBean class] varName:col]) {
        return [NSString stringWithValue:[acvtBean valueForKey:col]];
    }
    return nil;
    
}

- (NSArray *)queryQstWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode qstCode:(NSString *)qstCode {
    if (!storeId || !acvtCode || !qstCode) {
        LogInfo(@"StoreId or acvtCode or qstCode is nil");
        return nil;
    }
    
    NSString *queryQstSql = [NSString stringWithFormat:@"%@ qst join  base_acvt ba on qst.acvtId = ba._id  join base_store_acvt  bsa on (bsa.sid = '%@' and ba._id = bsa.acvtId) where ba.acvtCode = '%@' and qst.qstCod = '%@' order by qst.seq", kAcvtQstQueryString, storeId, acvtCode, qstCode];
    
    NSArray *qsts = [[WSBaseAcvtQstTable sharedTable] queryAndReturnInfosBySql:queryQstSql andClassName:@"WSAcvtBean_qst"];
    
    return qsts;
}
- (WSAcvtBean_qst *)queryQstWithQstCod:(NSString *)qstCod
{
    NSString *sql = [NSString stringWithFormat:@"select * from base_acvt_qst where qstCod = '%@'",qstCod];
    
    NSArray *acvtQsts = [[WSBaseAcvtQstTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSAcvtBean_qst"];
    
    WSAcvtBean_qst *acvtBean_qst = [acvtQsts firstObject];
    
    return acvtBean_qst;
    
}


@end
