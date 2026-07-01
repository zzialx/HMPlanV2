//
//  WCNetworkEngine.h
//  QuadCore
//
//  Created by Liyd on 13-2-23.
//  Copyright (c) 2013年 sam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WinAFNetworking.h"


@interface WCNetworkEngine : NSObject

/**
 * 管理普通请求的queue，例如实时请求数据、下载等
 **/
@property (nonatomic, strong) WinAFHTTPRequestOperationManager *normalRequestManager;

/**
 * 管理上传数据的queue，所有数据和照片都放入此队列，最大并发数是1
 **/
@property (nonatomic, strong) WinAFHTTPRequestOperationManager *uploadRequestManager;



+ (WCNetworkEngine *)sharedInstance;

- (void) cancelNormalRequestQueue;
- (void) cancelUploadRequestQueue;
/*
 * 取消所有请求，包括normal和upload两个队列
 **/
- (void) cancelAllRequest;


@end
