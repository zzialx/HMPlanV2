//
//  ModifyStoreViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreBaseViewController.h"
@class WSStoreBean,WSAcvtBean;

@interface WSModifyStoreViewController : WSStoreBaseViewController <UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) WSStoreBean *currentStore;
@property (nonatomic, strong) NSMutableArray *showStoreArray;

@end
