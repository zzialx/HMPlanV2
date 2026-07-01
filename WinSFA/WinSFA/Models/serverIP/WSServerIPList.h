//
//  ServerIPArrayController.h
//  WinChannelFrameWork
//
//  Created by ygs on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSServerIPController.h"

@interface WSServerIPList : NSObject

@property (nonatomic, strong) NSMutableArray *serverIPArray;

- (id)initWithObject:(id)object;

@end
