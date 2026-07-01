//
//  WSSNAlertView.h
//  WinSFA
//
//  Created by admin on 2023/2/14.
//  Copyright © 2023 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSNShowViewPart.h"
#import "WSSNShowViewConfig.h"
#import "WSSNShowViewGlobalConfig.h"

@class WSSNAlertView;

typedef void (^WSSNAlertViewCallback)(WSSNAlertView * _Nullable view , UIButton * _Nullable button,NSString * _Nullable msgIds);

NS_ASSUME_NONNULL_BEGIN

@interface WSSNAlertView : UIView

+ (WSSNAlertView *)showEmptyInView:(UIView *)superview
                              part:(WSSNShowViewPart *(^)(void))part
                            config:(WSSNShowViewConfig *(^)(void))config
                          callback:(WSSNAlertViewCallback)callback ;


+ (void)hiddenEmptyInView:(UIView *)superView ;

+ (void)hiddenEmptyView:(WSSNAlertView *)emptyView ;

@end

NS_ASSUME_NONNULL_END
