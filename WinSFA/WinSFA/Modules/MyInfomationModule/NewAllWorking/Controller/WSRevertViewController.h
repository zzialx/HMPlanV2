//
//  RevertViewController.h
//  demo
//
//  Created by admin on 15/10/21.
//  Copyright (c) 2015年 zhiqingPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"
#import "BaseViewController.h"
#import "WCBaseViewController.h"

#define TEXTFIELDTAG	100

#define SELFMSGNOTIFY       @"selfMsg"
#define ADDRECEIVER         @"addreceiver"
#define LastReplyCount  @"LastReplyCount"

@interface WSRevertViewController : WCBaseViewController <UITextViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSArray * inputStr;
@property(nonatomic,strong) UITableView * tableView;

@property (nonatomic, strong) WSMsgsBean_msg      *m_MSG;

@property (nonatomic, strong) MBProgressHUD     *m_HUD;

- (id)initWithMSG:(WSMsgsBean_msg *)aMSG;

@end
