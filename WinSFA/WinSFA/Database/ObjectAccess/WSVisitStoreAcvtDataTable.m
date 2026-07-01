//
//  WSVisitStoreAcvtDataTable.m
//  WinSFA
//
//  Created by yang on 16/11/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisitStoreAcvtDataTable.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"

static WSVisitStoreAcvtDataTable *baseTable = nil;

@implementation WSVisitStoreAcvtDataTable

+ (WSVisitStoreAcvtDataTable *)sharedTable{
    if (baseTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseTable = [[WSVisitStoreAcvtDataTable alloc] init];
        });
    }
    return baseTable;
}

- (void)cleanOldData
{
    NSString *currenTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE]; 
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];

//    NSString *sql = [NSString stringWithFormat:@"delete from %@ where biz_date < '%@'", dbTableName, [NSString stringNotNilWithValue:currenTime]];
    
    //  YIHAIKERRY-4489 董宏   SFA-24142
    
    NSString *lastTime = [WSAppData compareCurrentStrTime:currenTime withMonth:0 andDays:-7];
    
    NSString *sqlLast= [NSString stringWithFormat:@"delete  from %@ where biz_date < '%@'", dbTableName, [NSString stringNotNilWithValue:lastTime]];

    NSString *sql = [NSString stringWithFormat:@"delete  from %@ where gen_id in(select img_idx from wch_offLineUpload) and biz_date < '%@'", dbTableName, [NSString stringNotNilWithValue:currenTime]];

    [self executeUpdateWithSqls:@[sqlLast,sql]];
    
}

- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId
{
    return [self insertOrUpdateDatas:datas genId:genId andParentGenId:nil];
}

- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId andParentGenId:(NSString *)parentGenId
{
    BOOL isUpdate = NO;
    if ([datas count] < 1) {
        isUpdate = YES;
        return isUpdate;
    }
    
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];
    NSString* insertSql = [WSPlistHelper valueForKey:dbTableName withPlistName:kInsertTablesFileName];
   
    [self deleteDateGenId:genId];
//    if (parentGenId && parentGenId.length > 0) {
//        delSql = [NSString stringWithFormat:@"%@ and assetId = ? ", delSql];
//        [delArgumentsMArray addObject:parentGenId];
//    }

    
    return [[WSFMDatebase getInstance] insertWithSql:insertSql withArgumentsInArrays:datas];
}

- (BOOL)insertOrUpdateAcvtDataByGenId:(NSString *)genId storeId:(NSString *)storeId acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId value:(NSString *)value
{
    [self deleteWithNames:@[@"gen_id",@"acvtid",@"acvtqstid"] ArgumentsValue:@[genId,acvtId,acvtQstId]];

    if (value) {
        
        NSMutableArray* qstDatas = [[NSMutableArray alloc] init];
        [qstDatas addObject:storeId ? storeId : @"-1"];
        [qstDatas addObject:acvtId];
        [qstDatas addObject:acvtQstId];
        [qstDatas addObject:value];
        [qstDatas addObject:genId];
        [qstDatas addObject:[NSNull null]];
        [qstDatas addObject:[NSNull null]];
        [qstDatas addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
        [qstDatas addObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]];
        [qstDatas addObject:[NSNull null]];
        [qstDatas addObject:[WSCurrentTime getTimeMillisString]];
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        [qstDatas addObject:[NSString stringNotNilWithValue:model.currentFuncs.ds]];
        
        return [self insertWithArgumentsValue:qstDatas];
    }
    
    return YES;
}

- (NSArray *)queryDatasByGenId:(NSString *)genId
{
    return [self queryWithNames:@[@"gen_id"] ArgumentsValue:@[genId]];
}
- (BOOL)deleteDateGenId:(NSString *)genId
{
    NSString* dbTableName = [WSPlistHelper valueForKey:[self className] withPlistName:kDataBaseMappingFileName];

    NSString *delSql = [NSString  stringWithFormat:@"delete from %@ where %@ = ? ",dbTableName,@"gen_id"];
    
    NSMutableArray *delArgumentsMArray = [[NSMutableArray alloc] initWithObjects:genId, nil];
    
    return  [[WSFMDatebase getInstance] executeUpdateWithSql:delSql withArgumentsInArray:delArgumentsMArray];

}
@end
