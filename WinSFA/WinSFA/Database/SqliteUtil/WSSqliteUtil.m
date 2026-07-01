//
//  WSSqliteUtil.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSqliteUtil.h"


#import "WSBaseStoreTable.h"

#import "YYModel.h"

/**
 *  @author weida
 *
 *  @brief 对应服务器端字段
 */
NSString *kMapKey_serverKey      = @"server_key";

/**
 *  @author weida
 *
 *  @brief 若服务器没有该字段，用此值代替
 */
NSString *kMapKey_placeHolder    = @"placeHolder";

/**
 *  @author weida
 *
 *  @brief 若服务器没有该字段，根据插入顺序自动递增（目前不能同时设置多个字段同时自增）
 */
NSString *kMapKey_autoIncrement  = @"autoIncrement";

@implementation WSSqliteUtil


#pragma mark - 批量删除、插入

-(BOOL)batchDeleteFromTableWithNames:(NSArray*)names ArgumentsValues:(NSArray*)values
{
    BOOL ret = FALSE;
    LogTrace();

    if (![names isKindOfClass:[NSArray class]]  || !names.count ||
        ![values isKindOfClass:[NSArray class]] || !values.count)
    {//参数检查
        LogError(@"传递参数错误");
        return ret;
    }
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];//表名
    NSMutableArray *sqls;
    
    if ([[values firstObject] isKindOfClass:[NSArray class]] && (names.count==values.count))
    {//说明values数组每个元素都是一个数组,且这些数组的count应该是一样的
        @try
        {
            NSArray *first = [values firstObject];
            sqls = [NSMutableArray arrayWithCapacity:first.count];
            NSString *head = [NSString stringWithFormat:@"delete from %@ where  ",dbTableName];
            NSMutableString *deleteSQL = head.mutableCopy;
            
            for (int i=0; i<first.count; i++)
            {
                for (int j=0; j<names.count; j++)
                {
                    NSArray *valueArry = values[j];
                    
                    if (i < valueArry.count)
                    {//不越界
                        [deleteSQL appendFormat:@"%@ = '%@'",names[j],valueArry[i]];
                    }else
                    {//数组越界,就使用数组最后一个元素补上
                        [deleteSQL appendFormat:@"%@ = '%@'",names[j],valueArry[valueArry.count-1]];
                    }
                    
                    if (j!= names.count-1)
                    {//如果不是最后一个
                        [deleteSQL appendString:@" and "];
                    }
                }
                [sqls addObject:deleteSQL];
                deleteSQL = head.mutableCopy;
            }
            ret = [self executeUpdateWithSqls:sqls];//批量执行删除
        }
        @catch (NSException *exception)
        {
            LogError(@"error-->%@",exception.description);
            ret = FALSE;
        }
    }
    return ret;
}


-(BOOL)batchInsertToTableWithMap:(NSDictionary *)Map  Dicts:(NSArray *)dicts
{
    BOOL ret = FALSE;
    
    @try
    {
//        NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:dicts.count]; //数据库语句数组
        NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];//表名
        NSString* insertSql =  [WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
        if ([dbTableName isEqualToString:@"base_store_other_data"]) {
            
        }
        NSRange firstPlace= [insertSql rangeOfString:@"("];
        NSRange lastPlace = [insertSql rangeOfString:@")"];
        
        NSString *parameters = [[insertSql substringWithRange:NSMakeRange(firstPlace.location+1, lastPlace.location-firstPlace.location-1)]stringByReplacingOccurrencesOfString:@" " withString:@""];//找到插入语句中的参数并去掉空格
        
        NSArray *parametersArry = [parameters componentsSeparatedByString:@","];//SQL语句中要插入的字段名称数组
        
//        NSString *headSql = [NSString stringWithFormat:@"%@ values( ",[insertSql substringToIndex:lastPlace.location+1]];//SQL语句前面那段是固定的
//        NSMutableString *sql = headSql.mutableCopy;
        NSInteger autoIncrement = 0;//自动递增
        
        NSMutableArray *totalValueArray = [NSMutableArray arrayWithCapacity:[dicts count]];
        
        for (NSDictionary*dict in dicts)
        {
            //YIHAIKERRY-5205
            if ([dbTableName isEqualToString:@"base_product"] && ![dict objectForKey:@"id"]) {
                continue;
            }
            NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:[parametersArry count]];
            for (NSString*key in parametersArry)//key本地数据库字段
            {
                NSDictionary *config = Map[key];
                
                if (!config || ![config isKindOfClass:[NSDictionary class]])
                {//参数不对，自动忽略此参数,只做默认操作
                    
                    NSString *value = [NSString stringNotNilWithValue:dict[key]];
                    
                    /*如果当前是WSBaseStoreTable 则若dict中srid字段有值 则替换empId值 */
                    if ([self isKindOfClass:[WSBaseStoreTable class]]) {
                        if ([key isEqualToString:@"empId"]) {
                            NSString *srId = dict[@"srid"];
                            if ([srId isKindOfClass:[NSNumber class]]) {
                                srId = [(NSNumber *)srId stringValue];
                            }
                            if ([srId length] > 0) {
                                value = srId;
                            }
                        }
                    }
//                    [sql appendFormat:@"'%@',",value];
                    if ([value isEqualToString:@""]) {
                        //YIHAIKERRY-3815
                        // 备注：和安卓统一逻辑如果后台没有下发SEQ 的值就自己拼上，它的值就是当前所在的节点中的顺序
                        if ([key isEqualToString:kBaseDictKey_seq]) {
                            [valueArray addObject:[NSString stringWithFormat:@"%ld",[dicts indexOfObject:dict]]];
                        } else {
                            [valueArray addObject:[NSNull null]];
                        }
                        
                    }else{
                        [valueArray addObject:value];
                    }
                
                    continue;
                }
                
                NSString *keyService=  config[kMapKey_serverKey];//对应的服务器字段
                
                id value;//将要存入数据库的字段值
                if (!keyService || [keyService isKindOfClass:[NSNull class]])
                {//说明本地和服务器地段是一样的
                    value = [NSString stringNotNilWithValue:dict[key]];
                }else
                {//字段不一样
                    value = [NSString stringNotNilWithValue:dict[keyService]];
                }
                
                if ([value isEqualToString:@""])
                {//如果value为空
                    value = [NSString stringNotNilWithValue:config[kMapKey_placeHolder]];//就用placeHolder值替代
                    
                    if ([value isEqualToString:@""])
                    {//如果还为空,考虑，是不是设置了自动递增
                        if (autoIncrement)
                        {//说明肯定设置了自动递增
                            value = @(++autoIncrement);
                        }else
                        {//查看是否设置了自动递增标识，以下代码仅执行一次
                            NSInteger intger = [config[kMapKey_autoIncrement]integerValue];
                            if (intger)
                            {//设置值不为0
                                autoIncrement = intger;
                                value = @(autoIncrement);
                            }
                        }
                    }
                }
                
//                [sql appendFormat:@"'%@',",value];
                
                if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@""]) {
                    //YIHAIKERRY-3815
                    // 备注：和安卓统一逻辑如果后台没有下发SEQ 的值就自己拼上，它的值就是当前所在的节点中的顺序
                    if ([key isEqualToString:kBaseDictKey_seq]) {
                        [valueArray addObject:[NSString stringWithFormat:@"%ld",[dicts indexOfObject:dict]]];
                    } else {
                        [valueArray addObject:[NSNull null]];
                    }
                    
                }else{
                    [valueArray addObject:value];
                }
            }
//            [sql replaceCharactersInRange:NSMakeRange(sql.length-1, 1) withString:@");"];//去掉最后一个,号，加上); 到此SQL语句拼接完毕
//            [sqls addObject:sql];
//            sql = headSql.mutableCopy;//恢复,准备从头再来
            
            [totalValueArray addObject:valueArray];
        }
//        ret = [self executeUpdateWithSqls:sqls];//批量执行
        //为解决拼接SQL特殊符号插入失败的问题，改为预绑定参数方式插入
        ret = [self insertWithSql:insertSql withArgumentsInArrays:totalValueArray];
    }
    @catch (NSException *exception)
    {
        LogError(@"batchInsertError-->%@",exception.description);
        ret = FALSE;
    }
    return ret;
}

/*批量执行  域绑定 解决slq纯sql语句执行value有 单引号问题*/
- (BOOL)executeUpdateWithSqls:(NSArray *)sqlArray withArgumentsInArray:(NSArray *)valuesArray
{
    if (!sqlArray || [sqlArray count] == 0) {
        return NO;
    }
    return [[WSFMDatebase getInstance] executeUpdateWithSqls:sqlArray withArgumentsInValueArrays:valuesArray];
}

//-(NSString *)databaseFilePathWithDBName:(NSString *)dbName{
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString*filePath= [documentsDirectory stringByAppendingPathComponent:dbName];
//    return filePath;
//}


//#pragma mark 打开数据库
//-(BOOL)openDataBase:(NSString *)dbName
//{
//    if(self.db!=nil && [self.db open]){
//        return YES;
//    }else{
//        NSString *filePath = [self databaseFilePathWithDBName:dbName];
//        self.db = [FMDatabase databaseWithPath:filePath];
//        
//        if([self.db open]){
//            return YES;
//        }else{
//            LogError(@"%@ 数据库打开失败!" , filePath);
//            return NO;
//        }
//    }
//}
//
//#pragma mark 关闭数据库
//-(BOOL)closeDataBase:(NSString *)dbName
//{
//    if([self.db close]){
//        self.db=nil;
//        return YES;
//    }else{
//        LogError(@"数据库关闭失败!");
//        return NO;
//    }
//}

#pragma mark 插入
-(BOOL)insertWithArgumentsValue:(NSArray *)values
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
//    NSString *logString = [NSString stringWithFormat:@"%@\n%@",insertSql,values];
//    LogSQLString(logString);
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:insertSql withArgumentsInArray:values];
}

- (BOOL)batchInsertWithArgumentsValuesArray:(NSArray *)valuesArray
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:[valuesArray count]];
    for (int i = 0; i < [valuesArray count]; i++) {
        [sqls addObject:insertSql];
    }
    
    return [[WSFMDatebase getInstance] executeUpdateWithSqls:sqls withArgumentsInValueArrays:valuesArray];
}

- (BOOL)insertWithSql:(NSString *)insertSql withArgumentsInArrays:(NSArray *)values
{
    return [[WSFMDatebase getInstance] insertWithSql:insertSql withArgumentsInArrays:values];
}


- (BOOL)insertWithSqls:(NSArray *)aSqlsArray
{
//    LogSQLString(aSqlsArray);
    
    return [self executeUpdateWithSqls:aSqlsArray];
}

- (BOOL)deleteProdstWithSqls:(NSArray *)aSqlsArray
{
//    LogSQLString(aSqlsArray);
    
    return [self executeUpdateWithSqls:aSqlsArray];
}

- (BOOL)executeUpdateWithSqls:(NSArray *)aSqlsArray
{
//    LogSQLString(aSqlsArray);
    
    return [[WSFMDatebase getInstance] executeUpdateWithSqls:aSqlsArray];
}

#pragma mark 删除
- (BOOL)deleteWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values
{
    if (!names || !values || [names count] != [values count]) {
        LogError(@"whereNames==%@  %@==whereValues ",[names description],[values description]);
        return NO;
    }
    LogTrace();
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];

    NSString *delete=[NSString  stringWithFormat:@"delete from %@ where ",dbTableName];
    for (int i=0; i<names.count; i++) {
        delete=[delete stringByAppendingFormat:@"%@=?",[names objectAtIndex:i]];
        if(i<names.count-1){
            delete=[delete stringByAppendingFormat:@" and "];
        }
    }
    
//    NSString *logString = [NSString stringWithFormat:@"%@\n%@",delete,values];
//    LogSQLString(logString);
    return [[WSFMDatebase getInstance] executeUpdateWithSql:delete withArgumentsInArray:values];
}


//批量删除对应的的数据
- (BOOL)batchDeleteDataWithNamesArray:(NSArray *)namesArray ArgumentsValuesArray:(NSArray *)valuesArray
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    
    NSMutableArray *sqls = [NSMutableArray arrayWithCapacity:[valuesArray count]];
    
    for (int i = 0; i < [namesArray count]; i++) {
        NSString *deleteSql=[NSString  stringWithFormat:@"delete from %@ where ",dbTableName];

        NSArray *names = namesArray[i];
        
        for (int j = 0; j < names.count; j++) {
            
            deleteSql=[deleteSql stringByAppendingFormat:@"%@=?",[names objectAtIndex:j]];
            if(j < names.count-1){
                deleteSql = [deleteSql stringByAppendingFormat:@" and "];
            }
        }
       
        [sqls addObject:deleteSql];
    }

    return [[WSFMDatebase getInstance] executeUpdateWithSqls:sqls withArgumentsInValueArrays:valuesArray];

}


-(BOOL)deleteAll
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    
    NSString *delete=[NSString  stringWithFormat:@"delete from %@",dbTableName];
    
    NSString *logString = [NSString stringWithFormat:@"%@\n",delete];
    LogSQLString(logString);
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:delete];
    
    return NO;
}

- (BOOL)deleteWithNames:(NSArray *)names ArgumentsValues:(NSArray *)values notInName:(NSString *)notInName notInValues:(NSArray *)notInValues
{
    if ([names count] != [values count] || !notInName || !notInValues) {
        LogError(@"whereNames==%@  %@==whereValues ,notInName:%@,notInValues:%@",[names description],[values description], notInName, notInValues);
        return NO;
    }
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"delete from %@ where ", dbTableName];
    if ([names count] > 0) {
        for (NSInteger i = 0; i < [names count]; i++) {
            [sql appendFormat:@" %@='%@' ", names[i] , values[i]];
            if (i != [names count] - 1) {
                [sql appendString:@" and "];
            }
        }
    }
    if ([notInName length] > 0 && [notInValues count] > 0) {
        
        if ([names count] > 0) {
            [sql appendString:@" and "];
        }
        
        [sql appendFormat:@"%@ not in(", notInName];
        for (NSInteger i = 0; i < [notInValues count]; i++) {
            if (i != [notInValues count] - 1) {
                [sql appendFormat:@"'%@',", notInValues[i]];
            }else {
                [sql appendFormat:@"'%@')", notInValues[i]];
            }
        }
    }
    
    LogInfo(@"sql:%@", sql);
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:sql];
}

#pragma mark 更新
-(BOOL)updateWithNames:(NSArray *)names values:(NSArray *)values whereName:(NSArray *)whereNames whereValue:(NSArray *)whereValues
{
    
    if (!names || !values || [names count] != [values count]) {
        LogError(@"whereNames==%@  %@==whereValues ",[names description],[values description]);
        return NO;
    }
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    
    NSString *update=[NSString  stringWithFormat:@"update %@ set ",dbTableName];
	for (int i=0; i<names.count; i++){
        update=[update stringByAppendingFormat:@"%@=?",[names objectAtIndex:i]];
        if(i<names.count-1){
            update = [update stringByAppendingString:@", "];
        }
    }
    
    update=[update stringByAppendingString:@" where "];
    for (int i=0; i<[whereNames count]; i++){
        update=[update stringByAppendingFormat:@"%@=?",[whereNames objectAtIndex:i]];
        if(i<whereNames.count-1){
            update=[update stringByAppendingFormat:@" and "];
        }
    }
    
    NSMutableArray * array=[NSMutableArray arrayWithArray:values];
    [array addObjectsFromArray:whereValues];
    
//    NSString *logString = [NSString stringWithFormat:@"%@\n%@",update,array];
//    LogSQLString(logString);
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:update withArgumentsInArray:array];
}


-(NSInteger)queryCountWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSMutableArray *filteredValues = [NSMutableArray arrayWithCapacity:1];
    
    NSString *query=[NSString stringWithFormat:@"select count(id) from %@", dbTableName];
    if(names.count>0 && values.count>0){
        query=[query stringByAppendingString:@" where "];
    }
    for (int i=0; i<names.count; i++) {
        if ([[values objectAtIndex:i] isKindOfClass:[NSNull class]]) {
            query=[query stringByAppendingFormat:@"%@ is null",[names objectAtIndex:i]];
        }else {
            query=[query stringByAppendingFormat:@"%@=?",[names objectAtIndex:i]];
            [filteredValues addObject:[values objectAtIndex:i]];
        }
        if(i<names.count-1){
            query=[query stringByAppendingFormat:@" and "];
        }
    }
    
//    NSString *logString = [NSString stringWithFormat:@"%@\n%@",query, filteredValues];
//    LogSQLString(logString);
    
    NSInteger count = 0;
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:query withArgumentsInArray:filteredValues];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    return count;
}

-(NSInteger)queryCountWithSql:(NSString *)sql {
    NSInteger count = 0;
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    return count;
}


#pragma mark 查询
-(NSArray *)queryWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values
{
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSMutableArray *filteredValues = [NSMutableArray arrayWithCapacity:1];
    
    if ( [dbTableName rangeOfString:@"null"].location != NSNotFound) {
        NSLog(@"dbTableName is null");
    }

    NSString *query=[NSString stringWithFormat:@"select * from %@", dbTableName];
    
    
    if(names.count>0 && values.count>0){
        query=[query stringByAppendingString:@" where "];
    }
    for (int i=0; i<names.count; i++) {
        if ([[values objectAtIndex:i] isKindOfClass:[NSNull class]]) {
            query=[query stringByAppendingFormat:@"%@ is null",[names objectAtIndex:i]];
        }else {
            query=[query stringByAppendingFormat:@"%@=?",[names objectAtIndex:i]];
            [filteredValues addObject:[values objectAtIndex:i]];
        }
        if(i<names.count-1){
            query=[query stringByAppendingFormat:@" and "];
        }
    }
    
//    NSString *logString = [NSString stringWithFormat:@"%@\n%@",query, filteredValues];
//    LogSQLString(logString);


    NSMutableArray *queryDictArr=[[NSMutableArray alloc]init];
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:query withArgumentsInArray:filteredValues];
    NSString* className=[[[[self className] componentsSeparatedByString:@"Table"] firstObject] stringByAppendingString:@"Object"];
    
    while ([rs next]) {
        id object=[[NSClassFromString(className) alloc] init];
        for(int i=0;i<rs.columnCount;i++){
            
            if([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"id"] || [[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"_id"]){
            
                if ([object isKindOfClass:[WSBaseFunsObject class]]) {
                    [object setId:[rs stringForColumnIndex:i]];
                }else
                    [object setID:[rs intForColumnIndex:i]];
            }else if([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"parent_action_id"]){
                
                [object setParent_action_id:[rs intForColumnIndex:i]];
            } else if([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"frommodulename"]){
                NSString* string=[rs stringForColumnIndex:i];
                [object setFromModuleName:string];
            }else{
                
                NSString* string=[rs stringForColumnIndex:i];
                if(string && string.length>0){
                    if ([className isEqualToString:@"WSBaseStoreObject"] && [[rs columnNameForIndex:i] isEqualToString:@"custCode"]) {
                        [object setValue:string forKey:@"custCode"];
                        continue;
                    }
                    NSString* columnName=[[rs columnNameForIndex:i] lowercaseString];
                    [object setValue:string forKey:columnName];
                }
            }
        }
        [queryDictArr addObject:object];
    }
    return (NSArray*)queryDictArr;
}

-(NSMutableArray *)queryAndReturnInfosBySql:(NSString *)sql andClassName:(NSString *)class_name{
   NSMutableArray *array = [[NSMutableArray alloc] init];
   FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        
        NSObject *instance = [NSClassFromString(class_name) yy_modelWithDictionary:[rs resultDictionary]];
        [array addObject:instance];
    }
    
    return array;
}


-(NSObject *)queryAndReturnSingleInfoBySql:(NSString *)sql andClassName:(NSString *)class_name{
    
    NSObject *instance=nil;
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        
        instance = [NSClassFromString(class_name) yy_modelWithDictionary:[rs resultDictionary]];
        
    }
    return instance;
}

- (NSArray *)queryColValues:(NSString *)colName withName:(NSArray *)names ArgumentsValue:(NSArray *)values isDistinct:(BOOL)isDistinct
{
    if (!colName || [names count] != [values count]) {
        return nil;
    }
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select %@ %@ from %@", isDistinct ? @"distinct" : @"",colName, dbTableName];
    
    if ([names count] > 0) {
        [sql appendString:@" where "];
        for (NSInteger i = 0; i < [names count]; i++) {
            [sql appendFormat:@" %@='%@' ", names[i] , values[i]];
            if (i != [names count] - 1) {
                [sql appendString:@" and "];
            }
        }
    }
    
    LogInfo(@"sql:%@", sql);
    
    FMResultSet  *rs = [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    NSMutableArray *array = [NSMutableArray array];
    
    while ([rs next]) {
        NSString *colValue = [rs stringForColumn:colName];
        if ([colValue isKindOfClass:[NSString class]] && [colValue length] > 0) {
            [array addObject:colValue];
        }
    }
    
    return array;
    
}

-(NSMutableArray *)queryDatasBySql:(NSString *)sql columnArr:(NSArray *)columnArr;
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        
        for (NSString *str in columnArr) {
            id ob = [rs objectForColumnName:str];
            [array addObject:ob];
            NSLog(@"ob%@",ob);
        }
    }
    return array;
}

- (NSArray *)queryObjectsBySql:(NSString *)sql argumentsValues:(NSArray *)values className:(NSString *)className
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql withArgumentsInArray:values];
    
    while ([rs next]) {

        NSObject *instance = [NSClassFromString(className) yy_modelWithDictionary:[rs resultDictionary]];
        [array addObject:instance];
    }
    
    return array;
}

- (NSArray *)queryDicDatasBySql:(NSString *)sql argumentsValues:(NSArray *)values
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql withArgumentsInArray:values];
    
    while ([rs next]) {
        
        [array addObject:[rs resultDictionary]];
    }
    
    return array;
}

// 获取 Dic 中 key 的有序数组
- (NSArray *)queryDicKeysBySql:(NSString *)sql argumentsValues:(NSArray *)values
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql withArgumentsInArray:values];
    
    while ([rs next]) {
        for (int i = 0; i < [rs columnCount]; i++) {
            [array addObject:[rs columnNameForIndex:i]];
        }
        break;
    }
    
    return array;
}

/**
 新增查询不同模块下相同门店是否未离开的sql查询方法
 */

#pragma mark - 新增查询不同模块下相同门店是否未离开的sql查询方法
- (NSArray *)queryPrentTypeWithNames:(NSArray *)names ArgumentsValue:(NSArray *)values {
    
    NSString *dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    if ([dbTableName rangeOfString:@"null"].location != NSNotFound) {
        NSLog(@"dbTableName is null");
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", dbTableName];
    if (names.count > 0 && values.count > 0) {
        query = [query stringByAppendingString:@" where "];
    }
    
    NSMutableArray *filteredValues = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < names.count; i++) {
        
        if ([[values objectAtIndex:i] isKindOfClass:[NSNull class]]) {
            
            query = [query stringByAppendingFormat:@"%@ is null", [names objectAtIndex:i]];
        } else {
            
            if ([names[i] isEqualToString:@"modulefc"]) {
                
                query = [query stringByAppendingFormat:@"%@ in (?)", [names objectAtIndex:i]];
                [filteredValues addObject:[values objectAtIndex:i]];
            } else {
                
                query = [query stringByAppendingFormat:@"%@ = ?", [names objectAtIndex:i]];
                [filteredValues addObject:[values objectAtIndex:i]];
            }
        }
        if (i < names.count - 1) {
            query = [query stringByAppendingFormat:@" and "];
        }
    }
    
    NSMutableArray *queryDictArr = [[NSMutableArray alloc] init];
    NSString *sqlUrl = @"";
    FMResultSet *rs;
    
    if ([dbTableName isEqualToString:@"wch_inoutStore"]) {
        
        if (filteredValues.count > 2) {
            
            NSString *sqlStr = @"select * from wch_inoutStore where";
            NSString *modulefcStr = filteredValues[2];
            if ([modulefcStr containsString:@","]) {
                
                sqlUrl = [NSString stringWithFormat:@"%@ store_id = '%@' and emp_id = '%@' and modulefc in (%@)",
                          sqlStr, filteredValues[0], filteredValues[1], filteredValues[2]];
            } else {
                if ([(NSString*)filteredValues[2] containsString:@"'"]) {
                    sqlUrl = [NSString stringWithFormat:@"%@ store_id = '%@' and emp_id = '%@' and modulefc = %@",
                              sqlStr, filteredValues[0], filteredValues[1], filteredValues[2]];
                }else{
                    sqlUrl = [NSString stringWithFormat:@"%@ store_id = '%@' and emp_id = '%@' and modulefc = '%@'",
                              sqlStr, filteredValues[0], filteredValues[1], filteredValues[2]];
                }
                
            }
            rs = [[WSFMDatebase getInstance] executeQueryWithSql:sqlUrl];
        } else {
            
             sqlUrl = query;
             rs = [[WSFMDatebase getInstance] executeQueryWithSql:sqlUrl];
        }
    } else {
        
        sqlUrl = query;
        rs = [[WSFMDatebase getInstance] executeQueryWithSql:sqlUrl withArgumentsInArray:filteredValues];
    }
        
    NSString *className = [[[[self className] componentsSeparatedByString:@"Table"] firstObject] stringByAppendingString:@"Object"];
    while ([rs next]) {
        
        id object = [[NSClassFromString(className) alloc] init];
        for (int i = 0; i < rs.columnCount; i++) {
                
            if ([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"id"] ||
                [[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"_id"]) {
                    
                if ([object isKindOfClass:[WSBaseFunsObject class]]) {
                    
                    [object setId:[rs stringForColumnIndex:i]];
                } else {
                    
                    [object setID:[rs intForColumnIndex:i]];
                }
            } else if ([[[rs columnNameForIndex:i] lowercaseString] isEqualToString:@"parent_action_id"]) {
                    
                [object setParent_action_id:[rs intForColumnIndex:i]];
            } else {
                    
                NSString *string = [rs stringForColumnIndex:i];
                if (string && string.length > 0) {
                    
                    if ([className isEqualToString:@"WSBaseStoreObject"] && [[rs columnNameForIndex:i] isEqualToString:@"custCode"]) {
                        
                        [object setValue:string forKey:@"custCode"];
                        continue;
                    }
                    NSString *columnName = [[rs columnNameForIndex:i] lowercaseString];
                    [object setValue:string forKey:columnName];
                }
            }
        }
        
        [queryDictArr addObject:object];
    }
    
    return (NSArray *)queryDictArr;
}

-(NSString *)queryTableInfoWithSql:(NSString*)sql{
    NSString * result = @"";
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    while ([rs next]) {
        result = [rs stringForColumn:@"_id"];
    }
    return result;
}
- (NSArray *)queryParentfcWithCurrentfc:(NSString*)currentfc{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString * sql  = [NSString stringWithFormat:@"select fc  from base_funcs where parentId = (select parentId  from base_funcs where fc = '%@')",currentfc];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    while ([rs next]) {
        
        [array addObject:[NSString stringWithFormat:@"'%@'",[rs stringForColumn:@"fc"]]];
    }
    
    return array;
}

@end
