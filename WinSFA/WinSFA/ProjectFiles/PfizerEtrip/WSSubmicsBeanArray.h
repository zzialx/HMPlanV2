//
//  WSSubmicsBeanArray.h
//  WinSFA
//
//  Created by zhangke on 14-5-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSSubmicsBean.h"

#define SUBMICS       @ "submics"


@interface WSSubmicsBeanArray : NSObject

@property (nonatomic, strong) NSMutableArray *submicsArray;

- (id)initWithObject:(id)object;

@end
