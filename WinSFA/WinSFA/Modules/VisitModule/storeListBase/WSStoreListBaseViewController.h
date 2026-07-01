//
//  WSStoreListBaseViewController.h
//  WinSFA
//
//  Created by yang on 17/1/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreBaseViewController.h"
@class WSWorkFlowViewController;

@interface WSStoreListBaseViewController : WSStoreBaseViewController <WSSelectListNewTableviewCellDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *storeArray;
@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) NSMutableArray *todayVisitStoreArray; //<今日拜访门店
@property (nonatomic, strong) NSMutableArray *actualVisitStoreArray;//<拜访门店不分页查询
@property (nonatomic, strong) WSLocationDescribe *locationDescribe;
@property (nonatomic, strong) NSMutableDictionary *foldStateDic;    //存储展开和关闭协议的状态
@property (nonatomic, strong) WSFuncsBean *prepareFuncBean;
@property (nonatomic, strong) WSAcvtBean *prepareStateAcvtBean;
@property (nonatomic, strong) WSFuncsBean *visitTypeFuncBean;
@property (nonatomic, strong) WSAcvtBean *visitTypeAcvtBean;

- (void)setAccessFlag:(UITableViewCell *)cell Store:(WSStoreBean *)store;
- (NSArray *)sortStoreListArrayByVisitAction:(NSArray *)storeListArray;
- (BOOL)anyStoreHasNotLeave:(WSStoreBean *)aStore andModuleFC:(NSString *)store_moduleFC;
- (BOOL)isVisitedStore:(WSStoreBean *)aStore;
- (NSString *)getActionStateByStore:(WSStoreBean*)store andmodule_fc:(NSString *)module_fc;
- (NSString *)getStoreVisitStatusWith:(WSStoreBean *)store andParentFc:(NSString *)module_fc action:(WSVisitStoreActionObject *)action;
- (NSString *)getStoreVisitStatusWith:(WSStoreBean  *)store andParentFc:(NSString *)module_fc;
- (void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store andParentFc:(NSString *)module_fc;
- (void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store andParentFc:(NSString *)module_fc action:(WSVisitStoreActionObject *)action;
- (NSString *)getStoreVisitStatusWith:(WSStoreBean *)store isNotUseParentFC:(BOOL)isNotUseParentFC;
- (void)setAccessFlag:(UITableViewCell*)cell Store:(WSStoreBean*)store isNotUseParentFC:(BOOL)isNotUseParentFC;
- (NSInteger)getCount:(NSArray *)storeListArray withVisitActionStatus:(VisitActionStatus)visitActionStatus;
- (NSArray *)sortInplanStoreArrayByVisitPlan:(NSArray *)storeArray;
- (void)gotoWorkFlowController:(WSWorkFlowViewController *)wfvc;
- (void)showWorkFlowInSplitViewController:(WCBaseViewController *)controller;
- (NSString *)getFuncCodeWithFuncBean:(WSFuncsBean *)storeFuncs  andFunBeanDic:(NSDictionary *)fcBeanDic;
- (WSVisitStoreActionObject *)getPrepareFuncBeanVisitActionByStore:(WSStoreBean *)store;
- (WSStorePrepareState)getPrepareStateByStore:(WSStoreBean *)store;
- (NSString *)getVisitTypeByStore:(WSStoreBean *)store bizDate:(NSString *)bizDate;
- (NSString *)getVisitTypeByStore:(WSStoreBean *)store;
- (void)showVisitTypeControllerWithStore:(WSStoreBean *)store date:(NSString *)date;
- (BOOL)isUseFilterArray;
- (void)resortByVisitStateAndDistance:(CGFloat)distance;
- (void)resortStoreWithDistance;
- (void)addToolBar;
- (void)reloadStoreList;
- (void)resetLocation:(NSString *)administrativeArea locality:(NSString *)locality subLocality:(NSString *)subLocality;
- (void)needGps;
- (void)gotoSpecialViewController:(WSStoreBean *)store withFc:(NSString *)fc;
- (BOOL)isExistStoreOptRemindWithStoreBean:(WSStoreBean *)storeBean; 

@end
