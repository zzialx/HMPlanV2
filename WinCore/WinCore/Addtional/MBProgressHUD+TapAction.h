//
//  MBProgressHUD+TapAction.h
//  HudDemo
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "MBProgressHUD.h"
#ifndef MB_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define MB_INSTANCETYPE instancetype
#else
#define MB_INSTANCETYPE id
#endif
#endif

#ifndef MB_STRONG
#if __has_feature(objc_arc)
#define MB_STRONG strong
#else
#define MB_STRONG retain
#endif
#endif

#ifndef MB_WEAK
#if __has_feature(objc_arc_weak)
#define MB_WEAK weak
#elif __has_feature(objc_arc)
#define MB_WEAK unsafe_unretained
#else
#define MB_WEAK assign
#endif
#endif
typedef enum {
	MBProgressHUDMessageTypeWaiting,
    MBProgressHUDMessageTypeDone,
    MBProgressHUDMessageTypeFailed,
    MBProgressHUDMessageTypeText
} MBProgressHUDMessageType;

@interface MBProgressHUD (TapAction)
/**
 *点击Hud通知出去
 */
+(MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action;
+(MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action type:(MBProgressHUDMessageType)type;
+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)aView withText:(NSString *)text tips:(NSString *)tips tapTarget:(id)target action:(SEL)action type:(MBProgressHUDMessageType)type autoHideTime:(NSTimeInterval)autoHideTime;
@end
