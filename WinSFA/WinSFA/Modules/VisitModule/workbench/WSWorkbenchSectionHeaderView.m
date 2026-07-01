//
//  WSWorkbenchSectionHeaderView.m
//  WinSFA
//
//  Created by yang on 16/12/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSWorkbenchSectionHeaderView.h"
#import "PureLayout.h"

#define kTitleLeftSpace 10.0f

#define WORKFLOW_SECTIONHEADERVIEW_COLOR              ([UIColor colorForKey:@"WorkFlowSectionHeaderViewTitleColor"] ? : kWorkbenchSectionHeaderViewTextColor )

#define WORKFLOW_HEADERVIEW_FONT               [UIFont fontForKey:@"WorkFlowSectionHeaderViewTitle"] ? : FONT_SIZE_PINGFANG_MEDIUM(FONT_SIZE_DESC)

@interface WSWorkbenchSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation WSWorkbenchSectionHeaderView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIImageView *imageView = [UIImageView newAutoLayoutView];
        UIImage *image = [UIImage imageNamed:@"icon_bar_blue_1"];
        [imageView setImage:image];
        [self addSubview:imageView];
        
        _titleLabel = [UILabel newAutoLayoutView];
        [self addSubview:_titleLabel];
        
        _titleLabel.font = WORKFLOW_HEADERVIEW_FONT;
        _titleLabel.textColor = WORKFLOW_SECTIONHEADERVIEW_COLOR;

        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [_titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:kTitleLeftSpace];
        [_titleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
        [_titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:imageView withOffset:10];
        [_titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [imageView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
        [imageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:20];
        [imageView autoSetDimension:ALDimensionHeight toSize:10 ];
        [imageView autoSetDimension:ALDimensionWidth toSize:3];
        
    }
    
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end
