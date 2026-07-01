//
//  WSBaseGridDataSource.m
//  WinSFA
//
//  Created by Alicia on 2018/7/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSBaseGridDataSource.h"

@implementation WSBaseGridDataSource

- (NSArray *)getDataSourceByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs
                          store:(WSStoreBean *)store acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean {
    
    NSArray *localDatas = [self getLocalDatasByMd5:md5 funcs:funcs store:store qstId:qstBean.acvtQstId];
    NSArray *serverDatas = [self getServerDatasByMd5:md5 brandId:brandId pType:pType funcs:funcs store:store qstBean:qstBean];
    return (localDatas.count > 0) ? localDatas : serverDatas;
    
//    if ([serverDatas count] > 0) {
//        if ([localDatas count] > 0) {
//            NSMutableArray *dataSource = [NSMutableArray arrayWithArray:serverDatas];
//            NSArray *itemIdArray = [localDatas valueForKeyPath:@"self.Id"];
//            for (id<I_W_OptionDataItem> bean in serverDatas) {
//                if (![itemIdArray containsObject:[bean getDataItemID]]) {
//                    [dataSource addObject:bean];
//                }
//            }
//            return [dataSource copy];
//        } else {
//            return serverDatas;
//        }
//    } else {
//        return localDatas;
//    }
}

- (NSArray *)getLocalDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    return nil;
}

- (NSArray *)getServerDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean{
    return nil;
}

- (NSArray *)getDataBaseDatasByMd5:(NSString *)md5 funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstId:(NSString *)qstId {
    return nil;
}

/**
 *  服务器数据回显
 *  @param   WSFuncsBean_Param
 *  @return bool
 */
- (BOOL)serverRedisWith:(WSFuncsBean_Param *)param {
    BOOL serverRedis = YES;
    if (!param.redis
        || (param.redis && [param.redis isEqualToString:@"0"])
        || (param.redis && [param.redis length] < 1)) {
        serverRedis = NO;
    }
    return serverRedis;
}
- (NSArray *)getServerRedisDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean{
    return [self getServerRedisDatasByMd5:md5 brandId:brandId pType:pType funcs:funcs store:store qstBean:qstBean];
}

@end

