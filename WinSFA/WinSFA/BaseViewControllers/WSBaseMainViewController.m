//
//  WSBaseMainViewController.m
//  WinSFA
//
//  Created by yang on 2017/7/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSBaseMainViewController.h"
#import "WSBaseMsgTypeTable.h"
#import "WSBaseMsgTable.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSRequestHelper.h"
#import "WSMsgBeanArray.h"
#import "WSMsgsBean.h"

@interface WSBaseMainViewController ()

@end

@implementation WSBaseMainViewController

- (void)reloadFunTipCount {
    
}

// 信息中心定时更新公告信息
- (void)updateNoticeInfo {
    // to do something
    @autoreleasepool {
        id  interval = [[NSUserDefaults standardUserDefaults] objectForKey:POA_NOTIFICATION_INTERVAL];
        NSTimeInterval timeInterval = 30;
        if (interval && ([interval isKindOfClass:[NSString class]] || [interval isKindOfClass:[NSNumber class]])) {
            timeInterval = [interval   intValue];
        }
        self.noticeTimer = [NSTimer  timerWithTimeInterval:timeInterval*60.0f  target:self selector:@selector(updateNoticeInfoRequestStart) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.noticeTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop]  run];
    }
}

- (void)updateNoticeInfoRequestStart {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNoticeInfoFinished:)
                                                 name:@"updataMassage"
                                               object:nil];
    [[WSRequestHelper shareInstance]  postRequestMSGWithType:@"0"];
}
- (void)updateNoticeInfoFinished:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updataMassage" object:nil];
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
    if (error.code != 0)
    {
        //        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
        //        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return;
    }else{
        // 定时更新下来的 MSGS存入内存中.
        NSDictionary *uploadState = [info objectFromJSONString];
        NSString *timeUpdate = [uploadState objectForKey:APPDATA_TIME_UPDATE];
        if (!timeUpdate) {
            timeUpdate = @"";
        }
        // save timeUpdate
        [[NSUserDefaults standardUserDefaults] setObject:timeUpdate forKey:APPDATA_TIME_UPDATE];
        // fetch msgsQuery
        NSArray *queryMsgBeanList = [uploadState objectForKey:@"msgsQuery"];
        NSMutableArray *queryMsgArrys = [[NSMutableArray alloc]initWithCapacity:16];
        for (NSInteger i =0 ; i <[queryMsgBeanList count]; i++) {
            NSDictionary *msgBeanDictonary = [queryMsgBeanList objectAtIndex:i];
            WSMsgsBean *msgBean = [[WSMsgsBean alloc]initWithObject:msgBeanDictonary];
            [queryMsgArrys insertObject:msgBean atIndex:i];
        }
        // update savedMsgBeanArray
        
        WSMsgBeanArray * savedMsgBeanArray = [[WSMsgBeanArray alloc]initWithObject:[[WSBaseMsgTypeTable sharedTable] queryBaseMsgType]];
        if(savedMsgBeanArray == nil){
            LogError(@"savedMsgBeanArray == nil");
            return;
        }
        for (NSInteger i = 0; i < [savedMsgBeanArray.msgArray count]; i++) {
            WSMsgsBean *savedMsgBean = [savedMsgBeanArray.msgArray objectAtIndex:i];
            for (NSInteger j = 0; j < [queryMsgArrys count]; j++) {
                WSMsgsBean *queryMsgBean = [queryMsgArrys objectAtIndex:j];
                if ([queryMsgBean.Id isEqualToString:savedMsgBean.Id]) {
                    [savedMsgBeanArray.msgArray removeObjectAtIndex:i];
                    [savedMsgBeanArray.msgArray insertObject:queryMsgBean atIndex:i];
                    break;
                }
            }
        }
        // save savedMsgBeanArray
        
        if (queryMsgBeanList.count && queryMsgBeanList.count > 0) {
            
            [[WSBaseMsgTypeTable sharedTable] deleteAll];
            [[WSBaseMsgTable sharedTable] deleteAll];
            WSBaseMsgTypeDBService * dbSeevice = [[WSBaseMsgTypeDBService alloc] init];
            [dbSeevice replaceToTableWithDicts:queryMsgBeanList FromNode:MSGS hasNewData:YES];
        }
        // rest msgBadge
        [self resetNoticeInfoBadge:savedMsgBeanArray.msgArray];
    }
}

- (void)resetNoticeInfoBadge:(NSArray *)msgArray {
    
}


@end
