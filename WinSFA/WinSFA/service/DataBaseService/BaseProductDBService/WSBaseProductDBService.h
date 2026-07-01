//
//  WSBaseProductDBService.h
//  WinSFA
//
//  Created by weida on 15/12/25.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"

@interface WSBaseProductDBService : WSDBService


- (NSArray *)queryMoreProductsWithStoreId:(NSString *)storeId
                                    brand:(NSString *)brand
                                    pType:(NSString *)pType
                                   params:(NSArray *)params
                               appendprop:(NSString *)appendprop;

- (NSArray *)queryMoreProductsWithStoreId:(NSString *)storeId
                                    brand:(NSString *)brand
                                    pType:(NSString *)pType
                                   params:(NSArray *)params
                               appendprop:(NSString *)appendprop
                        filterProdIdArray:(NSArray *)filterProdIdArray;


- (NSArray *)queryProductsWithStoreId:(NSString *)storeId
                                brand:(NSString *)brand
                                pType:(NSString *)pType
                               params:(NSArray *)params
                           appendprop:(NSString *)appendprop;

- (NSArray *)queryBrandSortProductsWithStoreId:(NSString *)storeId
                                         brand:(NSString *)brandId
                                        params:(NSArray *)params
                                    appendprop:(NSString *)appendprop;


- (NSArray *)queryRedisBrandSortProductWithFuncCode:(NSString *)funcCode
                                            StoreId:(NSString *)storeId
                                               drId:(NSString *)drId
                                              genId:(NSString *)genId
                                              brand:(NSString *)brand
                                             params:(NSArray *)params
                             isUseDistributionRules:(BOOL)isUseDistributionRules
                                         appendprop:(NSString *)appendprop;


- (NSArray *)queryProductsForPeopleWithStoreId:(NSString *)storeId filter:(NSString *)filter;

- (NSArray *)queryProductsWithCondition:(NSString *)condition;

- (NSArray *)queryProductsWithFilter:(NSString *)filter;

- (NSArray *)queryAllProducts;

- (WSProdBean *)queryProductByID:(NSString *)prodID;

- (NSArray *)queryProductByIds:(NSArray *)prodIds appendprop:(NSString *)appendprop; //SFA-14624 2017-11-28

// SFA-13289 新增根据imgtype排序的查询方法
- (NSArray *)queryProductByIds:(NSArray *)prodIds andIsOrderByImgtype:(BOOL)isOrderByImgtype;
//表格中扫描按钮的显示
- (BOOL)queryHasBarcodeProductList;
//扫描出的产品  disRuleId分销规则id
- (NSArray *)queryHasBarcodeProductListByIsLimitOne:(BOOL)isLimitOne pType:(NSString *)pType sid:(NSString *)sid disRuleId:(NSString *)disRuleId appendprop:(NSString *)appendprop;
// 根据barcode 查询产品
- (NSArray *)queryProductsWithBarcode:(NSString *)barcode pType:(NSString *)pType;

- (NSString *)queryStoreValueWithParamCol:(NSString *)col prodBean:(WSProdBean *)prodBean;

//SFA-20430 2018-05-28 (增加参数 sid与moreProdType) 根据Prodtree查询产品方法
- (NSArray *)queryProductsWithProdtreeId:(NSString *)prodtreeId appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType;

//SFA-21064 2018-06-21 根据genid查询产品方法
- (NSArray *)queryProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType;
//SFA-21067 针对以上方法的扩充方法
- (NSArray *)queryProductsWithGenid:(NSString *)genid appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType needStoreID:(BOOL)needStoreID;

//SFA-21315 2018-06-22 根据产品id数组查询产品方法
- (NSArray *)queryProductByIds:(NSArray *)prodIds appendprop:(NSString *)appendprop sid:(NSString *)sid moreProdType:(NSString *)moreProdType;


- (NSArray *)queryServerRedisProductsWithStoreId:(NSString *)storeId
                                brand:(NSString *)brand
                                pType:(NSString *)pType
                               params:(NSArray *)params
                                      appendprop:(NSString *)appendprop fc:(NSString*)fc md5:(NSString*)md5 store_id:(NSString*)store_id;
@end
