//
//  WSSearchTagView.m
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSearchTagView.h"

@interface WSSearchTagView ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation WSSearchTagView

- (instancetype)initWithFrame:(CGRect)frame searchTag:(NSString *)searchTag
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _searchTag = searchTag;
        
        UIFont *font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 13 : 15];
        
//        CGRect newFrame = frame;
//        CGSize size = [searchTag sizeWithFont:font];
//        newFrame.size.width = size.width + 20;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [button.titleLabel setFont:font];
        button.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        button.contentMode = UIViewContentModeCenter;
        button.titleLabel.numberOfLines = 0;
        [button setTitleColor:RGBCOLOR(69, 69, 69) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setBackgroundColor:RGBCOLOR(241, 241, 241)];
//        button.clipsToBounds = YES;
        button.layer.cornerRadius = 5;
//        button.layer.borderColor = mainTintColor.CGColor;
//        button.layer.borderWidth = 1.0;
        [button setTitle:searchTag forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        _button = button;
        
//        self.frame = newFrame;
    }
    
    return self;
}

- (void)setButtonSelected:(BOOL)selected
{
    self.button.selected = selected;
    _selected = [self.button isSelected];
    
    if ([self.button isSelected]) {
        [self.button setBackgroundColor:MAIN_TINT_COLOT];
    }else {
        [self.button setBackgroundColor:RGBCOLOR(241, 241, 241)];
    }
}

- (void)clickAction:(UIButton *)sender
{
    [self setButtonSelected:![sender isSelected]];
    
    if ([self.delegate respondsToSelector:@selector(selectChanged:)]) {
        [self.delegate selectChanged:self];
    }
}

- (void)setSelected:(BOOL)selected
{
    [self setButtonSelected:selected];
}

@end
