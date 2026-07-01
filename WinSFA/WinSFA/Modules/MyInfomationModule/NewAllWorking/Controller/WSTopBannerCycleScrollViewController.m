//
//  WSTopBannerCycleScrollViewController.m
//  WinSFA
//
//  Created by yang on 17/4/6.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSTopBannerCycleScrollViewController.h"
#import "WSTopBannerCycleScrollView.h"

#define k_TopMsgViewHeight_iPad   260


#define k_TopMsgViewHeight (INTERFACE_IS_PHONE ? (self.view.width * k_TopMsgViewWHRatio) : k_TopMsgViewHeight_iPad)

@interface WSTopBannerCycleScrollViewController ()

@end

@implementation WSTopBannerCycleScrollViewController

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs {
    self = [super initWithFuncs:funcs];
    if (self) {
        if (![self setupViews]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)setupViews {
    WSTopBannerCycleScrollView *topBannerCycleScrollView = [[WSTopBannerCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, k_TopMsgViewHeight) withUseTitle:YES];
    if (!topBannerCycleScrollView) {
        return NO;
    }
    topBannerCycleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:topBannerCycleScrollView];
    return YES;
}


- (CGFloat)contentHeight {
    return k_TopMsgViewHeight;
}

@end
