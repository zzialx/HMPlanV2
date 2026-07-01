//
//  WSBaseDictsTable.m
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseDictsTable.h"

@implementation WSBaseDictsTable

static WSBaseDictsTable *baseStoreTable = nil;

+ (WSBaseDictsTable *)sharedTable{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseStoreTable = [[WSBaseDictsTable alloc] init];
    });
    return baseStoreTable;
}

- (NSArray *)queryWithFilter:(NSString *)qstFilter value:(NSString *)qstRedisValue {
    NSArray *filters = nil;
    if ([qstFilter rangeOfString:@"@"].location != NSNotFound) {
        filters= [qstFilter componentsSeparatedByString:@"@"];
    }else{
        filters = [qstFilter componentsSeparatedByString:@","];
    }
    NSString *filterStr = @" (";
    for (NSInteger i = 0; i < [filters count]; i++) {
        if (i == 0) {
            filterStr = [filterStr stringByAppendingFormat:@"'%@'",filters[i]];
        }else {
            filterStr = [filterStr stringByAppendingFormat:@",'%@'",filters[i]];
        }
    }
    filterStr = [filterStr stringByAppendingString:@")"];
    NSString *sql = [NSString stringWithFormat:@"select * from base_dicts where typ in %@ and _id = '%@'",filterStr,qstRedisValue];
    return [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseDictObject"];
}


@end
