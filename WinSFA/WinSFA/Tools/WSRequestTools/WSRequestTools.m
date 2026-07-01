//
//  WSRequestTools.m
//  WinSFA
//
//  Created by admin on 2022/10/22.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSRequestTools.h"
#import "WSRequestHelper.h"
#import "YYModel.h"
#import "WSRongCloudManager.h"
#import "SLFileManager.h"
#import "FCFileManager.h"
#import "WSInventoryModel.h"

#define VISIT_STORE_TIME_LEGNTH         @"visitStoreTimeByEmp"

#define KREQUEST_INSTORETIME            @"request_instore_timeLength"

static NSString * const BINDTOKENOBJID =   @"saveDeviceTokens";

static NSString * const CHATEXPIREDOBJID = @"checkVideoState";

static NSString * const AGREECOLLLECTOBJID = @"updateVisitPrivatePolicyLog";

static NSString * const RONGCloudTokenOBJID = @"getRongCloudTokens";

static NSString * const DISPLAYACTOBJID = @"getDisplayActivityTypeMsg";

@implementation WSRequestTools

+ (void)requestInStoreTimelengthWithNotice:(NSString *)notice block:(storeTimeLengthBlock)block{
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:APPDATA_EMPIDBIGI];
    [infoDic setObject:VISIT_STORE_TIME_LEGNTH forKey:@"objId"];
    [[WSRequestHelper shareInstance] postRequestStoreTimeLengthWithParametes:infoDic success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogInfo(@"在店时长接口返回：%@",resultDic);
        if(resultDic){
            NSDictionary * timeDic = [resultDic objectForKey:VISIT_STORE_TIME_LEGNTH];
            if(timeDic){
                NSString * visitStoreTimeByEmp_hh = [timeDic objectForKey:@"hh"];
                NSString * visitStoreTimeByEmp_mm = [timeDic objectForKey:@"mm"];
                NSString * visitStoreTimeByEmp_ss = [timeDic objectForKey:@"ss"];
                if(block){
                    block(ISNULL(visitStoreTimeByEmp_hh),ISNULL(visitStoreTimeByEmp_mm),ISNULL(visitStoreTimeByEmp_ss),@"");
                }
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(block){
                block(@"",@"",@"",response.error.titleForError);
            }
        }];

}
#pragma mark - # 路线请求
+ (void)requestStoreRouteListWithParameters:(NSDictionary*)parameters success:(getRouteList)success failure:(failure)failure{
    [[WSRequestHelper shareInstance] postRequestRouteListWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            WSNewRouteListModel * model = [WSNewRouteListModel yy_modelWithDictionary:resultDic];
            if(success){
                success(model);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];
}
+ (void)requestStoreDateListWithParameters:(NSDictionary*)parameters success:(getRouteList)success failure:(failure)failure{
    [[WSRequestHelper shareInstance] postRequestRouteListWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            WSNewRouteListModel * model = [WSNewRouteListModel yy_modelWithDictionary:resultDic];
            if(success){
                success(model);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];
}

+ (void)requestRouteTjInfoWithParameters:(NSDictionary*)parameters success:(success)success failure:(failure)failure{
    [[WSRequestHelper shareInstance] postRequestRouteListWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            NSObject * model = [NSClassFromString(@"WSTskfRouteTJModel") yy_modelWithDictionary:resultDic];
            if(success){
                success(model);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];
}
#pragma mark - # 推送解绑
+ (void)requestUnBindDeviceTokenSuccess:(completeSuccess)success failure:(failure)failure{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:BINDTOKENOBJID forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    [parameters setObject:@"1" forKey:@"unBindToken"];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:ISNULL(syncDate) forKey:@"bizeDate"];
    [[WSRequestHelper shareInstance] postRequestRouteListWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            if(success){
                success(YES);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];
    
}
#pragma mark - # 判断视频是否超时
+ (void)reqestChatMsgExpiredWithTaskId:(NSString*)taskId success:(expiredChat)success failure:(failure)failure{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:CHATEXPIREDOBJID forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    [parameters setObject:ISNULL(taskId) forKey:@"taskId"];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:syncDate forKey:@"bizeDate"];
    LogInfo(@"推送视频消息接口参数：%@",parameters);
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            BOOL checkVideoState = [[resultDic objectForKey:@"checkVideoState"] boolValue];
            if(success){
                success(checkVideoState);
            }
        }else{
            if(success){
                success(NO);
            }
        }
        } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
            if(failure){
                failure(response.error.titleForError);
            }
        }];
}
#pragma mark - # 同意收集用户定位信息接口
+ (void)requestAgreeAppCollectingPrivacySuccess:(agreeCollectUserLocaytion)success{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:AGREECOLLLECTOBJID forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"db_id"];

    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:syncDate forKey:@"bizeDate"];
    NSString * visitPrivacyPolicyVersion = [[WSAppData sharedManager].datas objectForKey:VISITPRIVACYVERRSION];
    [parameters setObject:visitPrivacyPolicyVersion==nil?@"1.0":ISNULL(visitPrivacyPolicyVersion) forKey:@"policyVersion"];
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            NSDictionary *  updateVisitPrivatePolicyLogResultDic= [resultDic objectForKey:@"updateVisitPrivatePolicyLog"];
            if ([updateVisitPrivatePolicyLogResultDic isKindOfClass:[NSString class]]) {
                NSString * updateVisitPrivatePolicyLogResultStr = (NSString*)updateVisitPrivatePolicyLogResultDic;
                BOOL checkVideoState =  [updateVisitPrivatePolicyLogResultStr boolValue];
                if(success){
                    success(checkVideoState);
                }
            }else{
                if(success){
                    success(NO);
                }
            }
        }else{
            if(success){
                success(NO);
            }
        }
    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:response.error.titleForError tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        if(success){
            success(NO);
        }
    }];
}
#pragma mark - # 请求融云IM Token接口
+ (void)requestRongIMTokenSuccess:(rongIMTokenSuccess)success{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:RONGCloudTokenOBJID forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    NSString * lllogName = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    [parameters setObject:ISNULL(lllogName) forKey:@"userAccount"];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:syncDate forKey:@"bizeDate"];
    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            NSString *  rongCloudTokens = [NSString stringWithFormat:@"%@",[resultDic objectForKey:RONGCloudTokenOBJID]];
            if(success){
                success(rongCloudTokens);
            }
        }else{
            if(success){
                success(@"");
            }
        }
    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:response.error.titleForError tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        if(success){
            success(@"");
        }
    }];
}
#pragma mark - # 请求CNY活动接口
+ (void)reuqestCNYActivityWithStoreId:(NSString*)storeId success:(success)success{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:DISPLAYACTOBJID forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    [parameters setObject:ISNULL(storeId) forKey:@"storeId"];

    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:syncDate forKey:@"bizeDate"];
//    [[WSRequestHelper shareInstance] postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
//        NSDictionary * resultDic = [response jsonResponse];
//        LogResponseString([resultDic JSONString],LOG_LENGTH);
//        WSCNYActivityModel * activityModel = [WSCNYActivityModel yy_modelWithDictionary:resultDic];
//        if (activityModel&&activityModel.getDisplayActivityTypeMsg.count>0) {
//            WSCNYActivityInfoModel * model = activityModel.getDisplayActivityTypeMsg.firstObject;
//            if (success) {
//                success(model.msg);
//            }
//        }else{
//            if (success) {
//                success(@"");
//            }
//        }
//        
//    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:response.error.titleForError tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
//        if (success) {
//            success(@"");
//        }
//    }];
}
#pragma mark - # 下载文件
+ (void)downloadFileFromURL:(NSURL *)url toDestinationPath:(NSString *)destinationPath progress:(void (^)(NSProgress *downloadProgress))progressBlock completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock {

    NSError *error = nil;
    NSString *directory = [destinationPath stringByDeletingLastPathComponent];
    
    BOOL isSuccess = [FCFileManager createDirectoriesForPath:directory error:&error];
    if (!isSuccess) {
        NSLog(@"创建目录失败: %@", error.localizedDescription);
        if (completionBlock) {
            completionBlock(nil, nil, error);
        }
        return;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    WinAFURLSessionManager *manager = [[WinAFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSProgress * progress = [[NSProgress alloc]init];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:destinationPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (completionBlock) {
            completionBlock(response,filePath,error);
        }
    }];
    [downloadTask resume];
}
#pragma makr - # 请求建议订单弹框内容
+ (void)reqestSuggestOrderListWithObjId:(NSString*)objId storeInfo:(WSStoreBean*)storeInfo success:(success)success failure:(failure)failure{
    
    if (objId.length==0||objId == nil) {
        LogError(@"未配置opt参数：suggestOrderNode");
        if (failure) {
            failure(@"");
        }
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:objId forKey:@"objId"];
    [parameters setObject:[WSAppData getObjectbyKey:APPDATA_EMPID] forKey:@"empId"];
    [parameters setObject:@"iOS" forKey:@"os"];
    NSString *syncDate = [WSAppData getObjectbyKey:APPDATA_BIZDATE];
    [parameters setObject:syncDate forKey:@"bizeDate"];
    [parameters setObject:storeInfo.Id forKey:@"storeId"];
    
    WSRequestHelper * request = [[WSRequestHelper alloc]init];
    [request postRequestWithParametes:parameters success:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSDictionary * resultDic = [response jsonResponse];
        LogResponseString([resultDic JSONString],LOG_LENGTH);
        if(resultDic){
            WSInventoryResultModel * model = [WSInventoryResultModel yy_modelWithDictionary:resultDic];
            if(success){
                success(model);
            }
        }else{
            if(failure){
                failure(@"接口没有返回数据");
            }
        }
        
    } failure:^(WCBaseResponse *response, WCBaseRequestLocalInfo *localInfo) {
        NSString * errorTips = response.error.titleForError;
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:errorTips tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        if (failure) {
            failure(errorTips);
        }
    }];
    
}
@end
