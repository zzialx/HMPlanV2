//
//  WSRichMediaOtherInfoTable.m
//  WinSFA
//
//  Created by yang on 17/1/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSRichMediaOtherInfoTable.h"


static WSRichMediaOtherInfoTable *baseStoreTable = nil;

@implementation WSRichMediaOtherInfoTable

+ (WSRichMediaOtherInfoTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSRichMediaOtherInfoTable alloc] init];
        });
    }
    return baseStoreTable;
}

- (void)cleanOldData
{
    NSArray *whereNames = [NSArray arrayWithObjects:@"emp_id", @"not biz_date", nil];
    NSArray *whereValues = [NSArray arrayWithObjects:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (BOOL)insertClickTimeWithStoreId:(NSString *)storeId richMediaId:(NSString *)richMediaId clickTime:(NSString *)clickTime
{
    if (!storeId || !richMediaId || !clickTime ) {
        return NO;
    }
    
    return [self insertWithArgumentsValue:@[storeId, richMediaId, clickTime, [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]]];
}

- (NSString *)getClickTimeWithStoreId:(NSString *)storeId richMediaId:(NSString *)richMediaId {
    
    NSString *sql = [NSString stringWithFormat:@"select click_time from spe_richMedia_otherinfo where sid = '%@' and speid = '%@' and biz_date = '%@' and emp_id = '%@'", storeId, richMediaId, [WSAppData getObjectbyKey:APPDATA_BIZDATE], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]]];
    
    NSArray *data = [self queryDicDatasBySql:sql argumentsValues:nil];
    
    NSDictionary *dic = [data firstObject];
    
    return dic[@"click_time"];
}

//- (NSArray *)getMediaInfoArrayWithStoreId:(NSString *)storeId {
//    
//    if (!storeId || [storeId length] == 0) {
//        return nil;
//    }
//    
//    NSString *sql = [NSString stringWithFormat:@"select * from spe_richMedia_otherinfo where sid = '%@' and biz_date = '%@' and ", storeId];
//    
//    return [self queryAndReturnInfosBySql:sql andClassName:@"WSRichMediaOtherInfo"];
//    
//}


@end
