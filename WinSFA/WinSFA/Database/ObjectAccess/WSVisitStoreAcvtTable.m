//
//  WSVisitStoreAcvtTable.m
//  WinSFA
//
//  Created by Alicia on 2017/5/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSVisitStoreAcvtTable.h"

static WSVisitStoreAcvtTable *baseTable = nil;

@implementation WSVisitStoreAcvtTable


+ (WSVisitStoreAcvtTable *)sharedTable{
    if (baseTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseTable = [[WSVisitStoreAcvtTable alloc] init];
        });
    }
    return baseTable;
}

- (void)cleanOldData
{
    NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where biz_date < '%@'", dbTableName, [NSString stringNotNilWithValue:currenTime]];
    
    [self executeUpdateWithSqls:@[sql]];
    
}

- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId
{
    BOOL isUpdate = NO;
    if ([datas count] < 1) {
        isUpdate = YES;
        return isUpdate;
    }
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql = [WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
    [self deleteDatasGenId:genId];
    return [[WSFMDatebase getInstance] insertWithSql:insertSql withArgumentsInArrays:datas];
}

- (BOOL)insertOrUpdateAcvtByGenId:(NSString *)genId storeId:(NSString *)storeId acvtId:(NSString *)acvtId srId:(NSString *)srId memo:(NSString *)memo
{
    [self deleteWithNames:@[@"gen_id",@"acvtid",@"memo"] ArgumentsValue:@[genId,acvtId,memo]];

    NSMutableArray* datas = [[NSMutableArray alloc] init];
    [datas addObject:storeId ? storeId : @"-1"];
    [datas addObject:acvtId];
    [datas addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
    [datas addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    [datas addObject:srId.length > 0 ? srId : [NSNull null]];
    [datas addObject:memo.length > 0 ? memo : [NSNull null]];
    [datas addObject:genId];
    
    NSArray *acvtDatas = [NSArray arrayWithObject:datas];
    return [self insertWithArgumentsValue:acvtDatas];
}

- (NSArray *)queryDatasByGenId:(NSString *)genId
{
    return [self queryWithNames:@[@"gen_id"] ArgumentsValue:@[genId]];
}
- (BOOL)deleteDatasGenId:(NSString*)genId
{
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];

    NSString *delSql = [NSString  stringWithFormat:@"delete from %@ where %@ = ? ",dbTableName,@"gen_id"];
    
    return [[WSFMDatebase getInstance] executeUpdateWithSql:delSql withArgumentsInArray:@[genId]];
}

@end
