//
//  HttpWebAction.h
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-18.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface HttpWebAction : NSObject <ASIHTTPRequestDelegate, NSCopying>{}
@property (nonatomic, strong) NSString *who;

+ (HttpWebAction *)shareInstance;

- (void)startJSONStringbyPost   :(NSString *)URL
        postData                :(NSData *)postData
        notifyName              :(NSString *)notifyName
        MD5                     :(NSString *)md5;

- (void)startVideoJSONStringbyPost  :(NSString *)URL
        postData                    :(NSData *)postData
        notifyName                  :(NSString *)notifyName
        MD5                         :(NSString *)md5;

- (void)startImageJSONStringbyPost:(NSString *)URL
                            params:(NSDictionary *)params
                          postData:(NSData *)postData
                        notifyName:(NSString *)notifyName
                               MD5:(NSString*)md5;
- (void)cancelRequest;

// ----------------------- 数据上传过程优化 -----------------------
- (void)startJSONStringbyPost:(NSString *)URL
                     postData:(NSData *)postData
                   notifyName:(NSString *)notifyName
                          MD5:(NSString*)md5
               withUploadType:(WCDatasUploadType)aUploadType;

- (void)startReportLoginbyPost:(NSString *)URL
                    notifyName:(NSString *)notifyName
                   userAccount:(NSString*)userAccount
                  userPassword:(NSString *)userPassword;

- (void)startReportLoginbyPost:(NSURL *)URL;

- (void)startImageJSONStringbyPost:(NSString *)URL
                            params:(NSDictionary *)params
                          filePath:(NSString *)filePath
                        notifyName:(NSString *)notifyName
                               MD5:(NSString*)md5;

@end
