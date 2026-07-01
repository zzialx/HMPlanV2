//
//  WSBottomPopView.h
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#ifndef ZY_INSTANCETYPE
#if __has_feature(objc_instancetype)
#define ZY_INSTANCETYPE instancetype
#else
#define ZY_INSTANCETYPE id
#endif
#endif

#define KPOPViewHide @"popViewHide"

#import <UIKit/UIKit.h>
#import "WSShareItem.h"
typedef void (^DidSelectItemBlock) (WSShareItem * item);

@interface WSBottomPopView : UIView

/**
 *  直接显示一个popView在某个view上
 *
 *  @param view       父view
 *  @param imageArray 图标数组
 *  @param titles     标题数组
 *  @param block      回调
 *  @return pop视图
 */
/**
 *  直接显示一个popView在某个view上
 *
 *  @param view       父view
 *  @param imageArray 图标数组
 *  @param titles     标题数组
 *  @param block      回调
 *  @return pop视图
 */
+ (ZY_INSTANCETYPE)showToView:(UIView *)view andImages:(NSArray *)imageArray andTitles:(NSArray *)titles andSelectBlock:(DidSelectItemBlock)block;
/**
 *  如果显示一个带more功能的，请使用此方法
 *
 *  @param view  父view
 *  @param array BHBItem类型的集合
 *  @param block 回调
 *  @return pop视图
 */
+ (ZY_INSTANCETYPE)showToView:(UIView *)view withItems:(NSArray *)array andSelectBlock:(DidSelectItemBlock)block;

@end
