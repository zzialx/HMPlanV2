//
//  WSHelpDocumentationViewController.h
//  WinSFA
//
//  Created by heju on 3/6/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSAppData.h"
#import "WSHelpDocument.h"
#import "WSHelpDocumentScrollView.h"
#import "MBProgressHUD.h"
#import "WCBaseViewController.h"


@interface WSHelpDocumentationViewController : WCBaseViewController <WSHelpDocumentItemViewDelegate>
@property (nonatomic ,strong)WSFuncsBean *funcsBean;

-(id)initWithFuncs:(WSFuncsBean*)funcs;

@end
