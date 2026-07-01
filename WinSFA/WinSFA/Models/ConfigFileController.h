//
//  ConfigFileController.h
//  WinChannelFrameWork
//
//  Created by ygs on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define UNPLANNED_SERVER_IP @ "http://omstest.cn.pvmgrp.com:6858/"
#define UNPLANNED_METHOD    @ "mobile/get.do?method=dataInfo"
#define LOGIN_METHOD        @ "get.do?method=login"
#define QUERY_METHOD        @ "get.do?method=dataInfo"
#define UPLOAD_METHOD       @ "post.do?method=save"
#define VERSIONCODE         @ "VersionCode"
#define SVNVERSION          @ "SvnVersion"
#define CHANGEPASSWD        @ "post.do?method=onChangePass"
#define EXCEPTION           @ "postInfo.do?method=save"
#define VIDEO_UPLOAD        @ "post.do?method=saveVideo"
#define IMAGE_UPLOAD            @"post.do?method=saveImg"
#define GET_SERVERTIME      @ "get.do?method=getServerLongTime"
#define GET_ROOTCONFIG      @ "get.do?method=getMobileRootConfig"

#define URL_LOGIN           [[ConfigFileController sharedInstanceMethod] getCompleteURL : LOGIN_METHOD]
#define URL_UPDATE          [[ConfigFileController sharedInstanceMethod] getCompleteURL : QUERY_METHOD]
#define URL_UPLOAD          [[ConfigFileController sharedInstanceMethod] getCompleteURL : UPLOAD_METHOD]
#define URL_CHANGEPW        [[ConfigFileController sharedInstanceMethod] getCompleteURL : CHANGEPASSWD]
#define URL_EXCEPTION       [[ConfigFileController sharedInstanceMethod] getCompleteURL : EXCEPTION]
#define URL_VIDEOUPLOAD     [[ConfigFileController sharedInstanceMethod] getCompleteURL : VIDEO_UPLOAD]
#define URL_IMAGEUPLOAD     [[ConfigFileController sharedInstanceMethod] getCompleteURL:IMAGE_UPLOAD]
#define URL_GETSERVERTIME   [[ConfigFileController sharedInstanceMethod] getCompleteURL:GET_SERVERTIME]
#define URL_GETROOTCONFIG   [[ConfigFileController sharedInstanceMethod] getCompleteURL:GET_ROOTCONFIG]


#import <Foundation/Foundation.h>

@interface ConfigFileController : NSObject <NSCopying>

@property (nonatomic, strong) NSDictionary *ReadPlistFileDic;

+ (ConfigFileController *)sharedInstanceMethod;
- (NSString *)getValueForKey:(NSString *)key;
- (UIColor *)colorWithHexString:(NSString *)stringToConvert;
- (NSString *)getCompleteURL:(NSString *)partOfURL;
- (CGRect)getCGRectFromString:(NSString *)keyString;
@end
