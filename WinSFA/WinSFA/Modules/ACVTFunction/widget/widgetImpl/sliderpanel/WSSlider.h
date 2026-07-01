//
//  WSSlider.h
//  WinSFA
//
//  Created by Alicia on 17/1/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kFontSize = 12;

@interface WSSlider : UISlider

@property (nonatomic, assign) BOOL isHideValueLabel;    // 是否隐藏数值显示
@property (nonatomic, assign) BOOL isReverse;           // 正向，则查询时获取小于滑杆的值，反向则查询大于滑杆的值，默认正向
@property (nonatomic, assign) BOOL isDistance;           // 是否用于距离
@property (nonatomic, assign) NSInteger multiplier;     // 乘数，默认是 1，值 * 乘数 = 真实值
@property (nonatomic, copy) NSString *valueLabelMemo; // 数值单位，显示数值是有效
@property (nonatomic, copy) NSString *dLen;             // 精度



//获取数值
- (NSString *)getResultDirectly;

- (NSString *)getSearchCondition;


// 获取显示值，isMultiply 为 YES 的时候 需要乘 multiplier
- (NSString *)getDisplayValueWithIsMultiply:(BOOL)isMultiply isSearch:(BOOL)isSearch;

@end
