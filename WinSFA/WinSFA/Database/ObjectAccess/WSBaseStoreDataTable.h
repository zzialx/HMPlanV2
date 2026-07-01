//
//  WSBaseStoreDataTable.h
//  WinSFA
//
//  Created by zhangke on 14/8/31.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"


@interface WSBaseStoreDataTable : WSSqliteUtil

+ (WSBaseStoreDataTable *)sharedTable;

- (void)cleanOldData;

//查询
- (NSArray *)queryWithEmpId:(NSString *)aEmpId withAcvtId:(NSString *)aAcvtId withBizDate:(NSString *)aBizDate;

//删除
- (void)deleteWithAcvtId:(NSString *)aAcvtId;

//插入
- (void)insertWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andITEM:(NSString *)aItem;

- (void)InsertTableEvaluatePersonWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andEvaluateResult:(NSDictionary *)aResult;

- (void)insertTableMeetingPersonSqlWithAcvtId:(NSString *)aAcvtId withType:(NSString *)aType andMeetingPersons:(NSArray *)aPersons;


@end
