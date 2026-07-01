//
//  WSCALDataSource.h
//  WinSFA
//
//  Created by heju on 2016/12/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseDataSource.h"

@interface WSCALDataSource : WSBaseDataSource

/**
 得到排班日历的标记数据
 @param  dataStrs  example： @[@"2016-12-11",@"2016-12-12"]
 
 @returen mutableDictionary @{@"2016-12-11":@{@"10":@"http:xxxxx1",@"11":@"http:xxxxx2",@"12":@"http:xxxxx3"}}
 */
- (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid;

- (NSArray *)getCalenderShowLimitDateStrs;

@end
