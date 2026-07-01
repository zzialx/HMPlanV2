//
//  WSMapViewController.h
//  WinSFA
//
//  Created by heju on 14/12/24.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//


#import "WCBaseViewController.h"

#import "WSWorkFlowViewController.h"

#import "WSFuncsBean.h"

#import "WSStoreBean.h"

#import "WSMapView.h"

@class WSAllStoresViewController;
@class WSAcvtSearchStoreView;
@interface WSAllStoresMapViewController : WCBaseViewController <WSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic,strong)WSAcvtSearchStoreView *acvtSearchStoreView;
@property (nonatomic,strong) WSAcvtBean *acvtBeanForSearchStore;
@property (nonatomic , copy) NSString *subempStoreId;
@property (nonatomic , copy) NSString *subMenuFuncsCode;
@property (nonatomic , copy) NSString *routeMapId; // 如果有路线id的话 走路线加载地图逻辑
@property (nonatomic , copy) NSString *rightButtonName; // SFA-16294  地图中返回按钮重新设计
@property (nonatomic , strong) WSStoreBean * storeMap; // 蒙牛门店详情点击地址跳转地图。
@property (nonatomic , copy) NSString *searchObjId;     //MMSH-3235  实时收索时请求的和查询数据的节点 add by zhiqing



-(instancetype)initWithFuncs:(WSFuncsBean*)funcs inPlanFuncs:(WSFuncsBean *)inPlanFuncs;

-(void)reloadMapViewWith:(NSArray *)stores;

@end
