//
//  WSBaseEmployeTable.m
//  WinSFA
//
//  Created by weida on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseEmployeTable.h"

@implementation WSBaseEmployeTable


static WSBaseEmployeTable *baseStoreTable = nil;

+ (WSBaseEmployeTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseEmployeTable alloc] init];
        });
    }
    return baseStoreTable;
}

- (NSArray *)queryWithType:(NSString *)type{
    NSArray *filters = nil;
    if ([type rangeOfString:@"@"].location != NSNotFound) {
        filters= [type componentsSeparatedByString:@"@"];
    }else{
        filters = [type componentsSeparatedByString:@","];
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
    /*emp_id 就是WSBaseEmployeeBean的id*/
    NSString *sql = [NSString stringWithFormat:@"select bep.emp_id Id,bep.pid pid,bep.emp_id  emp_id ,bep.name name,bep.emp_type type from base_emp bep where emp_type in %@ and login_emp_id = '%@'",filterStr, [WSAppData getObjectbyKey:APPDATA_EMPID]];
    return [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseEmployeeBean"];
}

@end
