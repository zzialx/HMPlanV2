//
//  WSFuncTipsViewModel.h
//  WinSFA
//
//  Created by yuanji on 2025/4/18.
//  Copyright © 2025 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WSShowFuncTipsViewRoleType) {
    WSShowFuncTipsViewRoleTypeSale = 0,     //销售
    WSShowFuncTipsViewRoleTypeManager = 1   //主管
};

@interface WSFuncTipsViewModel : NSObject

+ (BOOL)isShowTipsView;                                             //是否显示审批弹窗方法
+ (NSString *)getLoginUserRole;                                     //获取用户角色方法
+ (NSString *)getTipsTitle;                                         //获取标题方法
+ (void)saveTipsReadStatus;                                         //保存读取状态方法
+ (void)showTipsViewWithRole:(WSShowFuncTipsViewRoleType)roleType;  //显示提醒弹窗方法

@end

NS_ASSUME_NONNULL_END
