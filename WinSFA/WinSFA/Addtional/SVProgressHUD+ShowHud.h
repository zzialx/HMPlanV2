//
//  SVProgressHUD+ShowHud.h
//  WinSFA
//
//  Created by admin on 2022/11/4.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "SVProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface SVProgressHUD (ShowHud)

/// 自定义弹框提示语
/// - Parameter msg: 
+(void)showHudMsg:(NSString*)msg;


///
/// 加载Loading框
+ (void)showLoading;


/// 隐藏Loading框
+ (void)HideLoading;


@end

NS_ASSUME_NONNULL_END
