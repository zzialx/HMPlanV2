//
//  StoreBean+Plan.h
//  WinChannelFrameWork
//
//  Created by Lei Cai on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSStoreBean.h"
#import <Foundation/Foundation.h>

@interface WSStoreBean (Plan)

@property (nonatomic, assign) BOOL bPlanned;
@property (nonatomic, strong) NSString *stateUrl;
@property (nonatomic, strong) NSString *state;
@end
