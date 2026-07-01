//
//  WCNavigationController.m
//  QuadCore
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCNavigationController.h"
#import "WCNavBar.h"
#import "WSDeviceRotateTool.h"

@interface WCNavigationController ()

@end

@implementation WCNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundColor:[UIColor whiteColor]];
}

#pragma mark - About rotate

// iOS6以前
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.shouldRotate) {
        return YES;
    }
    else
    {
        if (INTERFACE_IS_PAD) {
            return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
        }
        else
        {
            return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        }
    }
}

// iOS6及以后
- (BOOL)shouldAutorotate
{
    return [WSDeviceRotateTool shouldAutorotate];
    //    if (INTERFACE_IS_PHONE) {
    //        return NO;
    //    } else {
    //        return YES;
    //    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.shouldRotate) {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return [WSDeviceRotateTool supportedInterfaceOrientations];
        //        if (INTERFACE_IS_PAD) {
        //            return UIInterfaceOrientationMaskLandscape;
        //        }
        //        else
        //        {
        //            return UIInterfaceOrientationMaskPortrait;
        //        }
    }
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return  [WSDeviceRotateTool preferredInterfaceOrientationForPresentation];
    /*
     return [self.topViewController preferredInterfaceOrientationForPresentation];
     return self.interfaceOrientation ios8 之后已经废弃 create by 孙洪福
     return self.interfaceOrientation;
     */
}

#pragma mark - About memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
