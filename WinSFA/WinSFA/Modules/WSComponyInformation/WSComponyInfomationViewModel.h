//
//  WSComponyInfomationViewModel.h
//  WinSFA
//
//  Created by zzialx on 2024/1/23.
//  Copyright © 2024 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSComponyInfomationViewModel : NSObject


/// 显示消息公告
- (void)showComponyInfomationAlertView;


/// 显示消息公告弹框
/// - Parameter vc:
- (void)showComponyInfomationAlertViewWithVC:(UIViewController*)vc;



@end

NS_ASSUME_NONNULL_END
