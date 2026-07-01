//
//  WinInventoryPopupView.h
//

#import <UIKit/UIKit.h>
#import "WinInventoryPopupConfig.h"

@interface WinInventoryPopupView : UIView

// 类方法显示弹框
+ (void)showWithConfig:(WinInventoryPopupConfig *)config;

// 隐藏弹框
+ (void)dismiss;

@end
