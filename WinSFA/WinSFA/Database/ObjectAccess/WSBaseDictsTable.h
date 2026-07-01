//
//  WSBaseDictsTable.h
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#import "WSSqliteUtil.h"

@interface WSBaseDictsTable : WSSqliteUtil

+ (WSBaseDictsTable *)sharedTable;


- (NSArray *)queryWithFilter:(NSString *)qstFilter value:(NSString *)qstRedisValue;

@end
