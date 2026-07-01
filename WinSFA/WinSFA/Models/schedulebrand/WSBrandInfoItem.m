//
//  WSBrandInfoItem.m
//  WinSFA
//
//  Created by xiaotang.wang on 7/24/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import "WSBrandInfoItem.h"

@implementation WSBrandInfoItem

@synthesize iBrandId = _iBrandId;
@synthesize iBrandName = _iBrandName;

- (id)initWithObject:(id)aObject
{
    if (aObject == nil || ![aObject isKindOfClass:[NSDictionary class]])
        return nil;
    
    self = [super init];
    if (self != nil) {
        NSDictionary *dic = (NSDictionary *)aObject;
        
        //Brand id
        NSNumber *brandid = [dic objectForKey:SCHEDULEBRAND_ID];
        _iBrandId = [[brandid stringValue] copy];
        
        //Brand name
        NSString *brandname = [dic objectForKey:SCHEDULEBRAND_NAME];
        _iBrandName = [brandname copy];
        
    }
    return self;
}

@end
