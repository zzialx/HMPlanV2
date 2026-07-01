//
//  WSVisitStorePlanTable.m
//  WinSFA
//
//  Created by zhangke on 14-5-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSVisitStorePlanTable.h"


@implementation WSVisitStorePlanTable

static WSVisitStorePlanTable *visitStorePlanTable = nil;

+ (WSVisitStorePlanTable *)sharedTable
{
    if (visitStorePlanTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            visitStorePlanTable = [[WSVisitStorePlanTable alloc] init];
        });
    }
    
    return visitStorePlanTable;
}

- (void)insertVisitStorePlanWithDic:(NSDictionary *)valueDic
{
    NSString *storeids = [NSString stringWithValue:[valueDic valueForKey:@"storeids"]];
    NSString *date = [NSString stringWithValue:[valueDic valueForKey:@"date"]];
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    if([[self queryVisitStorePlanByDate:date] count]>0){
        
        NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid", nil];
        NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid], nil];
        NSArray *N=[NSArray arrayWithObjects:@"storeids", nil];
        NSArray *V=[NSArray arrayWithObjects:storeids, nil];
        
        [self updateWithNames:N values:V whereName:whereN whereValue:whereV];
        
    }else{
        NSMutableArray *aValArray = [[NSMutableArray alloc] init];
        
        [aValArray addObject:(storeids != nil) ? storeids : [NSNull null]];
        [aValArray addObject:(date != nil) ? date : [NSNull null]];
        [aValArray addObject:empid];
        
        [aValArray addObject:[NSNull null]];
        [aValArray addObject:[NSNull null]];
        [aValArray addObject:[NSNull null]];
        [self insertWithArgumentsValue:aValArray];
    }
}

- (void)insertVisitStorePlanWithStoreInfoDic:(NSDictionary *)infoDic{

    NSString *doc_date = [infoDic objectForKey:@"doc_date"];
    NSString *storeId = [NSString stringNotNilWithValue:[infoDic objectForKey:@"store_id"]];
    NSString *state = [NSString stringNotNilWithValue:[infoDic objectForKey:@"state"]];
    NSString *stateUrl = [NSString stringNotNilWithValue:[infoDic objectForKey:@"stateUrl"]];
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    if([[self queryVisitStorePlanByDate:doc_date withStoreId:storeId] count]>0){
        
        NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid",@"storeId", nil];
        NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:doc_date], [NSString stringNotNilWithValue:empid], [NSString stringNotNilWithValue:storeId], nil];
        NSArray *N=[NSArray arrayWithObjects:@"storestate",@"storestateurl" ,nil];
        NSArray *V=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:state],[NSString stringNotNilWithValue:stateUrl], nil];
        
        [self updateWithNames:N values:V whereName:whereN whereValue:whereV];
        
    }else{
        NSMutableArray *aValArray = [[NSMutableArray alloc] init];
        [aValArray addObject:[NSNull null]];
        [aValArray addObject:(doc_date != nil) ? doc_date : [NSNull null]];
        [aValArray addObject:empid];
        [aValArray addObject:(storeId != nil) ? storeId : [NSNull null]];
        [aValArray addObject:(state != nil) ? state : [NSNull null]];
        [aValArray addObject:(stateUrl != nil) ? stateUrl : [NSNull null]];
        [self insertWithArgumentsValue:aValArray];
    }
    
}

- (BOOL)batchInsertVisitStorePlanWithStoreInfoArray:(NSArray *)array {
    
    if (!array || array.count == 0) {
        return YES;
    }
    
    NSArray *dateArray = [array valueForKeyPath:@"@distinctUnionOfObjects.doc_date"];
    
    if (dateArray.count) {
        [self batchDeleteFromTableWithNames:@[@"date"] ArgumentsValues:@[dateArray]];
    }
    
    return [[WSVisitStorePlanTable sharedTable] batchInsertToTableWithMap:@{@"DATE":@{kMapKey_serverKey:@"doc_date"},
                                                                            @"storeid":@{kMapKey_serverKey:@"store_id"},
                                                                            @"storestate":@{kMapKey_serverKey:@"state"},
                                                                            @"storestateurl":@{kMapKey_serverKey:@"stateUrl"},
                                                                            @"EMPID":@{kMapKey_placeHolder:[WSAppData getObjectbyKey:APPDATA_EMPID]}} Dicts:array];
    
}

- (NSArray *)queryVisitStorePlanByDate:(NSString*)date
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid], nil];
    
    return [self queryWithNames:whereN ArgumentsValue:whereV];
}

- (NSArray *)queryVisitStorePlanByDate:(NSString *)date withStoreId:(NSString *)storeId{

    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid",@"storeId", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid],  [NSString stringNotNilWithValue:storeId],nil];
    
    return [self queryWithNames:whereN ArgumentsValue:whereV];
}

- (NSInteger)queryVisitStorePlanCountByDate:(NSString *)date withStoreIds:(NSString *)storeIds
{
    
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSArray *names=[NSArray arrayWithObjects:@"date",@"empid", nil];
    NSArray *values=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid],nil];
    
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
//    SFA-27600  董宏
    query=[query stringByAppendingFormat:@" and storeid in (%@)", storeIds];
    
    NSInteger count = 0;
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:query withArgumentsInArray:filteredValues];
    while ([rs next]) {
        count = [rs intForColumnIndex:0];
    }
    return count;
}

- (void)deletVisitStorePlanWithByDate:(NSString *)date withStoreId:(NSString *)storeId{
    
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid",@"storeId", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid], [NSString stringNotNilWithValue:storeId], nil];
    [self deleteWithNames:whereN ArgumentsValue:whereV];
}

- (void)deletVisitStorePlanWithByDate:(NSString *)date{
    
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSArray *whereN=[NSArray arrayWithObjects:@"date",@"empid", nil];
    NSArray *whereV=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:date], [NSString stringNotNilWithValue:empid], nil];
    [self deleteWithNames:whereN ArgumentsValue:whereV];
}
@end
