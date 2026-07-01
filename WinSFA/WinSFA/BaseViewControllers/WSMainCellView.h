//
//  WSMainCellView.h
//  WinSFA
//
//  Created by heju on 12/16/13.
//  Copyright (c) 2013 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@protocol WSMainCellViewDelegate;

@interface WSMainCellView : UIView <UIGestureRecognizerDelegate> {
    UIImageView *_iconImageView;
    UIImageView *_iconBgView;
    UILabel *_label;
    NSInteger _viewTag;
    NSInteger _superColunms;
    BOOL _isHasBeenDarwed;
}

@property (nonatomic ,strong) UIImageView *iconImageView;
@property (nonatomic ,strong) UIImageView *iconBgView;
@property (nonatomic ,strong) UILabel *label;
@property (nonatomic ,assign) NSInteger viewTag;
@property (nonatomic ,weak) id<WSMainCellViewDelegate> delegate;
@property (nonatomic ,assign)NSInteger superColunms;

- (id)initWithFrame:(CGRect)frame tag:(NSInteger)viewTag superColumns:(NSInteger)cCount;
- (void)changeBackgroundHighlighted;
- (void)changeBackgroundNormal;

@end

@protocol WSMainCellViewDelegate <NSObject>

- (void)cellView:(WSMainCellView *)cellView  touchEnd:(NSInteger)viewTag;

- (void)cellView:(WSMainCellView *)cellView  touchBegin:(NSInteger)viewTag;

@end
