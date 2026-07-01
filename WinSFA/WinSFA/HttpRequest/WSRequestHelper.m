//
//  postRequest.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "WSRequestHelper.h"

#import "WSRequestBase.h"
#import "DecompressUtil.h"
#import "WinSFA.h"
#import "WSAppData.h"
#import "WSJSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSCurrentTime.h"
#import "WSSugReplyBeanArray.h"
#import "UIDevice+IdentifierAddition.h"
#import "GTMBase64.h"
#import "WSOfflineDataManager.h"
#import "WSTestTools.h"

#import "WSEncrpytion.h"
#import "FileManager.h"

#import "WSPlistHelper.h"
#import "WSOfflineDataDBService.h"

#import "WSEnvrionment.h"
#import "WSAliyunUtil.h"
#import "WCDataPacker2.h"

#import "TZImageManager.h"
#import "WSBaseAcvtDBService.h"
#import "WSAcvtModel.h"

#import "WSPaiPaiManager.h"
#import "WSNormalHttpResponse.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define VERSION     @"version"
#define SYS_VERSION @"systemVersion"
#define PLATFORM    @"platform"
#define LANGUAGE    @"language"
#define UPDATA_MSG  @"updataMassage"
#define OSVERSION   @"osVersion"
#define OS          @"os"
#define ORG_CODE    @"tenantCode"
#define REQ_FROM    @"reqFrom"
#define unUploadDataNum  @"unUploadDataNum"

#define KEY     @"keyWord1"
#define EMPID   @"empId"
#define CELLID  @"cellId"
#define OBJID   @"objId"

//#define PLATFORM_NAME [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]]

@interface WSRequestHelper ()




@end

@implementation WSRequestHelper

static WSRequestHelper* instance = nil;

+(WSRequestHelper*)shareInstance
{
    if(instance == nil)
    {
        instance = [[super allocWithZone:NULL]init];
    }
    
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self shareInstance];
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

//add by wangdongyan 04-12 for 6200服务器路线管理
-(void)postRequestOnRoadsManager:(NSDictionary *)aDic
                                notifyName:(NSString *)aNotifyName;
{
    LogTrace();
    NSString *postData = [WSJSONBuilder buildRoadsManagerRequest:aDic];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];

}

- (void)postRequestOnLogin:(NSString *)username
                    passWd:(NSString *)passWd
                notifyName:(NSString *)notifyName
                       URL:(NSString *)url
{
    [self postRequestOnLogin:username passWd:passWd notifyName:notifyName URL:url progress:nil];
}

- (void)postRequestOnLogin:(NSString *)username passWd:(NSString *)passWd notifyName:(NSString *)notifyName URL:(NSString *)url progress:(WCRequestProgressBlock)progressBlock {
    
    LogTrace();
    
    NSString *password_encrypt = [WSPlistHelper getPasswordEncrypt];
    if (!password_encrypt) {
        password_encrypt = @"0";
    }
            
    NSMutableDictionary *login = [self getLoginParam:username password:passWd password_encrypt:password_encrypt];
    [[WSTestTools getInstance] keepTimeWithKey:LOG_GET_LOGIN_DATA forcePrint:YES];
    [self uploadDatasDictionary:login urlString:url notifyName:notifyName md5:nil isUpload:NO progress:progressBlock];
}

- (void)postRequestOnLoginWithSSOUserCode:(NSString *)userCode notifyName:(NSString *)notifyName URL:(NSString *)url progress:(WCRequestProgressBlock)progressBlock {
    
    LogTrace();
    
    NSString *password_encrypt = [WSPlistHelper getPasswordEncrypt];
    if (!password_encrypt) {
        password_encrypt = @"0";
    }
    NSMutableDictionary *login = [self getLoginParamWithUserCode:userCode userName:@""];
    LogInfo(@"WSRequestHelper postRequestOnLoginWithSSOUserCode 1 login = %@", login);
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_GET_LOGIN_DATA forcePrint:YES];
    [self uploadDatasDictionary:login urlString:url notifyName:notifyName md5:nil isUpload:NO progress:progressBlock];
}

- (void)postRequestOnLoginWithSSOUserName:(NSString *)userName notifyName:(NSString *)notifyName URL:(NSString *)url progress:(WCRequestProgressBlock)progressBlock {
    
    LogTrace();
    
    NSString *password_encrypt = [WSPlistHelper getPasswordEncrypt];
    if (!password_encrypt) {
        password_encrypt = @"0";
    }
    NSMutableDictionary *login = [self getLoginParamWithUserCode:@"" userName:userName];
    LogInfo(@"WSRequestHelper postRequestOnLoginWithSSOUserName 1 login = %@", login);
    
    [[WSTestTools getInstance] keepTimeWithKey:LOG_GET_LOGIN_DATA forcePrint:YES];
    [self uploadDatasDictionary:login urlString:url notifyName:notifyName md5:nil isUpload:NO progress:progressBlock];
}

- (NSMutableDictionary *)getLoginParamWithUserCode:(NSString *)userCode userName:(NSString *)userName {
    
    NSMutableDictionary *login = [[NSMutableDictionary alloc] initWithDictionary:[self getNormalParam]];
    
    if (userCode && userCode.length > 0) {
        [login setObject:[NSString stringNotNilWithValue:userCode] forKey:AUTHORIZATIONCODE];
    }
    else if (userName && userName.length > 0) {
        [login setObject:[NSString stringNotNilWithValue:userName] forKey:SSOUSERNAME];
    }
    
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    [login setObject:@"" forKey:@"simid"];
    [login setObject:[NSString stringNotNilWithValue:svnVersion] forKey:@"AKU"];
    
    NSInteger unUploadDataNumber = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    NSString *unUploadDataStr = [NSString stringWithFormat:@"%ld",(long)unUploadDataNumber];
    [login setObject:unUploadDataStr forKey:unUploadDataNum];
    
    NSObject *exitAppStatus = [FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if (exitAppStatus) {
        [login setObject:exitAppStatus forKey:@"exitAppStatus"];
    }
    
    NSObject *timestamp = [FileManager getUserDefaults:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    if (timestamp) {
        [login setObject:timestamp forKey:@"exitAppTime"];
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (empId) {
        [login setObject:empId forKey:EMPID];
    }
    
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    [login setObject:[NSString stringNotNilWithValue:projectName] forKey:@"product"];
    
    if ([WSEnvrionment getParamInLoginData]) {
        [login setObject:@"1" forKey:LOGIN_CONFIG_PARAMS];
    }
    return login;
}

- (NSMutableDictionary *)getLoginParam:(NSString *)username password:(NSString *)passWd password_encrypt:(NSString *)password_encrypt {
    
    NSMutableDictionary *login = [[NSMutableDictionary alloc] initWithDictionary:[self getNormalParam]];

    NSString *cacheDataVersion = (NSString *)[FileManager getUserDefaults:CACHE_DATA_VERSION_KEY_BYUSER(username)];
    if (cacheDataVersion && [cacheDataVersion length] > 0) {
        NSString *loginFileUrl = [[FileManager Documents] stringByAppendingPathComponent:LOGIN_DATA_FILENAME_BYUSER(username)];
        if ([[NSFileManager defaultManager] fileExistsAtPath:loginFileUrl]) {
            id objectDic = [cacheDataVersion objectFromJSONString];
            if (objectDic) {
                [login setObject:objectDic forKey:CACHE_DATA_VERSION_NODE];
            }
        }
    }
    
    if ([password_encrypt isEqualToString:@"1"]) {
        passWd  = [WSEncrpytion encryptUseDES:passWd key:LOGIN_PASSWORD_DES_PRIVATE_KEY];
    }
    
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    [login setObject:[NSString stringNotNilWithValue:username] forKey:USERNAME];
    [login setObject:[NSString stringNotNilWithValue:passWd] forKey:PASSWORD];
    [login setObject:@"" forKey:@"simid"];
    [login setObject:[NSString stringNotNilWithValue:svnVersion] forKey:@"AKU"];
    [login setObject:password_encrypt forKey:@"password_encrypt"];

    NSInteger unUploadDataNumber = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    NSString *unUploadDataStr = [NSString stringWithFormat:@"%ld",(long)unUploadDataNumber];
    [login setObject:unUploadDataStr forKey:unUploadDataNum];
    
    NSObject *exitAppStatus = [FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if (exitAppStatus) {
        [login setObject:exitAppStatus forKey:@"exitAppStatus"];
    }
    
    NSObject *timestamp = [FileManager getUserDefaults:EXIT_APP_TIMESTAMP_USERDEFAULT_KEY];
    if (timestamp) {
        [login setObject:timestamp forKey:@"exitAppTime"];
    }
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    if (empId) {
        [login setObject:empId forKey:EMPID];
    }
    
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    [login setObject:[NSString stringNotNilWithValue:projectName] forKey:@"product"];
    
    if ([WSEnvrionment getParamInLoginData]) {
        [login setObject:@"1" forKey:LOGIN_CONFIG_PARAMS];
    }
    return login;
}

- (NSDictionary *)getNormalParam {

    NSMutableDictionary *params =[NSMutableDictionary dictionary];
    
    NSString *sendVersion = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_SAAS_SEND_VERSION];
    if (!sendVersion || [sendVersion length] == 0 || [sendVersion isEqualToString:LOGIN_SAAS_SEND_VERSION_YES]) {
        // 应用版本号 打包时动态配置
        NSString *versionCode = [WSEnvrionment getAppSystemVersion];
        [params setObject:[NSString stringNotNilWithValue:versionCode] forKey:VERSION];
        
        if ([[WSEnvrionment getSaasUrl] length] > 0) {
            [params setObject:@"saas" forKey:REQ_FROM];
        }
    }
    NSString *platform = [UIDevice platformNameForSFA];
    [params setObject:[NSString stringNotNilWithValue:platform] forKey:PLATFORM];
    
    NSString *deviceIdentifer = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    [params setObject:[NSString stringNotNilWithValue:deviceIdentifer] forKey:@"imei"];
    [params setObject:[NSString stringNotNilWithValue:[[UIDevice currentDevice] systemVersion]] forKey:SYS_VERSION];
    [params setObject:@"iOS" forKey:OS];
    [params setObject:[[UIDevice currentDevice] systemVersion] forKey:OSVERSION];
    return [params copy];
}

- (void)postRequestOnLoginSaas:(NSString *)username
                       orgName:(NSString *)orgName
                    notifyName:(NSString *)notifyName
                           URL:(NSString *)url {
 
    // SFA-13798 SAAS 密码不加密
    NSMutableDictionary *login = [self getLoginParam:username password:@"" password_encrypt:@"0"];
    if ([orgName length] > 0) {
        [login setObject:orgName forKey:ORG_CODE];
    }
    [self uploadDatasDictionary:login urlString:url notifyName:notifyName md5:nil isUpload:NO];
}

- (void)appChangePassWord:(NSDictionary*)newPassWord
               notifyName:(NSString*)notifyName
{
    LogTrace();
    [self uploadDatasDictionary:newPassWord urlString:URL_CHANGEPW notifyName:notifyName md5:nil isUpload:NO];
}

- (void)appGetStoreInfobyStoreId:(NSString *)sid notifyName:(NSString *)notifyName styp:(NSString *)stype{
    LogTrace();
    NSMutableDictionary *storeInfo = [NSMutableDictionary dictionary];
    [storeInfo setObject:[NSString stringNotNilWithValue:sid] forKey:WSREQUEST_STOREID];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [storeInfo setObject:@"updateStoreInfo" forKey:APPDATA_OBJID];
    if (stype) {
         [storeInfo setObject:[NSString stringNotNilWithValue:stype] forKey:@"storetype"];
    }
    [self uploadDatasDictionary:storeInfo urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}

- (void)appFetchStoreInfoWith:(NSString *)aStoreNameFilter
                    andFilter:(NSString *)aFilter
                   notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *objid = @"Executiveinfo";
    NSString *empid = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *fetchinfo = [NSMutableDictionary dictionary];
    [fetchinfo setObject:[NSString stringNotNilWithValue:objid] forKey:@"objId"];
    [fetchinfo setObject:[NSString stringNotNilWithValue:empid] forKey:@"empId"];
    [fetchinfo setObject:[NSString stringNotNilWithValue:aStoreNameFilter] forKey:@"name"];
    [fetchinfo setObject:[NSString stringNotNilWithValue:aFilter] forKey:@"type"];
    // modify at 2013 - 12 - 24
     [self uploadDatasDictionary:fetchinfo urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}
- (void)appGetProductInfobyProductId:(NSString *)sid notifyName:(NSString *)notifyName
{
    LogTrace();
    // modify at 2013 - 12 - 25
    NSMutableDictionary *storeInfo = [NSMutableDictionary dictionary];
    [storeInfo setObject:[NSString stringNotNilWithValue:sid] forKey:WSREQUEST_PROID];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [storeInfo setObject:@"proddetailinfo" forKey:APPDATA_OBJID];
    [self uploadDatasDictionary:storeInfo urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}



//进出店
- (void)postRequestOnEnterLeaveStorebyData:(NSString *)postData
                                      md5:(NSString *)md5
                               notifyName:(NSString *)notifyName
{
    LogTrace();
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyName md5:md5 isUpload:YES];
}
/*
 *离店补录
 */
- (NSString*)postRequestUnLeavedStore:(WSInoutStoreObject*)inOutStoreObj notifyName:(NSString *)notifyName
{
    LogTrace();
    if (!inOutStoreObj) {  return nil; }
    NSString *postData = [WSJSONBuilder buildUnleavedStore:inOutStoreObj srid:nil];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyName md5:nil isUpload:YES];
    
    return postData;
}

- (void)postRequestAcvtData:(NSString *)postData
                 notifyName:(NSString *)notifyName
                        md5:(NSString *)md5
       isSynchronizeRequest:(BOOL)isSynchronizeRequest
{
    LogTrace();
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyName md5:md5 isUpload:!isSynchronizeRequest];
    
}


- (void)postRequestOnPhotoWithFilePath:(NSString *)filePath
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID{
    LogTrace();
    
    NSDictionary *params = [WSJSONBuilder buildImageParamsDicByImageID:imageID];
    
    [self uploadImageWithFilePath:filePath
                           params:params
                              url:URL_IMAGEUPLOAD
                       notifyName:aNotify
                              md5:md5];
    
}

// common request for msg
- (void)postRequestWith:(NSString *)objId name:(NSString *)notify {
     NSString* postData = [WSJSONBuilder buildWith:objId];
     [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:notify md5:nil isUpload:NO];
}

//MSG 下拉刷新  type 为 0 请求msgsQuery 节点，否则请求msgs 节点
-(void)postRequestMSGWithType:(NSString *)type
{
    LogTrace();
    NSString* postData ;
    if ([type isEqualToString:@"0"]) {
        postData = [WSJSONBuilder buildQueryMsg];
    }else{
        postData = [WSJSONBuilder buildMSG];
    }
    
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:UPDATA_MSG md5:nil isUpload:NO];
    
}
-(void)postNewRequestMSGWithType:(NSString *)type storeId:(NSString*)storeId{
    LogTrace();
    NSString* postData ;
    if ([type isEqualToString:@"0"]) {
        postData = [WSJSONBuilder buildQueryMsg];
    }else{
        postData = [WSJSONBuilder buildNewMSG];
    }
    NSMutableDictionary * paraDic = [[postData mutableObjectFromJSONString] mutableCopy];
    [paraDic setObject:storeId forKey:@"storeId"];
    [self uploadDatasDictionary:paraDic urlString:URL_UPDATE notifyName:UPDATA_MSG md5:nil isUpload:NO];
}

//outPlanUpdata
-(void)appRequestCode:(NSString*)phoneNum
                 notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:@"mobilemessage" forKey:@"objId"];
    [outPlan setObject:phoneNum forKey:@"mobile"];
    [outPlan setObject:empId forKey:@"empId"];

    
    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}


//outPlanUpdata
-(void)appUpdataOutPlanInfo:(WSStoreBean*)store
                subEmpStore:(WSSubempstoreBean *)subEmpStore
                 notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME forKey:@"objId"];
    NSString *currentStoreEmpId = ([subEmpStore.empId length] > 0)? subEmpStore.Id:empId;
    [outPlan setObject:[NSString stringNotNilWithValue:currentStoreEmpId] forKey:@"empId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];//辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台

    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}

//add 添加主管拜访门店的获取 by yanguoshuai at 2012－03－27
-(void)appUpdataManagerInfo:(NSString*)storeId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:storeId] forKey:@"storeId"];
    [outPlan setObject:[NSString stringNotNilWithValue:objId] forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    //辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台
    if ([objId isEqualToString: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME]) {
        [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    }
    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}
-(void)appUpdataManagerInfo:(WSStoreBean*)store
                subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype
{
   
    [self appUpdataManagerInfo:store StoreIds:nil subempId:subempId withObjId:objId notifyName:notifyName styp:stype];
    
}

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                   StoreIds:(NSString*)storeIds
                   subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype
{
    [self appUpdataManagerInfo:store StoreIds:storeIds subempId:subempId withObjId:objId notifyName:notifyName styp:stype timeout:0];
}



-(void)appUpdataManagerInfo:(WSStoreBean*)store
                   StoreIds:(NSString*)storeIds
                   subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype
                    timeout:(NSInteger)timeout
{
 
    LogTrace();
    NSString* empId = subempId ?:[WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    if(storeIds)
    {
        [outPlan setObject:[NSString stringNotNilWithValue:storeIds] forKey:@"storeIds"];
    }
    else
    {
        [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    }
    [outPlan setObject:[NSString stringNotNilWithValue:objId] forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    //辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台
    if ([objId isEqualToString: ALL_PLAN_STORE_OTHER_INFO_FOONT_TIME]) {
        [outPlan setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:@"loginEmpId"];
    }
    if (stype ) {
        [outPlan setValue:[NSString stringNotNilWithValue:stype]  forKey:@"styp"];
    }
    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO timeout:timeout];
}


- (void)fetchHospitalInfo:(WSStoreBean *)store notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:@"spestoreinfo" forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}


//经销商
-(void)appUpdataAgentInfo:(WSStoreBean*)store 
               notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:@"diststoreinfo" forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
 [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
    
}

/*
 当升级时有未上传数据,缓存下empId上传的时候用
 */
- (void)saveEmpIdIfNotExistWith:(NSString *)empId {
  
    if (![WSAppData getObjectbyKey:APPDATA_EMPID]) {
        [WSAppData putObject:[NSString stringNotNilWithValue:empId] forKey:APPDATA_EMPID];
    }
}


-(void)uploadFailedData:(id)aFailedData
{
    LogTrace();
    WSOffLineUploadObject* object=(WSOffLineUploadObject*)aFailedData;
    NSString* l_url = object.url;
    NSString* l_postData = object.upload_data;
    NSString* l_MD5 = object.img_idx;
    NSString* l_notify = object.notify;
    NSString *dataType = object.data_type;
    NSString *l_fileName = object.photo_filename;

    NSString *empId = object.emp_id;
    [self saveEmpIdIfNotExistWith:empId];

    
    NSString *dataInfo = [NSString stringWithFormat:@"[url:%@]  [postData:%@]  [md5:%@] [notify:%@] [dataType : %@]",l_url,l_postData,l_MD5,l_notify,dataType];
    
    if (dataType && [dataType isEqualToString:kOfflineTableDataType_P]) {
        
        if ([l_fileName hasPrefix:PPZ_Upload_Logo]) {
            //
            if ([WSPaiPaiManager sharedInstance].isTasking)
            {
                return;
            }
            [[WSPaiPaiManager sharedInstance] ppzUploadFailDataWithObj:aFailedData]; //拍拍赚数据上传逻辑，走这里
            return;
        }
        if ([[l_postData objectFromJSONString] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[l_postData objectFromJSONString]] ;
            NSString *imageID = [dic stringForKey:@"photo" withDefault:nil];
            //2012-12-26:for PfizerOTC
            //该代码是为了兼容和解决辉瑞OTC陈列拍照的bug,之前key写成id了，为了能让用户将照片上传上去，所以作此兼容。
            //http://192.168.1.15/jira/browse/CALLCENTER-603
            if (imageID == nil)
            {
                imageID = [dic stringForKey:@"id" withDefault:nil];
                if (imageID) {
                    [dic removeObjectForKey:@"id"];
                    [dic setObject:imageID forKey:@"photo"];
                }
            }
            //2012-12-26:for PfizerOTC
            
            if (imageID)
            {
                NSString *filePath = [[SDImageCache sharedImageCache] imagePathFromKey:imageID];
                if (filePath)
                {
                    LogInfo(@"if (filePath)");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self uploadImageWithFilePath:filePath
                                               params:dic
                                                  url:l_url
                                           notifyName:l_notify
                                                  md5:l_MD5];
                    });
                    LogInfo(@"\n[ LogInfo -  成功获取图片数据并上传 %@ ]\n",dataInfo);
                    return;
                    
                }
                else
                {
                    [[SDImageCache sharedImageCache] printfDebugPhotoInfo:@"image data is null"];
                    NSString *errorStr = [NSString stringWithFormat:@"%@  image data is null(The image may be deleted).", imageID];
                    NSDictionary *userInfoDic = @{NSLocalizedDescriptionKey: errorStr};
                    NSError *error = [[NSError alloc] initWithDomain:kUploadFailedDataErrorDomain code:EUploadFailedDataImageDataInvalid userInfo:userInfoDic];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:ERROR];
                    [[NSNotificationCenter defaultCenter] postNotificationName:l_notify
                                                                        object: error
                                                                      userInfo:userInfo];
                    
                    LogError(@"%@ 由于获取照片为空上传数据失败，已经将此数据记录为 ‘错误数据’  %@",[error ws_localizedDescription],object);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[WSOffLineUploadTable sharedTable] updateUploadFlagErrorWithImageIndex:l_MD5 notifyId:l_notify];
                    });
                    return;
                }
            }
            else
            {
                NSString *errorStr = @"image id is null. ";
                NSDictionary *userInfoDic = @{NSLocalizedDescriptionKey: errorStr};
                NSError *error = [[NSError alloc] initWithDomain:kUploadFailedDataErrorDomain code:EUploadFailedDataImageIDInvalid userInfo:userInfoDic];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:error forKey:ERROR];
                [[NSNotificationCenter defaultCenter] postNotificationName:l_notify
                                                                    object: error
                                                                  userInfo:userInfo];
                LogError(@" %@ 由于获取照片为空上传数据失败，已经将此数据记录为 ‘错误数据’  %@",[error ws_localizedDescription],dataInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[WSOffLineUploadTable sharedTable] updateUploadFlagErrorWithImageIndex:l_MD5 notifyId:l_notify];
                });
                return;
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uploadDatasDictionary:[l_postData mutableObjectFromJSONString] urlString:l_url notifyName:l_notify md5:l_MD5 isUpload:YES];
    });
    LogInfo(@"上传离线数据： %@",dataInfo);
}


-(void)uploadComment:(NSString*)aComment
          NotifyName:(NSString*)aNotifyName
               MSGID:(NSString*)aMsgId
            Receiver:(NSArray*)aReceive
{
    LogTrace();
    NSString *postData = [WSJSONBuilder buildCommentWithContent:aComment
                                                        MSGID:aMsgId
                                                    Receivers:aReceive];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:nil isUpload:YES];
}
-(void)uploadComment:(NSString*)aComment
          NotifyName:(NSString*)aNotifyName
               MSGID:(NSString*)aMsgId
            Receiver:(NSArray*)aReceive
            AcvtData:(NSString *)aAcvtData
                 Md5:(NSString *)aMd5
{
    
    LogTrace();
    NSString *postData = [WSJSONBuilder buildCommentWithContent:aComment
                                                        MSGID:aMsgId
                                                    Receivers:aReceive
                                                     AcvtData:aAcvtData];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:aMd5 isUpload:YES];
    
}

-(void)getMSGWithId:(NSString*)aMsgId
         NotifyName:(NSString*)aNotifyName

{
    LogTrace();
    NSString *postData = [WSJSONBuilder buildGetPartnersCommentsWithID:aMsgId];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

-(void)uploadBackGroundGPSWithLocation:(WSLocationDescribe *)locatinDescribe
                            NotifyName:(NSString*)aNotifyName
{
    LogTrace();
    if (locatinDescribe.location == nil) {
        return;
    }
    
    NSString *postData = [WSJSONBuilder buildBackGroundGPSWithLocation:locatinDescribe];
    
    [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:aNotifyName];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:@"" isUpload:YES];
}

-(void)uploadBeaconWithUUid:(NSString*)beaconUuid
                withStoreId:(NSString*)storeId
                 NotifyName:(NSString*)aNotifyName
{
    if (beaconUuid) {
        if (!aNotifyName) {
            aNotifyName = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
        }
        NSString *postData = [WSJSONBuilder buildBeaconWithUUid:beaconUuid withStoreId:storeId];
        
        [WSOfflineDataDBService insertUploadData:postData URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:aNotifyName];
        [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:@"" isUpload:YES];
    }
}


//发送建议
-(void)uploadSendSuggestion:(NSDictionary*)aSelectSugs Notify:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildSendSuggestionWithTitle:aSelectSugs];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:nil isUpload:YES];
    
}

//查消息列表
-(void)getSuggestionList:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildGetSuggestionTitleAndContent];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

//发送回复消息内容
-(void)postSuggestionReply:(NSDictionary*)aSelectSugs
                    Notify:(NSString*)aNotifyName
                      SUGs:(WSSugReplyBeanArray*)aSugBeanArray
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildSendSuggestionReplay:aSelectSugs SUGs:aSugBeanArray];
     [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:nil isUpload:YES];
}

//查消息回复
-(void)getSuggestionReplyList:(NSString*)aMsgId Notify:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildGetSuggestionReplyListWithMsgId:aMsgId];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

-(void)PostModifyStoreInfo:(NSDictionary*)aDic NotifyName:(NSString*)aNotifyName Store:(WSStoreBean*)aStore
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildModifyStoreInfo:aDic Store:aStore];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:nil isUpload:YES];
    
}



-(void)performanceInfoRefreshWithNotifyName:(NSString*)aNotifyName
{
    LogTrace();
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
    [postDictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey: @"empId"];
    [postDictionary setObject:@"empinforefresh" forKey:@"objId"];
    NSString *postData = [postDictionary JSONString];
     [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

- (void)postVistHelpOutPlanQuery:(NSDictionary *)aDic {
    LogTrace();
    NSString * postData = [WSJSONBuilder buildOutPlanOfHelpVistRequst:aDic];
     [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:[aDic objectForKey:NT_NAME] md5:nil isUpload:YES];
}

// 辉瑞医院使用
- (void)QueryHospitalInfoWith:(NSDictionary *)aDic
{
    LogTrace();
    [self uploadDatasDictionary:aDic urlString:URL_UPDATE notifyName:[aDic objectForKey:NT_NAME] md5:nil isUpload:NO];
}

- (void)fetchDoctorsWithFilter:(NSString *)aFilter notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *name = (aFilter != nil && [aFilter length] > 0) ? aFilter : @"";
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [dic setObject:@"myOrgDoctor" forKey:@"objId"];
    [dic setObject:@"no cellid" forKey:@"cellId"];
    [dic setObject:name forKey:@"name"];
    [self uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}


- (void)uploadMarketActityDatas:(NSString *)aPostData notifyName:(NSString *)aNotifyName
{
    [self uploadDatasDictionary:[aPostData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:aNotifyName md5:nil isUpload:YES];
}

- (void)uploadPfizerBusinessDatas:(NSDictionary *)aDicData functionBean:(WSFuncsBean *)funcs withMd5:(NSString *)aMd5 notifyName:(NSString *)aNotifyName
{
     LogTrace();
    NSString *postData = [WSJSONBuilder buildPfizerBusinessStringWithDic:aDicData functionBean:funcs withMd5:aMd5];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:YES];
}

- (void)fetchDealersWithFilter:(NSString *)aFilter notifyName:(NSString *)aNotifyName
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *name = (aFilter != nil && [aFilter length] > 0) ? aFilter : @"";
    [dic setObject:empId forKey:@"empId"];
    [dic setObject:@"spestore" forKey:@"objId"];
    [dic setObject:@"no cellid" forKey:@"cellId"];
    [dic setObject:name forKey:@"name"];
     [self uploadDatasDictionary:dic urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}


-(void)requestMsgReceivers:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildMSGReceivers:aDic];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:[aDic objectForKey:NT_NAME] md5:nil isUpload:NO];
}

-(void)uploadExceptionInfo:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [WSJSONBuilder buildExceptionInfo:aDic];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_EXCEPTION notifyName:NT_EXPECTION md5:nil isUpload:YES];

}

-(void)uploadVideoDatas:(NSData*)aPostData 
                    Url:(NSString*)aUrl 
             NotifyName:(NSString*)aNotifyName
                    Md5:aMd5
{
    LogTrace();
    [[WSRequestBase shareInstance] postVideoData: aPostData
                                             url:aUrl
                                      notifyName: aNotifyName
                                             md5:aMd5];
}

//测试
-(void)uploadVideoFilePah:(NSString*)filePath
                    Url:(NSString*)aUrl
             NotifyName:(NSString*)aNotifyName
                    Md5:aMd5
{
    LogTrace();
    [[WSRequestBase shareInstance] postVideoFilePath:filePath
                                             url:aUrl
                                      notifyName: aNotifyName
                                             md5:aMd5];
}


-(void)uploadImageWithFilePath:(NSString *)filePath params:(NSDictionary *)params url:(NSString*)aUrl notifyName:(NSString*)aNotifyName md5:(NSString *)aMd5 {
    
    LogTrace();
    
    NSString *exPicFolder = [[NSUserDefaults standardUserDefaults] stringForKey:EXTERNAL_PIC_FOLDER];
    if (exPicFolder && exPicFolder.length > 0) {
        
        UIImage *saveImage = [UIImage imageWithContentsOfFile:filePath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveImageToAlbum:saveImage withAlbumName:exPicFolder photoKey:[params objectForKey:@"photoKey"]];
        });
    }

    if (![WSEnvrionment getUseAliyun]) {
        
        [[WSRequestBase shareInstance] postUrlString:aUrl headers:params filePath:filePath notifyName:aNotifyName md5:aMd5];
    } 
    else {
        
        NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        NSString *photoKey = [params objectForKey:@"photoKey"];
        NSString *photoName = [params objectForKey:@"photoName"];
        NSString *key = (photoName.length > 0) ? photoName : photoKey;
        NSString *fullPath = [NSString stringWithFormat:@"Saas/%@/%@/%@%@", appId, [WSCurrentTime getDateString], key, PHOTO_JPG_SUFFIX];
        
        [[WSAliyunUtil sharedAliyunUtil] uploadImageToAliCloud:fullPath localPath:filePath block:^(BOOL isSuccess, NSString *refCloudKey, NSError *error) {
            
            if (isSuccess) {
                NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] initWithDictionary:params];
                [tempParams setObject:refCloudKey forKey:@"photo"];
                [[WSRequestBase shareInstance] postUrlString:aUrl headers:[tempParams copy] filePath:filePath notifyName:aNotifyName md5:aMd5];
            } 
            else {
            
                if(aNotifyName && aNotifyName.length > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:aNotifyName object: nil userInfo:nil];
                }
                LogError(@"上传图片到阿里云失败:%@", error.localizedDescription);
            }
        }];
    }
}

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView {
    [self downloadImageWithUrl:urlString imageView:imageView placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder {
    [self downloadImageWithUrl:urlString imageView:imageView placeholderImage:placeholder options:0 progress:nil completed:nil];
}


- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView completed:(WSRequestDownloadCompletedBlock)completedBlock {
    [self downloadImageWithUrl:urlString imageView:imageView placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder completed:(WSRequestDownloadCompletedBlock)completedBlock {
    [self downloadImageWithUrl:urlString imageView:imageView placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder progress:(WSRequestDownloadProgressBlock)progressBlock completed:(WSRequestDownloadCompletedBlock)completedBlock {
    [self downloadImageWithUrl:urlString imageView:imageView placeholderImage:placeholder options:0 progress:progressBlock completed:completedBlock];
}

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(WSRequestDownloadProgressBlock)progressBlock completed:(WSRequestDownloadCompletedBlock)completedBlock {
    
    if (![self isUseAliyunByString:urlString]) {
        NSURL *url = [NSURL URLWithString:urlString];
        [imageView sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *imageURL) {
            if (completedBlock) {
                completedBlock(image, error, imageURL);
            }
        }];
    } else {
        //        YIHAIKERRY-2517
        //        益海嘉里-上海：门头照：优化门头照加载时间
        NSString *localImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:urlString]]];
        UIImage *serverImage = [[SDImageCache sharedImageCache] imageFromKey:localImageKey];
        if (serverImage)  {
            [imageView setImage:serverImage];
        } else {
        NSString *aliyunUrlString = [self getAliyunUrl:urlString];
        [[WSAliyunUtil sharedAliyunUtil] downLoadAliCloudImage:aliyunUrlString category:@"" localFileName:@"" progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (progressBlock) {
                progressBlock(receivedSize, expectedSize);
            }
        } completed:^(UIImage *image, NSError *error) {
            if (image) {
                [imageView setImage:image];
                
                NSURL *url = [NSURL URLWithString:urlString];
                [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
                
            }
            if (completedBlock) {
                NSURL *url = [NSURL URLWithString:urlString];
                completedBlock(image, error, url);
                }
            }];
        }
    }
}

- (void)downloadImageWithUrl:(NSString *)urlString
                    progress:(WSRequestDownloadProgressBlock)progressBlock
                   completed:(WSRequestDownloadCompletionWithFinishedBlock)completedBlock {

    NSURL *url = [NSURL URLWithString:urlString];
    
    if (![self isUseAliyunByString:urlString]) {
         [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
             progressBlock(receivedSize, expectedSize);
         } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
             completedBlock(image, error, finished, imageURL);
         }];
     } else {
         UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:urlString];
         if (cachedImage) {
             if (completedBlock) {
                 completedBlock(cachedImage, nil, YES, url);
             }
             return;
         }
         
         NSString *aliyunUrlString = [self getAliyunUrl:urlString];
         [[WSAliyunUtil sharedAliyunUtil] downLoadAliCloudImage:aliyunUrlString category:@"" localFileName:@"" progress:^(NSInteger receivedSize, NSInteger expectedSize) {
             
         }  completed:^(UIImage *image, NSError *error) {
             if (completedBlock) {
                 if (image) {
                     [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
                 }
                 
                 completedBlock(image, error, YES, url);
             }
         }];
     }
}


- (BOOL)isUseAliyunByString:(NSString *)urlString {
    BOOL isUseAliyun = [WSEnvrionment getUseAliyun];
    if (isUseAliyun) {
        // 如果是阿里云环境，图片地址不是以 aliyun 开头或者没有 aliyun 标志则按照正常逻辑下载图片
        NSRange range = [urlString rangeOfString:PHOTOTYPE_ALIYUN];
        if (range.location == NSNotFound || range.location != 0) {
            isUseAliyun = NO;
        }
    }
    return isUseAliyun;
}
- (BOOL)isHttpString:(NSString *)urlString {
        BOOL isHttp = YES;
        NSRange range = [urlString rangeOfString:PHOTOTYPE_HTTP];
        if (range.location == NSNotFound || range.location != 0) {
            isHttp = NO;
        }
    return isHttp;
}

- (NSString *)getAliyunUrl:(NSString *)urlString {
    NSRange range = [urlString rangeOfString:PHOTOTYPE_ALIYUN];
    if (range.location != NSNotFound && range.location == 0) {
        NSString *aliyunUrl = [urlString substringFromIndex:range.length];
        return aliyunUrl;
    }
    return nil;
}

//添加获取经销商的节点
//add 添加主管拜访门店的获取 by yanguoshuai at 2012－03－27
-(void)appUpdataDealterInfo:(NSString *)notifyName andObjId:(NSString *)objId
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
//    [outPlan setObject:@"dealerstore" forKey:@"objId"];
    [outPlan setObject:objId forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [self uploadDatasDictionary:outPlan urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}
//上传拜访计划 2012－06－29 yanguoshuai
- (void)uploadStoreSchedule:(WSArrangeScheduleViewController *)vc {
    LogTrace();
    NSString *postData = [WSJSONBuilder buildStoreScheduleData:vc];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:UPDATAFINISH_NOTIFY md5:nil isUpload:NO];
}

-(void)fetchStoreSchedule:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *postData = [WSJSONBuilder buildAllStoreScheduleRequest:aDic];
     [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

-(void)fetchCalendarDateDone:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *postData = [WSJSONBuilder buildCalendarRequest:aDic];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

-(void)appUpdateGeoDataWithEmpId:(NSString *)empId
                      notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *geo = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (empId && [empId isKindOfClass:[NSString class]]) {
        [geo setObject:empId forKey:@"empId"];
    }
    [geo setObject:@"geography" forKey:@"objId"];
    
     [self uploadDatasDictionary:geo urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}



// ----------------------- 数据上传过程优化 -----------------------

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
                progress:(WCRequestProgressBlock)progressBlock
{
    LogTrace();
    
    [self appGetRootConfig:username passWd:passWd notifyName:notifyName url:URL_GETROOTCONFIG progress:progressBlock];
    
}

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
                     url:(NSString *)url
                progress:(WCRequestProgressBlock)progressBlock
{
    LogTrace();
    NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
    if ([username isKindOfClass:[NSString class]])
    {
        [loginDic setObject:username forKey:USERNAME];
    }
    
    // appGetRootConfig接口加密key只有16位，所以请求时需要清空第二部分key，其他接口是32位key
    WCDataPacker2 *dataPacker2 = [WCDataPacker2 sharedInstance];
    [dataPacker2 setInitHttpCode2:nil];
    
    // 判断是否加密，先用后台配置串里给的值，如果没有则用打包时配置的（ConfigFile中PasswordEncrypt字段）
    NSString *password_encrypt = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordEncrypt];
    if (!password_encrypt)
    {
        password_encrypt = [WSPlistHelper getPasswordEncrypt];
    }
    
    if (password_encrypt) {
        if ([@"1" isEqualToString:password_encrypt])
        {
            passWd  = [WSEncrpytion encryptUseDES:passWd key:LOGIN_PASSWORD_DES_PRIVATE_KEY];
        }
    }
    if (passWd)
    {
        [loginDic setObject:passWd forKey:PASSWORD];
    }
    // 传给服务器 1：加密  0：不加密
    if (!password_encrypt)
    {
        password_encrypt = @"0";
    }
    if (password_encrypt)
    {
        [loginDic setObject:password_encrypt forKey:@"password_encrypt"];
    }
    id versionCode = [WSEnvrionment getAppSystemVersion];
    if (versionCode != nil)
    {
        [loginDic setObject:versionCode forKey:VERSION];
    }
    
    NSString *platformName = [UIDevice platformNameForSFA];
    if (platformName != nil)
    {
        [loginDic setObject:platformName forKey:PLATFORM];
    }
    
    NSString *identifier = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (identifier != nil)
    {
        [loginDic setObject:identifier forKey:@"imei"];
    }
    
    [loginDic setObject:@"" forKey:@"simid"];
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];
    if (!svnVersion)
    {
        svnVersion = @"";
    }
    [loginDic setObject:svnVersion forKey:@"AKU"];
    
    [loginDic setObject:[UIDevice getPreferredLanguage] forKey:LANGUAGE];
    
    NSString *projectName = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleName"];
    [loginDic setObject:[NSString stringNotNilWithValue:projectName] forKey:@"product"];
    
    NSNumber *exitAppStatus = (NSNumber *)[FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if (exitAppStatus)
    {
        [loginDic setObject:exitAppStatus forKey:@"exitAppStatus"];
    }
    
    [loginDic setObject:@"iOS" forKey:OS];
    [loginDic setObject:[[UIDevice currentDevice] systemVersion] forKey:OSVERSION];
    
    NSLog(@"%@", url);
    
    LogInfo(@"程序开始登陆并请求配置数据");
    
    [self uploadDatasDictionary:loginDic urlString:url notifyName:notifyName md5:nil isUpload:NO progress:progressBlock];
    
}

- (void)appUpdataOrderInfoEmpId:(NSString *)aEmpId
                     notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:[NSString stringNotNilWithValue:aEmpId] forKey:@"empId"];
    [postDic setObject:@"ordLst" forKey:@"objId"];
    
    [self uploadDatasDictionary:postDic urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}


- (void)postRequestData:(NSDictionary *)aDic
           notifyName:(NSString *)aNotifyName
{
    LogTrace();
    /*  Zheng Jiepeng 2013/07/02
     *  向服务器发送 请求数据
     *  请求参数 放在 aDic 中
     *  不需要每次都实现一个特定方法
     */
    [self uploadDatasDictionary:aDic urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

- (void)fetchOutplanStoreWithGeographicId:(NSString *)aGeoId withObjId:(NSString *)aObjId withNotifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outplan = [NSMutableDictionary dictionary];
    [outplan setObject:[NSString stringNotNilWithValue:aObjId] forKey:@"objId"];
    [outplan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [outplan setObject:[NSString stringNotNilWithValue:aGeoId] forKey:@"geoId"];
    
     [self uploadDatasDictionary:outplan urlString:URL_UPDATE notifyName:aNotifyName md5:nil isUpload:NO];
}

- (void)sendReadedMessageRequestWithMsgId:(NSString *)aMsgId andNotifyName:(NSString *)aNotifyName andMD5:(NSString *)aMd5
{
    LogTrace();
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    //isSync
    [dic setObject:@"0" forKey:@"isSync"];
    [dic setObject:@"0" forKey:@"compress"];
    id obj = [WSAppData getObjectbyKey:SERVERREQUIRE];
    if (obj != nil) {
        [dic setObject:obj forKey:SERVERREQUIRE];
    }
    
    [dic setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [dic setObject:@"normal" forKey:@"funcsTyp"];
    [dic setObject:@"NOTICE_READED" forKey:@"index"];
    NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    [msgDic setObject:[NSString stringNotNilWithValue:aMsgId] forKey:@"msgsId"];
    [dic setObject:msgDic forKey:@"hidVal"];
    [dic setObject:[WSCurrentTime getTimeMillisString] forKey:@"mobileClickTime"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"account"];
    [dic setObject:@"NOTICE_READED" forKey:@"method"];
    [dic setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatasDictionary:dic urlString:URL_UPLOAD notifyName:aNotifyName md5:aMd5 isUpload:YES];
}
#pragma mark - new Request method
-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                         url:(NSString*)aUrl
                  NotifyName:(NSString*)aNotifyName
                         md5:aMd5
              withUploadType:(WCDatasUploadType)aUploadType
                    isUpload:(BOOL)isUpload
{
    LogTrace();
    WSRequestBase *requestBase = [WSRequestBase shareInstance];
    [requestBase postUrlString:aUrl
                    parameters:datasDic
                    notifyName:aNotifyName
                           md5:aMd5
                withUploadType:aUploadType
                      isUpload:isUpload];
}

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
{
    [self uploadDatasDictionary:datasDic urlString:aUrlString notifyName:aNotifyName md5:aMd5 isUpload:isUpload progress:nil];
}

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
                     timeout:(NSInteger)timeout
{
    [self uploadDatasDictionary:datasDic urlString:aUrlString notifyName:aNotifyName md5:aMd5 isUpload:isUpload timeout:timeout progress:nil];
}

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
                    progress:(WCRequestProgressBlock)progressBlock {
    [self uploadDatasDictionary:datasDic urlString:aUrlString notifyName:aNotifyName md5:aMd5 isUpload:isUpload timeout:0 progress:nil];
}


-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
                    timeout:(NSInteger)timeout
                    progress:(WCRequestProgressBlock)progressBlock
{
    WSRequestBase *requestBase = [WSRequestBase shareInstance];
    [requestBase postUrlString:aUrlString
                    parameters:datasDic
                    notifyName:aNotifyName
                           md5:aMd5
                withUploadType:WCDatasUploadTypeDefault
                      isUpload:isUpload
                       timeout:timeout
                      progress:progressBlock];
    [requestBase setRequestSuccess:^{
        if (self.requsetFinish) {
            self.requsetFinish();
        }
    }];
}

// 若调查问卷中 问题类型为DM的问题 登录时候没有下发数据则实时请求
-(void)appUpdataAcvtQstTypeIsDmWithObjId:(NSString *)objId filter:(NSString *)filter
                              notifyName:(NSString *)notifyName {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    
    [dictionary setObject:[NSString stringNotNilWithValue:empId] forKey:EMPID];
    [dictionary setObject:@"" forKey:@"name"];
    [dictionary setObject:objId forKey:OBJID];
    [dictionary setObject:@"no cellid" forKey:@"cellId"];
    [self uploadDatasDictionary:dictionary urlString:URL_UPDATE notifyName:notifyName md5:nil isUpload:NO];
}

- (void)uploadStatisticsDatas:(NSDictionary *)dic
                   notifyName:(NSString *)notifyName
{
    LogTrace();
    
    [self uploadDatasDictionary:dic urlString:URL_ANALYTICS notifyName:notifyName md5:nil isUpload:NO];
    
}

- (void)checkUpgradeWithUrl:(NSString *)url
                 notifyName:(NSString *)notifyName {
    
    NSMutableDictionary *params = [[self getNormalParam] mutableCopy];
    [params removeObjectForKey:VERSION];
    [params removeObjectForKey:SYS_VERSION];
    [self uploadDatasDictionary:params urlString:url notifyName:notifyName md5:nil isUpload:NO];
}

#pragma mark - 上传关注状态 content:内容 storeId:门店id srid:随访人id notifyName:通知名称
- (void)uploadFollowStateWithContent:(NSString *)content
                             storeId:(NSString *)storeId
                                srid:(NSString *)srid
                          notifyName:(NSString *)notifyName
{
    NSString *postData = [WSJSONBuilder buildFollowWithContent:content storeId:storeId srid:srid mark:@"FOLLOW" dataMark:@"follow"];
    [self uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPLOAD notifyName:notifyName md5:nil isUpload:YES];
}

#pragma mark - 上传微信分享内容 title:标题 url:分享文章的链接
- (void)uploadWeChatArticleWithtitle:(NSString *)title
                          articleUrl:(NSString *)url
{
    NSMutableDictionary *qstValuesDic = [NSMutableDictionary dictionaryWithCapacity:0];
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    WSAcvtBean *acvt = [service queryAcvtWithAcvtCode:@"SH_shareRecord"];
    acvt.iOriginalAcvtId = acvt.acvtId;
    if (acvt != nil) {
        for (WSAcvtBean_qst *qst in acvt.qsts) {
            NSString *key = [NSString stringWithFormat:@"%@%@",qst.qstType,qst.acvtQstId];
            if ([qst.qstCod isEqualToString:@"shareTitle"]) {
                [qstValuesDic setObject:title forKey:key];
            } else if ([qst.qstCod isEqualToString:@"shareUrl"]) {
                [qstValuesDic setObject:url forKey:key];
            }
        }
    }
    WSFuncsBean *funcs = [[WSFuncsBean alloc] initFuncsWithObject:@{FUNCS_FC:@"FAC_wx_share"}];
    WSAcvtModel *model = [[WSAcvtModel alloc] init];
    model.currentAcvtBean = acvt;
    model.currentFuncs = funcs;
    NSString *postData  = [WSJSONBuilder buildAcvtDatasbyFuncs:funcs
                                                          acvt:acvt
                                                       isPhoto:NO
                                                         Store:nil
                                                  qstValuesDic:qstValuesDic
                                                           md5:[WSJSONBuilder gen_uuid]
                                                      submitId:[WSJSONBuilder gen_uuid]
                                                        Others:nil
                                             addedAcvtForStore:nil
                                                    tableDatas:nil
                                                    photoNames:nil
                                                     isNeedAdd:NO
                                                         isAdd:NO
                                                 subempStoreId:nil];
    
    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
    [self postRequestAcvtData:postData notifyName:notifyID md5:model.md5 isSynchronizeRequest:[model isSynchronizeRequest]];

    
}
- (void)postRequestStoreTimeLengthWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock) failureBlock{
    WCBaseRequest *requestBase = [[WCBaseRequest alloc]init];
    requestBase.responseDataClass= [WSNormalHttpResponse class];
    [requestBase  asyncPostJson:parameters urlString:URL_UPDATE isUpload:NO success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        if(successBlock){
            successBlock(response,localInfo);
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failureBlock){
                failureBlock(response,localInfo);
            }
    }];
}
- (void)postRequestRouteListWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock{
    WCBaseRequest *requestBase = [[WCBaseRequest alloc]init];
    requestBase.responseDataClass= [WSNormalHttpResponse class];
    [requestBase  asyncPostJson:parameters urlString:URL_UPDATE isUpload:NO success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        if(successBlock){
            successBlock(response,localInfo);
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failureBlock){
                failureBlock(response,localInfo);
            }
    }];
}
- (void)postRequestWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock{
    
    WCBaseRequest *requestBase = [[WCBaseRequest alloc]init];
    requestBase.responseDataClass= [WSNormalHttpResponse class];
    LogInfo(@"post params：%@",parameters);
    [requestBase  asyncPostJson:parameters urlString:URL_UPDATE isUpload:NO success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        if(successBlock){
            successBlock(response,localInfo);
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failureBlock){
                failureBlock(response,localInfo);
            }
    }];
}




- (void)saveImageToAlbum:(UIImage *)image withAlbumName:(NSString *)name photoKey:(NSString *)photoKey{
    
    __block NSString *assetId = nil;
    __block NSMutableDictionary *keyIdDic = [WSAppData getObjectbyKey:ALBUM_KEYANDID];
    if (!keyIdDic) {
        keyIdDic = [NSMutableDictionary new];
    }
    
    NSArray *allKeys = keyIdDic.allKeys;
    if ([allKeys containsObject:photoKey]) {
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        
        [keyIdDic setObject:assetId forKey:photoKey];
        [WSAppData putObject:keyIdDic forKey:ALBUM_KEYANDID];
    } 
                                      completionHandler:^(BOOL success, NSError * _Nullable error) {

        PHAssetCollection *collection = [self getCollectionWithAlbumName:name];

        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            [request addAssets:@[asset]];
        } 
                                          completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            LogInfo(@"成功保存到相簿：%@", collection.localizedTitle);
        }];
    }];
}

- (PHAssetCollection *)getCollectionWithAlbumName:(NSString *)name {
    
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:name]) {
            return collection;
        }
    }
    
    __block NSString *collectionId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name].placeholderForCreatedAssetCollection.localIdentifier;
    } 
                                                         error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}

@end
