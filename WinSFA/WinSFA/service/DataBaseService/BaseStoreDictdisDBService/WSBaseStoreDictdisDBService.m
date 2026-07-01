//
//  WSBaseStoreDictdisDBService.m
//  WinSFA
//
//  Created by heju on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseStoreDictdisDBService.h"
#import "WSBaseStoreDictDisTable.h"

#define K_DICT_ID (@"dict_id")
#define K_SERVER_NODE (@"server_node")
#define K_P_DEFAULT_LENGTH 11

@implementation WSBaseStoreDictdisDBService

- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId{
    
    WSBaseStoreDictDisTable *dictdisTable = [WSBaseStoreDictDisTable sharedTable];
    NSArray *ps = [dicts valueForKey:@"p"];
    NSArray *empIds = [dicts valueForKey:@"empId"];
    NSArray *genIds = [dicts valueForKey:@"gen_id"];
    
    NSMutableArray *dictIds = [NSMutableArray arrayWithCapacity:ps.count];
    NSMutableArray *dictdiss = [NSMutableArray arrayWithCapacity:ps.count];
    for (NSInteger i = 0; i < [ps count]; i++)
    {
        NSMutableDictionary *dictdis = [NSMutableDictionary dictionary];
        NSString *p_str = ps[i];
        
        if (![p_str isKindOfClass:[NSString class]])
            continue;
        
        NSArray *p_compoents = [p_str componentsSeparatedByString:@","];
        if ([p_compoents count] >= K_P_DEFAULT_LENGTH)
        {
            NSString *empId = @"";
            if (i < [empIds count])
                empId = empIds[i];
            
            NSString *gen_Id = @"";
            if (i < [genIds count])
                gen_Id = genIds[i];
            
            NSString *store_id = [p_compoents firstObject];
            NSString *dictIdAndFunccode = p_compoents [1];
            NSArray *id_code_components = [dictIdAndFunccode componentsSeparatedByString:@"@"];
            NSString *dict_id = [id_code_components firstObject];
            [dictIds addObject:dict_id];
            
            NSString *func_code = [id_code_components lastObject];
            
            for (int i = 2; i < p_compoents.count; i ++)
                [dictdis setObject:p_compoents[i] forKey:[NSString stringWithFormat:@"col%d", i - 1]];
            
            [dictdis setObject:empId forKey:@"emp_id"];
            [dictdis setObject:store_id forKey:@"store_id"];
            [dictdis setObject:func_code forKey:@"func_code"];
            [dictdis setObject:dict_id forKey:@"dict_id"];
            [dictdis setObject:gen_Id forKey:@"assetId"];
            
            [dictdiss addObject:dictdis];
        }
    }
    
    if ([storeID length] > 0)
    {
        if ([dictdiss count] > 0)
            [dictdisTable batchDeleteFromTableWithNames:@[@"store_id",K_SERVER_NODE] ArgumentsValues:@[@[storeID],@[nodeName]]];
    }
    else
    {
        if ([dictdiss count] > 0)
            [dictdisTable batchDeleteFromTableWithNames:@[K_SERVER_NODE] ArgumentsValues:@[@[nodeName]]];
    }
    
    if ([dictdiss count] > 0)
        return [dictdisTable batchInsertToTableWithMap:@{K_DICT_ID:@{K_SERVER_NODE:@"dict_id"},
                                                         K_SERVER_NODE:@{kMapKey_placeHolder:nodeName}}  Dicts:dictdiss];
    
    return YES;
}

#pragma mark - 查询门店字典项回显方法 genID:唯一标示 storeId:门店id dictIds:需要查询字典项的id组
- (NSArray *)queryStoreDictdisWithGenId:(NSString *)genID storeId:(NSString *)storeId dictIds:(NSString *)dictIds
{
    NSString *sql = [NSString stringWithFormat:@"select * from base_store_dict_dis bsdd where"];
    if (genID.length > 0)
        sql = [NSString stringWithFormat:@"%@ bsdd.assetId = '%@'", sql, genID];
    
    if (storeId.length > 0)
    {
        if (genID.length <= 0)
            sql = [NSString stringWithFormat:@"%@ bsdd.store_id = '%@'", sql, storeId];
        else
            sql = [NSString stringWithFormat:@"%@ and bsdd.store_id = '%@'", sql, storeId];
    }
    
    if (dictIds.length > 0)
    {
        if (genID.length <= 0 && storeId.length <= 0)
            sql = [NSString stringWithFormat:@"%@ bsdd.dict_id in ( %@ )", sql, dictIds];
        else
            sql = [NSString stringWithFormat:@"%@ and bsdd.dict_id in ( %@ )", sql, dictIds];
    }
    
    return [[WSBaseStoreDictDisTable sharedTable] queryAndReturnInfosBySql:sql andClassName:@"WSBaseStoreDictDisObject"];
}

@end
