//
//  WSBaseMsgTypeDBService.m
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseMsgTypeDBService.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgStoreTable.h"

#define kBaseMsgTypeKey_id        (@"_id")
#define kBaseMsgTypeKey_msg       (@"msg")

@implementation WSBaseMsgTypeDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    
    WSBaseMsgTypeTable *table = [WSBaseMsgTypeTable sharedTable];
    
    [table deleteAll];
    
    [table batchInsertToTableWithMap:@{kBaseMsgTypeKey_id:@{kMapKey_serverKey:@"id"}} Dicts:dicts];//批量插入
    
    NSMutableArray *msgsArry = @[].mutableCopy;
    
    for (NSDictionary*dict in dicts)
    {//找到里面所有的消息内容
        NSArray *msg = dict[kBaseMsgTypeKey_msg];
        if ([msg isKindOfClass:[NSArray class]] && msg.count)
        {
            [msgsArry addObjectsFromArray:msg];
        }
    }
    
    WSBaseMsgTable *msgTable = [WSBaseMsgTable sharedTable];
    
    [msgTable deleteAll];
    
    // MSTD-7490
    NSArray *datas = [self addPinyinFromField:@"title" toDicts:msgsArry];
    
    
    NSMutableArray *muDicts = [NSMutableArray array];
    int i = 0;
    for (NSDictionary *dict in datas) {
        NSMutableDictionary *muDict = [dict mutableCopy];
        NSString *seq;
        if (seq.length == 0) {
            [muDict setObject:@(i) forKey:@"seq"];
            i++;
        }
        [muDicts addObject:muDict];
    }
    
    
    [msgTable batchInsertToTableWithMap:@{@"_id":@{kMapKey_serverKey:@"id"},
                                          @"sound_url":@{kMapKey_serverKey:@"v_url"}} Dicts:muDicts];
    
    return ret;
}

-(NSInteger)queryMsgCountByCod:(NSString *)filter{
    if (!filter) {
        return 0;
    }
    NSString * sql = [NSString stringWithFormat:@"select * from base_msg left join base_msg_type on base_msg.pid = base_msg_type._id where base_msg_type.cod = '%@' ",filter];
    return [[WSBaseMsgTypeTable sharedTable] queryCountWithSql:sql] ;
}
- (BOOL)updateMsgStoreTable:(NSArray*)storemsgList storeId:(NSString*)storeId{
    BOOL ret = FALSE;
    
    WSBaseMsgStoreTable *table = [WSBaseMsgStoreTable sharedTable];
    NSString *sql = [NSString stringWithFormat:@"delete from base_msg_store where store_id = '%@'",storeId];
    [table executeUpdateWithSqls:@[sql]];
    
    [table  batchInsertToTableWithMap:@{@"store_id":@{kMapKey_serverKey:@"sid"},@"msg_id":@{kMapKey_serverKey:@"MESS_ID"}} Dicts:storemsgList];
    
    return ret;
}

@end
