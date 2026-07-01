//
//  StoreInfoBeanArray.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSStoreInfoBeanArray.h"

@implementation WSStoreInfoBeanArray

@synthesize storeinfoArray = _storeinfoArray;

-(void)initStoreinfosWithArray:(NSArray *)array
{
    
    _storeinfoArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            NSInteger arrayCount=[array count];
            for (int i = 0; i < arrayCount; i++) {
               WSStoreInfoBean  *storeInBean = [[WSStoreInfoBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.storeinfoArray insertObject:storeInBean atIndex:i];
                
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
            NSArray *Array = [object objectForKey:STOREINFOS];
            if (!Array || Array.count <= 0) {
                Array = [object objectForKey:EMPSRINFO];
            }

            [self initStoreinfosWithArray:Array];
        }
        return self;
    }
    return nil;
    
    
}

-(NSArray*)getStoreinfosWithFilter:(NSString*)filter;
{
    
    NSMutableArray* Array = [[NSMutableArray alloc]init];
    for(WSStoreInfoBean *storeInBean in self.storeinfoArray)
    {
        if([storeInBean.typ isEqualToString:filter])
        {
            [Array addObject:storeInBean];
        }
        
    }
    return Array;
    
}


@end
