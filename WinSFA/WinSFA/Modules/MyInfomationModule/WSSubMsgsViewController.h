//
//  WCSubMsgsViewController.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMsgsBean;

@interface WSSubMsgsViewController : UIViewController

@property (nonatomic, strong) WSMsgsBean *iMsgBean;

- (id)init;
- (id)initWithMsgsBean:(WSMsgsBean *)aMsgsBean;

@end
