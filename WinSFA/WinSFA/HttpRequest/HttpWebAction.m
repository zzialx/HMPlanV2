//
//  HttpWebAction.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "HttpWebAction.h"
#import "DecompressUtil.h"
#import "WinSFA.h"
#import "WSOffLineUploadTable.h"
#import "WSInoutStoreTable.h"
#import "WSFacTable.h"
#import "WSFdtTable.h"
#import "WSCurrentTime.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"
#import "FileManager.h"
#import "WSHttpResponseServer.h"
#import "WinSFA.h"
#import "WSOfflineDataManager.h"
#import "JSONBuilder.h"

#define CHECKDATE_ALERT_TAG 1001
#define EXIT_ALERT_TAG 1002
#define HTTPTYPE_POST   @"POST"



@interface HttpWebAction ()<UIAlertViewDelegate>
@property (nonatomic, assign) BOOL addedBackbgImage;
@property (nonatomic, strong) BlockAlertView *exitAlertView;
@property (nonatomic, strong) BlockAlertView *checkDateAlertView;
@end

@implementation HttpWebAction
@synthesize who;

static HttpWebAction* instance = nil;

+(HttpWebAction*)shareInstance
{
    if(instance == nil)
    {
        instance = [[super allocWithZone:NULL]init];
    }
    
    return instance;
}


//  直接上传调用

- (void)startJSONStringbyPost:(NSString *)URL
                     postData:(NSData *)postData
                   notifyName:(NSString *)notifyName
                          MD5:(NSString*)md5
{
    NSURL *url = [[NSURL alloc]initWithString:[self completeUrlParameter:URL]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    NSLog(@"传递上报数据 URL =%@" ,[url absoluteString]);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    ASIHTTPRequest* l_request = [ASIHTTPRequest requestWithURL:url];
    
    //add by wang 04-16 for 多张图片的更新问题，给notifyname重新赋直
    BOOL isConstraintSyn = NO;
    if ([notifyName hasSuffix:kForcibleSynchronizeRequest]) {
        isConstraintSyn = YES;
        int length = notifyName.length;
        notifyName = [notifyName substringToIndex: length - kForcibleSynchronizeRequest.length];
    }
    l_request.m_notify = notifyName;
    
    // 离线上报中的上次应用记录上报是不需要
    if (![notifyName hasPrefix:APPQUITREPORT]) {
         l_request.shouldStreamPostDataFromDisk = YES;
    }
    
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"
                          value:@"application/json; encoding=utf-8"];
    [l_request addRequestHeader:@"Accept-Language" value:[UIDevice getPreferredLanguage]];
    [l_request appendPostData:postData];
    
    [l_request setDelegate:self];
    [l_request setShouldContinueWhenAppEntersBackground:YES];
    l_request.m_identifiter = md5;
    
    NSOperationQueue* queue = [ASIHTTPRequest sharedQueue];
    NSArray* operations = [queue operations];
    //拥有md5的数据优先级最低 当md5 等于 nil的时候是实时请求。将请求优先级提高
    if([operations count]>0 && md5 == nil)
    {
        [l_request setQueuePriority:NSOperationQueuePriorityHigh];
    }

    if(isConstraintSyn){
        [l_request startSynchronous];
    }else{
        [l_request startAsynchronous];
    }
}

- (void)startReportLoginbyPost:(NSString *)URL
                   notifyName:(NSString *)notifyName
                    userAccount:(NSString*)userAccount
                      userPassword:(NSString *)userPassword
{
    
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URL]];
    request.m_notify = notifyName;
    
    request.delegate=self;
    [request setPostValue:userAccount forKey:@"userAccount"];
    [request setPostValue:userPassword forKey:@"userPassword"];

    [request startAsynchronous];
}


- (void)startVideoJSONStringbyPost:(NSString *)URL
                          postData:(NSData *)postData
                        notifyName:(NSString *)notifyName
                               MD5:(NSString*)md5
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    NSURL *url = [[NSURL alloc]initWithString:[self completeUrlParameter:URL]];
    NSString* l_uuid = [self gen_uuid];
    NSString* l_contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",l_uuid];
    
    ASIFormDataRequest* l_request = [ASIFormDataRequest requestWithURL:url];
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"
                          value:l_contentType];
    [l_request addRequestHeader:@"Accept-Language" value:[UIDevice getPreferredLanguage]];
    [l_request addRequestHeader:@"connection" value:@"keep-alive"];
    [l_request addRequestHeader:@"Charset" value:@"UTF-8"];
    [l_request addRequestHeader:@"extension" value:@"mov"];
    [l_request addRequestHeader:@"videoIndex" value:md5];
    [l_request addRequestHeader:@"method" value:@"F_VIDEO"];
    NSObject *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [l_request addRequestHeader:@"syncDate" value:[NSString stringWithValue:syncDate]];
    }
    
    NSString *BOUNDARY = l_uuid;
    NSString *PREFIX=@"--";
    NSString *LINE_END=@"\r\n";
    NSString *CHARSET=@"utf-8";
    NSString *fileNameString=[[NSString alloc]initWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"video\""];
    
    NSString *beginString=[NSString stringWithString:PREFIX];
    beginString= [beginString stringByAppendingString:BOUNDARY];
    beginString= [beginString stringByAppendingString:LINE_END];
    beginString= [beginString stringByAppendingString:fileNameString];
    beginString=[beginString stringByAppendingString:LINE_END];
    beginString=[beginString stringByAppendingString:@"Content-Type: application/octet-stream; charset="];
    beginString=[beginString stringByAppendingString:CHARSET];
    beginString= [beginString stringByAppendingString:LINE_END];
    beginString= [beginString stringByAppendingString:LINE_END];
    
    NSString *endString=[NSString stringWithString:PREFIX];
    endString=[endString stringByAppendingString:BOUNDARY];
    endString=[endString stringByAppendingString:PREFIX];
    endString=[endString stringByAppendingString:LINE_END];
    
    NSString *videoFileString=[[NSString alloc] init];
    videoFileString=[videoFileString stringByAppendingString:beginString];
    
    NSMutableData* l_videodata = [[NSMutableData alloc]init];
    [l_videodata appendData:[videoFileString dataUsingEncoding:NSUTF8StringEncoding]];
    [l_videodata appendData:postData];
    [l_videodata appendData:[LINE_END dataUsingEncoding:NSUTF8StringEncoding]];
    [l_videodata appendData:[endString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [l_request appendPostData:l_videodata];
    [l_request setDelegate:self];
    [l_request startAsynchronous];
}




- (void)cancelRequest
{
    NSOperationQueue* l_queue = [ASIHTTPRequest sharedQueue];
    NSArray* l_operations = [l_queue operations];
    
    for(ASIHTTPRequest* aRequest in l_operations)
    {
        [aRequest cancel];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:REQUESTFINISHED object:nil];
}

// ----------------------- 数据上传过程优化 -----------------------
- (void)startJSONStringbyPost:(NSString *)URL
                     postData:(NSData *)postData
                   notifyName:(NSString *)notifyName
                          MD5:(NSString*)md5
               withUploadType:(WCDatasUploadType)aUploadType
{
    NSURL *url = [[NSURL alloc]initWithString:[self completeUrlParameter:URL]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    ASIHTTPRequest* l_request = [ASIHTTPRequest requestWithURL:url];
    
    //add by wang 04-16 for 多张图片的更新问题，给notifyname重新赋直
    l_request.m_notify=notifyName;
    l_request.uploadType = aUploadType;
    
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"
                          value:@"application/json; encoding=utf-8"];
    [l_request addRequestHeader:@"Accept-Language" value:[UIDevice getPreferredLanguage]];
    [l_request appendPostData:postData];
    
    [l_request setDelegate:self];
    [l_request setShouldContinueWhenAppEntersBackground:YES];
    l_request.m_identifiter = md5;
    
    NSOperationQueue* queue = [ASIHTTPRequest sharedQueue];
    NSArray* operations = [queue operations];
    //拥有md5的数据优先级最低 当md5 等于 nil的时候是实时请求。2
    if([operations count]>0 && md5 == nil)
    {
        [queue cancelAllOperations];
    }
    
    [l_request startAsynchronous];
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
    }
    
    return self;
}



#pragma mark   tools methods
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
    //add by wangdongyan 03-09 for url
    
    // 总上传数
    NSString* l_TTlValue=[[NSNumber numberWithInteger:[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:All]] stringValue];
    
    // 未上传数
    NSString* l_unUploadValue=[[NSNumber numberWithInt:[[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed]] stringValue];

    NSString* l_mobileUploadTime =[NSString stringWithFormat:@"%@%@%@%@%@%@%@",aUrl,@"&mobileUploadTime=",[WSCurrentTime getTimeMillisString],@"&ttl=",l_TTlValue,@"&unuped=",l_unUploadValue];

    return l_mobileUploadTime;   
}


/*
 * modify by wangdongyan 04-16 for 多张图片的更新问题 ， 还有下面的所有的self.who改为request.m_notify
 */
-(void)updateOffLineDataBase:(ASIHTTPRequest *)aRequest
{
//    LogInfo(@"notifiy: %@, m_identifiter:%@", aRequest.m_notify, aRequest.m_identifiter);
    if ([aRequest.m_notify isEqualToString:LOGIN_NOTIFY]
        || [aRequest.m_notify isEqualToString:GETROOTCONFIG_NOTIFY]
        || [aRequest.m_notify isEqualToString:CHANGE_NOTIFY]
        || [aRequest.m_notify isEqualToString:PARTNERSMSG_NOTIFY])
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
    
    if(aRequest.m_notify == nil || ![aRequest.m_notify hasPrefix:kOfflineTableNotifyIdPrefix])
    {
        return;
    }
    
    // 更新离线上传数据状态
    [[WSOffLineUploadTable sharedTable] updateUploadFlagWithNotifyId:aRequest.m_notify];
}

-(void)removeExceptionRecord:(ASIHTTPRequest*)aRequest
{
    if([NT_EXPECTION isEqualToString:aRequest.m_notify])
        [FileManager removeDefaultsByKey:EexceptionKey];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case CHECKDATE_ALERT_TAG:
        {
            switch (buttonIndex) {
                case 0:
                    LogInfo(@"\n\n[ LogInfo - 业务日期与服务器时间不符，强制退出] \n\n");
                    _exitAlertView = nil;
                    
                    //保存应用上次退出状态以及相关信息
                    [FileManager setUserDefaults:[NSNumber numberWithInt:ExitAppStatusBizdateError] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
                    NSString *versionCode = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
                    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
                    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
                    exit(0);
                    break;
            }
        }
            break;
        case EXIT_ALERT_TAG: {
            switch (buttonIndex) {
                case 0:
                    LogInfo(@"\n\n[ LogInfo - 您的手机系统时间不准确,影响了数据的准确性,请调整您的系统时间,强制退出] \n\n");
                    _exitAlertView = nil;
//
//                    //保存应用上次退出状态以及相关信息
//                    [FileManager setUserDefaults:[NSNumber numberWithInt:ExitAppStatusBizdateError] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
//                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
//                    NSString *versionCode = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
//                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:versionCode] forKey:EXIT_APP_VERSION_USERDEFAULT_KEY];
//                    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:empId] forKey:EXIT_APP_ACCOUNT_USERDEFAULT_KEY];
//                    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
//                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:svnVersion] forKey:EXIT_APP_AKU_USERDEFAULT_KEY];
//                    [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getDateString]] forKey:EXIT_APP_SYNCDATE_USERDEFAULT_KEY];
//                    exit(0);
                    break;
                    
            }
        }
            break;
        default:
            break;
    }
    
}


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
            for (int i = srr.location+srr.length; i < [resultStr length]; i++)
            {
                unichar uc = [resultStr characterAtIndex:i];
                if (uc == ' ')
                {
                    continue;
                }
                if (uc != '"' && bFind)
                {
                    bFind = NO;
                    NSNumber* num = [[NSNumber alloc] initWithInt:i];
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
                        NSNumber* num = [[NSNumber alloc] initWithInt:i];
                        [aryinsert addObject:num];
                    }
                    break;
                }
                if ((i+1) == [resultStr length])
                {
                    if (!bFind)
                    {
                        NSNumber* num = [[NSNumber alloc] initWithInt:i+1];
                        [aryinsert addObject:num];
                    }
                    break;
                }
            }
            
            int newstart = srr.location + srr.length;
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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    LogInfo(@"response    notify name is %@",[request m_notify]);

    NSString *tmpResponse = nil;
    NSData *responseData = [DecompressUtil uncompressZippedData:[request responseData]];
    
    if (responseData == nil || responseData.length == 0) { //如果返回空数据就提前return

        tmpResponse = [[NSString alloc]
                       initWithData:[request responseData]
                       encoding:NSUTF8StringEncoding];
    }else{

        tmpResponse = [[NSString alloc]
               initWithData:responseData 
               encoding:NSUTF8StringEncoding];

    }
    
    NSDictionary *senderDictionary = [tmpResponse JSONValue];
    
    NSString *result =[NSString stringWithFormat:@"%@",[senderDictionary objectForKey:@"result"]] ;
    //应用退出记录上报 处理
    if ([[request m_notify] hasPrefix:APPQUITREPORT]) {

        // 即时上报的上次应用退出记录，本次上报不成功则插入离线上报数据表，择机上报。
        if ([request.m_notify isEqualToString:APPQUITREPORT] && ![result isEqualToString:@"1"]) {
            
            NSString *stringJson = [[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding];
            NSString *notifyID = [NSString stringWithFormat:@"%@_%@", APPQUITREPORT, [JSONBuilder gen_uuid]];
            [[WSOfflineDataManager sharedInstance] insertUploadDate:stringJson URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:notifyID];
        }
        
        // 更新离线上传表中应用退出记录的上传状态
        if (![request.m_notify isEqualToString:APPQUITREPORT] && [result isEqualToString:@"1"]) {
            
            [[WSOffLineUploadTable sharedTable] updateUploadFlagWithNotifyId:request.m_notify];
        }
    }
    
    LogResponseString(tmpResponse,LOG_LENGTH);

    if(tmpResponse == nil || tmpResponse.length == 0){
        LogWarn(@"response is empty->responseData:%@ || responseString:%@",responseData,request.responseString);
       //离线上传
//        [self updateOffLineDataBase:request];
        if(request.m_notify != nil)
            [[NSNotificationCenter defaultCenter] postNotificationName:request.m_notify
                                                                object: nil
                                                              userInfo:nil];
        //exception
        [self removeExceptionRecord:request];
        return;
    }

    //检查业务日期
    NSString *bizDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if (bizDate){
        NSString *newbizDate = [senderDictionary objectForKey:APPDATA_BIZDATE];
        if (newbizDate && [newbizDate isKindOfClass:[NSString class]]) {
            if (![newbizDate isEqualToString:bizDate]) {
                NSString *errorBizDate = NSLocalizedString(@"您的业务日期有误，请重新登陆,谢谢!", nil);
                NSString *title = NSLocalizedString(@"提示", nil);
                NSString *ok = NSLocalizedString(@"确定", nil);
                if (!_checkDateAlertView) {
                    
                    _checkDateAlertView = [BlockAlertView alertWithTitle:title message:errorBizDate];
                    
                    __weak typeof(self) _weakSelf = self;
                    
                    [_checkDateAlertView setCancelButtonWithTitle:ok block:^{
                        LogInfo(@"\n\n[ LogInfo - 业务日期与服务器时间不符，强制退出] \n\n");
                        
                        _weakSelf.checkDateAlertView = nil;
                        
                        //保存应用上次退出状态以及相关信息
                        [FileManager setUserDefaults:[NSNumber numberWithInt:ExitAppStatusBizdateError] forKey:EXIT_APP_STATUS_USERDEFAULT_KEY];
                        [FileManager setUserDefaults:[NSString stringNotNilWithValue:[WSCurrentTime getTimeMillisString]] forKey:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
                        NSString *versionCode = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
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
    
    //检查强退时间
    NSNumber *serverTime = [senderDictionary objectForKey:@"timeUpdate"];
    if (serverTime && [serverTime isKindOfClass:[NSNumber class]]) {
        double timeval = [serverTime doubleValue] / 1000;
        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:timeval];
        NSDate *now = [NSDate currentGregorianDate];
        NSTimeInterval interval = [serverDate timeIntervalSinceDate:now];
        double minutes = ABS(interval)/60;
        if (minutes > WCForceQuiteTimeInterval) {
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *time = [timeFormat stringFromDate:serverDate];
            NSString *tipSyncTime = NSLocalizedString(@"您的手机系统时间不准确，影响了数据的准确性，请调整您的系统时间为：", nil);
            NSString *message = [NSString stringWithFormat:@"%@%@", tipSyncTime, time];
            NSString *title = NSLocalizedString(@"提示", nil);
            NSString *ok = NSLocalizedString(@"确定", nil);
            LogInfo(@"\n\n[ LogInfo - 手机设置的时间与服务器时间不符，显示强制退出的alert] \n\n");
            if (!_exitAlertView) {
                
                _exitAlertView = [BlockAlertView alertWithTitle:title message:message];
                
                __weak typeof(self) _weakSelf = self;
                
                [_exitAlertView setCancelButtonWithTitle:ok block:^{
                    LogInfo(@"\n\n[ LogInfo - 您的手机系统时间不准确,影响了数据的准确性,请调整您的系统时间,强制退出] \n\n");
                    _weakSelf.exitAlertView = nil;
                }];
                
                [_exitAlertView show];
            }
        }
    }
    if (request.uploadType || [request.m_notify hasPrefix:kOfflineTableNotifyIdPrefix])
    {
        if ([request.m_notify hasPrefix:kOfflineTableNotifyIdPrefix_AddedNewsStore])
        {
            request.uploadType = WCDatasUploadTypeAddNewStore;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:request result:tmpResponse];
        }
        else if ([request.m_notify hasPrefix:kOfflineTableNotifyIdPrefix_ModifyAddedNewStore])
        {
            request.uploadType = WCDatasUploadTypeModifyAddedNewStore;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:request result:tmpResponse];
        }
        else if ([request.m_notify hasPrefix:kOfflineTableNotifyIdPrefix_AddedNewsAcvt])
        {
            request.uploadType = WCDatasUploadTypeAddAcvt;
            WSHttpResponseServer *responseServer = [[WSHttpResponseServer alloc] init];
            [responseServer dealWithResponse:request result:tmpResponse];
        }
    }
    NSString* ret = [self converJsonString:tmpResponse];
    
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
    
    NSArray *senderDictionaryKeys = [senderDictionary allKeys];
    
    if ([senderDictionaryKeys containsObject:@"result"] && [result isEqualToString:@"1"]) {
        [self updateOffLineDataBase:request];
    }else if ([senderDictionaryKeys containsObject:@"result"]) {
        if (result && [result length] > 0) {
            NSDictionary *resultDic = [result JSONValue];
            NSString *flag = [resultDic objectForKey:@"flag"];
            if (flag && [flag isKindOfClass:[NSNumber class]]) {
                flag = [(NSNumber*)flag stringValue];
            }
            if (flag && [flag isEqualToString:@"1"]) {
                 [self updateOffLineDataBase:request];
            } else {
                LogError(@"flage != 1 result:%@",result);
            }
        }
       
    }else if (![senderDictionaryKeys containsObject:@"result"]){
        [self updateOffLineDataBase:request];
    } 

    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:mRet forKey:DATAS];
    if(request.m_notify != nil)
        [[NSNotificationCenter defaultCenter] postNotificationName:request.m_notify
                                                        object: mRet
                                                      userInfo:userInfo];

    
    //exception
    [self removeExceptionRecord:request];

}

/*
 * 未调用 可以删了
 */
-(void)rePostFailedUploadData:(ASIHTTPRequest *)request
{
    ASIHTTPRequest* l_request = [ASIHTTPRequest requestWithURL:request.url];
    l_request.m_notify = request.m_notify;
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"  value:@"application/json; encoding=utf-8"];
    [l_request addRequestHeader:@"Accept-Language" value:[UIDevice getPreferredLanguage]];
    [l_request appendPostData:request.postBody];
    [l_request setDelegate:self];
    [l_request setShouldContinueWhenAppEntersBackground:YES];
    l_request.m_identifiter = request.m_identifiter;
    [l_request startAsynchronous];
}


/*
 * 未调用 可以删了
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    LogInfo(@"requestFailed response    notify name is %@",[request m_notify]);
    
    //将未成功的重新上传
    if(request.m_identifiter != nil)
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
    
    //  实时应用退出记录上报，上报失败则插入离线数据库
    if ([request.m_notify isEqualToString:APPQUITREPORT]) {
        
        NSString *stringJson = [[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding];
        NSString *notifyID = [NSString stringWithFormat:@"%@_%@", APPQUITREPORT, [JSONBuilder gen_uuid]];
        [[WSOfflineDataManager sharedInstance] insertUploadDate:stringJson URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:notifyID];
    }
    
    NSError *error = [request error];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:ERROR];
    [[NSNotificationCenter defaultCenter] postNotificationName:request.m_notify
                                                        object: error
                                                      userInfo:userInfo];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self getUploadFailedCount]];
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

/*
 * 获取uuid 转移代码
 */

- (void)startImageJSONStringbyPost:(NSString *)URL
                            params:(NSDictionary *)params
                          postData:(NSData *)postData
                        notifyName:(NSString *)notifyName
                               MD5:(NSString*)md5
{
    LogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    NSURL *url = [[NSURL alloc]initWithString:[self completeUrlParameter:URL]];
    NSString* l_uuid = [self gen_uuid];
    NSString* l_contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",l_uuid];
    
    ASIFormDataRequest* l_request = [ASIFormDataRequest requestWithURL:url];
    
    l_request.m_notify = notifyName;
    l_request.m_identifiter = md5;
    
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"
                          value:l_contentType];
    [l_request addRequestHeader:@"connection" value:@"keep-alive"];
    [l_request addRequestHeader:@"Charset" value:@"UTF-8"];
    [l_request addRequestHeader:@"extension" value:@"JPEG"];

    [l_request addRequestHeader:@"imageIndex" value:[NSString stringNotNilWithValue:md5]];
    
    NSString *photoTmp = [params objectForKey:@"photo"];
    if (photoTmp) {
        photoTmp = [[NSString md5:photoTmp] lowercaseString];
        if (photoTmp) {
            [l_request addRequestHeader:@"photoKey" value:photoTmp];
        }
    }
    
    NSString *account = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if(account){
        [l_request addRequestHeader:@"account" value:account];
    }
    [l_request addRequestHeader:@"uploadDate" value:[WSCurrentTime getTimeMillisString]];
    [l_request addRequestHeader:@"method" value:@"F_PHOTO"];
    id syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [l_request addRequestHeader:@"syncDate" value:syncDate];
    }
//    [l_request addRequestHeader:@"photoType" value:imageType];
//    [l_request addRequestHeader:@"photo" value:[self gen_uuid]];
    
    //服务端日志
    [l_request setPostValue:@"isphotoexist" forKey:md5];
    [l_request setPostValue:@"1" forKey:account];
    [l_request setPostValue:syncDate forKey:@"syncDate"];
    [l_request setPostValue:[NSString stringNotNilWithValue:md5] forKey:@"imageIndex"];
    [l_request setPostValue:[NSString stringNotNilWithValue:photoTmp] forKey:@"photoKey"];
    

    for (NSString *key in [params allKeys]) {
        NSString *value = [params objectForKey:key];
        if (value) {
            [l_request addRequestHeader:key value:[NSString stringNotNilWithValue:value]];
        }
        
    }
    
    NSString *BOUNDARY = l_uuid;
    NSString *PREFIX=@"--";
    NSString *LINE_END=@"\r\n";
    NSString *CHARSET=@"utf-8";
    NSString *fileNameString=[[NSString alloc]initWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"image\""];
    
    NSString *beginString=[NSString stringWithString:PREFIX];
    beginString= [beginString stringByAppendingString:BOUNDARY];
    beginString= [beginString stringByAppendingString:LINE_END];
    beginString= [beginString stringByAppendingString:fileNameString];
    beginString=[beginString stringByAppendingString:LINE_END];
    beginString=[beginString stringByAppendingString:@"Content-Type: application/octet-stream; charset="];
    beginString=[beginString stringByAppendingString:CHARSET];
    beginString= [beginString stringByAppendingString:LINE_END];
    beginString= [beginString stringByAppendingString:LINE_END];
    
    NSString *endString=[NSString stringWithString:PREFIX];
    endString=[endString stringByAppendingString:BOUNDARY];
    endString=[endString stringByAppendingString:PREFIX];
    endString=[endString stringByAppendingString:LINE_END];
    
    NSString *videoFileString=[[NSString alloc] init];
    videoFileString=[videoFileString stringByAppendingString:beginString];
    
    NSMutableData* l_videodata = [[NSMutableData alloc]init];
    [l_videodata appendData:[videoFileString dataUsingEncoding:NSUTF8StringEncoding]];
    [l_videodata appendData:postData];
    [l_videodata appendData:[LINE_END dataUsingEncoding:NSUTF8StringEncoding]];
    [l_videodata appendData:[endString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [l_request appendPostData:l_videodata];
    [l_request setDelegate:self];

    [l_request startAsynchronous];
    
}


- (void)startImageJSONStringbyPost:(NSString *)URL
                            params:(NSDictionary *)params
                          filePath:(NSString *)filePath
                        notifyName:(NSString *)notifyName
                               MD5:(NSString*)md5
{
    LogTrace();
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:REQUESTCANCEL
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelRequest)
                                                 name:REQUESTCANCEL object:nil];
    
    NSDate *date3 = [NSDate date];
    NSURL *url = [[NSURL alloc]initWithString:[self completeUrlParameter:URL]];
    
    NSDate *date4 = [NSDate date];
    NSLog(@"completeUrlParameter耗时：%f", [date4 timeIntervalSinceDate:date3]);
    
    NSString* l_uuid = [self gen_uuid];
    NSString* l_contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",l_uuid];
    
    ASIFormDataRequest* l_request = [ASIFormDataRequest requestWithURL:url];
    
    l_request.m_notify = notifyName;
    l_request.m_identifiter = md5;
    
    [l_request setRequestMethod:HTTPTYPE_POST];
    [l_request addRequestHeader:@"Content-Type"
                          value:l_contentType];
    [l_request addRequestHeader:@"connection" value:@"keep-alive"];
    [l_request addRequestHeader:@"Charset" value:@"UTF-8"];
    [l_request addRequestHeader:@"extension" value:@"JPEG"];
    
    [l_request addRequestHeader:@"imageIndex" value:[NSString stringNotNilWithValue:md5]];
    [l_request addRequestHeader:@"photoKey" value:[params objectForKey:@"photo"]];
    
    
    NSString *account = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if(account){
        [l_request addRequestHeader:@"account" value:account];
    }
    [l_request addRequestHeader:@"uploadDate" value:[WSCurrentTime getTimeMillisString]];
    [l_request addRequestHeader:@"method" value:@"F_PHOTO"];
    id syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    if(syncDate){
        [l_request addRequestHeader:@"syncDate" value:syncDate];
    }
    //    [l_request addRequestHeader:@"photoType" value:imageType];
    //    [l_request addRequestHeader:@"photo" value:[self gen_uuid]];
    
    //服务端日志
    [l_request setPostValue:@"isphotoexist" forKey:md5];
    [l_request setPostValue:@"1" forKey:account];
    [l_request setPostValue:syncDate forKey:@"syncDate"];
    [l_request setPostValue:[NSString stringNotNilWithValue:md5] forKey:@"imageIndex"];
    [l_request setPostValue:[NSString stringNotNilWithValue:[params objectForKey:@"photo"]] forKey:@"photoKey"];
    
    for (NSString *key in [params allKeys]) {
        NSString *value = [params objectForKey:key];
        if (value) {
            [l_request addRequestHeader:key value:[NSString stringNotNilWithValue:value]];
        }
        
    }
    
    [l_request addFile:filePath withFileName:@"image" andContentType:@"application/octet-stream" forKey:@"image"];
    [l_request setDelegate:self];
    
    [l_request startAsynchronous];
    
}

@end
