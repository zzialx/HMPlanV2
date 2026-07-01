//
//  WSBaseMsgTypeTable.h
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//
#import "WSSqliteUtil.h"

@interface WSBaseMsgTypeTable : WSSqliteUtil

+ (WSBaseMsgTypeTable *)sharedTable;

- (void)cleanOldData;

-(NSArray *)queryBaseMsgType;

-(WSBaseMsgTypeObject *)queryBaseMsgTypeById:(NSString *)typeId;

@end
