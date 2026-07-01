//
//  GPSUpload.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-10.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSGPSUpload.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"

@implementation WSGPSUpload
@synthesize m_locManager= _m_locManager;
@synthesize m_currentFuncs = _m_currentFuncs;

-(id)initWithFuncs:(WSFuncsBean*)funcs
{
    if(funcs == nil)
        return nil;
    _m_currentFuncs = funcs;
    return [self init];
}

-(void)startLocation
{
    [self performSelector:@selector(startLocation) withObject:nil afterDelay:[self.m_currentFuncs.unredo floatValue]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationFinished:) name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:NO];
}

- (void)updateLocationFinished:(NSNotification *)sender
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    
    NSError *error = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedErrorKey];
    CLLocation *location = [userInfo objectForKey:LBSManagerDidUpdatedLocationFinishedLocationKey];
    
    if (!error && location) {
        
        [self uploadLocation:location];
    }
}

- (id)init
{
    self = [super init];
    if (self) {

        if (![CLLocationManager locationServicesEnabled])
        {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }
        self.m_locManager = [[CLLocationManager alloc] init];
        self.m_locManager.delegate = self;
        self.m_locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.m_locManager.distanceFilter = 5.0f; // in meters
        
        //[self startLocation];
    }
    
    return self;
}

-(void)uploadLocation:(CLLocation*)aLocation;
{
    LogInfo(@"UPLOAD PASSIVE LOCATION");

    WSRequestHelper* l_upload = [WSRequestHelper shareInstance];
    if (aLocation.horizontalAccuracy < 0) 
		return;
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    WSLocationDescribe *locationDescribe = [[WSLocationDescribe alloc] initWithLocation:aLocation cityName:nil detailAddress:nil error:nil];
    [l_upload uploadBackGroundGPSWithLocation:locationDescribe NotifyName:notifyID];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LBSManagerDidUpdatedLocationFinishedNotification object:nil];
}
#pragma location delegate

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    //先stop后start
//    [self.m_locManager stopUpdatingLocationWithActive];
//    [self performSelector:@selector(startLocation) withObject:nil afterDelay:self.m_currentFuncs.unredo];
//	return;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    [self uploadLocation:newLocation];
//    [self.m_locManager stopUpdatingLocationWithActive];
//    
//    [self performSelector:@selector(startLocation) withObject:nil afterDelay:self.m_currentFuncs.unredo];
//    return;
//}
@end
