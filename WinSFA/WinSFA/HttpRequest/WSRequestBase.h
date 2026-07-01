//
//  WSRequestBase.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^requestSuccess)(void);

@interface WSRequestBase : NSObject

@property (nonatomic, strong) NSString *who;


@property (nonatomic, strong) NSMutableArray *uploadRequestArray;


@property(nonatomic,copy)requestSuccess requestSuccess;///<请求结束回调

+ (WSRequestBase *)shareInstance;

- (void)cancelRequest;

/**
 *  报表后台登陆 (校验OK)
 *
 *  @param URL
 *  @param notifyName
 *  @param userAccount
 *  @param userPassword
 */
- (void)startReportLoginbyPost:(NSString *)URL
                    notifyName:(NSString *)notifyName
                   userAccount:(NSString*)userAccount
                  userPassword:(NSString *)userPassword;

/**
 *  json方式 数据上传 
 *  @param aUrlString
 *  @param parameters   
 *  @param notifyName
 *  @param md5
 *  @param aUploadType
 */
- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload;


- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload
             progress:(WCRequestProgressBlock)progressBlock;

- (void)postUrlString:(NSString *)aUrlString
           parameters:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5
       withUploadType:(WCDatasUploadType)aUploadType
             isUpload:(BOOL)isUpload
              timeout:(NSInteger)timeout
             progress:(WCRequestProgressBlock)progressBlock;

/**
 *  图片上传 （校验OK）
 *
 *  @param aUrlString 地址
 *  @param parameters request headers 部分内容
 *  @param filePath   文件地址
 *  @param notifyName
 *  @param md5        
 */
- (void)postUrlString:(NSString *)aUrlString
              headers:(NSDictionary *)parameters
             filePath:(NSString *)filePath
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5;


/**
 *  视频上传 (标准版也失败，需要与后台联调)
 *
 *  @param URL
 *  @param videoData
 *  @param notifyName
 *  @param md5
 */
- (void)postVideoData:(NSData *)videoData
                  url:(NSString *)aUrl
           notifyName:(NSString *)notifyName
                  md5:(NSString *)md5;

- (void)postVideoFilePath:(NSString *)filePath
                      url:(NSString *)aUrl
               notifyName:(NSString *)notifyName
                      md5:(NSString *)md5;


/**
 上传多文件，图片或者视频
视频上传未实现
 @param aUrlString 请求地址
 @param parameters 参数
 @param files 文件数组
 @param notifyName 通知名
 @param md5 nil
 */
- (void)postUrlString:(NSString *)aUrlString
              headers:(NSDictionary *)parameters
             files:(NSArray *)files
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5;


/**
 删除服务器图片

 @param aUrlString url
 @param parameters 参数
 @param notifyName 名字
 @param md5 
 */
- (void)delePicPostUrlString:(NSString *)aUrlString
              headers:(NSDictionary *)parameters
           notifyName:(NSString *)notifyName
                  md5:(NSString*)md5;

@end
