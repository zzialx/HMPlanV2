//
//  ServerIPController.h
//  WinChannelFrameWork
//
//  Created by ygs on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ServerIP @ "serverURL"

@interface WSServerIPController : NSObject

@property (nonatomic, strong) NSString *ServerIPString;

- (id)initWithObject:(id)object;

@end
