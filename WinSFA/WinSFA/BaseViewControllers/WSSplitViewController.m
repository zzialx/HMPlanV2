//
//  WSSplitViewController.m
//  WinSFA
//
//  Created by Stephanie on 16/8/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSplitViewController.h"
#import "WCBaseViewController.h"

@interface WSSplitViewController ()

@end

@implementation WSSplitViewController

- (void)dealloc
{
    LogTrace();
}

- (instancetype)initWithLeftController:(UIViewController *)leftController rightController:(UIViewController *)rightController
{
    self = [super init];
    
    if (self) {
        _leftViewController = leftController;
        _rightViewController = rightController;
        
        
        [self addChildViewController:_leftViewController];
        [self addChildViewController:_rightViewController];
        
        self.leftControllerWidth = 350;
        self.separatorLineColor = [UIColor colorWithHexString:@"#cdcdcd"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _leftViewController.view.frame = CGRectMake(0, 0, self.leftControllerWidth, self.view.bounds.size.height);
    _leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_leftViewController.view];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.leftControllerWidth, 0, 1, self.view.bounds.size.height)];
    line.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [line setBackgroundColor:self.separatorLineColor];
    [self.view addSubview:line];
    
    _rightViewController.view.frame = CGRectMake(self.leftControllerWidth+1, 0, self.view.bounds.size.width - self.leftControllerWidth, self.view.bounds.size.height);
    _rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_rightViewController.view];
    
}

- (void)showRightController:(UIViewController *)rightController
{
    [self performSelector:@selector(_showRightController:) withObject:rightController afterDelay:0.01];
}

- (void)_showRightController:(UIViewController *)rightController
{
    rightController.view.frame = _rightViewController.view.frame;
    rightController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_rightViewController removeFromParentViewController];
    [_rightViewController.view removeFromSuperview];
    
    _rightViewController = rightController;
    [self addChildViewController:_rightViewController];
    
    [self.view addSubview:_rightViewController.view];
}

@end
