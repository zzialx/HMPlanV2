//
//  NSDictionary+RNAdditions.m
//  RRSpring
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "NSDictionary+WithDefault.h"

@implementation NSDictionary (WithDefault)

-(NSString *)stringForKey:(NSString *)key withDefault:(NSString *)defVal{
    return [[self allKeys] containsObject:key] ? [self objectForKey:key] : defVal;
}

-(CGFloat)floatForKey:(NSString *)key withDefault:(CGFloat)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp floatValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

-(double)doubleForKey:(NSString *)key withDefault:(double)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp doubleValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}



-(NSTimeInterval)timeIntervalForKey:(NSString *)key withDefault:(NSTimeInterval)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp doubleValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

-(NSInteger)intForKey:(NSString *)key withDefault:(NSInteger)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp intValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

-(long long)longLongForKey:(NSString *)key withDefault:(long long)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
             return [temp longLongValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

-(long)longForKey:(NSString *)key withDefault:(long)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp longValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

-(int)intValueForKey:(NSString *)key withDefault:(int)defVal{
    @try {
        id temp = [self objectForKey:key];
        if(temp != nil)
        {
            return [temp intValue];
        }
        else
        {
            return defVal;
        }
    }
    @catch (NSException *exception) {
        return defVal;
    }
}

@end
