//
//  WSProductValidateBean.m
//  WinSFA
//
//  Created by yang on 15/11/5.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSProductValidateBean.h"

@implementation WSProductValidateBean


- (instancetype)initWithObject:(id)object {
    
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _type = [NSString stringWithValue:[object objectForKey:@"type"]];
        _group = [NSString stringWithValue:[object objectForKey:@"group"]];
        _prodId = [NSString stringWithValue:[object objectForKey:@"prodId"]];
        _fenzhi = [NSString stringWithValue:[object objectForKey:@"fenzhi"]];
        _tip = [NSString stringWithValue:[object objectForKey:@"tip"]];
        
        return  self;
        
    }
    
    return nil;
    
    
    
}

@end
