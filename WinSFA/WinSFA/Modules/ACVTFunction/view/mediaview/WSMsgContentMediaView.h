//
//  WSMsgContentMediaView.h
//  WinSFA
//
//  Created by heju on 15/6/2.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSServerIPList.h"
#import "WSInterAction.h"
#import "WSMediaInfo.h"
#import "WSWidget.h"
#import "WSAcvtBean_qst.h"
#import "WSMsgsBean_msg.h"

#import "WSDownloadFileTable.h"

#import "WSMappingObject.h"

#import "IAttachment.h"

#import "WSDownloadUtil.h"

#import "WSServiceDispatcher.h"

#import "I_Task_ExecutorDelegate.h"

#import "DownloadExecutor.h"

@interface WSMsgContentMediaView : WSWidget <I_Task_ExecutorDelegate>{
    
}

@property (nonatomic ,strong)NSObject<IAttachment> *dowloadedAttachment;

@property (nonatomic, strong) NSObject<I_W_BuildInfo> *msgBean_msg;


@property (nonatomic, strong) WSServiceDispatcher *serviceDispatcher;

@property (nonatomic, strong) NSObject<I_W_BuildInfo> *currentbuildInfo;

@property (nonatomic, strong) NSMutableDictionary *interactionMap;

@property (nonatomic, strong) DownloadExecutor *downloadExecutor;

@property (nonatomic, strong) NSString *downLoadFilePath;

@property (nonatomic, strong) UIButton *downloadButton;

// 外面传进来的背景图片
@property(nonatomic,strong) UIImage * bgImage;
// 下载完成后的回调
@property (nonatomic , copy) void (^downLoadFinish)();

- (id)initWithFrame:(CGRect)frame msg:(NSObject<I_W_BuildInfo> *)msg_BuildInfo;

-(void)loadDisplayContent:(NSObject<I_W_BuildInfo> *)content; //载入内容

- (void)downloadMediaSource;

- (WSMediaInfo *)queryMediaInfoFromeDbWithEmpId:(NSString *)empId  fileId:(NSString *)fileId;

@end

