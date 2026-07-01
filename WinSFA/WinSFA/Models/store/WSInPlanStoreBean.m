//
//  InPlanStoreBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSInPlanStoreBean.h"
#import "WSStoreBean.h"
@interface WSInPlanStoreBean ()
@property (nonatomic,assign) BOOL isInitForWSAppData;
@end

@implementation WSInPlanStoreBean

- (void)addStoresWithArray:(NSArray *)array noteName:(NSString *)noteName
{
    if ([array isKindOfClass:[NSArray class]]){
        
        if (array != nil){ 
            
            for (int i = 0; i < [array count]; i++) {
                WSStoreBean *store = nil;
                if (self.isInitForWSAppData) {
                    
                    store = [[WSStoreBean alloc] initStoreForWSAppDataWithObject:[array objectAtIndex:i] IsPlan:YES noteName:noteName];
                }else{
                    store = [[WSStoreBean alloc] initStoreWithObject:[array objectAtIndex:i] IsPlan:YES noteName:noteName];
                }
                
                [self.storesArray insertObject:store atIndex:i];
            }
        }
    }
}

-(id)initWithObject:(id)object
{
    return [self initWithObject:object noteName:INPLANSTORE];
}

-(id)initWithObjectForWSAppData:(id)object
{
    self.isInitForWSAppData = YES;
    return [self initWithObject:object noteName:INPLANSTORE];
}

-(id)initWithObjectForWSAppData:(id)object andParseKey:(NSString *)parseKey
{
    self.isInitForWSAppData = YES;
    
    return [self initWithObject:object noteName:parseKey];
}

- (WSStoreBean *)getStoreBeanByID:(NSString *)storeID
{
    if (!storeID || [storeID length] <= 0) {
        return nil;
    }
    
    for (WSStoreBean *storeBean in self.storesArray) {
        if ([storeBean.Id isEqualToString:storeID]) {
            return storeBean;
        }
    }
    
    return nil;
}

@end
