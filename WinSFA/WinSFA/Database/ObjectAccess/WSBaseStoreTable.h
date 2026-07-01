//
//  WSBaseStoreTable.h
//  WinSFA
//
//  Created by heju on 15/9/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreTable : WSSqliteUtil

+ (WSBaseStoreTable *)sharedTable;

- (void)cleanOldData;

- (void)clearBaseStore;

- (void)insertAllStoresWith:(NSArray *)stores searchObjId:(NSString *)objId searchObjCode:(NSString *)objCode isPlan:(NSString *)plan;

- (NSArray *)insertStoreWith:(NSObject *)store searchObjId:(NSString *)objId searchObjCode:(NSString *)objCode isPlan:(NSString *)plan;

- (NSArray *)queryStoresWithFilter:(NSString *)qstFilter value:(NSString *)qstRedisValue;
//根据城市编码 查询是否下载过当前城市的 门店
- (BOOL)queryStoresWithSearchCode:(NSString *)searchCode;
//查询出门店所属的所有城市
- (NSArray*)queryStoresCitys;
@end
