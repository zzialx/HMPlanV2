//
//  WSHttpURLHelper.h
//  WinSFA
//
//  Created by xiajl on 15/1/14.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOGIN_METHOD                        @"mobile/get.do?method=login"
#define LOGIN_REFRESH                       @"mobile/get.do?method=refresh"
#define QUERY_METHOD                        @"mobile/get.do?method=dataInfo"
#define UPLOAD_METHOD                       @"mobile/post.do?method=save"
#define CHANGEPASSWD                        @"mobile/post.do?method=onChangePass"
#define EXCEPTION                           @"mobile/postInfo.do?method=save"
#define VIDEO_UPLOAD                        @"mobile/post.do?method=saveVideo"
#define IMAGE_UPLOAD                        @"mobile/post.do?method=saveImg"
#define GET_SERVERTIME                      @"mobile/get.do?method=getServerLongTime"
#define GET_ROOTCONFIG                      @"mobile/get.do?method=getMobileRootConfig"
#define WECHAT_BUILD_RULE                   @"/sfa/wechatShare.do?method=sharePage&gd="
#define ANALYTICS_UPLOAD                    @"mobile/post.do?method=saveAnalyticsLogs"
#define LOGIN_REMIND_METHOD                 @"changePassIgnore.do?method=login"
#define LOGIN_SAAS_METHOD                   @"mobile/get.do?method=saasLogin"
#define LOGIN_SAAS_CHECK_VERSION            @"/mobile/get.do?method=checkSaasVersion"
#define QR_SHARE                            @"mobile/get.do?method=shareAppUrl"
#define SHARE_WECHAT_RECORD                 @"mobile/get.do?method=shareRecord"

#define URL_LOGIN                           [WSHttpURLHelper getCompleteURL:LOGIN_METHOD]
#define URL_LOGINREFRESH                    [WSHttpURLHelper getCompleteURL:LOGIN_REFRESH]
#define URL_UPDATE                          [WSHttpURLHelper getCompleteURL:QUERY_METHOD]
#define URL_UPLOAD                          [WSHttpURLHelper getCompleteURL:UPLOAD_METHOD]
#define URL_CHANGEPW                        [WSHttpURLHelper getCompleteURL:CHANGEPASSWD]
#define URL_EXCEPTION                       [WSHttpURLHelper getCompleteURL:EXCEPTION]
#define URL_VIDEOUPLOAD                     [WSHttpURLHelper getCompleteURL:VIDEO_UPLOAD]
#define URL_IMAGEUPLOAD                     [WSHttpURLHelper getCompleteURL:IMAGE_UPLOAD]
#define URL_GETSERVERTIME                   [WSHttpURLHelper getCompleteURL:GET_SERVERTIME]
#define URL_ANALYTICS                       [WSHttpURLHelper getCompleteURL:ANALYTICS_UPLOAD]
#define URL_GETROOTCONFIG                   [WSHttpURLHelper getRootConfigURL]
#define URL_LOGINREMIND                     [WSHttpURLHelper getCompleteURL:LOGIN_REMIND_METHOD]
#define URL_SHARE_WECHAT_RECORD             [WSHttpURLHelper getCompleteURL:SHARE_WECHAT_RECORD]

//朋友社区相关接口定义
#define URL_FRIEND_COMMUNITY_ARTICLE_LIST   [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=articleList"]    //文章列表
#define URL_FRIEND_COMMUNITY_PRAISE_ARTICLE [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=fabulous"]       //点赞文章
#define URL_FRIEND_COMMUNITY_PUBLISH         [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=publish"]        //发布文章
#define URL_FRIEND_COMMUNITY_DEL_ARTICLE       [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=delArticle"]        //删除文章
#define URL_FRIEND_COMMUNITY_ARTICLE_DETAIL        [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=articleDetail"]        //文章详情

#define URL_FRIEND_COMMUNITY_ADD_COMMENT       [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=addComment"]        //发送评论
#define URL_FRIEND_COMMUNITY_DEL_COMMENT        [WSHttpURLHelper getCompleteURL:@"mengniu/circle.do?method=delComment"]        //删除评论
//===================================================================================================================================================================

@interface WSHttpURLHelper : NSObject

+ (NSString *)getCompleteURL:(NSString *)partOfURL;
+ (NSString *)getCompleteURLByServerUrl:(NSString *)serverUrl partOfURL:(NSString *)partOfURL;
+ (NSString *)getRootConfigURL;
+ (NSString *)getImageCompleteURL:(NSString *)partOfURL;
+ (NSString *)getConfigFileServerIP;
+ (NSString *)getRootConfigWebAddress;
+ (NSString *)getLoginDataServerUrl;
+ (NSString *)getNeedsSignUrl:(NSString *)urlString;
@end
//===================================================================================================================================================================
