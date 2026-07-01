//
//  BeaconManagerDelegate.h
//  WCBeaconSDK
//
//  Created by WinChannel on 14-2-19.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCBeaconRegion;
@class CLBeacon;

@protocol BeaconManagerDelegate <NSObject>

@optional
- (void)onFound:(WCBeaconRegion *)region beacons:(NSArray *)beacons;
- (void)onLost:(WCBeaconRegion *)region;
- (void)onChanged:(WCBeaconRegion *)region beacons:(NSArray *)beacons;
@end
