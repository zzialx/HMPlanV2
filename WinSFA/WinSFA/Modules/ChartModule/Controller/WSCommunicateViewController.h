//
//  WSCommunicateViewController.h
//  WinSFA
//
//  Created by LIBB on 16/12/15.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "WSSearchBar.h"
/*
 *类说明：沟通页面VC
 */
@interface WSCommunicateViewController : WCBaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) NSMutableArray    *filterArray;
@property (nonatomic, strong) UIAlertView       *alert;
@property (nonatomic, assign) BOOL isChatViewDidAppear;

-(void)resetUnreadNumber;

@end
