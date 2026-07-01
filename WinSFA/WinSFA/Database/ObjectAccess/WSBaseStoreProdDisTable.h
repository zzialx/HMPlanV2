//
//  WSBaseStoreProdDisTable.h
//  WinSFA
//
//  Created by heju on 16/3/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreProdDisTable : WSSqliteUtil

+ (WSBaseStoreProdDisTable *)sharedTable;

- (BOOL)insertProddisDatasWith:(NSArray *)proddiss;

- (BOOL)deleteProddisDatasWithStoreId:(NSString *)storeId;

- (BOOL)deleteProddisDatasWithStoreId:(NSString *)storeId andProdIds:(NSArray *)prodIds;

@end
