//
//  WorkFlowViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WSFuncsBeanArray.h"
#import "WSBaseWorkFlowViewController.h"

@class  WSFuncsBean;
@class  WSStoreBean;

@interface WSWorkFlowViewController : WSBaseWorkFlowViewController {}




- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;
//unredo 可能和所传的funcs 不相等，所以单独传 
- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store unredo:(NSString *)unredo;


-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore;

-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store subEmpStore:(WSSubempstoreBean *)subEmpStore unredo:(NSString *)unredo;

/**
 用与对店的新增门店 acvtNewStore是在店的拜访项中新增的门店（调查问卷）
 */
-(id)initWithFuncs:(WSFuncsBean*)funcs Store:(WSStoreBean*)store acvtNewStore:(WSStoreBean *)acvtNewStore;

- (WCBaseViewController *)getDefaultShowController;


@end
