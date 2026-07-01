//
//  WSAcvtListFlagArray.m
//  WinSFA
//
//  Created by zhangke on 14/6/27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAcvtListFlagArray.h"
#import "WSAcvtListFlag.h"

@implementation WSAcvtListFlagArray
@synthesize acvtArray = _acvtArray;

-(void)initAcvtWithArray:(NSArray*)array
{
    _acvtArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){
            
            for (int i = 0; i < [array count]; i++) {
                WSAcvtListFlag *dict = [[WSAcvtListFlag alloc] initWithObject:[array objectAtIndex:i]];
                [self.acvtArray insertObject:dict atIndex:i];
            }
        }
    }
}

-(id)initWithObject:(id)object
{
    
    //    return nil;
    return [self initMy:MENUACVTLISTFLAG :object];
}
-(id)initWithObjectEcho:(id)object
{
    
    return [self initMy:MENUACVTLISTFLAGECHO :object];
    
}
- (id)initMy:(NSString*)key :(id)object
{
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:key];
            [self initAcvtWithArray:Array];
        }
        return self;
    }
    return nil;
}



@end
