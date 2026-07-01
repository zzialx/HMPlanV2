//
//  WSBaseStoreDistruleDBService.m
//  WinSFA
//
//  Created by yang on 17/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDistruleDBService.h"
#import "WSBaseStoreDistruleTable.h"


#define K_SERVER_NODE  (@"server_node")

@implementation WSBaseStoreDistruleDBService

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    BOOL ret = NO;
    
    WSBaseStoreDistruleTable *table = [WSBaseStoreDistruleTable sharedTable];//获取数据表
    
    NSArray *names;
    NSArray *values;
    
    if ([storeID length] > 0) {
        if ([dicts count] > 0) {
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
        
    if (ret && [dicts count] > 0)
    {
        ret = [table  batchInsertToTableWithMap:@{K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:dicts];//插入数据库中
    }
    
    return ret;
}

- (NSArray *)queryDrIdByStoreId:(NSString *)storeId
{
    NSString *sql = [NSString stringWithFormat:@"select drId from base_store_distrule where sid = '%@'", storeId];
    
    NSArray *data = [[WSBaseStoreDistruleTable sharedTable] queryDicDatasBySql:sql argumentsValues:nil];
    
    NSArray *resultArray = nil;
    
    if ([data count] > 0) {
        resultArray = [data valueForKey:@"drId"];
    }
    
    return resultArray;
}

@end
