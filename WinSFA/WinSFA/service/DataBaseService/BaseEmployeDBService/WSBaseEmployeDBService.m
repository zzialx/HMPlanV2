//
//  WSBaseEmployeDBService.m
//  WinSFA
//
//  Created by weida on 15/12/29.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseEmployeDBService.h"
#import "WSBaseEmployeTable.h"

#define K_SERVER_NODE  @"server_node"

@implementation WSBaseEmployeDBService

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    WSBaseEmployeTable *table = [WSBaseEmployeTable sharedTable];
    
    if ([dicts count] > 0) {
        //emp表新增了server_node列，老数据的server_node为空，为了清空老数据，清除server_node为空的数据。
        NSString *sql = @"delete from base_emp where server_node is null";
        [table executeUpdateWithSqls:@[sql]];
    }
    
    [table deleteWithNames:@[K_SERVER_NODE] ArgumentsValue:@[nodeName]];
    

    if ([dicts count] > 0) {
        ret = [table batchInsertToTableWithMap:@{@"emp_id":@{kMapKey_serverKey:@"id"},
                                                 @"login_emp_id":@{kMapKey_serverKey:@"empId"},
                                                 @"emp_type":@{kMapKey_serverKey:@"type"},
                                                 K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:dicts];
    }
    
    
    return ret;
}

@end
