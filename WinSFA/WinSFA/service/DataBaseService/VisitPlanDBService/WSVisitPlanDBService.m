//
//  WSVisitPlanDBService.m
//  WinSFA
//
//  Created by heju on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisitPlanDBService.h"

#import "WSBaseStoreVisitPlanTable.h"

#define K_STORE_ID (@"store_id")
#define K_EMP_ID (@"emp_id")
#define K_BIZE_DATE (@"biz_date")
#define K_SEQ (@"seq")

#define K_SRID (@"")

@implementation WSVisitPlanDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData {
    
    
    NSMutableArray *muDicts = [NSMutableArray array];
    int i = 0;
    for (NSDictionary *dict in dicts) {
        NSMutableDictionary *muDict = [dict mutableCopy];
        NSString *srId = [NSString stringNotNilWithValue:dict[@"srId"]];
        if ([srId length] > 0) {
            muDict[@"empId"] = srId;
        }
        NSString * seq = [NSString stringNotNilWithValue:dict[K_SEQ]];
        if (seq.length == 0) {
            [muDict setObject:@(i) forKey:@"seq"];
            i++;
        }
        [muDicts addObject:muDict];
    }

    WSBaseStoreVisitPlanTable *visitPlanTable = [WSBaseStoreVisitPlanTable sharedTable];
    
    [visitPlanTable deleteAll];
    
    BOOL ret = [visitPlanTable batchInsertToTableWithMap:@{K_STORE_ID:@{kMapKey_serverKey:@"sId"},K_EMP_ID:@{kMapKey_serverKey:@"empId"},K_BIZE_DATE:@{kMapKey_serverKey:@"next"},K_SEQ:@{kMapKey_serverKey:@"seq"} } Dicts:muDicts];
    return ret;
}

@end
