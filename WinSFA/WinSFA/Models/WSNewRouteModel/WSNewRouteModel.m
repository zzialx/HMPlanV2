//
//  WSNewRouteModel.m
//  WinSFA
//
//  Created by admin on 2022/10/27.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSNewRouteModel.h"

@implementation WSNewRouteListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"getMySpeRouteInfo":[WSNewRouteModel class]
             };
}

@end

@implementation WSNewRouteModel

@end
