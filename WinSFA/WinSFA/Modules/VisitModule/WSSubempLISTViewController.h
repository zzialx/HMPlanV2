//
//  SubempLISTViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSubempstoreBeanArray.h"
#import "WSSubempstoreBean.h"
#import "WSManagV_LISTViewController.h"
#import "WSFuncsBean.h"
#import "MultipeerManager.h"
#import "WSSearchBar.h"

@interface WSSubempLISTViewController : SuperWorkSpaceViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,MultipeerManagerDelegate, UISearchBarDelegate>{
    UITableView     *myTableView;
    NSMutableArray  *dataArray;
}

@property (nonatomic, strong) UITableView       *myTableView;
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) NSMutableArray    *filterArray;
@property (nonatomic, strong) WSSearchBar *searchBar;

-(void)initDataArray;
-(void)reloadArray;

@end
