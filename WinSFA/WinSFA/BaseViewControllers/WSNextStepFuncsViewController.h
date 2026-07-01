//
//  WSNextStepFuncsViewController.h
//  WinSFA
//
//  Created by Alicia on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

// ⚠️ WSBaseWorkFlowViewController 需要重构为了避免重复代码暂时先继承自该类 ⚠️

#import "WCBaseViewController.h"
#import "WSBaseWorkFlowViewController.h"


@interface WSNextStepFuncsViewController : WSBaseWorkFlowViewController


- (instancetype)initWithFuncs:(WSFuncsBean *)funcs  store:(WSStoreBean *)store subempStore:(WSSubempstoreBean *)subempStore acvtNewStore:(WSStoreBean *)acvtNewStore moduleFC:(NSString *)moduleFC;

- (UIViewController *)addOtherControllerToView:(UIViewController *)viewController;


@end
