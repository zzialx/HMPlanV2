//
//  WCBeaconMonitor.h
//  WCBeaconSDK
//
//  Created by WinChannel on 14-1-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@class WCBeaconRegion;
@class WCBeaconMonitor;

@protocol WCBeaconMonitorDelegate <NSObject>

@optional
- (void)beaconMonitor:(WCBeaconMonitor *)monitor didRangeBeacons:(NSArray *)beacons inRegion:(WCBeaconRegion *)region;
- (void)beaconMonitor:(WCBeaconMonitor *)monitor inRegion:(WCBeaconRegion *)region;
- (void)beaconMonitor:(WCBeaconMonitor *)monitor outRegion:(WCBeaconRegion *)region;

@end

typedef NS_ENUM(NSInteger, WCBeaconMonitorType) {
	WCBeaconMonitorTypeDefault,
	WCBeaconMonitorTypeIgnoreUnknownBeacons,
	WCBeaconMonitorTypeCacheBeacons
};

@interface WCBeaconMonitor : NSObject <CLLocationManagerDelegate>
{
    __unsafe_unretained id<WCBeaconMonitorDelegate> _delegate;
}

@property (nonatomic, assign) id<WCBeaconMonitorDelegate> delegate;

- (void)startMonitor:(NSArray *)regions repeatInterval:(CGFloat)interval type:(WCBeaconMonitorType)type;
- (void)stopMonitor;
- (BOOL)isMonitorStarted;

+ (CLBeacon *)findNearestBeacon:(NSArray *)beacons;
+ (NSArray *)findBeaconsInRange:(CGFloat)range beacons:(NSArray *)beacons;

@end
