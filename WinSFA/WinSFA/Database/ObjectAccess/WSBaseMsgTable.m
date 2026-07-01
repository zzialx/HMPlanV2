//
//  WSBaseMsgTable.m
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseMsgTable.h"
#import "NSArray+SQL.h"

@implementation WSBaseMsgTable

static WSBaseMsgTable *baseStoreTable = nil;

+ (WSBaseMsgTable *)sharedTable{
    if (baseStoreTable == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseStoreTable = [[WSBaseMsgTable alloc] init];
        });
    }
    return baseStoreTable;
}

-(NSArray *)queryBaseMsgWithPid:(NSString *)aPid{
    NSArray *names = [NSArray arrayWithObjects:@"pid", nil];
    NSArray *values = [NSArray arrayWithObjects:aPid, nil];
    
    return [self queryWithNames:names ArgumentsValue:values];
    
}

- (NSArray *)queryMsgByHeadRail:(NSString *)headRail
{
    if (!headRail) {
        return nil;
    }
    return [self queryWithNames:@[@"headRail"] ArgumentsValue:@[headRail]];
}

-(NSArray *)queryAllUnreadBaseMsgs
{
    NSArray *names = [NSArray arrayWithObjects:@"isread", nil];
    NSArray *values = [NSArray arrayWithObjects:@"0", nil];
    
    return [self queryWithNames:names ArgumentsValue:values];
}

-(NSInteger)queryReadedBaseMsgsWithPid:(NSString *)aPid
{
    NSArray *names = [NSArray arrayWithObjects:@"isread",@"pid", nil];
    NSArray *values = [NSArray arrayWithObjects:@"1",aPid ,nil];
    
    return [self queryWithNames:names ArgumentsValue:values].count;
}
-(NSArray *)queryStoreMsgByPid:(NSString *)pid storeId:(NSString*)storeId{
    NSString * sql = [NSString stringWithFormat:@"select msg._id,msg.title,msg.cont,msg.pubdate,msg.pid,msg.url,msg.visit_address,msg_store.isread,msg_store.store_id from base_msg msg join base_msg_store msg_store on msg_store.msg_id=msg._id where msg_store.store_id='%@' and msg.pid = '%@'  order by cast (msg.seq as int)",storeId,pid];
    return  [self queryAndReturnInfosBySql:sql andClassName:@"WSBaseMsgObject"];
}
-(NSInteger)queryCountByMsgId:(NSString *)msgId{
    if (msgId.length == 0) {
        return 0;
    }
    NSString * sql = [NSString stringWithFormat:@"select * from base_msg where _id = '%@' ",msgId];
    WSBaseMsgObject * object = (WSBaseMsgObject *) [self queryAndReturnSingleInfoBySql:sql andClassName:@"WSBaseMsgObject"];
    if (object.lastreplycount.length > 0) {
        return [object.lastreplycount integerValue];
    }

    return 0;
}

- (void)cleanOldData{
    
    [self deleteAll];
}

//根据typcode查询未读条数多个typcode
-(NSInteger)queryNOReadedBaseMsgsWithIsread:(NSString *)isread multiTypcode:(NSString *)typcode{
    
    NSArray *typCodeArray;
    if ([typcode containsString:@","]) {
        typCodeArray = [typcode componentsSeparatedByString:@","];
    }else{
        typCodeArray = [NSArray arrayWithObject:typcode];
    }
    NSString *sql = [NSString stringWithFormat:@"select * from base_msg where isread ='%@' and  typcode  %@ ",isread,[typCodeArray getInSqlString]];
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    NSInteger count = 0;
    while ([rs next]) {
        count++;
    }
    
    return count;
    
}

//根据typcode查询未读条数
-(NSInteger)queryNOReadedBaseMsgsWithIsread:(NSString *)isread typcode:(NSString *)typcode
{
    NSString * sql = [NSString stringWithFormat:@"select * from base_msg where isread ='%@' and  typcode = '%@'",isread,typcode];
    
    FMResultSet  *rs =  [[WSFMDatebase getInstance] executeQueryWithSql:sql];
    
    NSInteger count = 0;
    while ([rs next]) {
        count++;
    }
  
    return count;
}

@end
