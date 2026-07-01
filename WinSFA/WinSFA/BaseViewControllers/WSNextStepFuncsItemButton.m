//
//  WSNextStepFuncsItemButton.m
//  WinSFA
//
//  Created by Alicia on 2017/12/7.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSNextStepFuncsItemButton.h"

@interface WSNextStepFuncsItemButton()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation WSNextStepFuncsItemButton


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    CGFloat paddingX = 4;
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNextStepOffsetX + paddingX, 0, self.width - kNextStepOffsetX * 2 - paddingX , self.height)];
    [self.contentLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MAIN]];
    [self.contentLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentLabel setNumberOfLines:0];
    [self.contentLabel setTextColor:GRAY_TEXT_COLOR];
    [self addSubview:self.contentLabel];
}

- (void)setFuncsBean:(WSFuncsBean *)funcsBean {
    _funcsBean = funcsBean;
    NSString  *name = funcsBean.name;
    NSString * first  = [name substringWithRange:NSMakeRange(0, 2)];
    NSString * next  = [name substringWithRange:NSMakeRange(2, 2)];
    name = [NSString stringWithFormat:@"%@\r\n%@",first,next];

    [self.contentLabel setText:name];
}

- (void)setIsLastItem:(BOOL)isLastItem {
    _isLastItem = isLastItem;
    
    NSString *bgName;
    NSString *selectedBgName;
    if (!isLastItem) {
        bgName = @"bg_tab";
        selectedBgName = @"bg_tab_touch";
    } else {
        bgName = @"bg_tab_end";
        selectedBgName = @"bg_tab_end_touch";
    }
    
    UIImage *bgImage =[UIImage imageNamed:bgName];
    UIImage *selectedBgImage = [UIImage imageNamed:selectedBgName];
    
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self setBackgroundImage:selectedBgImage forState:UIControlStateSelected];
}

- (void)setHasVisited {
    NSString *bgName;
    if (!self.isLastItem) {
        bgName = @"bg_tab_press";
    } else {
        bgName = @"bg_tab_end_press";
    }
    UIImage *bgImage =[UIImage imageNamed:bgName];

    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self.contentLabel setTextColor:[UIColor whiteColor]];
    } else {
        [self.contentLabel setTextColor:GRAY_TEXT_COLOR];
    }
}

@end
