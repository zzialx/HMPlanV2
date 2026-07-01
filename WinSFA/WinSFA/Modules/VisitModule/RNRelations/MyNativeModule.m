//
//  MyNativeModule.m
//  WinSFA
//
//  Created by HZH on 16/11/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "MyNativeModule.h"
//#import "YYModel.h"
//#import "WSRNRelationData.h"
//#import "WCBaseResponse.h"
//#import "WSRequestBase.h"
//#import "WSCookieHelper.h"
//#import "WSServerIPList.h"
//#import "WSBaseStoreOtherDataDBService.h"
//#import "WSOfflineDataDBService.h"
//#import "WSJSONBuilder.h"
//
////RCTConvert类支持的的类型也都可以使用,RCTConvert还提供了一系列辅助函数，用来接收一个JSON值并转换到原生Objective-C类型或类。
//#import "RCTConvert.h"
////本地模块也可以给JavaScript发送事件通知。最直接的方式是使用eventDispatcher
//#import "RCTEventDispatcher.h"
//#import "RCTEventEmitter.h"

@interface MyNativeModule ()
//{
//    NSString *_LoginWebSessionID;
//    BOOL _insertDataGridIsSucceed;
//}

@end

@implementation MyNativeModule
//
//@synthesize bridge = _bridge;
////====================================[JS ->  OC]=======================================
//
//
//RCT_EXPORT_MODULE();
//
////桥接到Javascript的方法返回值类型必须是void。React Native的桥接操作是异步的，所以要返回结果给Javascript，必须通过回调或者触发事件来进行
//RCT_EXPORT_METHOD(wincGetUrl:(NSString *)funcString)
//{
//    //data:{result:1,url:"http://....",formcode:"formcode",navigate:[{type:"menu",id:"11"},{type:"store",id:"12"},{type:"dictitem",id:"13"},{type:"prod",id:"14"}]}//navigate指的是从进入app后点击的菜单顺序
//
//    NSLog(@"js call iOS function wincGetUrl\n funcString: %@ ",funcString);
//
//    NSString *dataStr = [[WSRNRelationData sharedInstance] dataJsonStr];
//
//    [self.bridge.eventDispatcher sendDeviceEventWithName:funcString body:dataStr];
//}
//
//RCT_EXPORT_METHOD(wincRightTopButton:(BOOL)hasRightTopBtn)
//{
//    //data:{result:1,url:"http://....",formcode:"formcode",navigate:[{type:"menu",id:"11"},{type:"store",id:"12"},{type:"dictitem",id:"13"},{type:"prod",id:"14"}]}//navigate指的是从进入app后点击的菜单顺序
//
//    NSLog(@"js call iOS function wincRightTopButton\n funcString: %d ",hasRightTopBtn);
//
//}
//
//RCT_EXPORT_METHOD(wincGetData:(NSString *)funcString withUrl:(NSString *)url andJsonString:(NSString *)jsonString isUsedLocalData:(BOOL)isUsed)
//{
//    NSLog(@"js call iOS function wincGetData\n funcString: %@ ",funcString);
//
//    // submitUrl=json.url+"/form.do?method=submit&formcode="+json.formcode+"&protocol=json";
//
//    if (_LoginWebSessionID != nil) {
//        [self getFormDataWithJSFunc:funcString withUrl:url andJsonString:jsonString isUsedLocalData:(BOOL)isUsed];
//    }else{
//        [self loginWebWithFinishedBlock:^{
//            [self getFormDataWithJSFunc:funcString withUrl:url andJsonString:jsonString isUsedLocalData:(BOOL)isUsed];
//        }];
//    }
//
//}
//
//RCT_EXPORT_METHOD(wincDoAuth:(NSString *)dataString)
//{
//    NSLog(@"js call iOS function wincDoAuth\n dataString: %@ ",dataString);
//
//    [self loginWebWithFinishedBlock:^{
//
//    }];
//
//}
//
//RCT_EXPORT_METHOD(wincSave:(NSString *)submitUrl jsonString:(NSString *)submitJson syncOrNot:(BOOL)sync submitFunc:(NSString *)submitFunc urls:(NSString *)urls)
//{
//    NSLog(@"js call iOS function wincSave\n dataString: %@ ",submitJson);
//    if (submitUrl == nil || [submitUrl isEqualToString:@""]){
//        //注册通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitFormData:) name:@"submitFormData" object:nil];
//    }else{
//
//        NSMutableDictionary *paramters01 = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithJsonString:submitJson]];
//
//        WinAFHTTPRequestOperationManager *manager = [WinAFHTTPRequestOperationManager manager];
//        if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
//            [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
//        }
//
//        if (submitUrl && ![submitUrl hasPrefix:@"http://"]) {
//            submitUrl = [NSString stringWithFormat:@"%@%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName], submitUrl];
//        } else {
//
//        }
//
//        NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:[[NSURL URLWithString:submitUrl relativeToURL:nil] absoluteString] parameters:nil error:nil];
//        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//
//        NSData *oData = [paramters01 JSONData];
//
//        //        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//        //        [request setHTTPBody:[[NSString stringWithFormat:@"%@", infoString] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
//
//
//        [request setHTTPBody:oData];
//
//        NSLog(@"request HTTPBody = %@", request.HTTPBody);
//
//        NSLog(@"requestHeader = %@", request.allHTTPHeaderFields);
//
//        WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//                NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
//                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
//                NSDictionary *resultDic = [result yy_modelToJSONObject];
//                NSLog(@"responseHeader = %@", operation.response.allHeaderFields);
//
//                [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//
//                if (resultDic == nil){
//                    resultDic = jsonDict;
//                }
//
//                NSString *resultStr = [resultDic objectForKey:@"result"];
//                NSString *tipMessageStr = [resultDic objectForKey:@"message"];
//
//                if (resultStr != nil && ![resultStr isEqualToString:@""]) {
//                    if ([resultStr isEqualToString:@"1"]) {
//                        //创建通知
//                        NSNotification *notification =[NSNotification notificationWithName:@"submitFormDataFinished" object:nil userInfo:jsonDict];
//                        //通过通知中心发送通知
//                        [[NSNotificationCenter defaultCenter] postNotification:notification];
//                    }else{
//                        [self uploadFailedAndSaveToOfflineDBWithUploadDataStr:submitJson andUploadUrl:submitUrl];
//                        //创建通知
//                        NSNotification *notification =[NSNotification notificationWithName:@"submitFormDataFinished" object:nil userInfo:jsonDict];
//                        //通过通知中心发送通知
//                        [[NSNotificationCenter defaultCenter] postNotification:notification];
//                    }
//                }else{
//                    if (tipMessageStr != nil && ![tipMessageStr isEqualToString:@""]){
//                        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"js_alert_title", nil) message:tipMessageStr];
//                        [alert setCancelButtonWithTitle:NSLocalizedString(@"confirm", nil) block:nil];
//                        [alert show];
//                    }else{
//                        [self uploadFailedAndSaveToOfflineDBWithUploadDataStr:submitJson andUploadUrl:submitUrl];
//                        //创建通知
//                        NSNotification *notification =[NSNotification notificationWithName:@"submitFormDataFinished" object:nil userInfo:jsonDict];
//                        //通过通知中心发送通知
//                        [[NSNotificationCenter defaultCenter] postNotification:notification];
//                    }
//                }
//
//        }failure:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"wincSave failed");
//            [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//
//            [self uploadFailedAndSaveToOfflineDBWithUploadDataStr:submitJson andUploadUrl:submitUrl];
//
//            NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
//            [resultDic setObject:@"" forKey:@"result"];
//
//            NSNotification *notification =[NSNotification notificationWithName:@"submitFormDataFinished" object:nil userInfo:resultDic];
//            //通过通知中心发送通知
//            [[NSNotificationCenter defaultCenter] postNotification:notification];
//
//        }];
//
//        if ([manager.operationQueue operationCount] > 0) {
//            [operation setQueuePriority:NSOperationQueuePriorityHigh];
//        }
//
//        [manager.operationQueue addOperation:operation];
//
//    }
//
//}
//
//- (void)uploadFailedAndSaveToOfflineDBWithUploadDataStr:(NSString *)dataStr andUploadUrl:(NSString *)url
//{
//    NSString *md5 = [Md5Manager getMd5ByEmpId:nil
//                                      sotreId:nil
//                                      bizDate:nil
//                                     funcCode:nil
//                                       acvtId:nil
//                                         memo:dataStr];
//    NSString *notifyID = [NSString stringWithFormat:@"%@%@", kOfflineTableNotifyIdPrefix, [WSJSONBuilder gen_uuid]];
//    // 离线数据
//    _insertDataGridIsSucceed = [WSOfflineDataDBService insertUploadData:dataStr URL:url MD5:md5 IsPhoto:NO NotifyName:notifyID];
//
//    [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//}
//
//RCT_EXPORT_METHOD(wincDialog:(BOOL)isShow)
//{
//    NSLog(@"wincDialog\n");
//    if (isShow) {
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
//    }else{
//        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//    }
//}
//
////RCT_EXPORT_METHOD(wincShowDialog)
////{
////    NSLog(@"wincShowDialog\n");
////    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"pull_to_refresh_refreshing_label", nil) tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeWaiting];
////
////}
//
//- (void)getFormDataWithJSFunc:(NSString *)funcString withUrl:(NSString *)url andJsonString:(NSString *)jsonString isUsedLocalData:(BOOL)isUsed
//{
//
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//
//    [parameters setObject:@1 forKey:@"noresponsebody"];
//    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP] forKey:@"userAccount"];
//    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP] forKey:@"userPassword"];
//
//    NSMutableDictionary *paramters01 = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithJsonString:jsonString]];
//
//    NSMutableDictionary *nextPostHeaderDic = [[NSMutableDictionary alloc] init];
//    if (url && ![url hasPrefix:@"http://"]) {
//        url = [NSString stringWithFormat:@"%@%@", [WSPlistHelper valueForKey:kServerIP withPlistName:kConfilgFileName], url];
//    } else {
//
//    }
//
//    if (_LoginWebSessionID != nil) {
//        [nextPostHeaderDic setObject:_LoginWebSessionID forKey:@"Set-Cookie"];
//    }
//
//    WSBaseStoreOtherDataObject *bsodo = nil;
//
//    if (isUsed) {
//        WSBaseStoreOtherDataDBService *DB = [[WSBaseStoreOtherDataDBService alloc] init];
//        NSArray *dataArray = [DB queryWithItem1:url];
//
//        if (dataArray && [dataArray count] > 0) {
//            bsodo = [dataArray firstObject];
//        }
//
//        if (bsodo) {
//            [self.bridge.eventDispatcher sendDeviceEventWithName:funcString body:bsodo.item2];
//        }
//    }
//
//    [self netRequestPostWithParamters:paramters01 andUrl:url andHttpHeader:nextPostHeaderDic success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//        NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
////        NSString *datastr = [result yy_modelToJSONString];
//        NSLog(@"responseHeader = %@", operation.response.allHeaderFields);
//        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
//
//        NSInteger statusCode = operation.response.statusCode;
//        [mDic setObject:[NSString stringWithFormat:@"%ld", (long)statusCode] forKey:@"httpCode"];
//
//        [mDic setObject:result forKey:@"content"];
//
//        NSString *dataStr = [mDic yy_modelToJSONString];
//
//        if (isUsed) {
//            NSString *md5 = [Md5Manager getMd5ByEmpId:nil
//                                              sotreId:nil
//                                              bizDate:nil
//                                             funcCode:nil
//                                               acvtId:nil
//                                                 memo:dataStr];
//
//            if (![bsodo.item3 isEqualToString:md5]) {
//                [self saveDataToDB:dataStr andRequestUrl:url andOtherData:nil];
//                [self.bridge.eventDispatcher sendDeviceEventWithName:funcString body:dataStr];
//            }else{
//                [self.bridge.eventDispatcher sendDeviceEventWithName:funcString body:bsodo.item2];
//            }
//
//        }else{
//            [self.bridge.eventDispatcher sendDeviceEventWithName:funcString body:dataStr];
//        }
//        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"wincGetData failed");
//        [MBProgressHUD hideHUDForView:kApplicationWinddow animated:NO];
//    }];
//}
//
//- (void)submitFormData:(NSNotification *)notification{
//    NSLog(@"%@",notification.userInfo[@"textOne"]);
//    NSLog(@"－－－－－接收到通知------");
//    [self.bridge.eventDispatcher sendDeviceEventWithName:@"submitFn" body:nil];
//}
//
//- (void)netRequestPostWithParamters:(NSDictionary *)parameters andUrl:(NSString *)urlString andHttpHeader:(NSDictionary *)headerDic success:(void (^)(WinAFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(WinAFHTTPRequestOperation *operation, NSError *error))failure
//{
//
//    WinAFHTTPRequestOperationManager *manager = [WinAFHTTPRequestOperationManager manager];
//    if (![manager.requestSerializer isKindOfClass:[WinAFHTTPRequestSerializer class]]) {
//        [manager setRequestSerializer:[WinAFHTTPRequestSerializer serializer]];
//    }
//
////    NSString *urlStr = [[NSURL URLWithString:urlString relativeToURL:nil] absoluteString];
//
//    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:kHttpMethodPOST URLString:urlString parameters:parameters error:nil];
//
//    if (headerDic){
//        for (NSString *key in headerDic) {
//            NSLog(@"key: %@ value: %@", key, headerDic[key]);
//            [request addValue:headerDic[key] forHTTPHeaderField:key];
//        }
//
//        NSLog(@"requestHeader = %@", request.allHTTPHeaderFields);
//    }
//
//    WinAFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:success failure:failure];
//
//    if ([manager.operationQueue operationCount] > 0) {
//        [operation setQueuePriority:NSOperationQueuePriorityHigh];
//    }
//
//    [manager.operationQueue addOperation:operation];
//}
///*!
//
// * @brief 把格式化的JSON格式的字符串转换成字典
//
// * @param jsonString JSON格式的字符串
//
// * @return 返回字典
//
// */
//
//- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
//
//    if (jsonString == nil) {
//
//        return nil;
//
//    }
//
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSError *err;
//
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//
//                                                        options:NSJSONReadingMutableContainers
//
//                                                          error:&err];
//
//    if(err) {
//
//        NSLog(@"json解析失败：%@",err);
//
//        return nil;
//
//    }
//
//    return dic;
//
//}
//
//- (void)loginWebWithFinishedBlock:(void (^)())block
//{
////    WCBaseRequest *request = [[WCBaseRequest alloc] init];
//
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//
//    [parameters setObject:@1 forKey:@"noresponsebody"];
//    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP] forKey:@"userAccount"];
//    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP] forKey:@"userPassword"];
//    NSString *loginUrl = [NSString stringWithFormat:@"%@login.do", [WSHttpURLHelper getConfigFileServerIP]];
//
//    [self netRequestPostWithParamters:parameters andUrl:loginUrl andHttpHeader:nil success:^(WinAFHTTPRequestOperation *operation, id responseObject) {
//        NSString *result = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
//        NSLog(@"wincDoAuth result = %@", result);
//
//        _LoginWebSessionID = [operation.response.allHeaderFields objectForKey:@"Set-Cookie"];
//
//        block();
//
//    } failure:^(WinAFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"wincDoAuth failed");
//        block();
//    }];
//}
//
///*
// * 数据存储在table_store_other_data表中，存放的位置及含义.
// * item1—请求服务器的url.
// * item2—请求服务器获取的数据.
// * item3—item2中数据的hashcode.
// * item4—存放item2的时间戳.
// * item5—操作过程中产生的数据.
// * item6—存储item5数据时的时间戳.
// */
//
//- (void)saveDataToDB:(NSString *)jsonData andRequestUrl:(NSString *)requestUrl andOtherData:(NSString *)otherData
//{
//    NSLog(@"saveDataToDB: %@", jsonData);
//
//    WSBaseStoreOtherDataDBService *DB = [[WSBaseStoreOtherDataDBService alloc] init];
//    NSMutableDictionary *mDataDic = [[NSMutableDictionary alloc] init];
//
//    [mDataDic setObject:WINSFA_SHARE_DATA_TYPE forKey:@"type"];
//    [mDataDic setObject:requestUrl forKey:@"item1"];
//    [mDataDic setObject:jsonData forKey:@"item2"];
//
//    NSDate *serverDate = [WSCurrentTime getCurrentServerDate];
//    NSTimeInterval interval = [serverDate timeIntervalSince1970];
//
//    NSString *l_dateStr = [NSString stringWithFormat:@"%lld", (long long)interval];
//
//    NSString *md5 = [Md5Manager getMd5ByEmpId:nil
//                                 sotreId:nil
//                                 bizDate:nil
//                                funcCode:nil
//                                  acvtId:nil
//                                    memo:jsonData];
//    [mDataDic setObject:md5 forKey:@"item3"];
//    [mDataDic setObject:l_dateStr forKey:@"item4"];
//    [mDataDic setObject:@"" forKey:@"item5"];
//    [mDataDic setObject:@"" forKey:@"item6"];
//
//
//    [DB insertOrUpdateStoreWithDataDic:mDataDic];//保存到OtherDataTable
//}

@end
