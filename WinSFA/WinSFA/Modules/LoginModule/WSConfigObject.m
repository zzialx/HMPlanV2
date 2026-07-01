//
//  WSConfigObject.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-11-18.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSConfigObject.h"

@implementation WSConfigObject


static WSConfigObject *instance = nil;
+ (WSConfigObject*) getInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        if (instance == nil) {
            instance = [[WSConfigObject alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (nil == instance) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    
    return instance;
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

- (void) initializationWithDictionary:(NSDictionary*)dic
{
    if (dic) {
        
        NSString *tmp = [self parseDicValue:dic withKey:ENABLE_BEACON];
        self.isEnableBeacon = tmp ? [tmp boolValue] : NO;
        
        tmp = [self parseDicValue:dic withKey:BEACON_CHECK_TIME];
        self.beaconUpdateTime = tmp ? [tmp intValue] : 1800;
        
        tmp = [self parseDicValue:dic withKey:BEACON_SCAN_TIME];
        self.beaconCheckTime = tmp ? [tmp intValue] : 900;
        
        tmp = [self parseDicValue:dic withKey:BEACON_START_TIME];
        self.beaconStartTime = tmp ? [tmp intValue] : 0;
        
        tmp = [self parseDicValue:dic withKey:BEACON_END_TIME];
        self.beaconEndTime = tmp ? [tmp intValue] : 0;
        
        self.beaconUUid = [self parseDicValue:dic withKey:BEACON_UUID];
    }
}

- (int)getCurrentHour
{
    NSDateFormatter *fomatter = [NSDateFormatter standardDateFormatter];
    [fomatter setDateFormat:@"HH"];
    NSString *time = [fomatter stringFromDate:[WSCurrentTime getCurrentServerDate]];
    
    return [time intValue];
}


#pragma mark - private method
- (NSString*)parseDicValue:(NSDictionary*)dic withKey:(NSString*)key
{
    id value = [dic objectForKey:key];
    if (value && ![value isKindOfClass:[NSNull class]]) {
        return [NSString stringWithValue:value];
    }
    return nil;
}

@end
