//
//  AppUpload.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "WSFuncsBean.h"
#import "WSAcvtBean.h"
#import "WSStoreBean.h"
#import "WSSugBeanArray.h"
#import "WSSugReplyBeanArray.h"
#import "WSArrangeScheduleViewController.h"
//TODO:对上层依赖，需要重构
//#import "SP_WCArrangeScheduleViewController.h"
#import "WSNewProductBean.h"

#define APPUPLOAD_STOREID @ "storeId"
#define APPUPLOAD_PROID @ "prodId"

@class CLLocation;

@interface AppUpload : NSObject <ASIHTTPRequestDelegate, NSCopying>
{}

+ (AppUpload *)shareInstance;

// add by wangdongyan 04-12 for 6200服务器路线管理的请求

-(void)uploadDatas:(NSData*)aPostData
               Url:(NSString*)aUrl
        NotifyName:(NSString*)aNotifyName
               Md5:aMd5;

- (void)appUploadOnRoadsManager :(NSDictionary *)aDic
        notifyName              :(NSString *)aNotifyName;

- (void)appUploadOnLogin:(NSString *)username
        passWd          :(NSString *)passWd
        notifyName      :(NSString *)notifyName;

- (void)appChangePassWord   :(NSString *)newPassWord
        notifyName          :(NSString *)notifyName;

- (void)appGetStoreInfobyStoreId:(NSString *)sid
                      notifyName:(NSString *)notifyName
                          filter:(NSString *)filter;

- (void)appGetStoreInfobyStoreId:(id)store
        notifyName              :(NSString *)notifyName;

//- (void)appGetStoreInfobyStoreId:(NSString *)sid
//                      notifyName:(NSString *)notifyName
//                          filter:(NSString *)filter;

- (void)appGetProductInfobyProductId:(NSString *)sid 
                          notifyName:(NSString *)notifyName;

-(void)appUploadNewTaskWithName:(NSString *)name
                          empId:(NSString *)empId
                            des:(NSString *)description
                        content:(NSString *)content
                   completeDate:(NSString *)completeDate
                     remindDate:(NSString *)remindDate
                     createDate:(NSString *)createDate
                      receivers:(NSArray *)receivers
                       syncDate:(NSString *)syncDate
                     notifyName:(NSString *)notifyName
                            md5:(NSString *)md5;

-(void)appUploadReplyWithTaskId:(NSString *)taskId
                          empId:(NSString *)empId
                        content:(NSString *)content
                       syncDate:(NSString *)syncDate
                     notifyName:(NSString *)notifyName
                            md5:(NSString *)md5;

-(void)appUploadCompletedTaskWithId:(NSString *)taskId
                              empId:(NSString *)empId
                           syncDate:(NSString *)syncDate
                         notifyName:(NSString *)notifyName
                                md5:(NSString *)md5;

-(void)appUpdateTaskDistributedWithEmpId:(NSString *)empId
                                   orgId:(NSString *)orgId
                              notifyName:(NSString *)notifyName;

-(void)appUpdateTaskReceivedWithEmpId:(NSString *)empId
                                orgId:(NSString *)orgId
                           notifyName:(NSString *)notifyName;

-(void)appUploadTaskReadStatusWithId:(NSString *)taskId
                               empId:(NSString *)empId
                            syncDate:(NSString *)syncDate
                          notifyName:(NSString *)notifyName
                                 md5:(NSString *)md5;


-(void)appUpdateRemindDistributedWithEmpId:(NSString *)empId
                                     orgId:(NSString *)orgId
                                notifyName:(NSString *)notifyName;

-(void)appUpdateRemindReceivedWithEmpId:(NSString *)empId
                                  orgId:(NSString *)orgId
                             notifyName:(NSString *)notifyName;

-(void)appUpdateTaskRepliesWithTaskId:(NSString *)taskId
                           notifyName:(NSString *)notifyName;

-(void)appUpdateGeoDataWithEmpId:(NSString *)empId
                      notifyName:(NSString *)notifyName;


- (void)appUploadOnEnterLeaveStorebyData:(NSString *)postData
                                     md5:(NSString *)md5
                              notifyName:(NSString *)notifyName;

/*
 *
 */
- (NSString*)appUploadUnLeavedStore:(WSInoutStoreObject*)inOutStoreObj notifyName:(NSString *)notifyName;

- (void)uploadProdGridedatasByFuncs:(WSFuncsBean *)funcs
                           HasPhoto:(BOOL)hasPhoto
                              datas:(NSArray *)datas
                            dataIDs:(NSArray *)dataIDs
                              Store:(WSStoreBean *)aStore
                            dateTyp:(NSString *)dateTyp
                                md5:(NSString *)md5
                         notifyName:(NSString *)notifyName
                               memo:(NSString *)memo
                          otherInfo:(NSDictionary *)aDicOtherInfo;

- (void)uploadAcvtProdGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName;

- (void)uploadAcvtProdGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName
                             acvtMD5:(NSString *)acvtMD5;

- (void)uploadAcvtDictGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName;

- (void)uploadAcvtDictGridedatasByFc:(NSString *)fc
                                  fv:(NSString *)fv
                              params:(NSArray *)aParamArray
                             isPhoto:(BOOL)isPhoto
                               datas:(NSArray *)datas
                             dataIDs:(NSArray *)dataIDs
                               Store:(WSStoreBean*)aStore
                                 md5:(NSString *)md5
                          notifyName:(NSString *)notifyName
                             acvtMD5:(NSString *)acvtMD5;

- (void)uploadSalesPersonInfoGridedatasByFuncs:(WSFuncsBean *)funcs
                  HasPhoto                    :(BOOL) hasPhoto
                  datas                       :(NSArray *)datas
                  dataIDs                     :(NSArray *)dataIDs
                  Store                       :(WSStoreBean *)aStore
                  dateTyp                     :(NSString *)dateTyp
                  md5                         :(NSString *)md5
                  notifyName                  :(NSString *)notifyName
                  memo                        :(NSString *)memo
                  otherInfo                   :(NSDictionary *)aDicOtherInfo;

- (void)uploadSalesPersonInfoGridedatasByFuncs:(WSFuncsBean *)funcs
                  HasPhoto                    :(BOOL) hasPhoto
                  datas                       :(NSArray *)datas
                  dataIDs                     :(NSArray *)dataIDs
                  Store                       :(WSStoreBean *)aStore
                  dateTyp                     :(NSString *)dateTyp
                  md5                         :(NSString *)md5
                  notifyName                  :(NSString *)notifyName
                  memo                        :(NSString *)memo
                  otherInfo                   :(NSDictionary *)aDicOtherInfo
                                  sendBackData:(id) sendBackData;

//
//- (void)uploadProdGridedatasforPadByFuncs:(FuncsBean *)funcs
//                 HasPhoto                :(BOOL)hasPhoto
//                 datas                   :(NSArray *)datas
//                 dataIDs                 :(NSArray *)dataIDs
//                 Store                   :(StoreBean *)aStore
//                 dateTyp                 :(NSString *)dateTyp
//                 md5                     :(NSString *)md5
//                 notifyName              :(NSString *)notifyName
//                 memo                    :(NSString *)memo
//                 otherInf                :(NSDictionary *)aDicOtherInfo;

- (void)appUploadAcvtData:(NSString *)postData
               notifyName:(NSString *)notifyName
                      md5:(NSString *)md5;

// 陈列拍照 - 辉瑞零售
- (void)uploadDisplayPhotoDatasbyFuncs:(WSFuncsBean *)funcs
                              HasPhoto:(BOOL)hasPhoto
                                 Store:(WSStoreBean *)aStore
                                 cells:(NSArray *)cells
                                   md5:(NSString *)md5
                            notifyName:(NSString *)notifyName;

// - (void)appUploadOtherDutybyFuncs:(FuncsBean *)funcs
//                             cols:(NSArray *)cols
//                            datas:(NSArray *)datas
//                          dataIDs:(NSArray *)dataIDs
//                        dateBegin:(NSString *)dateBegin
//                          dateEnd:(NSString *)dateEnd
//                       notifyName:(NSString *)notifyName;

// add by caozhenguo
- (void)appUploadOtherDutybyFuncs:(WSFuncsBean *)funcs
                             cols:(NSArray *)cols
                            datas:(NSArray *)datas
                          dataIDs:(NSArray *)dataIDs
                        dateBegin:(NSString *)dateBegin
                          dateEnd:(NSString *)dateEnd
                       notifyName:(NSString *)notifyName
                             memo:(NSString *)memo
                              md5:(NSString *)md5;


- (void)appUploadNewProductbyFuncs:(WSFuncsBean *)funcs
                          acvt:(WSAcvtBean *)acvt
                      HasPhoto:(BOOL)hasPhoto
                         Product:(WSNewProductBean *)aProduct
                         cells:(NSDictionary *)cells
                           md5:(NSString *)md5
                    notifyName:(NSString *)notifyName
                        Others:(NSDictionary*)aOthers;


//上传照片，通过照片路径
- (void)appUploadOnPhotoWithFilePath:(NSString *)filePath
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID;

- (void)appUploadOnPhotoWithFilePath:(NSString *)filePath
                           imageType:(NSString *)imageType
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID;


// prom
// - (void)appUploadPrombyFuncs:(FuncsBean *)funcs
//                               photoIndex:(NSData *)photoIndex
//                                 jsonData:(NSString *)jsonData
//                                  storeId:(NSString *)storeId
//                                      md5:(NSString *)md5
//                                notifyName:(NSString *)notifyName;

// msg
- (void)appUploadMSG;


- (void)appUploadQueryMsg;

// updataOutPlan info

- (void)appUpdataOutPlanInfo:(WSStoreBean *)store
        notifyName          :(NSString *)notifyName;

// 高管获取店信息
- (void)appFetchStoreInfoWith:(NSString *)aStoreNameFilter
                    andFilter:(NSString *)aFilter
                   notifyName:(NSString *)aNotifyName;

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName;

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype;

//辉瑞制药
- (void)fetchHospitalInfo:(WSStoreBean *)store notifyName:(NSString *)notifyName;

- (void)appUpdataWorkReport:(WSFuncsBean *)func Data:(NSArray *)datas NotifyName:(NSString *)notifyName;

- (void)uploadFailedData:(id)aFailedData;

- (void)uploadComment   :(NSString *)aComment
        NotifyName      :(NSString *)aNotifyName
        MSGID           :(NSString *)aMsgId
        Receiver        :(NSArray *)aReceive;

-(void)uploadComment:(NSString*)aComment
          NotifyName:(NSString*)aNotifyName
               MSGID:(NSString*)aMsgId
            Receiver:(NSArray*)aReceive
            AcvtData:(NSString *)aAcvtData
                 Md5:(NSString *)aMd5;

- (void)getMSGWithId:(NSString *)aMsgId
        NotifyName  :(NSString *)aNotifyName;

-(void)uploadBackGroundGPSWithLocation:(WSLocationDescribe *)location
                            NotifyName:(NSString*)aNotifyName;

-(void)uploadBeaconWithUUid:(NSString*)beaconUuid
                withStoreId:(NSString*)storeId
                 NotifyName:(NSString*)aNotifyName;

- (void)uploadSendSuggestion:(NSDictionary *)aSelectSugs Notify:(NSString *)aNotifyName;

- (void)getSuggestionList:(NSString *)aNotifyName;

- (void)getSuggestionReplyList:(NSString *)aMsgId Notify:(NSString *)aNotifyName;

- (void)postSuggestionReply :(NSDictionary *)aSelectSugs
        Notify              :(NSString *)aNotifyName
        SUGs                :(WSSugReplyBeanArray *)aSugBeanArray;
- (void)appUpdataAgentInfo  :(WSStoreBean *)store
        notifyName          :(NSString *)notifyName;

- (void)PostModifyStoreInfo:(NSDictionary *)aDic NotifyName:(NSString *)aNotifyName Store:(WSStoreBean *)aStore;


- (void)uploadDictByFuncs:(WSFuncsBean *)funcs
                 HasPhoto:(BOOL)hasPhoto
                    datas:(NSArray *)datas
                  dataIDs:(NSArray *)dataIDs
                    Store:(WSStoreBean *)aStore
                  dateTyp:(NSString *)dateTyp
                      md5:(NSString *)md5
               notifyName:(NSString *)notifyName
                     memo:(NSString *)memo
                otherInfo:(NSDictionary *)aDicOtherInfo;

- (void)uploadDictforPadByFuncs:(WSFuncsBean *)funcs
                       HasPhoto:(BOOL)hasPhoto
                          datas:(NSArray *)datas
                        dataIDs:(NSArray *)dataIDs
                          Store:(WSStoreBean *)aStore
                        dateTyp:(NSString *)dateTyp
                            md5:(NSString *)md5
                     notifyName:(NSString *)notifyName
                           memo:(NSString *)memo;

// add 上传方法 yanguoshuai at 2012－03－15
- (void)appUploadCheckKey   :(NSString *)l_key
        notifyName          :(NSString *)notifyName;
- (void)postCustomerQuery:(NSDictionary *)aDic;
// 三棵树主管协防 计划外搜索调用
- (void)postVistHelpOutPlanQuery:(NSDictionary *)aDic;
//

-(void)performanceInfoRefreshWithNotifyName:(NSString*)aNotifyName;

- (void)postCustomerStoresQuery:(NSDictionary *)aDic;

- (void)requestMsgReceivers:(NSDictionary *)aDic;

//- (void)appUpdataOutPlanInfo:(StoreBean *)store
//        notifyName          :(NSString *)notifyName;

- (void)uploadExceptionInfo:(NSDictionary *)aDic;

- (void)uploadVideoDatas:(NSData *)aPostData
        Url             :(NSString *)aUrl
        NotifyName      :(NSString *)aNotifyName
        Md5             :aMd5;

- (void)appUpdataDealterInfo:(NSString *)notifyName;
- (void)uploadStoreSchedule:(WSArrangeScheduleViewController *)vc;
//- (void)uploadStoreSPSchedule:(SP_WCArrangeScheduleViewController *)vc;
- (void)updateSurrundingStores:(NSString *)aEmpId
                  withLatitude:(double)aLatitude
                 withLongitude:(double)aLongitude
                withNotifyName:(NSString *)aNotifyName;


- (void)search:(NSString *)date
    notifyName:(NSString *)notify;


- (void)appUpdataSalespersonInfoWithEmpid:(NSString *)empId
                               notifyName:(NSString *)notifyName;

- (void)appUpdataOrderInfoEmpId:(NSString *)aEmpId
                     notifyName:(NSString *)aNotifyName;

/*  Zheng Jiepeng 2013/07/02
 *  向服务器发送 请求数据
 *  请求参数 放在 aDic 中
 *  不需要每次都实现一个特定方法
 */
- (void)appUploadData:(NSDictionary *)aDic
           notifyName:(NSString *)aNotifyName;

// ----------------------- 数据上传过程优化 -----------------------
- (void)appUploadOnAcvtbyFuncs:(WSFuncsBean *)funcs
                          acvt:(WSAcvtBean *)acvt
                      HasPhoto:(BOOL)hasPhoto
                         Store:(WSStoreBean *)aStore
                         cells:(NSDictionary *)cells
                           md5:(NSString *)md5
                    notifyName:(NSString *)notifyName
                        Others:(NSDictionary*)aOthers
                withUploadType:(WCDatasUploadType)aUploadType;

//----------------------- 获取服务器时间 -----------------------
- (void)appFetchServerTime:(NSString *) aNotifyName;

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName;

// -----------------For Pfizer(辉瑞医院)----------------------
- (void)QueryHospitalInfoWith:(NSDictionary *)aDic;
- (void)fetchDoctorsWithFilter:(NSString *)aFilter notifyName:(NSString *)aNotifyName;
//- (void)uploadMarketActityDatas:(NSDictionary *)aDicData acvt:(WSAcvtBean *)acvt functionBean:(WSFuncsBean *)funcs notifyName:(NSString *)aNotifyName;
- (void)uploadMarketActityDatas:(NSString *)aPostData notifyName:(NSString *)aNotifyName;

// -----------------For Pfizer(辉瑞商务)---------------------
- (void)fetchDealersWithFilter:(NSString *)aFilter notifyName:(NSString *)aNotifyName;
- (void)uploadPfizerBusinessDatas:(NSDictionary *)aDicData functionBean:(WSFuncsBean *)funcs withMd5:(NSString *)aMd5 notifyName:(NSString *)aNotifyName;

//------------------For zhongliang(中粮)----------------------
- (void)fetchOutplanStoreWithGeographicId:(NSString *)aGeoId withObjId:(NSString *)aObjId withNotifyName:(NSString *)aNotifyName;

//------------------For Kimberly(金佰利)---------------------
- (void)sendReadedMessageRequestWithMsgId:(NSString *)aMsgId andNotifyName:(NSString *)aNotifyName andMD5:(NSString *)aMd5;
///
-(void)fetchStoreSchedule:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName;
-(void)fetchCalendarDateDone:(NSDictionary *)aDic notifyName:(NSString *)aNotifyName;

 
 

@end
