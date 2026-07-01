//
//  WSVisitPeoplePlanTable.h
//  WinSFA
//
//  Created by zhangke on 14-5-26.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSVisitPeoplePlanTable : WSSqliteUtil

+ (WSVisitPeoplePlanTable *)sharedTable;

//插入数据
- (void)insertVisitPlanWithArray:(NSArray *)array withDate:(NSString*)docDate;

//根据日期查询
- (NSArray *)queryVisitPlanByDate:(NSString*)date;

@end
