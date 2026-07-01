//
//  WSANActivityTableView.h
//  WinSFA
//
//  Created by zzialx on 2025/5/9.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSANActivityModel.h"

typedef void(^addNewActivityBlock)(void);

typedef void(^deleteActivityBlock)(NSIndexPath * _Nullable selectIndexPath);

typedef void(^expandActivityHandler)(NSIndexPath * _Nullable selectIndexPath,BOOL isExpand);


NS_ASSUME_NONNULL_BEGIN


@interface WSANActivityTableView : UIView

@property(nonatomic ,strong)WSAcvtBean *acvtBean;

@property(nonatomic ,assign)BOOL readonly;

//问卷控制器数组（数据源）
@property(nonatomic ,strong)NSMutableArray <WSANActivityModel*>*acvtVCArray;

/// 添加新的活动
/// - Parameters:
/// - block:回调
- (void)addNewANActivityBlock:(addNewActivityBlock)block;

/// 删除活动
/// - Parameters:
///   - block: 回调
- (void)deleteActivityBlock:(deleteActivityBlock)block;
/// 活动展开或者闭合
/// - Parameters:
///   - block: 回调
- (void)expandActivityHandler:(expandActivityHandler)block;


@end

NS_ASSUME_NONNULL_END
