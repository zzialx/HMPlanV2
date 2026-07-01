//
//  WSEnvrionment.m
//  WinSFA
//
//  Created by winchannel on 15/4/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSEnvrionment.h"
//============================================================================================================================================

#pragma mark - 系统环境变量 延展(内部)
@interface WSEnvrionment ()

@property (nonatomic, strong) NSDictionary *configFileDicCache; //配置字典

@end
//============================================================================================================================================

#pragma mark - 系统环境变量
@implementation WSEnvrionment

#pragma mark - 共享实例方法
+ (WSEnvrionment *)shareInstance {
    
    static WSEnvrionment *instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[WSEnvrionment alloc] init];
        }
        return instance;
    }
}

#pragma mark - 获取configFileDicCache方法
- (NSDictionary *)configFileDicCache {
    
    if (!_configFileDicCache) {
        
        NSString *configFileString = [[NSBundle mainBundle] pathForResource:@"configFile" ofType:@"plist"];
        _configFileDicCache = [[NSDictionary alloc] initWithContentsOfFile:configFileString];
    }
    return _configFileDicCache;
}

#pragma mark - 是否使用高德SDK方法
+ (BOOL)getuseGeoAmap {
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *useGeoAmap = [plistDic objectForKey:@"useGeoAmap"];
    return [useGeoAmap isEqualToString:@"1"];
}

#pragma mark - 是否使用百度地图SDK方法
+ (BOOL)getUseBaiduMap {

    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *useBaiduMap = [plistDic objectForKey:@"useBaiduMap"];
    return [useBaiduMap isEqualToString:@"1"];
}





+(NSString *)getServerIp{
    
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString* sreverIP=[[[plistDic objectForKey:@"ServerIP"] componentsSeparatedByString:@"/mobile/"] firstObject];
    return sreverIP;

}

+ (NSInteger)getStoreDataFromDb {
    
    /*
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    return [[plistDic objectForKey:@"get_store_data_from_db"] integerValue];
     */
    //以后无论如何配置，都让其返回值为1
    return 1;
}

+(NSInteger)getShortCut{
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    
    return [[plistDic objectForKey:@"hasShortCut"] integerValue];
}

+ (NSString *)getHotline {
    
    NSString *winchannelHotline = [[NSUserDefaults standardUserDefaults] objectForKey:WINCHANNEL_HOTLINE];
    
    if (!winchannelHotline || [winchannelHotline length] == 0 || [winchannelHotline isEqualToString:@"null"]) {
        NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
        winchannelHotline = [plistDic objectForKey:@"Hotline"];
//        if (!winchannelHotline) {
//            winchannelHotline = @"400-687-0099";
//        }
    }
    
    return winchannelHotline;
}


+(NSDictionary *)getEnvMapping{
    
    return [WSEnvrionment shareInstance].configFileDicCache;
    
}
+ (NSInteger)getNotUseTabBarItemTitle{
    
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    
    return [[plistDic objectForKey:@"useTabBarTitle"] integerValue];
    
}

/** TODO: 安卓的逻辑如下，不是0和1，待统一
 是否隐藏【找回密码】和 修改密码
 1:隐藏找回密码,隐藏修改密码
 2:隐藏找回密码,显示修改密码
 3:显示找回密码,隐藏修改密码
 默认：显示找回密码,显示修改密码.
 */

+ (BOOL)getHideRetrievePassword{
    
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *hideStr = [plistDic objectForKey:@"HIDE_RETRIEVE_PASSWORD"];
    
    if ([hideStr isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)getHideModifyPassword
{
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *hideStr = [plistDic objectForKey:@"HIDE_MODIFY_PASSWORD"];
    if ([hideStr isEqualToString:@"1"])
        return YES;
    
    //2017-10-28-yuanji-MSTD-6682 增加条件判定是否隐藏修改密码选项(SAAS版本未登录时隐藏)
    NSString *saasUrl = [WSEnvrionment getSaasUrl];
    if(saasUrl && saasUrl.length > 0)
    {
        NSString *loginState = [[NSUserDefaults standardUserDefaults] objectForKey:APP_LOGIN_SUCCESS];
        if(![loginState isEqualToString:@"1"])
            return YES;
    }
    return NO;
}

+ (BOOL)getUseAliyun {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * isUse = [plistDic objectForKey:@"useAliyun"];
    if ([isUse isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)getAliyunUrl {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *endPoint = [plistDic objectForKey:@"AliyunEndPoint"];
    NSString *bucket = [plistDic objectForKey:@"AliyunBucket"];
    
    NSRange range = [endPoint rangeOfString:@"://"];
    if (range.location != NSNotFound && [bucket length] > 0) {
        NSString *scheme = [endPoint substringToIndex:range.location + 3];
        NSString *other = [endPoint substringFromIndex:range.location + 3];
        NSString *url = [NSString stringWithFormat:@"%@%@.%@", scheme, bucket, other];
        return url;
    } else {
        LogError(@"getAliyunUrl:%@, %@", endPoint, bucket);
        return nil;
    }
}

+(BOOL)getUserGesturePassword
{
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *isUseLocal = [plistDic objectForKey:USER_GESTURE_PASSWORD];
    NSString *isUseServer = [[NSUserDefaults standardUserDefaults] objectForKey:USER_GESTURE_PASSWORD];
    
    if ([isUseLocal isEqualToString:@"1"]) {
        return YES;
    }
    
    if ([isUseServer isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)getUseDebugTool {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * isUse = [plistDic objectForKey:@"useDebugTool"];
    if ([isUse isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}


+ (BOOL)getParamInLoginData {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * isUse = [plistDic objectForKey:@"GET_PARAM_IN_LOGIN_DATA"];
    if ([isUse isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)getUseOfflineLoginWhenLaunch {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * isUse = [plistDic objectForKey:@"useOfflineLoginWhenLaunch"];
    if ([isUse isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isOpenUserStatistics {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * isUse = [plistDic objectForKey:@"STAT_ACTION"];
    if ([isUse isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)onlyAlertWhenUpgrade{
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString * result = [plistDic objectForKey:@"ONLY_ALERT_WHEN_UPGRADE"];
    if ([result isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)getUpgradeMessage{
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *result = [plistDic objectForKey:@"UPGRADE_MESSAGE"];
    return result;
}


+ (NSString *)getOnlineConsultation{
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *result = [plistDic objectForKey:@"Online_Consultation"];
    return result;
}

+ (NSString *)getLoginPlayVideo {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *result = [plistDic objectForKey:@"LOGIN_PLAY_VIDEO"];
    return result;
}

+ (NSString *)getSaasUrl {
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSString *result = [plistDic objectForKey:kSAAS_URL];
    return result;
}

+ (NSString *)getLoginCountdownTime {
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *result = [plistDic objectForKey:@"LOGIN_COUNTDOWN_TIME"];
    return result;
}

+ (BOOL)getLoginReject {
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *isLoginReject = [plistDic objectForKey:@"LOGIN_REJECT"];
    if ([isLoginReject isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}


+ (BOOL)getIsBottomMenu {
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *isBottomMenu = [plistDic objectForKey:@"BOTTOM_MENU"];
    if ([isBottomMenu isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

+ (NSArray *)getWWCHAT_SHARE_ID
{
    NSDictionary  *plistDic = [WSEnvrionment getEnvMapping];
    NSArray* chatShareID=[[plistDic objectForKey:@"WWCHAT_SHARE_ID"] componentsSeparatedByString:@","];
    return chatShareID;
}

#pragma mark - 获取app系统版本号方法
+ (NSString *)getAppSystemVersion {
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *appSystemVersion = [plistDic objectForKey:@"appSystemVersion"];
    return appSystemVersion;
}

#pragma mark - 获取app 融云AppKey
+ (NSString *)getAppRongCludKey {
    
    NSDictionary *plistDic = [WSEnvrionment getEnvMapping];
    NSString *appSystemVersion = [plistDic objectForKey:@"RongcloudAppKey"];
    return appSystemVersion;
}
@end
//============================================================================================================================================
