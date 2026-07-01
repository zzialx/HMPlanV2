//
//  ReplayViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSugReplyBeanArray.h"
#import "MBProgressHUD.h"

@interface WSReplayViewController : UITableViewController {}

@property (nonatomic, strong) NSMutableArray    *m_ReplyArray;
@property (nonatomic, strong) NSString          *m_currentMsgId;
@property (nonatomic, strong) WSSugReplyBeanArray *m_sugReplyBeanArray;
@property (nonatomic, strong) MBProgressHUD     *m_HUD;

- (id)initWithMsgId:(NSString *)aMsgId;
@end
