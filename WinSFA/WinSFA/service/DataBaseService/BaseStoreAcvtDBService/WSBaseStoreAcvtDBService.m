//
//  WSBaseStoreAcvtDBService.m
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseStoreAcvtDBService.h"
#import "WSBaseStoreAcvtTable.h"

#import "WSBaseStoreAcvtTable.h"// 店和调查问卷关系表

#import "WSBaseAcvtTable.h"// 调查问卷表
#define K_SERVER_NODE  (@"server_node")

@implementation WSBaseStoreAcvtDBService

/**
 *  @author weida
 *
 *  @brief 将arr数组内容覆盖到表中(先清空表内所有数据，再插入)，请谨慎使用
 *    一般在登录时使用(重写父类方法)
 *  @param arr 字典数组(store_acvt)
 *
 *  @return 成功返回TRUE，失败返回FALSE
 */


- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID
{
    BOOL ret = FALSE;
    WSBaseStoreAcvtTable *table = [WSBaseStoreAcvtTable sharedTable];//获取数据表
    
    
    NSString *sql = @"delete from base_store_acvt where server_node is null";
    [table executeUpdateWithSqls:@[sql]];
   
    /**
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
        ret = [table  batchInsertToTableWithMap:@{K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:dicts];//插入数据库中
    }
     */
    
    //优化---2018-12-11 zhangmin 改用下面的逻辑
    //base_store_acvt表没有主键，可以重复插入数据， 改为：先全部插入，再删除重复的数据
    ret = [table  batchInsertToTableWithMap:@{K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}} Dicts:dicts];//插入数据库中
    //删除重复多余数据
    NSString *deleteRepeatSql = @"delete from base_store_acvt where _id not in(select max(_id) from base_store_acvt group by sid,acvtId)";
    [table executeUpdateWithSqls:@[deleteRepeatSql]];
    
    return ret;
}

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts withStoreId:(NSString *)storeID
{
    BOOL ret = FALSE;
    WSBaseStoreAcvtTable *table = [WSBaseStoreAcvtTable sharedTable];//获取数据表
    NSString* dbTableName=[WSPlistHelper valueForKey:[table className] withPlistName:kDataBaseMappingFileName];//表名

    if (dicts.count > 0) {
        NSMutableArray * names = [NSMutableArray arrayWithCapacity:dicts.count];
        NSMutableArray * values = [NSMutableArray arrayWithCapacity:dicts.count];
        NSMutableArray * valuesArray = [NSMutableArray arrayWithCapacity:dicts.count];
        for (NSDictionary*dict in dicts){
            [names addObject:@"sid"];
            [values addObject:dict[@"sid"]];
            [names addObject:@"acvtId"];
            [values addObject:dict[@"acvtId"]];
            ret = [table deleteWithNames:names ArgumentsValue:values];
            NSString * sql = [NSString stringWithFormat: @"insert into %@ (sid,acvtId) VALUES (%@,%@)",dbTableName,dict[@"sid"],dict[@"acvtId"]];
            [valuesArray addObject:sql];
            [names removeAllObjects];
            [values removeAllObjects];
        }
        if (ret) {
            ret =  [table insertWithSqls:valuesArray];
        }
    }
    
    return ret;
}


@end
