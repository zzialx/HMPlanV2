//
//  WSVisitedMenuArray.h
//  WinSFA
//
//  Created by yang on 15/11/27.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseBeanArray.h"

@interface WSVisitedMenuArray : WSBaseBeanArray

- (BOOL)isFuncsCodeVisited:(NSString *)fc storeId:(NSString *)storeId parentFuncsCode:(NSString *)parentFc;

@end
