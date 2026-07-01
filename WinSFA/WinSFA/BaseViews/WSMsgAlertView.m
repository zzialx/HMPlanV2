//
//  WSAlertView.m
//  WinSFA
//
//  Created by heju on 15/5/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMsgAlertView.h"

#define VIEW_WIDHT 600.f
#define VIEW_INIT_HEIGHT  450.0f
#define VIEW_LEFT_MARGIN   (1024 - VIEW_WIDHT)/2
#define VIEW_TOP_MARGIN    (768 - VIEW_INIT_HEIGHT)/2

#define TITLE_LABEL_TOP_MARGIN 20.0f
#define TITLE_LABEL_LEFT_MARGIN 20.0f
#define TITLE_LABEL_HEIGHT  30.0f

#define CONTENT_VIEW_TOP_MARGIN 20.0f
#define CONTENT_LABEL_LEFT_MARGIN 20.0f
#define CONTENT_LABEL_INIT_HEIGHT 350.0f
#define CONTENT_LABEL_ADDITIONAL 10.0f

#define OK_BUTTON_WIDTH 100.0f
#define OK_BUTTON_HEIGTH 60.0f
#define OK_BUTTON_TOP_MARGIN 10.0f
#define OK_BUTTON_BOTTOM_MAGRIN 10.0f

#define CANCEL_BUTTON_WIDHT  OK_BUTTON_WIDTH
#define CANCEL_BUTTON_HEIGTH OK_BUTTON_HEIGTH

#define BUTTON_BASE_TAG 4000


#define OK_BUTTON_TITLE_COLOR ([UIColor colorWithRed:17.0/255 green:127.0f/255 blue:196.0f/255 alpha:1.0f])
#define TITLE_LABEL_COLOR    OK_BUTTON_TITLE_COLOR
#define CONTENT_LABEL_BORDER_COLOR   OK_BUTTON_TITLE_COLOR

@interface  WSMsgAlertView ()
@property (nonatomic ,strong) UIView *contView;
@property (nonatomic ,strong) WSMsgsBean_msg *msgBean;

@end

@implementation WSMsgAlertView

- (id)initWithFrame:(CGRect)frame msgBean:(WSMsgsBean_msg *)msg {
    self = [super initWithFrame:frame];
    if (self) {
        // to  do something
        _msgBean = msg;
        self.backgroundColor = [UIColor clearColor];
        [self loadBgViewWith:frame];
        [self loadSubViews];
    }
    return self;
}

- (void)loadBgViewWith:(CGRect)rect {
    UIView *bgView = [[UIView alloc] initWithFrame:rect];
    bgView.backgroundColor = [UIColor darkGrayColor];
    bgView.alpha = .6f;
    [self addSubview:bgView];
}

- (void)loadSubViews {
    
    _contView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_LEFT_MARGIN, VIEW_TOP_MARGIN, VIEW_WIDHT,VIEW_INIT_HEIGHT)];
    _contView.backgroundColor = [UIColor whiteColor];
    _contView.layer.cornerRadius = 3.0f;
    _contView.alpha = 1.0f;
    _contView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [super addSubview:_contView];
    
    CGFloat y = TITLE_LABEL_TOP_MARGIN;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LABEL_LEFT_MARGIN, y, VIEW_WIDHT-TITLE_LABEL_LEFT_MARGIN*2, TITLE_LABEL_HEIGHT)];
    titleLabel.text = self.msgBean.title;
    titleLabel.textColor = TITLE_LABEL_COLOR;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [_contView addSubview:titleLabel];
    y += TITLE_LABEL_HEIGHT;
    
    y += CONTENT_VIEW_TOP_MARGIN;
    UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(CONTENT_LABEL_LEFT_MARGIN, y, VIEW_WIDHT - 2*CONTENT_LABEL_LEFT_MARGIN, CONTENT_LABEL_INIT_HEIGHT)];
    contentView.editable = NO;
    contentView.textAlignment = NSTextAlignmentLeft;
    contentView.layer.cornerRadius = 5.0f;
    contentView.layer.borderWidth = 1.0f;
    contentView.layer.borderColor = [CONTENT_LABEL_BORDER_COLOR CGColor];
    UIFont *font = [UIFont fontWithName:@"Arial" size:16.0f];
    contentView.font = font;
    contentView.text = self.msgBean.cont;
    [_contView addSubview:contentView];
    y += contentView.height;
    
    y += OK_BUTTON_TOP_MARGIN;
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [okButton setFrame:CGRectMake((VIEW_WIDHT - OK_BUTTON_WIDTH)/2, y, OK_BUTTON_WIDTH, OK_BUTTON_HEIGTH)];
    [okButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    okButton.tag = BUTTON_BASE_TAG + 0;
    [okButton setTitleColor:OK_BUTTON_TITLE_COLOR forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont boldSystemFontOfSize:UI_Font]];
    [okButton setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [_contView addSubview:okButton];
    
    
    
    y += OK_BUTTON_HEIGTH;
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGFloat contentView_Y = 0.0f;
    if (IOS8_OR_LATER) {
        contentView_Y = (screenRect.size.height - y)/2;
    } else {
        contentView_Y = (screenRect.size.width - y)/2;
    }
    [_contView setFrame:CGRectMake( VIEW_LEFT_MARGIN,contentView_Y, VIEW_WIDHT, y)];
}


- (void)buttonClick:(id)sender {
    UIButton *clickButton = (UIButton *)sender;
    switch (clickButton.tag - BUTTON_BASE_TAG) {
        case 0:
        {
            [self removeFromSuperview];

        }
            break;
                default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
