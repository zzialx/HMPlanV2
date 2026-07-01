//
//  WSAddProductTable.m
//  WinSFA
//
//  Created by zhangke on 14/8/14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//


#import "WSAddProductTable.h"

@implementation WSAddProductTable

static WSAddProductTable *addProductTable = nil;

+ (WSAddProductTable *)sharedTable{
    
    if (addProductTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            addProductTable = [[WSAddProductTable alloc] init];
        });
    }
    
    return addProductTable;
}

- (void)cleanOldData
{
    NSString* currentTime = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSArray* whereNames = [NSArray arrayWithObjects:@"upload_flag",@"not biz_date", nil];
    NSArray* whereValues = [NSArray arrayWithObjects:@"1", currentTime, nil];
    
    [self deleteWithNames:whereNames ArgumentsValue:whereValues];
}

- (NSArray*)queryAllProduct
{
    NSString* curtime = [WSCurrentTime getDateString];
    NSString *sql = @"BIZ_DATE";
    
    return [self queryWithNames:@[sql] ArgumentsValue:@[curtime]];
}

- (int)selectMaxID
{
    NSArray* array= [self queryAllProduct];
    return [[array lastObject] ID];
}






@end
