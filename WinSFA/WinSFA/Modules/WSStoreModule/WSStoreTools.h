//
//  WSStoreTools.h
//  WinSFA
//
//  Created by yuanji on 2018/9/3.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSStoreTools : NSObject


/// 字符串转换
/// - Parameter str:
+ (NSString *)strChange:(NSString *)str;

/// 获取审批状态颜色值
+ (UIColor*)getApproveLabColorWithState:(NSString*)approveState;

@end
