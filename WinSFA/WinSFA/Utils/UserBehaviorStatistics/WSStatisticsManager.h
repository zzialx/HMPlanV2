//
//  WSStatisticsManager.h
//  WinSFA
//
//  Created by yang on 17/6/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSStatisticsDefine.h"

@interface WSStatisticsManager : NSObject

+ (WSStatisticsManager *)sharedInstance;

+ (NSString *)getGenId;

//监听登录事件方法
- (BOOL)insertLoginSenceEventWithID:(NSString *)eventID
                          startTime:(NSString *)startTime
                            endTime:(NSString *)endTime
                         eventValue:(NSString *)eventValue
                              genId:(NSString *)genId;

//监听报表事件方法
- (BOOL)insertWebPageSenceEventWithID:(NSString *)eventID
                       parentFuncBean:(WSFuncsBean *)parentFuncBean
                      currentFuncBean:(WSFuncsBean *)currentFuncBean
                                store:(WSStoreBean *)store
                            startTime:(NSString *)startTime
                              endTime:(NSString *)endTime
                                genId:(NSString *)genId;

// 对应 SCENE_NORMAL_PAGE 场景，执行的监听方法
- (BOOL)insertNormalPageSenceEventWithID:(NSString *)eventID
                          parentFuncBean:(WSFuncsBean *)parentFuncBean
                         currentFuncBean:(WSFuncsBean *)currentFuncBean
                                   store:(WSStoreBean *)store
                               startTime:(NSString *)startTime
                                 endTime:(NSString *)endTime
                                   genId:(NSString *)genId;

// SFA-26499
#pragma mark 对应 EVENT_MENU_CLICK 点击菜单场景，执行的监听方法
- (BOOL) insertMenuPageSenceEventWithID :(NSString *)eventID
                         parentFuncBean :(WSFuncsBean *)parentFuncBean
                         currentFuncBean :(WSFuncsBean *)currentFuncBean
                                  store :(WSStoreBean *)store
                             eventValue :(NSString *)eventValue
                              startTime :(NSString *)startTime
                                endTime :(NSString *)endTime
                                  genId :(NSString *)genId;

#pragma mark 对应订单列表 监听方法
- (BOOL) insertAddProductSenceEventWithID :(NSString *)eventID
                         parentFuncBean :(WSFuncsBean *)parentFuncBean
                        currentFuncBean :(WSFuncsBean *)currentFuncBean
                                  store :(WSStoreBean *)store
                               eventValue :(NSString *)eventValue
                              startTime :(NSString *)startTime
                                endTime :(NSString *)endTime
                                  genId :(NSString *)genId;

#pragma mark 对应进入门店查看二维码执行的监听方法
- (BOOL) insertStoreInfoSenceEventWithID :(NSString *)eventID
                           parentFuncBean :(WSFuncsBean *)parentFuncBean
                          currentFuncBean :(WSFuncsBean *)currentFuncBean
                                    store :(WSStoreBean *)store
                                 senceId :(NSString *)senceId
                               eventValue :(NSString *)eventValue
                                startTime :(NSString *)startTime
                                  endTime :(NSString *)endTime
                                    genId :(NSString *)genId;

- (BOOL)updateEndTime:(NSString *)endTime withGenID:(NSString *)genID;

- (BOOL)updateStartTime:(NSString *)startTime withGenID:(NSString *)genID;

- (void)uploadStatisticsLogs;

@end
