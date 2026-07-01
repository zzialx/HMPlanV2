//
//  WSTskfRouteModel.m
//  WinSFA
//
//  Created by admin on 2022/10/29.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSTskfRouteModel.h"

@implementation WSTskfRouteModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"getMySpeRouteStore":[WSTskfRouteStoreModel class]
             };
}

@end


@implementation WSTskfRouteStoreModel



@end
