//
//  WSBaseStoreDBService.h
//  WinSFA
//
//  Created by weida on 15/12/23.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDBService.h"
#import "WSSqliteUtil.h"

static NSString *kStoreDBOtherData_isFollowStore = @"storeDBOtherData_isFollowStore"; //门店数据库其它数据_是否关注门店
static NSString *kStoreDBOtherData_isMengNiu = @"isMengNiu";//是否是蒙牛 1是 其他否
static NSString *kStoreDBOtherData_storeClassCondition = @"storeClassCondition"; // MN-511 过滤 qstCode 是 storeClass 的回显门店
static NSString *kStoreDBOtherData_visitTimeSort = @"visitTimeSort"; // 是否用最近拜访时间排序
static NSString *kStoreDBOtherData_RouteID  = @"RouteID"; // 是否走路线
static NSString *kStoreDBOtherData_RouteID_Value  = @"RouteIDValue"; // 路线id
static NSString *kStoreDBOtherData_PageSize = @"PageSize"; //页数

@interface WSBaseStoreDBService : WSDBService

+ (instancetype)shareInstance;

- (NSMutableArray *)queryInPlanStoresWithFuncCode:(NSString *)funcCode empId:(NSString *)empId search_objId:(NSString *)objId styp:(NSString *)styp biz_date:(NSString *)biz_date storeAccessMode:(WSStoreAccessMode)storeAccessMode otherDataDic:(NSDictionary *)otherDataDic;

- (NSInteger)queryInPlanStoresCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId  biz_date:(NSString *)biz_date;

/**
 (1)
 查询门店列表方法
 */
- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode parentStoreFc:(NSString*)parentStoreFc;

// 分页查询门店列表
- (NSArray *) queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode acvtId:(NSString *)acvtId selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort otherDataDic:(NSDictionary *)otherDataDic parentStoreFc:(NSString*)parentStoreFc;

- (NSArray *) queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode acvtId:(NSString *)acvtId selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort otherDataDic:(NSDictionary *)otherDataDic storeFiletrTyp:(NSString *)storeFiletrTyp parentStoreFc:(NSString*)parentStoreFc;

- (NSArray *) queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable storeAccessMode:(WSStoreAccessMode)storeAccessMode acvtId:(NSString *)acvtId selectedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort otherDataDic:(NSDictionary *)otherDataDic storeFiletrTyp:(NSString *)storeFiletrTyp notPlan:(BOOL)notPlan parentStoreFc:(NSString*)parentStoreFc;



//查询所有门店-“修改门店信息”使用，不查询拜访状态等字段，加快查询速度
- (NSArray *)queryAllStoreForModifyWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort;

//查询修改后的某一家门店
- (NSArray *)queryStoreForModifyWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions pageNumber:(NSInteger)pageNumber  distanceSort:(NSString *)distanceSort storeId:(NSString *)storeId;
// 根据funcs 和人员id 查询门店数量
- (NSInteger)queryAllStoresCountWithFuncBean:(WSFuncsBean *)funcBean empId:(NSString *)empId;

/**
 查询需要更新的门店集合

 @param empId 人员id
 @param objId 节点名称
 @param styp 门店类型
 @return 返回 门店 ID 门店 经纬度 集合
 */
-(NSArray *)queryAllStoreToUpdataDistanceWith:(NSString *)empId objId:(NSString *)objId styp:(NSString *)styp;

/**
 查询门店数量

 @param empId 人员id
 @param styp 门店类型
 @param searchStr 搜索条件
 @param objId  节点名称
 @param isSearchable 是否搜服务器
 @return 门店list条数
 */
- (NSInteger)queryAllStoreCountEmpId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId isSearchable:(BOOL)isSearchable acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance otherDataDic:(NSDictionary *)otherDataDic;

/**
   查询门店列表方法
   用调查问卷及其选中问题的答案来过滤门店是否分页显示
 */

- (NSArray *)queryAllStoreWithFuncCode:(NSString *)funcCode empId:(NSString *)empId styp:(NSString *)styp searchStr:(NSString *)searchStr search_objId:(NSString *)objId acvtId:(NSString *)acvtId selctedQstValues:(NSMutableDictionary *)qstValues rangeConditions:rangeConditions pageNumber:(NSInteger)pageNumber distanceSort:(NSString *)distanceSort distance:(CGFloat)distance otherDataDic:(NSDictionary *)otherDataDic;

/**
 *  查询下属人员今日拜访的门店
 *
 *  @param objId 门店数据所属节点
 *  @param styp  门店类型
 *  @param srId  门店所属当前登录人下属人员id
 *
 *  @return 门店集合
 */
- (NSArray *)querySubempInPlanStoresWithSearch_objId:(NSString *)objId styp:(NSString *)styp empId:(NSString *)srId;

- (NSArray *)queryOutPlanVisitingAndVisvitedStoresWithFuncCode:(NSString *)funcCode  empId:(NSString *)empId;

- (NSArray *)queryOutPlanVisitingAndVisvitedStoresWithFuncCode:(NSString *)funcCode  empId:(NSString *)empId ds:(NSString*)ds;



- (WSBaseStoreObject *)queryStoreWithId:(NSString *)storeId;

- (NSString *)queryDrIdWithStoreId:(NSString *)storeId;

- (NSString *)queryStoreNameWithId:(NSString *)storeId;

/**
 *  查询DV类型下拉框的数据源
 *
 *  @param nodeName 门店数据所属节点
 *  @param filter  门店类型
 *
 *  @return 门店集合
 */
- (NSArray *)queryStoreWithFilter:(NSString *)filter andNodeName:(NSString *)nodeName andEmpId:(NSString *)empId andPid:(NSString *)pid;

- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic acvtGenId:(NSString *)acvtGenId;

- (BOOL)insertOrUpdateStoreWithDataDic:(NSDictionary *)dic acvtGenId:(NSString *)acvtGenId search_objId:(NSString *)search_objId;

- (NSMutableArray *)queryStoreWithSearchObjId:(NSString *)search_objId styp:(NSString *)styp;
//   SFA 项目 SFA-5815    处理门店修改之后的数据
-(BOOL)updateStoreWithDataDic:(NSDictionary *)dic;

// 利用storeId和empId查门店
- (NSArray *)queryStoreWithId:(NSString *)storeId andEmpId:(NSString *)empId;

- (NSString *)queryStoreValueWithParamCol:(NSString *)col storeBean:(WSStoreBean *)storeBean;
// 联合利华门店准备查询门店数据
-(NSArray *)queryStoreByStoreId:(NSString *)storeId;

-(WSStoreBean *)queryStoreByAcvtGenId:(NSString *)acvtGenId;


/**
 辉瑞医院查询计划路线中的门店

 @param funcCode 菜单编码
 @param search_objId 数据节点
 @param route_id 路线的id
 @return 门店集合
 */
-(NSArray *)queryRoutePlanStoresByFuncCode:(NSString *)funcCode SearchObjId:(NSString *)search_objId empId:(NSString *)empId route_id:(NSString *)route_id;

/**
 查询不在计划内中的 计划路线中的门店个数

 @param biz_date 业务日期
 @return 门店个数
 */
-(NSInteger)queryRoutePlanStoreCountByBiz_date:(NSString *)biz_date search_objId:(NSString *)objId ;

// 查询门店个数
- (NSInteger)queryAllStoresCount;

// 获取一个门店，用法是只有在一家门店的时候会调用该方法
- (WSStoreBean *)queryOnlyOneStore;

/**
 根据条件查询门店集合

 @param search_objId 数据下发时的节点名称
 @param styp 门店styp
 @param empId 人员id
 @return 门店集合
 */
-(NSMutableArray *)queryStoreWithSearchObjId:(NSString *)search_objId styp:(NSString *)styp empId:(NSString *)empId;

- (WSStoreBean *)getStoreWithResponseDic:(NSDictionary *)dic;

//删除门店未下载门店 益海嘉里200家离线需求
- (BOOL)deleteBaseStoreTable;
//根据cityid删除门店
- (BOOL)deleteBaseStoreTableCity:(NSString*)cityCode;
//根据门店类型删除门店
- (BOOL)deleteBaseStoreTableCity:(NSString*)cityCode type:(NSString *)type search_obj:(NSString *)search_obj;

// 是否使用 Store_Filter 节点作为筛选数据
+ (BOOL)isUseStoreFilterQueryStoreWithAcvtId:(NSString *)acvtId;

@end
