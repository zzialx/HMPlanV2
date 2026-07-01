//
//  WSTodayVisitViewController.h
//  WinSFA

//      ****这个页面是用来替换WSInPlanViewController的****

//  Created by xiajl on 14-8-14.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreListBaseViewController.h"

#import "WSBaseStoreDBService.h"

typedef NS_ENUM(NSUInteger, WSTodayVisitCategory)
{
    WSTodayVisitCategoryNormal,        //今日拜访（计划内+已拜访计划外）
    WSTodayVisitCategoryInPlan         //计划内
};

@class WSFuncsBean,WSWorkFlowViewController,WSStoreBean;

@interface WSTodayVisitViewController : WSStoreListBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *shouldAddFilters;
@property (nonatomic, assign) BOOL hasVisitType;
@property (nonatomic, strong) NSArray *noTypeItems;
@property (nonatomic, strong) NSMutableArray *visitedStoreArray;
@property (nonatomic, strong) NSMutableArray *notVisitStoreArray;
@property (nonatomic, copy) NSString *currentAddStoreName;
@property (nonatomic, weak) WSWorkFlowViewController *currentViewController;
@property (nonatomic, strong) UIAlertView *alert;

/**
 *  other funcsbean
 */

//@property (nonatomic, strong)WSFuncsBean *outPlanFuncsBean;
//
//@property (nonatomic, strong)WSFuncsBean *outPlanFuncsBean_FC_IS_TAB_F2002;// 和outPlanFuncsBean的区别为fv一样fc不一样 且都是门店拜访下的同及子模块
//
//@property (nonatomic, strong)WSFuncsBean *subempOutPlanFuncsBean;// 主管协防的不实时搜索的计划外
//
//@property (nonatomic, strong)WSFuncsBean *outPlanSearchFuncsBean;
//
//@property (nonatomic, strong)WSFuncsBean *outPlanSearchFuncsBean2;
//
//@property (nonatomic, strong)WSFuncsBean *newstoreFuncsBean;
//
//@property (nonatomic, strong)WSFuncsBean *managV_OutPlanFucsBean;// 随访门店清单
//
//@property (nonatomic, strong)WSFuncsBean *storeListFucsBean;// 新增门店列表funcBean

//存放当前页面已有的 currentFuncs ,outPlanFuncsBean，
// outPlanSearchFuncsBean，newstoreFuncsBean，managV_OutPlanFucsBean

//@property (nonatomic, strong)NSMutableDictionary *funcsBeanDic;

@property (nonatomic ,assign)WSTodayVisitCategory todayVisitCategory;

- (id)initWithFuncs:(WSFuncsBean *)funcs;

- (void)initDataArrayFromDb;

/**
 *  add by wangdongyan 03-21
 *
 *  @param funcs  
 *  @param stores 随访的店
 *
 *  @return
 */
- (instancetype)initWithFuncs:(WSFuncsBean *)funcs Stores:(NSArray *)stores;

-(instancetype)initWithFuncs:(WSFuncsBean*)funcs SubempStoreBean:(WSSubempstoreBean *)subempStoreBean;

+(void)setCurrentCategory:(NSString *)aCategory;

+(NSString *) currentCategory;

- (BOOL)categoryInNoTypeItems;

-(void)startUpdata:(WSStoreBean*)store;

- (void)addSubEmpInplanStoresFromDb;

- (UIViewController *)generateNextVCWithFuncsBean:(WSFuncsBean *)fb   store:(WSStoreBean*)store isSelf:(BOOL)isSelf;

@end
