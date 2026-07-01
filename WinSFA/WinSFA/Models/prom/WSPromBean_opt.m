//
//  PromBean_opt.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSPromBean_opt.h"

@implementation WSPromBean_opt

@synthesize pid = _pid;
@synthesize qid = _qid;

- (id)initWithObject:(id)object{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            
            _pid = [NSString stringWithValue: [dic objectForKey:PROMS_OPT_PID]];
            _qid = [NSString stringWithValue: [dic objectForKey:PROMS_OPT_QID]];
        }
    }
    
    return self;
}

@end
