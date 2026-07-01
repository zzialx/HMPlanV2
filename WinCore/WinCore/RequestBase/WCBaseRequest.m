
//
// Created by zijiefeng on 12-8-10.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "WCBaseRequest.h"
#import "WCLogger.h"
#import "WCBaseResponse.h"
#import "IAttachment.h"
#import "WCNetworkEngine.h"
#import "WCDataPacker2.h"
#import "WSPlistHelper.h"
#define kUploadAllLogDataFinishNotify @"UploadAllLogDataFinishNotify"

@implementation WCBaseRequestLocalInfo
@end

@interface WCBaseRequest ()

@property (nonatomic, strong) WinAFHTTPRequestOperation *httpRequestOperation;

@end

@implementation WCBaseRequest {
    id _json;
    NSData *_unzipData;
    
}
@synthesize protocolType = _protocolType;
@synthesize requestdelegate;
#pragma mark - WCLogManager
-(instancetype) initGetNaviFileWithURLString:(NSString*) urlString
{
    self = [super init];
    if (self){
        
        WinAFHTTPRequestSerializer *requestSerializer = [WinAFHTTPRequestSerializer serializer];
         NSError *initRequestError = nil;
        NSMutableURLRequest *request = [requestSerializer requestWithMethod:kHttpMethodGET URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:nil error:&initRequestError];
        if (initRequestError) {
            LogError(@"url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
            return nil;
        }
        _httpRequestOperation = [[WinAFHTTPRequestOperation alloc] initWithRequest:request];
    }
    return self;
}

-(instancetype) initPostLogFileWithURLString:(NSString*) urlString params:(NSDictionary*) params protocolType:(NSInteger) protocolType fileData:(NSData*)fileData
{
    self = [super init];
    if (self){
        _protocolType = protocolType;
        
        _responseDataClass = [WCBaseResponse class];
        
        NSError *initRequestError = nil;
        
        NSData *tempFileData = [WCBaseRequest generatePostBodyWithParams:params ProtocolType:protocolType fileData:fileData];
        
        NSURLRequest *request = [[WinAFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                           URLString:urlString
                                                                                          parameters:nil
                                                                           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                               [formData appendPartWithFileData:tempFileData name:@"upload" fileName:@"file" mimeType:@"application/octet-stream"];
                                                                               
                                                                           }
                                                                                               error:&initRequestError];
        if (initRequestError) {
             LogError(@"url:【%@】 httpMethod:[POST] 初始化出错; 错误信息: %@" ,urlString,initRequestError);
            return nil;
        }
        _httpRequestOperation = [[WinAFHTTPRequestOperation alloc] initWithRequest:request];
    }
    return self;
}


-(void)sendRequestForLogBusinessWithCompletionBlock:(WCRequestCompletionBlock)completionBlock;
{
    if (self.httpRequestOperation) {

        NSInteger protocol = self.protocolType;
        Class responseClass = self.responseDataClass;
        [self.httpRequestOperation setCompletionBlockWithSuccess:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"JSON: %@", responseObject);
             WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:protocol requestIdentifer:kUploadAllLogDataFinishNotify];
            completionBlock(operation,response);
        } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:protocol];
            completionBlock(operation,response);
        }];
        [[NSOperationQueue mainQueue] addOperation:self.httpRequestOperation];
    }
}
-(void) registerResponseDataClassForLogBusiness:(Class) aClass {
    
    self.responseDataClass = aClass;
}

#pragma mark WCLogManager help methods

+ (NSDictionary *)getAllParamsWithParams:(NSDictionary *)params
{
    NSMutableDictionary *allParams = nil;
    if (nil != params && [params count] > 0) {
        allParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    }
    else
    {
        allParams = [[NSMutableDictionary alloc] init];
    }

    //[allParams setObject:[WCGlobalSingleton sharedInstance].gToken forKey:@"token"];
    [allParams setValue:[WCGlobalSingleton sharedInstance].gPlatform forKey:@"platform"];
    [allParams setValue:[WCGlobalSingleton sharedInstance].gIMEI forKey:@"imei"];
    //[allParams setValue:[WCGlobalSingleton sharedInstance].gVer forKey:@"ver"];
    [allParams setValue:[WCGlobalSingleton sharedInstance].gSrc forKey:@"src"];
    [allParams setValue:[WCGlobalSingleton sharedInstance].gLang forKey:@"lang"];

    return allParams;
}

+ (NSString *)requestUrlForGETWithUrlString:(NSString *)urlString params:(NSDictionary*)params protocolType:(NSInteger)type
{
    NSDictionary *jsonDic = [WCBaseRequest getAllParamsWithParams:params];

    NSString *jsonString = [jsonDic JSONString];
    WCDataPacker *packer = [WCDataPacker sharedInstance];
    NSString *infoString = [packer packForURLParam:jsonString];
    NSString *finalUrlString = [NSString stringWithFormat:@"%@?type=%ld&info=%@", urlString, (long)type, infoString];

//    DLog(@"type=%ld,url=%@, params:%@", (long)type, [WCGlobalSingleton sharedInstance].gNaviFileItem.query, jsonDic);

    return finalUrlString;
}

+ (NSData *)generatePostBodyWithParams:(NSDictionary *)params ProtocolType:(NSInteger)type fileData:(NSData*)fileData
{
    NSDictionary *jsonDic = [WCBaseRequest getAllParamsWithParams:params];

    WCDataPacker *packer = [WCDataPacker sharedInstance];
    
    if (fileData) {
        return [packer generatePost:[packer packForPostBody:[jsonDic JSONData]] forType:type withFile:[packer packForPostBodyNoZip:fileData]];
    }
    else
    {
        return [packer generatePost:[packer packForPostBody:[jsonDic JSONData]] forType:type];
    }
    
}
#pragma mark - asyncPost

- (void)asyncPostJson:(NSDictionary *)parameters urlString:(NSString *)urlString isUpload:(BOOL)isUpload success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock
{
    [self asyncPostJson:parameters urlString:urlString isUpload:isUpload success:successBlock failure:failureBlock progress:nil];
}

- (void)asyncPostJson:(NSDictionary *)parameters urlString:(NSString *)urlString isUpload:(BOOL)isUpload success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock progress:(WCRequestProgressBlock)progressBlock
{
    [self asyncPostJson:parameters urlString:urlString isUpload:isUpload timeout:0 success:successBlock failure:failureBlock progress:progressBlock];
}
    
- (void)asyncPostJson:(NSDictionary *)parameters urlString:(NSString *)urlString isUpload:(BOOL)isUpload timeout:(NSInteger)timeout success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock progress:(WCRequestProgressBlock)progressBlock {

    WinAFHTTPRequestOperationManager *manager;
    
    if (isUpload) {
        manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    }else {
        manager = [WCNetworkEngine sharedInstance].normalRequestManager;
    }
    
    if (![manager.requestSerializer isKindOfClass:[WinAFJSONRequestSerializer class]]) {
            [manager setRequestSerializer:[WinAFJSONRequestSerializer serializer]];
    }
    
    NSTimeInterval lastTimeout = [manager.requestSerializer timeoutInterval];
    if (timeout > 0) {
        [manager.requestSerializer setTimeoutInterval:timeout];
    }
    
//    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:parameters error:nil];
    
    NSMutableURLRequest *request = [self getAsyncPostRequestWithPostJson:parameters urlString:urlString requestOperationManager:manager];
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSDictionary *mjetDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MjetLoginInfo"];
    if ([mjetDic count] > 0) {
        NSArray *headerKeys = [mjetDic allKeys];
        for (NSString *key in headerKeys) {
            NSString *value = [mjetDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }

    
    Class responseClass = self.responseDataClass;
    
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        // 单独设置某个请求的超时时间后要重置超时时间
        if (timeout > 0) {
            [manager.requestSerializer setTimeoutInterval:lastTimeout];
        }
        
        
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1 requestIdentifer:self.localInfo.m_notify];
        successBlock(response,self.localInfo);
        
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        
        LogError(@"Error: %@", error);
        
        // 单独设置某个请求的超时时间后要重置超时时间
        if (timeout > 0) {
            [manager.requestSerializer setTimeoutInterval:lastTimeout];
        }
        
        if (error.code == -1003) {
            NSString *title = NSLocalizedString(@"network_failure", nil);
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            [MBProgressHUD showHUDAddedTo:keyWindow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        }
        
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    
    }];
    
//    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"后台继续执行任务。");
//    }];
    
    if (self.localInfo && self.localInfo.m_identifiter == nil && [manager.operationQueue operationCount] > 0) {
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }
    
    if (progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            if (totalBytesExpectedToRead > 0) {
                CGFloat progress = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
                progressBlock(progress);
            }
        }];
    }
    
    [manager.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)getAsyncPostRequestWithPostJson:(NSDictionary *)parameters urlString:(NSString *)urlString requestOperationManager:(WinAFHTTPRequestOperationManager *)manager
{
    // urlSegment:&sfa=1 使用上传下载字符串加密，则需要再Url拼接字串儿"&sfa=1"
    
    WCDataPacker2 *packer = [WCDataPacker2 sharedInstance];
    
    NSString *jsonString = [parameters JSONString];
    
    
    NSMutableURLRequest *request = nil;
    
    
    BOOL passWordEncrypt = NO;
    
    NSString *saasurl =  [WSPlistHelper valueForKey:kSAAS_URL withPlistName:kConfilgFileName];
    // SFA-13798 SAAS 后台接口不进行加密
    if (!saasurl || [urlString rangeOfString:saasurl].location == NSNotFound) {
        NSString *password_encrypt = [WSPlistHelper getPasswordEncrypt];
        if (password_encrypt.length > 0 && [password_encrypt boolValue]){
            passWordEncrypt = YES;
        }
    }
    
    if (passWordEncrypt) {
        NSString *finalUrlString = [NSString stringWithFormat:@"%@&sfa=1", urlString];
        
        NSData *enData = [packer packForURLParam01:jsonString];
        
        request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:finalUrlString relativeToURL:nil] absoluteString] parameters:nil error:nil];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:enData];
        
        NSLog(@"request HTTPBody = %@", request.HTTPBody);
    }else{
        /*Jira- SFA-14509 崩溃原因,地址里面有空格,url返回nil requestWithMethod: 实现里的 NSParameterAssert(URLString)导致崩溃 create by 孙洪福 2017-11-24*/
        request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:[urlString stringByReplacingOccurrencesOfString:@" "withString:@""] relativeToURL:nil] absoluteString] parameters:nil error:nil];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        NSString *result  =[[ NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        NSLog(@"request HTTPBody = %@", result);
    }
    
    return request;
}


- (void) asyncPostBodyDataWithDictionary:(NSDictionary *)parameters urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock
{
//    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].normalRequestManager;
    WinAFHTTPRequestOperationManager *manager = [WinAFHTTPRequestOperationManager manager];
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
    }
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:parameters error:nil];
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSDictionary *mjetDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MjetLoginInfo"];
    if ([mjetDic count] > 0) {
        NSArray *headerKeys = [mjetDic allKeys];
        for (NSString *key in headerKeys) {
            NSString *value = [mjetDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
    Class responseClass = self.responseDataClass;
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1];
        successBlock(response,self.localInfo);
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    
    if (self.localInfo && self.localInfo.m_identifiter == nil && [manager.operationQueue operationCount] > 0) {
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }
    
    [manager.operationQueue addOperation:operation];
}

- (void) asyncPostBodyData:(NSDictionary *)parameters imageFilePath:(NSString *)filePath urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock
{
    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
    }
    NSError *initRequestError = nil;
    __block BOOL appendFileOK = YES;
    Class responseClass = self.responseDataClass;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                   URLString:urlString
                                                                                  parameters:parameters
                                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                       
                                                                       NSError *fileError = nil;
                                                                       [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath isDirectory:NO]
                                                                                                  name:@"image"
                                                                                              fileName:@"image"
                                                                                              mimeType:@"application/octet-stream" error:&fileError];
                                                                       if (fileError) {
                                                                           appendFileOK = NO;
                                                                           WCBaseResponse *response = [[responseClass alloc] initWithError:fileError protocolType:-1];
                                                                           failureBlock(response,self.localInfo);
                                                                           LogError(@"asyncPostBody url: 【%@】 初始化出错; 准备图片上传时，构造Request错误信息: %@" ,urlString ,fileError);
                                                                       }
                                                                   }
                                                                                       error:&initRequestError];
    
    
    if (!appendFileOK) {
        return;
    }
    if (initRequestError) {
         LogError(@"asyncPostBody url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
        WCBaseResponse *response = [[responseClass alloc] initWithError:initRequestError protocolType:-1];
        failureBlock(response,self.localInfo);
        return;
    }
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
   
    NSDictionary *mjetDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MjetLoginInfo"];
    if ([mjetDic count] > 0) {
        NSArray *headerKeys = [mjetDic allKeys];
        for (NSString *key in headerKeys) {
            NSString *value = [mjetDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
   
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1];
        successBlock(response,self.localInfo);
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    [manager.operationQueue addOperation:operation];
}
- (void) asyncPostViedoData:(NSData *)viedoData urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock
{
  
    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
    }
    NSError *initRequestError = nil;
//    NSString *boundary = self.localInfo.m_boundary;
    Class responseClass = self.responseDataClass;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                   URLString:urlString
                                                                                  parameters:nil
                                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                       
                                                                       [formData appendPartWithFileData:viedoData
                                                                                                   name:@"video"
                                                                                               fileName:@"video"
                                                                                               mimeType:@"application/octet-stream"];
//                                                                       NSString *BOUNDARY = boundary;
//                                                                       NSString *PREFIX=@"--";
//                                                                       NSString *LINE_END=@"\r\n";
//                                                                       NSString *CHARSET=@"utf-8";
//                                                                       NSString *fileNameString=[[NSString alloc]initWithFormat:@"Content-Disposition: form-data; name=\"video\"; filename=\"video\""];
//                                                                       
//                                                                       NSString *beginString=[NSString stringWithString:PREFIX];
//                                                                       beginString= [beginString stringByAppendingString:BOUNDARY];
//                                                                       beginString= [beginString stringByAppendingString:LINE_END];
//                                                                       beginString= [beginString stringByAppendingString:fileNameString];
//                                                                       beginString=[beginString stringByAppendingString:LINE_END];
//                                                                       beginString=[beginString stringByAppendingString:@"Content-Type: application/octet-stream; charset="];
//                                                                       beginString=[beginString stringByAppendingString:CHARSET];
//                                                                       beginString= [beginString stringByAppendingString:LINE_END];
//                                                                       beginString= [beginString stringByAppendingString:LINE_END];
//                                                                       
//                                                                       NSString *endString=[NSString stringWithString:PREFIX];
//                                                                       endString=[endString stringByAppendingString:BOUNDARY];
//                                                                       endString=[endString stringByAppendingString:PREFIX];
//                                                                       endString=[endString stringByAppendingString:LINE_END];
//                                                                       
//                                                                       NSMutableData* l_videodata = [[NSMutableData alloc]init];
//                                                                       [l_videodata appendData:[beginString dataUsingEncoding:NSUTF8StringEncoding]];
//                                                                       [l_videodata appendData:viedoData];
//                                                                       [l_videodata appendData:[LINE_END dataUsingEncoding:NSUTF8StringEncoding]];
//                                                                       [l_videodata appendData:[endString dataUsingEncoding:NSUTF8StringEncoding]];
//                                                                       [formData appendPartWithHeaders:nil body:l_videodata];
                                                                       
                                                                   }
                                                                                       error:&initRequestError];

    if (initRequestError) {
        LogError(@"asyncPostBody url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
        WCBaseResponse *response = [[responseClass alloc] initWithError:initRequestError protocolType:-1];
        failureBlock(response,self.localInfo);
    }
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1];
        successBlock(response,self.localInfo);
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    
    if (self.localInfo && self.localInfo.m_identifiter == nil && [manager.operationQueue operationCount] > 0) {
        [operation setQueuePriority:NSOperationQueuePriorityHigh];
    }
    
    [manager.operationQueue addOperation:operation];
}
- (void) asyncPostViedoFilePath:(NSString *)filePath urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock
{
    //    NSParameterAssert(self.localInfo.m_boundary);
    
    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
    }
    NSError *initRequestError = nil;
    Class responseClass = self.responseDataClass;
    //    NSString *boundary = self.localInfo.m_boundary;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                   URLString:urlString
                                                                                  parameters:nil
                                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                       
                                                                       NSError *fileError = nil;
                                                                       [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath isDirectory:NO]
                                                                                                  name:@"video"
                                                                                              fileName:@"video"
                                                                                              mimeType:@"application/octet-stream" error:&fileError];
                                                                       if (fileError) {
                                                                           LogError(@"asyncPostBody url: 【%@】 初始化出错; 视频上传前构造Request错误信息: %@" ,urlString ,fileError);
                                                                           WCBaseResponse *response = [[responseClass alloc] initWithError:fileError protocolType:-1];
                                                                           failureBlock(response,self.localInfo);
                                                                       }
                                                                   }
                                                                                       error:&initRequestError];
    
    if (initRequestError) {
        LogError(@"asyncPostBody url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
        WCBaseResponse *response = [[responseClass alloc] initWithError:initRequestError protocolType:-1];
        failureBlock(response,self.localInfo);
        return;
    }
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1];
        successBlock(response,self.localInfo);
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    [manager.operationQueue addOperation:operation];
}

-(void)doDownloadFile:(NSObject<IAttachment> *)attachobj shouldResume:(BOOL)shouldResume {
    
    //谢谢老夏！ 
    
    NSURL  *downloadurl =[NSURL  URLWithString:[attachobj getRequestpath]];
    
    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].normalRequestManager;
    
    
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
    
    }
    
    NSURLRequest *request =[[NSURLRequest alloc] initWithURL:downloadurl];
    
      _downLoadOperation = [[WinAFDownloadRequestOperation alloc] initWithRequest:request fileIdentifier:[[attachobj getRequestpath] md5] targetPath:[attachobj getMediaFileSavePath] shouldResume:shouldResume];
    _downLoadOperation.shouldOverwrite = YES;
    
    
     __weak __typeof(self)weakSelf = self;
    [_downLoadOperation setCompletionBlockWithSuccess:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.requestdelegate respondsToSelector:@selector(sendContentDataWithSuccess:)]) {
            
            [strongSelf.requestdelegate sendContentDataWithSuccess:operation.responseData];
            
        }
    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.requestdelegate respondsToSelector:@selector(sendErrorContentWithFailed:)]) {
            
            [strongSelf.requestdelegate sendErrorContentWithFailed:error];
            
        }
    }];
    
    [_downLoadOperation setProgressiveDownloadProgressBlock:^(WinAFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.requestdelegate respondsToSelector:@selector(sendProgressWithBytesRead:andBytesExpected:)]) {
            
            [strongSelf.requestdelegate sendProgressWithBytesRead:totalBytesReadForFile andBytesExpected:totalBytesExpectedToReadForFile];
            
        }
    }];
    
    [manager.operationQueue addOperation:_downLoadOperation];
        
    
}
- (void)pasueOrResumeRequest {
    if (_downLoadOperation.isPaused) {
        [_downLoadOperation resume];
    }else {
        [_downLoadOperation pause];
    }
}



#pragma mark - 多文件统一上传 parameters请求参数 files文件数组 urlString请求地址 successBlock成功回调 failureBlock失败回调
- (void)asyncPostBodyData:(NSDictionary *)parameters files:(NSArray *)files urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock {

    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    }
    
    NSError *initRequestError = nil;
    __block BOOL appendFileOK = YES;
    Class responseClass = self.responseDataClass;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                   URLString:urlString
                                                                                  parameters:parameters
                                                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i < files.count; i++) {
            id object = files[i];
            if ([object isKindOfClass:[UIImage class]]) {
                NSData *imageData = UIImageJPEGRepresentation((UIImage *)object, 0.5f);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"photos[%d]", i] fileName:[NSString stringWithFormat:@"image%d.jpeg", i] mimeType:@"image/jpeg"];
            }
        }
    }
                                                                                       error:nil];
    
    if (!appendFileOK) {
        return;
    }
    
    if (initRequestError) {
        LogError(@"asyncPostBody url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
        WCBaseResponse *response = [[responseClass alloc] initWithError:initRequestError protocolType:-1];
        failureBlock(response,self.localInfo);
        return;
    }
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSDictionary *mjetDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MjetLoginInfo"];
    if ([mjetDic count] > 0) {
        NSArray *headerKeys = [mjetDic allKeys];
        for (NSString *key in headerKeys) {
            NSString *value = [mjetDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                            success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:responseObject protocolType:-1];
        successBlock(response,self.localInfo);
    }
                                                                            failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    
    [manager.operationQueue addOperation:operation];
}

#pragma mark - 单文件统一上传 parameters请求参数 file文件 fileCompress文件压缩比(针对图片) urlString请求地址 successBlock 成功回调 failureBlock 失败回调
- (void)asyncSinglePostBodyData:(NSDictionary *)parameters file:(id)file fileCompress:(CGFloat)fileCompress urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock {
    
    WinAFHTTPRequestOperationManager *manager = [WCNetworkEngine sharedInstance].uploadRequestManager;
    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    }
    
    NSError *initRequestError = nil;
    Class responseClass = self.responseDataClass;
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:kHttpMethodPOST
                                                                                   URLString:urlString
                                                                                  parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ([file isKindOfClass:[UIImage class]]) {
            NSData *imageData = UIImageJPEGRepresentation((UIImage *)file, ((fileCompress > 0.5 && fileCompress < 1.0) ? fileCompress : 0.5));
            [formData appendPartWithFileData:imageData name:@"image" fileName:@"image" mimeType:@"image/jpeg"];
        }
    }
                                                                                       error:&initRequestError];
    
    if (initRequestError) {
        LogError(@"asyncPostBody url: 【%@】 初始化出错; 错误信息: %@" ,urlString ,initRequestError);
        WCBaseResponse *response = [[responseClass alloc] initWithError:initRequestError protocolType:-1];
        failureBlock(response, self.localInfo);
        return;
    }
    
    if (self.httpHeaders && [self.httpHeaders count] > 0) {
        
        NSArray *headerKeys = [self.httpHeaders allKeys];
        for (NSString *key in headerKeys) {
            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
        }
    }
        
    NSDictionary *mjetDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"MjetLoginInfo"];
    if ([mjetDic count] > 0) {
        
        NSArray *headerKeys = [mjetDic allKeys];
        for (NSString *key in headerKeys) {
            NSString *value = [mjetDic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
        
    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                            success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:responseObject protocolType:-1];
        successBlock(response,self.localInfo);
    }
                                                                            failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
        failureBlock(response,self.localInfo);
    }];
    [manager.operationQueue addOperation:operation];
}



#pragma mark - syncPost test
//- (void) syncPostJson:(NSDictionary *)parameters urlString:(NSString *)urlString success:(WCRequestSuccessBlock) successBlock failure:(WCRequestFailureBlock) failureBlock
//{
//    WinAFHTTPRequestOperationManager *manager = [WinAFHTTPRequestOperationManager manager];
//    if (![manager.requestSerializer isKindOfClass:[WinAFJSONRequestSerializer class]]) {
//        [manager setRequestSerializer:[WinAFJSONRequestSerializer serializer]];
//    }
//    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:urlString relativeToURL:nil] absoluteString] parameters:parameters error:nil];
//    
//    if (self.httpHeaders && [self.httpHeaders count] > 0) {
//        NSArray *headerKeys = [self.httpHeaders allKeys];
//        for (NSString *key in headerKeys) {
//            [request setValue:[self.httpHeaders objectForKey:key] forHTTPHeaderField:key];
//        }
//    }
//    Class responseClass = self.responseDataClass;
//    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//        WCBaseResponse *response = [[responseClass alloc] initWithResponseData:operation.responseData protocolType:-1];
//        successBlock(response,self.localInfo);
//    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"Error: %@", error);
//        WCBaseResponse *response = [[responseClass alloc] initWithError:error protocolType:-1];
//        failureBlock(response,self.localInfo);
//    }];
//    
//    if (self.localInfo && self.localInfo.m_identifiter == nil && [manager.operationQueue operationCount] > 0) {
//        [operation setQueuePriority:NSOperationQueuePriorityHigh];
//    }
////    NSArray *ops = [NSArray arrayWithObject:operation];
////    [manager.operationQueue addOperations:ops waitUntilFinished:YES];
//}

+ (NSString *)getUserAgent {
    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"configFile" ofType:@"plist"];
    NSDictionary *configFileDic = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];
    NSString *appSystemVersion = [NSString stringNotNilWithValue:[configFileDic objectForKey:@"appSystemVersion"]];
    
    NSString *userAgent = @"";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)",
                 [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ? : [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
                 appSystemVersion,
                 [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)",
                 [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ? : [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey],
                 appSystemVersion,
                 [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        return userAgent;
    }
    return userAgent;
}

@end
