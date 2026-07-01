//
//  WSAcvtBatchUploadView.m
//  WinSFA
//
//  Created by Alicia on 2018/4/20.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtBatchUploadView.h"

static const NSInteger kButtonCount = 2;


@interface WSAcvtBatchUploadView ()

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) id target;


@end

@implementation WSAcvtBatchUploadView

- (instancetype)initWithFrame:(CGRect)frame target:(id)target {
    self = [super initWithFrame:frame];
    if (self) {
        _target = target;
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    CGFloat buttonWidth = (self.width - MAIN_PADDING * (kButtonCount + 1)) / kButtonCount;
    self.saveButton = [self createButtonWithIndex:0 title:NSLocalizedString(@"save_label", nil) width:buttonWidth action:@selector(bottomSaveAction:)];
    
    self.uploadButton = [self createButtonWithIndex:1 title:NSLocalizedString(@"upload_label", nil) width:buttonWidth action:@selector(bottomUploadAction:)];
}

- (UIButton *)createButtonWithIndex:(NSInteger)index title:(NSString *)title width:(CGFloat)width action:(SEL)action {
    UIButton *button = [[UIButton alloc] init];
    CGFloat buttonHeight = MAIN_BUTTON_WH;
    [button setFrame:CGRectMake((MAIN_PADDING + width) * index + MAIN_PADDING, (self.height - buttonHeight) / 2, width, buttonHeight)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self.target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.layer setCornerRadius:(buttonHeight * BTN_CORNER_RADIUS_RAITO)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:MAIN_TINT_COLOR];
//    [button.layer setBorderColor:BTN_GRAY_BORDER_COLOR.CGColor];
//    [button.layer setBorderWidth:1];
    [button.titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
    [self addSubview:button];
    return button;
}

@end
