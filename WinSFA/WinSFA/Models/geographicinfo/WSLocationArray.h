//
//  WSLocationArray.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSLocation.h"

#define CITYNAMES @"citynames"

@interface WSLocationArray : NSObject

@property (nonatomic, strong) NSMutableArray *locationArray;

- (void)initLocationWithArray:(NSArray *)array;
//- (id)initWithObject:(id)object;
- (id)initWithObject:(id)object andNode:(NSString *)aNode;

@end
