//
//  WSContactsBookServiceDataModel.m
//  WinSFA
//
//  Created by yuanji on 2018/5/6.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSContactsBookServiceDataModel.h"
//===================================================================================================================================================================

#pragma mark - 通讯录服务器数据模型
@implementation WSContactsBookServiceDataModel

#pragma mark - 重写keyMapper方法
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"contactsArray" : @"mailList", @"storeContactsArray" : @"cusMailList"}];
}

#pragma mark - 重写propertyIsOptional:方法 propertyName:属性名称
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
//===================================================================================================================================================================

#pragma makr - 联系人标准信息
@implementation WSContactsStandardInfo

#pragma mark - 重写keyMapper方法
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"contactsId" : @"id", @"detailArray" : @"detail"}];
}

#pragma mark - 重写propertyIsOptional:方法 propertyName:属性名称
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
//===================================================================================================================================================================

#pragma makr - 联系人详细信息
@implementation WSContactsDetailInfo

#pragma mark - 重写keyMapper方法
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{@"contactsId" : @"id", @"address" : @"addr"}];
}

#pragma mark - 重写propertyIsOptional:方法 propertyName:属性名称
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
//===================================================================================================================================================================
