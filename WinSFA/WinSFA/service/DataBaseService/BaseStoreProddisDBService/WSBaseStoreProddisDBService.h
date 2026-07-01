//
//  WSStoreProddisDBService.h
//  WinSFA
//
//  Created by heju on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseStoreProddisDBService : WSDBService





/**/
- (NSString *)queryRedisValueWith:(Class)cls storeId:(NSString *)sId acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId prodId:(NSString *)prodId colForParam:(NSString *)colName;

- (NSString *)queryRedisValueWith:(Class)cls funcCode:(NSString *)funcCode storeId:(NSString *)sId  prodId:(NSString *)prodId colForParam:(NSString *)colName;

/**/
- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId qstId:(NSString *)acvtQstId genId:(NSString *)genId;

- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId qstId:(NSString *)acvtQstId genId:(NSString *)genId needValidateRedisValueParamCols:(NSString *)paramColsString;

- (NSString  *)queryStoreProdRedisValueWithGenId:(NSString *)genId storeId:(NSString *)storeId prodId:(NSString *)prodId paramCol:(NSString *)col repeateIndex:(NSInteger)repeateIndex;

- (NSArray *)queryStoreProdDissWithFuncCode:(NSString *)funcCode storeId:(NSString *)storeId;

- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId;

- (NSArray *)queryStoreProdDissWithStoreId:(NSString *)storeId sortByColParam:(NSString *)colStr isOrderByDesc:(BOOL)isDesc;

- (NSArray *)queryStoreProdDissWithFuncCode:(NSString *)funcCode storeId:(NSString *)storeId sortByColParam:(NSString *)colStr isOrderByDesc:(BOOL)isDesc;

- (NSArray *)queryStoreProdDissWithGenId:(NSString *)genID storeId:(NSString *)storeId prodIds:(NSString *)prodIds;

@end

