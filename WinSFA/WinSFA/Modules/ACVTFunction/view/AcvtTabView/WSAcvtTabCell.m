//
//  WSAcvtTabCell.m
//  WinSFA
//
//  Created by Alicia on 2018/1/25.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSAcvtTabCell.h"

@interface WSAcvtTabCell()

@property (nonatomic, strong) UILabel *navLabel;

@end

@implementation WSAcvtTabCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.navLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [self.navLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_MAIN]];
    [self.contentView addSubview:self.navLabel];

    [self setSelected:NO];
}

- (void)setTitle:(NSString *)title {
    [self.navLabel setText:title];
}


- (UIColor *)getTitleColor {
    UIColor *titleColor = [UIColor colorForKey:@"AcvtTabCellTitleColor"];
    if (!titleColor) {
        titleColor = [UIColor blackColor];
    }
    return titleColor;
}


- (UIColor *)getTitleSelectedColor {
    UIColor *titleSeletedColor = [UIColor colorForKey:@"AcvtTabCellTitleSelectedColor"];
    if (!titleSeletedColor) {
        titleSeletedColor = [UIColor whiteColor];
    }
    return titleSeletedColor;
}

- (UIColor *)getBgColor {
    UIColor *bgColor = [UIColor colorForKey:@"AcvtTabCellBackgroundColor"];
    if (!bgColor) {
        bgColor = [UIColor whiteColor];
    }
    return bgColor;
}

- (UIColor *)getBgSelectedColor {
    UIColor *bgSeletedColor = [UIColor colorForKey:@"AcvtTabCellSelectedBackgroundColor"];
    if (!bgSeletedColor) {
        bgSeletedColor = MAIN_TINT_COLOR;
    }
    return bgSeletedColor;
}


- (void)setUnselectedTextColor {
    [self.navLabel setTextColor:[self getTitleColor]];
    [self.contentView setBackgroundColor:[self getBgColor]];
}

// 子类会调用
- (void)setSelectedTextColor {
    [self.navLabel setTextColor:[self getTitleSelectedColor]];
    [self.contentView setBackgroundColor:[self getBgSelectedColor]];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (!selected) {
        [self setUnselectedTextColor];
    }
//    YIHAIKERRY-1837 董宏 暂时取消选中效果
//    else {
//        [self setSelectedTextColor];
//    }
}


@end
