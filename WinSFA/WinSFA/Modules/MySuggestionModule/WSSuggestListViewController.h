//
//  SuggestListViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSuggestionListArray.h"
#import "MBProgressHUD.h"
#import "SuperWorkSpaceViewController.h"

@interface WSSuggestListViewController : SuperWorkSpaceViewController<UITableViewDataSource,UITableViewDelegate> {}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WSSuggestionListArray   *m_suggestionListArray;
@property (nonatomic, strong) MBProgressHUD         *m_HUD;

@end
