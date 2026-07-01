//
//  WSVisitStoreAcvtTable.h
//  WinSFA
//
//  Created by Alicia on 2017/5/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSVisitStoreAcvtTable : WSSqliteUtil

- (void)cleanOldData;

+ (WSVisitStoreAcvtTable *)sharedTable;

- (BOOL)insertOrUpdateDatas:(NSArray *)datas genId:(NSString *)genId;

- (BOOL)deleteDatasGenId:(NSString*)genId;

@end
