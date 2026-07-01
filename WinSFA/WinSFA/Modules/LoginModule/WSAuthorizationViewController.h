//
//  WSAuthorizationViewController.h
//  WinSFA
//
//  Created by heju on 14-11-7.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//  法律申明授权页面

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol WSAuthorizationViewControllerDelegate;

@interface WSAuthorizationViewController : UIViewController
@property (nonatomic, weak) id<WSAuthorizationViewControllerDelegate> delegate;

@end

@protocol WSAuthorizationViewControllerDelegate  <NSObject>

- (void)wsAuthorizationViewController:(WSAuthorizationViewController*)authorizationVC didSelected:(UIButton *)sender;

@end
