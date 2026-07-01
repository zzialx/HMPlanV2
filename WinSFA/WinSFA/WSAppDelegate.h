//
//  WSAppDelegate.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WSLocationManager.h"
#import "SaasViewController.h"
#import "SaasEnterViewController.h"
#import "WSRegisterViewController.h"
#import "WinJSBridgeViewController.h"
#import "EMSDK.h"
#import "BlockAlertView.h"

#define  UNLEAVED_STORE_PUSH            @"UNLEAVED_STORE_PUSH_KEY"
#define  LOCAL_PUSH_KEY                 @"LOCAL_PUSH_KEY"
#define  UNUPLOADDATA_COUNT_PUSH        @"UNUPLOAD_COUNT_PUSH"
#define  UNUPLOADDATA_COUNT_KEY         @"UNUPLOAD_COUNT_KEY"
#define  CHANGGE_MAINCELL_STATENORMAL   @"ChangeMainCellStateNormal"
#define  EASEMOB_RECEIVE_MESSAGE_PUSH   @"EASEMOB_RECEIVE_MESSAGE_PUSH"
#define  EASEMOB_RECEIVE_MESSAGE_KEY    @"EASEMOB_RECEIVE_MESSAGE_KEY"
#define  SHORTCUT_PUSH_KEY              @"SHORTCUT_PUSH_KEY"

@class  WSLoginViewController;
@class  WSModifyPasswdViewController;
@class  WCBaseViewController;

@interface WSAppDelegate : UIResponder <UIApplicationDelegate> {
    
    EMConnectionState _connectionState;
}

@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) SaasViewController *saasVC;
@property (nonatomic, strong) SaasEnterViewController *saasEnterViewControll;
@property (nonatomic, strong) WCBaseViewController * chatViewControll;
@property (nonatomic, strong) WCBaseViewController *welcomeReportVC;
@property (nonatomic, strong) WSRegisterViewController *registerVC;
@property (nonatomic, strong) WinJSBridgeViewController * chatVC;
@property (nonatomic, strong) NSDictionary * chatNotifiInfo;
@property (nonatomic, strong) UIAlertController * alert;
@property (nonatomic, assign) BOOL isUploadDeviceTokenSuccess;
@property (nonatomic, assign) BOOL isUpdatingLocation;
@property (nonatomic, assign) BOOL easeMobIsLogging;
@property (nonatomic, assign) BOOL sfaHasLogin;
@property (nonatomic, assign) NSInteger easeMobLoginRetryCount;
@property (nonatomic, copy) NSString *remoteNoticeDeviceToken;

- (NSURL *)applicationDocumentsDirectory;
- (NSInteger)getUnReadMsgNumber;
- (NSInteger)getNotoMsgNumber;
- (NSDate *)getForceQuitTime;
- (void)locationTimerAction;
- (void)showLoginAndClearAppDatasByIsLogout:(BOOL)isLogout;
- (void)removeAllLocalNotification;
- (void)clearCookies;
- (void)createLocalNotificationWithTitle:(NSString*)title message:(NSString*)msg;
- (void)callOrDownLoadOtherAPPWith:(WSFuncsBean *)funcs;
- (void)callOrDownLoadOtherAPPWith:(WSFuncsBean *)funcs paramsDic:(NSDictionary *)paramsDic;

@end
