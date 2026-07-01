//
//  WSEditableAcvtQstBean.m
//  WinSFA
//
//  Created by yang on 16/1/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEditableAcvtQstBean.h"

@implementation WSEditableAcvtQstBean

- (instancetype)initWithObject:(id)object {
    
    if (!object || ![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _genID = [NSString stringWithValue:[object objectForKey:@"id"]];
        _value = [NSString stringWithValue:[object objectForKey:@"value"]];
        _empId = [NSString stringWithValue:[object objectForKey:@"empId"]];
        _acvtId = [NSString stringWithValue:[object objectForKey:@"acvtId"]];
        _acvtQstId = [NSString stringWithValue:[object objectForKey:@"acvtQstId"]];
        _qstId = [NSString stringWithValue:[object objectForKey:@"qst_id"]];
        
        return  self;
        
    }
    
    return nil;
    
}

@end
