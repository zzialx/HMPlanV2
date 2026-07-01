//
//  SubempstoreBeanArray.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSSubempstoreBeanArray.h"

@implementation WSSubempstoreBeanArray

@synthesize subempstoreArray = _subempstoreArray;


-(void)initSubBeanWithArray:(NSArray*)array
{
     self.subempstoreArray = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSSubempstoreBean *sub = [[WSSubempstoreBean alloc] initWithObject:[array objectAtIndex:i]];
                
                 [self.subempstoreArray insertObject:sub atIndex:i];
            }
        }
    }
}


-(id)initWithObject:(id)object
{
    return [self initWithObject:object noteName:SUBEMPSTORES];
//    self = [super init];
//    if(self != nil)
//    {
//        if ([object isKindOfClass:[NSDictionary class]]){
//            NSArray *Array = [object objectForKey:SUBEMPSTORES];
//            [self initSubBeanWithArray:Array];
//        }
//    }
//    return self;
}
- (id)initWithObject:(id)object noteName:(NSString *)aNoteName {
    self = [super init];
    if(self != nil)
    {
        if ([object isKindOfClass:[NSDictionary class]]){
            NSArray *Array = [object objectForKey:aNoteName];
            [self initSubBeanWithArray:Array];
        }
    }
    return self;
}



-(WSSubempstoreBean*)getSubempstoreById:(NSString*)anId

{
    if(anId == nil)
        return nil;
    for(WSSubempstoreBean* sub in self.subempstoreArray)
    {
        if([sub.Id isEqualToString:anId])
            return sub;
    }
    return nil;
}





@end
