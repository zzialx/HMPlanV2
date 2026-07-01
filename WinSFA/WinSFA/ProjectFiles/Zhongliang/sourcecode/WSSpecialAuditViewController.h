//
//  WSSpecialAuditViewController.h
//  Zhongliang
//
//  Created by xiaotang.wang on 8/27/13.
//  Copyright (c) 2013 Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "SuperWorkSpaceViewController.h"
#import "WSPointInfo.h"

#define ACVTS_ZXJH_NODE_FOR_ZHONGLIANG @"acvt_zxjh"  // 专项稽核单独的acvt节点 只为中粮


typedef enum {
    WSAuditBrandLevelWorkState,
    WSAuditFindPointWorkState,
    WSAuditFindAcvtListFromNetWorkState
}WSSpecialAuditWorkState;

@interface WSSpecialAuditViewController : SuperWorkSpaceViewController

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean;

- (id)initWithFuncs:(WSFuncsBean *)aFuncsBean withPointInfo:(WSPointInfo *)aInfo;

@end
