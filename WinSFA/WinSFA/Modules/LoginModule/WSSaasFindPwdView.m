//
//  WSSaasFindPwdView.m
//  WinSFA
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSSaasFindPwdView.h"

#define kTitleHeight            50
#define kFindPwdHeight          212
#define kKeyboardMoveOffSet     -80

@interface WSSaasFindPwdView () <WSLoginTextFieldDelegate>

@property (nonatomic, strong) WSLoginTextFieldView *userNameView;
@property (nonatomic, strong) WSLoginTextFieldView *orgNameView;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation WSSaasFindPwdView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = POP_WINDOW_BG_COLOR;
    
    CGFloat width = self.width * POP_VIEW_WIDTH_RATIO;
    CGFloat paddingX = (self.width - width) / 2;
    CGFloat paddingY = (self.height - kFindPwdHeight) / 2;
    CGRect rect = CGRectMake(paddingX, paddingY, width, kFindPwdHeight);
    UIView *contentView = [[UIView alloc] initWithFrame:rect];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    self.contentView = contentView;
    [self addSubview:contentView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, kTitleHeight)];
    [titleLabel setText:NSLocalizedString(@"password_retake", nil)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [contentView addSubview:titleLabel];
    
    CGFloat padding = MAIN_CELL_PADDING;
    CGFloat viewWidth = width - MAIN_CELL_PADDING * 2;
    self.userNameView = [[WSLoginTextFieldView alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(titleLabel.frame), viewWidth, MAIN_CELL_HEIGHT)];
    [self.userNameView setIconImage:[UIImage scaledImageForName:@"usernameIcon" ofType:@"png"]];
    [self.userNameView setPlaceHolderString:NSLocalizedString(@"user_name_edit_hint",nil)];
    self.userNameView.delegate = self;
    [contentView addSubview:self.userNameView];
    
    self.orgNameView = [[WSLoginTextFieldView alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(self.userNameView.frame), viewWidth, MAIN_CELL_HEIGHT)];
    [self.orgNameView setIconImage:[UIImage scaledImageForName:@"organizationIcon" ofType:@"png"]];
    [self.orgNameView setPlaceHolderString:NSLocalizedString(@"org_code",nil)];
    [contentView addSubview:self.orgNameView];
    
    CGRect btnRect = CGRectMake(padding, CGRectGetMaxY(self.orgNameView.frame) + MAIN_CELL_PADDING, viewWidth, MAIN_CELL_HEIGHT);
    UIButton *button = [[UIButton alloc] initWithFrame:btnRect];
    UIImage *btnImg = [UIImage imageFromColor:MAIN_TINT_COLOR with:btnRect];
    UIImage *btnDisableImg = [UIImage imageFromColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_DISABLED] with:btnRect];
    UIImage *btnPressImg = [UIImage imageFromColor:[MAIN_TINT_COLOR colorWithAlphaComponent:ALPHA_PRESSED] with:btnRect];
    [button setBackgroundImage:btnImg forState:UIControlStateNormal];
    [button setBackgroundImage:btnDisableImg forState:UIControlStateDisabled];
    [button setBackgroundImage:btnPressImg forState:UIControlStateHighlighted];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = MAIN_CELL_HEIGHT / 11;
    [button setEnabled:NO];
    [button setTitle:NSLocalizedString(@"next_label", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoNext:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button];
    self.nextButton = button;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [self addGestureRecognizer:tapRecognizer];
}


#pragma mark - Actions

- (void)gotoNext:(id)sender {
    if (self.delegate) {
        NSString *userName = [self.userNameView getTextField].text;
        NSString *orgName = [self.orgNameView getTextField].text;
        [self.delegate getWebAddressByUserName:userName orgName:orgName];
    }
}

- (void)touch:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationOfTouch:0 inView:self];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self animationsOnTextFieldIsUp:NO];
        [self removeFromSuperview];
    }
}


#pragma mark - Private Method
- (void)animationsOnTextFieldIsUp:(BOOL)up {
    int y[2] = {0, kKeyboardMoveOffSet};
    [UIView beginAnimations:@"showkeyboard" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3f];
    CGRect newFrame = self.frame;
    newFrame.origin.y = y[up];
    [self setFrame:newFrame];
    [UIView commitAnimations];
}

#pragma mark - WSLoginTextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animationsOnTextFieldIsUp:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (void)textFieldDidChange:(UITextField *)textField {
    BOOL hasContent = YES;
    if (textField == [self.userNameView getTextField])  {
        if ([textField.text isEqualToString:@""] || [textField.text length] == 0) {
            hasContent = NO;
        }
    }
    self.nextButton.enabled = hasContent;
}

@end
