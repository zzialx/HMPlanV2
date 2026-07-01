//
//  SuperWorkSpaceViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-12-15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreBean.h"
#import "WCBaseViewController.h"

#import "WSSubempstoreBean.h"

#import "WSHosBean.h"

#import "WSSelectListNewTableviewCell.h"

//YIHAIKERRY-4353 工作查询额外提醒闭包 isSuccess:是否成功 result:结果
typedef void (^WCWorkQueryAdditionalRemindBlock)(BOOL isSuccess, NSString *result);

@class SuperWorkSpaceViewController;

@protocol SuperWorkSpaceViewControllerDelegate <NSObject>

- (void)superWorkSpaceVC:(SuperWorkSpaceViewController *)controller refreshControllerTitle:(NSString *)title;

@end

@class WSFuncsBean;
@class WSStoreBean;
@class WSAcvtBean;
@interface SuperWorkSpaceViewController : WCBaseViewController
{}
@property (nonatomic, strong) WSFuncsBean         *currentFuncs;
@property (nonatomic, strong) WSStoreBean         *currentStore;
@property (nonatomic, strong) WSStoreBean         *acvtNewStore;
@property (nonatomic, strong) WSAcvtBean          *currentAcvt;
@property (nonatomic, strong) NSNumber *originalViewYPosition;
@property (nonatomic, assign) BOOL parentViewHasSegment;
@property (nonatomic, strong) WSSubempstoreBean *subempStore;

@property (nonatomic,strong) WSHosBean *hosBean;

@property (nonatomic, strong) NSString *subMenuFuncsCode;

@property (nonatomic, strong) WSFuncsBean *subMenuFuncsBean;

@property (nonatomic, weak) id<SuperWorkSpaceViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isLoaded;

//TB层的module_fc传下去主要为了区分不同模块（同九宫格）下的门店拜访（方便从门店向上回溯遍历本模块fc树）。
@property (nonatomic, copy)NSString *moduleFC;

@property (nonatomic, assign) BOOL refreshVisitFlagWhenBackTo;

@property(nonatomic, copy) NSString *unredo;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store;

- (id)initWithFuncs:(WSFuncsBean *)funcs subempStore:(WSSubempstoreBean *)store;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store subEmpStore:(WSSubempstoreBean *)subEmpStore; ;

- (id)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store hosBean:(WSHosBean*)hosBean;

- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Store:(WSStoreBean *)store acvtNewStore:(WSStoreBean *)acvtNewStore;

- (int) initializationSelectSegment;

- (void)initializationBackItemAction;

- (void)refreshControllerTitle:(NSString *)title;

//门店修改使用的实时请求的方法
- (void)startGetStoreInfoBySotre:(WSStoreBean *)store;
//找 func SFA-22607 donghong
- (WSFuncsBean *)getRealFuncBeanNeedSubMenu:(BOOL)needSubMenu;

//查询额外提醒方法 empId:用户id storeId:门店id completionBlock:完成闭包
- (void)queryAdditionalRemindWithEmpId:(NSString *)empId storeId:(NSString *)storeId completionBlock:(WCWorkQueryAdditionalRemindBlock)completionBlock;

@end
