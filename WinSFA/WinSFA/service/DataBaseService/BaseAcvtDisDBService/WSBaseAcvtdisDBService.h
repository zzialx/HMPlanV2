//
//  WSBaseAcvtdisDBService.h
//  WinSFA
//
//  Created by heju on 16/3/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
typedef NS_ENUM(unsigned int, WSStoreImgType) {
    WSStoreImgTypeSmall   = 0,
    WSStoreImgTypeBig     = 1
};

@interface WSBaseAcvtdisDBService : WSDBService


- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID isRemoteSearch:(BOOL)isRemoteSearch;
// isRemoteSearch 是否服务器获取
- (BOOL)replaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID genId:(NSString *)genId  isRemoteSearch:(BOOL)isRemoteSearch;

/**
 *  查询对人问卷某一个问题的值的Presentation （选项类型会根据ds查询对应的name）
 *  本地数据优先，如果没有本地数据，返回服务器数据
 *
 *  @param md5     md5
 *  @param acvtId  acvtId
 *  @param qstBean qstBean
 *
 *  @return value presentation
 */
- (NSString *)queryPeopleQstValuePresentationByGenID:(NSString *)genID acvtId:(NSString *)acvtId qstBean:(WSAcvtBean_qst *)qstBean;

/**
 *  根据storeID和acvtID查询所有新增问卷的MD5 (包括本地数据和服务器数据)
 *
 *  @param storeID  storeID
 *  @param acvtID  acvtID
 *
 *  @return md5 array
 */
- (NSArray *)queryAcvtMd5ArrayWithStoreID:(NSString *)storeID acvtID:(NSString *)acvtID;

- (NSArray *)queryStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID acvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName;

- (NSArray *)queryStoreAcvtDisBeanArrayAcvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName;

- (NSArray *)queryStoreAcvtDisBeanArrayAcvtQstID:(NSString *)acvtQstID noteName:(NSString *)noteName isRemoteSearch:(BOOL)isRemoteSearch;

- (NSArray *)queryLocalAcvtDisBeanArrayWithStoreID:(NSString *)storeID acvtQstID:(NSString *)acvtQstID;

- (NSArray *)queryLocalStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID newStoreId:(NSString *)newStoreId genID:(NSString *)genID withEmpId:(NSString *)empId;

- (WSBaseStoreAcvtDisObject *)queryServerAcvtDisObjectByGenID:(NSString *)genID acvtQstID:(NSString *)acvtQstID;

- (WSVisitStoreAcvtDataObject *)queryLocalAcvtDisObjectByGenID:(NSString *)genID acvtQstID:(NSString *)acvtQstID;

- (NSArray *)queryServerStoreAcvtDisBeanArrayWithStoreID:(NSString *)storeID genID:(NSString *)genID;


/**
 获取acvt列表数据

 @param storeID     storeID
 @param acvtType    filter
 @param searchText  searchText
 @param genIDs      genIDs
 @param isRead      YES查询已读未读状体，NO不查询
 @param isRemoteSearch    是否服务器搜索
 @param acvtSort    1：所有问卷按照原服务器下发顺序排序，0或者不配置：本地操作过的问卷排在前面，如果配置为3 只显示服务器的
 @return WSAcvtListDataItem数组
 */
- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId;

- (NSInteger)getAcvtDatasCountWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId;

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort;

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType qstAnswer:(NSString *)qstAnswer genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort;

- (NSArray *)queryAcvtDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType  withEmpId:(NSString *)empId qstAnswer:(NSString *)qstAnswer isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead;

- (NSArray *)queryStoresWithAcvtType:(NSString *)acvtType  isRemoteSearch:(BOOL)isRemoteSearch acvtSort:(NSString *)acvtSort withEmpId:(NSString *)empId isCode:(NSString *)isCode;
/**
 获取以 searchText(例如:日期)为答案的 同一调查问卷相关问题服务器回显值的集合
 
 @param storeID     storeID
 @param acvtType    filter
 @param searchText  searchText
 @param genIDs      genIDs
 @param isRead      YES查询已读未读状体，NO不查询
 @param isRemoteSearch    是否服务器搜索
 @return WSAcvtQstDisItem数组
 */
- (NSArray *)queryAcvtQstDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch;

/**
 处理服务器回显的opt_value（opt_value存入id对应的值）

 @return result
 */
- (BOOL)processServerAcvtDisValue;
/**
 处理本地数据的opt_value（opt_value存入id对应的值）
 
 @return result
 */
- (BOOL)processLocalAcvtDisValue;


/**
 返回主页所有TB对应的下级acvt未读数

 @return key:fc，value:未读数（NSNumber）
 */
- (NSDictionary *)getFuncCodeAndAcvtDataReadCount;

/**
 查询问卷某一个问题的值 （选项类型为对应的id）
 本地数据优先，如果没有本地数据，返回服务器数据 (对店、对人问卷通用)

 @param storeID   storeId
 @param acvtId    acvtId
 @param acvtQstId acvtQstId
 @param genId     genId
 @param bizDate   bizDate
 @param isMatchGenId 是否需要match GenId（主要针对服务器回显，对店的不需要match genId，对人的需要）

 @return 问题值
 */
- (NSString *)queryQstValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId isMatchGenId:(BOOL)isMatchGenId bizDate:(NSString *)bizDate;

// param: isGetLastValue 是否取结果集的最后一个值  NO 取第一个值 YES 取最后一个值
- (NSString *)queryQstValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId isMatchGenId:(BOOL)isMatchGenId bizDate:(NSString *)bizDate isGetLastValue:(BOOL)isGetLastValue;

//服务器数据
- (NSString *)queryQstServerValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId;

/**
 根据genid  filter  server_node 获取数据
 
 @param genId genId
 @param acvtQstId 过滤条件
 @param server_node ds
 
 @return WSAcvtQstDisItem数组
 */
- (WSBaseStoreAcvtDisObject *)queryQstServerValueAcvtQstId:(NSString *)acvtQstId genId:(NSString *)genId server_node:(NSString * )server_node;

//本地数据
- (NSString *)queryQstLocalValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId bizDate:(NSString *)bizDate;

- (NSString *)queryQstLocalValueWithStoreId:(NSString *)storeID acvtId:(NSString *)acvtId acvtQstId:(NSString *)acvtQstId genId:(NSString *)genId bizDate:(NSString *)bizDate isGetLastValue:(BOOL)isGetLastValue;

- (BOOL)deleteLocalDataWithGenId:(NSString *)genId;
- (BOOL)deleteLocalDataWithGenIds:(NSArray *)genIds;

- (BOOL)deleteServerDataWithGenId:(NSString *)genId;

- (BOOL)deleteLocalDataWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId;


/**
 根据genid获取数据，优先取本地的，本地没有取服务器数据
 同时获取isAcvtName，qstType等内容

 @param genId genId

 @return WSAcvtQstDisItem数组
 */
- (NSArray *)queryAcvtQstDatasByGenId:(NSString *)genId;
- (NSArray *)queryLocalAcvtQstDatasByGenId:(NSString *)genId;
- (NSArray *)queryServerAcvtQstDatasByGenId:(NSString *)genId;


/**
 根据genids获取数据，优先取本地的，本地没有取服务器数据
 同时获取isAcvtName，qstType等内容
 
 @param genIds genIds
 
 @return WSAcvtQstDisItem数组
 */
- (NSArray *)queryAcvtQstDatasByGenIds:(NSArray *)genIds;


/**
 根据条件获取数据，优先取本地的，本地没有取服务器数据
 同时获取isAcvtName，qstType等内容 (不包含主副标题等)

 @param storeId storeId
 @param acvtId  acvtId
 @param genIds  genIds

 @return WSAcvtListDataItem数组,qstDisArray里面包含WSAcvtQstDisItem对象
 */
- (NSArray *)queryAcvtDatasWithStoreId:(NSString *)storeId acvtId:(NSString *)acvtId genIds:(NSArray *)genIds;




- (NSArray *)queryAcvtQstDatasWithStoreID:(NSString *)storeID acvtType:(NSString *)acvtType searchText:(NSString *)searchText genIDs:(NSArray *)genIDs isFromLocal:(BOOL)isFromLocal isRead:(BOOL)isRead isRemoteSearch:(BOOL)isRemoteSearch;



/**
 
 @param acvtId  acvtId 
 @return WSBaseStoreAcvtDisObject数组
 */
- (NSArray *)queryAcvtQstDatasByAcvtId:(NSString *)acvtId;


- (NSArray *)queryAcvtQstDictsCountByAcvtId:(NSString *)acvtId  filter:(NSString *)filter objId:(NSString *)objId;


/**
 storeId，acvtId是否能查询到回显值（包括本地与服务器回显）

 @param storeId storeId
 @param acvtId acvtId
 @return 是否有回显值
 */
- (BOOL)hasValueForStoreId:(NSString *)storeId acvtId:(NSString *)acvtId;

// 根据门店ID 查找门头照url
-(NSString *)queryStoreImageUrlWithStoreId:(NSString *)storeId imgType:(WSStoreImgType)imgType;

//通过问题编码数组查询问题回显值方法 qstCode:问题编码
- (NSString *)queryQstValueWithQstCode:(NSString *)qstCode;




// SFA-15017 查询某个问题的回显值
- (NSArray *)queryQstValueWithStoreId:(NSString *)storeID acvtQstIdArray:(NSArray *)acvtQstIdArray;

/**
 根据门店id 问卷code查询回显数据

 @param storeId 门店id
 @param acvtCode 调查问卷编码
 @return 回显值
 */
-(NSArray *)queryAcvtDisWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode;

- (NSArray *)queryAcvtUploadTimeWithStoreId:(NSString *)storeId withsubEmpId:(NSString *)subEmpId;

// MN-511 根据问题和答案查询有回显的门店
- (NSArray *)queryStoreIdWithAnswer:(NSString *)answer acvtQstID:(NSString *)acvtQstID;

#pragma mark - YIHAIKERRY-2139 董宏添加 查询问卷列表的时间回显 storeId:门店id
- (NSArray *)queryAcvtQuestionAnswerWithStoreId:(NSString *)storeId;

#pragma mark ----批量处理门店列表数据的回显数据
- (BOOL)BatchReplaceToTableWithDicts:(NSArray *)dicts FromNode:(NSString *)nodeName hasNewData:(BOOL)hasNewData storeID:(NSString *)storeID isRemoteSearch:(BOOL)isRemoteSearch genId:(NSString *)genId;

- (NSInteger )queryAcvtReadNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode andNeedGenId:(BOOL)needGenId;

/// 查询橙色采集和主货架是否上传
/// @param storeId
/// @param qstCode
/// @param needGenId
- (NSInteger)queryOrangeCollectAndMainDisplayNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode;
/**
 查询未读消息数量

 @param storeId 商店id
 @param pid
 @return 未读数量
 */
- (NSInteger)queryMsgReadNumberStoreId:(NSString *)storeId;
/**
 根据门店id 问卷code查询回显数据

 @param storeId 门店id
 @param acvtCode 调查问卷编码
 @return 回显值
 */
-(NSArray *)queryAcvtDisWithStoreId:(NSString *)storeId acvtCode:(NSString *)acvtCode qstType:(NSString*)qstType;
/**
 根据门店id 问卷code查询回显数据

 @param storeId 门店id
 @param acvtCode 调查问卷编码
 @return 回显值
 */
- (NSString*)queryCNYActivityAndMainDisplayNumberStoreId:(NSString *)storeId andQstCode:(NSString *)qstCode;

@end
