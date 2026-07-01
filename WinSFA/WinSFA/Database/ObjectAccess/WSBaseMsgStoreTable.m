//
//  WSBaseMsgStoreTable.m
//  WinSFA
//
//  Created by mac on 2018/11/10.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseMsgStoreTable.h"

@implementation WSBaseMsgStoreTable
static WSBaseMsgStoreTable *baseMsgStoreTable = nil;

+ (WSBaseMsgStoreTable *)sharedTable{
    if (baseMsgStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseMsgStoreTable = [[WSBaseMsgStoreTable alloc] init];
        });
    }
    return baseMsgStoreTable;
}
- (void)cleanOldData
{
    NSString *clearSql = [NSString stringWithFormat:@"DELETE FROM base_msg_store "];
    [self executeUpdateWithSqls:@[clearSql]];
}
@end
