//
//  MemoDisBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSMemoDisBean.h"

@implementation WSMemoDisBean
@synthesize Id = _Id;
@synthesize memos = _memos;

- (id)initMemoWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    
    
    if (self) 
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
//            NSDictionary *memoDictionary = (NSDictionary *)object;
  
        }
    }
    
    return self;    
}



@end
