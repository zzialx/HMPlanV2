//
//  WSTskfRouteTjModel.m
//  WinSFA
//
//  Created by admin on 2022/12/6.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSTskfRouteTjModel.h"

@implementation WSTskfRouteTJModel


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"getMySpeRouteTotal":[WSTskfRouteTjInfoModel class]
             };
}

@end

@implementation WSTskfRouteTjInfoModel

@end
