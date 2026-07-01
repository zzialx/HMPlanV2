//
//  WSVisitedMenuBean.m
//  WinSFA
//
//  Created by yang on 15/11/27.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSVisitedMenuBean.h"

@implementation WSVisitedMenuBean


- (instancetype)initWithObject:(id)object {
    
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _store_id = [NSString stringWithValue:[object objectForKey:@"store_id"]];
        _pfc = [NSString stringWithValue:[object objectForKey:@"pfc"]];
        _empId = [NSString stringWithValue:[object objectForKey:@"empId"]];
        _func_code = [NSString stringWithValue:[object objectForKey:@"func_code"]];
        
        return  self;
        
    }
    
    return nil;
    
}



@end
