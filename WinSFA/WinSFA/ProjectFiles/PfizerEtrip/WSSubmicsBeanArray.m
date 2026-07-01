//
//  WSSubmicsBeanArray.m
//  WinSFA
//
//  Created by zhangke on 14-5-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSubmicsBeanArray.h"

@implementation WSSubmicsBeanArray


-(void)initEmpinforefreshWithArray:(NSArray *)array
{
    
    self.submicsArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            NSInteger arrayCount=[array count];
            for (int i = 0; i < arrayCount; i++) {
                WSSubmicsBean *submicsBean = [[WSSubmicsBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.submicsArray insertObject:submicsBean atIndex:i];
                
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
            NSArray *Array = [object objectForKey:SUBMICS];
            [self initEmpinforefreshWithArray:Array];
        }
        return self;
    }
    return nil;
    
    
}

@end
