//
//  WSLoginDataProcessService.h
//  WinSFA
//
//  Created by yang on 15/12/31.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, WSDataProcessProgress) {
    WSDataProcessProgressStart = 0,
    WSDataProcessProgressParseJson = 10,
    WSDataProcessProgressPutData = 20,
    WSDataProcessProgressSaveDB = 30,
    WSDataProcessProgressSaveData = 80,
    WSDataProcessProgressSaveUnOfflineData = 90,
    WSDataProcessProgressDone = 100
};

typedef void (^WSLoginDataProgressBlock)(NSInteger);
typedef void (^WSLoginDataCompleteBlock)(BOOL);

@interface WSLoginDataProcessService : NSObject

@property (nonatomic, copy) WSLoginDataProgressBlock progressBlock;

- (BOOL)processLoginData:(NSDictionary *)loginDataDic userName:(NSString *)userName password:(NSString *)password isFromCache:(BOOL)isFromCache isOfflineLogin:(BOOL)isOfflineLogin;

// 使用同步队列方式处理数据，为了获取加载进度
- (void)processLoginDataWithQueue:(NSDictionary *)loginDataDic userName:(NSString *)userName password:(NSString *)password isFromCache:(BOOL)isFromCache isOfflineLogin:(BOOL)isOfflineLogin complete:(WSLoginDataCompleteBlock)completeBlock;

- (void)deleteAllRequestedStoreDataFlag;

- (BOOL)isOfflineLoginWhenLaunchNeedRefresh;

@end
