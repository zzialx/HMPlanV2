//
//  WSRefreshLoginManager.m
//  WinSFA
//
//  Created by yang on 15/12/31.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSRefreshLoginHttpService.h"
#import "WSRequestHelper.h"
#import "WSLoginDataProcessService.h"
#import "WSLoginProgressDefine.h"

#define REFRESH_DATA_NOTIFY @"REFRESH_DATA_NOTIFY"




@interface WSRefreshLoginHttpService ()

@property (nonatomic, assign) NSInteger totalUnUploadCount;
@property (nonatomic, assign) NSInteger hasUploadCount;
@property (nonatomic, strong) WSLoginDataProcessService *processService;

@end

@implementation WSRefreshLoginHttpService

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)beginRefreshData
{
    LogTrace();
    
    if ([self unUploadDataCount] > 0) {
        [self uploadAllFailedData];
    }else {
        [self sendRefreshDataRequest];
    }
    
}

- (void)sendRefreshDataRequest
{
    [self setProgress:WSLoginProgressRequestConfig];
    
    LogTrace();
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:REFRESH_DATA_NOTIFY
                                               object:nil];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_LAST_LOGIN];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_LAST_LOGIN];
//    [uploadMgr postRequestOnLogin:userName passWd:pwd notifyName:REFRESH_DATA_NOTIFY URL:URL_LOGINREFRESH];
    [[WSRequestHelper shareInstance] postRequestOnLogin:userName passWd:pwd notifyName:REFRESH_DATA_NOTIFY URL:URL_LOGIN progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger totalProgress = WSLoginProgressRequestConfig + progress * (WSLoginProgressRequestLogin - WSLoginProgressRequestConfig);
            [self setProgress:totalProgress];
        });
    }];

}

- (NSInteger)unUploadDataCount
{
    WSOffLineUploadTable* l_leaveStore = [WSOffLineUploadTable sharedTable];
    return [l_leaveStore queryCountWithUploadFlagType:Failed];
}

- (void)uploadAllFailedData
{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"数据上传中...", nil)  tips:nil tapTarget:self action:nil];
    
    NSArray* l_failedDatas = [[WSOffLineUploadTable sharedTable] queryWithUploadFlagType:Failed];
    self.totalUnUploadCount = [l_failedDatas count];
    WSRequestHelper* l_WSRequestHelper = [WSRequestHelper shareInstance];
    for (WSOffLineUploadObject* object in l_failedDatas)
    {
        NSString* l_notify = object.notify;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishRequest:)
                                                     name:l_notify
                                                   object:nil];
        LogInfo(@"uploadFailedData%@",object);
        [l_WSRequestHelper uploadFailedData:object];
    }

}

- (void)finishRequest:(id)sender
{
    LogTrace();
    NSNotification *notification = (NSNotification *)sender;
    
    LogInfo(@"[notification name] %@", [notification name]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[notification name]
                                                      object:nil];
    
    
    self.hasUploadCount++;
    
    if (self.hasUploadCount == self.totalUnUploadCount) {
        NSInteger count = [self unUploadDataCount];
        if (count == 0) {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:NSLocalizedString(@"数据刷新中...", nil)  tips:nil tapTarget:self action:nil];
            [self sendRefreshDataRequest];
        }else {
            [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
            [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:[NSString stringWithFormat:@"%ld条数据上传失败，请重试", (long)count] tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
            if (self.endRefreshBlock) {
                self.endRefreshBlock(WSRefreshLoginStatusError);
            }
        }
        
        self.totalUnUploadCount = 0;
        self.hasUploadCount = 0;
    }

}



- (void)loginResponse:(id)sender{
    
    [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_DATA_NOTIFY object:nil];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    NSDictionary *dic = [info objectFromJSONString];
    
    // 保存timeUpdate
    NSString *timeUpdate = [dic objectForKey:APPDATA_TIME_UPDATE];
    [[NSUserDefaults standardUserDefaults] setObject:timeUpdate forKey:APPDATA_TIME_UPDATE];
    
    NSString *message = nil;
    
    if (error)
    {
        [self showMessage:[error ws_localizedDescription]];
        if (self.endRefreshBlock) {
            if (error.code != NSURLErrorTimedOut && error.code != NSURLErrorNotConnectedToInternet) { // 非超时和无连接
                self.endRefreshBlock(WSRefreshLoginStatusError);
            } else {
                self.endRefreshBlock(WSRefreshLoginStatusDisable);
            }
        }
        return;
    }
    
    if (!info || [info length] == 0 || !dic) {
        LogError(@"info length == 0");
        if (self.endRefreshBlock) {
            self.endRefreshBlock(WSRefreshLoginStatusError);
        }
        return;
    }
    
    NSString* flag = [NSString stringWithValue:[dic objectForKey:@"flag"]];
    if(![flag isEqualToString:@"1"])
    {
        //错误信息
        message = [NSString stringWithValue:[dic objectForKey:@"msg"]];
        if (!message || [message length] == 0) {
            message = NSLocalizedString(@"refresh_failure", nil);
        }
        
        [self showMessage:message];
        if (self.endRefreshBlock) {
            if (![flag isEqualToString:@"02"]) {
                self.endRefreshBlock(WSRefreshLoginStatusError);
            } else {
                self.endRefreshBlock(WSRefreshLoginStatusDisable);
            }
        }
        
        return;
    }
    
    
    NSNumber *number = [[sender userInfo] objectForKey:LOGIN_DATA_IS_FROMCACHE];
    BOOL isLoginDataFromCache = number ? [number boolValue] : NO;
    
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_CALL_APP];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_CALL_APP];
    
    __weak typeof (self) weakSelf = self;
    [self.processService processLoginDataWithQueue:dic userName:userId password:password isFromCache:isLoginDataFromCache isOfflineLogin:NO complete:^(BOOL isSuccess) {
        
        WSRefreshLoginStatus status;
        if (isSuccess) {
            [[WSAppData sharedManager].datas setValue:nil forKey:APPDATA_LOGIN_REDIRECT_FC];
            status = WSRefreshLoginStatusSuccess;
        } else {
            NSString *message = [NSString stringWithValue:[dic objectForKey:@"msg"]];
            if (!message || [message length] == 0) {
                message = NSLocalizedString(@"refresh_failure", nil);
            }
            [weakSelf showMessage:message];
            status = WSRefreshLoginStatusError;
        }
        
        if (weakSelf.endRefreshBlock) {
            weakSelf.endRefreshBlock(status);
        }
    }];
    
    [self setProgress:WSLoginProgressProcessData];
    
    self.processService.progressBlock = ^(NSInteger progress) {
        NSInteger totalProgress = WSLoginProgressProcessData + progress / 100.0 * (WSLoginProgressSuccess - WSLoginProgressProcessData);
        [weakSelf setProgress:totalProgress];
    };
    
//    BOOL result = [processService processLoginDataWithQueue:dic userName:userId password:password isFromCache:isLoginDataFromCache isOfflineLogin:NO];
    
//    if (!result) {
//        message = [NSString stringWithValue:[dic objectForKey:@"msg"]];
//        if (!message || [message length] == 0) {
//            message = NSLocalizedString(@"refresh_failure", nil);
//        }
//        [self showMessage:message];
//    }
    
    
    //下拉刷新后不需要显示loginRedirectFc页面，删除loginRedirectFc数据
//    [[WSAppData sharedManager].datas setValue:nil forKey:APPDATA_LOGIN_REDIRECT_FC];
    
//    if (self.endRefreshBlock) {
//        self.endRefreshBlock(result);
//    }
}

- (void)showMessage:(NSString *)message{
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

- (void)setProgress:(NSInteger)progress {
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

- (WSLoginDataProcessService *)processService {
    if (!_processService) {
        _processService = [[WSLoginDataProcessService alloc] init];
    }
    return _processService;
}


@end
