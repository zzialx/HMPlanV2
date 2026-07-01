//
//  WSBaseMsgTable.h
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#import "WSSqliteUtil.h"

@interface WSBaseMsgTable : WSSqliteUtil

+ (WSBaseMsgTable *)sharedTable;

//清除前天数据
- (void)cleanOldData;
//查询
-(NSArray *)queryBaseMsgWithPid:(NSString *)aPid;

- (NSArray *)queryMsgByHeadRail:(NSString *)headRail;

//查询所有未读消息
-(NSArray *)queryAllUnreadBaseMsgs;

// 根据 消息id 查询该条消息下所有回复的条数
-(NSInteger)queryCountByMsgId:(NSString *)msgId;
// 根据 消息pid 查询该条消息下的已读条数
-(NSInteger)queryReadedBaseMsgsWithPid:(NSString *)aPid;
//根据typcode查询未读条数多个typcode逗号隔开
-(NSInteger)queryNOReadedBaseMsgsWithIsread:(NSString *)isread multiTypcode:(NSString *)typcode;
//根据typcode查询未读条数
-(NSInteger)queryNOReadedBaseMsgsWithIsread:(NSString *)isread typcode:(NSString *)typcode;

-(NSArray *)queryStoreMsgByPid:(NSString *)pid storeId:(NSString*)storeId;

@end
