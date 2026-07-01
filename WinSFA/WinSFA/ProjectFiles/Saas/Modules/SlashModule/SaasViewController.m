//
//  SaasViewController.m
//  WinChannelFrameWork
//
//  Created by Jiepeng Zheng on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SaasViewController.h"

@interface SaasViewController ()
{
    NSTimer *timer;
}
@end

@implementation SaasViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                 target:self
                                               selector:@selector(enter)
                                               userInfo:nil 
                                                repeats:NO];
        return self;
    }
    return nil;
}

- (void)enter
{
    self.view.hidden = YES;
    [UIView transitionWithView:self.view.window 
                      duration:1 
                       options:UIViewAnimationOptionTransitionCurlUp 
                    animations:nil
                    completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [timer fire];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
    imageView.image = [UIImage imageNamed:@"Saas2"];
    [self.view addSubview:imageView];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
