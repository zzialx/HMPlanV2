//
//  AppConfig_App.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_App.h"
#import "WinSFA.h"
@implementation WSAppConfig_App
@synthesize App_empId;
@synthesize App_value;
-(id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            App_value = [dic objectForKey:APPCONFIG_APP_VALUE];
            App_empId = [dic objectForKey:App_empId];
        }
    }
    
    return self;
}

@end
