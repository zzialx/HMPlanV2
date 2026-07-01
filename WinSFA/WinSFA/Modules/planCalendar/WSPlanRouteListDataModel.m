//
//  WSPlanRouteListDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/28.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanRouteListDataModel.h"

@implementation WSPlanRouteListDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"getRouteInfo" : [WSPlanRouteListDataInfoModel class]};
}
@end

@implementation WSPlanRouteListDataInfoModel

@end
