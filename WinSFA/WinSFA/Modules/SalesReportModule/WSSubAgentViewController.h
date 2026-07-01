//
//  SubAgentViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAllStoresViewController.h"

@interface WSSubAgentViewController : WSAllStoresViewController
{}
- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)initDataArray;
@end
