//
//  InfoPerformanceViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSEmpinforefreshBean.h"
#import "WSEmpinforefreshBeanArray.h"
#import "WSAppData.h"
#import "WSFuncsBean.h"
#import "BaseViewController.h"

@interface WSInfoPerformanceViewController : BaseViewController

@property (nonatomic, weak) UIViewController  *ownParentViewController;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) NSArray           *filtedData;
@property (nonatomic, strong) NSMutableArray  *titles;
@property (nonatomic, strong) UITableView     *myTabView;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

@end
