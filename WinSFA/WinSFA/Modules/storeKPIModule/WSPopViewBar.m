//
//  WSPopViewBar.m
//  WinSFA
//
//  Created by winchannel on 2017/7/3.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSPopViewBar.h"
#import "UIView+WSAnimation.h"
@implementation WSPopViewBar

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
    
        UIButton * btn = [[UIButton alloc]init];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15];
        [btn setTitle:NSLocalizedString(@"cancel_label", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        CGFloat width = WSBOTTOMHEIGHT + 40;
        btn.frame = CGRectMake((frame.size.width - width)/2.0, 0, width, WSBOTTOMHEIGHT);
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:btn];
    }
    return self;
    
}

- (void)close
{
    [self fadeOutWithTime:.05];
    if (self.closeClick) {
        self.closeClick();
    }
}

@end
