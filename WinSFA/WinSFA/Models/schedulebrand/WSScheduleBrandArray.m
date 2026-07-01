//
//  WSScheduleBrandArray.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSScheduleBrandArray.h"
#import "WSBrandInfoItem.h"

@implementation WSScheduleBrandArray

@synthesize iBrandInfos = _iBrandInfos;

- (id)initWithObject:(id)aObject
{
    if (aObject == nil || ![aObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self != nil) {
        NSDictionary *dic = (NSDictionary *)aObject;
        NSArray *array = [dic objectForKey:SCHEDULEBRAND_NODE];
        
        if (array && [array count] > 0) {
            _iBrandInfos = [[NSMutableArray alloc] initWithCapacity:4];
            
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    WSBrandInfoItem *item = [[WSBrandInfoItem alloc] initWithObject:obj];
                    if (item != nil) {
                        [_iBrandInfos addObject:item];
                    }
                }
            }];
        }
    }
    return self;
}

- (NSString *)getBrandNameByBrandId:(NSString *)aBrandId
{
    if (aBrandId == nil || ![aBrandId isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *name = nil;
    
    for (WSBrandInfoItem *item in self.iBrandInfos) {
        if ([item.iBrandId isEqualToString:aBrandId]) {
            name = item.iBrandName;
            break;
        }
    }
    
    return name;
}


@end
