//
//  WSPlanCalendarManageTableViewFooterView.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/29.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarManageTableViewFooterView.h"



@interface WSPlanCalendarManageTableViewFooterView ()
@property (nonatomic, strong) UIButton *setBtn;
@property (nonatomic, strong) UIView *linView;
@end

@implementation WSPlanCalendarManageTableViewFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutControls];
}

#pragma mark - Controls
- (void)addControls {
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [setBtn setTitle:@"添加随访" forState:UIControlStateNormal];
    
    [setBtn setTintColor:[UIColor colorWithHexString:@"#5AA7EC"]];
    setBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [setBtn addTarget:self action:@selector(btnDown) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    

    
    [self.contentView addSubview:setBtn];
    [self.contentView addSubview:view];

    
    self.setBtn = setBtn;
    self.linView = view;

}

- (void)layoutControls {

    CGFloat viewHeight = self.frame.size.height;
    CGFloat viewWidth = self.frame.size.width;

    self.setBtn.frame = self.bounds;
    
    self.linView.frame = CGRectMake(0, viewHeight - 1 , viewWidth,1);

}
- (void)btnDown{
    if (self.planCalendarTableViewFooterViewDelegate && [self.planCalendarTableViewFooterViewDelegate respondsToSelector:@selector(btnDownDelegate:)]) {
        [self.planCalendarTableViewFooterViewDelegate btnDownDelegate:self.strDS];

    }
}
@end

