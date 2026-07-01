//
//  SugBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSugBeanArray.h"
#import "WSSugBean.h"

@implementation WSSugBeanArray

@synthesize sugArray = _sugArray;

-(void)initSugWithArray:(NSArray*)array
{
    _sugArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            for (int i = 0; i < [array count]; i++) {
                WSSugBean *sug = [[WSSugBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.sugArray insertObject:sug atIndex:i];
            }
        }
    }
}

-(id)initWithObject:(id)object
{
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:SUG];
            [self initSugWithArray:Array];
        }
        return self;
    }
    return nil;
}

@end
