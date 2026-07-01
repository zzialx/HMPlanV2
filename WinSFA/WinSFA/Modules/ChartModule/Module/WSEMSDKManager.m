//
//  WSEMSDKManager.m
//  WinSFA
//
//  Created by huzepei on 16/12/19.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSEMSDKManager.h"
#import "EMSDK.h"
#import "EaseUI.h"
#import "WSChartConst.h"
#import "WSSqliteUtil.h"
#import "WSServerIPList.h"
//#import <OBSS3/OBSS3.h>
#import "NSString+ServerUrl.h"

//#import "EaseMob.h"

#define FILEPATH   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

static id _instance;

@implementation WSEMSDKManager

#pragma mark
#pragma mark 类函数
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)init{
    if(self=[super init]){
        _isLoginSucess=NO;
        _isLogin=NO;
        _loginNameDic=[[NSMutableDictionary alloc]init];
        [_loginNameDic setObject:@"8001" forKey:@"test1"];
        [_loginNameDic setObject:@"8002" forKey:@"test2"];
    }
    return self;
}

#pragma mark
#pragma mark 功能函数
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //1116161209178529#winchannltest1
    NSString * keyvalue=[WSPlistHelper valueForKey:kEaseMobAppKey withPlistName:kConfilgFileName];
    // Override point for customization after application launch.
    EMOptions *options = [EMOptions optionsWithAppkey:keyvalue];
    //options.apnsCertName = @"istore_dev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [[EaseSDKHelper shareHelper] hyphenateApplication:application
                        didFinishLaunchingWithOptions:launchOptions
                                               appkey:keyvalue
                                         apnsCertName:nil
                                          otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    return YES;
}

#pragma mark
#pragma mark 接口

-(void)loginUserName:(NSString*)username PassWord:(NSString*)password completion:(void (^)(NSString *aUsername, EMError *aError))aCompletionBlock{
    if(username==nil || username.length==0)
        return;
    
    [[EMClient sharedClient] loginWithUsername:username password:password completion:^(NSString *aUsername, EMError *aError) {
        aCompletionBlock(aUsername,aError);
    }];
}
-(void)loginChartSys{
    
    //取得登录账号
    _isLogin=YES;
    WSUserInfo * loginUser=[self getUserInfo];
    NSString * charName=loginUser.wschatID;
    NSString * charPassWord=@"winchannel@sfa";
    // MSTD-7226 换线注册规则  -- add by zhiqing
    if(charName==nil || charName.length==0){
        //登陆者无聊天账号，且有通知发送功能，则使用该用户的账户登录，以兼容以前的通知发送功能
        NSDictionary *loginEaseMob = [WSAppData getObjectbyKey:IS_LOGIN_EASEMOB];
        NSString *loginEaseMobString = [loginEaseMob objectForKey:IS_LOGIN_EASEMOB];
        if ([loginEaseMobString isEqualToString:@"1"]) {
            charName=[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
        }
    }else{
        if(loginUser.wsheadImageURL){
            [[NSUserDefaults standardUserDefaults] setObject:[loginUser.wsheadImageURL buildupUrl] forKey:WS_CHARTMODULE_USERHEADIMAGE];
        }
        NSString * nickname= [WSAppData getObjectbyKey:EMPNAME];
        if(nickname && nickname.length>0){
            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:WS_CHARTMODULE_USERNICKNAME];
        }
    }

    LogInfo(@"环信开始登录，%@，%@", charName, charPassWord);
    [self loginUserName:charName PassWord:charPassWord completion:^(NSString *aUsername, EMError *aError) {
        if(!aError){
            LogInfo(@"环信登录成功，%@",aUsername);
            [[NSUserDefaults standardUserDefaults] setObject:charName forKey:WS_CHARTMODULE_USERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:charPassWord forKey:WS_CHARTMODULE_PASSWORD];
            if(loginUser.wsheadImageURL){
                [[NSUserDefaults standardUserDefaults] setObject:[loginUser.wsheadImageURL buildupUrl] forKey:WS_CHARTMODULE_USERHEADIMAGE];
            }
            
            
            NSString * nickname= [WSAppData getObjectbyKey:EMPNAME];
            if(nickname && nickname.length>0){
                [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:WS_CHARTMODULE_USERNICKNAME];
            }
            _isLoginSucess=YES;
            
            //MSTD-6688 暂时性方案(每次登陆成功后进行7天数据筛选)
            [self dealWithMessageFor7day];
        }
        else
        {
            LogInfo(@"环信登录失败，进行注册，%@",aUsername);
            if(aError.code==EMErrorUserNotFound){
//                NSString *Uploading = NSLocalizedString(@"Unregistered EM", nil);
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:Uploading  tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
                //如果没有此用户，则注册该用户
                EMError *Reginsterror = [[EMClient sharedClient] registerWithUsername:charName password:charPassWord];
                if(!Reginsterror){
                    //注册成功，进行登录
                    LogInfo(@"环信注册成功，进行登录，%@",aUsername);
                   EMError *loginsterror =[[EMClient sharedClient] loginWithUsername:charName password:charPassWord];
                    if(!loginsterror){
                        LogInfo(@"环信登录成功，%@",aUsername);
                        [[NSUserDefaults standardUserDefaults] setObject:charName forKey:WS_CHARTMODULE_USERNAME];
                        [[NSUserDefaults standardUserDefaults] setObject:charPassWord forKey:WS_CHARTMODULE_PASSWORD];
                        NSString * nickname= [WSAppData getObjectbyKey:EMPNAME];
                        if(nickname && nickname.length>0){
                            [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:WS_CHARTMODULE_USERNICKNAME];
                        }
                        if(loginUser.wsheadImageURL){
                            [[NSUserDefaults standardUserDefaults] setObject:[loginUser.wsheadImageURL buildupUrl] forKey:WS_CHARTMODULE_USERHEADIMAGE];
                        }
                        _isLoginSucess=YES;
                    }else{
                        _isLoginSucess=NO;
                    }
                }else{
                    LogInfo(@"环信注册失败，%@",aUsername);
                    _isLoginSucess=NO;
                }
            }
        }
    }];
}

- (void)logout:(BOOL)aIsUnbindDeviceToken completion:(void (^)(EMError *aError))aCompletionBlock{
    
    [[EMClient sharedClient] logout:aIsUnbindDeviceToken completion:^(EMError *aError) {
        aCompletionBlock(aError);
    }];
}

-(BOOL)getLoginState{
    return _isLoginSucess;
}
-(NSString *)getLoginName{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERNAME];
}
-(NSString *)getChatNickName{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERNICKNAME];
}
-(NSString *)getChatHeadImageLRL{
    return  [[NSUserDefaults standardUserDefaults] objectForKey:WS_CHARTMODULE_USERHEADIMAGE];
}

-(WSUserInfo*) getUserInfoWithStoreID:(NSString*)storeID andEmpId:(NSString *)storeEmpId{
    // SFA-10351 
    NSString  *empIdSql = @"";
    if (storeEmpId.length > 0) {
        empIdSql = [NSString stringWithFormat:@"and (bsad.gen_id is null or (bsad.gen_id ='%@'))",storeEmpId];
    }
    NSString * query=[NSString stringWithFormat:@"select acvt_qst_answer,baq.qstCod from base_store_acvt_dis bsad join base_acvt ba on ba._id=bsad.acvtId and ba.acvtCode='empInfo' join base_acvt_qst baq on  baq.acvtId=ba._id and baq._id=bsad.acvtQstId where bsad.sid= '%@' %@",storeID,empIdSql];
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:query];
    //NSInteger TEST= rs.columnCount;
    NSMutableDictionary * resultDic=[[NSMutableDictionary alloc]init];
    while ([rs next]) {
        NSString* stringValue=[rs stringForColumnIndex:0];
        NSString* stringKey=[rs stringForColumnIndex:1];
        if(stringValue && stringValue.length>0){
            [resultDic setObject:stringValue forKey:stringKey];
        }
    }
    
    WSUserInfo * userinfo=[[WSUserInfo alloc]init];
    //用户图片
    NSString * seticon=[resultDic objectForKey:@"setIcon"];
    if(seticon && seticon.length>0){
        userinfo.wsheadImageURL=seticon;
    }
    //用户名称
    NSString * empName=[resultDic objectForKey:@"empName"];
    if(empName && empName.length>0){
        userinfo.wsname=empName;
    }
    //用户手机
    NSString * empMobile=[resultDic objectForKey:@"empMobile"];
    if(empMobile && empMobile.length>0){
        userinfo.wsphone=empMobile;
    }
    //用户聊天账号
    NSString * userChatAccount=[resultDic objectForKey:@"userChatAccount"];
    if(userChatAccount && userChatAccount.length>0){
        userinfo.wschatID=userChatAccount;
    }
    //部门管理人ID
    NSString * empDepartment=[resultDic objectForKey:@"empDepartment"];
    if(empDepartment && empDepartment.length>0){
        userinfo.wsdePartID=empDepartment;
    }
    //empID
    NSString * empId=[resultDic objectForKey:@"empId"];
    if(empId && empId.length>0){
        userinfo.wsempID=empId;
    }
    //empCode
    NSString * empCode=[resultDic objectForKey:@"empCode"];
    if(empCode && empCode.length>0){
        userinfo.wsempCode=empCode;
    }
    
    //roleName
    NSString * roleName=[resultDic objectForKey:@"roleName"];
    if(roleName && roleName.length>0){
        userinfo.wsroleName=roleName;
    }
    
    return  userinfo;
}
/*
 *函数功能：取得登录用户信息
 *参数：storeID,商店ID
 */
-(WSUserInfo*) getUserInfo{
//    SFA-17280
//    SFA葵花药业--IOS端“我的”中信息有误
    NSString * query=@"select acvt_qst_answer,newQst.qstCode from base_store_acvt_dis bsad left join (select baq.acvtId as acvtId,baq.acvtQstId as qstId,baq.qstCod as qstCode from base_acvt ba join base_acvt_qst baq on baq.acvtId = ba._id where  ba.acvtCode = 'empInfo') newQst on bsad.acvtQstId = newQst.qstId where bsad.sid IS NULL and bsad.gen_id IS NULL";
    FMResultSet *rs = [[WSFMDatebase getInstance] executeQueryWithSql:query];
    NSMutableDictionary * resultDic=[[NSMutableDictionary alloc]init];
    while ([rs next]) {
        NSString* stringValue=[rs stringForColumnIndex:0];
        NSString* stringKey=[rs stringForColumnIndex:1];
        if(stringKey && stringValue.length>0){
            [resultDic setObject:stringValue forKey:stringKey];
        }
    }
    
    WSUserInfo * userinfo=[[WSUserInfo alloc]init];
    //用户图片
    NSString * seticon=[resultDic objectForKey:@"setIcon"];
    if(seticon && seticon.length>0){
        userinfo.wsheadImageURL=seticon;
    }
    //用户名称
    NSString * empName=[resultDic objectForKey:@"empName"];
    if(empName && empName.length>0){
        userinfo.wsname=empName;
    }
    //用户手机
    NSString * empMobile=[resultDic objectForKey:@"empMobile"];
    if(empMobile && empMobile.length>0){
        userinfo.wsphone=empMobile;
    }
    //用户聊天账号
    NSString * userChatAccount=[resultDic objectForKey:@"userChatAccount"];
    if(userChatAccount && userChatAccount.length>0){
        userinfo.wschatID=userChatAccount;
    }
    //部门管理人ID
    NSString * empDepartment=[resultDic objectForKey:@"empDepartment"];
    if(empDepartment && empDepartment.length>0){
        userinfo.wsdePartID=empDepartment;
    }
    //empID
    NSString * empId=[resultDic objectForKey:@"empId"];
    if(empId && empId.length>0){
        userinfo.wsempID=empId;
    }
    
    //empCode
    NSString * empCode=[resultDic objectForKey:@"empCode"];
    if(empCode && empCode.length>0){
        userinfo.wsempCode=empCode;
    }
    
    //roleName
    NSString * roleName=[resultDic objectForKey:@"roleName"];
    if(roleName && roleName.length>0){
        userinfo.wsroleName=roleName;
    }
    
    return  userinfo;

}


-(void)clearCacheData{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_USERNICKNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_USERHEADIMAGE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_STORICONURL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_STORNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WS_CHARTMODULE_LOCALIMAGEID];
    [self logout:YES completion:^(EMError *aError) {
        //
    }];
}

-(void)checkUserIsFirstLoadAndDownLoadMessageRecord{
    
//#if __LP64__
//    NSString * flag = [[NSUserDefaults standardUserDefaults] objectForKey:IS_SUPPORT_MESSAGE_BACKUP];
//    if ([flag isEqualToString:@"1"]) {
//        NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//
//        // 同步聊天数据
//
//        OBSS3GetObjectRequest *request = [OBSS3GetObjectRequest new];
//        request.bucket = @"winsfauat";
//        request.key = [NSString stringWithFormat:@"e%@.db",empId];
//
//        OBSS3 *S3Service = [OBSS3 S3ForKey];
//        [[S3Service GetObject:request] continueWithBlock:^id(BFTask *task) {
//            NSString *errString = nil;
//            NSMutableString *resultString = [NSMutableString stringWithString:@"OBSS3GetObjectRequest:\n"];
//            if (task.error) {
//                errString = [NSString stringWithFormat:@"OBSS3GetObjectRequest failed2: [%@]",task.error];
//                LogError(@"OBSS3GetObjectRequest_Error___%@",errString);
////                 MN-3350 - ios-总经理角色登入状态100%停留，登入不成功
//                dispatch_async(dispatch_get_main_queue(), ^ {
//                    [[WSEMSDKManager sharedInstance]loginChartSys];
//                });
//
//            } else {
//                OBSS3GetObjectOutput *getObjectOutput = task.result;
//                [resultString appendString:getObjectOutput.contentType];
//                NSString *documentsDirectory = [self getFileNameString];
//                NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//                NSString * fileName = [NSString stringWithFormat:@"e%@.db",empId];
//                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//
//                NSLog(@"------%@",documentsDirectory);
//
//                dispatch_async(dispatch_get_main_queue(), ^ {
//                    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                        if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
//                            [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
//                                                      withIntermediateDirectories:YES
//                                                                       attributes:nil
//                                                                            error:nil];
//                        }
//
//                        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//
//                    }
//
//                    NSData * data = [NSData dataWithData:getObjectOutput.body];
//                    [data writeToFile:filePath atomically:YES];
//                    [[WSEMSDKManager sharedInstance]loginChartSys];
//
//                });
//
//            }
//
//            return nil;
//        }];
//
//    }else{
//        [[WSEMSDKManager sharedInstance]loginChartSys];
//
//    }
//#else
//     [[WSEMSDKManager sharedInstance] loginChartSys];
//#endif
    
    
}

-(void)uploadBackupFor7Day{

//    NSString *Uploading = NSLocalizedString(@"uploading_please_wait_prompt", nil);
//    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:Uploading  tips:nil tapTarget:self action:nil];
//    [self dealWithMessageFor7day];
//
//    NSString * documentsDirectory = [self getFileNameString];
//    NSString * empId = [WSAppData getObjectbyKey:APPDATA_EMPID];
//    NSString * fileName = [NSString stringWithFormat:@"e%@.db",empId];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
//    NSData * data = [NSData dataWithContentsOfFile:filePath];
//
//    OBSS3PutObjectRequest *request = [OBSS3PutObjectRequest new];
//    request.bucket = @"winsfauat";
//    request.key = [NSString stringWithFormat:@"e%@.db",[WSAppData getObjectbyKey:APPDATA_EMPID]];
//    request.body = data;
//    request.ACL = OBSS3ObjectCannedACLPublicReadWrite;
//    request.contentLength = [NSNumber numberWithInteger:data.length];
//
//
//    OBSS3 *S3Service = [OBSS3 S3ForKey];
//    [[S3Service PutObject:request] continueWithBlock:^id(BFTask *task) {
//
//         dispatch_async(dispatch_get_main_queue(), ^ {
//            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
//
//            NSString *string = NSLocalizedString(@"fail_upload", nil);
//            NSString *errString = nil;
//            if (task.error) {
//                errString = [self errorCodeStr:task.error.code];//见创建桶示例代码
//                if  ([errString isEqualToString:@"xml"]) {
//                    errString = [NSString stringWithFormat:@"OBSS3PutObjectRequest failed2: [%@]",task.error];
//                    LogError(@"BSS3PutObjectRequest_Error___%@",errString);
//                }
//                 [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed autoHideTime:0.5];
//            }else{
//                string = NSLocalizedString(@"upload_success", nil);
//                [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:string tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone autoHideTime:0.5];
//            }
//         });
//        return nil;
//
//    }];
    
}

-(NSString *)getFileNameString{
    NSString * fileNameString = [NSString stringWithFormat:@"/HyphenateSDK/easemobDB/"];
    
    return [NSString stringWithFormat:@"%@%@",FILEPATH,fileNameString];
}

-(void)dealWithMessageFor7day{
    //取得当前登录用户 --- 删除超过七天的数据再上传
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    for (EMConversation  *obj in conversations) {
            [obj loadMessagesStartFromId:nil count:1000 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
                for (EMMessage * subMsg in aMessages) {
                    NSLog(@"%@",subMsg);
                    NSDate * pre7day = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
                    long long timeFor7Day =  [pre7day timeIntervalSince1970] * 1000;
                    if (timeFor7Day > subMsg.localTime) {
                        [obj deleteMessageWithId:subMsg.messageId error:nil];
                    }
                }
            }];
    }
}

//根据错误码返回错误消息
-(NSString *)errorCodeStr:
(NSInteger)taskError {
    NSString *errorStr = nil;
//    switch (taskError) {
//        case OBSS3ErrorUnknown:
//            errorStr = @"OBSS3ErrorUnknown";
//            break;
//        case OBSS3ErrorBucketAlreadyExists:
//            errorStr = @"OBSS3ErrorBucketAlreadyExists";
//            break;
//        case OBSS3ErrorNoSuchBucket:
//            errorStr = @"OBSS3ErrorNoSuchBucket";
//            break;
//        case OBSS3ErrorBucketAlreadyOwnedByYou:
//            errorStr = @"OBSS3ErrorBucketAlreadyOwnedByYou";
//            break;
//        case OBSS3ErrorNoSuchKey:
//            errorStr = @"OBSS3ErrorNoSuchKey";
//            break;
//        case OBSS3ErrorNoSuchUpload:
//            errorStr = @"OBSS3ErrorNoSuchUpload";
//            break;
//        case OBSS3ErrorObjectAlreadyInActiveTier:
//            errorStr = @"OBSS3ErrorObjectAlreadyInActiveTier";
//            break;
//        case OBSS3ErrorObjectNotInActiveTier:
//            errorStr = @"OBSS3ErrorObjectNotInActiveTier";
//            break;
//
//        default:
//            errorStr = @"xml";
//            break;
//    }
    return errorStr;
}
@end
