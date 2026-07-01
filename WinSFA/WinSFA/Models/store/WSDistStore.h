//
//  DistStore.h
//  WinChannelFrameWork
//
//  Created by ygs on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define DISTSTORE @ "diststore"
#import <Foundation/Foundation.h>

@interface WSDistStore : NSObject

@property (nonatomic, strong) NSMutableArray *distStoreArray;

- (id)initWithObject:(id)object;

@end
