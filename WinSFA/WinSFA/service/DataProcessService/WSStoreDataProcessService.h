//
//  WSStoreDataProcessService.h
//  
//
//  Created by yang on 15/12/24.
//
//

#import <Foundation/Foundation.h>
#import "WSBaseStoreAcvtTable.h"

@interface WSStoreDataProcessService : NSObject


+ (void)processStoreDisDataWithDic:(NSDictionary *)uploadState objID:(NSString *)objID storeID:(NSString *)storeID;

/**
 *
 *  更新本地StoreInfo节点下的数据
 *
 *  storeInfo 内包含两种业务
 *      1. 对当前登陆账号的业务, 这类业务的WSStoreInfoBean的empId属性不为空，storeId属性为空。
 *      2. 对当前进入的店的业务, 这类业务的WSStoreInfoBean的storeId属性不为空,empId属性为空。
 *
 *      self.currentFuncs.filter
 *
 *  @param uploadState  服务器返回的更新数据
 *  @param objID    要更新的节点
 *  @param filterString 过滤器，缩小更新范围 以前的业务所用
 */
+ (void)processStoreInfoDataWithDic:(NSDictionary *)uploadState objID:(NSString *)objID filter:(NSString *)filterString;


+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo;

+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo genId:(NSString *)genId;

+ (void)processStoreInfoDataToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo genId:(NSString *)genId isRemoteSearch:(BOOL)isRemoteSearch;

+ (void)processStoreInfoDataToDbWithStoresInfo:(NSDictionary *)storesInfo storeID:(NSString *)storeId genId:(NSString *)genId isRemoteSearch:(BOOL)isRemoteSearch ;

+ (void)saveStoreAcvtUploadCountToDbWith:(WSStoreBean *)store info:(NSDictionary *)storeInfo;

// YIHAIKERRY-3408 将多个门店下的节点数据拼接成一个节点下多个门店的数据，用于批量操作数据库
+ (NSDictionary *)convertStoresInfoDictionaryFromStores:(NSArray *)stores;

@end
