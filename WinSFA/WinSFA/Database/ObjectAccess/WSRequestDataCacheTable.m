//
//  WSRequestDataCacheTable.m
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-1.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSRequestDataCacheTable.h"
#import "WSAppData.h"



@implementation WSRequestDataCacheTable

static WSRequestDataCacheTable *sharedCacheTable = nil;
+ (WSRequestDataCacheTable *)sharedTable {
    @synchronized(self) {
        if (sharedCacheTable == nil) {
            sharedCacheTable = [[[self class] alloc] init];
        }
    }
    return sharedCacheTable;
}

- (void)cleanOldData
{
    NSArray *whereNames=[NSArray arrayWithObjects:@"emp_id", @"not biz_date", nil];
    NSArray *whereValues=[NSArray arrayWithObjects:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]], [NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]], nil];
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (NSArray *)queryWithObject:(WSRequestDataCacheObject *)aObject {
    NSArray *whereNameArray = [[self getActionObjectNamesAndValuesArray:aObject] firstObject];
    NSArray *whereValueArray = [[self getActionObjectNamesAndValuesArray:aObject] lastObject];
    
    return  [self queryWithNames:whereNameArray ArgumentsValue:whereValueArray];
}

- (void)insertWithObject:(WSRequestDataCacheObject *)aObject {
    if (aObject == nil) {
        return;
    }
    NSMutableArray *aValArray = [[NSMutableArray alloc] init];
    NSString *emp_Id = aObject.emp_Id;
    NSString *biz_date = aObject.biz_date;
    NSString *data_md5 = aObject.data_md5;
    NSString *data = aObject.data;
    NSString *reserve0 = aObject.reserve0;
    NSString *reserve1 = aObject.reserve1;
    NSString *reserve2 = aObject.reserve2;
    NSString *reserve3 = aObject.reserve3;
    NSString *reserve4 = aObject.reserve4;
    NSString *reserve5 = aObject.reserve5;
    NSString *reserve6 = aObject.reserve6;
    NSString *reserve7 = aObject.reserve7;
    NSString *reserve8 = aObject.reserve8;
    NSString *reserve9 = aObject.reserve9;
    
    [aValArray addObject:(emp_Id != nil) ? emp_Id : [NSNull null]];
    [aValArray addObject:(biz_date != nil) ? biz_date : [NSNull null]];
    [aValArray addObject:(data_md5 != nil) ? data_md5 : [NSNull null]];
    [aValArray addObject:(data != nil) ? data : [NSNull null]];
    [aValArray addObject:(reserve0 != nil) ? reserve0 : [NSNull null]];
    [aValArray addObject:(reserve1 != nil) ? reserve1 : [NSNull null]];
    [aValArray addObject:(reserve2 != nil) ? reserve2 : [NSNull null]];
    [aValArray addObject:(reserve3 != nil) ? reserve3 : [NSNull null]];
    [aValArray addObject:(reserve4 != nil) ? reserve4 : [NSNull null]];
    [aValArray addObject:(reserve5 != nil) ? reserve5 : [NSNull null]];
    [aValArray addObject:(reserve6 != nil) ? reserve6 : [NSNull null]];
    [aValArray addObject:(reserve7 != nil) ? reserve7 : [NSNull null]];
    [aValArray addObject:(reserve8 != nil) ? reserve8 : [NSNull null]];
    [aValArray addObject:(reserve9 != nil) ? reserve9 : [NSNull null]];
    
    [self insertWithArgumentsValue:aValArray];
}

- (NSArray *)getActionObjectNamesAndValuesArray:(WSRequestDataCacheObject *)aObject {
    NSMutableArray *namesAndValuesArray = [[NSMutableArray alloc] init];
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    if (aObject.ID) {
        [nameArray addObject:@"id"];
        [valueArray addObject:[NSString stringWithFormat:@"%d",aObject.ID]];
    }
    if (aObject.emp_Id != nil) {
        [nameArray addObject:@"emp_Id"];
        [valueArray addObject:aObject.emp_Id];
    }
    if (aObject.biz_date != nil) {
        [nameArray addObject:@"biz_date"];
        [valueArray addObject:aObject.biz_date];
    }
    if (aObject.data_md5 != nil) {
        [nameArray addObject:@"data_md5"];
        [valueArray addObject:aObject.data_md5];
    }
    if (aObject.data != nil) {
        [nameArray addObject:@"data"];
        [valueArray addObject:aObject.data];
    }
    if (aObject.reserve0 != nil) {
        [nameArray addObject:@"reserve0"];
        [valueArray addObject:aObject.reserve0];
    }
    if (aObject.reserve1 != nil) {
        [nameArray addObject:@"reserve1"];
        [valueArray addObject:aObject.reserve1];
    }
    if (aObject.reserve2 != nil) {
        [nameArray addObject:@"reserve2"];
        [valueArray addObject:aObject.reserve2];
    }
    if (aObject.reserve3 != nil) {
        [nameArray addObject:@"reserve3"];
        [valueArray addObject:aObject.reserve3];
    }
    if (aObject.reserve4 != nil) {
        [nameArray addObject:@"reserve4"];
        [valueArray addObject:aObject.reserve4];
    }
    if (aObject.reserve5 != nil) {
        [nameArray addObject:@"reserve5"];
        [valueArray addObject:aObject.reserve5];
    }
    if (aObject.reserve6 != nil) {
        [nameArray addObject:@"reserve6"];
        [valueArray addObject:aObject.reserve6];
    }
    if (aObject.reserve7 != nil) {
        [nameArray addObject:@"reserve7"];
        [valueArray addObject:aObject.reserve7];
    }
    if (aObject.reserve8 != nil) {
        [nameArray addObject:@"reserve8"];
        [valueArray addObject:aObject.reserve8];
    }
    if (aObject.reserve9 != nil) {
        [nameArray addObject:@"reserve9"];
        [valueArray addObject:aObject.reserve9];
    }
    [namesAndValuesArray addObject:nameArray];
    [namesAndValuesArray addObject:valueArray];
    return namesAndValuesArray;
}




@end
