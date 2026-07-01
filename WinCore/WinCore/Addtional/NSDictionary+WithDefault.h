//
//  NSDictionary+RNAdditions.h
//  RRSpring
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//



@interface NSDictionary (WithDefault)

/*
 返回指定key的字符串值
 没有指定key的值，返回默认值
 */
-(NSString *)stringForKey:(NSString *)key withDefault:(NSString *)defVal;
/*
 返回指定key的float值
 没有指定key的值，返回默认值
 */
-(CGFloat)floatForKey:(NSString *)key withDefault:(CGFloat)defVal;
-(double)doubleForKey:(NSString *)key withDefault:(double)defVal;
/*
 返回指定key的timeInterval值
 没有指定key的值，返回默认值
 */
-(NSTimeInterval)timeIntervalForKey:(NSString *)key withDefault:(NSTimeInterval)defVal;
/*
 返回指定key的int值
 没有指定key的值，返回默认值
 */
-(NSInteger)intForKey:(NSString *)key withDefault:(NSInteger)defVal;

-(long long)longLongForKey:(NSString *)key withDefault:(long long)defVal;

-(long)longForKey:(NSString *)key withDefault:(long)defVal;

-(int)intValueForKey:(NSString *)key withDefault:(int)defVal;


@end
