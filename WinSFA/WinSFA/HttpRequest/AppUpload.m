//
//  AppUpload.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "AppUpload.h"

#import "HttpWebAction.h"
#import "DecompressUtil.h"
#import "WinSFA.h"
#import "WSAppData.h"
#import "JSONBuilder.h"
#import "GetMD5byStr.h"
#import "WSCurrentTime.h"
//#import "PropertyManager.h"
#import "WSSugReplyBeanArray.h"
//#import "ConfigFileController.h"
#import "UIDevice+IdentifierAddition.h"
#import "GTMBase64.h"
#import "WSOfflineDataManager.h"

#import "WSEncrpytion.h"
#import "FileManager.h"

#import "WSPlistHelper.h"

#define VERSION     @"version"
#define PLATFORM    @"platform"
#define LANGUAGE    @"language"
#define UPDATA_MSG  @"updataMassage"

#define unUploadDataNum  @"unUploadDataNum"

#define KEY     @"keyWord1"
#define EMPID   @"empId"
#define CELLID  @"cellId"
#define OBJID   @"objId"


//#define PLATFORM_NAME [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]]

@interface AppUpload ()




@end

@implementation AppUpload

static AppUpload* instance = nil;

+(AppUpload*)shareInstance
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



-(void)uploadDatas:(NSData*)aPostData 
               Url:(NSString*)aUrl 
        NotifyName:(NSString*)aNotifyName
               Md5:aMd5
{
    HttpWebAction *hwa = [HttpWebAction shareInstance];
    [hwa startJSONStringbyPost: aUrl
                      postData: aPostData
                    notifyName: aNotifyName
                           MD5:aMd5];
}


//add by wangdongyan 04-12 for 6200服务器路线管理
-(void)appUploadOnRoadsManager:(NSDictionary *)aDic
                                notifyName:(NSString *)aNotifyName;
{
    LogTrace();
    NSString *postData = [JSONBuilder buildRoadsManagerRequest:aDic];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:aNotifyName 
                  Md5:nil];

}

- (void)appUploadOnLogin:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString *deviceIdentifer = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSMutableDictionary *login =[NSMutableDictionary dictionary];
    // 此键值对需要加在密码加密前边(cacheDataVersion对应的key是由不加密的密码拼接成的)
    NSString *cacheDataVersion = (NSString *)[FileManager getUserDefaults:CACHE_DATA_VERSION_KEY_BY_UID_AND_PASSWD(username,passWd)];
    NSLog(@"cacheDataVersion -----%@",cacheDataVersion);
    if (cacheDataVersion && [cacheDataVersion length] > 0) {
        id objectDic = [cacheDataVersion objectFromJSONString];
        if (objectDic) {
            [login setObject:objectDic forKey:CACHE_DATA_VERSION_NODE];
        }
    }

    // 应用版本号 打包时动态配置
    NSString *versionCode = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    // 获取ConfigFile中PasswordEncrypt字段 判断是否加密 此字段为打包时动态配置
    NSString *password_encrypt = [WSPlistHelper valueForKey:@"PasswordEncrypt" withPlistName:kConfilgFileName];
    if (!password_encrypt) {
        password_encrypt = @"0";
    }
    if (password_encrypt) {
        if ([@"1" isEqualToString:password_encrypt]) {
            // des加密后转成16进制字符串 并做大写处理  -  Nemo
            passWd  = [WSEncrpytion encryptUseDES:passWd key:LOGIN_PASSWORD_DES_PRIVATE_KEY];
        }
    }
    
    
    NSString *svnVersion = [WSPlistHelper valueForKey:SVNVersion withPlistName:kConfilgFileName];

    
    [login setObject:[NSString stringNotNilWithValue:username] forKey:USERNAME];
    [login setObject:[NSString stringNotNilWithValue:passWd] forKey:PASSWORD];
    [login setObject:[NSString stringNotNilWithValue:versionCode] forKey:VERSION];
    NSString *platform = [UIDevice platformNameForSFA];
    [login setObject:[NSString stringNotNilWithValue:platform] forKey:PLATFORM];
    [login setObject:[NSString stringNotNilWithValue:deviceIdentifer] forKey:@"imei"];
    [login setObject:@"" forKey:@"simid"];
    [login setObject:[NSString stringNotNilWithValue:svnVersion] forKey:@"AKU"];
    [login setObject:[UIDevice getPreferredLanguage] forKey:LANGUAGE];
    [login setObject:password_encrypt forKey:@"password_encrypt"];
    
    NSInteger unUploadDataNumber = [[WSOffLineUploadTable sharedTable] queryCountWithUploadFlagType:Failed];
    NSString *unUploadDataStr = [NSString stringWithFormat:@"%d",unUploadDataNumber];
    [login setObject:unUploadDataStr forKey:unUploadDataNum];
    
    NSString *loginStart = [WSCurrentTime getServerTime];
    [[NSUserDefaults standardUserDefaults] setObject:loginStart forKey:@"login_Start"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSObject *exitAppStatus = [FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if (exitAppStatus) {
        [login setObject:exitAppStatus forKey:@"exitAppStatus"];
    }
    
    
    
    // 如果存在webAddress  则用此url作为登陆url
    NSUserDefaults *addressDefaults= [NSUserDefaults standardUserDefaults];
    NSString *loginUrl = [addressDefaults  objectForKey:WEB_ADDRESS];
    if ([JFDEntryObject getInstance].debugWebServer) {
        loginUrl = [JFDEntryObject getInstance].debugWebServer;
    }
    [addressDefaults synchronize];
    if (loginUrl && [loginUrl hasPrefix:@"http://"]) {
        LogInfo(@"web_address---%@",loginUrl);
        loginUrl = [loginUrl stringByAppendingFormat:@"/%@/%@",@"mobile",LOGIN_METHOD];
    } else {
        loginUrl = URL_LOGIN;
    }
    [self uploadDatas:[[login JSONRepresentation]dataUsingEncoding:NSUTF8StringEncoding]
                  Url:loginUrl
           NotifyName:notifyName
                  Md5:nil];
    
}

- (void)appChangePassWord:(NSString*)newPassWord
               notifyName:(NSString*)notifyName
{
    LogTrace();
    [self uploadDatas:[newPassWord dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_CHANGEPW
           NotifyName:notifyName
                  Md5:nil];
    
}

- (void)appGetStoreInfobyStoreId:(NSString *)sid notifyName:(NSString *)notifyName filter:(NSString *)filter
{
    LogTrace();
    // modify at 2013 - 12 - 24
    NSMutableDictionary *storeInfo = [NSMutableDictionary dictionary];
    [storeInfo setObject:[NSString stringNotNilWithValue:sid] forKey:APPUPLOAD_STOREID];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [storeInfo setObject:@"updateStoreInfo" forKey:APPDATA_OBJID];
    [storeInfo setObject:[NSString stringNotNilWithValue:filter]forKey:STORE_TYPE];
    
//    NSLog(@"%@", [storeInfo JSONRepresentation]);
    
    [self uploadDatas:[[storeInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
    
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
    [self uploadDatas:[[fetchinfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}


-(void)appUpdateTaskDistributedWithEmpId:(NSString *)empId
                                   orgId:(NSString *)orgId
                              notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *taskDis = [NSMutableDictionary dictionary];
    [taskDis setObject:[NSString stringNotNilWithValue:orgId] forKey:@"orgId"];
    [taskDis setObject:@"getTaskDis" forKey:@"objId"];
    [taskDis setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatas:[[taskDis JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}
-(void)appUpdateTaskReceivedWithEmpId:(NSString *)empId
                                orgId:(NSString *)orgId
                           notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *taskRec = [NSMutableDictionary  dictionary];
    [taskRec setObject:[NSString stringNotNilWithValue:orgId] forKey:@"orgId"];
    [taskRec setObject:@"getTaskRec" forKey:@"objId"];
    [taskRec setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatas:[[taskRec JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}
-(void)appUpdateRemindDistributedWithEmpId:(NSString *)empId
                                     orgId:(NSString *)orgId
                                notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *remindDis = [NSMutableDictionary dictionary];
    [remindDis setObject:[NSString stringNotNilWithValue:orgId]forKey:@"orgId"];
    [remindDis setObject:@"getRemindDis" forKey:@"objId"];
    [remindDis setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatas:[[remindDis JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}

-(void)appUpdateRemindReceivedWithEmpId:(NSString *)empId
                                  orgId:(NSString *)orgId
                             notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary  *remindRec = [NSMutableDictionary dictionary];
    [remindRec setObject:[NSString stringNotNilWithValue:orgId] forKey:@"orgId"];
    [remindRec setObject:@"getRemindRec" forKey:@"objId"];
    [remindRec setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatas:[[remindRec JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
    
}

-(void)appUpdateTaskRepliesWithTaskId:(NSString *)taskId
                           notifyName:(NSString *)notifyName

{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *taskReplies = [NSMutableDictionary dictionary];
    [taskReplies setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [taskReplies setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [taskReplies setObject:@"getTaskRep" forKey:@"objId"];
    
    [self uploadDatas:[[taskReplies JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}

-(void)appUploadNewTaskWithName:(NSString *)name
                          empId:(NSString *)empId
                            des:(NSString *)description
                        content:(NSString *)content
                   completeDate:(NSString *)completeDate
                     remindDate:(NSString *)remindDate
                     createDate:(NSString *)createDate
                      receivers:(NSArray *)receivers
                       syncDate:(NSString *)syncDate
                     notifyName:(NSString *)notifyName
                            md5:(NSString *)md5
{
    LogTrace();
    NSMutableDictionary *taskInfo = [NSMutableDictionary dictionary];

    [taskInfo setObject:[NSString stringNotNilWithValue:md5] forKey:@"id"];
    [taskInfo setObject:[NSString stringNotNilWithValue:name] forKey:@"name"];
    [taskInfo setObject:[NSString stringNotNilWithValue:empId]forKey:@"empId"];
    [taskInfo setObject:[NSString stringNotNilWithValue:description] forKey:@"des"];
    [taskInfo setObject:[NSString stringNotNilWithValue:content] forKey:@"content"];
    [taskInfo setObject:[NSString stringNotNilWithValue:completeDate] forKey:@"completeDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:remindDate] forKey:@"remindDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:createDate] forKey:@"createDate"];
    [taskInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [taskInfo setObject:@"SPE_SEPTWOLVES_TASK" forKey:@"method"];
    [taskInfo setObject:receivers forKey:@"receiver"];
    [self uploadDatas:[[taskInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}

-(void)appUploadReplyWithTaskId:(NSString *)taskId
                          empId:(NSString *)empId
                        content:(NSString *)content
                       syncDate:(NSString *)syncDate
                     notifyName:(NSString *)notifyName
                            md5:(NSString *)md5;
{
    LogTrace();
    NSMutableDictionary *replyInfo = [NSMutableDictionary  dictionary];
    [replyInfo setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [replyInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [replyInfo setObject:[NSString stringNotNilWithValue:content] forKey:@"content"];
    [replyInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [replyInfo setObject:@"SPE_SEPTWOLVES_REPLY" forKey:@"method"];
    [self uploadDatas:[[replyInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}

-(void)appUploadCompletedTaskWithId:(NSString *)taskId
                              empId:(NSString *)empId
                           syncDate:(NSString *)syncDate
                         notifyName:(NSString *)notifyName
                                md5:(NSString *)md5
{
    LogTrace();
    NSMutableDictionary *completeInfo = [NSMutableDictionary dictionary];
    [completeInfo setObject:[NSString stringNotNilWithValue:taskId]forKey:@"taskId"];
    [completeInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [completeInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [completeInfo setObject:@"SPE_SEPTWOLVES_STATUS" forKey:@"method"];
    
    [self uploadDatas:[[completeInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}

-(void)appUploadTaskReadStatusWithId:(NSString *)taskId
                               empId:(NSString *)empId
                            syncDate:(NSString *)syncDate
                          notifyName:(NSString *)notifyName
                                 md5:(NSString *)md5
{
    LogTrace();
    NSMutableDictionary *readStatusInfo = [NSMutableDictionary dictionary];
    [readStatusInfo setObject:[NSString stringNotNilWithValue:taskId] forKey:@"taskId"];
    [readStatusInfo setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [readStatusInfo setObject:[NSString stringNotNilWithValue:syncDate] forKey:@"syncDate"];
    [readStatusInfo setObject:@"SPE_SEPTWOLVES_READ_STATUS" forKey:@"method"];
    [self uploadDatas:[[readStatusInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}

- (void)appGetStoreInfobyStoreId:(WSStoreBean*)store notifyName:(NSString *)notifyName{
    LogTrace();
    NSMutableDictionary *storeInfo = [NSMutableDictionary dictionary];
    [storeInfo setObject:[NSString stringNotNilWithValue:store.Id] forKey:APPUPLOAD_STOREID];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [storeInfo setObject:[NSString stringNotNilWithValue:store.styp] forKey:@"storetype"];
    [storeInfo setObject:@"updateStoreInfo" forKey:APPDATA_OBJID];
    [self uploadDatas:[[storeInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:notifyName 
                  Md5:nil];

}

- (void)appGetProductInfobyProductId:(NSString *)sid notifyName:(NSString *)notifyName
{
    LogTrace();
    // modify at 2013 - 12 - 25
    NSMutableDictionary *storeInfo = [NSMutableDictionary dictionary];
    [storeInfo setObject:[NSString stringNotNilWithValue:sid] forKey:APPUPLOAD_PROID];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_BIZDATE]] forKey:APPDATA_BIZDATE];
    [storeInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [storeInfo setObject:@"proddetailinfo" forKey:APPDATA_OBJID];

    [self uploadDatas:[[storeInfo JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:notifyName 
                  Md5:nil];
}



//进出店
- (void)appUploadOnEnterLeaveStorebyData:(NSString *)postData
                                      md5:(NSString *)md5
                               notifyName:(NSString *)notifyName
{
    LogTrace();
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:notifyName 
                  Md5:md5];

}


/*
 *离店补录
 */
- (NSString*)appUploadUnLeavedStore:(WSInoutStoreObject*)inOutStoreObj notifyName:(NSString *)notifyName
{
    LogTrace();
    if (!inOutStoreObj) {  return nil; }
    NSString *postData = [JSONBuilder buildUnleavedStore:inOutStoreObj srid:nil];

    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:nil];
    
    return postData;
}

- (void)uploadProdGridedatasByFuncs:(WSFuncsBean *)funcs
                           HasPhoto:(BOOL)hasPhoto
                              datas:(NSArray *)datas
                            dataIDs:(NSArray *)dataIDs
                              Store:(WSStoreBean *)aStore
                            dateTyp:(NSString *)dateTyp
                                md5:(NSString *)md5
                         notifyName:(NSString *)notifyName
                               memo:(NSString *)memo
                          otherInfo:(NSDictionary *)aDicOtherInfo{
    LogTrace();
    NSString *postData = [JSONBuilder buildProdGrideDataByFuncs:funcs
                                                        isPhoto:hasPhoto?YES:NO
                                                          datas:datas
                                                        dataIDs:dataIDs
                                                          Store:aStore
                                                            md5:md5
                                                           memo:memo
                                                      otherInfo:aDicOtherInfo];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:notifyName 
                  Md5:md5];

}

- (void)uploadAcvtProdGridedatasByFc:(NSString *)fc
                              fv:(NSString *)fv
                          params:(NSArray *)aParamArray
                         isPhoto:(BOOL)isPhoto
                           datas:(NSArray *)datas
                         dataIDs:(NSArray *)dataIDs
                           Store:(WSStoreBean*)aStore
                             md5:(NSString *)md5
                      notifyName:(NSString *)notifyName {
    LogTrace();
    NSString *postData = [JSONBuilder buildAcvtProdGrideDataByFc:fc
                                                          fv:fv
                                                      params:aParamArray
                                                     isPhoto:isPhoto
                                                       datas:datas
                                                     dataIDs:dataIDs
                                                       Store:aStore
                                                         md5:md5];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
    
}

- (void)uploadAcvtProdGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName
                             acvtMD5:(NSString *)acvtMD5{
    LogTrace();
    NSString *postData = [JSONBuilder buildAcvtProdGrideDataByFc:fc
                                                              fv:fv
                                                          params:aParamArray
                                                         isPhoto:isPhoto
                                                           datas:datas
                                                         dataIDs:dataIDs
                                                           Store:aStore
                                                             md5:md5
                                                         acvtMD5:acvtMD5];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}


- (void)uploadAcvtDictGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName
{
    LogTrace();
    [self uploadAcvtDictGridedatasByFc:fc
                                    fv:fv
                                params:aParamArray
                               isPhoto:isPhoto
                                 datas:datas
                               dataIDs:dataIDs
                                 Store:aStore
                                   md5:md5
                            notifyName:notifyName
                               acvtMD5:nil];
    
}

- (void)uploadAcvtDictGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName
                             acvtMD5:(NSString *)acvtMD5{
    LogTrace();
    NSString *postData = [JSONBuilder buildAcvtDictGrideDataByFc:fc
                                                              fv:fv
                                                          params:aParamArray
                                                         isPhoto:isPhoto
                                                           datas:datas
                                                         dataIDs:dataIDs
                                                           Store:aStore
                                                             md5:md5
                                                         acvtMD5:acvtMD5];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
    
}

- (void)uploadSalesPersonInfoGridedatasByFuncs:(WSFuncsBean *)funcs
                  HasPhoto                    :(BOOL) hasPhoto
                  datas                       :(NSArray *)datas
                  dataIDs                     :(NSArray *)dataIDs
                  Store                       :(WSStoreBean *)aStore
                  dateTyp                     :(NSString *)dateTyp
                  md5                         :(NSString *)md5
                  notifyName                  :(NSString *)notifyName
                  memo                        :(NSString *)memo
                  otherInfo                   :(NSDictionary *)aDicOtherInfo

{
    LogTrace();
    return [self uploadSalesPersonInfoGridedatasByFuncs:funcs HasPhoto:hasPhoto datas:datas dataIDs:dataIDs Store:aStore dateTyp:dateTyp md5:md5 notifyName:notifyName memo:memo otherInfo:aDicOtherInfo sendBackData:nil];
}

- (void)uploadSalesPersonInfoGridedatasByFuncs:(WSFuncsBean *)funcs
                  HasPhoto                    :(BOOL) hasPhoto
                  datas                       :(NSArray *)datas
                  dataIDs                     :(NSArray *)dataIDs
                  Store                       :(WSStoreBean *)aStore
                  dateTyp                     :(NSString *)dateTyp
                  md5                         :(NSString *)md5
                  notifyName                  :(NSString *)notifyName
                  memo                        :(NSString *)memo
                  otherInfo                   :(NSDictionary *)aDicOtherInfo
                                  sendBackData:(id) sendBackData
{
    LogTrace();
    NSString *postData = [JSONBuilder buildSalesPersonInfoGrideDataByFuncs:funcs
                                                                   isPhoto:hasPhoto?YES:NO
                                                                     datas:datas
                                                                   dataIDs:dataIDs
                                                                     Store:aStore
                                                                       md5:md5
                                                                      memo:memo
                                                                 otherInfo:aDicOtherInfo
                                                              sendBackData:sendBackData];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}


- (void)uploadProdGridedatasforPadByFuncs:(WSFuncsBean *)funcs
                                 HasPhoto:(BOOL)hasPhoto
                                    datas:(NSArray *)datas
                                  dataIDs:(NSArray *)dataIDs
                                    Store:(WSStoreBean *)aStore
                                  dateTyp:(NSString *)dateTyp
                                      md5:(NSString *)md5
                               notifyName:(NSString *)notifyName
                                     memo:(NSString *)memo{
    LogTrace();
    NSString *postData = [JSONBuilder buildProdGrideDataforPadByFuncs:funcs
                                                              isPhoto:hasPhoto?YES:NO
                                                                datas:datas
                                                              dataIDs:dataIDs
                                                                Store:aStore
                                                                  md5:md5
                                                                 memo:memo];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
    
}


- (void)uploadDisplayPhotoDatasbyFuncs:(WSFuncsBean *)funcs
                              HasPhoto:(BOOL)hasPhoto
                                 Store:(WSStoreBean *)aStore
                                 cells:(NSArray *)cells
                                   md5:(NSString *)md5
                            notifyName:(NSString *)notifyName {
    LogTrace();
    if (funcs == nil) return;
        
    NSString *postData = [JSONBuilder buildDisplayPhotoDatasbyFuncs:funcs
                                                           HasPhoto:hasPhoto
                                                              Store:aStore
                                                              cells:cells
                                                                md5:md5
                                                         notifyName:notifyName];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:notifyName 
                  Md5:md5];
    
}

- (void)appUploadAcvtData:(NSString *)postData
               notifyName:(NSString *)notifyName
                      md5:(NSString *)md5
{
    LogTrace();
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
    
}

- (void)appUploadNewProductbyFuncs:(WSFuncsBean *)funcs
                              acvt:(WSAcvtBean *)acvt
                          HasPhoto:(BOOL)hasPhoto
                           Product:(WSNewProductBean *)aProduct
                             cells:(NSDictionary *)cells
                               md5:(NSString *)md5
                        notifyName:(NSString *)notifyName
                            Others:(NSDictionary*)aOthers {
    LogTrace();
    if(funcs==nil|| acvt == nil)
        return;
    NSString *postData = [JSONBuilder buildNewProductbyFuncs:funcs 
                                                      acvt:acvt
                                                   isPhoto:hasPhoto 
                                                     Product:aProduct 
                                                     cells:cells 
                                                       md5:md5
                                                    Others:aOthers];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:notifyName 
                  Md5:md5];    
}

//add by caozhenguo
- (void)appUploadOtherDutybyFuncs:(WSFuncsBean *)funcs
                             cols:(NSArray *)cols
                            datas:(NSArray *)datas
                          dataIDs:(NSArray *)dataIDs
                        dateBegin:(NSString *)dateBegin
                          dateEnd:(NSString *)dateEnd
                       notifyName:(NSString *)notifyName
                             memo:(NSString*)memo
                              md5:(NSString *)md5
{
    LogTrace();
    NSString *postData = [JSONBuilder buildbuildAttendancebyFuncs:funcs
                                                             cols:cols
                                                            datas:datas
                                                          dataIDs:dataIDs
                                                        dateBegin:dateBegin
                                                          dateEnd:dateEnd
                                                             memo:memo
                                                              md5:md5];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD
           NotifyName:notifyName 
                  Md5:md5];
    
}


- (void)appUploadOnPhotoWithFilePath:(NSString *)filePath
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID{
    LogTrace();
    
    NSDictionary *params = [JSONBuilder buildImageParamsDicByImageID:imageID];
    
    [self uploadImageWithFilePath:filePath
                           params:params
                              url:URL_IMAGEUPLOAD
                       notifyName:aNotify
                              md5:md5];
    
}

- (void)appUploadOnPhotoWithFilePath:(NSString *)filePath
                           imageType:(NSString *)imageType
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID
{
    LogTrace();
    
    
    NSDictionary *params = [JSONBuilder buildImageParamsDicByImageID:imageID andPhotoTypeId:imageType];
    
    [self uploadImageWithFilePath:filePath
                           params:params
                              url:URL_IMAGEUPLOAD
                       notifyName:aNotify
                              md5:md5];
    
}


//MSG
-(void)appUploadMSG
{
    LogTrace();
    NSString* postData = [JSONBuilder buildMSG];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:UPDATA_MSG 
                  Md5:nil];
    
}

- (void)appUploadQueryMsg {
    LogTrace();
    NSString* postData = [JSONBuilder buildQueryMsg];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:UPDATA_MSG
                  Md5:nil];

}

//outPlanUpdata
-(void)appUpdataOutPlanInfo:(WSStoreBean*)store 
                 notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:@"allplanstoreotherinfoontime" forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];//辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台

    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:notifyName 
                  Md5:nil];
}

//add 添加主管拜访门店的获取 by yanguoshuai at 2012－03－27
-(void)appUpdataManagerInfo:(WSStoreBean*)store
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:[NSString stringNotNilWithValue:objId] forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    //辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台
    if ([objId isEqualToString:@"allplanstoreotherinfoontime"]) {
        [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    }
    
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE
           NotifyName:notifyName 
                  Md5:nil];
}
-(void)appUpdataManagerInfo:(WSStoreBean*)store
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:[NSString stringNotNilWithValue:objId] forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    //辉瑞etrip增加，后台说接口改了，随访时，当前登录人的id为loginEmpId，empId是下属id。当不是随访时，两个都传当前登录人id,如有问题请找后台
    if ([objId isEqualToString:@"allplanstoreotherinfoontime"]) {
        [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"loginEmpId"];
    }
    if (stype ) {
        [outPlan setValue:[NSString stringNotNilWithValue:stype]  forKey:@"styp"];
    }
    
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}

- (void)fetchHospitalInfo:(WSStoreBean *)store notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:store.Id] forKey:@"storeId"];
    [outPlan setObject:@"spestoreinfo" forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
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
 
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:notifyName 
                  Md5:nil];
    
}

-(void)appUpdataWorkReport:(WSFuncsBean *)func Data:(NSArray*)datas NotifyName:(NSString*)notifyName
{
    LogTrace();
    NSString *postData = [JSONBuilder buildWorkReportbyFuncs:func Data:datas];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD
           NotifyName:notifyName 
                  Md5:nil];
    
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
    
    NSString *dataInfo = [NSString stringWithFormat:@"[url:%@]  [postData:%@]  [md5:%@] [notify:%@] [dataType : %@]",l_url,l_postData,l_MD5,l_notify,dataType];
    
    if (dataType && [dataType isEqualToString:kOfflineTableDataType_P]) {
        if ([[l_postData JSONValue] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[l_postData JSONValue]] ;
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
                    
                    LogError(@"%@ 由于获取照片为空上传数据失败，已经将此数据记录为 ‘错误数据’  %@",[error localizedDescription],object);
                    
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
                LogError(@" %@ 由于获取照片为空上传数据失败，已经将此数据记录为 ‘错误数据’  %@",[error localizedDescription],dataInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[WSOffLineUploadTable sharedTable] updateUploadFlagErrorWithImageIndex:l_MD5 notifyId:l_notify];
                });
                return;
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uploadDatas:[l_postData dataUsingEncoding:NSUTF8StringEncoding]
                      Url:l_url
               NotifyName:l_notify
                      Md5:l_MD5];
    });
    LogInfo(@"成功获取图片数据并准备上传 %@",dataInfo);
}


-(void)uploadComment:(NSString*)aComment
          NotifyName:(NSString*)aNotifyName
               MSGID:(NSString*)aMsgId
            Receiver:(NSArray*)aReceive
{
    LogTrace();
    NSString *postData = [JSONBuilder buildCommentWithContent:aComment
                                                        MSGID:aMsgId
                                                    Receivers:aReceive];
    //NSLog(@"postdata is %@",postData);
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:aNotifyName 
                  Md5:nil];
    
}
-(void)uploadComment:(NSString*)aComment
          NotifyName:(NSString*)aNotifyName
               MSGID:(NSString*)aMsgId
            Receiver:(NSArray*)aReceive
            AcvtData:(NSString *)aAcvtData
                 Md5:(NSString *)aMd5
{
    
    LogTrace();
    NSString *postData = [JSONBuilder buildCommentWithContent:aComment
                                                        MSGID:aMsgId
                                                    Receivers:aReceive
                                                     AcvtData:aAcvtData];
    //NSLog(@"postdata is %@",postData);
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:aNotifyName
                  Md5:aMd5];
    
}

-(void)getMSGWithId:(NSString*)aMsgId
         NotifyName:(NSString*)aNotifyName

{
    LogTrace();
    NSString *postData = [JSONBuilder buildGetPartnersCommentsWithID:aMsgId];
    //NSLog(@"postdata is %@",postData);
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:aNotifyName 
                  Md5:nil];
}

-(void)uploadBackGroundGPSWithLocation:(WSLocationDescribe *)locatinDescribe
                            NotifyName:(NSString*)aNotifyName
{
    LogTrace();
    if (locatinDescribe.location == nil) {
        return;
    }
    NSString *postData = [JSONBuilder buildBackGroundGPSWithLocation:locatinDescribe];
    
    [[WSOfflineDataManager sharedInstance] insertUploadDate:postData URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:aNotifyName];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:aNotifyName
                  Md5:@""];
}

-(void)uploadBeaconWithUUid:(NSString*)beaconUuid
                withStoreId:(NSString*)storeId
                 NotifyName:(NSString*)aNotifyName
{
    if (beaconUuid) {
        if (!aNotifyName) {
            aNotifyName = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [JSONBuilder gen_uuid]];
        }
        NSString *postData = [JSONBuilder buildBeaconWithUUid:beaconUuid withStoreId:storeId];
        
        [[WSOfflineDataManager sharedInstance] insertUploadDate:postData URL:URL_UPLOAD MD5:@"" IsPhoto:NO NotifyName:aNotifyName];
        [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                      Url:URL_UPLOAD
               NotifyName:aNotifyName
                      Md5:@""];
    }
}


//发送建议
-(void)uploadSendSuggestion:(NSDictionary*)aSelectSugs Notify:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [JSONBuilder buildSendSuggestionWithTitle:aSelectSugs];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:aNotifyName 
                  Md5:nil];
    
}

//查消息列表
-(void)getSuggestionList:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [JSONBuilder buildGetSuggestionTitleAndContent];
    //NSLog(@"postData is %@",postData);
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:aNotifyName 
                  Md5:nil];
}

//发送回复消息内容
-(void)postSuggestionReply:(NSDictionary*)aSelectSugs
                    Notify:(NSString*)aNotifyName
                      SUGs:(WSSugReplyBeanArray*)aSugBeanArray
{
    LogTrace();
    NSString* postData = [JSONBuilder buildSendSuggestionReplay:aSelectSugs SUGs:aSugBeanArray];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:aNotifyName 
                  Md5:nil];
    
}

//查消息回复
-(void)getSuggestionReplyList:(NSString*)aMsgId Notify:(NSString*)aNotifyName
{
    LogTrace();
    NSString* postData = [JSONBuilder buildGetSuggestionReplyListWithMsgId:aMsgId];

    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE 
           NotifyName:aNotifyName 
                  Md5:nil];
}

-(void)PostModifyStoreInfo:(NSDictionary*)aDic NotifyName:(NSString*)aNotifyName Store:(WSStoreBean*)aStore
{
    LogTrace();
    NSString* postData = [JSONBuilder buildModifyStoreInfo:aDic Store:aStore];

    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:aNotifyName 
                  Md5:nil];
    
}

- (void)uploadDictByFuncs:(WSFuncsBean *)funcs
                 HasPhoto:(BOOL)hasPhoto
                    datas:(NSArray *)datas
                  dataIDs:(NSArray *)dataIDs
                    Store:(WSStoreBean *)aStore
                  dateTyp:(NSString *)dateTyp
                      md5:(NSString *)md5 
               notifyName:(NSString *)notifyName
                     memo:(NSString *)memo
                otherInfo:(NSDictionary *)aDicOtherInfo{
    LogTrace();
    NSString *postData = [JSONBuilder buildDictDetailbyFuncs:funcs 
                                                     isPhoto:hasPhoto?YES:NO 
                                                       datas:datas 
                                                     dataIDs:dataIDs 
                                                       Store:aStore
                                                         md5:md5 
                                                        memo:memo
                                                   otherInfo:aDicOtherInfo];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:notifyName 
                  Md5:md5];
}
- (void)uploadDictforPadByFuncs:(WSFuncsBean *)funcs
                       HasPhoto:(BOOL)hasPhoto
                          datas:(NSArray *)datas
                        dataIDs:(NSArray *)dataIDs
                          Store:(WSStoreBean *)aStore
                        dateTyp:(NSString *)dateTyp
                            md5:(NSString *)md5
                     notifyName:(NSString *)notifyName
                           memo:(NSString *)memo{
    LogTrace();
    NSString *postData = [JSONBuilder buildDictDetailforPadbyFuncs:funcs
                                                           isPhoto:hasPhoto?YES:NO
                                                             datas:datas
                                                           dataIDs:dataIDs
                                                             Store:aStore
                                                               md5:md5
                                                              memo:memo];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5];
}
//add 主管检查功能 yanguoshuai at 2012－03－15
- (void)appUploadCheckKey:(NSString *)l_key 
              notifyName:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *login = [NSMutableDictionary dictionary];
    [login setObject:[NSString stringNotNilWithValue:l_key] forKey:KEY];
    [login setObject:[NSString stringNotNilWithValue:empId] forKey:EMPID];
    [login setObject:@"NoCellId" forKey:CELLID];
    [login setObject:@"lowerlevelstore" forKey:OBJID];
    
    [self uploadDatas:[[login JSONRepresentation]dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE
           NotifyName:notifyName 
                  Md5:nil];
}

-(void)performanceInfoRefreshWithNotifyName:(NSString*)aNotifyName
{
    LogTrace();
    NSMutableDictionary *postDictionary = [NSMutableDictionary dictionary];
    [postDictionary setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey: @"empId"];
    [postDictionary setObject:@"empinforefresh" forKey:@"objId"];
    NSString *postData = [postDictionary JSONRepresentation];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}

- (void)postVistHelpOutPlanQuery:(NSDictionary *)aDic {
    LogTrace();
    /*
    NSString* postData = [JSONBuilder buildCustomerRequest:aDic];
     */
    NSString * postData = [JSONBuilder buildOutPlanOfHelpVistRequst:aDic];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:[aDic objectForKey:NT_NAME] Md5:nil];
}

-(void)postCustomerQuery:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [JSONBuilder buildCustomerRequest:aDic];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:[aDic objectForKey:NT_NAME] Md5:nil];
}

// 辉瑞医院使用
- (void)QueryHospitalInfoWith:(NSDictionary *)aDic
{
    LogTrace();
    NSString* postData = [aDic JSONRepresentation];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:[aDic objectForKey:NT_NAME] Md5:nil];
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
    
    NSString *postData = [dic JSONRepresentation];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
}

//- (void)uploadMarketActityDatas:(NSDictionary *)aDicData acvt:(WSAcvtBean *)acvt functionBean:(WSFuncsBean *)funcs notifyName:(NSString *)aNotifyName
//{
//    NSString* postData = [JSONBuilder buildMarketActivityWithDic:aDicData acvtBean:acvt functionBean:funcs];
//    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
//}

- (void)uploadMarketActityDatas:(NSString *)aPostData notifyName:(NSString *)aNotifyName
{
    [self uploadDatas:[aPostData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPLOAD/*URL_UPDATE*/ NotifyName:aNotifyName Md5:nil];
}

- (void)uploadPfizerBusinessDatas:(NSDictionary *)aDicData functionBean:(WSFuncsBean *)funcs withMd5:(NSString *)aMd5 notifyName:(NSString *)aNotifyName
{
     LogTrace();
    NSString *postData = [JSONBuilder buildPfizerBusinessStringWithDic:aDicData functionBean:funcs withMd5:aMd5];   
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
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
    
    NSString *postData = [dic JSONRepresentation];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
}


-(void)postCustomerStoresQuery:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [JSONBuilder buildCustomerStoreRequest:aDic];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:[aDic objectForKey:NT_NAME] Md5:nil];
}

-(void)requestMsgReceivers:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [JSONBuilder buildMSGReceivers:aDic];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:[aDic objectForKey:NT_NAME] Md5:nil];
}

-(void)uploadExceptionInfo:(NSDictionary*)aDic
{
    LogTrace();
    NSString* postData = [JSONBuilder buildExceptionInfo:aDic];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] Url:URL_EXCEPTION NotifyName:NT_EXPECTION Md5:nil];

}

-(void)uploadVideoDatas:(NSData*)aPostData 
                    Url:(NSString*)aUrl 
             NotifyName:(NSString*)aNotifyName
                    Md5:aMd5
{
    LogTrace();
    HttpWebAction *hwa = [HttpWebAction shareInstance];
    [hwa startVideoJSONStringbyPost: aUrl
                           postData: aPostData
                         notifyName: aNotifyName
                                MD5:aMd5];
}


-(void)uploadImageWithFilePath:(NSString *)filePath
                        params:(NSDictionary *)params
                           url:(NSString*)aUrl
                    notifyName:(NSString*)aNotifyName
                           md5:aMd5
{
    LogTrace();
    HttpWebAction *hwa = [HttpWebAction shareInstance];
    
    [hwa startImageJSONStringbyPost:aUrl
                             params:params
                           filePath:filePath
                         notifyName:aNotifyName
                                MD5:aMd5];
}


//添加获取经销商的节点
//add 添加主管拜访门店的获取 by yanguoshuai at 2012－03－27
-(void)appUpdataDealterInfo:(NSString *)notifyName
{
    LogTrace();
    NSString* empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:@"dealerstore" forKey:@"objId"];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPDATE
           NotifyName:notifyName 
                  Md5:nil];
}
//上传拜访计划 2012－06－29 yanguoshuai
- (void)uploadStoreSchedule:(WSArrangeScheduleViewController *)vc {
    LogTrace();
    NSString *postData = [JSONBuilder buildStoreScheduleData:vc];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding] 
                  Url:URL_UPLOAD 
           NotifyName:UPDATAFINISH_NOTIFY
                  Md5:nil];
}

-(void)fetchStoreSchedule:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *postData = [JSONBuilder buildAllStoreScheduleRequest:aDic];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}

-(void)fetchCalendarDateDone:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *postData = [JSONBuilder buildCalendarRequest:aDic];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}


- (void)updateSurrundingStores:(NSString *)aEmpId
                  withLatitude:(double)aLatitude
                 withLongitude:(double)aLongitude
                withNotifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSMutableDictionary *updateInfo = [[NSMutableDictionary alloc] init];
    [updateInfo setObject:[NSString stringNotNilWithValue:aEmpId] forKey:@"empId"];
    [updateInfo setObject:[NSNumber numberWithDouble:aLatitude] forKey:GPS_LAT];
    [updateInfo setObject:[NSNumber numberWithDouble:aLongitude] forKey:GPS_LON];
    [updateInfo setObject:@"neighborStore" forKey:APPDATA_OBJID];
    NSData *postData = [[updateInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    [self uploadDatas:postData Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
}


- (void)search:(NSString *)date
    notifyName:(NSString *)notify
{
    LogTrace();
    // modify at 2013 -12 - 25
    NSMutableDictionary *searchInfo = [NSMutableDictionary dictionary];
    [searchInfo setObject:[NSString stringNotNilWithValue:date] forKey:@"docDate"];
    [searchInfo setObject:[NSString stringNotNilWithValue:[WSAppData getObjectbyKey:APPDATA_EMPID]] forKey:APPDATA_EMPIDBIGI];
    [searchInfo setObject:@"callPlan" forKey:APPDATA_OBJID];
    NSLog(@"%@", [searchInfo JSONRepresentation]);
    
    [self uploadDatas:[[searchInfo JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notify
                  Md5:nil];
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
    
    NSString *datas = [geo JSONRepresentation];
    
    [self uploadDatas:[datas dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}

- (void)appUpdataSalespersonInfoWithEmpid:(NSString *)empId
                               notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *outPlan = [NSMutableDictionary dictionary];
    [outPlan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [outPlan setObject:@"pminpost" forKey:@"objId"];
    [outPlan setObject:@"pminpost" forKey:@"filter"];
    
    [self uploadDatas:[[outPlan JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:notifyName
                  Md5:nil];
}

// ----------------------- 数据上传过程优化 -----------------------
- (void)appUploadOnAcvtbyFuncs:(WSFuncsBean *)funcs
                          acvt:(WSAcvtBean *)acvt
                      HasPhoto:(BOOL)hasPhoto
                         Store:(WSStoreBean *)aStore
                         cells:(NSDictionary *)cells
                           md5:(NSString *)md5
                    notifyName:(NSString *)notifyName
                        Others:(NSDictionary*)aOthers
                withUploadType:(WCDatasUploadType)aUploadType
{
    LogTrace();
    if(funcs==nil|| acvt == nil)
        return;
    NSString *postData = [JSONBuilder buildActivitybyFuncs:funcs
                                                      acvt:acvt
                                                   isPhoto:hasPhoto
                                                     Store:aStore
                                                     cells:cells
                                                       md5:md5
                                                    Others:aOthers];
    
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPLOAD
           NotifyName:notifyName
                  Md5:md5
       withUploadType:aUploadType];
    
}

-(void)uploadDatas:(NSData*)aPostData
               Url:(NSString*)aUrl
        NotifyName:(NSString*)aNotifyName
               Md5:aMd5
    withUploadType:(WCDatasUploadType)aUploadType
{
    LogTrace();
    HttpWebAction *hwa = [HttpWebAction shareInstance];
    [hwa startJSONStringbyPost:aUrl
                      postData:aPostData
                    notifyName:aNotifyName
                           MD5:aMd5
                withUploadType:aUploadType];
}

- (void)appFetchServerTime:(NSString *) aNotifyName
{
    LogTrace();
    HttpWebAction *hwa = [HttpWebAction shareInstance];
    [hwa startJSONStringbyPost: URL_GETSERVERTIME
                      postData: nil
                    notifyName: aNotifyName
                           MD5: nil];
}

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
{
    LogTrace();
    NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
    if ([username isKindOfClass:[NSString class]])
    {
        [loginDic setObject:username forKey:USERNAME];
    }
    
    // 判断是否加密，先用后台配置串里给的值，如果没有则用打包时配置的（ConfigFile中PasswordEncrypt字段）
    NSString *password_encrypt = [[NSUserDefaults standardUserDefaults] objectForKey:PasswordEncrypt];
    if (!password_encrypt)
    {
        password_encrypt = [WSPlistHelper valueForKey:PasswordEncrypt withPlistName:kConfilgFileName];
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
    id versionCode = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleVersion"];
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
    
    NSNumber *exitAppStatus = (NSNumber *)[FileManager getUserDefaults:EXIT_APP_STATUS_USERDEFAULT_KEY];
    if (exitAppStatus)
    {
        [loginDic setObject:exitAppStatus forKey:@"exitAppStatus"];
    }
    
    NSLog(@"%@", URL_GETROOTCONFIG);

    LogInfo(@"程序开始登陆并请求配置数据");
    NSString *rootConfigStart = [WSCurrentTime getServerTime];
    [[NSUserDefaults standardUserDefaults] setObject:rootConfigStart forKey:@"appGetRootConfig_start"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self uploadDatas:[[loginDic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_GETROOTCONFIG
           NotifyName:notifyName
                  Md5:nil];
    
}

- (void)appUpdataOrderInfoEmpId:(NSString *)aEmpId
                     notifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:[NSString stringNotNilWithValue:aEmpId] forKey:@"empId"];
    [postDic setObject:@"ordLst" forKey:@"objId"];
    
    [self uploadDatas:[[postDic JSONRepresentation]
                       dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}


- (void)appUploadData:(NSDictionary *)aDic
           notifyName:(NSString *)aNotifyName
{
    LogTrace();
    /*  Zheng Jiepeng 2013/07/02
     *  向服务器发送 请求数据
     *  请求参数 放在 aDic 中
     *  不需要每次都实现一个特定方法
     */
    NSString *postData = [aDic JSONRepresentation];
    [self uploadDatas:[postData dataUsingEncoding:NSUTF8StringEncoding]
                  Url:URL_UPDATE
           NotifyName:aNotifyName
                  Md5:nil];
}

- (void)fetchOutplanStoreWithGeographicId:(NSString *)aGeoId withObjId:(NSString *)aObjId withNotifyName:(NSString *)aNotifyName
{
    LogTrace();
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSMutableDictionary *outplan = [NSMutableDictionary dictionary];
    [outplan setObject:[NSString stringNotNilWithValue:aObjId] forKey:@"objId"];
    [outplan setObject:[NSString stringNotNilWithValue:empId] forKey:@"empId"];
    [outplan setObject:[NSString stringNotNilWithValue:aGeoId] forKey:@"geoId"];
    
    [self uploadDatas:[[outplan JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding] Url:URL_UPDATE NotifyName:aNotifyName Md5:nil];
}


- (void)sendReadedMessageRequestWithMsgId:(NSString *)aMsgId andNotifyName:(NSString *)aNotifyName andMD5:(NSString *)aMd5
{
    LogTrace();
    NSString *empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    //isSync
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"isSync"];
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
    
    NSString *strPost = [dic JSONRepresentation];
    NSData *postData = [strPost dataUsingEncoding:NSUTF8StringEncoding];
    [self uploadDatas:postData Url:URL_UPLOAD NotifyName:aNotifyName Md5:aMd5];
}

@end
