//
//  GPSUpload.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "WSGPSUpload.h"
#import "WSFuncsBean.h"

#import "WSLocationManager.h"

@interface WSGPSUpload : NSObject <CLLocationManagerDelegate>
{}
@property (strong) CLLocationManager    *m_locManager;
@property (nonatomic, strong) WSFuncsBean *m_currentFuncs;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)startLocation;

@end
