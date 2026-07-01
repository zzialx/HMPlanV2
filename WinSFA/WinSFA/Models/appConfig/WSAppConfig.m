//
//  AppConfig.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig.h"
#import "WSAppConfig_App.h"
#import "WSAppConfig_Color.h"
#import "WSAppConfig_InfoBK.h"
#import "WSAppConfig_Log.h"
#import "WSAppConfig_Push.h"
#import "WSAppConfig_Sensor.h"
#import "WinSFA.h"
#import "WSServerIPList.h"
#import "WSAppData.h"

@implementation WSAppConfig
@synthesize empId;
@synthesize appConfigArr; 
- (id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            empId = [NSString stringWithValue:[dic objectForKey:APPCONFIG_EMPID]];
            appConfigArr=[[NSMutableArray alloc]initWithObjects:[dic objectForKey:APPCONFIG_APP],[dic objectForKey:APPCONFIG_COLOR],[dic objectForKey:APPCONFIG_INFOBK],[dic objectForKey:APPCONFIG_LOG],[dic objectForKey:APPCONFIG_PUSH],[dic objectForKey:APPCONFIG_SENSOR],nil];
        }
    }
    return self;
}


@end
