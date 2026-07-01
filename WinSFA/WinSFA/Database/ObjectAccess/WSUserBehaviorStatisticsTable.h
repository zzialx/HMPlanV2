//
//  WSUserBehaviorStatisticsTable.h
//  WinSFA
//
//  Created by yang on 17/5/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSUserBehaviorStatisticsTable : WSSqliteUtil

+ (WSUserBehaviorStatisticsTable *)sharedTable;

@end
