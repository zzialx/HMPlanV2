//
//  WSBeaconManager.h
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/8.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBeaconManager : NSObject

+ (WSBeaconManager*) getInstance;

- (void) checkBeacon;
- (void) startBeaconWithUUID:(NSString*)uuidStr withStoreId:(NSString*)storeIdStr;
- (void) removeBeaconWithStoreId:(NSString*)storeIdStr;

- (void) didEnterBackground;
- (void) willEnterForeground;

@end


@interface WSBeaconObject : NSObject<NSCoding>
@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) NSString *uuids;
@property (nonatomic, strong) NSString *synDate;

-(id) initWithStoreId:(NSString*)storeId withUuids:(NSString*)uuid;
@end