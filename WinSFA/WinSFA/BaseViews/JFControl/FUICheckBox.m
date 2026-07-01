//
//  FUICheckBox.m
//  WinSFA
//
//  Created by dujinfeng481 on 14-7-30.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "FUICheckBox.h"

#define BUTTON_WIDTH                (19)
#define BUTTON_AND_TITLE_SPACE      (10)
#define PADDING_CONTNET             (UIEdgeInsetsMake(0, 0, 0, 10)) //top, left, bottom, right

@interface FUICheckBox() {
    FCheckBoxBlock  checkBoxBlock;
}

@property (nonatomic, strong) UIButton      *checkButton;

@end

@implementation FUICheckBox

- (id)initWithFrame:(CGRect)frame
          withTitle:(NSString*)title
          withBlock:(FCheckBoxBlock)block
{
    self = [super initWithFrame:frame];
    if (self) {
        checkBoxBlock = block;
        
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkButton setFrame:CGRectMake(PADDING_CONTNET.left, 0, BUTTON_WIDTH, BUTTON_WIDTH)];
        [_checkButton addTarget:self action:@selector(checkBoxPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_checkButton setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
//        [_checkButton setImage:[UIImage imageNamed:@"checkbox-pressed"] forState:UIControlStateHighlighted];
        [_checkButton setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
        [_checkButton setCenter:CGPointMake(_checkButton.centerX, CGRectGetHeight(frame) / 2)];
        [self addSubview:_checkButton];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_CONTNET.left + BUTTON_WIDTH + BUTTON_AND_TITLE_SPACE, 0,
                                                                        CGRectGetWidth(frame) - PADDING_CONTNET.left - PADDING_CONTNET.right - BUTTON_WIDTH - BUTTON_AND_TITLE_SPACE,
                                                                        BUTTON_WIDTH)];
        [titleLabel setText:title];
        [titleLabel setFont:[UIFont systemFontOfSize:UI_Font]];
        [titleLabel setCenter:CGPointMake(titleLabel.centerX, CGRectGetHeight(frame) / 2)];
        [self addSubview:titleLabel];
    }
    return self;
}

#pragma mark - private method
- (void)checkBoxPressed: (id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        if (((UIButton *)sender).selected) {
            [(UIButton *)sender setSelected:NO];
        }else{
            [(UIButton *)sender setSelected:YES];
        }
        
        if (checkBoxBlock) {
            checkBoxBlock(self.checkButton.selected);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
