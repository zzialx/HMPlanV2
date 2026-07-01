//
//  AppConfig_Sensor.m
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSAppConfig_Sensor.h"
#import "WinSFA.h"
@implementation WSAppConfig_Sensor
@synthesize Sensor_value;
@synthesize sensor_empId;
-(id)initWithObject:(id)object
{
    if (nil == object) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            Sensor_value = [dic objectForKey:APPCONFIG_SENSOR_VALUE];
            sensor_empId = [dic objectForKey:APPCONFIG_EMPID];
        }
    }
    return self;
}

@end
