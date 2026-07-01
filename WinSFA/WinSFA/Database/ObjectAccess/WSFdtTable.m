//
//  WSFdtTable.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-1-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSFdtTable.h"
#import "WSImagePathTable.h"

@implementation WSFdtTable

static WSFdtTable *fdtTable=nil;
+(WSFdtTable*)sharedTable{
    
    @synchronized(self) {
        if (fdtTable==nil) {
            fdtTable= [[WSFdtTable alloc]init];
        }
    }
    return  fdtTable;
}


-(void)cleanOldData
{
    NSString *currentTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSArray* array=[self queryWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue:currentTime]]];
    for(WSFdtObject* object in array){
        [[WSDictTable sharedTable] deleteWithNames:@[@"idx"] ArgumentsValue:@[object.img_idx]];
    }
    
    [self deleteWithNames:@[@"not biz_date"] ArgumentsValue:@[[NSString stringNotNilWithValue: currentTime]]];
}

- (void)insertWithFdtArray:(NSArray *)fdtValues Dict:(NSArray *)dictValues srid:(NSString *)srid
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"store_id",@"func_code",@"sr_id",@"TITLE",nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[fdtValues objectAtIndex:4],[fdtValues objectAtIndex:0], [fdtValues objectAtIndex:10],[fdtValues lastObject], nil];

    
    NSArray *fdtArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    if(fdtArray && fdtArray.count>0 && dictValues.count>0){
        NSString *fdtImg_idx=[[fdtArray objectAtIndex:0] img_idx];
        
        NSArray *whereNam=[NSArray arrayWithObjects:@"idx", nil];
        NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fdtImg_idx], nil];
        [[WSDictTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
    }
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
    
    
    NSMutableArray* sqlArray=[NSMutableArray array];
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
    NSString *valueString = [NSString string];
    for (NSString *value in fdtValues) {
        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
    }
    
    valueString = [valueString substringToIndex:valueString.length - 1];
    insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
    insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
    
    [sqlArray addObject:insertSql];
    
    
    for(id object  in dictValues){
        if([object isKindOfClass:[NSArray class]]){
            
            NSString* dbTableName=[WSPlistHelper valueForKey:[WSDictTable className] withPlistName:kDataBaseMappingFileName];
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
            [sqlArray addObject:[self insertDict:(NSDictionary*)object]];
            
        }
    }
    [self insertWithSqls:sqlArray];
}




- (BOOL)insertWithFdtArray:(NSArray *)fdtValues Dict:(NSArray *)dictValues
{
    NSArray *whereNames;
    NSArray *whereValues;
    //SFA-26143 fv:TAB_V2003 为其他考勤，安卓单独的一张表使用empid和日期存取，iOS使用fv单独做处理
    if ([[fdtValues objectAtIndex:1] isEqualToString:@"TAB_V2003"]) {
        whereNames=[NSArray arrayWithObjects:@"store_id",@"func_view",@"sr_id",nil];
        whereValues=[NSArray arrayWithObjects:[fdtValues objectAtIndex:4],[fdtValues objectAtIndex:1], [fdtValues objectAtIndex:10], nil];
    }else{
        whereNames=[NSArray arrayWithObjects:@"store_id",@"func_code",@"sr_id",nil];
        whereValues=[NSArray arrayWithObjects:[fdtValues objectAtIndex:4],[fdtValues objectAtIndex:0], [fdtValues objectAtIndex:10], nil];
    }
    
    NSArray *fdtArray=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    if(fdtArray && fdtArray.count>0 && dictValues.count>0){
        NSString *fdtImg_idx=[[fdtArray objectAtIndex:0] img_idx];
        
        NSArray *whereNam=[NSArray arrayWithObjects:@"idx", nil];
        NSArray *whereValu=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:fdtImg_idx], nil];
        [[WSDictTable sharedTable] deleteWithNames:whereNam ArgumentsValue:whereValu];
    }
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];

    
    NSMutableArray* sqlArray=[NSMutableArray array];
    
    NSString* dbTableName=[WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql=[WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    
    NSString *valueString = [NSString string];
    for (NSString *value in fdtValues) {
        valueString = [valueString stringByAppendingFormat:@"'%@',", value];
    }
    
    valueString = [valueString substringToIndex:valueString.length - 1];
    insertSql=[[insertSql componentsSeparatedByString:@"(?"] firstObject];
    insertSql=[insertSql stringByAppendingFormat:@"(%@);",valueString];
    
    [sqlArray addObject:insertSql];
    
    
    for(id object  in dictValues){
        if([object isKindOfClass:[NSArray class]]){
            
            NSString* dbTableName=[WSPlistHelper valueForKey:[WSDictTable className] withPlistName:kDataBaseMappingFileName];
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
            [sqlArray addObject:[self insertDict:(NSDictionary*)object]];
            
        }
    }
    return [self insertWithSqls:sqlArray];
}

- (NSString*)insertDict:(NSDictionary *)aDic {
    
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
    NSString *sql = [NSString stringWithFormat:@"insert into wch_dict (%@) values (%@);", keyString, valueString];
    return sql;
}

- (NSArray *)queryDictWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid withMd5:(NSString *)md5{
    
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //STORE_ID
    if(aStoreId  && [aStoreId length] > 0){
        [whereNames addObject:@"STORE_ID"];
        [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    }
    //SFA-26143 fv:TAB_V2003 为其他考勤，安卓单独的一张表使用empid和日期存取，iOS使用fv单独做处理
    if ([aFc isEqualToString:@"TAB_V2003"]) {
        //func_view
        [whereNames addObject:@"FUNC_view"];
    }else{
        //func_code
        [whereNames addObject:@"FUNC_CODE"];
    }

    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //emp_id
    [whereNames addObject:@"EMP_ID"];
    [whereValues addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && srid != nil && [srid length] > 0 ) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    if(md5.length >0)
    {
        
        return [[WSDictTable sharedTable] queryWithNames:@[@"IDX"] ArgumentsValue:@[md5]];
    }else if ([uploadInfoArr count]>0 ){
        WSFdtObject* fdtobject = [uploadInfoArr lastObject];
        
        return [[WSDictTable sharedTable] queryWithNames:@[@"IDX"] ArgumentsValue:@[fdtobject.img_idx]];
        
    }
    
    return nil;
}


- (NSArray *)queryFdtWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid
{
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //STORE_ID
    if(aStoreId  && [aStoreId length] > 0){
        [whereNames addObject:@"STORE_ID"];
        [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    }
    //func_code
    [whereNames addObject:@"FUNC_CODE"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //emp_id
    [whereNames addObject:@"EMP_ID"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //emp_id
    [whereNames addObject:@"BIZ_DATE"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    
    return [self queryWithNames:whereNames ArgumentsValue:whereValues];
}


- (NSArray *)queryFdtImagePathWithStoreId:(NSString *)aStoreId fc:(NSString *)aFc srid:(NSString *)srid
{
    NSMutableArray *whereNames = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *whereValues = [NSMutableArray arrayWithCapacity:1];
    //STORE_ID
    if(aStoreId  && [aStoreId length] > 0){
        [whereNames addObject:@"STORE_ID"];
        [whereValues addObject:[NSString stringNotNilWithValue:aStoreId]];
    }
    //func_code
    [whereNames addObject:@"FUNC_CODE"];
    [whereValues addObject:[NSString stringNotNilWithValue:aFc]];
    //emp_id
    [whereNames addObject:@"EMP_ID"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_EMPID]];
    //emp_id
    [whereNames addObject:@"BIZ_DATE"];
    [whereValues addObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE]];
    //srid
    [whereNames addObject:@"SR_ID"];
    if (srid && [srid length] > 0) {
        [whereValues addObject:srid];
    }else{
        [whereValues addObject:@"null"];
    }
    
    NSArray *uploadInfoArr=[self queryWithNames:whereNames ArgumentsValue:whereValues];
    
    if([uploadInfoArr count]>0)
    {
        WSFdtObject* fdtobject = [uploadInfoArr objectAtIndex:0];
        NSString* id_=[NSString stringWithFormat:@"%@_%@",aFc,fdtobject.img_idx];
        return [[WSImagePathTable sharedTable] queryWithImageIDX:id_];
    }
    
    return nil;
}

@end
