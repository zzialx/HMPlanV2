//
//  WSBaseStoreVisitPlanTable.h
//  WinSFA
//
//  Created by heju on 15/9/24.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSSqliteUtil.h"

@interface WSBaseStoreVisitPlanTable : WSSqliteUtil

+ (WSBaseStoreVisitPlanTable *)sharedTable;

- (void)cleanOldData;

- (void)insertStoreVisitPlansWith:(NSArray *)plans;

@end
