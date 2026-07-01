//
//  WSRefreshLoginManager.h
//  WinSFA
//
//  Created by yang on 15/12/31.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WSRefreshLoginStatus)
{
    WSRefreshLoginStatusSuccess,
    WSRefreshLoginStatusError,
    WSRefreshLoginStatusDisable         // MSTD-5186 后台正在"维护数据中",无网络或后台无响应时页面不能点击
};


typedef void (^WSEndRefreshBlock)(WSRefreshLoginStatus);
typedef void (^WSProgressRefreshBlock)(NSInteger);

@interface WSRefreshLoginHttpService : NSObject

@property (nonatomic, copy) WSEndRefreshBlock endRefreshBlock;
@property (nonatomic, copy) WSProgressRefreshBlock progressBlock;

- (void)beginRefreshData;

@end
