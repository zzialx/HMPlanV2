//
//  PromOptViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-1-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSPromOptViewController.h"

@implementation WSPromOptViewController
@synthesize isUpdata;

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
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 50)];
    NSString *PerformString = NSLocalizedString(@"是否执行",nil);
    label.text = PerformString;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    UISwitch* st = [[UISwitch alloc]initWithFrame:CGRectMake(100, 10, 30, 50)];
    self.isUpdata = st;
    [self.view addSubview:self.isUpdata];
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
