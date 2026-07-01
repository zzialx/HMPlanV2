//
//  WSNextStepFuncsItemLineButton.m
//  WinSFA
//
//  Created by Alicia on 2018/4/7.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSNextStepFuncsItemLineButton.h"
#import "UIView+Additions.h"

@interface WSNextStepFuncsItemLineButton()

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) CALayer *lineLayer;

@end

@implementation WSNextStepFuncsItemLineButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.contentLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MAIN]];
    [self.contentLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentLabel setNumberOfLines:0];
    [self addSubview:self.contentLabel];
}

- (void)setIsLastItem:(BOOL)isLastItem {
}

- (void)setHasVisited {
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self.contentLabel setTextColor:MAIN_TINT_COLOR];
        self.lineLayer = [self addBottomBorderWithOffset:0 width:2 color:MAIN_TINT_COLOR];
    } else {
        [self.contentLabel setTextColor:[UIColor blackColor]];
        [self.lineLayer removeFromSuperlayer];
    }
}

@end
