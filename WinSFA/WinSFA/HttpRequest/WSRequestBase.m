//
//  WSRequestBase.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//
#import "WSPrintUtil.h"

#import "WSRequestBase.h"
#import "DecompressUtil.h"
#import "WinSFA.h"
#import "WSOffLineUploadTable.h"
#import "WSInoutStoreTable.h"
#import "WSFacTable.h"
#import "WSFdtTable.h"
#import "WSCurrentTime.h"
#import "Reachability.h"
#import "FileManager.h"
#import "WSHttpResponseServer.h"
#import "WSOfflineDataManager.h"
#import "WSJSONBuilder.h"
#import "WCBaseRequest.h"
#import "WSNormalHttpResponse.h"

#import "JSONKit.h"

#import "WSOfflineDataDBService.h"
#import "WSPhotoLogicService.h"
#import "WSEnvrionment.h"
#import "WSBadgeValueTool.h"

#define CHECKDATE_ALERT_TAG 1001
#define EXIT_ALERT_TAG 1002
#define HTTPTYPE_POST   @"POST"
#define LANGUAGE        @"language"


@interface WSRequestBase ()
@property (nonatomic, assign) BOOL addedBackbgImage;
@property (nonatomic, strong) BlockAlertView *exitAlertView;
@property (nonatomic, strong) BlockAlertView *checkDateAlertView;
@end

@implementation WSRequestBase
@synthesize who;

static WSRequestBase* instance = nil;

+(WSRequestBase*)shareInstance
{
    if(instance == nil)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            instance = [[super allocWithZone:NULL]init];
        });
        
    }
    
    return instance;
}
#pragma mark  init and copy

+(id)allocWithZone:(NSZone *)zone
{
    return [self shareInstance];
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _uploadRequestArray = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)isRequestInUploadQueue:(NSString *)notifyName md5:(NSString *)md5
{
    BOOL isExist = NO;
    for (WCBaseRequest *request in self.uploadRequestArray) {
        if ([request.localInfo.m_notify isEqualToString:notifyName] && [request.localInfo.m_identifiter isEqualToString:md5]) {
            isExist = YES;
            break;
        }
    }
    
    return isExist;
}

#pragma mark - login(report)

- (void)startReportLoginbyPost:(NSString *)URL
                    notifyName:(NSString *)notifyName
                   userAccount:(NSString *)userAccount
                  userPassword:(NSString *)userPassword
{
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    request.localInfo = requestLocalInfo;
    
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    
    NSString *ssoLoginState = [[NSUserDefaults standardUserDefaults] objectForKey:SSOLOGINSTATE];
    if ([ssoLoginState isEqualToString:@"1"]) {
        [paramters setValue:userAccount forKey:@"ssoUserAccount"];
    } else {
        [paramters setValue:userAccount forKey:@"userAccount"];
        [paramters setValue:userPassword forKey:@"userPassword"];
    }
    
    [request asyncPostBodyDataWithDictionary:paramters urlString:URL  success:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
    } failure:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
    }];
    
    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@", URL, paramters, notifyName);
    
}

#pragma mark - post video
- (void)postVideoData:(NSData *)videoData
                  url:(NSString *)aUrl
           notifyName:(NSString *)notifyName
                  md5:(NSString *)md5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    
    //reuqest 附加信息，不上传。
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.m_identifiter = md5;
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    request.localInfo = requestLocalInfo;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setValue:[UIDevice getPreferredLanguage] forKey:@"Accept-Language"];
    [headers setValue:@"keep-alive" forKey:@"connection"];
    [headers setValue:@"UTF-8" forKey:@"Charset"];
    [headers setValue:@"mov" forKey:@"extension"];
    [headers setValue:md5 forKey:@"videoIndex"];
    [headers setValue:@"F_VIDEO" forKey:@"method"];
    NSObject *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [headers setValue:[NSString stringWithValue:syncDate] forKey:@"syncDate"];
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [headers setValue:userName forKey:@"winc-ua"];
    
    [request setHttpHeaders:headers];
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];
    
    NSString * newURLString = [self completeUrlParameter:aUrl];
    [request asyncPostViedoData:videoData urlString:newURLString  success:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
    } failure:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
    }];
    
    
    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@ \nmd5:%@", aUrl, headers, notifyName, md5);
    
}

- (void)postVideoFilePath:(NSString *)filePath
                      url:(NSString *)aUrl
               notifyName:(NSString *)notifyName
                      md5:(NSString *)md5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    
    //reuqest 附加信息，不上传。
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.m_identifiter = md5;
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    request.localInfo = requestLocalInfo;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setValue:[UIDevice getPreferredLanguage] forKey:@"Accept-Language"];
    [headers setValue:@"keep-alive" forKey:@"connection"];
    [headers setValue:@"UTF-8" forKey:@"Charset"];
    [headers setValue:@"mov" forKey:@"extension"];
    [headers setValue:md5 forKey:@"videoIndex"];
    [headers setValue:@"F_VIDEO" forKey:@"method"];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [headers setValue:userName forKey:@"winc-ua"];

    NSObject *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [headers setValue:[NSString stringWithValue:syncDate] forKey:@"syncDate"];
    }
    [request setHttpHeaders:headers];
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];
    
    NSString * newURLString = [self completeUrlParameter:aUrl];
    [request asyncPostViedoFilePath:filePath urlString:newURLString  success:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
    } failure:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
    }];
    
    
    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@ \nmd5:%@ \nfilePath:%@", aUrl, headers, notifyName,md5 ,filePath);
    
}
- (void)postUrlString:(NSString *)aUrlString
              headers:(NSDictionary *)parameters
                files:(NSArray *)files
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5{
    
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    request.localInfo = requestLocalInfo;
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];

    [request asyncPostBodyData:parameters files:files urlString:aUrlString success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
         [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
    }];

    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@", aUrlString, parameters, notifyName);
}
#pragma mark - post image
- (void)postUrlString:(NSString *)aUrlString
           headers:(NSDictionary *)parameters
             filePath:(NSString *)filePath
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
{
    LogTrace();
    LogInfo(@"上传照片请求");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    
    //reuqest 附加信息，不上传。
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.m_identifiter = md5;
    requestLocalInfo.uploadType = WCDatasUploadTypeDefault;
    requestLocalInfo.requestIsForPhoto = YES;
    request.localInfo = requestLocalInfo;
    
    //request head
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:7];
    [headers setValue:@"keep-alive" forKey:@"connection"];
    [headers setValue:@"UTF-8" forKey:@"Charset"];
    [headers setValue:@"JPEG" forKey:@"extension"];
    [headers setValue:[NSString stringNotNilWithValue:md5] forKey:@"imageIndex"];
    NSString *account = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    if(account){
        [headers setValue:account forKey:@"account"];
        //[headers setValue:account forKey:@"winc-ua"];
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [headers setValue:userName forKey:@"winc-ua"];
    
    [headers setValue:[WSCurrentTime getTimeMillisString] forKey:@"uploadDate"];
    [headers setValue:@"F_PHOTO" forKey:@"method"];
    id syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [headers setValue:syncDate forKey:@"syncDate"];
    }
    
    
    NSString *fc = [WSPhotoLogicService getFCFromImageIndex:md5];
    if ([fc length] > 0) {
        [headers setValue:fc forKey:@"fc"];
    }
    
    NSArray *allkeys = [parameters allKeys];
    for (NSString *key in allkeys) {
        NSString *value = [parameters objectForKey:key];
        if (value) {
             [headers setValue:[NSString stringNotNilWithValue:value] forKey:key];
        }
    }
    if ([WSEnvrionment getUseAliyun]) {
        [headers setValue:PHOTOTYPE_ALIYUN forKey:@"photoFrom"];
    }
    
    [request setHttpHeaders:headers];
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];
    //服务端日志
    NSMutableDictionary *bodyDataDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    [bodyDataDictionary setValue:@"isphotoexist" forKey:md5];
    if (account) {
        [bodyDataDictionary setValue:@"1" forKey:account];
    }
    [bodyDataDictionary setValue:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [bodyDataDictionary setValue:[NSString stringNotNilWithValue:md5] forKey:@"imageIndex"];
    //有photoKey就传，没有则不传
    if ([parameters objectForKey:@"photoKey"]) {
            [bodyDataDictionary setValue:[NSString stringNotNilWithValue:[parameters objectForKey:@"photoKey"]] forKey:@"photoKey"];
    }

    NSString * newURLString = [self completeUrlParameter:aUrlString];
    
    if (![WSEnvrionment getUseAliyun]) {
        [request asyncPostBodyData:bodyDataDictionary imageFilePath:filePath urlString:newURLString success:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
            [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
        } failure:^(WCBaseResponse *response,WCBaseRequestLocalInfo *localInfo) {
            [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
        }];
    } else {
        [request asyncPostBodyDataWithDictionary:parameters urlString:newURLString success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
        }];
    }
   
    
    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@ \nmd5:%@ \nfilePath:%@", aUrlString, headers, notifyName, md5, filePath);

}
#pragma mark - post json
/**
 *  post方式发送json数据
 *
 *  @param aUrlString  服务端地址
 *  @param parameters  字典类【可转换成json】
 *  @param notifyName
 *  @param md5
 *  @param aUploadType
 */
- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload

{
    [self postUrlString:aUrlString parameters:parameters notifyName:notifyName md5:md5 withUploadType:aUploadType isUpload:isUpload progress:nil];
}

- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload
             progress:(WCRequestProgressBlock)progressBlock {
    [self postUrlString:aUrlString parameters:parameters notifyName:notifyName md5:md5 withUploadType:aUploadType isUpload:isUpload timeout:0 progress:progressBlock];
}


- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload
              timeout:(NSInteger)timeout
             progress:(WCRequestProgressBlock)progressBlock

{

    if (isUpload && [self isRequestInUploadQueue:notifyName md5:md5]) {
        return;
    }


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    //add by wang 04-16 for 多张图片的更新问题，给notifyname重新赋直
    /* 对于同步上传调查问卷 此处截取通知名称会造成通知名字改变 导致post通知失败，前人写代码不知为何，故注掉.
    BOOL isConstraintSyn = NO;
    if ([notifyName hasSuffix:kForcibleSynchronizeRequest]) {
        
        isConstraintSyn = YES;
        
        int length = notifyName.length;
        
        notifyName = [notifyName substringToIndex: length - kForcibleSynchronizeRequest.length];
    }
     */
    
    //当前页面上传时，卡住页面，等上传OK再进行下一步就可以做到工作流同步，数据异步上传 。
    WCBaseRequest *request = [[WCBaseRequest alloc] init];
    WCBaseRequestLocalInfo *requestLocalInfo = [[WCBaseRequestLocalInfo alloc] init];
    requestLocalInfo.m_notify = notifyName;
    requestLocalInfo.m_identifiter = md5;
    requestLocalInfo.uploadType = aUploadType;
    NSString *userName =[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];

    request.localInfo = requestLocalInfo;
    
    if (userName) {
        [request setHttpHeaders:@{@"Accept-Language":[UIDevice getPreferredLanguage],@"winc-ua":userName}];
    }else {
        [request setHttpHeaders:@{@"Accept-Language":[UIDevice getPreferredLanguage]}];
    }
    // 按照后台要求，且与 Android 保持一致
    NSMutableDictionary *paramDics = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [paramDics setObject:[UIDevice getPreferredLanguage] forKey:LANGUAGE];
    
    [request registerResponseDataClassForLogBusiness:[WSNormalHttpResponse class]];
    
    NSString * newURLString = [self completeUrlParameter:aUrlString];
    
    
    if (isUpload) {
        [self.uploadRequestArray addObject:request];
    }
    
    [request asyncPostJson:paramDics urlString:newURLString isUpload:isUpload timeout:timeout success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFinished:response andLocalInfo:localInfo];
        [self.uploadRequestArray removeObject:request];
        //同步请求，请求成功再回调
        if (isUpload) {
            if (self.requestSuccess) {
                self.requestSuccess();
            }
        }
        
    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        [[WSRequestBase shareInstance] requestFailed:response andLocalInfo:localInfo];
        [self.uploadRequestArray removeObject:request];

    } progress:progressBlock];
    
    LogInfo(@"url:%@ \nparams:%@ \nnotifyName:%@ \nmd5:%@", aUrlString, parameters, notifyName,md5);
    
}

#pragma mark - finished , failed , cancel

- (void)cancelRequest
{
    [[WCNetworkEngine sharedInstance] cancelAllRequest];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:REQUESTFINISHED object:nil];
}

- (void)requestFinished:(WCBaseResponse *)response andLocalInfo:(WCBaseRequestLocalInfo *)localInfo
{
    LogInfo(@"response    notify name is %@",[localInfo m_notify]);
    
    NSDictionary *jsonDictionary = response.jsonResponse;
    
    NSString *m_notify = [localInfo.m_notify copy];

    NSString *result =[NSString stringWithFormat:@"%@",[jsonDictionary objectForKey:@"result"]] ;
    
    LogResponseString([jsonDictionary JSONString],LOG_LENGTH);
    if(!jsonDictionary || [jsonDictionary count] < 1){
        LogWarn(@"response is empty->responseData:%@ || responseString:%@",jsonDictionary,response.jsonResponse);
        //离线上传
        // SFA-13590 （根本原因：数据解析错误， 业务逻辑错误：如果上传成功没有返回数据，或者返回数据解析错的情况下 不应该去更新离线数据库，这种更新就不合理。）  
//        [self updateOffLineDataBase:localInfo];
        if(m_notify != nil)
            [[NSNotificationCenter defaultCenter] postNotificationName:m_notify
                                                                object: nil
                                                              userInfo:nil];
        //exception
        [self removeExceptionRecordWithNotify:m_notify];
        
        /*Jira - MSTD-6983 MSTD-7247 create by sunhongfu */ 
        [WSBadgeValueTool changeTabBarItemBadgeValueWithNumber:[NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]]];
        
        return;
    }

    
    //is_offline_landing = 1 时，不校验业务日期
    NSString *isOfflineLanding = [[NSUserDefaults standardUserDefaults] objectForKey:IS_OFFLINE_LANDING];
    if (!isOfflineLanding || ![isOfflineLanding isEqualToString:@"1"]) {
        
        //检查业务日期
        NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
        if (bizDate){
            NSString *newbizDate = [jsonDictionary objectForKey:APPDATA_BIZDATE];
            if (newbizDate && [newbizDate isKindOfClass:[NSString class]]) {
                if (![newbizDate isEqualToString:bizDate]) {
                 
                    NSString *errorBizDate = NSLocalizedString(@"bizdate_error_tip", nil);
                    NSString *title = NSLocalizedString(@"js_alert_title", nil);
                    NSString *ok = NSLocalizedString(@"confirm", nil);
                    if (!_checkDateAlertView) {
                        
                        _checkDateAlertView = [BlockAlertView alertWithTitle:title message:errorBizDate];
                        
                        __weak typeof(self) _weakSelf = self;
                        
                        [_checkDateAlertView setCancelButtonWithTitle:ok block:^{
                            LogInfo(@"\n\n[ LogInfo - 业务日期与服务器时间不符，强制退出] \n\n");
                            
                            _weakSelf.checkDateAlertView = nil;
                            
                            //保存应用上次退出状态以及相关信息
                            [FileManager setUserDefaults:[NSNumber numberWithInteger:ExitAppStatusBizdateError] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
                            [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
                            NSString *versionCode = [WSEnvrionment getAppSystemVersion];
                            [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
                            NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                            [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
                            NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
                            [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
                            [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
                            exit(0);
                        }];
                        
                        [_checkDateAlertView show];
                    }
                }
            }
        }
        
    }

    if (localInfo.uploadType || [m_notify hasPrefix:kOfflineTableNotifyIdPrefix])
    {
        if ([m_notify hasPrefix:kOfflineTableNotifyIdPrefix_AddedNewsStore])
        {
            localInfo.uploadType = WCDatasUploadTypeAddNewStore;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:jsonDictionary localInfo:localInfo];
        }
        else if ([m_notify hasPrefix:kOfflineTableNotifyIdPrefix_ModifyAddedNewStore])
        {
            localInfo.uploadType = WCDatasUploadTypeModifyAddedNewStore;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:jsonDictionary localInfo:localInfo];
        }
        else if ([m_notify hasPrefix:kOfflineTableNotifyIdPrefix_AddedNewsAcvt])
        {
            localInfo.uploadType = WCDatasUploadTypeAddAcvt;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:jsonDictionary localInfo:localInfo];
        }
    }
    NSString* ret = [self converJsonString:[jsonDictionary JSONString]];
    
    ret = [ret stringByReplacingOccurrencesOfString:@"x:1" withString:@"\"x\":1"];
    
    NSString *tmp = @"x:1";
    NSRange range = [ret rangeOfString:tmp];
    
    NSMutableString *mRet = [[NSMutableString alloc] initWithString:ret];
    if (range.length > 0){
        [mRet replaceCharactersInRange:range withString:@"\"x\":1"];
    }
    
    memset(&range, 0, sizeof(NSRange));
    range = [mRet rangeOfString:@"isGps:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isGps\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isGps:"];
    }
    
    range = [mRet rangeOfString:@"isPic:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isPic\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isPic:"];
    }
    
    range = [mRet rangeOfString:@"isRule:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isRule\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isRule:"];
    }
    
    range = [mRet rangeOfString:@"isMemo:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isMemo\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isMemo:"];
    }
    
    range = [mRet rangeOfString:@"isCode:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isCode\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isCode:"];
    }
    
    range = [mRet rangeOfString:@"isMore:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isMore\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isMore:"];
    }
    
    range = [mRet rangeOfString:@"isSingle:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"isSingle\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"isSingle:"];
    }
    
    range = [mRet rangeOfString:@"numMemo:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"numMemo\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"numMemo:"];
    }
    
    range = [mRet rangeOfString:@"label:"];
    while (range.length > 0) {
        [mRet replaceCharactersInRange:range withString:@"\\\"label\\\":"];
        memset(&range, 0, sizeof(NSRange));
        range = [mRet rangeOfString:@"label:"];
    }
    
    NSArray *senderDictionaryKeys = [jsonDictionary allKeys];
    
   // add by jimmy
    [WSPrintUtil PrintDictionary:jsonDictionary];
    
    
    if (localInfo.requestIsForPhoto && ![WSEnvrionment getUseAliyun]) {
        if ([senderDictionaryKeys containsObject:@"result"] && [result isEqualToString:@"1"]) {
            [self updateOffLineDataBase:localInfo];
        }else {
            LogError(@"图片上传失败 \n  m_notify:%@  m_identifiter:%@  uploadType(WCDatasUploadType):%d",localInfo.m_notify,localInfo.m_identifiter,localInfo.uploadType);
        }
    }else {
        if ([senderDictionaryKeys containsObject:@"result"]) {
            [self updateOffLineDataBase:localInfo];
        }else if (localInfo.m_identifiter){
            LogError(@"数据上传失败 \n  m_notify:%@  m_identifiter:%@  uploadType(WCDatasUploadType):%d",localInfo.m_notify,localInfo.m_identifiter,localInfo.uploadType);
        }
    }
    
    /*
    if ([senderDictionaryKeys containsObject:@"result"] && [result isEqualToString:@"1"]) {
        [self updateOffLineDataBase:localInfo];
    }else if ([senderDictionaryKeys containsObject:@"result"]) {
        if (result && [result length] > 0) {
            NSDictionary *resultDic = [result objectFromJSONString];
            NSString *flag = [resultDic objectForKey:@"flag"];
            if (flag && [flag isKindOfClass:[NSNumber class]]) {
                flag = [(NSNumber*)flag stringValue];
            }
            if (flag && [flag isEqualToString:@"1"]) {
                [self updateOffLineDataBase:localInfo];
            } else {
                LogError(@"flage != 1 result:%@",result);
            }
        }
        
    }else if (![senderDictionaryKeys containsObject:@"result"]){
        [self updateOffLineDataBase:localInfo];
    }
     */
    
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:mRet forKey:DATAS];
    [userInfo setValue:[[NSNumber numberWithBool:localInfo.requestIsForPhoto] stringValue] forKey:REQUEST_IS_FOR_PHOTO];
    if(localInfo.m_notify != nil){
        [[NSNotificationCenter defaultCenter] postNotificationName:localInfo.m_notify
                                                            object: mRet
                                                          userInfo:userInfo];

    }
    
    //exception
    [self removeExceptionRecordWithNotify:localInfo.m_notify];
    
    /*Jira - MSTD-6983 create by sunhongfu */
    [WSBadgeValueTool changeTabBarItemBadgeValueWithNumber:[NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]]];
}

- (void)requestFailed:(WCBaseResponse *)response andLocalInfo:(WCBaseRequestLocalInfo *)localInfo
{
    LogInfo(@"requestFailed response    notify name is %@",[localInfo m_notify]);
    
    /*Jira - MSTD-6983 create by sunhongfu */
    [WSBadgeValueTool changeTabBarItemBadgeValueWithNumber:[NSString stringWithFormat:@"%ld",(long)[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]]];
    //将未成功的重新上传
    
    if(localInfo.m_identifiter != nil)
    {
        NSString *timeString = [WSAppData getObjectbyKey:MOBILE_AUTO_UPLOAD];
        NSScanner *scanner;
        if (timeString && [timeString length] > 0) {
            scanner = [NSScanner scannerWithString:timeString];
        }
        NSInteger minute;
        if (scanner && [scanner scanInteger:&minute]) {
            if (![WSOfflineDataManager sharedInstance].isStartAutoUpload) {
                [[WSOfflineDataManager sharedInstance] startAutoUploadWithDelayTime:minute * 60 andTimeInterval:minute * 60];
            }
        }
        
    }
    
    
    NSError *error = response.error;
    if(error!=nil || response == nil){
        NSDictionary *userInfo = nil;
        if (response == nil) {
            error = [NSError errorWithDomain:@"respones is nil" code:-1000 userInfo:nil];
        }
        userInfo = [NSDictionary dictionaryWithObject:error forKey:ERROR];
        [[NSNotificationCenter defaultCenter] postNotificationName:localInfo.m_notify
                                                            object: error
                                                          userInfo:userInfo];
    }

    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self getUploadFailedCount]];
}

-(void)removeExceptionRecordWithNotify:(NSString*)notify
{
    if([NT_EXPECTION isEqualToString:notify])
        [FileManager removeDefaultsByKey:EexceptionKey];
}

#pragma mark -  tools methods

- (NSString*)converJsonString:(NSString*)aJson
{
    NSString* sr = @"\"empName\":";
    NSMutableString* resultStr = [[NSMutableString alloc] initWithString:aJson];
    NSRange rangToSearch = NSMakeRange(0,[resultStr length]);
    NSMutableArray* aryinsert = [[NSMutableArray alloc] initWithCapacity:10];
    while (YES) {
        @autoreleasepool {
            NSRange srr = [resultStr rangeOfString:sr options:NSCaseInsensitiveSearch range:rangToSearch];
            if (srr.location == NSNotFound) {
                break;
            }
            NSLog(@"find = %@", NSStringFromRange(srr));
            
            BOOL bFind = YES;
            for (NSInteger i = srr.location+srr.length; i < [resultStr length]; i++)
            {
                unichar uc = [resultStr characterAtIndex:i];
                if (uc == ' ')
                {
                    continue;
                }
                if (uc != '"' && bFind)
                {
                    bFind = NO;
                    NSNumber* num = [[NSNumber alloc] initWithInteger:i];
                    [aryinsert addObject:num];
                }
                if (uc == '"')
                {
                    break;
                }
                if (uc == ','  )
                {
                    if (!bFind)
                    {
                        NSNumber* num = [[NSNumber alloc] initWithInteger:i];
                        [aryinsert addObject:num];
                    }
                    break;
                }
                if ((i+1) == [resultStr length])
                {
                    if (!bFind)
                    {
                        NSNumber* num = [[NSNumber alloc] initWithInteger:i+1];
                        [aryinsert addObject:num];
                    }
                    break;
                }
            }
            
            NSInteger newstart = srr.location + srr.length;
            memset(&rangToSearch, 0, sizeof(NSRange));
            rangToSearch = NSMakeRange(newstart, [resultStr length]-newstart);
        }
    }
    
    int i = 0;
    for (NSNumber* num in aryinsert)
    {
        int n = [num intValue] + i++;
        [resultStr insertString:@"\"" atIndex:n];
    }
    return resultStr;
}

- (NSString * )gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return uuid;
}


-(BOOL)timeNeedReset:(double)serverTime
{
    NSDate *date = [[NSDate alloc] init];
    NSTimeInterval currentTime = [date timeIntervalSince1970];
    
    if ([WSCurrentTime  systemCalendaIdentifierEqualTo:NSBuddhistCalendar]) {
        NSDate *gDate = [WSCurrentTime  currentDateWithCalendarIndentifier:NSGregorianCalendar];
        currentTime =[gDate timeIntervalSince1970];
    }
    if (ABS(currentTime - serverTime) > 20*60)
    {
        return YES;
        
    }
    return NO;
}

/*
 *获取上传失败的数据条数  应该挪到离线数据库
 */
-(NSInteger)getUploadFailedCount
{
    return [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
}

/*
 * 完整url  构建公共参数
 */
-(NSString*)completeUrlParameter:(NSString*)aUrl
{
    LogTrace();
    //add by wangdongyan 03-09 for url
    
    
    /* 稍后删除
    // 总上传数
    NSString* l_TTlValue=[[NSNumber numberWithInteger:[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:All]] stringValue];
    
    // 未上传数
    NSString* l_unUploadValue=[[NSNumber numberWithInteger:[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]] stringValue];
    
    NSString* l_mobileUploadTime =[NSString stringWithFormat:@"%@%@%@%@%@%@%@",aUrl,@"&mobileUploadTime=",[WSCurrentTime getTimeMillisString],@"&ttl=",l_TTlValue,@"&unuped=",l_unUploadValue];
     */

    NSString* l_mobileUploadTime =[NSString stringWithFormat:@"%@%@%@",aUrl,@"&mobileUploadTime=",[WSCurrentTime getTimeMillisString]];
    
    
    return l_mobileUploadTime;
}


/*
 * modify by wangdongyan 04-16 for 多张图片的更新问题 ， 还有下面的所有的self.who改为request.m_notify
 */
-(void)updateOffLineDataBase:(WCBaseRequestLocalInfo *)localInfo
{
    
    if (localInfo==nil) {
        
        return;
        
    }
    //    LogInfo(@"notifiy: %@, m_identifiter:%@", aRequest.m_notify, aRequest.m_identifiter);
    if ([localInfo.m_notify isEqualToString:LOGIN_NOTIFY]
        || [localInfo.m_notify isEqualToString:GETROOTCONFIG_NOTIFY]
        || [localInfo.m_notify isEqualToString:CHANGE_NOTIFY]
        || [localInfo.m_notify isEqualToString:PARTNERSMSG_NOTIFY])
    {
        

        return;
    }
    
    //md5为空时cancel了所有请求，请求结束后再把未上传数据放入队列
    //    if (aRequest.m_identifiter == nil)
    //    {
    //        NSString *timeString = [WSAppData getObjectbyKey:MOBILE_AUTO_UPLOAD];
    //        NSScanner *scanner;
    //        if (timeString && [timeString length] > 0)
    //        {
    //            scanner = [NSScanner scannerWithString:timeString];
    //        }
    //        NSInteger minute;
    //        if (scanner && [scanner scanInteger:&minute])
    //        {
    //            if (![WSOfflineDataManager sharedInstance].isStartAutoUpload)
    //            {
    //                [[WSOfflineDataManager sharedInstance] startAutoUploadWithDelayTime:minute * 60 andTimeInterval:minute * 60];
    //            }
    //        }
    //        return;
    //    }
    
    if(localInfo.m_notify == nil || ![localInfo.m_notify hasPrefix:kOfflineTableNotifyIdPrefix])
    {
        return;
    }
    
    // 更新离线上传数据状态
    [[WSOffLineUploadTable sharedTable] updateUploadFlagWithNotifyId:localInfo.m_notify];
    //通知webview重新加载页面 //YIHAIKERRY-4033
    [[NSNotificationCenter defaultCenter] postNotificationName:ACVT_UPLOAD_SUCEESS_REFRESH_WEBVIEW_NOTIFY object:nil];

}

@end
