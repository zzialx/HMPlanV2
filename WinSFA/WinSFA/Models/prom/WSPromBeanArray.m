//
//  PromBeanArray.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSPromBeanArray.h"
#import "WSPromBean.h"

#define PROM     @"proms"

@implementation WSPromBeanArray

@synthesize promArray = _promArray;

-(void)initPromWithArray:(NSArray*)array
{
    _promArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                 WSPromBean *prom = [[WSPromBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.promArray insertObject:prom atIndex:i];
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
            NSArray *Array = [object objectForKey:PROM];
            [self initPromWithArray:Array];
        }
        return self;
    }
    return nil;
}

@end
