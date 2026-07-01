//
//  WSBaseMsgStoreDBService.m
//  WinSFA
//
//  Created by mac on 2018/11/10.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseMsgStoreDBService.h"
#import "WSBaseMsgStoreTable.h"

@implementation WSBaseMsgStoreDBService
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    
    WSBaseMsgStoreTable *table = [WSBaseMsgStoreTable sharedTable];//获取数据表

    [table cleanOldData];
    
    ret = [table  batchInsertToTableWithMap:@{@"store_id":@{kMapKey_serverKey:@"sid"},@"msg_id":@{kMapKey_serverKey:@"MESS_ID"}} Dicts:dicts];//插入数据库中
    
    return ret;
}
//SFA-25570 董宏
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    BOOL ret = FALSE;
    WSBaseMsgStoreTable *table = [WSBaseMsgStoreTable sharedTable];//获取数据表
    NSString *sql = [NSString stringWithFormat:@"delete from base_store_acvt where store_id = '%@'",storeID];
    [table executeUpdateWithSqls:@[sql]];
    
    ret = [table  batchInsertToTableWithMap:@{@"store_id":@{kMapKey_serverKey:@"sid"},@"msg_id":@{kMapKey_serverKey:@"MESS_ID"}} Dicts:dicts];//插入数据库中

    return ret;
}

@end
