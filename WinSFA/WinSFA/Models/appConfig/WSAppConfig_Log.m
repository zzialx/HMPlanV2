//
//  AppConfig_Log.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_Log.h"
#import "WinSFA.h"
@implementation WSAppConfig_Log
@synthesize Log_empId;
@synthesize Log_value;
-(id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            Log_value = [dic objectForKey:APPCONFIG_LOG_VALUE];
            Log_empId = [dic objectForKey:APPCONFIG_EMPID];
        }
    }
    
    return self;
}

@end
