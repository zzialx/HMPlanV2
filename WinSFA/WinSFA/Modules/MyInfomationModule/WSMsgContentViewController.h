//
//  WCMsgContentViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 10/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCDownLoadingAndShowingImageView.h"
#import "WSMsgContentMediaView.h"
#import "WSServiceDispatcher.h"
#import "WCBaseViewController.h"

@class WSMsgsBean_msg;

@interface WSMsgContentViewController : UIViewController <WCDownLoadingAndShowingImageViewDelegate,UIScrollViewDelegate ,WSServiceDispatcherDelegate,WSWidgetDelegate,WCBaseViewControllerDelegate>


@property (nonatomic, strong) WSMsgsBean_msg *iMsg;
@property (nonatomic, assign) BOOL isShowingReply;
@property (nonatomic, assign) BOOL  isHomePageSign;

@property (nonatomic, strong) NSMutableDictionary *mediaDic;

- (id)init;

- (id)initWithMessage:(WSMsgsBean_msg *)aMsg;


@end
