//
//  ServerIPArrayController.m
//  WinChannelFrameWork
//
//  Created by ygs on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSServerIPList.h"

@implementation WSServerIPList

@synthesize serverIPArray = _serverIPArray;

-(void)initProdWithArray:(NSArray*)array
{
    self.serverIPArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSServerIPController *serverIP=[[WSServerIPController alloc]initWithObject:[array objectAtIndex:i] ];
//                ProdBean *prod = [[ProdBean alloc] initWithObject:[array objectAtIndex:i]];
                [self.serverIPArray insertObject:serverIP atIndex:i];
//                [self.prodArray insertObject:prod atIndex:i];
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
            NSArray *Array = [object objectForKey:SERVERURL];
            [self initProdWithArray:Array];
        }
        return self;
    }
    return nil;
}
@end
