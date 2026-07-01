//
//  WSStoresSearchDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/14.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoresSearchDataModel.h"


@implementation WSStoresSearchDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"spestoreSearchList" : [WSStoresSearchDataInfoModel class]};
}


@end

@implementation WSStoresSearchDataInfoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    // 将personId映射到key为id的数据字段
    return @{@"storeId":@"id"};
}
@end
