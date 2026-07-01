//
//  WSCustomTimeTable.h
//  WinSFA
//
//  Created by dujinfeng481 on 14-8-4.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSCustomTimeTable : WSSqliteUtil

+ (WSCustomTimeTable*)sharedTable;

/**
 *  清楚过期的并且离店的数据
 */
- (void)cleanOldData;

/**
 *  插入进店自定义数据(EMP_ID, STORE_ID, ENTER_STORE_FC, UPLOAD_FLAG, ENTER_DISPOSE_TIME, CUSTOM_ENTER_DATE, CUSTOM_ENTER_TIME, BIZ_DAATE,md5)
 *
 *  @param storeId 店铺id
 *  @param fc      进店fc
 *  @param dateStr 自定义进店日期
 *  @param timeStr 自定义进店时间
 *  @param VisitId 拜访数据的标识
 */
- (void) insertEnterCustomTimeWithStoreId:(NSString*)storeId
                                   withFC:(NSString*)fc
                           withCustomDate:(NSString*)dateStr
                           withCustomTime:(NSString*)timeStr
                              withVisitId:(NSString*)visitId;



-(void)insertEnterCustomTimeWithStoreId:(NSString*)storeId
                                           withFC:(NSString*)fc
                                   withCustomDate:(NSString*)dateStr
                                      withVisitId:(NSString*)visitId;

- (void) insertEnterNormalTimeWithStoreId:(NSString*)storeId
                                   withFC:(NSString*)fc
                              withVisitId:(NSString*)visitId;

/**
 *  更新自定义时间店铺的离店时间
 *
 *  @param storeId 店铺ID
 *  @param timeStr 自定义离店时间
 *  @param VisitId 拜访数据的唯一标识查询
 *
 *  @return 操作结果（成功or失败）
 */
- (BOOL) updateLeaveCustomTimeWithStoreId:(NSString*)storeId
                           withCustomTime:(NSString*)timeStr
                              withVisitId:(NSString*)visitId;


/**
 *  设置离店数据已经添加到离线数据库，此数据已经使用完毕，UPLOAD_FLAG置为1.
 *
 *  @param storeId 店铺ID
 *
 *  @return 操作结果（成功or失败）
 */
- (BOOL) updateCustomTimeFinishedWithStoreId:(NSString*)storeId withVisitId:(NSString*)visitId;

/**
 *  检测当前用户进入的店铺是否为自定义时间进店模式（补录数据模式）
 *
 *  @param storeId 店铺ID
 *  @param noLeaveStore 需要必须查询未离店的未上传数据标识
 *
 *  @return 如果是补录数据模式则返回YES，否则为NO
 */
- (BOOL) isCustomTimeWithStoreId:(NSString*)storeId withNeedNoLeaveStore:(BOOL) noLeaveStore withVisitId:(NSString*)visitId;

- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId ;
- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId withParentFc:(NSString *)module_fc;

/**
 *
 *
 *  @param storeId
 *  @param visitId 拜访数据的标识
 *
 *  @return 
 */
- (NSString*) queueCustomEnterDateWithStoreId:(NSString*)storeId withVisitId:(NSString*)visitId;

/**
 *  查询自定义日期和时间，如果有离店时间则返回离店日期和时间，否则返回进店日期和时间
 *
 *  @param storeId 店铺ID
 *  @param noLeaveStore 需要必须查询未离店的未上传数据标识
 *
 *  @return 【date, time】
 */
- (NSArray*) queryCustomDateAndTimeWithStoreId:(NSString*)storeId withNeedNoLeaveStore:(BOOL) noLeaveStore withVisitId:(NSString*)visitId;

@end
