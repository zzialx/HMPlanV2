//
//  WSStoreService.h
//  WinSFA
//
//  Created by winchannel on 15/7/29.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseService.h"


typedef NS_ENUM(NSUInteger, WSTodayVisitCategory)
{
    WSTodayVisitCategoryNormal,        //今日拜访（计划内+已拜访计划外）
    WSTodayVisitCategoryInPlan         //计划内
};

@class WSStoreBean;
@class WSVisitStoreActionObject;
@interface WSStoreService : WSBaseService{
    
    NSMutableDictionary *interactiondict; //存储操作的字典
    
    WSStoreBean *currentStore;  //当前门店
    
    WSFuncsBean *currentFuncs;  //当前函数

    WSInterAction *current_interaction;

    WSVisitStoreActionObject *currentVisitAction;
    
    
}


@property (nonatomic, strong)WSFuncsBean *outPlanFuncsBean;

@property (nonatomic, strong)WSFuncsBean *outPlanSearchFuncsBean;

@property (nonatomic, strong)WSFuncsBean *outPlanSearchFuncsBean2;

@property (nonatomic, strong)WSFuncsBean *newstoreFuncsBean;

@property (nonatomic,strong) NSMutableDictionary *funcsBeanDic;

@property (nonatomic ,assign) WSTodayVisitCategory todayVisitCategory;

//查询门店列表根据功能信息

-(void)queryStoreListByFunc:(WSInterAction *)interaction;

-(void)generateJumpInfo:(WSInterAction *)interaction;

@end
