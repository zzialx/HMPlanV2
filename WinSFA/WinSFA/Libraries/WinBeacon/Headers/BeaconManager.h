//
//  BeaconManager.h
//  WCBeaconSDK
//
//  Created by WinChannel on 14-2-19.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "WCBeaconMonitor.h"
#import "BeaconRegionNotificationTrans.h"
#import "BeaconManagerDelegate.h"

@interface BeaconManager : NSObject <WCBeaconMonitorDelegate, BeaconRegionNotificationTransDelegate>
{
    __unsafe_unretained id<BeaconManagerDelegate> _delegate;
}

@property (nonatomic, assign) BOOL forceNotificationSwitch;
@property (nonatomic, assign) BOOL debugForceNotification;
@property (nonatomic, assign) BOOL debugNotifyLocalMessage;
@property (nonatomic, assign) id<BeaconManagerDelegate> delegate;
@property(nonatomic, strong) NSNumber *beaconCallType;
@property(nonatomic, strong) NSArray *configBeaconRegions;

- (void)startBeaconManagerInRegions:(NSArray *)regions range:(CGFloat)range repeatInterval:(CGFloat)interval type:(WCBeaconMonitorType)type;
- (void)stopBeaconManager;
- (BOOL)isBeaconManagerStarted;
- (BOOL)isInBackground;
- (void)willEnterForeground;
- (void)didEnterBackground;
- (NSArray *)currentInRegions;
- (NSArray *)getBeacons;

+ (BeaconManager *)sharedInstance;

@end
