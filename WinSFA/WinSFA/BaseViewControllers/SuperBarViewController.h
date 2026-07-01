//
//  SuperBarViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-5.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"
#import "SuperWorkSpaceViewController.h"

@class WSFuncsBean;

@interface SuperBarViewController : WCBaseViewController<SuperWorkSpaceViewControllerDelegate>
{}
@property (nonatomic, strong) UIView            *mainView;
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) UIViewController  *selectViewController;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *pageViewSubViewControllersArray;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

- (void)addSelfMainView;

-(void)initializationBackItemAction;

-(void)valueChange:(id)sender;

- (BOOL)JumpToNext;

@end
