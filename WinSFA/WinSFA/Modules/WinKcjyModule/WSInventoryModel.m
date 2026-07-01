//
//  WSInventoryModel.m
//  WinSFA
//
//  Created by zzialx on 2025/7/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSInventoryModel.h"

@implementation WSInventoryModel

@end

@implementation WSStockOutModel

@end

@implementation WSInventoryResultModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"data":[WSInventoryModel class],
             @"otoData":[WSStockOutModel class]
             };
}
@end


