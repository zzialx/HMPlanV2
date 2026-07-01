//
//  ManagersVisitViewController.m
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSManagersVisitViewController.h"
#import "SuperWorkSpaceViewController.h"
//#import "ConfigFileController.h"
#import "WSPlistHelper.h"
#import "WSReportFormController.h"
#import "WSStatisticsManager.h"
@implementation WSManagersVisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)valueChange:(id)sender
{
    for(UIView* view in [self.mainView subviews])
    {
        [view removeFromSuperview];
    }
    self.navigationItem.rightBarButtonItem = nil;
    if(self.selectViewController!= nil)
    {
        [self.selectViewController.view removeFromSuperview];
        [self.selectViewController removeFromParentViewController];
        self.selectViewController = nil;
    }
    NSInteger seleted = 0;
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *sc = (UISegmentedControl *)sender;
        seleted = sc.selectedSegmentIndex;
    }else if ([sender isKindOfClass:[NSNumber class]]) {
        seleted = [sender intValue];
    }

    WSFuncsBean* fb = [self.currentFuncs.funcsArray objectAtIndex:seleted];

    NSString *className = [WSPlistHelper valueForKey:fb.fv withPlistName:kControllerMappingFileName];
    SuperWorkSpaceViewController *vc = [[NSClassFromString(className) alloc]initWithFuncs:fb];
    
    if (vc != nil) {
        LogInfo(@"Going to init class: %@", vc);
        [self addChildViewController:vc];
        vc.ownParentViewController = self;
        vc.view.frame = self.mainView.bounds;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.mainView addSubview:vc.view];
        self.selectViewController = vc;
    }else {
        LogInfo(@"%@ is nil", className);
    }
    
     [[WSStatisticsManager sharedInstance] insertMenuPageSenceEventWithID:EVENT_MENU_CLICK parentFuncBean:self.currentFuncs.iParentFuncsBean currentFuncBean:self.currentFuncs store:self.currentStore eventValue:self.currentFuncs.name startTime:[WSCurrentTime getTimeMillisStringForDevice] endTime:nil genId:[WSStatisticsManager getGenId]];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.selectViewController isKindOfClass:[WSSubempLISTViewController class]])
    {
        WSSubempLISTViewController* subEmpList = (WSSubempLISTViewController*)self.selectViewController;
        [subEmpList.myTableView reloadData];
    }
     
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
