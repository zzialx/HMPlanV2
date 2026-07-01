//
//  OutPlanViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WSStoreListBaseViewController.h"
#import "WSFuncsBean.h"
#import "WSSearchBar.h"

#define UPDATA_NOTIFY       @"outPlan_notify"

//TODO:对上层依赖，需要重构
//#import "SP_AddNewStoreViewController.h"
@class WSStoreBean;

@interface WSOutPlanViewController : WSStoreListBaseViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{}
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) WSSearchBar       *ownSearchBar;
//WSOutPlanViewController类定义为为计划外门店; WSAllStoresViewController类里定义为门店清单（计划内+计划外）
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) UIAlertView       *alert;
@property (nonatomic, strong) WSStoreBean         *currentStore;


@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) NSMutableArray *filterArray;

@property (nonatomic, assign) BOOL canVisitNewStore;

@property (nonatomic, strong) NSDictionary *shouldAddFilters;

@property (nonatomic, copy) NSString *storeInfoClassName;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)initDataArray;
- (NSArray *)searchUnitbyString:(NSString *)search;
- (void)startUpdata:(WSStoreBean *)store;

- (NSString *)getObjID;

-(void)goNextWorkView;
- (WSFuncsBean*)getSubMenu:(NSString*)subMenu;


- (BOOL) isNewStorePage;
@end
