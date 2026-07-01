//
//  WSANActivityModel.h
//  WinSFA
//
//  Created by zzialx on 2025/5/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSANActivityModel : NSObject

@property(nonatomic,assign)BOOL isExpand;//默认展开 YES

@property(nonatomic,strong)WCBaseViewController * controller;

@property(nonatomic,assign)CGFloat cellHeight;

@property(nonatomic,copy) NSString * activityTitle;

@end

NS_ASSUME_NONNULL_END
