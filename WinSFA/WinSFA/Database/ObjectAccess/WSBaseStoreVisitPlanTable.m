//
//  WSBaseStoreVisitPlanTable.m
//  WinSFA
//
//  Created by heju on 15/9/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreVisitPlanTable.h"

@implementation WSBaseStoreVisitPlanTable

static WSBaseStoreVisitPlanTable *baseStoreVisitPlanTable = nil;

+ (WSBaseStoreVisitPlanTable *)sharedTable{
    if (baseStoreVisitPlanTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreVisitPlanTable = [[self alloc] init];
        });
    }
    return baseStoreVisitPlanTable;
}

- (void)cleanOldData
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"emp_id", @"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (void)insertStoreVisitPlansWith:(NSArray *)plans {
    if (!plans) {
        NSLog(@"plans  is  nil !!!");
        return;
    }
    
    /*
    [plans enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertVisitPlanWith:(NSDictionary *)obj];
    }];
     */
}

- (void)insertVisitPlanWith:(NSDictionary *)planDictionary {
    NSString *emp_id = [NSString stringNotNilWithValue:[planDictionary objectForKey:@"emp_id"]];
    NSString *store_id = [NSString stringNotNilWithValue:[planDictionary objectForKey:@"store_id"]];
    NSString *biz_date = [NSString stringNotNilWithValue:[planDictionary objectForKey:@"biz_date"]];
    NSString *seq = [NSString stringNotNilWithValue:[planDictionary objectForKey:@"seq"]];
    if(seq==nil){
        seq=@"";
    }
    [self insertWithArgumentsValue:[NSArray arrayWithObjects:emp_id,store_id,biz_date,seq,nil]];
}

@end
