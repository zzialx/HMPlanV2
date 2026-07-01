//
//  WSBaseStoreInfoDBService.m
//  WinSFA
//
//  Created by HZH on 2017/11/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseStoreInfoDBService.h"
#import "WSBaseStoreInfoTable.h"

#define kbaseFunKey_spec        (@"spec")

@implementation WSBaseStoreInfoDBService

static WSBaseStoreInfoDBService *baseStoreInfoDBService;

+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    if (baseStoreInfoDBService == nil) {
        dispatch_once(&onceToken, ^{
            baseStoreInfoDBService = [[self alloc] init];
        });
    }
    return baseStoreInfoDBService;
}

-(BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData
{
    BOOL ret = FALSE;
    WSBaseStoreInfoTable *table = [WSBaseStoreInfoTable sharedTable];
    NSMutableArray *mutableArry = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary *dict in dicts)
    {

        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        for (NSString *keyStr in dict.allKeys) {
            if ([keyStr hasPrefix:@"col"]) {
                [mDic setObject:keyStr forKey:@"col_name"];
                [mDic setObject:[dict objectForKey:keyStr] forKey:@"col_value"];
                [mDic removeObjectForKey:keyStr];
            }
        }
            [mutableArry addObject:mDic];
    }
    
    [table deleteAll];
    
    ret = [table batchInsertToTableWithMap:@{@"_id":@{kMapKey_autoIncrement:@1},@"emp_or_store_id":@{kMapKey_serverKey:@"storeId"}} Dicts:mutableArry];
    
    return ret;
    
}

- (WSStoreInfoBean *)queryStoreInfoByStoreId:(NSString *)storeId andType:(NSString *)type
{
    WSSqliteUtil *sqliteUtil = [[WSSqliteUtil alloc] init];
    NSString * sql =[NSString stringWithFormat:@"select storeInfo._id  Id, storeInfo.info_type, storeInfo.col_name, storeInfo.col_value, storeInfo.typ, storeInfo.emp_or_store_id,storeInfo.group_id,storeInfo.empId from base_store_info storeInfo where storeInfo.emp_or_store_id = '%@' and storeInfo.typ = '%@'", storeId, type];
    
    return  [[sqliteUtil queryAndReturnInfosBySql:sql andClassName:@"WSStoreInfoBean"] firstObject];
}

@end
