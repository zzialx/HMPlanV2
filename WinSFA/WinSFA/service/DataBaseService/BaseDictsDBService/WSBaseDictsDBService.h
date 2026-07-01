//
//  WSBaseDictsDBService.h
//  WinSFA
//
//  Created by weida on 15/12/26.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"



@interface WSBaseDictsDBService : WSDBService

- (NSArray *)queryDictsForAcvtGridWithFilter:(NSString *)filter;


- (NSString *)queryAcvtDictsGridRedisWithStoreId:(NSString *)storeId qst:(WSAcvtBean_qst *)qst param:(WSFuncsBean_Param *)param dict:(WSDictBean *)dictBean;
- (NSString *)queryAcvtDictsGridRedisWithStoreId:(NSString *)storeId qst:(WSAcvtBean_qst *)qst param:(WSFuncsBean_Param *)param dict:(WSDictBean *)dictBean andGenId:(NSString *)genId repeateIndex:(NSInteger)repeateIndex;

- (WSDictBean *)queryDictWithID:(NSString *)dictID;

- (WSDictBean *)queryDictWithTyp:(NSString *)dictTyp;

- (WSDictBean *)queryDictWithTyp:(NSString *)dictTyp andCod:(NSString *)cod;

- (WSDictBean *)queryDictWithName:(NSString *)dictName;

- (NSArray *)queryDictsWithIDs:(NSArray *)dictIDArray;

- (NSArray *)queryDictsWithIDsString:(NSString *)dictIDsString;

- (WSDictBean *)queryDictWithCod:(NSString *)dictCod;

- (NSArray *)queryDictWithType:(NSString *)dictCod;

- (WSDictBean *)queryDictWithParentId:(NSString *)pId;

- (NSArray *)queryDictsWithParentId:(NSString *)pId;

- (NSString *)queryBrandIdByFilter:(NSString *)aFilter searchQuestion:(NSString *)searchQuestion;

- (NSArray *)queryProdsBrandByFilter:(NSString*)filter;

- (NSArray *)queryDictsWithParentId:(NSString *)pId filter:(NSString *)filter;

- (NSArray *)queryDictWithPid:(NSString *)dictPid;

- (void)updateDictWithId:(NSString *)dictId andSequence:(NSString *)seStr;

// 查询富媒体分类的字典项 -- 专用
-(NSArray *)queryRichMediaDict;

- (NSArray *)queryDictsWithParentId:(NSString *)pId andDrid:(NSString *)drid;

// 门店列表查询城市列表--- level filter 固定
-(NSArray *)queryCityListByFilter:(NSString *)filter  levelCode:(NSString *)levelCode;
//查询下砸门店列表对应的城市
- (NSArray*)queryCityDownLoadList;
//查询下砸门店列表对应的分公司
- (NSArray*)queryBranchDownLoadList;


/// 查询对店关系的字典项
/// - Parameters:
///   - storeId: 门店id
///   - filter: filter
- (NSArray *)queryStoreDictsWithStoreId:(NSString*)storeId filter:(NSString *)filter;

@end
