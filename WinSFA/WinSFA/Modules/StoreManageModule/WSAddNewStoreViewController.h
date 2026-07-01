//
//  AddNewStoreViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSAcvtViewController.h"
#import "WSAddStoreTable.h"
#import "WSSelectListView.h"
#import "WSWorkFlowViewController.h"
#import "SuperWorkSpaceViewController.h"
#import "WSWidget.h"
#import "I_W_BuildInfo.h"
#import "WSAddNewStoreSelectView.h"
#import "WSBaseService.h"




typedef enum  {
   BTN_STATUS_REFRESH,
   BTN_STAUS_UPLOAD,
}BTN_STAUS;

@class WSAddNewStoreViewController;

@protocol WSAddNewStoreViewControllerDelegate <NSObject>

- (void)toBeVisitedStore:(WSStoreBean *)storeBean;

@end

@interface WSAddNewStoreViewController : WSAcvtViewController <ZJPSelectListDelegate,WSBaseServiceDelegate> {}

@property (nonatomic, weak) NSDictionary  *m_dataSources;

@property (nonatomic, strong) WSHTextField  *textField;

@property (nonatomic,assign) BTN_STAUS  refresh_status;

@property (nonatomic , weak) id<WSAddNewStoreViewControllerDelegate>delegate;


- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (id)initWithFuncs:(WSFuncsBean *)funcs acvtId:(NSString *)acvtId genId:(NSString *)genId newStoreId:(NSString *)newStoreId;
- (id)initWithFuncs:(WSFuncsBean *)funcs acvtBean:(WSAcvtBean *)acvtBean storeBean:(WSStoreBean *)storeBean;

@end
