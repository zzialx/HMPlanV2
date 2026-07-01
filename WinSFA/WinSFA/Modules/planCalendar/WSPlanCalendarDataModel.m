//
//  WSPlanCalendarDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarDataModel.h"

@implementation WSPlanCalendarDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"tableData" : [WSPlanCalendarDataInfoModel class],
             @"kqInfo" : [WSAttenanceModel class],
             @"callPlanStoreList" : [WSPlanStoreModel class]
    };
}
@end

@implementation WSPlanCalendarDataInfoModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"visitList" : [WSPlanCalendarRouteDataInfoModel class]};
}

@end

@implementation WSPlanCalendarRouteDataInfoModel

@end


@implementation WSAttenanceModel

@end

@implementation WSPlanStoreModel



@end

