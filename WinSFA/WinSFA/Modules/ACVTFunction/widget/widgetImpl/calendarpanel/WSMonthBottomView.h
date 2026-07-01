//
//  WSMonthBottomView.h
//  WinSFA
//
//  Created by heju on 15/4/24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSMonthBottomDelegate;

@interface WSMonthBottomView : UIView
@property (nonatomic, strong) UIImageView *selectedBgImageView;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,assign)id<WSMonthBottomDelegate>delegate;

- (id)initWithFrame:(CGRect)frame index:(NSInteger)selectedIndex;

- (void)didSelectedIndex:(NSInteger)index;

- (void)setBgImageViewFrameWith:(NSInteger)selectedIndex;

@end

@protocol WSMonthBottomDelegate <NSObject>

- (void)monthBottomView:(WSMonthBottomView *)monthBottomView didSelectedIndex:(NSInteger)index;

@end
