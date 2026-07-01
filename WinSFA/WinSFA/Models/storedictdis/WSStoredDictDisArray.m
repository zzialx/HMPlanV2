//
//  WSStoredDictDisArray.m
//  WinSFA
//
//  Created by xiajl on 14-11-20.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSStoredDictDisArray.h"
#import "WSStoredDictDisBean.h"

@implementation WSStoredDictDisArray

-(void)initStoreAcvtDisWithArray:(NSArray*)array
{
    _storedDictDisArray = [[NSMutableArray alloc] init];
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            NSInteger i_arrayCount = [array count];
            for (NSInteger i = 0; i < i_arrayCount; i++)
            {
                WSStoredDictDisBean* f_sad = [[WSStoredDictDisBean alloc]initWithObject:[array objectAtIndex:i]];
                [_storedDictDisArray addObject:f_sad];
                f_sad = nil;
            }
        }
    }
}


-(id)initWithObject:(id)object
{
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {
            NSArray *Array = [object objectForKey:STOREDICTDIS];
            [self initStoreAcvtDisWithArray:Array];
        }
    }
    return self;
}

@end
