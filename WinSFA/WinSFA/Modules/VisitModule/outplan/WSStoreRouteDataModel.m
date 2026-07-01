//
//  WSStoreRouteDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/9.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreRouteDataModel.h"
//==========================================================================================================================================

@implementation WSStoreRouteDataModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    
    return @{@"routs" : [WSStoreRouteDataInfoModel class]};
}

- (void)setCurRoute:(NSString *)curRoute {
    
    _curRoute = curRoute;
}

@end
//==========================================================================================================================================

@implementation WSStoreRouteDataInfoModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"stores" : [WSStoreDataInfoModel class]};
}

@end
//==========================================================================================================================================

@implementation WSStoreDataInfoModel

@end
//==========================================================================================================================================

