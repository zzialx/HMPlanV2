//
//  WSPlanCalendarManageDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarManageDataModel.h"



@implementation WSPlanCalendarManageDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"tableData" : [WSPlanCalendarManageDataInfoModel class]};
}
@end

@implementation WSPlanCalendarManageDataInfoModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"salesList" : [WSPlanCalendarRouteManageDataInfoModel class],@"leaderList" : [WSPlanCalendarRouteManageDataInfoModel class]};
}

@end

@implementation WSPlanCalendarRouteManageDataInfoModel

@end
