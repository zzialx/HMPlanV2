//
//  WSBeaconManager.m
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/8.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSBeaconManager.h"
#import "BeaconManager.h"
#import "WCBeaconRegion.h"
#import "WSConfigObject.h"
#import "WSRequestHelper.h"

#define BEACON_STORARY_KEY  @"beaconStroaryKey"
#define BEACON_OBJ_KEY      @"beaconObjKey"
#define STORE_ID_KEY        @"storeIdKey"

@implementation WSBeaconObject

-(id) initWithStoreId:(NSString*)storeId withUuids:(NSString*)uuid
{
    if (!storeId || !uuid) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.storeId = storeId;
        self.uuids = uuid;
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.storeId forKey:@"storeId"];
    [aCoder encodeObject:self.uuids forKey:@"uuids"];
    [aCoder encodeObject:self.synDate forKey:@"synDate"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.storeId = [aDecoder decodeObjectForKey:@"storeId"];
        self.uuids = [aDecoder decodeObjectForKey:@"uuids"];
        self.synDate = [aDecoder decodeObjectForKey:@"synDate"];
    }
    
    return self;
}

@end

@interface WSBeaconManager () <BeaconManagerDelegate> {
    BOOL        isBeaconing;
    BOOL        runUploadQueue;
}
@property (nonatomic, retain) NSMutableDictionary *dataDictionary;    //storeId:WSBeaconObject
@end

@implementation WSBeaconManager
static WSBeaconManager *instance = nil;
+ (WSBeaconManager*) getInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance == nil) {
            instance = [[WSBeaconManager alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (nil == instance) {
            instance = [super allocWithZone:zone];
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:BEACON_STORARY_KEY];
            if (data) {
                instance.dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }else {
                instance.dataDictionary = [NSMutableDictionary dictionary];
            }
            return instance;
        }
    }
    
    return nil;
}

-(id)copy
{
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;    //如果未MRC，个人感觉应该使用 [self retain]
}

#if __has_feature(objc_arc)
#else
- (id) retain
{
    return self;
}

- (unsigned) retainCount
{
    return NSUIntegerMax;
}

- (oneway void) release
{
    // Do nothing
}

- (id) autorelease
{
    return self;
}
#endif

#pragma mark - public method
- (void) checkBeacon
{
    LogInfo(@"isBeaconing:%d, count:%lu", isBeaconing, (unsigned long)self.dataDictionary.count);
    if (IOS7_OR_LATER && self.dataDictionary.count > 0 && !isBeaconing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkBeacon) object:nil];
        
        [self.dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            WSBeaconObject *tmpObj = (WSBeaconObject*)obj;
            if (tmpObj.synDate) {
                [self doBeacon];
                *stop = YES;
            }
        }];
        
//        if ([self isCurrentTimeInBeaconPeriod]) {
//            //39C4BCF5-7DB7-43AC-BAB2-E9C09E37902C
//            [BeaconManager sharedInstance].delegate = self;
//            
//            NSMutableArray *regions = [NSMutableArray array];
//            NSArray *beaconUUids = [[WSConfigObject getInstance].beaconUUid componentsSeparatedByString:@","];
//            [beaconUUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                WCBeaconRegion *region = [[WCBeaconRegion alloc] initWithProximityId:obj identifier:[NSString stringWithFormat:@"vguidebeacon%d", idx]];
//                [regions addObject:region];
//            }];
//            
//            [[BeaconManager sharedInstance] startBeaconManagerInRegions:regions range: 10 repeatInterval: 2.f type: WCBeaconMonitorTypeCacheBeacons];
//        }else {
//            [self dealyStartBeacon];
//        }
    }
}

- (void) startBeaconWithUUID:(NSString*)uuidStr withStoreId:(NSString*)storeIdStr
{
    LogInfo(@"uuid:%@, storeid:%@", uuidStr, storeIdStr);
    if (!uuidStr || !storeIdStr) {
        return;
    }
    
    if (IOS7_OR_LATER) {
        if (![self isExsitStoreBeaconWithStoreId:storeIdStr]) {
            WSBeaconObject *tmpObj = [[WSBeaconObject alloc] initWithStoreId:storeIdStr withUuids:uuidStr];
            if (tmpObj) {
                [self.dataDictionary setObject:tmpObj forKey:storeIdStr];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.dataDictionary];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:BEACON_STORARY_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else {
                LogError(@"Beacon object create error: uuid=%@, stroeid=%@", uuidStr, storeIdStr);
            }
        }
        [self doBeacon];
    }
}

- (void) removeBeaconWithStoreId:(NSString*)storeIdStr
{
    LogInfo(@"storeid:%@", storeIdStr);
    if (storeIdStr) {
        [self.dataDictionary removeObjectForKey:storeIdStr];
        
        if (self.dataDictionary.count == 0) {
            LogInfo(@"stopBeaconManager");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            
            isBeaconing = NO;
            runUploadQueue = NO;
            [[BeaconManager sharedInstance] stopBeaconManager];
        }
    }
}

- (void) didEnterBackground
{
    if (IOS7_OR_LATER && isBeaconing) {
        [[BeaconManager sharedInstance] didEnterBackground];
    }
}

- (void) willEnterForeground
{
    if (IOS7_OR_LATER && isBeaconing) {
        [[BeaconManager sharedInstance] willEnterForeground];
    }
}

#pragma mark - private method
- (BOOL) isExsitStoreBeaconWithStoreId:(NSString*)storeId
{
    if (storeId) {
        WSBeaconObject *tmpObj = [self.dataDictionary objectForKey:storeId];
        if (tmpObj) {
            return YES;
        }
    }
    
    return NO;
}

- (void) doBeacon
{
    LogInfo(@"isBeaconing:%d", isBeaconing);
    if (!isBeaconing) {
        isBeaconing = YES;
        
        //39C4BCF5-7DB7-43AC-BAB2-E9C09E37902C
        [BeaconManager sharedInstance].delegate = self;
        
        NSMutableArray *regions = [NSMutableArray array];
        [self.dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            WSBeaconObject *tmp = (WSBeaconObject*)obj;
            NSArray *beaconUUids = [tmp.uuids componentsSeparatedByString:@","];
            [beaconUUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WCBeaconRegion *region = [[WCBeaconRegion alloc] initWithProximityId:obj identifier:[NSString stringWithFormat:@"vguidebeacon%lu", (unsigned long)idx]];
                [regions addObject:region];
            }];
        }];
        
        if (regions.count > 0) {
            [[BeaconManager sharedInstance] startBeaconManagerInRegions:regions range:10 repeatInterval:2.f type:WCBeaconMonitorTypeCacheBeacons];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopBeaconWithSuccess:) object:[NSNumber numberWithBool:NO]];
            [self performSelector:@selector(stopBeaconWithSuccess:) withObject:[NSNumber numberWithBool:NO] afterDelay:[WSConfigObject getInstance].beaconCheckTime];
        }
    }
}

- (void) stopBeaconWithSuccess:(NSNumber*)isSuccess
{
    isBeaconing = NO;
    [[BeaconManager sharedInstance] stopBeaconManager];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkBeacon) object:nil];
    
    NSString *msg = nil;
    if ([isSuccess boolValue]) {
        msg = NSLocalizedString(@"beacon_device_enter", @"beacon_device_enter");
//        [BlockAlertView showInfoAlertWithTitle:nil message:NSLocalizedString(@"beacon_device_enter", @"beacon_device_enter")];
    }else {
        msg = NSLocalizedString(@"beacon_device_disconnect", @"beacon_device_disconnect");
//        [BlockAlertView showInfoAlertWithTitle:nil message:NSLocalizedString(@"beacon_device_disconnect", @"beacon_device_disconnect")];
    }
    
    BlockAlertView *alertView = [BlockAlertView alertWithTitle:nil message:msg];
    [alertView addButtonWithTitle:@"OK" block:^{
        [self performSelector:@selector(checkBeacon) withObject:nil afterDelay:[WSConfigObject getInstance].beaconCheckTime];
    }];
    [alertView show];
    
    [self startUploadQueue];
}

- (void) doUploadBeacon
{
    LogInfo();
    
    NSDate *curDate = [WSCurrentTime getCurrentServerDate];
    [[NSUserDefaults standardUserDefaults] setObject:curDate forKey:BEACON_FOUND_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WSRequestHelper* l_upload = [WSRequestHelper shareInstance];
    [self.dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        WSBeaconObject *tmpObj = (WSBeaconObject*)obj;
        if (tmpObj.synDate) {
            [l_upload uploadBeaconWithUUid:tmpObj.uuids withStoreId:tmpObj.storeId NotifyName:nil];
            tmpObj.synDate = nil;
        }else {
            [l_upload uploadBeaconWithUUid:@"0" withStoreId:tmpObj.storeId NotifyName:nil];
        }
    }];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.dataDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:BEACON_STORARY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSelector:@selector(doUploadBeacon) withObject:nil afterDelay:[WSConfigObject getInstance].beaconUpdateTime];
}

- (void) startUploadQueue
{
    if (!runUploadQueue) {
        runUploadQueue = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doUploadBeacon) object:nil];
        [self doUploadBeacon];
    }
}

#pragma mark - BeaconManagerDelegate method
- (void)onFound:(WCBeaconRegion *)region beacons:(NSArray *)beacons
{
    LogInfo(@"found beacons:%@", beacons);
    
//    NSString *str = nil;
//    if (beacons && [beacons count] > 0) {
//        CLBeacon *beacon = [beacons objectAtIndex:0];
//        if (beacon) {
//            str = beacon.proximityUUID.UUIDString;
//        }
//    }
    
    [beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CLBeacon class]]) {
            CLBeacon *beacon = (CLBeacon*)obj;
            NSString *str = beacon.proximityUUID.UUIDString;
            [self.dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                WSBeaconObject *tmpObj = (WSBeaconObject*)obj;
                if ([tmpObj.uuids rangeOfString:str].length > 0) {
                    tmpObj.synDate = [WSCurrentTime getDateString];
                    *stop = YES;
                }
            }];
        }
    }];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self.dataDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:BEACON_STORARY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopBeaconWithSuccess:) object:[NSNumber numberWithBool:NO]];
    [self stopBeaconWithSuccess:[NSNumber numberWithBool:YES]];
}


//- (void)onLost:(WCBeaconRegion *)region
//{
//    NSLog(@"Leave beacon Region!");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onLost" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//}
//
//-(void)onChanged:(WCBeaconRegion *)region beacons:(NSArray *)beacons
//{
//    NSLog(@"beacon changed!");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onChanged" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//}

- (BOOL)isCurrentTimeInBeaconPeriod
{
    WSConfigObject *configObj = [WSConfigObject getInstance];
    int hour = [configObj getCurrentHour];
    if (hour >= configObj.beaconStartTime && hour < configObj.beaconEndTime) {
        NSDate *lastBeaconDate = [[NSUserDefaults standardUserDefaults] objectForKey:BEACON_FOUND_DATE];
        if (lastBeaconDate) {
            NSDate *curDate = [WSCurrentTime getCurrentServerDate];
            int space = [curDate timeIntervalSinceDate:lastBeaconDate];
            if (space > configObj.beaconCheckTime) {
                return YES;
            }else {
                return NO;
            }
        }
        return YES;
    }
    else {
        return NO;
    }
}

- (void) dealyStartBeacon
{
    WSConfigObject *configObj = [WSConfigObject getInstance];
    int hour = [configObj getCurrentHour];
    if (hour >= configObj.beaconStartTime && hour < configObj.beaconEndTime) {
        NSDate *lastBeaconDate = [[NSUserDefaults standardUserDefaults] objectForKey:BEACON_FOUND_DATE];
        if (lastBeaconDate) {
            NSDate *curDate = [WSCurrentTime getCurrentServerDate];
            int dealy = [curDate timeIntervalSinceDate:lastBeaconDate];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * (configObj.beaconCheckTime - dealy))), dispatch_get_main_queue(), ^{
                [BeaconManager sharedInstance].delegate = self;
                
                NSMutableArray *regions = [NSMutableArray array];
                NSArray *beaconUUids = [[WSConfigObject getInstance].beaconUUid componentsSeparatedByString:@","];
                [beaconUUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    WCBeaconRegion *region = [[WCBeaconRegion alloc] initWithProximityId:obj identifier:[NSString stringWithFormat:@"vguidebeacon%lu", (unsigned long)idx]];
                    [regions addObject:region];
                }];
                
                [[BeaconManager sharedInstance] startBeaconManagerInRegions:regions range: 10 repeatInterval: 2.f type: WCBeaconMonitorTypeCacheBeacons];
            });
        }
    }else if (hour < configObj.beaconStartTime) {
        NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        NSDateFormatter *formatTime = [NSDateFormatter standardDateFormatter];
        [formatTime setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [NSString stringWithFormat:@"%@ %d:00:00", bizDate, configObj.beaconStartTime];
        NSDate *startDate = [formatTime dateFromString:strDate];
        
        NSDate *curDate = [WSCurrentTime getCurrentServerDate];
        int dealy = [startDate timeIntervalSinceDate:curDate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * dealy)), dispatch_get_main_queue(), ^{
            [BeaconManager sharedInstance].delegate = self;
            
            NSMutableArray *regions = [NSMutableArray array];
            NSArray *beaconUUids = [[WSConfigObject getInstance].beaconUUid componentsSeparatedByString:@","];
            [beaconUUids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                WCBeaconRegion *region = [[WCBeaconRegion alloc] initWithProximityId:obj identifier:[NSString stringWithFormat:@"vguidebeacon%lu", (unsigned long)idx]];
                [regions addObject:region];
            }];
            
            [[BeaconManager sharedInstance] startBeaconManagerInRegions:regions range: 10 repeatInterval: 2.f type: WCBeaconMonitorTypeCacheBeacons];
        });
    }
}

@end
