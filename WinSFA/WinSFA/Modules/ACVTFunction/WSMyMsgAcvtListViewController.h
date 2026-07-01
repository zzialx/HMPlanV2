//
//  MsgAcvtListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperBarViewController.h"
#import "WSMsgsBean_msg.h"

@interface WSMyMsgAcvtListViewController : SuperBarViewController

@property (nonatomic,strong) WSFuncsBean           *subFuncsBeanNeedShow;

- (void)handleTabBarItemBadgeValue ;
@end
