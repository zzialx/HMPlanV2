//
//  AppConfigArray.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfigArray.h"
#import "WSAppConfig.h"
#import "WinSFA.h"
@implementation WSAppConfigArray
@synthesize appConfigArray;
@synthesize empID = empID_;


-(void)initAcvtWithArray:(NSArray*)array
{
    appConfigArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSAppConfig *appConfig = [[WSAppConfig alloc] initWithObject:[array objectAtIndex:i]];
                [self.appConfigArray insertObject:appConfig atIndex:i];
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
            empID_ = [[object objectForKey:@"empid"] copy];
            NSArray *Array = [object objectForKey:APPCONFIG];
            [self initAcvtWithArray:Array];
        }
        return self;
    }
    return nil;
}


@end
