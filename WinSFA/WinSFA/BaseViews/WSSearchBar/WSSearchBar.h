//
//  WSSearchBar.h
//  WinSFA
//
//  Created by ZhengJiepeng on 13-8-15.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSSearchBar : UIView

/*
 Jira - MSTD-6838 修改搜索框尺寸 create by sunhongfu 2017-11-8
 新正价contentInset参数
 有默认值当 searchBar高度是44的时候 UIEdgeInsetsMake(7, 15, 7, 15) 外部有需要修改可以调用会覆盖
 */
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) UIEdgeInsets contentInset;
/*
 Jira - MSTD-6893 所有搜索框标准化 create by sunhongfu 2017-11-16
 searchCornerRadius 根据需求需要特殊设置圆角 可以设置这个值 默认15
 backViewColor 根据需求需要特殊设置WSSearchBar 的背景色  不是self.searchBar的背景色 可以设置这个值 默认whiteColor
 */
@property (nonatomic, assign) CGFloat searchBarCornerRadius;
@property (nonatomic, strong) UIColor *backViewColor;
/*是否不需要自动约束  YES时候不需要  NO时候需要  为了适配类似Tab-沟通 将searchBarView放在tableheaderview上视图出问题增加 */
@property (nonatomic, assign) BOOL isNotAutoresizingFlexible;

@property (nonatomic, assign) BOOL isResetTextField;        // 是否设置编辑框样式，仅 iPad 中有效，为 YES 时去掉搜索框中编辑框的边框
@property (nonatomic, assign) BOOL isResetBackgroundColor;  // 是否设置背景色，如果调用的地方已经设置过背景色则不用重置 为 NO 即可
@property (nonatomic, assign) BOOL isTopBar;

- (instancetype)initWithFrame:(CGRect)frame
             isResetTextField:(BOOL)isResetTextField
       isResetBackgroundColor:(BOOL)isResetBackgroundColor;

- (instancetype)initWithFrame:(CGRect)frame
             isResetTextField:(BOOL)isResetTextField
       isResetBackgroundColor:(BOOL)isResetBackgroundColor
                        isTop:(BOOL)isTop;

- (instancetype)initWithFrame:(CGRect)frame
             isResetTextField:(BOOL)isResetTextField
       isResetBackgroundColor:(BOOL)isResetBackgroundColor
                        isTop:(BOOL)isTop
    isNotAutoresizingFlexible:(BOOL)isNotAutoresizingFlexible;
- (UIColor *)getSearchBarBgColor;
- (void)resetViews;

- (void)setSearchBarPlaceholderWithText:(NSString *)text color:(UIColor *)color; //设置占位符文本/颜色方法

@end

