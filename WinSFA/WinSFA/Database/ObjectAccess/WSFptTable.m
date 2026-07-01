//
//  WSFptTable.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSFptTable.h"
#import "NSDictionary+Additional.h"
#import "WSImagePathTable.h"

@implementation WSFptTable

static WSFptTable *fptTable=nil;
+(WSFptTable*)sharedTable{
    
    @synchronized(self) {
        if (fptTable==nil) {
            fptTable= [[WSFptTable alloc]init];
        }
    }
    return  fptTable;
}

-(void)cleanOldData
{
    NSString *currentTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
//    NSArray* array=[self queryWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue:currentTime]]];
//    for(WSFptObject* object in array){
//        [[WSProductTable sharedTable] deleteWithNames:@[@"idx"] ArgumentsValue:@[object.img_idx]];
//    }
//    [self deleteWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue:currentTime]]];
//
    
    //    YIHAIKERRY-4517 donghong    SFA-24142
    NSString *sql = [NSString stringWithFormat:@"delete  from wch_fpt where IMG_IDX not in(select acvt_qst_answer from visit_store_acvt_data) and biz_date < '%@'", [NSString stringNotNilWithValue:currentTime]];
    
    NSString *sql1 = [NSString stringWithFormat:@"delete  from wch_product where IDX not in(select acvt_qst_answer from visit_store_acvt_data) and  biz_date < '%@'", [NSString stringNotNilWithValue:currentTime]];
    
    NSString *lastTime = [WSAppData compareCurrentStrTime:currentTime withMonth:0 andDays:-7];
    
    NSString *sqlLast= [NSString stringWithFormat:@"delete  from wch_fpt where biz_date < '%@'", [NSString stringNotNilWithValue:lastTime]];
    
    NSString *sqlLastProduct= [NSString stringWithFormat:@"delete  from wch_product where biz_date < '%@'", [NSString stringNotNilWithValue:lastTime]];

    [self executeUpdateWithSqls:@[sqlLast,sqlLastProduct,sql,sql1]];

}

- (void)insertWithFptArray:(NSArray *)fptValues product:(NSArray *)proValues
{
    NSArray *whereNames = [NSArray arrayWithObjects:@"func_code",@"store_id",@"TITLE", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[fptValues objectAtIndex:0], [fptValues objectAtIndex:4],[fptValues lastObject],nil];
    
    NSArray *fptArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    if(fptArray && fptArray.count>0){
        
        NSString *fptImg_idx=[[fptArray objectAtIndex:0] img_idx];
        
        NSArray *whereNam=[NSArray arrayWithObjects:@"idx", nil];
        NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fptImg_idx], nil];
        [[WSProductTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
        [self deleteWithNames:whereNames ArgumentsValue:whereValues];
    }
    
    
    NSMutableArray* sqlArray=[NSMutableArray array];
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
    NSString *valueString = [NSString string];
    for (NSString *value in fptValues) {
        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
    }
    
    valueString = [valueString substringToIndex:valueString.length - 1];
    insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
    insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
    
    [sqlArray addObject:insertSql];

    for(id object  in proValues){
        if([object isKindOfClass:[NSArray class]]){
            
            NSString* dbTableName=[WSPlistHelper valueForKey:[WSProductTable className] withPlistName:kDataBaseMappingFileName];
            NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
            
            NSString *valueString = [NSString string];
            for (NSString *value in object) {
                valueString = [valueString stringByAppendingFormat:@"'%@',", value];
            }
            
            valueString = [valueString substringToIndex:valueString.length - 1];
            insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
            insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
            
            [sqlArray addObject:insertSql];
            
        }else if([object isKindOfClass:[NSDictionary class]]){
            [sqlArray addObject:[self insertProduct:(NSDictionary*)object]];

        }
    }
    [self insertWithSqls:sqlArray];
}




- (BOOL)insertWithFptArray:(NSArray *)fptValues product:(NSArray *)proValues isClear:(BOOL) isClear
{
    NSArray *whereNames = [NSArray arrayWithObjects:@"func_code",@"store_id",@"TITLE", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[fptValues objectAtIndex:0], [fptValues objectAtIndex:4],[fptValues lastObject],nil];
    
    NSArray *fptArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    if(fptArray && fptArray.count>0){
        if(isClear){
            for(id object  in proValues){
                if([object isKindOfClass:[NSArray class]]){
                    NSArray *prodValuesArray = (NSArray *)object;
                    NSString *fptImg_idx=[[fptArray objectAtIndex:0] img_idx];
                    NSArray *whereNam=[NSArray arrayWithObjects:@"idx",@"prod_id", nil];
                    NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fptImg_idx],[NSString stringNotNilWithValue:[prodValuesArray objectAtIndex:1]] , nil];
                    [[WSProductTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
                    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
                    
                }else if([object isKindOfClass:[NSDictionary class]]){
                    
                    NSDictionary *prodValuesDictionary = (NSDictionary *)object;
                    NSString *fptImg_idx=[[fptArray objectAtIndex:0] img_idx];
                    NSArray *whereNam=[NSArray arrayWithObjects:@"idx",@"prod_id", nil];
                    NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fptImg_idx],[NSString stringNotNilWithValue:[prodValuesDictionary objectForKey:@"PROD_ID"]] , nil];
                    [[WSProductTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
                    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
                }
            }
            // SFA-18657 新增删除表格本地上传所有数据然后上传之后清除之前上传数据的逻辑
            if (proValues.count <= 0) {
                NSString *fptImg_idx=[[fptArray objectAtIndex:0] img_idx];
                NSArray *whereNam=[NSArray arrayWithObjects:@"idx", nil];
                NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fptImg_idx] , nil];
                [[WSProductTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
                [self deleteWithNames:whereNames ArgumentsValue:whereValues];
            }
        }else{
            NSString *fptImg_idx=[[fptArray objectAtIndex:0] img_idx];
            NSArray *whereNam=[NSArray arrayWithObjects:@"idx", nil];
            NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fptImg_idx], nil];
            [[WSProductTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
            [self deleteWithNames:whereNames ArgumentsValue:whereValues];
        
        }
    }
    
    
    NSMutableArray* sqlArray=[NSMutableArray array];
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
    NSString *valueString = [NSString string];
    for (NSString *value in fptValues) {
        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
    }
    
    valueString = [valueString substringToIndex:valueString.length - 1];
    insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
    insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
    
    [sqlArray addObject:insertSql];
    
    for(id object  in proValues){
        if([object isKindOfClass:[NSArray class]]){
            
            NSString* dbTableName=[WSPlistHelper valueForKey:[WSProductTable className] withPlistName:kDataBaseMappingFileName];
            NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
            
            NSString *valueString = [NSString string];
            for (NSString *value in object) {
                valueString = [valueString stringByAppendingFormat:@"'%@',", value];
            }
            
            valueString = [valueString substringToIndex:valueString.length - 1];
            insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
            insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
            
            [sqlArray addObject:insertSql];
            
        }else{
            [sqlArray addObject:[self insertProduct:(NSDictionary*)object]];
            
        }
    }
    return [self insertWithSqls:sqlArray];
}

- (NSString*)insertProduct:(NSDictionary *)aDic {
    
    NSString *keyString = [NSString string];
    NSString *valueString = [NSString string];
    
    NSArray *keys = [aDic allKeys];
    
    for (NSString *key in keys) {
        NSString *value = [aDic objectForKey:key];
        if (!value) {
            value = @"null";
        }
        keyString = [keyString stringByAppendingFormat:@"%@,", key];
        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
    }
    
    keyString = [keyString substringToIndex:keyString.length - 1];
    valueString = [valueString substringToIndex:valueString.length - 1];
    NSString *sql = [NSString stringWithFormat:@"insert into wch_product (%@) values (%@);", keyString, valueString];
    return sql;
}


- (NSArray *)queryFptWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid
{

    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    //func_code
    [whereNames addObject:@"func_code"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //biz_date
    [whereNames addObject:@"biz_date"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    //emp_id
    [whereNames addObject:@"emp_id"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //title
    if (aTitle && [aTitle length] > 0) {
        [whereNames addObject:@"title"];
        [whereValues addObject:aTitle];
    }
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    return [self queryWithNames:whereNames ArgumentsValue:whereValues];
}

- (BOOL)deleteProductWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid andProdIds:(NSArray *)prodIds
{
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    //func_code
    [whereNames addObject:@"func_code"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //biz_date
    [whereNames addObject:@"biz_date"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    //emp_id
    [whereNames addObject:@"emp_id"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //title
    if (aTitle && [aTitle length] > 0 && ![aTitle isEqualToString:@"null"]) {
        [whereNames addObject:@"title"];
        [whereValues addObject:aTitle];
    }
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    if ([uploadInfoArr count]>0) {
        WSFptObject *temp_fptedObject=[uploadInfoArr firstObject];
        for (NSString *prodId in prodIds) {
            [whereNames removeAllObjects];
            [whereValues removeAllObjects];
            //idx
            [whereNames addObject:@"idx"];
            [whereNames addObject:@"prod_id"];
            [whereValues addObject:[NSString stringNotNilWithValue:temp_fptedObject.img_idx]];
            [whereValues addObject:[NSString stringNotNilWithValue:prodId]];
            [[WSProductTable sharedTable] deleteWithNames:whereNames ArgumentsValue:whereValues];
        }
        return YES;
    }
    return NO;
}

- (NSArray *)queryAcvtDataGridPannelProductWithGenId:(NSString *)genId  {
    if ([genId length] == 0) {
        NSLog(@"genId is nil");
        return nil;
    }
    NSArray *names = @[@"idx"];
    NSArray *values = @[genId];
    return [[WSProductTable sharedTable] queryWithNames:names ArgumentsValue:values];
}


- (NSArray *)queryProductWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid
{
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    //func_code
    [whereNames addObject:@"func_code"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //biz_date
    [whereNames addObject:@"biz_date"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    //emp_id
    [whereNames addObject:@"emp_id"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //title
    if (aTitle && [aTitle length] > 0) {
        [whereNames addObject:@"title"];
        [whereValues addObject:aTitle];
    }
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    if ([uploadInfoArr count]>0) {
        WSFptObject *temp_fptedObject=[uploadInfoArr firstObject];
        [whereNames removeAllObjects];
        [whereValues removeAllObjects];
        //idx
        [whereNames addObject:@"idx"];
        [whereValues addObject:[NSString stringNotNilWithValue:temp_fptedObject.img_idx]];
        
        return [[WSProductTable sharedTable] queryWithNames:whereNames ArgumentsValue:whereValues];
    }
    return nil;
}

- (WSFptObject *)queryFPTWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid
{

    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    //func_code
    [whereNames addObject:@"func_code"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //biz_date
    [whereNames addObject:@"biz_date"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    //emp_id
    [whereNames addObject:@"emp_id"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //title
    if (aTitle && [aTitle length] > 0) {
        [whereNames addObject:@"title"];
        [whereValues addObject:aTitle];
    }
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }

    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];

    return [uploadInfoArr firstObject];
}

- (WSFptObject *)queryFPTWithStoreIdForTB:(NSString *)aStoreId fc:(NSString *)aFc md5:(NSString *)md5
{
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSArray *whereNames = nil;
    NSArray *whereValues = nil;
    if (md5){
        whereNames=[NSArray arrayWithObjects:@"store_id",@"func_code",@"biz_date",@"emp_id",@"title", nil];
        whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:aStoreId],[NSString stringNotNilWithValue:aFc],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID],[NSString stringNotNilWithValue:md5], nil];
    }else{
        whereNames=[NSArray arrayWithObjects:@"store_id",@"func_code",@"biz_date", @"emp_id", nil];
        whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:aStoreId],[NSString stringNotNilWithValue:aFc],[NSString stringNotNilWithValue:currenTime], [WSAppData getObjectbyKey:APPDATA_EMPID], nil];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    return [uploadInfoArr firstObject];
}


- (NSArray *)queryFptImagePathWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc title:(NSString *)aTitle andSrid:(NSString *)srid
{
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //store_id
    [whereNames addObject:@"store_id"];
    [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    //func_code
    [whereNames addObject:@"func_code"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //biz_date
    [whereNames addObject:@"biz_date"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    //emp_id
    [whereNames addObject:@"emp_id"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //title
    if (aTitle && [aTitle length] > 0) {
        [whereNames addObject:@"title"];
        [whereValues addObject:aTitle];
    }
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    if ([uploadInfoArr count] >0)
    {
        WSFptObject *temp_fptedObject = [uploadInfoArr objectAtIndex:0];
        //存储 FPT_001_AT01_5db4db97fb26db8686f2a315e29c1dea，
        NSString* id_=[NSString stringWithFormat:@"%@_%@",aFc,temp_fptedObject.img_idx];
        return [[WSImagePathTable sharedTable] queryWithImageIDX:id_];
    }
    return nil;
}



@end

