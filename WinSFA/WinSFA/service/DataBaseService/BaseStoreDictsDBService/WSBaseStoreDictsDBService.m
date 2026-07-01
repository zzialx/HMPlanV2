//
//  WSBaseStoreDictsDBService.m
//  WinSFA
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDictsDBService.h"
#import "WSBaseStoreDictsTable.h"

#define K_MEMO         (@"memo")

#define K_SERVER_NODE  (@"server_node")


@implementation WSBaseStoreDictsDBService
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    BOOL ret = FALSE;
    WSBaseStoreDictsTable *table = [WSBaseStoreDictsTable sharedTable];//获取数据表
    
    
    NSString *sql = @"delete from base_store_dicts where server_node is null";
    [table executeUpdateWithSqls:@[sql]];
    
    NSArray *names;
    NSArray *values;
    
    if ([storeID length] > 0) {
        if ([dicts isKindOfClass:[NSArray class]] && [dicts count] > 0) {
            names = @[K_SERVER_NODE,@"sid"];
            values = @[nodeName,storeID];
        }
    }else {
        names = @[K_SERVER_NODE];
        values = @[nodeName];
    }
    
    if ([names count] > 0) {
        ret = [table deleteWithNames:names ArgumentsValue:values];
    }
    
    if (ret && [dicts isKindOfClass:[NSArray class]] && [dicts count] > 0)
    {
        ret = [table  batchInsertToTableWithMap:@{
            K_SERVER_NODE:@{kMapKey_placeHolder:nodeName},
            K_MEMO:@{kMapKey_serverKey:@"memo"}
        } Dicts:dicts];//插入数据库中

    }
    
    return ret;
}

@end
