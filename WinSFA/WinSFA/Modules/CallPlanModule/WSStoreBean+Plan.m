//
//  StoreBean+Plan.m
//  WinChannelFrameWork
//
//  Created by Lei Cai on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSStoreBean+Plan.h"
#import <objc/runtime.h>

@implementation WSStoreBean (Plan)

@dynamic bPlanned;

NSString * const kStorePlan = @"kStorePlan";
NSString * const kStoreState = @"kStoreState";
NSString * const kStoreStateUrl = @"kStoreStateUrl";


- (void)setBPlanned:(BOOL)bPlanned
{
    objc_setAssociatedObject(self, (__bridge const void *)(kStorePlan), [NSNumber numberWithBool:bPlanned], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)bPlanned
{
	return [(NSNumber*)objc_getAssociatedObject(self, (__bridge const void *)(kStorePlan)) boolValue];
}

- (void)setState:(NSString *)state{
     objc_setAssociatedObject(self, (__bridge const void *)(kStoreState), (NSString *)state,OBJC_ASSOCIATION_RETAIN);
}
- (NSString *)state{
    
     return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kStoreState));
}

- (void)setStateUrl:(NSString *)stateUrl{
    
   objc_setAssociatedObject(self, (__bridge const void *)(kStoreStateUrl), (NSString *)stateUrl,OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)stateUrl{
    
  return (NSString *)objc_getAssociatedObject(self, (__bridge const void *)(kStoreStateUrl));
}
@end
