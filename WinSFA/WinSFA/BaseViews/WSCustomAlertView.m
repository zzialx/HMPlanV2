//
//  WSCustomAlertView.m
//  WinSFA
//
//  Created by lishuli on 2018/10/30.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSCustomAlertView.h"
#import "NSString+Additions.h"

#define PADDING             20
#define kTitleHeight        30
#define kContentHeight      40
#define kTextFont           [UIFont systemFontOfSize:12]

#define kLayer_BACKGROUNDCOLOR   [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0f]
#define kContent_BACKGROUNDCOLOR [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0f]
@interface WSCustomAlertView ()
@property (nonatomic, strong) UIView *contentView;//展示内容的view
@property (nonatomic, strong) UILabel *titleLabel;//提示的标题
@property (nonatomic, strong) UILabel *messageLabel;//提示的内容
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, copy) NSString *message;

@end
@implementation WSCustomAlertView

-(instancetype)initWithFrame:(CGRect)frame {
    
    return [self initWithFrame:frame buttonsTitle:nil message:nil];
}
-(instancetype)initWithFrame:(CGRect)frame buttonsTitle:(NSArray *)buttonsTitle message:(NSString *)message
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.buttonsTitle = [NSMutableArray arrayWithArray:buttonsTitle];
        _message = message;
        [self setupViews];
    }
    return self;
}

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:10];
    }
    return _buttons;
}

- (void)setupViews {
   
    self.contentView = [UIView new];
    self.contentView.layer.cornerRadius = 0;
    self.contentView.layer.masksToBounds = YES;
    [self.contentView setBackgroundColor:kContent_BACKGROUNDCOLOR];
    [self addSubview:self.contentView];
    
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.topView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setText:NSLocalizedString(@"js_alert_title", nil)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:self.titleLabel];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.text = _message.length > 0 ? _message : NSLocalizedString(@"back_confirm3", nil);
    [self.messageLabel setFont:kTextFont];
    self.messageLabel.textColor = [UIColor darkGrayColor];
    [self.topView addSubview:self.messageLabel];
    
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bottomView];
    if (self.buttonsTitle.count > 0) {
        UIColor *buttonColor = ([UIColor colorForKey:@"AlertViewTitle"] ? [UIColor colorForKey:@"AlertViewTitle"] : MAIN_TINT_COLOR);
        for (int i = 0 ; i < self.buttonsTitle.count; i++) {
            NSString *buttonTitle = self.buttonsTitle[i];
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            [button setTitleColor:buttonColor forState:UIControlStateNormal];
            [button.titleLabel setFont:kTextFont];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self.bottomView addSubview:button];
            [self.buttons addObject:button];
        }
    }
    [self layoutIfNeeded];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat actionHeight = MAIN_CELL_HEIGHT;
    CGFloat contentWidth = self.width * POP_VIEW_WIDTH_RATIO;
    CGFloat contentHeight = kContentHeight;
    CGFloat viewHeight = contentHeight + actionHeight + kTitleHeight + MAIN_PADDING + PADDING;
    self.contentView.frame = CGRectMake((self.width - contentWidth) / 2, (self.height - viewHeight) / 2, contentWidth, viewHeight);
    
    self.topView.frame = CGRectMake(0, MAIN_PADDING, contentWidth, kTitleHeight+kContentHeight);
    self.titleLabel.frame = CGRectMake(PADDING, MAIN_PADDING, contentWidth-2 *PADDING, kTitleHeight);
    self.messageLabel.frame = CGRectMake(PADDING, CGRectGetMaxY(self.titleLabel.frame), contentWidth-(2 * PADDING), contentHeight);
    CGFloat buttonW = (self.width * POP_VIEW_WIDTH_RATIO)/3;
    CGFloat buttonY = CGRectGetMaxY(self.topView.frame)+PADDING;
    self.bottomView.frame = CGRectMake(0, buttonY, contentWidth, MAIN_CELL_HEIGHT);
    for (int i = 0;i < self.buttons.count;i++) {
        UIButton *button = self.buttons[i];
        button.frame = CGRectMake(buttonW *i, 0, buttonW, MAIN_CELL_HEIGHT);
        if ((i+1) < self.buttons.count) {
            CALayer *buttonLayer = [CALayer layer];
            buttonLayer.frame = CGRectMake(buttonW, 1, 1,MAIN_CELL_HEIGHT);
            buttonLayer.backgroundColor = kLayer_BACKGROUNDCOLOR.CGColor;
            [button.layer addSublayer:buttonLayer];
        }
        [self addTopLayerToView:button];
    }
}
#pragma mark - Actions

- (void)buttonAction:(UIButton *)sender
{
    if (self.selectButtonBlock) {
        self.selectButtonBlock(sender,sender.tag);
    }
    [self removeFromSuperview];
}

- (void)setButtonsTitle:(NSMutableArray *)buttonsTitle
{
    _buttonsTitle = buttonsTitle;
    
}

- (void)addTopLayerToView:(UIView *)view {
    CALayer *topLayer = [CALayer layer];
    topLayer.frame = CGRectMake(0, 0, view.frame.size.width, 1);
    topLayer.backgroundColor = kLayer_BACKGROUNDCOLOR.CGColor;
    [view.layer addSublayer:topLayer];
}

- (void)updateAlertViewWithButtonsTitle:(NSMutableArray *)buttonsTitle message:(NSString *)message
{
    [self removeAllSubviews];
    [self.buttons removeAllObjects];
    [self.buttonsTitle removeAllObjects];
    _buttonsTitle = buttonsTitle;
    _message = message;
    [self setupViews];
}

@end
