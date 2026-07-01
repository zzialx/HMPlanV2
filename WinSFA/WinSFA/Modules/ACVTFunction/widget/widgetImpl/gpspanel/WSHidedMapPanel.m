//
//  WSHidedMapPanel.m
//  WinSFA
//
//  Created by xiajl on 15/3/24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSHidedMapPanel.h"
#import "I_W_BuildInfo.h"
#import "WSLocationManager.h"

@implementation WSHidedMapPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        return self;
    }
    return nil;
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    [self locationMe];
    [self setFrame:CGRectZero];
}

-(void)locationMe{
    
    DDLogInfo(@"使用通知方式获取定位回调");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFinished:) name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    [[WSLocationManager getInstance] startUpdatingLocationWithActive:YES];
}

- (void)locationFinished:(NSNotification *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:locationAddressManagerDidUpdatedFinishedNotification object:nil];
    
    NSDictionary *userInfo = [sender userInfo];
    NSError *error = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedNotificationErrorKey];
    WSLocationDescribe *tmpLocationDescribe = [userInfo objectForKey:locationAddressManagerDidUpdatedFinishedKey];
    
    if (error) {
        LogError(@"定位失败");
    }else{
        LogInfo(@"定位成功：aLocationDescribe=====%@",tmpLocationDescribe);
        if (tmpLocationDescribe.location && (tmpLocationDescribe.location.coordinate.longitude != 0 && tmpLocationDescribe.location.coordinate.latitude != 0)) {
            self.locationDescribe = tmpLocationDescribe;
            self.location = tmpLocationDescribe.location;
            self.isGpsReady = YES;
        }
    }
    
}

- (void)secondUpdateLocaiton {
    __weak typeof(self)  baseView = self;
    [[WSLocationManager getInstance] startUpdateUserLocationWithBlock:^(WSLocationDescribe *aLocationDescribe, NSError *error) {
        __strong typeof(baseView) secondBaseView = baseView;
        if (aLocationDescribe.location
            && (aLocationDescribe.location.coordinate.longitude != 0
                && aLocationDescribe.location.coordinate.latitude != 0)) {
                secondBaseView.locationDescribe = aLocationDescribe;
                secondBaseView.location = aLocationDescribe.location;
                secondBaseView.isGpsReady = YES;
            }
    }];
}

-(NSObject *)getResultDirectly{
    
    return [WSLocationManager getLocationUploadDataWithLocation:self.location andAddress:self.locationDescribe.detailAddress];
}


@end
