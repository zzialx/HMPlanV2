//
//  WSFuncsBeanFilterService.h
//  WinSFA
//
//  Created by Stephanie on 16/8/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSFuncsBeanFilterLogicService : NSObject

+ (NSArray *)filterFuncsBean:(NSArray *)funcsBeanArray withStore:(WSStoreBean *)storeBean bizDate:(NSString *)bizDate;

- (NSArray *)filterMenuTypeFuncsBean:(NSArray *)funcsBeanArray withDictsBeanArray:(NSArray *)dictsBeanArray;

+ (WSFuncsBean *)getSubMenuFuncsBeanByCurrentFB:(WSFuncsBean *)currentFB;

+ (WSFuncsBean*)getSubMenuFuncsBeanByFuncsCode:(NSString*)subMenuFC;

@end
