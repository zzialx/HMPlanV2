//
//  WSCalendarLogicService.h
//  WinSFA
//
//  Created by Alicia on 2017/6/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSAcvtModel.h"

@interface WSCalendarLogicService : NSObject

/**
 得到排班日历的标记数据
 @param  dataStrs  example： @[@"2016-12-11",@"2016-12-12"]
 
 @returen mutableDictionary @{@"2016-12-11":@{@"10":@"http:xxxxx1",@"11":@"http:xxxxx2",@"12":@"http:xxxxx3"}}
 */

+ (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid acvtModel:(WSAcvtModel *)acvtModel;
+ (NSMutableDictionary *)getCalendaDutyPlanIcon:(NSArray *)dateStrs usingGenId:(BOOL)isUsingGenid acvtModel:(WSAcvtModel *)acvtModel withoutEmptyDic:(BOOL)withoutEmpty;

@end
