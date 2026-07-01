//
//  WSBaseBeanArray.m
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSBaseBeanArray.h"
#import "WSBaseBean.h"

@implementation WSBaseBeanArray

- (Class)getBeanSubclass
{
    return [WSBaseBean class];
}

- (NSString *)getDefaultParseKey
{
    return @"";
}

-(void)initBeanArrayWithDicArray:(NSArray *)array
{
    if (!_beanArray) {
        _beanArray = [[NSMutableArray alloc] init];
    }
    if ([array isKindOfClass:[NSArray class]]){
        for (id obj in array) {
            Class subClass = [self getBeanSubclass];
            if (subClass) {
                WSBaseBean * visitPlan = [[subClass alloc] initWithObject:obj];
                [_beanArray addObject:visitPlan];
            }else {
                [_beanArray addObject:obj];
            }
        }
    }
}

- (instancetype)initWithObject:(id)object {
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {

            NSString *defaultParseKey = [self getDefaultParseKey];
            
            if ([defaultParseKey length] > 0) {
                [(NSDictionary *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    if (key && [key isKindOfClass:[NSString class]] && [key hasPrefix:defaultParseKey]) {
                        
                        [self initBeanArrayWithDicArray:(NSArray *)obj];
                    }
                }];
            }
            
            return self;
        }
    }
    
    return nil;
    
}

- (instancetype)initWithObject:(id)object andKey:(NSString *)parserkey {
    
    if([object isKindOfClass:[NSDictionary class]])
    {
        self = [super init];
        if(self)
        {
            NSArray *Array = [object objectForKey:parserkey];
            [self initBeanArrayWithDicArray:Array];
            return self;
        }
    }
    return nil;
    
}

@end
