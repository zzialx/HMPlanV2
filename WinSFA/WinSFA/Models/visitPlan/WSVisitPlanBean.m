//
//  WSVisitPlan.m
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSVisitPlanBean.h"

@implementation WSVisitPlanBean

- (instancetype)initWithObject:(id)object {
    
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self) {

        _sId = [NSString stringWithValue:[object objectForKey:@"sId"]];
        _next = [NSString stringWithValue:[object objectForKey:@"next"]];
        _empId = [NSString stringWithValue:[object objectForKey:@"empId"]];

        return  self;
        
    }
    
    return nil;
    
}

@end
