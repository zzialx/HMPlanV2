//
//  AppConfig_Push.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_Push : NSObject
{
    NSString    *y;
    NSString    *u;
    NSString    *d;
    NSString    *empId;
}
@property (nonatomic, strong) NSString  *y;
@property (nonatomic, strong) NSString  *u;
@property (nonatomic, strong) NSString  *d;
@property (nonatomic, strong) NSString  *empId;
- (id)initWithObject:(id)object;
@end
