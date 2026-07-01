//
//  WSMapValidate.m
//  WinSFA
//
//  Created by heju on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMapValidate.h"
#import "I_W_Validate.h"
#import "I_W_BuildInfo.h"
#import "RegexKitLite.h"
#import "WSWidget.h"
#import "WSConstant.h"
#import "WSMessageObject.h"
#import "WSMessageCenter.h"
#import "BlockAlertView.h"
#import "WSMapPanel.h"
#import "WSInoutStoreTable.h"
#import "WSAcvtViewController.h"

#define UPLOAD_LUA_FUNTION_ONSUMIT  @"function onSubmit()"
#define LIMIT_INTERVAL              30.0f

@implementation WSMapValidate

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo {
    
    return YES;
}

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withValue:(NSObject *)value {

    return YES;
}

- (BOOL)executeValidate:(NSObject<I_W_BuildInfo> *)buildinfo withWidget:(WSWidget *)widget {
    
    WSMapPanel *mapPanel = (WSMapPanel *)widget;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval differenceInterval = [currentDate timeIntervalSinceDate:mapPanel.mapInitDate];
   
    if ([[buildinfo getISRequire] isEqualToString:@"1"] && !mapPanel.isGpsReady) {
        
        if ([[buildinfo getLocationType] isEqualToString:@"2"] && mapPanel.hasRedisLocation) {
            
            return YES;
        }
        
        CGFloat locationTimeout = LIMIT_INTERVAL;
        NSString *timeConfig = [[NSUserDefaults standardUserDefaults]objectForKey:LOCATION_TIMEOUT];
        if (timeConfig && [timeConfig floatValue] > 0) {
            
            locationTimeout = [timeConfig floatValue];
        }
        
        if ((differenceInterval < locationTimeout)) {
            
            NSTimeInterval remdinderInterval = locationTimeout - differenceInterval;
            NSString *message = [NSString stringWithFormat:@"%@,%@%0.f秒",
                                 NSLocalizedString(@"gps_fail_lable",nil), NSLocalizedString(@"location_wait",nil), remdinderInterval];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            return NO;
        }
    }
    
    if ([mapPanel.delegate respondsToSelector:@selector(executeLuaScript:script:funcName:widget:)] &&
        !([[buildinfo getIsHidden] isEqualToString:@"0"] && !mapPanel.isGpsReady)) {
        
        NSString *luaScriptForsetValue = [WSLuaExecutorManager getSubLuaScriptWith:[buildinfo getLuaScript] ByFuntionName:UPLOAD_LUA_FUNTION_ONSUMIT];
        [mapPanel.delegate executeLuaScript:buildinfo script:luaScriptForsetValue funcName:UPLOAD_LUA_FUNTION_ONSUMIT widget:mapPanel];
    }
    //经确认二次刷新地图的需求，客户不要了，脚本也还原了，所以注释掉了这部分代码，不再校验了
//    if ([WSLuaExecutorManager shareInstance].isErrorFromScript) {
//        return NO;
//    }
    
    return YES;
}

@end
