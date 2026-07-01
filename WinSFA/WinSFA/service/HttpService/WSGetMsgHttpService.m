//
//  WSGetMsgHttpService.m
//  WinSFA
//
//  Created by winchannel on 16/4/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSGetMsgHttpService.h"
#import "WSRequestHelper.h"
#import "WSJSONBuilder.h"
#import "WSMsgBeanArray.h"
#import "WSAppData.h"
#import "WSBaseMsgTypeTable.h"
#import "WSMsgsBean_msg.h"
#import "WSMsgsBean.h"
#import "WSBaseMsgTypeDBService.h"
#import "WSBaseMsgTable.h"

#define kWSMsgHttpServiceNotifyName @"kMsgHttpServiceNotifyName"
@interface WSGetMsgHttpService ()

@property (nonatomic, copy)WSGetMsgHttpServiceCompletionBlock completionBlock;

@end

@implementation WSGetMsgHttpService

- (void)getMsgDataWithCompletionBlock:(WSGetMsgHttpServiceCompletionBlock)completionBlock{
    
    self.completionBlock = completionBlock;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(uploadFinished:)
                                                 name:kWSMsgHttpServiceNotifyName
                                               object:nil];

    
    WSRequestHelper *uploadMgr =[WSRequestHelper shareInstance];
    
    NSString *postData = [WSJSONBuilder buildMSG];
    [uploadMgr postRequestData:[postData mutableObjectFromJSONString] notifyName:kWSMsgHttpServiceNotifyName];
    //[uploadMgr uploadDatasDictionary:[postData mutableObjectFromJSONString] urlString:URL_UPDATE notifyName:kWSMsgHttpServiceNotifyName md5:nil isUpload:NO];
    
    
}
- (void)uploadFinished:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWSMsgHttpServiceNotifyName object:nil];
    
     [MBProgressHUD hideAllHUDsForView:kApplicationWinddow animated:NO];
    
    NSString *info = [[sender userInfo] objectForKey:DATAS];
    NSError *error = [[sender userInfo] objectForKey:ERROR];
     NSDictionary *uploadState = [info objectFromJSONString];
    if (error.code != 0)
    {
//        NSString *tmpString = NSLocalizedString(@"network_failure",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        self.completionBlock(nil,error);
        return;
    }else{
        
        
        NSDictionary *uploadState = [info objectFromJSONString];
        NSArray * array = [uploadState objectForKey:MSGS];
        
        if (array.count && array.count > 0) {
            [[WSBaseMsgTypeTable sharedTable] deleteAll];
            [[WSBaseMsgTable sharedTable] deleteAll];
            WSBaseMsgTypeDBService * dbSeevice = [[WSBaseMsgTypeDBService alloc] init];
            [dbSeevice replaceToTableWithDicts:array FromNode:MSGS hasNewData:YES];
        }
        
//        NSString *tmpString = NSLocalizedString(@"update_done_label",nil);
//        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:tmpString tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeDone];
        
        //更新完成后对userdefault重新处理
    }
    self.completionBlock(uploadState, nil);
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWSMsgHttpServiceNotifyName object:nil];
}

@end
