//
//  VisitDoctorViewController.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-15.
//
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"

#import "WSVisitDoctorTableViewCell.h"

#import "WSSplitViewController.h"

#import "WSWorkFlowViewController.h"



@interface VisitDoctorViewController : WCBaseViewController

- (id)initWithFuncs:(WSFuncsBean *)funcs;
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean*)store;

@end
