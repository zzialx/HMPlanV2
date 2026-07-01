//
//  WSRequestHelper.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSFuncsBean.h"
#import "WSAcvtBean.h"
#import "WSStoreBean.h"
#import "WSSugBeanArray.h"
#import "WSSugReplyBeanArray.h"
#import "WSArrangeScheduleViewController.h"
//TODO:对上层依赖，需要重构
//#import "SP_WCArrangeScheduleViewController.h"
#import "WSNewProductBean.h"

#define WSREQUEST_STOREID @ "storeId"
#define WSREQUEST_PROID @ "prodId"


typedef void(^WSRequestDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);

typedef void(^WSRequestDownloadCompletedBlock)(UIImage *image, NSError *error, NSURL *imageURL);

typedef void(^WSRequestDownloadCompletionWithFinishedBlock)(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL);

typedef void(^requsetFinish)(void);

@class CLLocation;

@interface WSRequestHelper : NSObject

@property (nonatomic,copy)requsetFinish requsetFinish;///<请求是否成功

+ (WSRequestHelper *)shareInstance;

// add by wangdongyan 04-12 for 6200服务器路线管理的请求

- (void)postRequestOnRoadsManager :(NSDictionary *)aDic
                       notifyName :(NSString *)aNotifyName;

- (void)postRequestOnLogin:(NSString *)username
                    passWd:(NSString *)passWd
                notifyName:(NSString *)notifyName
                       URL:(NSString *)url;

- (void)postRequestOnLogin:(NSString *)username
                    passWd:(NSString *)passWd
                notifyName:(NSString *)notifyName
                       URL:(NSString *)url
                  progress:(WCRequestProgressBlock)progressBlock;

- (void)postRequestOnLoginWithSSOUserCode:(NSString *)userCode
                               notifyName:(NSString *)notifyName
                                      URL:(NSString *)url
                                 progress:(WCRequestProgressBlock)progressBlock;
- (void)postRequestOnLoginWithSSOUserName:(NSString *)userName
                               notifyName:(NSString *)notifyName
                                      URL:(NSString *)url
                                 progress:(WCRequestProgressBlock)progressBlock;


// add by liran MSTD-6201
- (void)postRequestOnLoginSaas:(NSString *)username
                       orgName:(NSString *)orgName
                    notifyName:(NSString *)notifyName
                           URL:(NSString *)url;


- (void)appChangePassWord   :(NSDictionary *)newPassWord
        notifyName          :(NSString *)notifyName;

- (void)appGetStoreInfobyStoreId:(NSString *)sid
                      notifyName:(NSString *)notifyName
                            styp:(NSString *)stype;

- (void)appGetProductInfobyProductId:(NSString *)sid 
                          notifyName:(NSString *)notifyName;

-(void)appUpdateGeoDataWithEmpId:(NSString *)empId
                      notifyName:(NSString *)notifyName;


- (void)postRequestOnEnterLeaveStorebyData:(NSString *)postData
                                     md5:(NSString *)md5
                              notifyName:(NSString *)notifyName;

- (NSString*)postRequestUnLeavedStore:(WSInoutStoreObject*)inOutStoreObj
                           notifyName:(NSString *)notifyName;

-(void)appRequestCode:(NSString*)phoneNum
           notifyName:(NSString *)notifyName;


- (void)postRequestAcvtData:(NSString *)postData
                 notifyName:(NSString *)notifyName
                        md5:(NSString *)md5
       isSynchronizeRequest:(BOOL)isSynchronizeRequest;


//上传照片，通过照片路径
- (void)postRequestOnPhotoWithFilePath:(NSString *)filePath
                                 md5:(NSString *)md5
                              notify:(NSString *)aNotify
                             imageID:(NSString *)imageID;

// common requset for msg  
- (void)postRequestWith:(NSString *)objId name:(NSString *)notify;

// msg
- (void)postRequestMSGWithType:(NSString *)type;

// updataOutPlan info
- (void)appUpdataOutPlanInfo:(WSStoreBean *)store
                 subEmpStore:(WSSubempstoreBean *)subEmpStore
                        notifyName:(NSString *)notifyName;

// 高管获取店信息
- (void)appFetchStoreInfoWith:(NSString *)aStoreNameFilter
                    andFilter:(NSString *)aFilter
                   notifyName:(NSString *)aNotifyName;

-(void)appUpdataManagerInfo:(NSString*)storeId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName;

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype;

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                   StoreIds:(NSString*)storeIds
                   subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype;

-(void)appUpdataManagerInfo:(WSStoreBean*)store
                   StoreIds:(NSString*)storeIds
                   subempId:(NSString *)subempId
                  withObjId:(NSString *)objId
                 notifyName:(NSString *)notifyName
                      styp :(NSString *)stype
                    timeout:(NSInteger)timeout;

 
//辉瑞制药
- (void)fetchHospitalInfo:(WSStoreBean *)store notifyName:(NSString *)notifyName;

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

// 三棵树主管协防 计划外搜索调用
- (void)postVistHelpOutPlanQuery:(NSDictionary *)aDic;


-(void)performanceInfoRefreshWithNotifyName:(NSString*)aNotifyName;

- (void)requestMsgReceivers:(NSDictionary *)aDic;

- (void)uploadExceptionInfo:(NSDictionary *)aDic;

- (void)uploadVideoDatas:(NSData *)aPostData
        Url             :(NSString *)aUrl
        NotifyName      :(NSString *)aNotifyName
        Md5             :aMd5;

-(void)appUpdataDealterInfo:(NSString *)notifyName andObjId:(NSString *)objId
;

- (void)uploadStoreSchedule:(WSArrangeScheduleViewController *)vc;

- (void)appUpdataOrderInfoEmpId:(NSString *)aEmpId
                     notifyName:(NSString *)aNotifyName;

/*  Zheng Jiepeng 2013/07/02
 *  向服务器发送 请求数据
 *  请求参数 放在 aDic 中
 *  不需要每次都实现一个特定方法
 */
- (void)postRequestData:(NSDictionary *)aDic
           notifyName:(NSString *)aNotifyName;

// ----------------------- 数据上传过程优化 -----------------------

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
                progress:(WCRequestProgressBlock)progressBlock;

- (void)appGetRootConfig:(NSString *)username
                  passWd:(NSString *)passWd
              notifyName:(NSString *)notifyName
                     url:(NSString *)url
                progress:(WCRequestProgressBlock)progressBlock;

// -----------------For Pfizer(辉瑞医院)----------------------
- (void)QueryHospitalInfoWith:(NSDictionary *)aDic;
- (void)fetchDoctorsWithFilter:(NSString *)aFilter notifyName:(NSString *)aNotifyName;
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

-(void)uploadImageWithFilePath:(NSString *)filePath
                        params:(NSDictionary *)params
                           url:(NSString*)aUrl
                    notifyName:(NSString*)aNotifyName
                           md5:(NSString *)aMd5;

// 图片下载的封装


- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView;

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView completed:(WSRequestDownloadCompletedBlock)completedBlock;

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder;

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder completed:(WSRequestDownloadCompletedBlock)completedBlock;

- (void)downloadImageWithUrl:(NSString *)urlString imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholder progress:(WSRequestDownloadProgressBlock)progressBlock completed:(WSRequestDownloadCompletedBlock)completedBlock;

- (void)downloadImageWithUrl:(NSString *)urlString
                    progress:(WSRequestDownloadProgressBlock)progressBlock
                   completed:(WSRequestDownloadCompletionWithFinishedBlock)completedBlock;


#pragma mark - new

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload;

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
                     timeout:(NSInteger)timeout;

-(void)uploadDatasDictionary:(NSDictionary *)datasDic
                   urlString:(NSString*)aUrlString
                  notifyName:(NSString*)aNotifyName
                         md5:(NSString*)aMd5
                    isUpload:(BOOL)isUpload
                    progress:(WCRequestProgressBlock)progressBlock;

-(void)uploadVideoFilePah:(NSString*)filePath
                      Url:(NSString*)aUrl
               NotifyName:(NSString*)aNotifyName
                      Md5:aMd5;

// 若调查问卷中 问题类型为DM的问题 登录时候没有下发数据 则实时请求
-(void)appUpdataAcvtQstTypeIsDmWithObjId:(NSString *)objId filter:(NSString *)fiter
                                   notifyName:(NSString *)notifyName;

- (void)uploadStatisticsDatas:(NSDictionary *)dic
                   notifyName:(NSString *)notifyName;

- (BOOL)isUseAliyunByString:(NSString *)urlString;

- (BOOL)isHttpString:(NSString *)urlString;

- (NSDictionary *)getNormalParam;

// MSTD-6201
- (void)checkUpgradeWithUrl:(NSString *)url
                 notifyName:(NSString *)notifyName;

#pragma mark - 上传关注状态 content:内容 storeId:门店id srid:随访人id notifyName:通知名称
- (void)uploadFollowStateWithContent:(NSString *)content
                             storeId:(NSString *)storeId
                                srid:(NSString *)srid
                          notifyName:(NSString *)notifyName;

#pragma mark - 上传微信分享内容 title:标题 url:分享文章的链接
- (void)uploadWeChatArticleWithtitle:(NSString *)title
                         articleUrl :(NSString *)url;



/**
 请求当前商店的消息列表
 */
-(void)postNewRequestMSGWithType:(NSString *)type storeId:(NSString*)storeId;


/// 请求在店时长
/// - Parameters:
///   - parameters:请求参数
///   - successBlock:成功回调
///   - failureBlock:失败回调
- (void)postRequestStoreTimeLengthWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock) failureBlock;
/// 请求路线
/// - Parameters:
///   - parameters:请求参数
///   - successBlock:成功回调
///   - failureBlock:失败回调
- (void)postRequestRouteListWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock;

/// 通用post请求
/// - Parameters:
///   - parameters:请求参数
///   - successBlock:成功回调
///   - failureBlock:失败回调
- (void)postRequestWithParametes:(NSDictionary*)parameters success:(WCRequestSuccessBlock)successBlock failure:(WCRequestFailureBlock)failureBlock;


@end
