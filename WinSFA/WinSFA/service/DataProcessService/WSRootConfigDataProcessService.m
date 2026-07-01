//
//  WSRootConfigDataProcessService.m
//  WinSFA
//
//  Created by yang on 2017/7/24.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSRootConfigDataProcessService.h"

@implementation WSRootConfigDataProcessService

+ (void)processRootConfigData:(NSDictionary *)dic isRememberBtnSelected:(BOOL)isRememberBtnSelected {
    
    NSString *password_encrypt = [NSString stringWithValue:[dic valueForKey:PasswordEncrypt]];
    if (password_encrypt) {
        [[NSUserDefaults standardUserDefaults] setObject:password_encrypt forKey:PasswordEncrypt];
    }
    
    id numServerTime = [dic objectForKey:@"servertime"];
    LogInfo(@"Origin root config servertime = %@", numServerTime);
    NSNumber *time;
    if ([numServerTime isKindOfClass:[NSNumber class]]) {
        time = (NSNumber *)numServerTime;
    } else if ([numServerTime isKindOfClass:[NSString class]]) {
        NSString *numServerTimeStr = numServerTime;
        time = [NSNumber numberWithLongLong:[numServerTimeStr longLongValue]];
    }
    NSDate *serverTime = [NSDate dateWithTimeIntervalSince1970:[time longLongValue] / 1000.0];
    
    LogInfo(@"Root config servertime(since 1970) = %@", serverTime);
    
    /*
     *没有考虑diff为-1的情况
     */
    time_t baseUptime = [WSAppData uptime];
    NSNumber *numBaseUpTime = [NSNumber numberWithLong:baseUptime];
    [[NSUserDefaults standardUserDefaults] setObject:numBaseUpTime forKey:@"tickTime"]; //
    [[NSUserDefaults standardUserDefaults] setObject:serverTime forKey:@"serverTime"];//服务器时间
    
    //设置图片压缩(ImgCompress通用)
    int compress = 50;
    id imgCompress = [dic objectForKey:@"ImgCompress"];
    if (imgCompress != nil && [imgCompress isKindOfClass:[NSString class]]) {
        int num = 0;
        NSScanner *scanner = [NSScanner scannerWithString:imgCompress];
        if (scanner && [scanner scanInt:&num]) {
            if (num > 0) {
                compress = num;
            }
        }
    }
    else if (imgCompress != nil && [imgCompress isKindOfClass:[NSNumber class]]){
        NSNumber *number = (NSNumber *)imgCompress;
        if ([imgCompress intValue] > 0) {
            compress = [number intValue];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:compress] forKey:@"ImgCompress"];
    //(ImgCompress_IOS)
    int compress_ios = 50;
    id imgCompress_ios = [dic objectForKey:@"ImgCompress_IOS"];
    if (imgCompress_ios != nil && [imgCompress_ios isKindOfClass:[NSString class]]) {
        int num = 0;
        NSScanner *scanner = [NSScanner scannerWithString:imgCompress_ios];
        if (scanner && [scanner scanInt:&num]) {
            if (num > 0) {
                compress_ios = num;
            }
        }
    }
    else if (imgCompress_ios != nil && [imgCompress_ios isKindOfClass:[NSNumber class]]){
        NSNumber *number = (NSNumber *)imgCompress_ios;
        if ([imgCompress_ios intValue] > 0) {
            compress_ios = [number intValue];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:compress_ios] forKey:@"ImgCompress_IOS"];
    
    //缩放宽度(IMAGE_WIDTH通用)
    float width = 320.0;
    id imgWidth = [dic objectForKey:IMAGE_WIDTH];
    if (imgWidth != nil && [imgWidth isKindOfClass:[NSString class]]) {
        float num = 0.0;
        NSScanner *scanner = [NSScanner scannerWithString:imgWidth];
        if (scanner && [scanner scanFloat:&num]) {
            if (num > 1) {
                width = num;
            }
        }
    }
    else if (imgWidth != nil && [imgWidth isKindOfClass:[NSNumber class]]){
        NSNumber *number = (NSNumber *)imgWidth;
        if ([number floatValue] > 0) {
            width = [number floatValue];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:width] forKey:IMAGE_WIDTH];
    //(IMAGE_WIDTH_IOS)
    float width_ios = 320.0;
    id imgWidth_ios = [dic objectForKey:@"IMAGE_WIDTH_IOS"];
    if (imgWidth_ios != nil && [imgWidth_ios isKindOfClass:[NSString class]]) {
        float num = 0.0;
        NSScanner *scanner = [NSScanner scannerWithString:imgWidth_ios];
        if (scanner && [scanner scanFloat:&num]) {
            if (num > 1) {
                width_ios = num;
            }
        }
    }
    else if (imgWidth_ios != nil && [imgWidth_ios isKindOfClass:[NSNumber class]]){
        NSNumber *number = (NSNumber *)imgWidth_ios;
        if ([number floatValue] > 0) {
            width_ios = [number floatValue];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:width_ios] forKey:@"IMAGE_WIDTH_IOS"];

    //图片是否加日期水印
    NSString *image_watermark = [NSString stringWithValue:[dic objectForKey:IMAGE_WATERMARK]];
    if (image_watermark) {
        [[NSUserDefaults standardUserDefaults] setObject:image_watermark forKey:IMAGE_WATERMARK];
    }
    
    //是否开启坐标服务，默认0，关闭
    NSString *enableLocation = [NSString stringWithValue:[dic objectForKey:ENABLE_LOCATION]];
    if (!enableLocation || [enableLocation length] == 0) {
        enableLocation = @"0";
    }
    [[NSUserDefaults standardUserDefaults] setObject:enableLocation forKey:ENABLE_LOCATION];
    
    //采集GSP信息时 是否要开启WIFI检测 0关闭
    NSString *openWifiOnGetGps = [NSString stringWithValue:[dic objectForKey:OPEN_WIFI_ON_GET_GPS]];
    if (!openWifiOnGetGps || [openWifiOnGetGps length] == 0)
        openWifiOnGetGps = @"0";
    [[NSUserDefaults standardUserDefaults] setObject:openWifiOnGetGps forKey:OPEN_WIFI_ON_GET_GPS];
    
    //SFA-23687 照相后是否保存到相册 保存登陆下发参数
    NSString *take_photo_album = [NSString stringWithValue:[dic objectForKey:TAKE_PHOTO_ALBUM]];
    if (take_photo_album) {
        [[NSUserDefaults standardUserDefaults] setObject:take_photo_album forKey:TAKE_PHOTO_ALBUM];
    }
    
    // 是否启动被动定位
    NSNumber *passiveLocation = [NSNumber numberWithBool:NO];   // 默认为否
    NSString *passiveLocationString = [NSString stringWithValue:[dic objectForKey:ENABLE_PASSIVE_LOCATION]];
    if (passiveLocationString && [passiveLocationString isEqualToString:@"1"]) {
        passiveLocation = [NSNumber numberWithBool:YES];
    }
    [[NSUserDefaults standardUserDefaults] setObject:passiveLocation forKey:ENABLE_PASSIVE_LOCATION];
    
    // 被动定位上报时间间隔
    NSNumber *locationCheckTime = [NSNumber numberWithInteger:1200]; // 默认为 20分钟
    NSString *locationCheckTimeString = [NSString stringWithValue:[dic objectForKey:LOCATION_CHECK_TIME]];
    if (locationCheckTimeString && [locationCheckTimeString integerValue] > 0) {
        locationCheckTime = [NSNumber numberWithInteger:[locationCheckTimeString integerValue]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:locationCheckTime forKey:LOCATION_CHECK_TIME];
    
    // 被动定位开始时间
    NSNumber *locationStartTime = [NSNumber numberWithInteger:8]; //默认8点
    NSString *startTimeString = [NSString stringWithValue:[dic objectForKey:LOCATION_START_TIME]];
    if (startTimeString && [startTimeString integerValue] > 0) {
        locationStartTime = [NSNumber numberWithInteger:[startTimeString integerValue]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:locationStartTime forKey:LOCATION_START_TIME];
    
    // 被动定位结束时间
    NSNumber *locationEndTime = [NSNumber numberWithInteger:18];  //默认18点
    NSString *endTimeString = [NSString stringWithValue:[dic objectForKey:LOCATION_END_TIME]];
    if (endTimeString && [endTimeString integerValue] > 0) {
        locationEndTime = [NSNumber numberWithInteger:[endTimeString integerValue]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:locationEndTime forKey:LOCATION_END_TIME];
    
    // 定位精度
    NSNumber *locationAccuracy = [NSNumber numberWithInteger:300]; // 默认为 300
    NSString *locationAccuracyString = [NSString stringWithValue:[dic objectForKey:LOCATION_ACCURACY]];
    if (locationAccuracyString && [locationAccuracyString integerValue] > 0) {
        locationAccuracy = [NSNumber numberWithInteger:[locationAccuracyString integerValue]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:locationAccuracy forKey:LOCATION_ACCURACY];
    
    
    //LOGIN_CHECK_GPS/0不检查；1提示开启；2提示开启，未开启不允许登陆系统。
    NSString *loginCheckGps = [NSString stringWithValue:[dic objectForKey:LOGIN_CHECK_GPS]];
    if (!loginCheckGps) {
        loginCheckGps = @"0";
    }
    [[NSUserDefaults standardUserDefaults] setObject:loginCheckGps forKey:LOGIN_CHECK_GPS];
    
    
    //是否使用系统相机，默认为1 使用系统相机
    // 01 两位数，十位代表iOS的配置，个位代表Android的配置
    NSNumber *isUseSystemCamera = [NSNumber numberWithBool:YES];
    NSString *isUseSystemCameraString = [NSString stringWithValue:[dic objectForKey:USE_SYSTEM_CAMERA]];
    if (isUseSystemCameraString && [isUseSystemCameraString length] >= 2) {
        isUseSystemCameraString = [isUseSystemCameraString substringFromIndex:[isUseSystemCameraString length] - 2];
        if ([isUseSystemCameraString hasPrefix:@"0"]) {
            isUseSystemCamera = [NSNumber numberWithBool:NO];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:isUseSystemCamera forKey:USE_SYSTEM_CAMERA];
    
    
    //
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:ROOT_CONFIG_USERDEFAULT_KEY];
    // 是否开启定时获取公告信息功能
    NSString *pushInformation = [dic objectForKey:INFORMATION_PUSH];
    [[NSUserDefaults standardUserDefaults] setObject:pushInformation forKey:INFORMATION_PUSH];
    
    // 保存获取公告信息的间隔时间
    NSObject *interval = [dic objectForKey:POA_NOTIFICATION_INTERVAL];
    if (interval) {
        [[NSUserDefaults standardUserDefaults] setObject:interval forKey:POA_NOTIFICATION_INTERVAL];
    }
    
    // 登陆界面是否显示修改密码,第一次显示登陆界面时候默认显示
    NSString *showModifyPwd = [dic objectForKey:IS_LOGIN_PASSWORD];
    if (!showModifyPwd) {
        showModifyPwd = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:showModifyPwd forKey:IS_LOGIN_PASSWORD];
    
    // 是否记住密码
    NSString *rememberPwd = [dic objectForKey:REMEMBER_PASSWORD];
    if (!rememberPwd && isRememberBtnSelected) {
        rememberPwd = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:rememberPwd forKey:REMEMBER_PASSWORD];
    
    // 是否勾选记住用户名
    NSString *rememberUserName = [dic objectForKey:REMEMBER_ME_KEY];
    if (!rememberUserName && isRememberBtnSelected) {
        rememberUserName = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:rememberUserName forKey:REMEMBER_ME_KEY];
    if (INTERFACE_IS_PAD) {
        NSString * lock_timeout =[NSString stringWithValue:[dic objectForKey:LOCK_TIMEOUT]];
        if(!lock_timeout){
            lock_timeout=@"0";
        }
        [[NSUserDefaults standardUserDefaults] setObject:lock_timeout forKey:LOCK_TIMEOUT];
    }
    
    
    NSString * lock_run_in_background =[NSString stringWithValue:[dic objectForKey:LOCK_RUN_IN_BACKGROUND]];
    if(!lock_run_in_background){
        lock_run_in_background=@"0";
    }
    [[NSUserDefaults standardUserDefaults] setObject:lock_run_in_background forKey:LOCK_RUN_IN_BACKGROUND];
    
    
    
    // WEB_ADDRESS 用此地址作为登陆地址
    NSString *webAddress = [dic objectForKey:WEB_ADDRESS];
    if (webAddress) {
        webAddress = [webAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setObject:webAddress forKey:WEB_ADDRESS];
    }
    
    
    // 进离店是否显示除gps以外地址
    NSString *gps_Adress = [dic objectForKey:IS_SHOW_GPS_ADDRESS];
    if (!gps_Adress) {
        gps_Adress = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:gps_Adress forKey:IS_SHOW_GPS_ADDRESS];
    
    
    // 根据后台配置显示主页列数
    NSString *homePageColumns = [dic objectForKey:HOMEPAGE_COLUMNS];
    if (!homePageColumns) {
        homePageColumns = HOMEPAGE_COLUMNS_DEFAULT;
    }
    [[NSUserDefaults standardUserDefaults] setObject:homePageColumns forKey:HOMEPAGE_COLUMNS];
    
    //是否将下发的坐标转为02坐标，值为0时不转换 （蒙牛项目使用）
    NSString *isTransformCoordinate = [dic objectForKey:GAODE2WGS84];
    if (!isTransformCoordinate) {
        isTransformCoordinate = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:isTransformCoordinate forKey:GAODE2WGS84];
    
    // 配置为 1 代表使用单位转换（规格只包含：KG、kg、Kg、kG、g、G、克、千克） （立白项目)
    NSString *needWeightConversion = [dic objectForKey:NEED_WEIGHT_CONVERSION];
    if (!needWeightConversion) {
        needWeightConversion = NEED_WEIGHT_CONVERSION;
    }
    [[NSUserDefaults standardUserDefaults] setObject:needWeightConversion forKey:NEED_WEIGHT_CONVERSION];
    
    //热线电话
    NSString *winchannelHotline = [dic objectForKey:WINCHANNEL_HOTLINE];
    if (winchannelHotline && [winchannelHotline length] > 0 && ![winchannelHotline isEqualToString:@"null"]) {
        [[NSUserDefaults standardUserDefaults] setObject:winchannelHotline forKey:WINCHANNEL_HOTLINE];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:WINCHANNEL_HOTLINE];
    }
    
    //是否开启检测附近peer的功能，由于之前的项目增加此功能没有加参数控制，大部分项目不需要此功能，每次都启动multipeerManager有些浪费,故加此参数控制，如后面发现需要此功能的项目没有开启，增加参数即可，1为开启，0为关闭，默认为关闭。
    NSString *enableMultipeer = [dic objectForKey:ENABLE_MULTIPEER];
    if (!enableMultipeer || [enableMultipeer length] == 0) {
        enableMultipeer = @"0";
    }
    [[NSUserDefaults standardUserDefaults] setObject:enableMultipeer forKey:ENABLE_MULTIPEER];
    
    //是否离线登录
    NSString *isOfflineLanding = [dic objectForKey:IS_OFFLINE_LANDING];
    if (isOfflineLanding && [isOfflineLanding length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:isOfflineLanding forKey:IS_OFFLINE_LANDING];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_OFFLINE_LANDING];
    }
    
    NSString *bottomMenu = [dic objectForKey:BOTTOM_MENU];
    if (bottomMenu && [bottomMenu length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:bottomMenu forKey:BOTTOM_MENU];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BOTTOM_MENU];
    }
    
    NSString *isForceExit = [dic objectForKey:IS_FORCE_EXIT];
    if (isForceExit && [isForceExit length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:isForceExit forKey:IS_FORCE_EXIT];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_FORCE_EXIT];
    }
    
    NSString *checkUploadData = [dic objectForKey:CHECK_UPLOADED_DATA];
    if (checkUploadData && [checkUploadData length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:checkUploadData forKey:CHECK_UPLOADED_DATA];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CHECK_UPLOADED_DATA];
    }
    
    //是否显示门头照 （0:不显示，1:显示）默认为显示
    NSString *isUseStorePhotos = [dic objectForKey:USE_STORE_PHOTOS];
    if (!isUseStorePhotos || [isUseStorePhotos length] == 0) {
        isUseStorePhotos = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:isUseStorePhotos forKey:USE_STORE_PHOTOS];
    
    NSString *locationTimeout = [NSString stringWithValue:[dic objectForKey:LOCATION_TIMEOUT]];
    if ([locationTimeout length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:locationTimeout forKey:LOCATION_TIMEOUT];
    }
    
    
    //是否校验离店， 配置为0时，不离店也可以做其他店的进店操作, 默认为1
    NSString *checkLeaveStore = [dic objectForKey:CHECK_LEAVE_STORE];
    if (!checkLeaveStore) {
        checkLeaveStore = @"1";
    }
    [[NSUserDefaults standardUserDefaults] setObject:checkLeaveStore forKey:CHECK_LEAVE_STORE];
    
    
    //更多产品是否可以按品牌分类
    NSString *isBrand = [dic objectForKey:IS_BRAND_MORE];
    if (isBrand && [isBrand length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:isBrand forKey:IS_BRAND_MORE];
    }else {
        
        //SFA-84、WRIGLEY-793添加这个逻辑，可能想要删除的字段是 IS_BRAND_MORE，而不是 IS_FORCE_EXIT
        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_FORCE_EXIT];
        // YIHAIKERRY-4070 zhaodanyang
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_BRAND_MORE];

    }
    
    
    NSString * isShowRichMediaHome = nil;
    isShowRichMediaHome = [dic objectForKey:IS_SHOW_RICHMEDIA_HOME]; // 默认显示 1显示 0 不显示
    if ( [isShowRichMediaHome isEqualToString:@"0"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_SHOW_RICHMEDIA_HOME];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:IS_SHOW_RICHMEDIA_HOME];
    }
    
    // MSTD-5876 是否开启在线沟通
    NSString *online_Consultation = nil;
    online_Consultation = [dic objectForKey:ONLINE_CONSULTATION];
    
    if (online_Consultation && online_Consultation.length > 0) {
        
        [[NSUserDefaults standardUserDefaults] setObject:online_Consultation forKey:ONLINE_CONSULTATION];
        [[NSUserDefaults standardUserDefaults] setObject:online_Consultation forKey:ONLINE_CONSULTATION_SERVER];
        
    }else{
        NSString *oldOnline_Consultation = [[NSUserDefaults standardUserDefaults] objectForKey:ONLINE_CONSULTATION];
        if (oldOnline_Consultation && oldOnline_Consultation.length > 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ONLINE_CONSULTATION];
        }
    }
    
    // MN-802 同步安卓加入调查问卷默认全选的登陆下发参数
    NSString *select_all_on_focus = nil;
    select_all_on_focus = [dic objectForKey:SELECT_ALL_ON_FOCUS];
    
    if (select_all_on_focus && select_all_on_focus.length > 0) {
        
        [[NSUserDefaults standardUserDefaults] setObject:select_all_on_focus forKey:SELECT_ALL_ON_FOCUS];
        
    }else{
        NSString *oldSelect_all_on_focus = [[NSUserDefaults standardUserDefaults] objectForKey:SELECT_ALL_ON_FOCUS];
        if (oldSelect_all_on_focus && oldSelect_all_on_focus.length > 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECT_ALL_ON_FOCUS];
        }
    }
    
    // MSTD-6731 欢迎页跳过时间
    if ([dic objectForKey:APPDATA_WELCOME_SKIP_TIME]) {
        NSString *skipTime =  [NSString stringWithValue:[dic objectForKey:APPDATA_WELCOME_SKIP_TIME]];
        [[NSUserDefaults standardUserDefaults] setObject:skipTime forKey:APPDATA_WELCOME_SKIP_TIME];
    }
    
    // SFA-15017
    if ([dic objectForKey:STORE_TIPS_INFO]) {
        NSString *tipsInfo = [dic objectForKey:STORE_TIPS_INFO];
        [[NSUserDefaults standardUserDefaults] setObject:tipsInfo forKey:STORE_TIPS_INFO];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORE_TIPS_INFO];
    }
    
    //YIHAIKERRY-2888
    if ([dic objectForKey:SEARCH_STORE_RANGE])
    {
        NSString *rangeInfo = [dic objectForKey:SEARCH_STORE_RANGE];
        [[NSUserDefaults standardUserDefaults] setObject:rangeInfo forKey:SEARCH_STORE_RANGE];
    }
    else
        [[NSUserDefaults standardUserDefaults] setObject:@"2500" forKey:SEARCH_STORE_RANGE];
    
    // YIHAIKERRY-1085 此处为服务器登陆参数配置是否使用手势密码，本地plist的打包参数与此参数两个有一个为1则开启手势密码功能
    NSString *userGesturePassword = nil;
    userGesturePassword = [dic objectForKey:USER_GESTURE_PASSWORD];
    
    if (userGesturePassword && userGesturePassword.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:userGesturePassword forKey:USER_GESTURE_PASSWORD];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_GESTURE_PASSWORD];
    }
    
    // 手势密码新增过期天数，若超过此天数需重新用用户名密码登陆并重设手势密码
    NSString *userGesturePasswordExpiredDays = nil;
    userGesturePasswordExpiredDays = [dic objectForKey:USER_GESTURE_PASSWORD_EXPIRED_DAYS];
    if (userGesturePasswordExpiredDays && userGesturePasswordExpiredDays.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:userGesturePasswordExpiredDays forKey:USER_GESTURE_PASSWORD_EXPIRED_DAYS];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_GESTURE_PASSWORD_EXPIRED_DAYS];
    }
    
    // YIHAIKERRY-2297  益海嘉里更新门头照功能
    NSString * isUpdateStoreIcon = [dic objectForKey:IS_UPDATE_STORE_ICON];
    if (isUpdateStoreIcon.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:isUpdateStoreIcon forKey:IS_UPDATE_STORE_ICON];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:IS_UPDATE_STORE_ICON];
    }
   // YIHAIKERRY-3233   日志最大数量
    NSString *logMaxCount = (dic[LOG_FILE_COUNT] ? dic[LOG_FILE_COUNT] : @"4" );
    [[NSUserDefaults standardUserDefaults] setObject:logMaxCount forKey:LOG_FILE_COUNT];
    
    //SFA-24180
    NSString *needSearchProdRecord = [dic objectForKey:NEED_SEARCH_PROD_RECORD];
    if (needSearchProdRecord && needSearchProdRecord.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:needSearchProdRecord forKey:NEED_SEARCH_PROD_RECORD];
    }
    
    //备份到本地相册
    NSString *externalPicFolder = [dic objectForKey:EXTERNAL_PIC_FOLDER];
    if (externalPicFolder && [externalPicFolder length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:externalPicFolder forKey:EXTERNAL_PIC_FOLDER];
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:EXTERNAL_PIC_FOLDER];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
