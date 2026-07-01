//
//  OutPlanStoreBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSOutPlanStoreBean.h"
#import "WSStoreBean.h"
@interface WSOutPlanStoreBean ()
@property (nonatomic,assign) BOOL isInitForWSAppData;
@end


@implementation WSOutPlanStoreBean


- (void)addStoresWithArray:(NSArray *)array noteName:(NSString *)noteName
{
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSStoreBean *store = nil;
                if (self.isInitForWSAppData) {
                    store = [[WSStoreBean alloc] initStoreForWSAppDataWithObject:[array objectAtIndex:i] IsPlan:NO noteName:noteName];
                }else{
                    store = [[WSStoreBean alloc] initStoreWithObject:[array objectAtIndex:i] IsPlan:NO noteName:noteName];
                }
                [self.storesArray insertObject:store atIndex:i];
            }
        }
    }
}

-(id)initWithObject:(id)object
{
    return [self initWithObject:object noteName:OUTPLANSTORE];
}

-(id)initWithObjectForWSAppData:(id)object
{
    self.isInitForWSAppData = YES;
    return [self initWithObject:object noteName:OUTPLANSTORE];
}


@end
