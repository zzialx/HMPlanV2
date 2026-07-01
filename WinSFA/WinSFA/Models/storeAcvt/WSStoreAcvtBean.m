//
//  WSStoreAcvtBean.m
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSStoreAcvtBean.h"

@implementation WSStoreAcvtBean

- (instancetype)initWithObject:(id)object {
    
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _sid = [NSString stringWithValue:[object objectForKey:@"sid"]];
        _acvtId = [NSString stringWithValue:[object objectForKey:@"acvtId"]];
        _empId = [NSString stringWithValue:[object objectForKey:@"empId"]];
        
        return  self;
        
    }
    
    return nil;
    
    
    
}

@end
