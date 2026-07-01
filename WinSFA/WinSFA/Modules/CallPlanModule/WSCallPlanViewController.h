//
//  WSCallPlanViewController.h
//  WinSFA
//
//  Created by winchannel on 2017/5/4.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
#import "FMMoveTableView.h"
#import "WSCallPlanTableViewCell.h"
//#import "WSCallPlanSchedule.h"

#define UPDATAFINISH_NOTIFY    @"storeSchedule_notify"

@interface WSCallPlanSchedule : NSObject

@property (nonatomic, strong) NSDate            *date;
@property (nonatomic, strong) NSMutableArray    *tasks;
@property (nonatomic, assign) BOOL  changed;

@end

@interface WSCallPlanViewController : SuperWorkSpaceViewController<UITableViewDataSource, UITableViewDelegate,FMMoveTableViewDataSource,FMMoveTableViewDelegate,WSCallPlanTableViewCellDelegate>{


}
@property (nonatomic, strong) FMMoveTableView  *tableView;
@property (nonatomic, strong) WSCallPlanSchedule * currentSch;
@property (nonatomic, strong) NSString *currentDateState;

@property (nonatomic, strong) NSMutableDictionary *visitedStoreDict;

@property (nonatomic, assign) WSCallPlanTableViewCellStyle funcStyle;

- (void)addToolBar;

@end
