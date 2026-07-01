//
//  WSComponyInfomationManager.h
//  WinSFA
//
//  Created by zzialx on 2024/1/23.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSComponyInfomationManager : NSObject

+ (WSComponyInfomationManager *)sharedInstance;

@property(nonatomic,assign)BOOL isPushComponyAcvt;

@property(nonatomic,assign)BOOL isShowComponyInfo;

/// 标记消息阅读状态以及上传后台阅读状态
/// - Parameter msgId: 消息id
+ (void)markAsReadedByMsg:(NSString *)msgId;

#pragma mark - # 是否跳转隐私协议
+ (BOOL)isShouldPushRedirectFC;

@end

NS_ASSUME_NONNULL_END
