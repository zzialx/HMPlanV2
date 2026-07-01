//
//  WSVisitStoreAcvtDataTable.h
//  WinSFA
//
//  Created by yang on 16/11/7.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSVisitStoreAcvtDataTable : WSSqliteUtil

- (void)cleanOldData;

+ (WSVisitStoreAcvtDataTable *)sharedTable;

- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId;
- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId andParentGenId:(NSString *)parentGenId;

- (BOOL)insertOrUpdateAcvtDataByGenId:(NSString *)genId storeId:(NSString *)storeId acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId value:(NSString *)value;

- (NSArray *)queryDatasByGenId:(NSString *)genId;

- (BOOL) deleteDateGenId:(NSString *)genId;

@end
