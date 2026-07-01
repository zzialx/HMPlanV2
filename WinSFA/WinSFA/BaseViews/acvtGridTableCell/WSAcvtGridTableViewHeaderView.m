//
//  WSAcvtGridTableViewHeaderView.m
//  WinSFA
//
//  Created by Stephanie on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAcvtGridTableViewHeaderView.h"
#import "PureLayout.h"

CGFloat const AcvtGridTableViewHeaderHeight = 55.0f;

@interface WSAcvtGridTableViewHeaderView ()
{
    NSMutableArray *labelArray;
    UIButton *addButton;
}

@end

@implementation WSAcvtGridTableViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray leftSpace:(CGFloat)leftSpace
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIColor *bgColor = [UIColor colorForKey:@"AcvtGridTableViewHeaderViewBackgroundColor"];
        if (!bgColor) {
            bgColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        }
        self.backgroundColor = bgColor;
        
        UIColor *titleColor = [UIColor colorForKey:@"AcvtGridTableViewHeaderViewTitleColor"];
        if (!titleColor) {
            titleColor = [UIColor blackColor];
        }
        
        UIView *contentWidthView = [UIView newAutoLayoutView];
        contentWidthView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentWidthView];
        [contentWidthView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-leftSpace];
        [contentWidthView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:leftSpace];
        
        UILabel *lastLabel = nil;
        for (NSInteger i = 0; i < [titleArray count]; i++) {
            NSString *data = titleArray[i];
            if ([data hasSuffix:@":"] || [data hasSuffix:@"："]) {
                data = [data substringToIndex:[data length] - 1];
            }
            UILabel *label = [UILabel newAutoLayoutView];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:titleColor];
            [label setFont:[UIFont systemFontOfSize:UI_Font]];
            [label setBackgroundColor:bgColor];
            
//            label.backgroundColor = [UIColor redColor];
//            label.layer.borderColor = [UIColor grayColor].CGColor;
//            label.layer.borderWidth = 1.0;
            
            label.text = data;
            [self addSubview:label];
            [labelArray addObject:label];
            
            [label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:contentWidthView withMultiplier:1./[titleArray count]];
            [label autoPinEdgeToSuperviewEdge:ALEdgeTop];
            [label autoSetDimension:ALDimensionHeight toSize:AcvtGridTableViewHeaderHeight];
            if (lastLabel) {
                [label autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:lastLabel];
            }else {
                [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:leftSpace];
            }
            
            lastLabel = label;
        }
        
        UIButton *button = [UIButton newAutoLayoutView];
        [button setBackgroundImage:[UIImage imageForName:@"add_btn"] forState:UIControlStateNormal];
//        [button setTitleColor:MAIN_TINT_COLOT forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button autoSetDimension:ALDimensionHeight toSize:30];
        [button autoSetDimension:ALDimensionWidth toSize:30];
        [button autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:5];
        [button autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        addButton = button;
        
        
        UIView *line = [UIView newAutoLayoutView];
        line.backgroundColor = [UIColor colorWithHexString:@"#d2d2d2"];
        [self addSubview:line];
        [line autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
        [line autoSetDimension:ALDimensionHeight toSize:1];
        [line autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        [line autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    }
    
    return self;
}

- (void)setReadonly:(BOOL)readonly
{
    if (readonly) {
        addButton.hidden = YES;
    }else {
        addButton.hidden = NO;
    }
}

- (void)buttonAction
{
    if ([self.delegate respondsToSelector:@selector(headerViewAddButtonClicked:)]) {
        [self.delegate headerViewAddButtonClicked:self];
    }
}

@end
