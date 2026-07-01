//
//  WSAcvtSideView.m
//  WinSFA
//
//  Created by Alicia on 2018/1/29.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtSideView.h"

@interface WSAcvtSideView() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;

@end

@implementation WSAcvtSideView

- (instancetype)initWithFrame:(CGRect)frame subView:(UIView *)subView title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewsWithSubView:subView title:title];
    }
    return self;
}

- (void)setupViewsWithSubView:(UIView *)subView title:(NSString *)title {

    [self setBackgroundColor:POP_WINDOW_BG_COLOR];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    CGFloat width = self.width * SIDE_VIEW_WIDTH_RATIO;
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(self.width, 0, width, self.height)];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIColor *navColor = [UIColor colorForKey:@"NavigationBarBackgroundColor"];
    if (!navColor) {
        navColor = MAIN_TINT_COLOR;
    }
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, UI_STATUS_BAR_HEIGHT + UI_NAVIGATION_BAR_HEIGHT)];
    [topView setBackgroundColor:navColor];
    [contentView addSubview:topView];
   
    
    CGFloat buttonWH = 24;
    CGFloat offsetY = UI_STATUS_BAR_HEIGHT;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, offsetY + (UI_NAVIGATION_BAR_HEIGHT - buttonWH ) / 2, buttonWH, buttonWH);
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backButton.frame), offsetY, width - buttonWH, UI_NAVIGATION_BAR_HEIGHT)];
    [label setText:title];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [topView addSubview:label];
    
    subView.frame = CGRectMake(0, CGRectGetMaxY(topView.frame), width, self.height - UI_NAVIGATION_BAR_HEIGHT);
    [contentView addSubview:subView];
}

#pragma mark - Gesture
- (void)tapGesture:(UITapGestureRecognizer *)tapRecognizer {
    [self showOrHideWithAnimation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self) {
        return YES;
    } else {
        return NO;
    }
}

- (void)backAction:(id)sender {
    [self showOrHideWithAnimation];
}

- (void)showOrHideWithAnimation {
    BOOL isHidden = self.hidden;
    if (isHidden) {
        self.hidden = NO;
        
        [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
            self.contentView.frame = CGRectMake(self.width - self.contentView.width, 0, self.contentView.width, self.contentView.height);
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:MAIN_ANIM_DURATION animations:^{
            self.contentView.frame = CGRectMake(self.width, 0, self.contentView.width, self.contentView.height);
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

@end
