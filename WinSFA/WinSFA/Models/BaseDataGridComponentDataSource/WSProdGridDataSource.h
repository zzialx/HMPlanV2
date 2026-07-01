//
//  WSProdGridDataSource.h
//  WinSFA
//
//  Created by Alicia on 2018/7/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBaseGridDataSource.h"

@interface WSProdGridDataSource : WSBaseGridDataSource

- (NSMutableArray *)getMoreProductArrayByBrandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store filterProdIdArray:(NSArray *)filterProdIdArray;

- (NSArray *)getMoreRedisHomeDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store acvtId:(NSString *)acvtId qstId:(NSString *)qstId moreProductArray:(NSArray *)moreProductArray;

- (NSArray *)getServerRedisDatasByMd5:(NSString *)md5 brandId:(NSString *)brandId pType:(NSString *)pType funcs:(WSFuncsBean *)funcs store:(WSStoreBean *)store qstBean:(WSAcvtBean_qst *)qstBean;

@end
