//
//  WSWatermarkOverlayView.h
//  WinSFA
//
//  Created by Alicia on 2017/8/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSWatermarkOverlayView : UIView

- (instancetype)initWithFrame:(CGRect)frame locationType:(NSString *)locationType;
- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName lua:(NSString *)lua;

- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName storeCode:(NSString *)storeCode storeName:(NSString *)storeName storeAddress:(NSString *)storeAddress storeLocation:(NSString *)storeLocation lua:(NSString *)lua;

- (void)setFuncName:(NSString *)funcName empName:(NSString *)empName storeCode:(NSString *)storeCode storeName:(NSString *)storeName storeAddress:(NSString *)storeAddress storeLocation:(NSString *)storeLocation lua:(NSString *)lua qstName:(NSString*)qstName;


- (CGFloat)getBottomViewOffsetY;

// MSTD-7860
- (CGPoint)getLineBottomPoint;

// MSTD-7860
- (CGFloat)getMiddleContentHeight;

// MSTD-7860
- (CGFloat)getHeaderViewHeight;

// MSTD-7860
- (CGFloat)getBottomViewHeight;

@end
