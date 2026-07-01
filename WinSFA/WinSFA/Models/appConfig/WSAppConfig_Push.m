//
//  AppConfig_Push.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_Push.h"
#import "WinSFA.h"
@implementation WSAppConfig_Push
@synthesize y;
@synthesize u;
@synthesize d;
@synthesize empId;
-(id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            y = [dic objectForKey:APPCONFIG_Y];
            u = [dic objectForKey:APPCONFIG_U];
            d = [dic objectForKey:APPCONFIG_D];
            empId = [dic objectForKey:APPCONFIG_EMPID];
        }
    }
    
    return self;
}

@end
