//
//  WSBaseWorkFlowViewController.h
//  WinSFA
//
//  Created by yang on 16/12/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"

@interface WSBaseWorkFlowViewController : SuperWorkSpaceViewController

@property (nonatomic, strong) NSArray *funcBeanArray;
@property (nonatomic, strong) NSArray *dictBeanArray;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, weak) UIViewController      *backVC;        //返回时自定的界面

- (void)initFuncsBeanData;
- (void)initDictBeanAndDataSource;

- (UIViewController*)checkNextPageWithFuncsBean:(WSFuncsBean*)fb withShowToast:(BOOL)showToast;

- (UIViewController*)checkNextPageWithFuncsBean:(WSFuncsBean*)fb withShowToast:(BOOL)showToast isInStore:(BOOL)isInStore;

-(BOOL) gotoNextPageWithViewController:(UIViewController*)tmpVc
                         withFuncsBean:(WSFuncsBean*)fb
                          withAutoJump:(BOOL)isAuto;

- (BaseViewController *)getValidNextControllerWithVC:(UIViewController*)tmpVc
                                       withFuncsBean:(WSFuncsBean*)fb
                                        withAutoJump:(BOOL)isAuto;

- (BaseViewController *)getValidNextControllerWithVC:(UIViewController*)tmpVc
                                       withFuncsBean:(WSFuncsBean*)fb
                                        withAutoJump:(BOOL)isAuto
                                           isInStore:(BOOL)isInStore;

- (BOOL)checkEnterLeaveStore:(WSFuncsBean *)fb showToast:(BOOL)showToast;

- (void)pushViewController:(UIViewController *)controller isAutoJump:(BOOL)isAutoJump;

- (UIViewController *)rebuildEnterSoreViewControllerIfExistFilter:(WSFuncsBean *)fb;

- (VisitActionStatus)getVisitActionStatusWithFuncsBean:(WSFuncsBean *)funcsBean action:(WSVisitStoreActionObject *)action;

- (WSVisitStoreActionObject *)queryVisitActionObjectWithFuncsBean:(WSFuncsBean *)funcsBean;

- (BOOL)isExistNewAcvtAndAcvtListWithFuncsBean:(WSFuncsBean *)aFuncsBean withStoreBean:(WSStoreBean *)aStoreBean;

- (BOOL)isVisitedStore:(WSStoreBean *)aStore withParentFuncCode:(NSString *)parentFC;

- (void)reloadView;

- (void)removeSelection;

- (void)reloadHeaderView;

- (void)startUpdateStoreWithFb:(WSFuncsBean *)fb;

// SFA-15017 是否需要显示警告图标， ST 类型的问题，并且问题的回显值不是 0 返回 YES
- (BOOL)hasTipsWithStore:(WSStoreBean *)aStore funcCode:(WSFuncsBean *)fb;

- (void)loadSuggestOrderInfo;

@end
