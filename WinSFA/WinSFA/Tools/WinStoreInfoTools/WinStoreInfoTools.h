//
//  WinStoreInfoTools.h
//  WinSFA
//
//  Created by yuanji on 2022/11/12.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WinStoreInfoTools : NSObject

//请求门店信息方法
- (void)requestStoreInfoWithStoreId:(NSString *)storeId
                         notifyName:(NSString *)notifyName;

//解析全部门店数据到数据库方法
- (void)analysisAllStoresInfoToDBWithDictionary:(NSDictionary *)dictionary
                                          objId:(NSString *)objId;

//查询门店对象方法
- (WSStoreBean *)queryStoreBeanWithStoreId:(NSString *)storeId;

//是否可以拜访门店方法
- (BOOL)isVisitStoreWithStoreId:(WSStoreBean *)storeBean
                      funcsBean:(WSFuncsBean *)funcsBean;

//更新当前门店方法
- (void)updateCurrentStoreWithStoreBean:(WSStoreBean *)storeBean
                              storeInfo:(NSDictionary *)dictionary
                                  objId:(NSString *)objId;

//更新当前门店其它数据方法
- (void)updateCurrentStoreOtherDataWithStoreBean:(WSStoreBean *)storeBean
                                       storeInfo:(NSDictionary *)dictionary
                                            flag:(NSString *)flag;

//查找门店拜访项方法
- (WSVisitStoreActionObject *)findActionIDAndCreateNextAction:(WSFuncsBean *)funcsBean
                                           currentVisitAction:(WSVisitStoreActionObject * __nullable)currentAction
                                                      storeId:(NSString *)store_id
                                             subMenuFuncsCode:(NSString *)subMenuFuncsCode
                                                    storeBean:(WSStoreBean *)storeBean;

@end

NS_ASSUME_NONNULL_END
