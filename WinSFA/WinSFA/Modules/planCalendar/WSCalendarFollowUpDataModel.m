//
//  WSCalendarFollowUpDataModel.m
//  WinSFA
//
//  Created by 董宏 on 2020/5/7.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSCalendarFollowUpDataModel.h"

@implementation WSCalendarFollowUpDataModel

+ (nullable NSDictionary<NSString*, id>*)modelContainerPropertyGenericClass
{
    return @{@"getLeaderList" : [WSCalendarFollowUpDataInfoModel class],@"getSrList" : [WSCalendarFollowUpDataInfoModel class],@"getSrStoreList" : [WSCalendarFollowUpDataInfoModel class]};
}
@end



@implementation WSCalendarFollowUpDataInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"Id":@"id"};
}
@end

