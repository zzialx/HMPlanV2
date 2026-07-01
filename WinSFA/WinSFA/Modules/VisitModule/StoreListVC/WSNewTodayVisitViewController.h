//
//  WSNewTodayVisitViewController.h
//  WinSFA
//
//  Created by sunhongfu on 2017/12/5.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "SuperWorkSpaceViewController.h"
#import "WSNewTodayVisitAndAllStoreCell.h"
#import "WSNewStoreListTool.h"
#import "WSPopViewController.h"
#import "WSWorkFlowViewController.h"
@class WSFuncsBean,WSStoreBean;

@interface WSNewTodayVisitViewController : SuperWorkSpaceViewController <UITableViewDataSource,UITableViewDelegate,WSNewTodayVisitAndAllStoreCellDelegate,WSPopViewControllerDelegate>
/*
 列表view
 */
@property (nonatomic, strong) UITableView       *todayVisitTableView;
/*
 门店数据
 */
@property (nonatomic, strong) NSMutableArray    *storeDataArray;

/*
 定位信息
 */
//#warning 感觉没用
//@property (nonatomic, strong) WSLocationDescribe *locationDescribe;


/*联合利华-拜访准备功能使用=========================================================================================*/

/*
 WSFuncsBean菜单model
 */
@property (nonatomic, strong) WSFuncsBean *prepareFuncBean;
@property (nonatomic, strong) WSFuncsBean *visitTypeFuncBean;
/*
 WSAcvtBean调查问卷model
 */
@property (nonatomic, strong) WSAcvtBean *prepareStateAcvtBean;
@property (nonatomic, strong) WSAcvtBean *visitTypeAcvtBean;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

/**
 *  add by wangdongyan 03-21
 *
 *  @param funcs
 *  @param stores 随访的店
 *
 *  @return
 */
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores;

- (instancetype)initWithFuncs:(WSFuncsBean*)funcs SubempStoreBean:(WSSubempstoreBean *)subempStoreBean;

//-(void)startUpdata:(WSStoreBean*)store;
- (UIViewController *)generateNextVCWithFuncsBean:(WSFuncsBean *)fb   store:(WSStoreBean*)store isSelf:(BOOL)isSelf;

@end
