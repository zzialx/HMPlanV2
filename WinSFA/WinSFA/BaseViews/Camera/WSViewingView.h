//
//  WSViewingView.h
//  WinSFA
//
//  Created by macbook  on 2018/6/26.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
// MSTD-7860
@interface WSViewingView : UIView
// 在调取相机的时候，如果配置了isAddNoWaterMark = YES,则配置此取景框
@property (nonatomic, assign) CGFloat width;            // 配置的取景框宽度
@property (nonatomic, assign) CGFloat height;           // 配置的取景框的高度

@property (nonatomic, assign) CGFloat maxCameraperHeight;

-(instancetype)initWithFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height maxCameraperHeight:(CGFloat)maxCameraperHeight;

// 返回取景框的相对坐标
- (CGRect)getHollowRect;

// 返回取景框的的绝对坐标
- (CGRect)getAbsHollowRect;
@end
