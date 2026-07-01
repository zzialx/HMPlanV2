//
//  AppConfig_Sensor.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAppConfig_Sensor : NSObject
{
    NSString    *Sensor_value;
    NSString    *sensor_empId;
}
@property (nonatomic, strong) NSString  *Sensor_value;
@property (nonatomic, strong) NSString  *sensor_empId;
- (id)initWithObject:(id)object;
@end
