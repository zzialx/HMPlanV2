//
//  WSDictBean+child.m
//  WinSFA
//
//  Created by winchannel on 2017/11/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSDictBean+child.h"
#import <objc/runtime.h>
@implementation WSDictBean (child)
@dynamic childArray;
NSString * const kChildArray = @"kChildArray";

- (void)setChildArray:(NSMutableArray *)childArray{
    
    objc_setAssociatedObject(self, (__bridge const void *)(kChildArray), (NSMutableArray *)childArray,OBJC_ASSOCIATION_RETAIN);
}
- (NSMutableArray *)childArray{
    
    return (NSMutableArray *)objc_getAssociatedObject(self, (__bridge const void *)(kChildArray));
    
}
@end
