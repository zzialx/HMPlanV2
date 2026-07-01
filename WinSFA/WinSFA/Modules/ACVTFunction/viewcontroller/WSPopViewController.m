//
//  WSAcvtPopViewController.m
//  WinSFA
//
//  Created by Stephanie on 16/7/22.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSPopViewController.h"


#define kLeftSpace (INTERFACE_IS_PHONE ? 20 : 93)
#define kTopSpace (INTERFACE_IS_PHONE ? 90 : 90)
#define kBottomSpace (INTERFACE_IS_PHONE ? 60 : 45)

#define kTitleViewHeight 48
#define kBottomViewHeight 56
#define kBottomButtonWidth 130
#define kBottomButtonHeight 36
#define kBottomButtonGap 16

@interface WSPopViewController ()<WCBaseViewControllerDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation WSPopViewController

- (instancetype)initWithContentViewController:(WCBaseViewController *)contentController
{
    self = [super init];
    if (self) {
        _contentViewController = contentController;
        _contentViewController.wcBaseViewdelegate = self;
        if (self.contentViewController) {
            [self addChildViewController:self.contentViewController];
        }
        
        _cancelButtonTitle = NSLocalizedString(@"cancel_label", nil);
        _confirmButtonTitle = NSLocalizedString(@"confirm", nil);
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    if (self.popViewSize.width > 0 && self.popViewSize.height > 0) {
        contentView.frame = CGRectMake((self.view.width - self.popViewSize.width)/2, (self.view.height - self.popViewSize.height)/2, self.popViewSize.width, self.popViewSize.height);
        contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }else {
        contentView.frame = CGRectMake(kLeftSpace, kTopSpace, self.view.width - kLeftSpace * 2, self.view.height - kTopSpace - kBottomSpace);
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    contentView.clipsToBounds = YES;
    contentView.layer.cornerRadius = 5.0;
    self.contentView = contentView;
    UIColor *bgColor = [UIColor colorForKey:@"AcvtViewBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor whiteColor];
    }
    contentView.backgroundColor = bgColor;
    contentView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
    contentView.layer.shadowOffset = CGSizeMake(2, 2);
    [self.view addSubview:contentView];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentView.width, kTitleViewHeight)];
    UIColor *color = [UIColor colorForKey:@"AcvtPopViewNavigationBarBackgroundColor"];
    if (!color) {
        color = MAIN_TINT_COLOT;
    }
    [titleView setBackgroundColor:color];
    [titleView setTextColor:[UIColor whiteColor]];
    [titleView setFont:[UIFont boldSystemFontOfSize:18]];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleView.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:titleView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.height - kBottomViewHeight - 1, contentView.width, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [contentView addSubview:line];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.height - kBottomViewHeight, contentView.width, kBottomViewHeight)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    bottomView.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:bottomView];
    
    UIColor *mainTintColor = MAIN_TINT_COLOT;
    
    CGFloat buttonViewWidth = kBottomButtonGap + kBottomButtonWidth * 2;
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake((bottomView.width - buttonViewWidth)/2, 0, buttonViewWidth, kBottomButtonHeight)];
    buttonView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [bottomView addSubview:buttonView];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (bottomView.height - kBottomButtonHeight)/2, kBottomButtonWidth, kBottomButtonHeight)];
    cancelButton.clipsToBounds = YES;
    cancelButton.layer.cornerRadius = 5.0;
    cancelButton.layer.borderColor = [UIColor colorWithHexString:@"#dddddd"].CGColor;
    cancelButton.layer.borderWidth = 1.0;
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [cancelButton setTitleColor:mainTintColor forState:UIControlStateNormal];
    [cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:cancelButton];
    _cancelButton = cancelButton;
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonViewWidth - kBottomButtonWidth, (bottomView.height - kBottomButtonHeight)/2, kBottomButtonWidth, kBottomButtonHeight)];
    confirmButton.clipsToBounds = YES;
    confirmButton.layer.cornerRadius = 5.0;
    [confirmButton setBackgroundColor:mainTintColor];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitle:self.confirmButtonTitle forState:UIControlStateNormal];
    confirmButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:confirmButton];
    _confirmButton = confirmButton;
    
    
    self.contentViewController.view.frame = CGRectMake(0, kTitleViewHeight, self.contentView.width, self.contentView.height - kTitleViewHeight - kBottomViewHeight);
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentViewController.view.layer.cornerRadius = 10.0;
    [self.contentView addSubview:self.contentViewController.view];
    [self.contentView sendSubviewToBack:self.contentViewController.view];
    
    [titleView setText:self.contentViewController.title];
    
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(popViewControllerDidDismiss:isConfirm:)]) {
            [self.delegate popViewControllerDidDismiss:self isConfirm:NO];
        }
    }];
}

- (void)confirmAction
{
    if ([self.contentViewController respondsToSelector:self.confirmSelector]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.contentViewController performSelector:self.confirmSelector];
#pragma clang diagnostic pop
        
    }else {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(popViewControllerDidDismiss:isConfirm:)]) {
                [self.delegate popViewControllerDidDismiss:self isConfirm:YES];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    } completion:^(BOOL finished) {
        //
    }];
    
    LogTrace();
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogTrace();
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
    }];
}

- (void)setConfirmButtonEnable:(BOOL)enable
{
    self.confirmButton.enabled = enable;
    if (enable == NO) {
        [self.confirmButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void)setConfirmButtonHidden:(BOOL)hidden
{
    self.confirmButton.hidden = hidden;
    
    if (hidden) {
        CGRect frame = self.cancelButton.frame;
        frame.origin.x = (self.cancelButton.superview.width - self.cancelButton.width)/2;
        self.cancelButton.frame = frame;
    }
}

#pragma mark - WCBaseViewControllerDelegate

- (void)controllerNeedDismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(popViewControllerDidDismiss:isConfirm:)]) {
            [self.delegate popViewControllerDidDismiss:self isConfirm:YES];
        }
    }];

}

- (void)callBackWhenFinishTask:(WSInterAction *)interaction
{
    if ([self.wcBaseViewdelegate respondsToSelector:@selector(callBackWhenFinishTask:)]) {
        [self.wcBaseViewdelegate callBackWhenFinishTask:interaction];
    }
}

@end
