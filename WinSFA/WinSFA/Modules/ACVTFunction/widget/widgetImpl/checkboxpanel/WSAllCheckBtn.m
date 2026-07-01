//
//  WSAllCheckBtn.m
//  WinSFA
//
//  Created by mwj on 2021/3/16.
//  Copyright © 2021 WinChannel. All rights reserved.
//

#import "WSAllCheckBtn.h"

static const CGFloat imageWH = 16.5;

@implementation WSAllCheckBtn

- (instancetype)initWithFrame:(CGRect)frame btnName:(NSString*)btnName{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAllBtnUIWithName:btnName];
    }
    return self;
}
- (void)setAllBtnUIWithName:(NSString*)btnName{
    self.userInteractionEnabled = YES;
    UIImage *buttonImage = [UIImage imageNamed:@"icn_nocheck"];
    self.checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - buttonImage.size.height)/2, buttonImage.size.width, buttonImage.size.height)];
    _checkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _checkBtn.backgroundColor = [UIColor clearColor];
    _checkBtn.titleLabel.textColor = MAIN_TEXT_COLOR;
    [_checkBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_checkBtn setImage:[UIImage imageNamed:@"icn_nocheck"] forState:UIControlStateNormal];
    
    [_checkBtn setImage:[UIImage imageNamed:@"icn_check"] forState:UIControlStateSelected];
    
    [self addSubview:_checkBtn];
    
    CGFloat paddingX = imageWH + MAIN_PADDING;
    CGFloat labelWidth = SCREEN_WIDTH - _checkBtn.frame.origin.x - imageWH - MAIN_PADDING;
    UILabel * btnNameLab = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, 0, labelWidth, self.frame.size.height)];
    btnNameLab.lineBreakMode = NSLineBreakByWordWrapping;
    btnNameLab.numberOfLines = 1;
    btnNameLab.text = btnName;
    btnNameLab.font = FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
    btnNameLab.textColor = DETAIL_TEXT_COLOR;
    btnNameLab.backgroundColor = [UIColor clearColor];
    [self addSubview:btnNameLab];
    btnNameLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClicked:)];
    btnNameLab.userInteractionEnabled = YES;
    [btnNameLab addGestureRecognizer:tap];
}

#pragma mark----全选按钮处理逻辑
- (void)buttonClicked:(UIButton*)sender{
    self.checkBtn.selected = !self.checkBtn.selected;
    if (self.checkBtn.selected) {
        //选中全部
        if (self.selectAllBtnAction) {
            self.selectAllBtnAction(YES);
        }
    }else{
        //取消全选
        if (self.selectAllBtnAction) {
            self.selectAllBtnAction(NO);
        }
    }
}
- (void)btnClicked:(UIButton*)tap
{
    self.checkBtn.selected = !self.checkBtn.selected;
    if (self.checkBtn.selected) {
        if (self.selectAllBtnAction) {
            self.selectAllBtnAction(YES);
        }
    }else{
        if (self.selectAllBtnAction) {
            self.selectAllBtnAction(NO);
        }
    }
}

@end
