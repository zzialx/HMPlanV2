//
//  WSStoreManageDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreManageDataModel.h"
//========================================================================================================================================================================

@implementation WSStoreManageDataModel

+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass {
    
    return @{@"spestorelist" : [WSStoreManageDataInfoModel class]};
}

@end
//========================================================================================================================================================================

@implementation WSStoreManageDataInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{@"genId" : @"id"};
}

@end
//========================================================================================================================================================================
