//
//  WSAbstArrayStoreBean.m
//  WinSFA
//
//  Created by xiajl on 14-8-15.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSAbstArrayStoreBean.h"

@implementation WSAbstArrayStoreBean

- (void)addStoresWithArray:(NSArray *)array noteName:(NSString *)noteName
{
    
}

- (void)initWithStoreArrayForSer:(NSArray *)array{
    
    [self.storesArray addObjectsFromArray:array];
}

-(id)initWithObject:(id)object
{
    
    return [self initWithObject:object noteName:nil];
}

- (id)initWithObject:(id)object noteName:(NSString *)aNoteName {
    if (nil == object){
        return nil;
    }
    
    self = [super init];
    if(self != nil) {

        _storesArray = [[NSMutableArray alloc] init];
        if (aNoteName) {
            
            if ([object isKindOfClass:[NSDictionary class]]) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (key && [key isKindOfClass:[NSString class]] && [key hasPrefix:aNoteName]) {
                        [self addStoresWithArray:(NSArray *)obj noteName:key];
                    }
                }];
            }
        }
        return self;
    }
    return nil;
}

- (id)initWithObjectForSer:(id)object notName:(NSString *)aNotName{
    if (nil == object){
        return nil;
    }
    
    self = [super init];
    if(self != nil) {
        
        _storesArray = [[NSMutableArray alloc] init];
        if (aNotName) {
            
            __block NSMutableArray *array = [NSMutableArray array];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if (key && [key isKindOfClass:[NSString class]] && [key hasPrefix:aNotName]) {
                        [array addObjectsFromArray:(NSArray *)obj];
                    }
                }];
                
                [self initWithStoreArrayForSer:array];
            }
        }
        return self;
    }
    return nil;

}


- (id)initWithStoreArray:(NSArray *)array {
    
    self = [super init];
    
    if (self) {
        if (array) {
            _storesArray = [NSMutableArray arrayWithArray:array];
        }
        return self;
    }
    
    return nil;
}


- (WSStoreBean *)getStoreByID:(NSString *)storeID
{
    if (!storeID || [storeID length] == 0) {
        return nil;
    }
    
    for (WSStoreBean *storeBean in _storesArray) {
        if ([storeBean.Id isEqualToString:storeID] && [storeBean.noteName isEqualToString:STORES]) {
            return storeBean;
        }
    }
    
    return nil;
}

@end
