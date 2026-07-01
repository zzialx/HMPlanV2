//
//  WSBaseStoreDictsTable.h
//  WinSFA
//
//  Created by mac on 2018/10/16.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreDictsTable : WSSqliteUtil
+ (WSBaseStoreDictsTable *)sharedTable;

@end
