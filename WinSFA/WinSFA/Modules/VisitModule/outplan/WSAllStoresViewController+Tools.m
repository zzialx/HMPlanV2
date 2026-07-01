//
//  WSAllStoresViewController+Tools.m
//  WinSFA
//
//  Created by zzialx on 2025/5/20.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import "WSAllStoresViewController+Tools.h"

@implementation WSAllStoresViewController (Tools)

#pragma mark -  # 进入助销模块
- (void)gotoHelpSalesMoudleWithStore:(WSStoreBean*)store{
    
    WSWorkFlowViewController* wfvc = nil;
    WSFuncsBeanArray* funcsArray=[WSAppData getObjectbyKey:FUNCS];
    WSFuncsBean * helpSalesMoudleFuncBean = [funcsArray getHideFuncsBeanWithFC:self.currentFuncs.opt.salesAssistanceMenu];
    LogInfo(@"助销菜单：%@",helpSalesMoudleFuncBean.name);
    
    wfvc = [[WSWorkFlowViewController alloc] initWithFuncs:helpSalesMoudleFuncBean Store:store unredo:self.currentFuncs.unredo];
    if ([store.name isKindOfClass:[NSString class]] && ![store.name isEqualToString:@""]) {
        NSString *title = nil;
        if ([store.code isKindOfClass:[NSString class]] && [store.code length] > 0) {
             title = [NSString stringWithFormat:@"%@-%@", store.code, store.name];
        } else {
             title = store.name;
        }
        wfvc.title = title;
    }
    WSVisitStoreActionObject * visitAction = [self findActionIDAndCreateNextAction:helpSalesMoudleFuncBean andCurrentVisitAction:self.currentVisitAction andStoreId:store.Id subMenuFuncsCode:self.subMenuFuncsCode];
    visitAction.fromModuleName = kHelpSalesName;
    wfvc.currentVisitAction =  visitAction;
    wfvc.moduleFC = visitAction.func_code;
    wfvc.realParentFuncsCode = self.currentFuncs.fc;
    if (self.subMenuFuncsCode != nil && self.subMenuFuncsCode.length > 0) {
        wfvc.moduleFC = self.subMenuFuncsCode;
    }
    if (wfvc) {
        [self gotoWorkFlowController:wfvc];
    }else{
        LogError(@"未找到助销模块VC");
    }
    
}
#pragma mark -  # 结束编辑
- (void)endEdit{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}


@end
