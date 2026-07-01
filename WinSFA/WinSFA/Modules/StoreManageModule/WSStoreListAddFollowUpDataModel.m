//
//  WSStoreListAddFollowUpDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/12.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSStoreListAddFollowUpDataModel.h"

@implementation WSStoreListAddFollowUpDataModel
+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"addFollowUpStoreSearchList" : [WSStoreListAddFollowUpDataInfoModel class],
             @"addTskfFollowUpStoreSearchList" : [WSStoreListAddFollowUpDataInfoModel class]};
}
@end
@implementation WSStoreListAddFollowUpDataInfoModel

@end
