//
//  StoreListViewController.h
//  WinChannelFrameWork
//
//  Created by Jiepeng Zheng on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSearchBar.h"

@interface WSStoreListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *filter;
@property (nonatomic, strong) NSMutableArray *storeBeanArray;
@property (nonatomic, weak) UIViewController *ownParentViewController;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDC;
@property (nonatomic, strong) NSArray *searchResultArray;
@property (nonatomic, strong) UITableView *tv;

- (id)initWithFilter:(NSString *)aFilter;

@end
