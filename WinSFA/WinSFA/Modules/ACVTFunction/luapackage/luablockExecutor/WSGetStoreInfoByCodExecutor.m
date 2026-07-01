//
//  WSGetStoreInfoByCodExecutor.m
//  WinSFA
//
//  Created by winchannel on 16/4/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetStoreInfoByCodExecutor.h"
#import "WSAbstArrayStoreBean.h"
#import "WSStoreBean.h"
#import "WSStoreBeans.h"
#import "WSBaseStoreDBService.h"

@implementation WSGetStoreInfoByCodExecutor

-(LuaScriptWithParamsExpandBlock)getLuaScriptWithParamsExpandBlock{
    
    LuaScriptWithParamsExpandBlock paramExpanedBlock = ^NSString *(id firstObj,...){
        
        //返回值类型
        NSString *cod = [NSString stringWithFormat:@"%@",firstObj];
        
        va_list argsList;
        va_start(argsList, firstObj);
        id secondObj = va_arg(argsList, id);
        
        //查询条件
        NSString *queryName = [NSString stringWithFormat:@"%@",secondObj];
        
        if ([queryName isEqualToString:@"_id"]) {
            queryName = @"store_id" ;
        }
        id args = va_arg(argsList, id);
        va_end(argsList);
        
        //查询条件值
        NSString *argumentValue = [NSString stringWithFormat:@"%@",args];
        
        WSBaseStoreDBService *dbService = [[WSBaseStoreDBService alloc] init];
        WSBaseStoreObject *object = [dbService queryStoreWithId:argumentValue];
        WSStoreBean *storeBean = [[WSStoreBean alloc] initstoreWithBaseStoreObject:object isPlan:YES];
        NSString *value = [dbService queryStoreValueWithParamCol:cod storeBean:storeBean];
        if (value) {
            return value;
        }
        return @"";
    };
    
    return [paramExpanedBlock copy];
}
@end
