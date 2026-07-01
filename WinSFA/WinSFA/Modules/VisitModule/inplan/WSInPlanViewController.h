//
//  InPlanViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WSStoreListBaseViewController.h"

@class WSFuncsBean,WSWorkFlowViewController,WSStoreBean;

@interface WSInPlanViewController : WSStoreListBaseViewController <UITableViewDelegate, UITableViewDataSource>
{}
@property (nonatomic, strong) UITableView       *tableView;
//WSInPlanViewController类定义为为计划内门店; WSTodayVisitViewController类里定义为今日拜访的门店（计划内+计划外拜访门店）
@property (nonatomic, strong) NSMutableArray    *PlanStoreArray;
@property (nonatomic, strong) NSDictionary *shouldAddFilters;
@property (nonatomic, assign) BOOL hasVisitType;
@property (nonatomic, strong) NSArray *noTypeItems;
@property (nonatomic, strong) NSMutableArray *visitedStoreArray;
@property (nonatomic, strong) NSMutableArray *notVisitStoreArray;
@property (nonatomic, copy) NSString *currentAddStoreName;
@property (nonatomic, strong) WSWorkFlowViewController *currentViewController;
@property (nonatomic, strong) UIAlertView *alert;

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (void)initDataArray;

// add by wangdongyan 03-21
- (id)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores;

+(void)setCurrentCategory:(NSString *)aCategory;

+(NSString *) currentCategory;


- (BOOL)categoryInNoTypeItems;

-(void)startUpdata:(WSStoreBean*)store;
@end
