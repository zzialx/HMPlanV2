//
//  InfoSearchViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSInfoSearchViewController.h"
#import "WSInfoCustomerViewController.h"
#import "WSFuncsBean.h"
#import "WSInfoPerformanceViewController.h"
#import "WSInfoProdViewController.h"

@implementation WSInfoSearchViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewWillDisappear:(BOOL)animated
{
    LogTrace();
    [super viewWillDisappear:animated];
    LogInfo(@"\n[ LogInfo -  self.navigationController.toolbarHidden = YES; ]\n");
    self.navigationController.toolbarHidden = YES;
}


@end
