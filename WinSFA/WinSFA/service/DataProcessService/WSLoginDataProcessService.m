//
//  WSLoginDataProcessService.m
//  WinSFA
//
//  Created by yang on 15/12/31.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSLoginDataProcessService.h"

#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSCurrentTime.h"
#import "WSOffLineUploadTable.h"
#import "WCLogManager.h"
#import "WSOfflineDataManager.h"
#import "FileManager.h"
#import "WSLocationManager.h"
#import "WinSFA.h"
#import "WSOfflineDataDBService.h"
#import "WSOffLineUploadTable.h"
#import "WSFuncsBeanArray.h"
#import "WSCustomTimeTable.h"
#import "BlockAlertView.h"
#import "WSConfigObject.h"
#import "WSTestTools.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
#import "WSLoginDataProcessService+DB.h"
#import "WSInoutStoreTable.h"
#import "WSBaseStoreOtherDataTable.h"
#import "WSEnvrionment.h"
#import "NSDate+Formatter.h"
#import "WSBaseAcvtDBService.h"
#import "WSBaseStoreAcvtDBService.h"
#import "WSWelcomeDataService.h"



@implementation WSLoginDataProcessService
{
    NSString *_userName;
    NSString *_password;
}

- (void)processLoginDataWithQueue:(NSDictionary *)loginDataDic userName:(NSString *)userName password:(NSString *)password isFromCache:(BOOL)isFromCache isOfflineLogin:(BOOL)isOfflineLogin complete:(WSLoginDataCompleteBlock)completeBlock
{
    dispatch_queue_t serialQueue = dispatch_queue_create("net.winchannel.sfa.processLoginDataQueue", NULL);
    dispatch_async(serialQueue, ^{
        [self processLoginData:loginDataDic userName:userName password:password isFromCache:isFromCache isOfflineLogin:isOfflineLogin complete:completeBlock];
    });
}

- (BOOL)processLoginData:(NSDictionary *)loginDataDic userName:(NSString *)userName password:(NSString *)password isFromCache:(BOOL)isFromCache isOfflineLogin:(BOOL)isOfflineLogin {
    return [self processLoginData:loginDataDic userName:userName password:password isFromCache:isFromCache isOfflineLogin:isOfflineLogin complete:nil];
}

- (BOOL)processLoginData:(NSDictionary *)loginDataDic userName:(NSString *)userName password:(NSString *)password isFromCache:(BOOL)isFromCache isOfflineLogin:(BOOL)isOfflineLogin complete:(WSLoginDataCompleteBlock)completeBlock {

    _userName = userName;
    _password = password;
    
    NSDictionary *serverNewLoginDataDic = loginDataDic;
    NSDictionary *newLoginDataDic = loginDataDic;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setProgress:WSDataProcessProgressStart];
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_PROCESS_JSON_DATA forcePrint:YES];
   
    NSDictionary *cacheDataVersionDic = [newLoginDataDic objectForKey:CACHE_DATA_VERSION_NODE];
    NSNumber * currentTimems = [cacheDataVersionDic objectForKey:@"timems"];
    if ([currentTimems isKindOfClass:[NSString class]]) {
        currentTimems = [NSNumber numberWithInteger:[currentTimems integerValue]];
    }
  

    /**
     * MSTD-717
     * 默认加载本地缓存，用服务端更新的节点替换本地节点。
     * 如果取消某个节点，那么从服务端返回的登陆版本串里的该节点的值设置为nil
     */
    NSString *oldLoginDataString = [self getLoginData];
    
    [self setProgress:WSDataProcessProgressParseJson];
    
    id oldObjects = [oldLoginDataString objectFromJSONString];
    
    if (oldLoginDataString != nil && [oldLoginDataString length] > 0) {
        
        if ([oldObjects isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *oldDic = [NSMutableDictionary dictionaryWithDictionary:oldObjects];
            
            if (!isOfflineLogin) {
                NSArray *newDicKeys = [newLoginDataDic allKeys];
                NSArray *oldDicKeys = [oldDic allKeys];
                
                for (NSString* keyString in newDicKeys) {
                    id value = [newLoginDataDic objectForKey:keyString];
                    if (value
                        && [value isKindOfClass:[NSString class]]
                        && [value length] == 0) {
                        value = nil;
                    }
                    [oldDic setValue:value forKey:keyString];
                }
                
                if (cacheDataVersionDic) {
                    NSArray *cacheDataVersionKeys = [cacheDataVersionDic allKeys];
                
                    //处理类似 pswValidDayMsg 节点
                    for (NSString *oldKeyString in oldDicKeys) {
                        if (![cacheDataVersionKeys containsObject:oldKeyString]
                            && ![newDicKeys containsObject:oldKeyString]
                            && ![oldKeyString isEqualToString:@"funcs2"]) {
                            [oldDic setValue:nil forKey:oldKeyString];
                        }
                    }
                }
                
                
            }
            
            
            newLoginDataDic = oldDic;
        }
    }
    
    [self setProgress:WSDataProcessProgressPutData];
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_PROCESS_JSON_DATA forcePrint:YES];
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_PROCESS_APP_DATA forcePrint:YES];
    
    [WSAppData putData:newLoginDataDic];//将不存入数据库的内容存储在缓存当中
    
    [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_PROCESS_APP_DATA forcePrint:YES];
    
    //Note: 验证服务器数据
    WSFuncsBeanArray* fba = [WSAppData getObjectbyKey:FUNCS];
    
    //  YIHAIKERRY-3377
    //  SFA 益海嘉里-传统渠道【200家门店列表】【IOS】登陆App进入门店列表，加载门店列表完成，下载Top10家完成后，退出登录，重进登录该账号进入门店列表，已下载门店“已下载”消失
    WSFuncsBean *fb = [fba getFuncsBeanFromAllFucsWithFC:@"TAB_F2002_001"];
    BOOL isdeleteCache = isOfflineLogin;
    if ([fb.opt.downByMap isEqualToString:@"2"]) {
        isdeleteCache = YES;
    }
    if (!isdeleteCache && currentTimems) {
        /**
         *  根据timems字段判断 是否需要清除 计划外门店是否拜访过的标识
         */
        
        NSNumber * preTimems = [[NSUserDefaults standardUserDefaults] objectForKey:@"preTimems"];
        if ([preTimems isKindOfClass:[NSString class]]) {
            preTimems = [NSNumber numberWithInteger:[preTimems integerValue]];
        }
        if (preTimems != nil) {
            if (!([currentTimems compare:preTimems] == NSOrderedSame)) {
                [self deleteAllRequestedStoreDataFlag];
                [[NSUserDefaults standardUserDefaults] setObject:currentTimems forKey:@"preTimems"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            
            [[NSUserDefaults standardUserDefaults] setObject:currentTimems forKey:@"preTimems"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
   
    NSInteger fba_count = [fba.funcsArray count];
    
    if (fba_count == 0) {
        LogError(@"login funcs.funcsarray.count == 0");
        
        [[WSTestTools getInstance] keepTimeWithKey:LOG_PROCESS_APP_DATA forcePrint:YES];
        [WSAppData putData:oldObjects];
        [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_PROCESS_APP_DATA forcePrint:YES];
        
        [self setComplete:completeBlock isSuccess:NO];
        
        return NO;
    }
    
    [self setProgress:WSDataProcessProgressSaveDB];
    
    if (!isOfflineLogin) {
        [[WSTestTools getInstance] keepTimeWithKey:LOG_LOGIN_CLEAR_DATA forcePrint:YES];
        
        // SFA-16350 此处代码会导致卡住若干秒才能弹出离店提醒并继续操作，因此移动至WSAppDelegate中的loginSuccess()方法末尾
//        if (INTERFACE_IS_PAD) {
//            // 在清理数据前 提醒未离开的店
//            WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
//            NSString *unLeavedStoreName = [inOutStoreObj memo1];
//            if (unLeavedStoreName) {
//                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//                [dic setObject:unLeavedStoreName forKey:UNLEAVED_STORE];
//                [[NSNotificationCenter defaultCenter] postNotificationName:ALERT_UNLEAVED_STORE object:nil userInfo:dic];
//            }
//        }
        
        [self reUploadUnleavedStore];
        
        //for 辉瑞零售-营业执照采集，限制上传次数
        //先清除前一天的数据
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *lastBizDate = [userDefaults objectForKey:LAST_BIZ_DATE_KEY];
        if (lastBizDate && ![lastBizDate isEqualToString:[WSAppData getObjectbyKey:APPDATA_BIZDATE]]) {
            [userDefaults removeObjectForKey:STORE_ACVTS_KEY_BY_EMPID([WSAppData getObjectbyKey:APPDATA_EMPID])];
            [userDefaults synchronize];
        }
        
        //再更新新数据
        if (!isFromCache) {
            
            NSDictionary *originDic = [userDefaults dictionaryForKey:STORE_ACVTS_KEY_BY_EMPID([WSAppData getObjectbyKey:APPDATA_EMPID])];
            NSMutableDictionary *newDic = nil;
            if (originDic) {
                newDic = [[NSMutableDictionary alloc] initWithDictionary:originDic];
            }
            else
            {
                newDic = [[NSMutableDictionary alloc] init];
            }
            
            WSInPlanStoreBean *inplanStore = [WSAppData getObjectbyKey:INPLANSTORE];
            
            for (WSStoreBean *storeBean in inplanStore.storesArray) {
                if (storeBean.acvtsArray) {
                    [newDic setObject:storeBean.acvtsArray forKey:storeBean.Id];
                }
            }
            
            [userDefaults setObject:newDic forKey:STORE_ACVTS_KEY_BY_EMPID([WSAppData getObjectbyKey:APPDATA_EMPID])];
            [userDefaults synchronize];
        }
        [userDefaults setObject:[WSAppData getObjectbyKey:APPDATA_BIZDATE] forKey:LAST_BIZ_DATE_KEY];
        
        [userDefaults synchronize];
        
        
        [[WCLogManager sharedInstance] saveEmpIDAndEmpName];
        
        //清除旧的拜访数据
        [WSLoginDataProcessService clearOldVisitDatas];
        
        //清除缓存图片，上传失败的除外
        NSArray *failedPhotoFileNames = [[WSOffLineUploadTable sharedTable] queryUploadFailedPhotoNames];
        [[SDImageCache sharedImageCache] cleanDiskWithExcludeFileNames:failedPhotoFileNames];
        
        
        [[WSBaseStoreOtherDataTable sharedTable] insertItem1Value:@"preTimems" Item2value:[currentTimems stringValue]];
        
        [[WSTestTools getInstance] printAndEndTimeIntervalforKey:LOG_LOGIN_CLEAR_DATA forcePrint:YES];
        
        [self saveToDataBase:serverNewLoginDataDic];//之前的数据已经入库，只需入库最新服务器返回的数据即可
        
        
        
        // MSTD-6643
//        WSFuncsBeanArray *funcsBeanArray = [WSAppData getObjectbyKey:FUNCS];
        WSFuncsBean *funcsBean = [fba getFuncsBeanWithFV:@"TAB_CHAT"];
        if (funcsBean) {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:IS_SUPPORT_MESSAGE_BACKUP];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_SUPPORT_MESSAGE_BACKUP];
        }
    }

    
    [self setProgress:WSDataProcessProgressSaveData];
    
    //是否开启自动上传
    NSString *mobileAutoUpload = [WSAppData getObjectbyKey:MOBILE_AUTO_UPLOAD];
    if ([mobileAutoUpload isEqualToString:@"0"]) {
        [[WSOfflineDataManager sharedInstance] uploadFailedDatas];
    }else{
        NSInteger minute = [mobileAutoUpload integerValue];
        if (![WSOfflineDataManager sharedInstance].isStartAutoUpload && minute > 0) {
            [[WSOfflineDataManager sharedInstance] startAutoUploadWithTimeInterval:minute * 60];
        }
    }
    
    // 登陆成功时候初始化应用的退出状态
    [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusException] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
    
    [FileManager removeDefaultsByKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    [FileManager removeDefaultsByKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
    [FileManager removeDefaultsByKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
    [FileManager removeDefaultsByKey:EXIT_APP_AKU_USERDEFAULT_KEY];
    [FileManager removeDefaultsByKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
    
    if (!isOfflineLogin) {
        
        [self setProgress:WSDataProcessProgressSaveUnOfflineData];
        
        NSString *newDataVersion;
        id obj = [WSAppData getObjectbyKey:CACHE_DATA_VERSION_NODE];
        if (obj != nil && [obj isKindOfClass:[NSDictionary class]]) {
            // MSTD-717
            NSDictionary *versionDic = (NSDictionary *)obj;
            newDataVersion = [versionDic JSONString] ;
        }
        NSString *localDataVersion = (NSString *)[FileManager getUserDefaults:CACHE_DATA_VERSION_KEY_BYUSER(_userName)];
        LogInfo(@"localDataVersion is:%@,newDataVersion is:%@",localDataVersion,newDataVersion);
        if (!(newDataVersion != nil && localDataVersion != nil && [newDataVersion isEqualToString:localDataVersion])) {
            [self saveLoginData:[newLoginDataDic JSONString] withVersion:newDataVersion];
        }
        
        // MSTD-6659 要求同步下载，下载图片后才能进入登录
        BOOL isDownload = NO;
        NSString *welcomeDownloadUrl = [[WSWelcomeDataService sharedInstance] getWelcomeUrl];
        if ([welcomeDownloadUrl length] > 0) {
            BOOL hasCache = [[WSWelcomeDataService sharedInstance] hasCacheFileWithUrl:welcomeDownloadUrl];
            if (!hasCache) {
                isDownload = YES;
                [[WSWelcomeDataService sharedInstance] downloadFileWithUrl:welcomeDownloadUrl completeBlock:^(BOOL isSuccess) {
                    [self setProgress:WSDataProcessProgressDone];
                    [self setComplete:completeBlock isSuccess:YES];
                }];
            }
        }
        
        if (!isDownload) {
            [self setProgress:WSDataProcessProgressDone];
            [self setComplete:completeBlock isSuccess:YES];
        }
    }
    return YES;
}

- (void)setComplete:(WSLoginDataCompleteBlock)completeBlock isSuccess:(BOOL)isSuccess {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (completeBlock) {
            completeBlock(YES);
        }
    });
}

- (void)setProgress:(NSInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.progressBlock) {
            self.progressBlock(progress);
        }
    });
}


// 如果timems 值改变 说明后台刷新了数据,那么计划外门店数据需要重新请求,此方法删除之前保存的状态值
- (void)deleteAllRequestedStoreDataFlag{
    [[WSBaseStoreOtherDataTable  sharedTable] deleteWithNames:@[@"type"] ArgumentsValue:@[WSASVC_OUTPLANSTORE_REQUESTED_FLAG]];
    
    /* acvtinfo节点为问卷信息 */
    WSBaseAcvtDBService *acvtService = [[WSBaseAcvtDBService alloc] init];
    [acvtService replaceToTableWithDicts:nil FromNode:ACVTINFO hasNewData:YES];
    
    /*acvt节点数据对应登录下发store_acvt节点数据*/
    WSBaseStoreAcvtDBService *baseStoreAcvtDBService = [[WSBaseStoreAcvtDBService alloc] init];
    [baseStoreAcvtDBService replaceToTableWithDicts:nil FromNode:ACVT hasNewData:YES];
}

- (NSString *)getLoginDataFilePath
{
    return [[FileManager Documents] stringByAppendingPathComponent:LOGIN_DATA_FILENAME_BYUSER(_userName)];
}

- (NSString *)getLoginData
{
    return [FileManager readFileContent:[self getLoginDataFilePath]];
}

- (void)saveLoginData:(NSString *)loginDataString withVersion:(NSString *)version
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LogTrace();
        __block BOOL isSuccess = NO;
        
        if (loginDataString == nil || [loginDataString length] <= 0) {
            return;
        }
        
        NSData *data = [loginDataString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data == nil) {
            return;
        }
        
        isSuccess = [FileManager writeFileAndCover:[self getLoginDataFilePath] data:data];
        
        NSLog(@"[FileManager Documents] :%@", [FileManager Documents] );
        
        if (isSuccess) {
            LogInfo(@"isSuccess");
            [FileManager setUserDefaults:version forKey:CACHE_DATA_VERSION_KEY_BYUSER(_userName)];
        }
        
    });
}

- (void)reUploadUnleavedStore
{
    // 是否有非当日的未离店数据
    WSInoutStoreObject *inOutStoreObj = [[WSInoutStoreTable sharedTable] anyStorehaveNotLeave];
    if (!inOutStoreObj) { return; }
    // 如果是当天的未离店 无需补录
    if ([[WSAppData getObjectbyKey:@"bizDate"] isEqualToString:inOutStoreObj.biz_date]) { return; }
    
    // 上传
    NSString *postData = [[WSRequestHelper shareInstance] postRequestUnLeavedStore:inOutStoreObj notifyName:UPLOAD_UNLEAVED_STORE];
    // 离线上传
    NSString *notifyID = [NSString stringWithFormat:@"%@%@",kOfflineTableNotifyIdPrefix,[WSJSONBuilder gen_uuid]];
    [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:@"upload_unleaved_store" IsPhoto:NO NotifyName:notifyID];
}

// 启动时非首次登录离线登录情况下是否需要自动刷新数据
- (BOOL)isOfflineLoginWhenLaunchNeedRefresh {
    if ([WSEnvrionment getUseOfflineLoginWhenLaunch]) {
        WSAppDelegate * deleget = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
        NSDate *forceQuitTime = [deleget getForceQuitTime];
        
        NSDate *nowDate = [NSDate date];
        if ([nowDate compare:forceQuitTime] == NSOrderedDescending) {
            // 当前时间晚于强退时间则需要刷新数据
            return YES;
        }
        
        NSDate *serverDate = [WSCurrentTime getCurrentServerDate];
        NSTimeInterval interval = [serverDate timeIntervalSinceDate:nowDate];
        if (ABS(interval) > (60 * WCForceQuiteTimeInterval)) {
            return YES;
        }
    }
    return NO;
}

@end
