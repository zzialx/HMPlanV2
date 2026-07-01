//
//  WSSuggestDataFactory.h
//  WinSFA
//
//  Created by huzepei on 16/9/6.
//  Copyright © 2016年 WinChannel. All rights reserved.
//  提供建议单的数据查询.用家和批发的数据是统一的


#import <Foundation/Foundation.h>

@interface WSSuggestDataFactory : NSObject

/**
 *  获取建议单品牌 type:prod  本品   comp 竞品
 *  @param suggestType 建议单类型本品, 竞品
 */
+ (NSArray *)suggestBrandForType:(NSString *)suggestType;

/**
 *  建议单的品类, 品类是不分本品和竞品
 */
+ (NSArray *)suggestCategory;

/**
 *  建议单的产品,由品牌和品类来过滤.
 */
+ (NSArray *)suggestProForBrand:(NSString *)brand cate:(NSString *)cate className:(NSString *)className;


/**
 *  先去查找pro表,根据产品反查存在的 品牌 与 品类.
 */
+ (NSArray *)suggestAVProType:(NSString *)suggestType className:(NSString *)className;


@end
