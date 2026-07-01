//
//  WSConfigObject.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-18.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSConfigObject : NSObject

@property (nonatomic, assign) BOOL  isEnableBeacon;
@property (nonatomic, assign) int   beaconCheckTime;    //扫描时间间隔
@property (nonatomic, assign) int   beaconUpdateTime;   //上报时间间隔
@property (nonatomic, assign) int   beaconStartTime;
@property (nonatomic, assign) int   beaconEndTime;
@property (nonatomic, strong) NSString  *beaconUUid;

+ (WSConfigObject*) getInstance;

- (void) initializationWithDictionary:(NSDictionary*)dic;
- (int)getCurrentHour;

@end
