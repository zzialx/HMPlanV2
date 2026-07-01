//
//  UIButton+Filter.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/30/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "UIButton+Filter.h"
#import <objc/runtime.h>

@implementation UIButton (Filter)

@dynamic iFilter;

NSString *const kBtnFilter = @"kBtnFilter";

- (void)setIFilter:(NSString *)aFilter
{
    objc_setAssociatedObject(self, (__bridge const void *)(kBtnFilter), (id)aFilter, OBJC_ASSOCIATION_COPY);
}

- (NSString *)iFilter
{
    return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kBtnFilter));
}

@end
