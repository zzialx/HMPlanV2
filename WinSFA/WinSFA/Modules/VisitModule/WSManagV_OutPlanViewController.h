//
//  ManagV_OutPlanViewController.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSSubempstoreBean.h"
#import "WSSubempstoreBeanArray.h"
#import "WSFuncsBeanArray.h"
#import "WSAppData.h"
#import "WSRequestHelper.h"
#import "WSCustomerQueryViewController.h"
#import "WSWorkFlowViewController.h"

#define CQ_OUT_NOTIFY @ "OutSubEmpNotify"

@interface WSManagV_OutPlanViewController : WSCustomerQueryViewController {
//    WSSubempstoreBean *currentSubBean;
}

@property (nonatomic, strong) WSSubempstoreBean *currentSubBean;

@property (nonatomic, strong) NSMutableArray *resultDataArray;
@property (nonatomic, strong) NSMutableString *searchResult;

- (id)initWithSubBeans:(WSSubempstoreBean *)subBeans Funcs:(WSFuncsBean *)funcs;
@end
