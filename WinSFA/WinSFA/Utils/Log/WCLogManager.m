//
//  WCLogManager.m
//  WinSFA
//
//  Created by yang on 13-7-12.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WCLogManager.h"
#import <WCBaseRequest.h>
#import <WCBaseResponse.h>
#import <ZipArchive.h>
#import "UncaughtExceptionHandler.h"
#import "WCLogFormatter.h"
#import "WSEnvrionment.h"
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import <DDASLLogger.h>
#import "WSAppData.h"
#import "WCNaviFileResponse.h"
#import "WSPlistHelper.h"
#import "FileManager.h"

#define kCrashLogUploadProtocolType 444
#define kCrashLogFileNamePrefix @"crashLog"

#define kDataBaseName @"wch_DataBase.db"

static WCLogManager *_instance;

@interface WCLogManager ()

@property (nonatomic, copy) NSString *zipFileName;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end

@implementation WCLogManager

+ (WCLogManager*)sharedInstance
{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[WCLogManager alloc] init];
        });
    }
    
    return _instance;
}

-(NSDateFormatter *)dateFormatter
{
    if (nil == _dateFormatter) {
        _dateFormatter = [NSDateFormatter standardDateFormatter];
        [_dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    return _dateFormatter;
}

+ (NSString*)safeStringForDiskRepresentation:(NSString*)candidate {
    NSCharacterSet *invalidCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:@"];
    return [[candidate componentsSeparatedByCharactersInSet:invalidCharacters] componentsJoinedByString:@"_"];
}

- (NSString*)getEmpID
{
    NSString *empID = [[NSUserDefaults standardUserDefaults] objectForKey:APPDATA_EMPID];
    empID = empID ? empID : @"0";
    return empID;
}

- (NSString*)getEmpName
{
    NSString *empName = [[NSUserDefaults standardUserDefaults] objectForKey:EMPNAME];
    empName = empName ? empName : @"UnknownUser";
    return empName;
}

- (NSString*)getUserName
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
    userName = userName ? userName : @"UnknownUser";
    return userName;
}

- (NSString*)creatZipFileName:(UploadLogTyped)UploadLogTyped //(BOOL)isOnlyUploadCrashLog
{
    NSString *logTypeStr = nil;//isOnlyUploadCrashLog?@"crash":@"all"
    switch (UploadLogTyped)
    {
        case UploadLogTypedAll:
            logTypeStr = @"all";
            break;
        case UploadLogTypedImageNilError:
            logTypeStr = @"ImageNilError";
            break;
        case UploadLogTypedCrash:
            logTypeStr = @"crash";
            break;
    
        default:
            break;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@-%@.zip",
                         [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey],
                          [WSEnvrionment getAppSystemVersion],
                          [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName],
                          [self getEmpID],
                          [self getUserName],
                          [self.dateFormatter stringFromDate:[NSDate date]],
                          logTypeStr];
    
    fileName = [WCLogManager safeStringForDiskRepresentation:fileName];
    
    return fileName;
}

- (NSString*)getLogDir
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [pathArray lastObject];
    NSString *logDir = [documentPath stringByAppendingPathComponent:@"Log"];
    return logDir;
}

- (NSString*)getCrashLogDir
{
    
    NSString *crashLogDir = [[self getLogDir] stringByAppendingPathComponent:@"CrashLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:crashLogDir isDirectory:&isDir]) {
        isDir = [fileManager createDirectoryAtPath:crashLogDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (isDir) {
        return crashLogDir;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getErrorLogDir
{
    
    NSString *errorLogDir = [[self getLogDir] stringByAppendingPathComponent:@"ErrorLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:errorLogDir isDirectory:&isDir]) {
        isDir = [fileManager createDirectoryAtPath:errorLogDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (isDir) {
        return errorLogDir;
    }
    else
    {
        return nil;
    }
}
- (NSString*)getZipLogDir
{
    
    NSString *errorLogDir = [[self getLogDir] stringByAppendingPathComponent:@"ZipLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if (![fileManager fileExistsAtPath:errorLogDir isDirectory:&isDir]) {
        isDir = [fileManager createDirectoryAtPath:errorLogDir withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if (isDir) {
        return errorLogDir;
    }
    else
    {
        return nil;
    }
}

- (NSString*)getCrashLogFilePath
{
    NSString *dir = [self getCrashLogDir];
    
    if (nil == dir) {
        return nil;
    }
    
    
    NSString *crashFileName = [NSString stringWithFormat:@"%@-%@.txt", kCrashLogFileNamePrefix, [self.dateFormatter  stringFromDate:[NSDate date]]];
    
    NSString *crashFilePath = [dir stringByAppendingPathComponent:crashFileName];
    
    return crashFilePath;
}

- (NSData*)getLogFileZipDataFromDirPath:(NSString*)dirPath withZipFileName:(NSString*)zipFileName
{
    NSData *zipData = nil;
    
    if (dirPath) {
        NSError *error;
        NSArray *fileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:&error] pathsMatchingExtensions:@[@"txt"]];
        if (!error && fileNames != nil && [fileNames count] > 0) {

            ZipArchive *zipFile = [[ZipArchive alloc] init];
            NSString *zipFilePath = [dirPath stringByAppendingPathComponent:zipFileName];
            [zipFile CreateZipFile2:zipFilePath];
            
            for (NSString *fileName in fileNames) {
                NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
                [zipFile addFileToZip:filePath newname:fileName];
            }
            [zipFile CloseZipFile2];
            
            zipData = [NSData dataWithContentsOfFile:zipFilePath];
        }
    }
    
    return zipData;
}

- (NSData *)getDiagnosticUploadDataWithZipFileName:(NSString *)zipFileName isOnlyUploadCrashLog: (UploadLogTyped)UploadLogTyped //(BOOL)
{
    NSData *zipData = nil;
    
    NSString *crashDir = [self getCrashLogDir];
    NSString *errorDir = [self getErrorLogDir];
    NSString *zipDir   =  [self getZipLogDir];
    
    if (crashDir) {
        NSError *error;
        NSArray *fileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:crashDir error:&error] pathsMatchingExtensions:@[@"txt"]];
        //YIHAIKERRY-3233   SFA益海嘉里 IOS【诊断日志】手机端的诊断日志保留60天，上传时需要选择日期进行上传
        if (self.selCrashDate) {
            fileNames = [self selectDateLogNames:fileNames withSelString:self.selCrashDate];  //指定日期的crashlog
        }
       
        if (UploadLogTyped == UploadLogTypedCrash && [fileNames count] == 0) {
            return nil;
        }
        ZipArchive *zipFile = [[ZipArchive alloc] init];
        NSString *zipFilePath = [zipDir stringByAppendingPathComponent:zipFileName];
        [zipFile CreateZipFile2:zipFilePath];
        
        BOOL hasData = NO;
        
        if (!error && fileNames != nil && [fileNames count] > 0)
        {
            
            for (NSString *fileName in fileNames)
            {
                NSString *filePath = [crashDir stringByAppendingPathComponent:fileName];
                [zipFile addFileToZip:filePath newname:fileName];
            }
            
            hasData = YES;
            
        }
        if (errorDir)
        {
            NSArray *errorfileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:errorDir error:&error];
            
            //YIHAIKERRY-3233   SFA益海嘉里 IOS【诊断日志】手机端的诊断日志保留60天，上传时需要选择日期进行上传
            if (self.selErrorDate) {
                errorfileNames = [self selectDateLogNames:errorfileNames withSelString:self.selErrorDate];  //指定日期的errorlog
            }
            
            if (!error && errorfileNames != nil && [errorfileNames count] > 0) {
                
                for (NSString *fileName in errorfileNames)
                {
                    NSString *filePath = [errorDir stringByAppendingPathComponent:fileName];
                    [zipFile addFileToZip:filePath newname:fileName];
                }
                
                hasData = YES;
                
            }
        }
        
        NSString *dataBaseFilePath= [[FileManager Documents] stringByAppendingPathComponent:kDataBaseName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dataBaseFilePath])
        {
            [zipFile addFileToZip:dataBaseFilePath newname:kDataBaseName];
            hasData = YES;
        }
        
        NSString *userName =  (NSString *)[FileManager getUserDefaults:USERNAME];
        if (userName && [userName length] > 0)
        {
            NSString *loginDataFilePath = [[FileManager Documents] stringByAppendingPathComponent:LOGIN_DATA_FILENAME_BYUSER(userName)];
            if ([[NSFileManager defaultManager] fileExistsAtPath:loginDataFilePath])
            {
                [zipFile addFileToZip:loginDataFilePath newname:LOGIN_DATA_FILENAME_BYUSER(userName)];
                hasData = YES;
            }
        }
        
        [zipFile CloseZipFile2];
        
        if (hasData)
        {
            zipData = [NSData dataWithContentsOfFile:zipFilePath];
        }
//        }
    }
    
    return zipData;
}


/*
 都是字符串类型，建议长度50
 
 --project:    SFA项目名称(使用原协议中的grp)
 --Version:    SFA客户端版本号 (使用原协议中的appver 值为  Version_Aku)
 --Aku:        SFA客户端SVN Release版本号 (使用原协议中的appver 值为  Version_Aku)
 userid:     SFA用户ID
 username:   SFA用户名称
 
 platform:   sfai_winchannel
 grp:        按SFA项目简称
 src:        winchannel
 
 所有参数：
 TODO:【公共】参数默认值需要修改。
 --【公共】"imei": "834828432efa398",
 --【公共】"platform": "crma_loreal",
 --【公共】"grp": "loreal",
 --【公共】"src":"",//合作伙伴标识
 --【公共】"lang":"zh",//当前语言
 "manufacturer": "samsung",//手机厂商
 "phonetype":"i9300", //手机型号，如 i9300
 "osver":"4.1.2",//手机系统版本号，android系统为android系统版本号
 "appver":"1.0",//应用程序版本号
 "userid":"***",//用户ID
 "username":"*****",    //用户名称
 "uploadFile":"***.txt:100,###.log:155"//上传文件清单
 "project":SFA项目名称
 
 */

- (void)uploadLog:(UploadLogTyped)uploadLogTyped
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *zipFileName = [self creatZipFileName:uploadLogTyped ];//isOnlyUploadCrashLog];
        NSData *zipData = [self getDiagnosticUploadDataWithZipFileName:zipFileName isOnlyUploadCrashLog:uploadLogTyped];//isOnlyUploadCrashLog];
        __block NSString *notifyStr = nil;
        switch (uploadLogTyped) {
            case UploadLogTypedCrash:
                notifyStr = kUploadAllLogDataFinishNotifyName;
                break;
            case UploadLogTypedAll:
                notifyStr = kUploadAllLogDataFinishNotifyName;
                break;
            case UploadLogTypedImageNilError:
                notifyStr = kUploadImageNilFinishNotifyName;
                break;
                
            default:
                break;
        }
        if (zipData)
        {
            NSDictionary *paramDic = @{@"manufacturer": @"apple",
                                       @"phonetype": [[UIDevice currentDevice] modelName],
                                       @"osver": [UIDevice currentDevice].systemVersion,
                                       @"appver": [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName],
                                       @"userId": [self getEmpID],
                                       @"userName": [self getEmpName],
                                       @"uploadFile": zipFileName,
                                       @"project":[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]};
            
            
            WCBaseRequest *request = [[WCBaseRequest alloc] initPostLogFileWithURLString:[WCGlobalSingleton sharedInstance].gNaviFileItem.upload
                                                                       params:paramDic
                                                                 protocolType:kCrashLogUploadProtocolType
                                                                     fileData:zipData];
            if (!request) {
                NSDictionary *userinfo = @{kUploadAllLogDataResultKey: @NO};
                [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr object:self userInfo:userinfo];
                return ;
            }
            
            
            [request sendRequestForLogBusinessWithCompletionBlock:^(WinAFHTTPRequestOperation *completedOperation, WCBaseResponse *response) {
                BOOL isSuccess = NO;
                if (nil == response.error) {
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:[self getZipLogDir] error:nil];//删除压缩数据
                    //备注：日志不用手动删除，设置了最大条数，超过了，ddlog会自己删除超出的 
                    //现在所有的类型都是上传全部日志，上传完成后即删除全部日志。
                    //SFA-26065
                    //备注：CrashLog文件上传完成后需要直接删除防止重复上传
                     [fileManager removeItemAtPath:[self getCrashLogDir] error:nil];
                    // [fileManager removeItemAtPath:[self getErrorLogDir] error:nil];
                    
                    
                    self.zipFileName = nil;
                    isSuccess = YES;
                }
                
                NSDictionary *userinfo = nil;
                if (isSuccess) {
                    userinfo = @{kUploadAllLogDataResultKey: @YES};
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr object:self userInfo:userinfo];
                
            }];
        }
        else
        {
            NSDictionary *userinfo = @{kUploadAllLogDataResultKey: @YES};
            [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr object:self userInfo:userinfo];
        }
    });
}


#pragma mark - public methods

-(void)setUpUncaughtExceptionHandler
{
    InstallUncaughtExceptionHandler();
}

/**
 *	@brief	setup app level logger with xcodecolors plugin and customized DDLogFormatter
 *  @see https://github.com/robbiehanson/CocoaLumberjack/wiki/XcodeColors
 */
-(void)setUpDDlogger
{
        
    WCLogFormatter *formatter = [[WCLogFormatter alloc] init];
    //[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[self getErrorLogDir]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    
    //YIHAIKERRY-3233
    //SFA益海嘉里 IOS【诊断日志】手机端的诊断日志保留60天，上传时需要选择日期进行上传
    NSString * logMaxCount = [[NSUserDefaults standardUserDefaults] stringForKey:LOG_FILE_COUNT];
    logMaxCount = (logMaxCount ? logMaxCount : @"4" );
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = [logMaxCount integerValue] ;
    
    [fileLogger setLogFormatter:formatter];
    
    UIColor *pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
    
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:LOG_FLAG_ERROR];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:LOG_FLAG_WARN];
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_VERBOSE];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
   
#ifdef DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif

    [DDLog addLogger:fileLogger];
    
    
//    char *xcode_colors = getenv("XcodeColors");
//    NSString *xcodecolorsInfo = nil;
//    if (xcode_colors)
//    {
//        if (strcmp(xcode_colors, "YES") == 0) {
//            xcodecolorsInfo = @"XcodeColors enabled";
//            [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
//        }
//        else
//            xcodecolorsInfo = @"XcodeColors disabled";
//    }
//    else
//    {
//        xcodecolorsInfo = @"XcodeColors not detected";
//    }
//    
//    DDLogVerbose(@"%@", xcodecolorsInfo);

}

- (void)addCrashLog:(NSString *)crashLog
{
    
    NSError *error;
//    NSString *crashLogString = [NSString stringWithFormat:@"=================崩溃日志================\n 项目:%@\n 版本:%@\n empId:%@\n empName:%@\n 系统版本:%@\n 设备型号:%@\n 时间:%@\n 崩溃信息:\n%@",
//                                [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey],
//                                [PropertyManager getPropertybyKey:SVNVersion],
//                                [self getEmpID],
//                                [self getEmpName],
//                                [[UIDevice currentDevice] systemVersion],
//                                [[UIDevice currentDevice] model],
//                                [self.dateFormatter stringFromDate:[NSDate date]],
//                                crashLog];
    NSString *crashLogString = [NSString stringWithFormat:@"=================崩溃日志================\n 项目:%@\n 版本:%@\n svn版本:%@\n empId:%@\n empName:%@\n 系统版本:%@\n 设备型号:%@\n 时间:%@\n 崩溃信息:\n%@",
                                [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey],
                                [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName],
                                [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName],
                                [self getEmpID],
                                [self getEmpName],
                                [[UIDevice currentDevice] systemVersion],
                                [[UIDevice currentDevice] platform],
                                [self.dateFormatter stringFromDate:[NSDate date]],
                                crashLog];
    
    if (![crashLogString writeToFile:[self getCrashLogFilePath] atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        DDLogError(@"\n\n[ LogError Write crash log to file failed!\n error:%@\n \ncrashLog:\n%@ ]\n\n",error, crashLog);
    }

}

- (void)startUploadLog:(UploadLogTyped)uploadLogTyped
{
    LogTrace();
    NSString *notifyStr = nil;
    switch (uploadLogTyped) {
        case UploadLogTypedCrash:
            notifyStr = kUploadAllLogDataFinishNotifyName;
            break;
        case UploadLogTypedAll:
            notifyStr = kUploadAllLogDataFinishNotifyName;
            break;
        case UploadLogTypedImageNilError:
            notifyStr = kUploadImageNilFinishNotifyName;
            break;
            
        default:
            break;
    }
    if ([WCGlobalSingleton sharedInstance].gNaviFileItem.loadFinished != YES) {
        WCBaseRequest *naviRequest = [[WCBaseRequest alloc] initGetNaviFileWithURLString:kSFANaviFileUrl];
        [naviRequest registerResponseDataClassForLogBusiness:[WCNaviFileResponse class]];
        [naviRequest sendRequestForLogBusinessWithCompletionBlock:^(WinAFHTTPRequestOperation *completedOperation, WCBaseResponse *response) {
            
            if (response.jsonResponse) {
                WCNaviFile *navFile = [[WCNaviFile alloc] initWithDictionary:response.jsonResponse];
                [WCDataPacker sharedInstance].salt = navFile.salt;
                [WCGlobalSingleton sharedInstance].gNaviFileItem = navFile;
                [WCGlobalSingleton sharedInstance].gNaviFileItem.loadFinished = YES;
                
                
                [[WCLogManager sharedInstance] uploadLog:uploadLogTyped];
                
                DDLogInfo(@"\n[ LogInfo -  navi success, %@ ]\n", response.jsonResponse);
            }
            else
            {
                DDLogError(@" \n\n[ LogError get navi file error, %@ ]\n\n", response.error);
                [[NSNotificationCenter defaultCenter] postNotificationName:notifyStr object:self userInfo:nil];
            }
        }];
    }
    else
    {
        [[WCLogManager sharedInstance] uploadLog:uploadLogTyped];
    }
    
    
}


- (void)saveEmpIDAndEmpName
{
    NSString *empID = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *empName = [WSAppData getObjectbyKey:EMPNAME];
    if ([empID isKindOfClass:[NSNumber class]]) {
        empID = [(NSNumber *)empID  stringValue];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil != empID && [empID length] > 0) {
        [defaults setObject:empID forKey:APPDATA_EMPID];
    }
    if (nil != empName && [empName length] > 0) {
        [defaults setObject:empName forKey:EMPNAME];
    }
    
}
//获取选中日期的lognames
-(NSArray *)selectDateLogNames:(NSArray *)logNames withSelString:(NSString *)selectDate {
    NSMutableArray *selectNames = [NSMutableArray array];
    
    for (int i = 0; i <logNames.count ; i ++) {
        NSString *str = logNames[i];
        if ([str containsString:selectDate]) {
            [selectNames addObject:str];
        }
    }
    return selectNames;
}
//判断指定日期是否有日志，有yes
-(BOOL)checkIsHasData
{
    NSString *crashDir = [self getCrashLogDir];
    NSString *errorDir = [self getErrorLogDir];
    NSArray *fileNames = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:crashDir error:nil] pathsMatchingExtensions:@[@"txt"]];
    NSArray *errorfileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:errorDir error:nil];

    fileNames = [self selectDateLogNames:fileNames withSelString:self.selCrashDate];  //指定日期的crashlog
    errorfileNames = [self selectDateLogNames:errorfileNames withSelString:self.selErrorDate];  //指定日期的errorlog
   
    if (errorfileNames.count || fileNames.count) {
        return YES;
    }else {
        return NO;
    }

}


@end
