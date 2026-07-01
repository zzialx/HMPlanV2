//
//  WSProductValidateBeanArray.m
//  WinSFA
//
//  Created by yang on 15/11/5.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSProductValidateBeanArray.h"
#import "WSProductValidateBean.h"

@implementation WSProductValidateBeanArray

- (NSString *)getDefaultParseKey
{
    return PRODUCT_VALIDATE;
}

- (Class)getBeanSubclass
{
    return [WSProductValidateBean class];
}

- (NSArray *)getSKUProductArrayByGroupName:(NSString *)groupName
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (WSProductValidateBean *prodValidateBean in self.beanArray) {
        if ([prodValidateBean.group isEqualToString:groupName] && [prodValidateBean.type isEqualToString:@"sku"]) {
            [array addObject:prodValidateBean];
        }
    }
    
    return array;
}

- (WSProductValidateBean *)getGroupProductByGroupName:(NSString *)groupName
{
    for (WSProductValidateBean *prodValidateBean in self.beanArray) {
        if ([prodValidateBean.group isEqualToString:groupName] && [prodValidateBean.type isEqualToString:@"group"]) {
            return prodValidateBean;
        }
    }
    
    return nil;
}

@end
