//
//  empinforefreshBeanArray.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSEmpinforefreshBeanArray.h"

@implementation WSEmpinforefreshBeanArray

@synthesize empinforefreshArray = _empinforefreshArray;

-(void)initEmpinforefreshWithArray:(NSArray *)array
{

    self.empinforefreshArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            NSInteger arrayCount=[array count];
            for (NSInteger i = 0; i < arrayCount; i++) {
            WSEmpinforefreshBean *emprefreshBean = [[WSEmpinforefreshBean alloc] initWithObject:[array objectAtIndex:i]];
            [self.empinforefreshArray insertObject:emprefreshBean atIndex:i];
            
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
            NSArray *Array = [object objectForKey:EMPINFOREFRESHS];
           [self initEmpinforefreshWithArray:Array];
        }
        return self;
    }
    return nil;


}

-(NSArray*)getEmpinforefreshsWithFilter:(NSString*)filter
{

    NSMutableArray* Array = [[NSMutableArray alloc]init];
    for(WSEmpinforefreshBean* emprefreshBean in self.empinforefreshArray)
    {
        if([emprefreshBean.typ isEqualToString:filter])
        {
            [Array addObject:emprefreshBean];
        }
        
    }
    return Array;

}

@end
