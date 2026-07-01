//
//  LoginViewController.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-14.
//  Copyright 2011年 dumbrock. All rights reserved.
// tester 1

#import <UIKit/UIKit.h>
#import "WSInoutStoreTable.h"
#import "WSFptTable.h"
#import "WSFacTable.h"
#import "WSFdtTable.h"
#import "WSOffLineUploadTable.h"
#import "WSAddStoreTable.h"
#import "WSAppSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WSCurrentTime.h"
#import "WSAppGuidanceViewController.h"
#import "WSAuthorizationViewController.h"
#import "WCBaseViewController.h"
#import "JFTakeCountButton.h"

#define GETSERVERTIME_NOTIFY @"getservertime"
//===================================================================================================================================================================

@interface WSLoginViewController : WCBaseViewController <UITextFieldDelegate, UIAlertViewDelegate, WSAuthorizationViewControllerDelegate>
{
    UIActivityIndicatorView *aiv;
    UILabel                 *loginstate;
    UIButton                *cancelBtn;
    UITextView              *phoneNumber;
}

@property (nonatomic, strong) UIButton *changePasswd;
@property (nonatomic, strong) UIButton *rememberUsername;
@property (nonatomic, copy)   NSString *passwdcache;
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UILabel *loginstate;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UITextView *phoneNumber;
@property (nonatomic, strong) NSString *startUpdateTime;
@property (nonatomic, strong) NSString *currentUpdateTime;

- (void)createLoginBoxView;
- (void)loginStart:(id)sender;
- (void)modifyPasswd:(id)sender;
- (BOOL)offlineLoginWhenLaunch;

@end
//===================================================================================================================================================================

