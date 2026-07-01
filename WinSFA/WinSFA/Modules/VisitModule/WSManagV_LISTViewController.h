//
//  ManagV_LISTViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "WSSkillsAssessmentViewController.h"
#import "SuperWorkSpaceViewController.h"
#import "WSSkillsAssessmentViewController.h"
#import "WSTodayVisitViewController.h"
#import "WSSubempstoreBean.h"
#import "WSManagV_OutPlanViewController.h"
#import "WSPlistHelper.h"

@interface WSManagV_LISTViewController : SuperWorkSpaceViewController <UITableViewDelegate, UITableViewDataSource,SuperWorkSpaceViewControllerDelegate>{
    UITableView     *MyTableView;
    NSMutableArray  *dataArray;
    WSSubempstoreBean *currentSubBean;
}

@property (nonatomic, strong) UITableView       *MyTableView;
@property (nonatomic, strong) NSMutableArray    *dataArray;
@property (nonatomic, strong) WSSubempstoreBean   *currentSubBean;
@property (nonatomic, strong) UIView *  mainView;
@property (nonatomic, assign) NSInteger segementSelectIndex;
@property (nonatomic, strong) UIViewController  *selectViewController;

// -(id)initWithFuncs:(FuncsBean*)funcs;
- (id)initWithSubBeans:(WSSubempstoreBean *)subBeans Funcs:(WSFuncsBean *)funcs;

@end
