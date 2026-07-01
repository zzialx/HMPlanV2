//
//  WSBaseStoreDataTable.m
//  WinSFA
//
//  Created by zhangke on 14/8/31.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//


#import "WSBaseStoreDataTable.h"

@implementation WSBaseStoreDataTable

static WSBaseStoreDataTable *addStoreTable=nil;
+ (WSBaseStoreDataTable *)sharedTable
{
    if (addStoreTable==nil) {
        
        addStoreTable= [[WSBaseStoreDataTable alloc]init];
    }
    return  addStoreTable;
}


- (void)cleanOldData
{
    NSString *currenTime=[WSAppData getObjectbyKey:APPDATA_BIZDATE];
    
    NSArray *whereNames=[NSArray arrayWithObjects:@"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:currenTime, nil];
    
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}


- (NSArray *)queryWithEmpId:(NSString *)aEmpId withAcvtId:(NSString *)aAcvtId withBizDate:(NSString *)aBizDate
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSCurrentTime getDateString];
    
   return  [self queryWithNames:@[@"emp_id",@"store_id",@"biz_date"] ArgumentsValue:@[empid,aAcvtId,bizDate]];
}

- (void)deleteWithAcvtId:(NSString *)aAcvtId
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSCurrentTime getDateString];
    
    [self deleteWithNames:@[@"emp_id",@"store_id",@"biz_date"] ArgumentsValue:@[empid,aAcvtId,bizDate]];
}

- (void)insertWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andITEM:(NSString *)aItem
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSCurrentTime getDateString];
    
    [self insertWithArgumentsValue:@[empid, aAcvtId, aType, [NSString stringNotNilWithValue:aItem],@"",@"",@"",@"",@"",@"",@"",@"",@"",bizDate]];
}

- (void)InsertTableEvaluatePersonWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andEvaluateResult:(NSDictionary *)aResult
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSCurrentTime getDateString];
    
    [aResult enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *personid = [dic objectForKey:@"id"]; // item1
        NSString *name = [dic objectForKey:@"name"]; // item2
        NSString *typ = [dic objectForKey:@"typ"]; // item3
        NSNumber *isRequired = [dic objectForKey:@"isMustRequried"]; // item4
        NSString *strIsRequired = ([isRequired boolValue]) ? @"1" : @"0";
        NSString *brandTrendId = [dic objectForKey:@"brandTrendId"]; // item5
        NSString *speechLevelId = [dic objectForKey:@"speechLevelId"]; // item 6
        NSString *acvtId = [dic objectForKey:@"acvtId"]; // item7
        
        [self insertWithArgumentsValue:@[empid,aAcvtId, aType, personid, name, typ, strIsRequired, brandTrendId, speechLevelId, acvtId, @"", @"", @"", bizDate]];
    }];
}

- (void)insertTableMeetingPersonSqlWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andMeetingPersons:(NSArray *)aPersons
{
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *bizDate = [WSCurrentTime getDateString];
    
    [aPersons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSNumber *pid = [dic objectForKey:@"id"];
        NSString *personid = [NSString stringWithValue: pid];
        NSString *name = [dic objectForKey:@"name"]; // item2
        NSString *typ = [dic objectForKey:@"typ"]; // item3
        NSString *acvtId = aAcvtId; // item4
        [self insertWithArgumentsValue:@[empid,aAcvtId, aType, personid, name, typ, acvtId, @"", @"", @"", @"", @"", @"", bizDate]];
    }];
}




@end
