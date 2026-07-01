//
//  WSBaseMsgStoreTable.h
//  WinSFA
//
//  Created by mac on 2018/11/10.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseMsgStoreTable : WSSqliteUtil
+ (WSBaseMsgStoreTable *)sharedTable;
- (void)cleanOldData;
@end
