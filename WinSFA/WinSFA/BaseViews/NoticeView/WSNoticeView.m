//
//  WSNoticeView.m
//  WinSFA
//
//  Created by Alicia on 2017/4/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNoticeView.h"

@interface WSNoticeView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *noticeImageView;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation WSNoticeView


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
    
    UIColor *bgColor = [UIColor colorForKey:@"MainNoticeBackgroudColor"] ? [UIColor colorForKey:@"MainNoticeBackgroudColor"]  : [MAIN_TINT_COLOR colorWithAlphaComponent:0.1];
    UIColor *textColor = [UIColor colorForKey:@"MainNoticeTextColor"] ? [UIColor colorForKey:@"MainNoticeTextColor"]  : MAIN_TINT_COLOR ;
    
    UIView *bgView = [[UIView alloc] init];
    [bgView setBackgroundColor:bgColor];
    [self addSubview:bgView];
    self.bgView = bgView;
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *noticeImageView = [[UIImageView alloc] init];
    UIImage *noticeImage = [[UIImage imageNamed:@"message_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    noticeImageView.image = noticeImage;
    noticeImageView.tintColor = textColor;
    [self addSubview:noticeImageView];
    self.noticeImageView = noticeImageView;
    
    UILabel *noticeLabel = [[UILabel alloc] init];
    [noticeLabel setTextColor:textColor];
    [noticeLabel setFont:[UIFont systemFontOfSize:12]];
    [self addSubview:noticeLabel];
    self.noticeLabel = noticeLabel;
    

    UIImage *closeImage = [[UIImage imageNamed:@"close_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.tintColor = textColor;
    [self addSubview:closeButton];
    self.closeButton = closeButton;
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];

    [self setHidden:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = self.bounds;
    
    CGFloat imageWH = 20;
    self.noticeImageView.frame = CGRectMake(MAIN_PADDING, (self.height - imageWH) / 2, imageWH, imageWH);
    
    CGFloat leftPadding = CGRectGetMaxX(self.noticeImageView.frame) + MAIN_TEXT_IMG_PADDING;
    CGFloat noticeWidth = self.width - leftPadding - MAIN_PADDING;
    if (self.isShowCloseButton) {
        noticeWidth = noticeWidth - imageWH - MAIN_TEXT_IMG_PADDING;
    }
    self.noticeLabel.frame = CGRectMake(leftPadding, 0, noticeWidth, self.height);
    if (self.isShowCloseButton) {
        self.closeButton.frame = CGRectMake(CGRectGetMaxX(self.noticeLabel.frame) + MAIN_TEXT_IMG_PADDING, 0, imageWH, self.height);
        [self.closeButton setHidden:NO];
    } else {
        [self.closeButton setHidden:YES];
    }
}

#pragma mark - Public Method

- (void)setNoticeText:(NSString *)text {
    [self.noticeLabel setText:text];
}

#pragma mark - Action

- (void)closeAction:(id)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self removeFromSuperview];
}

@end
