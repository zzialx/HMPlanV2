//
//  DACircularProgressView.h
//  DACircularProgress
//
//  Created by Daniel Amitay on 2/6/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWidget.h"

@interface DACircularProgressView : WSWidget

@property(nonatomic, strong) UIColor *trackTintColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSInteger roundedCorners UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

@property(nonatomic) CGFloat thicknessRatio UI_APPEARANCE_SELECTOR;

@property(nonatomic) NSInteger clockwiseProgress UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

@property(nonatomic) CGFloat progress;
//圆环宽度
@property (nonatomic, assign) CGFloat lineWidth;
@property(nonatomic) CGFloat indeterminateDuration UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat  max_percent;

@property(nonatomic) NSInteger indeterminate UI_APPEARANCE_SELECTOR; // Can not use BOOL with UI_APPEARANCE_SELECTOR :-(

@property (nonatomic,strong) UIColor *pgcolor;

+ (instancetype) initDACircleProgressViewWithFrame  :(CGRect)frame withLineWidth :(CGFloat)lineWidth;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated initialDelay:(CFTimeInterval)initialDelay;

@end
