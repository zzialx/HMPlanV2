//
//  WCArrangeScheduleViewController.h
//  WinChannelFrameWork
//
//  Created by Lei Cai on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperWorkSpaceViewController.h"
#import "FMMoveTableView.h"
#import "WSCallPlanTableViewCell.h"


#define UPDATAFINISH_NOTIFY    @"storeSchedule_notify"


@interface WCSchedule : NSObject
@property (nonatomic, strong) NSDate            *date;
@property (nonatomic, strong) NSMutableArray    *tasks;
@property (nonatomic, assign) BOOL  changed;

@end

@interface WSArrangeScheduleViewController : SuperWorkSpaceViewController <UITableViewDataSource, UITableViewDelegate,FMMoveTableViewDataSource,FMMoveTableViewDelegate,WSCallPlanTableViewCellDelegate>

@property (nonatomic, strong) FMMoveTableView  *tableView;
@property (nonatomic, strong) WCSchedule * currentSch;
@property (nonatomic, strong) NSString *currentDateState;

@property (nonatomic, strong) NSMutableDictionary *visitedStoreDict;

@property (nonatomic, assign) WSCallPlanTableViewCellStyle funcStyle;

- (void)addToolBar;
@end
