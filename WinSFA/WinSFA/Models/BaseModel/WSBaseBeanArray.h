//
//  WSBaseBeanArray.h
//  WinSFA
//
//  Created by yang on 15/10/14.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBaseBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *beanArray;

- (instancetype)initWithObject:(id)object;

- (instancetype)initWithObject:(id)object andKey:(NSString *)parserkey;

- (Class)getBeanSubclass;

- (NSString *)getDefaultParseKey;

@end
