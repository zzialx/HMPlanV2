//
//  WCBeaconRegion.h
//  WCBeaconSDK
//
//  Created by WinChannel on 14-1-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

@interface WCBeaconRegion : NSObject

@property (nonatomic, readonly) NSUUID *proximityId;
@property (nonatomic, readonly) NSString *identifier;

- (id)initWithProximityId:(NSString *)proximityId identifier:(NSString *)identifier;

@end
