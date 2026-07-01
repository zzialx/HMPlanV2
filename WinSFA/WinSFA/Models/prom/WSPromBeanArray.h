//
//  PromBeanArray.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROMS @ "proms"
@interface WSPromBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *promArray;

- (id)initWithObject:(id)object;

@end
