//
// Created by yang on 13-6-18.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <objc/runtime.h>
#import "WCBaseResponse.h"
#import "WCDataPacker2.h"
#import "WSPlistHelper.h"

#define kUploadAllLogDataFinishNotify @"UploadAllLogDataFinishNotify"

@implementation WCBaseResponse
@synthesize jsonResponse = _jsonResponse;
@synthesize error = _error;
@synthesize protocolType = _protocolType;

-(instancetype)initWithResponseData:(NSData *)data protocolType:(NSInteger)protocolType {
    return [self initWithResponseData:data protocolType:protocolType requestIdentifer:nil];
}
-(instancetype)initWithResponseData:(NSData *)data protocolType:(NSInteger)protocolType requestIdentifer:(NSString *)requestIdentifer{
    self = [super init];
    if (self){
        _protocolType = protocolType;
        _resopnseData = data;
        _requestIdentifer = requestIdentifer;
        NSString *password_encrypt = [WSPlistHelper getPasswordEncrypt];
        
        if (password_encrypt.length > 0 && [password_encrypt boolValue]){
            // 不需要解密的逻辑，包括诊断日志上传，SAAS登录和版本号校验
            if (requestIdentifer.length > 0 &&
                ([requestIdentifer isEqualToString:kUploadAllLogDataFinishNotify]  || [requestIdentifer isEqualToString:LOGIN_SAAS_NOTIFY] || [requestIdentifer isEqualToString:CHECK_UPGRADE_NOTIFY])) {
                [self parseResponseData];
            }else
                [self parseResponseDataWithNewEncryptRules];
        }else{
            [self parseResponseData];
        }

        [self parseJsonData];
    }
    return self;
}
-(instancetype)initWithError:(NSError *)error  protocolType:(NSInteger)protocolType{
     self = [super init];
    if (self){
        _protocolType = protocolType;
        _error = [WCError errorWithNSError:error];
    }
    return self;
}

- (void)parseResponseDataWithNewEncryptRules {

    WCDataPacker2 *packer02 = [WCDataPacker2 sharedInstance];

    
    NSString *deStr = [packer02 unpackForResponseData:self.resopnseData];

    if (deStr.length > 0) {
        _jsonResponse = [deStr objectFromJSONString];
        NSLog(@"---------解密返回数据为：%@", deStr);
    }
    else{
        NSLog(@"+++++++++解密返回数据为空：%@", deStr);
    }
}

// 2017之前的解密解压方法
- (void)parseResponseData {
    
    WCDataPacker *packer = [WCDataPacker sharedInstance];
    UInt16 type = 0;
    UInt32 errorCode = 0;
    UInt32 contentLength = 0;
    NSData *contentData = nil;
    
    [packer getResponseInfo:[self.resopnseData bytes] type:&type errorCode:&errorCode contentLength:&contentLength content:&contentData];
    
    if (errorCode == 0) {
        NSData *responseData = [packer unpackForPostBody:contentData];
        NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        _jsonResponse = [str objectFromJSONString];
    }
    else{
        _error = [WCError errorWithCode:errorCode errorMessage:nil];
    }
}

- (void)parseJsonData {
    
    
}

@end
