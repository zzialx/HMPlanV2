//
//  WSAcvtPopView.m
//  WinSFA
//
//  Created by Stephanie on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtPopView.h"

//#define kContentSize (INTERFACE_IS_PHONE ? CGSizeMake(840, 635) : CGSizeMake(280, 400))

#define kLeftSpace (INTERFACE_IS_PHONE ? 20 : 93)
#define kTopSpace (INTERFACE_IS_PHONE ? 90 : 90)
#define kBottomSpace (INTERFACE_IS_PHONE ? 60 : 45)

#define kTitleViewHeight 48
#define kBottomViewHeight 55
#define kBottomButtonWidth 130
#define kBottomButtonHeight 36

@interface WSAcvtPopView ()

@property (nonatomic, strong) UIViewController *contentViewController;

@end

@implementation WSAcvtPopView

- (instancetype)initWithContentViewController:(UIViewController *)contentController
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentViewController = contentController;
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    UIView *bgView = [[UIView alloc] initWithFrame:view.bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addSubview:bgView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(kLeftSpace, kTopSpace, view.width - kLeftSpace * 2, view.height - kTopSpace - kBottomSpace)];
    contentView.clipsToBounds = YES;
    contentView.layer.cornerRadius = 5.0;
    [self addSubview:contentView];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.width, kTitleViewHeight)];
    UIColor *color = [UIColor colorForKey:@"AcvtPopViewNavigationBarBackgroundColor"];
    if (!color) {
        color = MAIN_TINT_COLOT;
    }
    [titleView setBackgroundColor:color];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setFont:[UIFont systemFontOfSize:18]];
    [contentView addSubview:titleView];
    
    self.contentViewController.view.frame = CGRectMake(0, kTitleViewHeight, contentView.width, contentView.height - kTitleViewHeight - kBottomViewHeight);
//    contentView addSubview:conte
    
    
    
}

- (void)hide
{
    
}

@end
