//
//  WSStoreFollowUpDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/22.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSStoreFollowUpDataModel.h"

@implementation WSStoreFollowUpDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"followUpList" : [WSStoreFollowUpInfoDataModel class]};
}
@end
@implementation WSStoreFollowUpInfoDataModel

@end

