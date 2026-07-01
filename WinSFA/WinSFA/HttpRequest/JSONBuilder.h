//
//  JSONBuilder.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-8-11.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean.h"
#import "WSAcvtBean.h"
#import "WSSugBeanArray.h"
#import "WSSugReplyBeanArray.h"
#import "WSStoreBean.h"
#import "WSNewProductBean.h"
#import <CoreLocation/CoreLocation.h>
//TODO:对上层依赖，需要重构
//#import "SP_WCArrangeScheduleViewController.h"
@class WSArrangeScheduleViewController;
@interface JSONBuilder : NSObject

+ (NSString *)buildNewTaskByTaskName:(NSString *)name
                               empId:(NSString *)empId
                                 des:(NSString *)description
                             content:(NSString *)content
                        completeDate:(NSString *)completeDate
                          remindDate:(NSString *)remindDate
                          createDate:(NSString *)createDate
                           receivers:(NSArray *)receivers
                            syncDate:(NSString *)syncDate
                                 md5:(NSString *)md5;

+ (NSString *)buildReplyByTaskId:(NSString *)taskId
                           empId:(NSString *)empId
                         content:(NSString *)content
                        syncDate:(NSString *)syncDate;

+ (NSString *)buildTaskCompleteStatusByTaskId:(NSString *)taskId
                                        empId:(NSString *)empId
                                     syncDate:(NSString *)syncDate;

+ (NSString *)buildTaskReadStatusByTaskId:(NSString *)taskId
                                    empId:(NSString *)empId
                                 syncDate:(NSString *)syncDate;

+ (NSString *)buildProdGrideDataforPadByFuncs:(WSFuncsBean *)func
                                      isPhoto:(BOOL)isPhoto
                                        datas:(NSArray *)datas
                                      dataIDs:(NSArray *)dataIDs
                                        Store:(WSStoreBean*)aStore
                                          md5:(NSString *)md5
                                         memo:(NSString *)memo;

+ (NSString *)buildProdGrideDataByFuncs:(WSFuncsBean *)func
                                isPhoto:(BOOL)isPhoto
                                  datas:(NSArray *)datas
                                dataIDs:(NSArray *)dataIDs
                                  Store:(WSStoreBean*)aStore
                                    md5:(NSString *)md5
                                   memo:(NSString *)memo
                              otherInfo:(NSDictionary *)aDicOtherInfo;

+ (NSString *)buildAcvtProdGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5;

+ (NSString *)buildAcvtProdGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5
                                 acvtMD5:(NSString *)acvtMD5;

+ (NSString *)buildAcvtDictGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5;

+ (NSString *)buildAcvtDictGrideDataByFc:(NSString *)fc
                                      fv:(NSString *)fv
                                  params:(NSArray *)aParamArray
                                 isPhoto:(BOOL)isPhoto
                                   datas:(NSArray *)datas
                                 dataIDs:(NSArray *)dataIDs
                                   Store:(WSStoreBean*)aStore
                                     md5:(NSString *)md5
                                 acvtMD5:(NSString *)acvtMD5;


+ (NSString *)  buildSalesPersonInfoGrideDataByFuncs:(WSFuncsBean *)func
                isPhoto                     :(BOOL) isPhoto
                datas                       :(NSArray *)datas
                dataIDs                     :(NSArray *)dataIDs
                Store                       :(WSStoreBean *)aStore
                md5                         :(NSString *)md5
                memo                        :(NSString *)memo
                otherInfo                   :(NSDictionary *)aDicOtherInfo;

+ (NSString *)  buildSalesPersonInfoGrideDataByFuncs:(WSFuncsBean *)func
                        isPhoto                     :(BOOL) isPhoto
                        datas                       :(NSArray *)datas
                        dataIDs                     :(NSArray *)dataIDs
                        Store                       :(WSStoreBean *)aStore
                        md5                         :(NSString *)md5
                        memo                        :(NSString *)memo
                        otherInfo                   :(NSDictionary *)aDicOtherInfo
                                        sendBackData:(id) sendBackData;

+ (NSString *)  buildActivitybyFuncs:(WSFuncsBean *)func
                acvt                :(WSAcvtBean *)acvt
                isPhoto             :(BOOL) isPhoto
                Store               :(WSStoreBean *)aStore
                cells               :(NSDictionary *)cells
                md5                 :(NSString *)md5
                Others              :(NSDictionary *)aOthers;

+ (NSString *)buildDisplayPhotoDatasbyFuncs:(WSFuncsBean *)funcs
                                   HasPhoto:(BOOL)hasPhoto
                                      Store:(WSStoreBean *)aStore
                                      cells:(NSArray *)cells
                                        md5:(NSString *)md5
                                 notifyName:(NSString *)notifyName;


+ (NSString *)buildNewProductbyFuncs:(WSFuncsBean *)func
                              acvt:(WSAcvtBean *)acvt
                           isPhoto:(BOOL)isPhoto
                             Product:(WSNewProductBean *)aProduct
                             cells:(NSDictionary *)cells
                               md5:(NSString *)md5
                            Others:(NSDictionary*)aOthers;


//进出店json
/*
 + (NSString *)buildEnterLeaveStorebyFuncs:(FuncsBean *)func
 +                                  isPhoto:(BOOL)isPhoto
 +                                      pId:(NSString *)pId
 +                                 jsonData:(NSString *)jsonData
 +                                      md5:(NSString *)md5;
 */

// add by wangdongyan 03-09 for 改参数pid为store
// 进出店json
+ (NSString *)  buildEnterLeaveStorebyFuncs :(WSFuncsBean *)func
                isPhoto                     :(BOOL) isPhoto
                Store                       :(WSStoreBean *)aStore
                jsonData                    :(NSDictionary *)jsonData
                md5                         :(NSString *)md5;

// prom json
// + (NSString *)buildPrombyFuncs:(FuncsBean *)func
//                                  isPhoto:(BOOL)isPhoto
//                                      pId:(NSString *)pId
//                                 jsonData:(NSString *)jsonData
//                                      md5:(NSString *)md5;

// + (NSString *)buildImagebyImage:(NSData *)image
//                            funCode:(NSString *)fc
//                                pId:(NSString *)pId
//                           imageMD5:(NSString *)md5
//                            extName:(NSString *)extName;

// modify by wangdongyan 03-12
+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID;

//删除照片的请求数据
+ (NSDictionary *)buildDelImageParamsDicByImageID:(NSString *)imageID withImgIdx:(NSString*)imgIdx;

+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID
                                  andImageType:(NSString *)imageType;

+ (NSDictionary *)buildImageParamsDicByImageID:(NSString *)imageID
                                andPhotoTypeId:(NSString *)photoTypeId;

+ (NSString *)buildbuildAttendancebyFuncs:(WSFuncsBean *)func
                                     cols:(NSArray *)cols
                                    datas:(NSArray *)datas
                                  dataIDs:(NSArray *)dataIDs
                                dateBegin:(NSString *)dateBegin
                                  dateEnd:(NSString *)dateEnd
                                     memo:(NSString *)memo
                                      md5:(NSString *)md5;

+ (NSString *)buildMSG;

+ (NSString *)buildQueryMsg;

+ (NSString *)  buildWorkReportbyFuncs  :(WSFuncsBean *)func
                Data                    :(NSArray *)datas;

+ (NSString *)  buildCommentWithContent :(NSString *)aContent
                MSGID                   :(NSString *)aMsgId
                Receivers               :(NSArray *)aReceives;

+(NSString*)buildCommentWithContent:(NSString*)aContent
                              MSGID:(NSString*)aMsgId
                          Receivers:(NSArray*)aReceives
                           AcvtData:(NSString *)aAcvtData;

+ (NSString *)buildGetPartnersCommentsWithID:(NSString *)aMsgId;

+ (NSString*)buildBackGroundGPSWithLocation:(WSLocationDescribe *)locationDescribe;

+(NSString*)buildBeaconWithUUid:(NSString*)beaconUuid
                    withStoreId:(NSString*)storeId;

+ (NSString *)buildGetSuggestionTitleAndContent;

+ (NSString *)buildGetSuggestionReplyListWithMsgId:(NSString *)aMsgId;

+ (NSString *)buildSendSuggestionWithTitle:(NSDictionary *)aDiction;

+ (NSString *)buildSendSuggestionReplay:(NSDictionary *)aDiction SUGs:(WSSugReplyBeanArray *)aSugBeanArray;

+ (NSString *)buildModifyStoreInfo:(NSDictionary *)aDic Store:(WSStoreBean *)aStore;

+ (NSString *)buildDictDetailbyFuncs:(WSFuncsBean *)func
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean *)aStore
                                 md5:(NSString *)md5
                                memo:(NSString *)memo
                           otherInfo:(NSDictionary *)aDicOtherInfo;

+ (NSString *)buildDictDetailforPadbyFuncs:(WSFuncsBean *)func
                                   isPhoto:(BOOL)isPhoto
                                     datas:(NSArray *)datas
                                   dataIDs:(NSArray *)dataIDs
                                     Store:(WSStoreBean *)aStore
                                       md5:(NSString *)md5
                                      memo:(NSString *)memo;

// 三棵树主管协防 的计划外搜索
+ (NSString *)buildOutPlanOfHelpVistRequst:(NSDictionary *)aDic;
//
+ (NSString *)buildCustomerRequest:(NSDictionary *)aDic;
+ (NSString *)buildCustomerStoreRequest:(NSDictionary *)aDic;
+ (NSString *)buildMSGReceivers:(NSDictionary *)aDic;
+ (NSString *)buildExceptionInfo:(NSDictionary *)aDic;
// add by wangdongyan 04-12 for 6200服务器路线管理
+ (NSString *)buildRoadsManagerRequest:(NSDictionary *)aDictionary;
// 2012-06-29 by yanguoshuai 上传拜访计划
+ (NSString *)buildStoreScheduleData:(WSArrangeScheduleViewController *)vc;
//TODO:对上层依赖，需要重构
//+ (NSString *)buildStoreSPScheduleData:(SP_WCArrangeScheduleViewController *)vc;

+ (NSString *)buildAllStoreScheduleRequest:(NSDictionary *)aDictionary;

/*
 *srid为协访时属下的id
 */
+ (NSString*)buildUnleavedStore:(WSInoutStoreObject*)inOutStoreObj srid:(NSString*)srid;

+ (NSString * )gen_uuid;


// for pfizer
+ (NSString *)buildMarketActivityWithDic:(NSDictionary *)aDic acvtBean:(WSAcvtBean *)aBean functionBean:(WSFuncsBean *)aFuncsBean withMd5:(NSString *)aMd5;

+ (NSString *)buildPfizerBusinessStringWithDic:(NSDictionary *)aDic functionBean:(WSFuncsBean *)aFuncsBean withMd5:(NSString *)aMd5;

// 
+ (NSString *)buildSendRedMessageWithMsgId:(NSString *)aMsgId andNotifyName:(NSString *)aNotifyName andMD5:(NSString *)aMd5;
+ (NSString *)buildCalendarRequest:(NSDictionary *)aDictionary;

/**
 *  创建应用退出数据报告
 *
 *
 *  @return json字符串
 */
+ (NSString *)buildAppQuitReport;


@end
