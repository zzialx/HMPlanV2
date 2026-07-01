 //
//  WSSerieLinkHeadView.m
//  WinSFA
//
//  Created by heju on 15/3/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSSerieLinkHeadView.h"


#define K_HEAD_LAUNCH_BUTTON_HEIGHT 6
#define K_HEAD_LAUNCH_BUTTON_WIDHT 12
#define K_HEAD_LAUCH_BUTTON_RIGHT_MARGIN 20


#define K_SELECTED_COLOR [UIColor colorWithRed:208.0f/255 green:208.0f/255 blue:208.0f/255 alpha:0.6]

#define K_NORMAL_COLOR [UIColor colorWithRed:232.0f/255 green:232.0f/255 blue:232.0f/255 alpha:0.6]

@interface WSSerieLinkHeadView  () <UIGestureRecognizerDelegate>

@end

@implementation WSSerieLinkHeadView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = K_NORMAL_COLOR;
        _superViewDisplay = NO;

        CGFloat x = INTERFACE_IS_PAD ? 20:15;
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0,  frame.size.width, frame.size.height)];
        self.headLabel.font = [UIFont systemFontOfSize:UI_Font];
        self.headLabel.textColor = DETAIL_TEXT_COLOR;
        self.headLabel.text = NSLocalizedString(@"brand_series", nil);
        [self  addSubview:self.headLabel];
        
        // 展开和收缩的标识
        _headMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headMarkButton.frame = CGRectMake(frame.size.width - K_HEAD_LAUNCH_BUTTON_WIDHT - K_HEAD_LAUCH_BUTTON_RIGHT_MARGIN,(frame.size.height - K_HEAD_LAUNCH_BUTTON_HEIGHT)/2, K_HEAD_LAUNCH_BUTTON_WIDHT, K_HEAD_LAUNCH_BUTTON_HEIGHT);
        [self.headMarkButton addTarget: self action:@selector(singleTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.headMarkButton setBackgroundImage:[UIImage imageForName:@"triangle_down.png"] forState:UIControlStateNormal];
        [self addSubview:self.headMarkButton];
        
        // 分割视图
        _sperateView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height -1, frame.size.width, 1)];
        self.sperateView.backgroundColor =[UIColor whiteColor];
        [self addSubview:self.sperateView];
        
        //
        UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleRecognizer.numberOfTapsRequired = 1;
        [self  addGestureRecognizer:singleRecognizer];
        
    }

    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES; 
}


- (void)changeSelectedNormal {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)changeMarkImageViewDown {
    
    [self.headMarkButton setBackgroundImage:[UIImage imageForName:@"triangle_down.png"] forState:UIControlStateNormal];
}


- (void)changeHeadLableText:(NSString *)text {
    self.headLabel.text = [NSString stringWithFormat:@"%@    %@",NSLocalizedString(@"brand_series", nil),text];
}
- (void)singleTap:(UITapGestureRecognizer*)recognizer {
    self.superViewDisplay = !self.superViewDisplay;
    if (self.superViewDisplay) {
        [self.headMarkButton setBackgroundImage:[UIImage imageForName:@"triangle_up.png"] forState:UIControlStateNormal];
        self.sperateView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = K_SELECTED_COLOR;
    } else {
        self.backgroundColor = K_NORMAL_COLOR;
        [self.headMarkButton setBackgroundImage:[UIImage imageForName:@"triangle_down.png"] forState:UIControlStateNormal];
        self.sperateView.backgroundColor = K_SELECTED_COLOR;
    }
    if ([_delegate respondsToSelector:@selector(serieLinkHeadView:superViewWillDisplay:)]) {
        [_delegate serieLinkHeadView:self superViewWillDisplay:self.superViewDisplay];
    }
}


- (void)isReadonly:(BOOL)readonly {
    if (readonly) {
        self.headLabel.textColor =  MAIN_TEXT_DISABLE_COLOR;
        self.headMarkButton.enabled = NO;
        self.userInteractionEnabled = NO;
        self.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    }else {
        self.headLabel.textColor = DETAIL_TEXT_COLOR;
        self.headMarkButton.enabled = YES;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
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
