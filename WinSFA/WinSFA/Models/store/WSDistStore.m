//
//  DistStore.m
//  WinChannelFrameWork
//
//  Created by ygs on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSDistStore.h"
#import "WSStoreBean.h"
@implementation WSDistStore

@synthesize distStoreArray =_distStoreArray;

- (void)initArrayWithArray:(NSArray*)array
{
    _distStoreArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSStoreBean *store = [[WSStoreBean alloc] initStoreWithObject:[array objectAtIndex:i] IsPlan:NO];
                [self.distStoreArray insertObject:store atIndex:i];
            }
        }
    }
}

-(id)initWithObject:(id)object
{
    if (nil == object){
        return nil;
    }
    
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:DISTSTORE];
            [self initArrayWithArray:Array];
        }
        return self;
    }
    return nil;
}

@end
