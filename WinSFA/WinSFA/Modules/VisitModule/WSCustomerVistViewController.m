//
//  CustomerVistViewController.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSCustomerVistViewController.h"
#import "WSFuncsBean.h"
#import "WSOutPlanViewController.h"
#import "WSInPlanViewController.h"
#import "WSOutPlanStoreBean.h"
#import "WSOtherDutyViewController.h"
#import "SuperWorkSpaceViewController.h"
#import "WSTodayVisitViewController.h"
#import "WSAllStoresViewController.h"

@implementation WSCustomerVistViewController

#pragma mark - View lifecycle


//-(void)dealloc
//{
//    self.selectViewController = nil;
//    self.mainView = nil;
//    self.currentFuncs = nil;
//}
//SFA-34145
//点击工作台，弹出调查问卷--SR角色：修复门店列表作为默认选择的时候不弹框的问题
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([WSAppData sharedManager].showHomePage) {
        return;
    }
//    [WSAppData sharedManager].showHomePage = YES;
//    WSFuncsBeanArray* fba= [WSAppData getObjectbyKey:FUNCS];
//    NSDictionary *showFuncsDict = [fba getShowFuncsBean];
//    LogInfo(@"门店列表自动跳转页面 = %@",showFuncsDict);
//    if ([[showFuncsDict objectForKey:IS_SHOW] isEqualToString:@"1"]) {
//        [self pushViewWithFuncsBean:[showFuncsDict objectForKey:FROM_FUNCS_BEAN] realSubFuncsBean:[showFuncsDict objectForKey:SHOW_FUNCS_BEAN]];
//    }
}

- (void)pushViewWithFuncsBean:(WSFuncsBean *)fb realSubFuncsBean:(WSFuncsBean *)realSubFuncsBean{
    WCBaseViewController* vc = [WCBaseViewController getControllerWithFuncsBean:fb realSubFuncsBean:realSubFuncsBean];
    
    if (vc) {
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end

