//
//  BeaconRegionNotificationTrans.h
//  WCBeaconSDK
//
//  Created by WinChannel on 14-2-20.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WCBeaconRegion;
@class BeaconRegionNotificationTrans;

@protocol BeaconRegionNotificationTransDelegate <NSObject>

- (void)transCompleted:(BeaconRegionNotificationTrans *)trans;

@end

@interface BeaconRegionNotificationTrans : NSObject
{
    WCBeaconRegion *_region;
    NSMutableArray *_beacons;
    __unsafe_unretained id<BeaconRegionNotificationTransDelegate> _delegate;
}

@property (nonatomic, strong) WCBeaconRegion *region;
@property (nonatomic, strong) NSMutableArray *beacons;
@property (nonatomic, assign) id<BeaconRegionNotificationTransDelegate> delegate;

- (void)startWithRegion:(WCBeaconRegion *)region;
- (void)stop;

@end
