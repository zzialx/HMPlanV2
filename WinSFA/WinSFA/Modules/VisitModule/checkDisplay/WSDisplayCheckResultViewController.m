//
//  DisplayCheckResultViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSDisplayCheckResultViewController.h"

@implementation WSDisplayCheckResultViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
}

- (id)initWithArray:(NSArray *)array Funcs:(WSFuncsBean *)fb
{
    return nil;
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
